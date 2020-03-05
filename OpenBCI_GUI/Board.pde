
abstract class Board {

    public abstract boolean initialize();

    public abstract void uninitialize();

    public abstract void update();

    public abstract void startStreaming();

    public abstract void stopStreaming();

    public abstract boolean isConnected();

    public abstract int getSampleRate();
    
    public abstract int getNumChannels();

    public abstract void setChannelActive(int channelIndex, boolean active);

    public abstract void sendCommand(String command);

    public abstract void setSampleRate(int sampleRate);

    public boolean isDigitalActive() { return false; }

    public boolean isDigitalAvailable() { return false; }

    public void setDigitalActive(boolean active) {
        outputWarn("setDigitalActive is not implemented for this board.");
    }

    public boolean isMarkerActive() { return false; }

    public boolean isMarkerAvailable() { return false; }

    public void setMarkerActive(boolean active) {
        outputWarn("setMarkerActive is not implemented for this board.");
    }
};
