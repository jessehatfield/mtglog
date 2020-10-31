package mtg.logic.combo;

import mtg.logic.Deck;

import java.util.Map;

public class AllSpellsDeck extends Deck {
    public AllSpellsDeck(int[] counts) {
        super(cards, decodeMaindeck(counts), decodeSideboard(counts), deckSize);
    }

    private static int[] decodeMaindeck(int[] counts) {
        int[] maindeck = new int[cards.length];
        assert fourofs + counts.length <= cards.length;
        for (int i = 0; i < cards.length; i++) {
            //Assume we have 4 of each of the first <fourofs> cards
            if (i < fourofs) {
                maindeck[i] = 4;
            } else {
                //Add one of each of the next <oneofs> cards
                if (i < (fourofs + oneofs)) {
                    maindeck[i] = 1;
                } else {
                    maindeck[i] = 0;
                }
                //Then apply the counts, skipping the (already added) four-ofs.
                //Note that this allows us to add extra copies of the required
                //one-ofs, possibly to a total of 5. Only use if that's not a
                //problem. If the counts vector isn't as long as the list of
                //cards, leave the last few cards at zero.
                if (i < fourofs + counts.length) {
                    maindeck[i] += counts[i-fourofs];
                }
            }
        }
        return maindeck;
    }

    private static int[] decodeSideboard(int[] counts) {
        int[] sideboard = new int[cards.length];
        for (int i = 0; i < sideboard.length; i++) {
            sideboard[i] = 0;
        }
        return sideboard;
    }

    //All relevant cards that might be in the deck.
    private static final int fourofs = 5;
    private static final int oneofs = 2;
    static final String[] cards = {
            // Always 4-ofs
            "Balustrade Spy",
            "Undercity Informer",
            "Narcomoeba", // can work as a 3-of but test that later; tests with 1-2 waste too much time
            "Lotus Petal",
            "Dark Ritual",

            //2
            //At least 1-ofs (allow 5-ofs for now; assuming that won't matter)
            "Dread Return",
            "Thassa's Oracle",

            //5 reliable starting mana sources
            "Chrome Mox",
            "Elvish Spirit Guide",
            "Simian Spirit Guide",
            "Summoner's Pact",
            "Chancellor of the Tangle",

            //2 mana filtering effects
            "Manamorphose",
            "Wild Cantor",

            //9 ritual effects of varying quality
            "Mox Opal",
            "Tinder Wall",
            "Rite of Flame",
            "Grim Monolith",
            "Cabal Ritual",
            "Pyretic Ritual",
            "Desperate Ritual",
            "Seething Song",
            "Lion's Eye Diamond",

            //1 less efficient win condition(s)
            "Goblin Charbelcher",

            //5 different lands that don't count as lands
            "Emeria's Call",
            "Sea Gate Restoration",
            "Agadeem's Awakening",
            "Shatterskull Smashing",
            "Turntimber Symbiosis",

            //4 simple protection spells
            "Pact of Negation",
            "Force of Will",
            "Unmask",
            "Chancellor of the Annex",

            //7 narrower protection spells
            "Cabal Therapy",
            "Thoughtseize",
            "Silence",
            "Orim\'s Chant",
            "Veil of Summer",
            "Misdirection",
            "Leyline of Lifeforce",

            //1 Non-immediate win condition
            "Empty the Warrens",

            //3 ways to get cards into the graveyard (unused for now)
            "Bridge from Below",
            "Lingering Souls",
            "Phantasmagorian",

            //6 misc. (unused for now)
            "Street Wraith",
            "Living Wish",
            "Cephalid Illusionist",
            "Shuko",
            "Burning Wish"
    };
    private final static int deckSize = 60;

    public static void main(String[] args) {
        int maxCards = cards.length - fourofs;
        if (args.length > maxCards) {
            System.out.println("Usage: AllSpellsDeck <vector of length <= " + cards.length + ">");
            System.exit(1);
        } else {
            final int[] vector = new int[args.length];
            for (int i = 0; i < vector.length; i++) {
                vector[i] = Integer.parseInt(args[i]);
            }
            final Map<String, Integer> counts = new AllSpellsDeck(vector).getCounts();
            for (String card : cards) {
                final int n = counts.getOrDefault(card, 0);
                if (n > 0) {
                    System.out.println(n + " " + card);
                }
            }
        }
    }
}
