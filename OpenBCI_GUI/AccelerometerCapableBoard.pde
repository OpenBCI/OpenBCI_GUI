
interface AccelerometerCapableBoard {

    public boolean isAccelerometerActive();

    public void setAccelerometerActive(boolean active);

    public boolean canDeactivateAccelerometer();

    public int[] getAccelerometerChannels();

    public List<double[]> getDataWithAccel(int maxSamples);

    public int getAccelSampleRate();
};
