
abstract class Board {

    public abstract boolean initialize();

    public abstract void uninitialize();

    public abstract void update();

    public abstract void startStreaming();

    public abstract void stopStreaming();

    public abstract int getSampleRate();
    
    public abstract int getNumChannels();

    // TODO[brainflow] do we need this? Or could this be set in the datapacket class?
    public abstract float[] getLastAccelValues();

    public boolean isAccelerometerActive() { return false; }

    public boolean isAccelerometerAvailable() { return false; }

    public boolean isAnalogActive() { return false; }

    public boolean isAnalogAvailable() { return false; }

    public boolean isDigitalActive() { return false; }

    public boolean isDigitalAvailable() { return false; }

    public boolean isMarkerActive() { return false; }

    public boolean isMarkerAvailable() { return false; }

    public abstract void setChannelActive(int channelIndex, boolean active);
};
