
interface AnalogCapableBoard {

    public boolean isAnalogActive();

    public void setAnalogActive(boolean active);

    public boolean canDeactivateAnalog();

    public int[] getAnalogChannels();

    public List<double[]> getDataWithAnalog(int maxSamples);

    public int getAnalogSampleRate();
};
