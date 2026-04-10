class BoardGanglionNative extends BoardGanglion {

    private PacketLossTrackerGanglionBLE packetLossTrackerGanglionNative;
    private String boardName;
    private int firmwareVersion;

    public BoardGanglionNative() {
        super();
    }

    public BoardGanglionNative(GanglionDevice device) {
        super();
        this.boardName = device.identifier;
        this.firmwareVersion = device.firmware_version;
    }

    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.serial_number = boardName;
        return params;
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
        if (firmwareVersion == 2) {
            packetLossTrackerGanglionNative = new PacketLossTrackerGanglionBLE2(getSampleIndexChannel(), getTimestampChannel());
        }
        else if (firmwareVersion == 3) {
            packetLossTrackerGanglionNative = new PacketLossTrackerGanglionBLE3(getSampleIndexChannel(), getTimestampChannel());
        }

        packetLossTrackerGanglionNative.setAccelerometerActive(isAccelerometerActive());
        return packetLossTrackerGanglionNative;
    }
};

class BoardGanglionBLE extends BoardGanglion {

    private int firmwareVersion;
    private PacketLossTrackerGanglionBLE packetLossTrackerGanglionBLE;

    public BoardGanglionBLE() {
        super();
    }

    public BoardGanglionBLE(GanglionDevice device, String serialPort) {
        super();
        this.serialPort = serialPort;
        this.macAddress = device.mac_address;
        this.firmwareVersion = device.firmware_version;
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
        if (firmwareVersion == 2) {
            packetLossTrackerGanglionBLE = new PacketLossTrackerGanglionBLE2(getSampleIndexChannel(), getTimestampChannel());
        }
        else if (firmwareVersion == 3) {
            packetLossTrackerGanglionBLE = new PacketLossTrackerGanglionBLE3(getSampleIndexChannel(), getTimestampChannel());
        }

        packetLossTrackerGanglionBLE.setAccelerometerActive(isAccelerometerActive());
        return packetLossTrackerGanglionBLE;
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
        channelNames[getMarkerChannel()] = "Marker Channel";
    }

    @Override
    public List<double[]> getDataWithAccel(int maxSamples) {
        return getData(maxSamples);
    }

    @Override
    public int getAccelSampleRate() {
        return getSampleRate();
    }

    @Override
    public String[] getChannelNames() {
        String[] output = super.getChannelNames();
        int[] resistanceChannels = getResistanceChannels();
        for (int i = 0; i < resistanceChannels.length - 1; i++) {
            output[resistanceChannels[i]] = "Impedance Channel " + i;
        }
        output[resistanceChannels[resistanceChannels.length - 1]] = "Impedance Channel Reference";
        return output;
    }
};
