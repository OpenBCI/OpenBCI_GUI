interface FilterSettingsEnum {
    public String getString();
}

public enum BFFilter implements FilterSettingsEnum
{
    BANDSTOP (0, "BandStop"),
    BANDPASS (1, "BandPass");

    private int index;
    private String name;
 
    BFFilter(int index, String name) {
        this.index = index;
        this.name = name;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }
}

public enum FilterChannelSelect implements FilterSettingsEnum
{
    ALL_CHANNELS (0, "All Channels"),
    CUSTOM_CHANNELS (1, "Per Channel");

    private int index;
    private String name;
 
    FilterChannelSelect(int index, String name) {
        this.index = index;
        this.name = name;
    }

    public int getIndex() {
        return index;
    }

    public String getString() {
        return name;
    }
}

enum GlobalEnvironmentalFilter implements FilterSettingsEnum {
    FIFTY (0, "50 Hz"),
    SIXTY (1, "60 Hz"),
    FIFTY_AND_SIXTY (2, "50 + 60 Hz"),
    NONE (3, "None");

    private int index;
    private String name;

    GlobalEnvironmentalFilter(int index, String name) {
        this.index = index;
        this.name = name;
    }

    public int getIndex() {
        return index;
    }

    public String getString() {
        return name;
    }
}

enum FilterActiveOnChannel implements FilterSettingsEnum {
    ON (0, "Active"),
    OFF (1, "Inactive");

    private int index;
    private String name;

    FilterActiveOnChannel(int index, String name) {
        this.index = index;
        this.name = name;
    }

    public int getIndex() {
        return index;
    }

    public String getString() {
        return name;
    }

    public boolean isActive() {
        return name.equals("Active");
    }
}

enum BrainFlowFilterType implements FilterSettingsEnum {
    BUTTERWORTH (0, "Butterworth", FilterTypes.BUTTERWORTH.get_code()),
    CHEBYSHEV (1, "Chebyshev", FilterTypes.CHEBYSHEV_TYPE_1.get_code()),
    BESSEL (2, "Bessel", FilterTypes.BESSEL.get_code());

    private int index;
    private String name;
    private int value;

    BrainFlowFilterType(int index, String name, int value) {
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

    private int getValue() {
        return value;
    }
}

public enum BrainFlowFilterOrder implements FilterSettingsEnum {
    TWO (0, "2", 2),
    THREE (1, "3", 3),
    FOUR (2, "4", 4);

    private int index;
    private String name;
    private int value;

    BrainFlowFilterOrder(int index, String name, int value) {
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