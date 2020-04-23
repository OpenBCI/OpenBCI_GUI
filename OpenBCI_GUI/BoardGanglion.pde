class BoardGanglion extends BoardBrainFlow implements AccelerometerCapableBoard {

    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars =  {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    
    private String serialPort = "";
    private String macAddress = "";
    private String ipAddress = "";
    private BoardIds boardId = BoardIds.GANGLION_BOARD;
    private boolean isCheckingImpedance = false;
    private boolean isGettingAccel = false;

    public BoardGanglion(String serialPort, String macAddress) {
        super();
        this.serialPort = serialPort;
        this.macAddress = macAddress;

        boardId = BoardIds.GANGLION_BOARD;
    }

    public BoardGanglion(String ipAddress) {
        super();
        this.ipAddress = ipAddress;

        boardId = BoardIds.GANGLION_WIFI_BOARD;
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.serial_port = serialPort;
        params.mac_address = macAddress;
        params.ip_address = ipAddress;
        params.ip_port = 6677;
        return params;
    }

    @Override
    public BoardIds getBoardId() {
        return boardId;
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        if (channelIndex >= getNumEXGChannels()) {
            println("ERROR: Can't toggle channel " + (channelIndex + 1) + " when there are only " + getNumEXGChannels() + "channels");
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
    public int[] getAccelerometerChannels() {
        try {
            return BoardShim.get_accel_channels(getBoardIdInt());
        } catch (BrainFlowError e) {
            println("Error when getting accel channels.");
            e.printStackTrace();
            return new int[0];
        }
    }

    public void setCheckingImpedance(boolean checkImpedance) {
        configBoard(checkImpedance ? "z" : "Z");
        isCheckingImpedance = checkImpedance;
    }
    
    public boolean isCheckingImpedance() {
        return isCheckingImpedance;
    }
};
