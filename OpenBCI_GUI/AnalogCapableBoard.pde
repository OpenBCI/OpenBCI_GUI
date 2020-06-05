
interface AnalogCapableBoard {

    public boolean isAnalogActive();

    public void setAnalogActive(boolean active);

    public boolean canDeactivateAnalog();

    public int[] getAnalogChannels();
};
