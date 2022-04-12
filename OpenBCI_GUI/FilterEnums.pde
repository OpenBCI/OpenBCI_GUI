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
    CUSTOM_CHANNELS (1, "Custom");

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

public enum BandStopRanges implements FilterSettingsEnum
{
    Sixty(0, 60.0d),
    Fifty(1, 50.0d),
    None(2, null);

    private int index;
    private Double freq;

    private static BandStopRanges[] vals = values();
 
    BandStopRanges(int index, Double freq) {
        this.index = index;
        this.freq = freq;
    }

    public int getIndex() {
        return index;
    }
 
    public Double getFreq() {
        return freq;
    }

    public static BandStopRanges getByIndex(int i)
    {
        return vals[i];
    }

    public BandStopRanges next()
    {
        return vals[(this.ordinal() + 1) % vals.length];
    }

    public String getString() {
        if (freq == null) {
            return "None";
        }
        return freq.intValue() + "Hz";
    }
}

public enum BandPassRanges implements FilterSettingsEnum
{
    FiveToFifty(0, 5.0d, 50.0d),
    SevenToThirteen(1, 7.0d, 13.0d),
    FifteenToFifty(2, 15.0d, 50.0d),
    OneToFifty(3, 1.0d, 50.0d),
    OneToHundred(4, 1.0d, 100.0d),
    None(5, null, null);

    private int index;
    private Double start;
    private Double stop;

    private static BandPassRanges[] vals = values();
 
    BandPassRanges(int index, Double start, Double stop) {
        this.index = index;
        this.start = start;
        this.stop = stop;
    }

    public int getIndex() {
        return index;
    }
 
    public Double getStart() {
        return start;
    }

    public Double getStop() {
        return stop;
    }

    public static BandPassRanges getByIndex(int i)
    {
        return vals[i];
    }

    public BandPassRanges next()
    {
        return vals[(this.ordinal() + 1) % vals.length];
    }

    public String getString() {
        if ((start == null) || (stop == null)) {
            return "None";
        }
        return start.intValue() + "-" + stop.intValue() + "Hz";
    }
}