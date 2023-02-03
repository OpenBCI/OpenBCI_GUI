
interface BatteryInfoCapableBoard {

    public Integer getBatteryChannel();

    public List<double[]> getDataWithBatteryInfo(int maxSamples);

    public int getBatteryInfoSampleRate();
};
