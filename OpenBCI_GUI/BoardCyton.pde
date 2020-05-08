
import brainflow.*;

enum CytonBoardMode {
    DEFAULT(0),
    DEBUG(1),
    ANALOG(2),
    DIGITAL(3),
    MARKER(4);

    private final int value;
    CytonBoardMode(final int newValue) {
        value = newValue;
    }
    public int getValue() { return value; }
}

static class BoardCytonConstants {
    static final float series_resistor_ohms = 2200; // Ohms. There is a series resistor on the 32 bit board.
    static final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
    static final float ADS1299_gain = 24.f;  //assumed gain setting for ADS1299.  set by its Arduino code
    static final float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
    static final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code
}

class BoardCytonSerial extends BoardCyton {
    public BoardCytonSerial() {
        super();
    }

    public BoardCytonSerial(String serialPort) {
        super();
        this.serialPort = serialPort;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.CYTON_BOARD;
    }
};

class BoardCytonSerialDaisy extends BoardCyton {
    public BoardCytonSerialDaisy() {
        super();
    }
    
    public BoardCytonSerialDaisy(String serialPort) {
        super();
        this.serialPort = serialPort;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.CYTON_DAISY_BOARD;
    }
};

class BoardCytonWifi extends BoardCytonWifiBase {
    public BoardCytonWifi() {
        super();
    }
    public BoardCytonWifi(String ipAddress, int samplingRate) {
        super(samplingRate);
        this.ipAddress = ipAddress;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.CYTON_WIFI_BOARD;
    }
};

class BoardCytonWifiDaisy extends BoardCytonWifiBase {
    public BoardCytonWifiDaisy() {
        super();
    }
    public BoardCytonWifiDaisy(String ipAddress, int samplingRate) {
        super(samplingRate);
        this.ipAddress = ipAddress;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.CYTON_DAISY_WIFI_BOARD;
    }
};

abstract class BoardCytonWifiBase extends BoardCyton {
    // https://docs.openbci.com/docs/02Cyton/CytonSDK#sample-rate
    private Map<Integer, String> samplingRateCommands = new HashMap<Integer, String>() {{
        put(16000, "~0");
        put(8000, "~1");
        put(4000, "~2");
        put(2000, "~3");
        put(1000, "~4");
        put(500, "~5");
        put(250, "~6");
    }};

    public BoardCytonWifiBase() {
        super();
    }

    public BoardCytonWifiBase(int samplingRate) {
        super();
        samplingRateCache = samplingRate;
    }

    @Override
    public boolean initializeInternal() {
        boolean res = super.initializeInternal();

        if ((res) && (samplingRateCache > 0)){
            String command = samplingRateCommands.get(samplingRateCache);
            sendCommand(command);
        }
        return res;
    }
};

abstract class BoardCyton extends BoardBrainFlow
implements ImpedanceSettingsBoard, AccelerometerCapableBoard, AnalogCapableBoard, DigitalCapableBoard {
    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars = {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    private final char[] channelSelectForSettings = {'1', '2', '3', '4', '5', '6', '7', '8', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

    private double[] scalers = null;
    private Map<Character, Integer> gainCommandMap = new HashMap<Character, Integer>() {{
        put('0', 1);
        put('1', 2);
        put('2', 4);
        put('3', 6);
        put('4', 8);
        put('5', 12);
        put('6', 24);
    }};
    // same for all channels
    private final double brainflowGain = 24.0;
    
    private int[] accelChannelsCache = null;
    private int[] analogChannelsCache = null;

    private boolean[] exgChannelActive;

    protected String serialPort = "";
    protected String ipAddress = "";
    private CytonBoardMode currentBoardMode = CytonBoardMode.DEFAULT;

    public BoardCyton() {
        super();
        scalers = new double[getNumEXGChannels()];
        for (int i = 0; i < scalers.length; i++) {
            scalers[i] = 1.0;
        }
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.serial_port = serialPort;
        params.ip_address = ipAddress;
        params.ip_port = 6677;
        return params;
    }

    @Override
    public boolean initializeInternal() {        
        exgChannelActive = new boolean[getNumEXGChannels()];
        Arrays.fill(exgChannelActive, true);

        return super.initializeInternal();
    }

    @Override
    public void uninitializeInternal() {
        closeSDFile();
        super.uninitializeInternal();
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
    public boolean isAccelerometerActive() {
        return getBoardMode() == CytonBoardMode.DEFAULT;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        if(active) {
            setBoardMode(CytonBoardMode.DEFAULT);
        }
        // no way of turning off accel.
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

    @Override
    public boolean isAnalogActive() {
        return getBoardMode() == CytonBoardMode.ANALOG;
    }

    @Override
    public void setAnalogActive(boolean active) {
        if(active) {
            setBoardMode(CytonBoardMode.ANALOG);
        } else {
            setBoardMode(CytonBoardMode.DEFAULT);
        }
    }

    @Override
    public int[] getAnalogChannels() {
        if (analogChannelsCache == null) {
            try {
                analogChannelsCache = BoardShim.get_analog_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return analogChannelsCache;
    }

    @Override
    public boolean isDigitalActive() {
        return getBoardMode() == CytonBoardMode.DIGITAL;
    }

    @Override
    public void setDigitalActive(boolean active) { 
        if(active) {
            setBoardMode(CytonBoardMode.DIGITAL);
        } else {
            setBoardMode(CytonBoardMode.DEFAULT);
        }
    }

    @Override
    public int[] getDigitalChannels() {
        // the removeAll function will remove array indices 0 and 5.
        // remove other_channel[0] because it's the end byte
        // remove other_channels[5] because it does not contain digital data
        int[] digitalChannels = ArrayUtils.removeAll(getOtherChannels(), 0, 5); // remove non-digital channels
        return digitalChannels;
    }

    @Override
    public void setImpedanceSettings(int channel, char pORn, boolean active) {
        char p = '0';
        char n = '0';

        if (active) {
            if (pORn == 'p') {
                p = '1';
            }
            else if (pORn == 'n') {
                n = '1';
            }
        }

        // for example: z 4 1 0 Z
        String command = String.format("z%c%c%cZ", channelSelectForSettings[channel], p, n);
        configBoard(command);
    }

    @Override
    protected double[][] getNewDataInternal() {
        double[][] data = super.getNewDataInternal();
        int[] exgChannels = getEXGChannels();
        for (int i = 0; i < exgChannels.length; i++) {
            for (int j = 0; j < data[exgChannels[i]].length; j++) {
                data[exgChannels[i]][j] *= scalers[i];
            }
        }
        return data;
    }

    public void setChannelSettings(int channel, char[] channelSettings) {
        char powerDown = channelSettings[0];
        char gain = channelSettings[1];
        char inputType = channelSettings[2];
        char bias = channelSettings[3];
        char srb2 = channelSettings[4];
        char srb1 = channelSettings[5];

        String command = String.format("x%c%c%c%c%c%c%cX", channelSelectForSettings[channel],
                                        powerDown, gain, inputType, bias, srb2, srb1);
        configBoard(command);
        scalers[channel] = brainflowGain / gainCommandMap.get(gain);
    }

    public CytonBoardMode getBoardMode() {
        return currentBoardMode;
    }

    private void setBoardMode(CytonBoardMode boardMode) {
        configBoard("/" + boardMode.getValue());
        currentBoardMode = boardMode;
    }

    public void closeSDFile() {
        println("Closing any open SD file. Writing 'j' to OpenBCI.");
        configBoard("j"); // tell the SD file to close if one is open...
        delay(100); //make sure 'j' gets sent to the board
    }

    public void printRegisters() {
        println("Cyton: printRegisters(): Writing ? to OpenBCI...");
        configBoard("?");
    }

    public void configureAllChannelsToDefault() {
        configBoard("d");
    };
    
    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        for (int i=0; i<getAccelerometerChannels().length; i++) {
            channelNames[getAccelerometerChannels()[i]] = "Accel Channel " + i;
        }
        for (int i=0; i<getAnalogChannels().length; i++) {
            channelNames[getAnalogChannels()[i]] = "Analog Channel " + i;
        }
    }
};
