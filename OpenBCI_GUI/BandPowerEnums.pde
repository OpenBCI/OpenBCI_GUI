
public enum BPLogLin implements IndexingInterface {
    LOG (0, "Log"),
    LINEAR (1, "Linear");

    private int index;
    private String label;

    BPLogLin(int _index, String _label) {
        this.index = _index;
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
}

public enum BPVerticalScale implements IndexingInterface {
    SCALE_10 (0, 10, "10 uV"),
    SCALE_50 (1, 50, "50 uV"),
    SCALE_100 (2, 100, "100 uV"),
    SCALE_500 (3, 500, "500 uV"),
    SCALE_1000 (4, 1000, "1000 uV"),
    SCALE_1500 (5, 1500, "1500 uV");

    private int index;
    private final int value;
    private String label;

    BPVerticalScale(int index, int value, String label) {
        this.index = index;
        this.value = value;
        this.label = label;
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