public enum MarkerWindow implements IndexingInterface
{
    FIVE (0, 5, "5 sec"),
    TEN (1, 10, "10 sec"),
    TWENTY (2, 20, "20 sec");

    private int index;
    private int value;
    private String label;

    MarkerWindow(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}

public enum MarkerVertScale implements IndexingInterface
{
    AUTO (0, 0, "Auto"),
    TWO (1, 2, "2"),
    FOUR (2, 4, "4"),
    EIGHT (3, 8, "8"),
    TEN (4, 10, "10"),
    TWENTY (6, 20, "20");

    private int index;
    private int value;
    private String label;

    MarkerVertScale(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}
