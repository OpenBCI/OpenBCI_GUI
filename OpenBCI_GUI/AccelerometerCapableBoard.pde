
interface AccelerometerCapableBoard {

    public boolean isAccelerometerActive();

    public void setAccelerometerActive(boolean active);

    // TODO[brainflow] do we need this? Or could this be set in the datapacket class?
    public float[] getLastValidAccelValues();
};
