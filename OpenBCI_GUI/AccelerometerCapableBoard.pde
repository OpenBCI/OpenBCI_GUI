
interface AccelerometerCapableBoard {

    public abstract boolean isAccelerometerActive();

    public abstract void setAccelerometerActive(boolean active);

    // TODO[brainflow] do we need this? Or could this be set in the datapacket class?
    public abstract float[] getLastValidAccelValues();
};
