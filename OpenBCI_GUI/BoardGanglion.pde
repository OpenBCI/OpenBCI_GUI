class BoardGanglion extends BoardBrainFlow implements AccelerometerCapableBoard {

    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars =  {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    
    private String serialPort = "";
    private String macAddress = "";
    private boolean isCheckingImpedance = false;
    private boolean isGettingAccel = false;

    public BoardGanglion(String serialPort, String macAddress) {
        super();
        this.serialPort = serialPort;
        this.macAddress = macAddress;
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.serial_port = serialPort;
        params.mac_address = macAddress;
        return params;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.GANGLION_BOARD;
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        if (channelIndex >= getNumChannels()) {
            println("ERROR: Can't toggle channel " + (channelIndex + 1) + " when there are only " + getNumChannels() + "channels");
        }

        char[] charsToUse = active ? activateChannelChars : deactivateChannelChars;
        configBoard(str(charsToUse[channelIndex]));
    }

    @Override
    public boolean initialize()
    {
        // turn on accel by default, or is it handled somewhere else?
        boolean res = super.initialize();
        if (res)
            setAccelerometerActive(true);
        return res;
    }

    @Override
    public boolean isAccelerometerActive()
    {
        return isGettingAccel;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        configBoard(active ? "n" : "N");
        isGettingAccel = active;
    }

    @Override
    public float[] getLastValidAccelValues() {
        return lastValidAccelValues;
    }

    public void setCheckingImpedance(boolean checkImpedance) {
        configBoard(checkImpedance ? "z" : "Z");
        isCheckingImpedance = checkImpedance;
    }
    
    public boolean isCheckingImpedance() {
        return isCheckingImpedance;
    }
};
