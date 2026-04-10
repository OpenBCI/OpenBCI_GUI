public enum AccelerometerVerticalScale implements IndexingInterface
{
    AUTO (0, 0, "Auto"),
    ONE_G (1, 1, "1 g"),
    TWO_G (2, 2, "2 g"),
    FOUR_G (3, 4, "4 g");
    
    private int index;
    private int value;
    private String label;
    
    AccelerometerVerticalScale(int _index, int _value, String _label) {
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

    public int getHighestValue() {
        int highestValue = 0;
        for (AccelerometerVerticalScale scale : values()) {
            if (scale.getValue() > highestValue) {
                highestValue = scale.getValue();
            }
        }
        return highestValue;
    }
}

public enum AccelerometerHorizontalScale implements IndexingInterface
{
    ONE_SEC (1, 1, "1 sec"),
    THREE_SEC (2, 3, "3 sec"),
    FIVE_SEC (3, 5, "5 sec"),
    TEN_SEC (4, 10, "10 sec"),
    TWENTY_SEC (5, 20, "20 sec");
    
    private int index;
    private int value;
    private String label;
    
    AccelerometerHorizontalScale(int _index, int _value, String _label) {
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

    public int getHighestValue() {
        int highestValue = 0;
        for (AccelerometerHorizontalScale scale : values()) {
            if (scale.getValue() > highestValue) {
                highestValue = scale.getValue();
            }
        }
        return highestValue;
    }
}