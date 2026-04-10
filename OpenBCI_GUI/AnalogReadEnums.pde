public enum AnalogReadVerticalScale implements IndexingInterface
{
    AUTO (0, 0, "Auto"),
    FIFTY (1, 50, "50 uV"),
    ONE_HUNDRED (2, 100, "100 uV"),
    TWO_HUNDRED (3, 200, "200 uV"),
    FOUR_HUNDRED (4, 400, "400 uV"),
    ONE_THOUSAND_FIFTY (5, 1050, "1050 uV"),
    TEN_THOUSAND (6, 10000, "10000 uV");
    
    private int index;
    private int value;
    private String label;
    
    AnalogReadVerticalScale(int _index, int _value, String _label) {
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

public enum AnalogReadHorizontalScale implements IndexingInterface
{
    ONE_SEC (1, 1, "1 sec"),
    THREE_SEC (2, 3, "3 sec"),
    FIVE_SEC (3, 5, "5 sec"),
    TEN_SEC (4, 10, "10 sec"),
    TWENTY_SEC (5, 20, "20 sec");
    
    private int index;
    private int value;
    private String label;
    
    AnalogReadHorizontalScale(int _index, int _value, String _label) {
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