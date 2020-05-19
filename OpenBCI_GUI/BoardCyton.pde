
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

public enum CytonSDMode {
    NO_WRITE("Do not write to SD...", null),
    MAX_5MIN("5 minute maximum", "A"),
    MAX_15MIN("15 minute maximum", "S"),
    MAX_30MIN("30 minute maximum", "F"),
    MAX_1HR("1 hour maximum", "G"),
    MAX_2HR("2 hour maximum", "H"),
    MAX_4HR("4 hour maximum", "J"),
    MAX_12HR("12 hour maximum", "K"),
    MAX_24HR("24 hour maximum", "L");

    private String name;
    private String command;

    CytonSDMode(String _name, String _command) {
        this.name = _name;
        this.command = _command;
    }

    public String getName() {
        return name;
    }

    public String getCommand() {
        return command;
    }
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

class CytonDefaultSettings extends ADS1299Settings {
    CytonDefaultSettings(Board theBoard) {
        super(theBoard);

        // the 'd' command is automatically sent by brainflow on prepare_session
        Arrays.fill(powerDown, PowerDown.ON);
        Arrays.fill(gain, Gain.X24);
        Arrays.fill(inputType, InputType.NORMAL);
        Arrays.fill(bias, Bias.INCLUDE);
        Arrays.fill(srb2, Srb2.CONNECT);
        Arrays.fill(srb1, Srb1.DISCONNECT);
    }
}

abstract class BoardCyton extends BoardBrainFlow
implements ImpedanceSettingsBoard, AccelerometerCapableBoard, AnalogCapableBoard, DigitalCapableBoard, ADS1299SettingsBoard {
    private final char[] channelSelectForSettings = {'1', '2', '3', '4', '5', '6', '7', '8', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

    private ADS1299Settings currentADS1299Settings;
    private boolean[] isCheckingImpedance;

    // same for all channels
    private final double brainflowGain = 24.0;

    private int[] accelChannelsCache = null;
    private int[] analogChannelsCache = null;

    protected String serialPort = "";
    protected String ipAddress = "";
    private CytonBoardMode currentBoardMode = CytonBoardMode.DEFAULT;

    public BoardCyton() {
        super();

        isCheckingImpedance = new boolean[getNumEXGChannels()];
        Arrays.fill(isCheckingImpedance, false);

        // The command 'd' is automatically sent by brainflow on prepare_session
        currentADS1299Settings = new CytonDefaultSettings(this);
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
        return super.initializeInternal();
    }

    @Override
    public void uninitializeInternal() {
        closeSDFile();
        super.uninitializeInternal();
    }

    @Override
    public void setEXGChannelActive(int channelIndex, boolean active) {
        currentADS1299Settings.powerDown[channelIndex] = active ? PowerDown.ON : PowerDown.OFF;
        currentADS1299Settings.commit(channelIndex);
    }

    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return currentADS1299Settings.powerDown[channelIndex] == PowerDown.ON;
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
    public void setCheckingImpedance(int channel, boolean active) {
        char p = '0';
        char n = '0';

        if (active) {
            Srb2 srb2sSetting = currentADS1299Settings.srb2[channel];
            if (srb2sSetting == Srb2.CONNECT) {
                n = '1';
            }
            else {
                p = '1';
            }
        }

        // for example: z 4 1 0 Z
        String command = String.format("z%c%c%cZ", channelSelectForSettings[channel], p, n);
        sendCommand(command);

        isCheckingImpedance[channel] = active;
    }

    @Override
    public boolean isCheckingImpedance(int channel) {
        return isCheckingImpedance[channel];
    }

    @Override
    protected double[][] getNewDataInternal() {
        double[][] data = super.getNewDataInternal();
        int[] exgChannels = getEXGChannels();
        for (int i = 0; i < exgChannels.length; i++) {
            for (int j = 0; j < data[exgChannels[i]].length; j++) {
                // brainflow assumes a fixed gain of 24. Undo brainflow's scaling and apply new scale.
                double scalar = brainflowGain / currentADS1299Settings.gain[i].getScalar();
                data[exgChannels[i]][j] *= scalar;
            }
        }
        return data;
    }

    @Override
    public ADS1299Settings getADS1299Settings() {
        return currentADS1299Settings;
    }

    @Override
    public char getChannelSelector(int channel) {
        return channelSelectForSettings[channel];
    }

    public CytonBoardMode getBoardMode() {
        return currentBoardMode;
    }

    private void setBoardMode(CytonBoardMode boardMode) {
        sendCommand("/" + boardMode.getValue());
        currentBoardMode = boardMode;
    }

    @Override
    public void startStreaming() {
        openSDFile();
        super.startStreaming();
    }

    @Override
    public void stopStreaming() {
        closeSDFile();
        super.stopStreaming();
    }

    public void openSDFile() {
        //If selected, send command to Cyton to enabled SD file recording for selected duration
        if (cyton_sdSetting != CytonSDMode.NO_WRITE) {
            println("Opening SD file. Writing " + cyton_sdSetting.getCommand() + " to Cyton.");
            sendCommand(cyton_sdSetting.getCommand());
        }
    }

    public void closeSDFile() {
        if (cyton_sdSetting != CytonSDMode.NO_WRITE) {
            println("Closing any open SD file. Writing 'j' to Cyton.");
            sendCommand("j"); // tell the SD file to close if one is open...
        }
    }

    public void printRegisters() {
        println("Cyton: printRegisters(): Writing ? to OpenBCI...");
        sendCommand("?");
    }
    
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
