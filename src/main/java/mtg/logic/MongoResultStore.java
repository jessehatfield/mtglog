package mtg.logic;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.BsonValue;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.util.ArrayList;
import java.util.List;

public class MongoResultStore extends ResultStore {
    public static final String DECKLIST_COLLECTION_NAME = "decks";
    public static final String OBJECTIVE_COLLECTION_NAME = "objectives";
    public static final String TEST_COLLECTION_NAME = "tests";

    public static final String DECKLIST_FIELD = "maindeck";
    public static final String OBJECTIVE_FIELD = "spec";
    public static final String DECK_JOIN_FIELD = "deck_id";
    public static final String OBJECTIVE_JOIN_FIELD = "objective_id";
    public static final String SUCCESS_FIELD = "success";
    public static final String MULLIGAN_COUNT_FIELD = "mulligans";
    public static final String BOOL_OUTPUT_FIELD = "properties";
    public static final String CATEGORICAL_OUTPUT_FIELD = "categories";

    private final String connectionString;
    private final String databaseName;

    public MongoResultStore(final String connectionString,
                            final String databaseName) {
        this.connectionString = connectionString;
        this.databaseName = databaseName;
        try (final MongoClient mongoClient = MongoClients.create(connectionString)) {
            final MongoDatabase database = mongoClient.getDatabase(databaseName);
            final MongoCollection<Document> testCollection = database.getCollection(TEST_COLLECTION_NAME);
            System.out.println("Initialized connection to MongoDB database of " + testCollection.countDocuments() + " tests.");
        }
    }

    private ObjectId insertOrGetId(final MongoCollection<Document> collection, final String key, final String value) {
        final MongoCursor<Document> cursor = collection.find(Filters.eq(key, value)).cursor();
        if (cursor.hasNext()) {
            final ObjectId id = cursor.next().getObjectId("_id");
            cursor.close();
            return id;
        } else {
            cursor.close();
            Document document = new Document(key, value);
            final BsonValue idBson = collection.insertOne(document).getInsertedId();
            if (idBson == null || idBson.asObjectId() == null) {
                return null;
            } else {
                return idBson.asObjectId().getValue();
            }
        }
    }

    public void flushResults() {
        if (resultCache.isEmpty()) {
            return;
        }
        try (final MongoClient mongoClient = MongoClients.create(connectionString)) {
            final MongoDatabase database = mongoClient.getDatabase(databaseName);
            // If the decklist hasn't been stored, store it, then get its ID
            final MongoCollection<Document> deckCollection = database.getCollection(DECKLIST_COLLECTION_NAME);
            final MongoCollection<Document> specCollection = database.getCollection(OBJECTIVE_COLLECTION_NAME);
            final MongoCollection<Document> testCollection = database.getCollection(TEST_COLLECTION_NAME);
            final ObjectId deckId = insertOrGetId(deckCollection, DECKLIST_FIELD, deckRepr);
            final ObjectId objectiveId = insertOrGetId(specCollection, OBJECTIVE_FIELD, objectiveRepr);
            final List<Document> tests = new ArrayList<>(resultCache.size());
            for (ResultSequence result : resultCache) {
                final Results finalResult = result.getFinalResult();
                final Document boolOutputs = new Document();
                final Document categoricalOutputs = new Document();
                final boolean isSuccess = finalResult.getNSuccesses() > 0;
                if (isSuccess) {
                    for (String flag : objective.getBooleanOutputs()) {
                        boolOutputs.append(flag, finalResult.getBooleanMetadata(flag).get(0));
                    }
                    for (String key : objective.getCategoricalOutputs()) {
                        categoricalOutputs.append(key, finalResult.getStringMetadata(key).get(0));
                    }
                }
                final Document testDocument = new Document(DECK_JOIN_FIELD, deckId)
                        .append(OBJECTIVE_JOIN_FIELD, objectiveId)
                        .append(SUCCESS_FIELD, isSuccess)
                        .append(MULLIGAN_COUNT_FIELD, finalResult.getMulliganCounts(0))
                        .append(BOOL_OUTPUT_FIELD, boolOutputs)
                        .append(CATEGORICAL_OUTPUT_FIELD, categoricalOutputs);
                tests.add(testDocument);
            }
            testCollection.insertMany(tests);
        }
        resultCache.clear();
    }

    @Override
    public void close() {
        flushResults();
    }
}
