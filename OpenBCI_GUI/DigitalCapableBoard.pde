
interface DigitalCapableBoard {

    public boolean isDigitalActive();

    public void setDigitalActive(boolean active);

    public boolean canDeactivateDigital();

    public int[] getDigitalChannels();

    public List<double[]> getDataWithDigital(int maxSamples);
    
    public int getDigitalSampleRate();
};
