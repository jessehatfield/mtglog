package mtg.logic;

import java.util.List;
import java.util.Map;

public class SingleResult {
    private boolean success;
    private long duration;
    private Map<String, Integer> intMetadata;
    private Map<String, String> stringMetadata;
    private Map<String, Boolean> booleanMetadata;
    private Map<String, List<String>> listMetadata;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public Map<String, Integer> getIntMetadata() {
        return intMetadata;
    }

    public void setIntMetadata(Map<String, Integer> intMetadata) {
        this.intMetadata = intMetadata;
    }

    public Map<String, String> getStringMetadata() {
        return stringMetadata;
    }

    public void setStringMetadata(Map<String, String> stringMetadata) {
        this.stringMetadata = stringMetadata;
    }

    public Map<String, Boolean> getBooleanMetadata() {
        return booleanMetadata;
    }

    public void setBooleanMetadata(Map<String, Boolean> booleanMetadata) {
        this.booleanMetadata = booleanMetadata;
    }

    public Map<String, List<String>> getListMetadata() {
        return listMetadata;
    }

    public void setListMetadata(Map<String, List<String>> listMetadata) {
        this.listMetadata = listMetadata;
    }
}
