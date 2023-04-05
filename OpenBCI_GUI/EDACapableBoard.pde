
interface EDACapableBoard {

    public boolean isEDAActive();

    public void setEDAActive(boolean active);

    public int[] getEDAChannels();

    public List<double[]> getDataWithEDA(int maxSamples);

    public int getEDASampleRate();
};
