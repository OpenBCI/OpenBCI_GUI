class BoardGanglionNative extends BoardGanglion {

    private PacketLossTrackerGanglionBLE packetLossTrackerGanglionNative;

    public BoardGanglionNative() {
        super();
    }

    public BoardGanglionNative(String serialPort, String macAddress) {
        super();
        this.macAddress = macAddress;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.GANGLION_NATIVE_BOARD;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        super.setAccelerometerActive(active);

        if (packetLossTrackerGanglionNative != null) {
            // notify the packet loss tracker, because the sample indices change based
            // on whether accel is active or not
            packetLossTrackerGanglionNative.setAccelerometerActive(active);
        }
    }

    @Override
    protected PacketLossTracker setupPacketLossTracker() {
        packetLossTrackerGanglionNative = new PacketLossTrackerGanglionBLE(getSampleIndexChannel(), getTimestampChannel());
        packetLossTrackerGanglionNative.setAccelerometerActive(isAccelerometerActive());
        return packetLossTrackerGanglionNative;
    }
};

class BoardGanglionBLE extends BoardGanglion {

    private PacketLossTrackerGanglionBLE packetLossTrackerGanglionBLE;

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

    @Override
    public void setAccelerometerActive(boolean active) {
        super.setAccelerometerActive(active);

        if (packetLossTrackerGanglionBLE != null) {
            // notify the packet loss tracker, because the sample indices change based
            // on whether accel is active or not
            packetLossTrackerGanglionBLE.setAccelerometerActive(active);
        }
    }

    @Override
    protected PacketLossTracker setupPacketLossTracker() {
        packetLossTrackerGanglionBLE = new PacketLossTrackerGanglionBLE(getSampleIndexChannel(), getTimestampChannel());
        packetLossTrackerGanglionBLE.setAccelerometerActive(isAccelerometerActive());
        return packetLossTrackerGanglionBLE;
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

    @Override
    protected PacketLossTracker setupPacketLossTracker() {
        final int minSampleIndex = 0;
        final int maxSampleIndex = 200;
        return new PacketLossTracker(getSampleIndexChannel(), getTimestampChannel(),
                                    minSampleIndex, maxSampleIndex);
    }
};

abstract class BoardGanglion extends BoardBrainFlow implements AccelerometerCapableBoard {

    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars =  {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    
    private int[] accelChannelsCache = null;
    private int[] resistanceChannelsCache = null;

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
        sendCommand(str(charsToUse[channelIndex]));
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
        sendCommand(active ? "n" : "N");
        isGettingAccel = active;
    }

    @Override
    public boolean canDeactivateAccelerometer() {
        return true;
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

    public int[] getResistanceChannels() {
        if (resistanceChannelsCache == null) {
            try {
                resistanceChannelsCache = BoardShim.get_resistance_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return resistanceChannelsCache;
    }

    public void setCheckingImpedance(boolean checkImpedance) {
        if (checkImpedance) {
            if (isCheckingImpedance) {
                println("Already checking impedance.");
                return;
            }
            if (streaming) {
                stopRunning();
            }
            sendCommand("z");
            startStreaming();
            packetLossTracker = null;
        }
        else {
            if (!isCheckingImpedance) {
                println ("Impedance is not running.");
                return;
            }
            if (streaming) {
                stopStreaming();
            }
            sendCommand("Z");
            packetLossTracker = setupPacketLossTracker();
        }
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

    @Override
    public List<double[]> getDataWithAccel(int maxSamples) {
        return getData(maxSamples);
    }

    @Override
    public int getAccelSampleRate() {
        return getSampleRate();
    }
};
