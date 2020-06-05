
interface AccelerometerCapableBoard {

    public boolean isAccelerometerActive();

    public void setAccelerometerActive(boolean active);

    public boolean canDeactivateAccelerometer();

    public int[] getAccelerometerChannels();
};
