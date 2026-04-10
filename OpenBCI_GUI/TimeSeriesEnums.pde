public enum TimeSeriesXLim implements IndexingInterface
{
    ONE (0, 1, "1 sec"),
    THREE (1, 3, "3 sec"),
    FIVE (2, 5, "5 sec"),
    TEN (3, 10, "10 sec"),
    TWENTY (4, 20, "20 sec");

    private int index;
    private int value;
    private String label;

    TimeSeriesXLim(int _index, int _value, String _label) {
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

public enum TimeSeriesYLim implements IndexingInterface
{
    AUTO (0, 0, "Auto"),
    UV_10(1, 10, "10 uV"),
    UV_25(2, 25, "25 uV"),
    UV_50 (3, 50, "50 uV"),
    UV_100 (4, 100, "100 uV"),
    UV_200 (5, 200, "200 uV"),
    UV_400 (6, 400, "400 uV"),
    UV_1000 (7, 1000, "1000 uV"),
    UV_10000 (8, 10000, "10000 uV");

    private int index;
    private int value;
    private String label;

    TimeSeriesYLim(int _index, int _value, String _label) {
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

public enum TimeSeriesLabelMode implements IndexingInterface
{
    OFF (0, 0, "Off"),
    MINIMAL (1, 1, "Minimal"),
    ON (2, 2, "On");

    private int index;
    private int value;
    private String label;

    TimeSeriesLabelMode(int _index, int _value, String _label) {
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