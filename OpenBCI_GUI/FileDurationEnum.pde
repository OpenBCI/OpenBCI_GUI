public enum OdfFileDuration implements IndexingInterface {
    FIVE_MINUTES (0, 5, "5 Minutes"),
    FIFTEEN_MINUTES (1, 15, "15 Minutes"),
    THIRTY_MINUTES (2, 30, "30 Minutes"),
    SIXTY_MINUTES (3, 60, "60 Minutes"),
    ONE_HUNDRED_TWENTY_MINUTES (4, 120, "120 Minutes"),
    NO_LIMIT (5, -1, "No Limit");

    private int index;
    private int duration;
    private String label;

    OdfFileDuration(int _index, int _duration, String _label) {
        this.index = _index;
        this.duration = _duration;
        this.label = _label;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public int getValue() {
        return duration;
    }
}