class BoardGanglionBLE extends BoardGanglion {
    public BoardGanglionBLE() {
        super();
    }

    public BoardGanglionBLE(String serialPort, String macAddress) {
        super();
        this.serialPort = serialPort;
        this.macAddress = macAddress;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.GANGLION_BOARD;
    }
};

class BoardGanglionWifi extends BoardGanglion {
    // https://docs.openbci.com/docs/03Ganglion/GanglionSDK
    private Map<Integer, String> samplingRateCommands = new HashMap<Integer, String>() {{
        put(25600, "~0");
        put(12800, "~1");
        put(6400, "~2");
        put(3200, "~3");
        put(1600, "~4");
        put(800, "~5");
        put(400, "~6");
        put(200, "~7");
    }};

    public BoardGanglionWifi(String ipAddress, int samplingRate) {
        super();
        this.ipAddress = ipAddress;
        samplingRateCache = samplingRate;
    }
    
    @Override
    public boolean initializeInternal()
    {
        // turn on accel by default, or is it handled somewhere else?
        boolean res = super.initializeInternal();
        
        if ((res) && (samplingRateCache > 0)){
            String command = samplingRateCommands.get(samplingRateCache);
            sendCommand(command);
        }

        return res;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.GANGLION_WIFI_BOARD;
    }
};

abstract class BoardGanglion extends BoardBrainFlow implements AccelerometerCapableBoard {

    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars =  {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    
    private int[] accelChannelsCache = null;

    private boolean[] exgChannelActive;

    protected String serialPort = "";
    protected String macAddress = "";
    protected String ipAddress = "";
    private boolean isCheckingImpedance = false;
    private boolean isGettingAccel = false;

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
    public void setEXGChannelActive(int channelIndex, boolean active) {
        char[] charsToUse = active ? activateChannelChars : deactivateChannelChars;
        configBoard(str(charsToUse[channelIndex]));
        exgChannelActive[channelIndex] = active;
    }
    
    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return exgChannelActive[channelIndex];
    }

    @Override
    public boolean initializeInternal()
    {
        // turn on accel by default, or is it handled somewhere else?
        boolean res = super.initializeInternal();
        
        setAccelerometerActive(true);
        exgChannelActive = new boolean[getNumEXGChannels()];
        Arrays.fill(exgChannelActive, true);

        return res;
    }

    @Override
    public boolean isAccelerometerActive() {
        return isGettingAccel;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        configBoard(active ? "n" : "N");
        isGettingAccel = active;
    }

    @Override
    public int[] getAccelerometerChannels() {
        if (accelChannelsCache == null) {
            try {
                accelChannelsCache = BoardShim.get_accel_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }
        
        return accelChannelsCache;
    }

    public void setCheckingImpedance(boolean checkImpedance) {
        configBoard(checkImpedance ? "z" : "Z");
        isCheckingImpedance = checkImpedance;
    }
    
    public boolean isCheckingImpedance() {
        return isCheckingImpedance;
    }
    
    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        for (int i=0; i<getAccelerometerChannels().length; i++) {
            channelNames[getAccelerometerChannels()[i]] = "Accel Channel " + i;
        }
    }
};
