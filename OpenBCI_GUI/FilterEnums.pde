public enum BandStopRanges
{
    Sixty(60.0d),
    Fifty(50.0d),
    None(null);

    private Double freq;

    private static BandStopRanges[] vals = values();
 
    BandStopRanges(Double freq) {
        this.freq = freq;
    }
 
    public Double getFreq() {
        return freq;
    }

    public BandStopRanges next()
    {
        return vals[(this.ordinal() + 1) % vals.length];
    }

    public String getDescr() {
        if (freq == null) {
            return "None";
        }
        return freq.toString();
    }
}

public enum BandPassRanges
{
    OneToFifty(1.0d, 50.0d),
    SevenToThirteen(7.0d, 13.0d),
    FifteenToFifty(15.0d, 50.0d),
    FiveToFifty(5.0d, 50.0d),
    None(null, null);

    private Double start;
    private Double stop;

    private static BandPassRanges[] vals = values();
 
    BandPassRanges(Double start, Double stop) {
        this.start = start;
        this.stop = stop;
    }
 
    public Double getStart() {
        return start;
    }

    public Double getStop() {
        return stop;
    }

    public BandPassRanges next()
    {
        return vals[(this.ordinal() + 1) % vals.length];
    }

    public String getDescr() {
        if ((start == null) || (stop == null)) {
            return "None";
        }
        return start.toString() + "-" + stop.toString();
    }
}