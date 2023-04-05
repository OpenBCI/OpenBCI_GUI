
interface PPGCapableBoard {

    public boolean isPPGActive();

    public void setPPGActive(boolean active);

    public int[] getPPGChannels();

    public List<double[]> getDataWithPPG(int maxSamples);

    public int getPPGSampleRate();
};
