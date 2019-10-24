
interface Board {

    public void initialize();

    public void uninitialize();

    public void update();

    public void startStreaming();

    public void stopStreaming();

    public int getSampleRate();
    
    public int getNumChannels();

    public int[] getLastAccelValues();
};
