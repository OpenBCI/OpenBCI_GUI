interface EmgSettingsEnum {
    public int getIndex();
    public String getString();
}

public enum EmgWindow implements EmgSettingsEnum
{
    ONE_HUNDREDTH_SECOND (0, "0.01 s", .01f),
    ONE_TENTH_SECOND (1, "0.1 s", .1f),
    FIFTEEN_HUNDREDTHS_SECOND (2, "0.15 s", .15f),
    QUARTER_SECOND (3, "0.25 s", .25f),
    HALF_SECOND (4, "0.5 s", .5f),
    THREE_QUARTERS_SECOND (5, "0.75 s", .75f),
    ONE_SECOND (6, "1.0 s", 1f),
    TWO_SECONDS (7, "2.0 s", 2f);

    private int index;
    private String name;
    private float value;
 
    EmgWindow(int index, String name, float value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public float getValue() {
        return value;
    }
}

public enum EmgUVLimit implements EmgSettingsEnum
{
    FIFTY_UV (0, "50 uV", 50),
    ONE_HUNDRED_UV (1, "100 uV", 100),
    TWO_HUNDRED_UV (2, "200 uV", 200),
    FOUR_HUNDRED_UV (3, "400 uV", 400);

    private int index;
    private String name;
    private int value;
 
    EmgUVLimit(int index, String name, int value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public int getValue() {
        return value;
    }
}

public enum EmgCreepIncreasing implements EmgSettingsEnum
{
    POINT_9 (0, "0.9", .9f),
    POINT_95 (1, "0.95", .95f),
    POINT_98 (2, "0.98", .98f),
    POINT_99 (3, "0.99", .99f),
    POINT_999 (4, "0.999", .999f),
    POINT_9999 (5, "0.9999", .9999f),
    POINT_99999 (6, "0.99999", .99999f);
    
    private int index;
    private String name;
    private float value;
 
    EmgCreepIncreasing(int index, String name, float value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public float getValue() {
        return value;
    }
}

public enum EmgCreepDecreasing implements EmgSettingsEnum
{
    POINT_9 (0, "0.9", .9f),
    POINT_95 (1, "0.95", .95f),
    POINT_98 (2, "0.98", .98f),
    POINT_99 (3, "0.99", .99f),
    POINT_999 (4, "0.999", .999f),
    POINT_9999 (5, "0.9999", .9999f),
    POINT_99999 (6, "0.99999", .99999f);
    
    private int index;
    private String name;
    private float value;
 
    EmgCreepDecreasing(int index, String name, float value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public float getValue() {
        return value;
    }
}

public enum EmgMinimumDeltaUV implements EmgSettingsEnum
{
    TWO_UV (0, "2 uV", 2),
    FOUR_UV (1, "4 uV", 4),
    SIX_UV (2, "6 uV", 6),
    EIGHT_UV (3, "8 uV", 8),
    TEN_UV (4, "10 uV", 10),
    TWENTY_UV (5, "20 uV", 20),
    FORTY_UV (6, "40 uV", 40),
    EIGHTY_UV (7, "80 uV", 80);

    private int index;
    private String name;
    private int value;
 
    EmgMinimumDeltaUV(int index, String name, int value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public int getValue() {
        return value;
    }
}

public enum EmgLowerThresholdMinimum implements EmgSettingsEnum
{
    ZERO_UV (0, "0 uV", 0),
    TWO_UV (1, "2 uV", 2),
    FOUR_UV (2, "4 uV", 4),
    SIX_UV (3, "6 uV", 6),
    EIGHT_UV (4, "8 uV", 8),
    TEN_UV (5, "10 uV", 10),
    FIFTEEN_UV (6, "15 uV", 15),
    TWENTY_UV (7, "20 uV", 20),
    THIRTY_UV (8, "30 uV", 30),
    FORTY_UV (9, "40 uV", 40);

    private int index;
    private String name;
    private int value;
 
    EmgLowerThresholdMinimum(int index, String name, int value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public int getValue() {
        return value;
    }
}