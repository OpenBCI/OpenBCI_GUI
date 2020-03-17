class BoardGanglion extends BoardBrainFlow {

    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars =  {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    
    private String serialPort = "";
    private String macAddress = "";
    private String ipAddress = "";
    private BoardIds boardId = BoardIds.GANGLION_BOARD;
    private boolean isCheckingImpedance = false;

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
        if (channelIndex >= getNumChannels()) {
            println("ERROR: Can't toggle channel " + (channelIndex + 1) + " when there are only " + getNumChannels() + "channels");
        }

        char[] charsToUse = active ? activateChannelChars : deactivateChannelChars;
        configBoard(str(charsToUse[channelIndex]));
    }

    public void setAccelSettings(boolean active) {
        configBoard(active ? "n" : "N");
    }

    public void setCheckingImpedance(boolean checkImpedance) {
        configBoard(checkImpedance ? "z" : "Z");
        isCheckingImpedance = checkImpedance;
    }
    
    public boolean isCheckingImpedance() {
        return isCheckingImpedance;
    }
};
