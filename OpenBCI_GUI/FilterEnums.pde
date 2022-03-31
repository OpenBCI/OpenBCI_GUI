interface FilterEnum {
    public String getName();
}

public enum BandStopRanges implements FilterEnum
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

    public String getName() {
        if (freq == null) {
            return "None";
        }
        return freq.intValue() + "Hz";
    }
}

public enum BandPassRanges implements FilterEnum
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

    public String getName() {
        if ((start == null) || (stop == null)) {
            return "None";
        }
        return start.intValue() + "-" + stop.intValue() + "Hz";
    }
}