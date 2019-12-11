
abstract class Board {

    public abstract boolean initialize();

    public abstract void uninitialize();

    public abstract void update();

    public abstract void startStreaming();

    public abstract void stopStreaming();

    public abstract boolean isConnected();

    public abstract int getSampleRate();
    
    public abstract int getNumChannels();

    // TODO[brainflow] do we need this? Or could this be set in the datapacket class?
    public abstract float[] getLastAccelValues();

    public abstract void setChannelActive(int channelIndex, boolean active);

    public void sendCommand(String command) {
        outputWarn("Sending commands is not implemented for this board. Command: " + command);
    }

    public void setSampleRate(int sampleRate) {
        outputWarn("Changing the sampling rate is not implemented. Sampling rate will stay at " + getSampleRate());
    }

    public boolean isAccelerometerActive() { return false; }

    public boolean isAccelerometerAvailable() { return false; }

    public void setAccelerometerActive(boolean active) { }

    public boolean isAnalogActive() { return false; }

    public boolean isAnalogAvailable() { return false; }

    public void setAnalogActive(boolean active) { }

    public boolean isDigitalActive() { return false; }

    public boolean isDigitalAvailable() { return false; }

    public void setDigitalActive(boolean active) { }

    public boolean isMarkerActive() { return false; }

    public boolean isMarkerAvailable() { return false; }

    public void setMarkerActive(boolean active) { }
};
