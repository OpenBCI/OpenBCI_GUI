
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

class BoardCytonWifi extends BoardCyton {
    public BoardCytonWifi() {
        super();
    }
    public BoardCytonWifi(String ipAddress) {
        super();
        this.ipAddress = ipAddress;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.CYTON_WIFI_BOARD;
    }
};

class BoardCytonWifiDaisy extends BoardCyton {
    public BoardCytonWifiDaisy() {
        super();
    }
    public BoardCytonWifiDaisy(String ipAddress) {
        super();
        this.ipAddress = ipAddress;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.CYTON_DAISY_WIFI_BOARD;
    }
};

abstract class BoardCyton extends BoardBrainFlow
implements ImpedanceSettingsBoard, AccelerometerCapableBoard, AnalogCapableBoard, DigitalCapableBoard, MarkerCapableBoard {
    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars = {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    private final char[] channelSelectForSettings = {'1', '2', '3', '4', '5', '6', '7', '8', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    
    private int[] accelChannelsCache = null;
    private int[] analogChannelsCache = null;

    private boolean[] exgChannelActive;

    protected String serialPort = "";
    protected String ipAddress = "";
    private CytonBoardMode currentBoardMode = CytonBoardMode.DEFAULT;

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
        // TODO[brainflow]
        return new int[0];
        // return digitalChannels;
    }

    @Override
    public boolean isMarkerActive() {
        return getBoardMode() == CytonBoardMode.MARKER;
    }

    @Override
    public void setMarkerActive(boolean active) {
        if(active) {
            setBoardMode(CytonBoardMode.MARKER);
        } else {
            setBoardMode(CytonBoardMode.DEFAULT);
        }
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


// TODO[brainflow] keeping this ghost alive because the InterfaceSerial class does some magic to 
// test serial ports and switch channels.

///////////////////////////////////////////////////////////////////////////////
//
// This class configures and manages the connection to the OpenBCI shield for
// the Arduino.  The connection is implemented via a Serial connection.
// The OpenBCI is configured using single letter text commands sent from the
// PC to the Arduino.  The EEG data streams back from the Arduino to the PC
// continuously (once started).  This class defaults to using binary transfer
// for normal operation.
//
// Created: Chip Audette, Oct 2013
// Modified: through April 2014
// Modified again: Conor Russomanno Sept-Oct 2014
// Modified for Daisy (16-chan) OpenBCI V3: Conor Russomanno Nov 2014
// Modified Daisy Behaviors: Chip Audette Dec 2014
//
// Note: this class now expects the data format produced by OpenBCI V3.
//
/////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

// final char command_stop = 's';
// // final String command_startText = "x";
// final char command_startBinary = 'b';

// final char[] command_deactivate_channel = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
// final char[] command_activate_channel = {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

// enum BoardMode {
//     DEFAULT(0),
//     DEBUG(1),
//     ANALOG(2),
//     DIGITAL(3),
//     MARKER(4);

//     private final int value;
//     BoardMode(final int newValue) {
//         value = newValue;
//     }
//     public int getValue() { return value; }
// }

//------------------------------------------------------------------------
//                       Classes
//------------------------------------------------------------------------

class CytonLegacy {

    private final char command_startBinary = 'b';
    private final char command_stop = 's';
    private final char[] command_deactivate_channel = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] command_activate_channel =  {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

    private int nEEGValuesPerPacket = 8; //defined by the data format sent by cyton boards
    private int nAuxValuesPerPacket = 3; //defined by the data format sent by cyton boards
    private DataPacket_ADS1299 rawReceivedDataPacket;
    private DataPacket_ADS1299 missedDataPacket;
    private DataPacket_ADS1299 dataPacket;

    private final int fsHzSerialCyton = 250;  //sample rate used by OpenBCI board...set by its Arduino code
    private final int fsHzSerialCytonDaisy = 125;  //sample rate used by OpenBCI board...set by its Arduino code
    private final int fsHzWifi = 1000;  //sample rate used by OpenBCI board...set by its Arduino code
    private final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
    private float ADS1299_gain = 24.0;  //assumed gain setting for ADS1299.  set by its Arduino code
    private float openBCI_series_resistor_ohms = 2200; // Ohms. There is a series resistor on the 32 bit board.
    private float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
    private final float scale_fac_accel_G_per_count = 0.002 / ((float)pow(2, 4));  //assume set to +/4G, so 2 mG per digit (datasheet). Account for 4 bits unused
    //private final float scale_fac_accel_G_per_count = 1.0;  //to test stimulations  //final float scale_fac_accel_G_per_count = 1.0;
    private final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code

    private int curBoardMode = 0;

    private BoardProtocol curInterface = BoardProtocol.SERIAL;
    private int sampleRate = fsHzWifi;

    // needed by interfaceserial
    public int hardwareSyncStep = 0; //start this at 0...
    public String potentialFailureMessage = "";
    public String defaultChannelSettings = "";
    public String daisyOrNot = "";

    //used to detect and flag error during initialization
    public boolean daisyNotAttached = false;

    //some get methods
    public float getSampleRate() {
        if (isSerial()) {
            if (nchan == NCHAN_CYTON_DAISY) {
                return fsHzSerialCytonDaisy;
            } else {
                return fsHzSerialCyton;
            }
        } else {
            return hub.getSampleRate();
        }
    }

    public int getBoardMode() {
        return curBoardMode;
    }
    
    public BoardProtocol getInterface() {
        return curInterface;
    }

    public float get_series_resistor() {
        return openBCI_series_resistor_ohms;
    }
    public float get_scale_fac_uVolts_per_count() {
        return scale_fac_uVolts_per_count;
    }
    public float get_scale_fac_accel_G_per_count() {
        return scale_fac_accel_G_per_count;
    }
    public float get_leadOffDrive_amps() {
        return leadOffDrive_amps;
    }

    public void setBoardMode(int boardMode) {
        hub.sendCommand("/" + boardMode);
        curBoardMode = boardMode;
        println("Cyton: setBoardMode to :" + curBoardMode);
    }

    public void setSampleRate(int _sampleRate) {
        sampleRate = _sampleRate;
        // output("Setting sample rate for Cyton to " + sampleRate + "Hz");
        println("Setting sample rate for Cyton to " + sampleRate + "Hz");
        hub.setSampleRate(sampleRate);
    }

    public boolean setInterface(BoardProtocol _interface) {
        curInterface = _interface;
        // println("current interface: " + curInterface);
        println("setInterface: curInterface: " + selectedProtocol);
        if (isWifi()) {
            //setSampleRate((int)fsHzWifi);
            hub.setProtocol(PROTOCOL_WIFI);
        } else if (isSerial()) {
            //setSampleRate((int)fsHzSerialCyton);
            hub.setProtocol(PROTOCOL_SERIAL);
        }
        return true;
    }

    //constructors
    CytonLegacy() {};  //only use this if you simply want access to some of the constants
    CytonLegacy(PApplet applet, String comPort, int baud, int nEEGValuesPerOpenBCI, boolean useAux, int nAuxValuesPerOpenBCI, BoardProtocol _interface) {
        curInterface = _interface;

        initDataPackets(nEEGValuesPerOpenBCI, nAuxValuesPerOpenBCI);

        if (isSerial()) {
            hub.connectSerial(comPort);
        } else if (isWifi()) {
            hub.connectWifi(comPort);
        }
    }

    public void initDataPackets(int _nEEGValuesPerPacket, int _nAuxValuesPerPacket) {
        nEEGValuesPerPacket = _nEEGValuesPerPacket;
        nAuxValuesPerPacket = _nAuxValuesPerPacket;
        //allocate space for data packet
        rawReceivedDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
        missedDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
        dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);            //this could be 8 or 16 channels
        //set all values to 0 so not null

        for (int i = 0; i < nEEGValuesPerPacket; i++) {
            rawReceivedDataPacket.values[i] = 0;
            //prevDataPacket.values[i] = 0;
        }

        for (int i=0; i < nEEGValuesPerPacket; i++) {
            dataPacket.values[i] = 0;
            missedDataPacket.values[i] = 0;
        }
        for (int i = 0; i < nAuxValuesPerPacket; i++) {
            rawReceivedDataPacket.auxValues[i] = 0;
            dataPacket.auxValues[i] = 0;
            missedDataPacket.auxValues[i] = 0;
            //prevDataPacket.auxValues[i] = 0;
        }
    }

    public int closeSDandPort() {
        closeSDFile();
        return closePort();
    }

    public int closePort() {
        if (isSerial()) {
            return hub.disconnectSerial();
        } else {
            return hub.disconnectWifi();
        }
    }

    public int closeSDFile() {
        println("Closing any open SD file. Writing 'j' to OpenBCI.");
        if (isPortOpen()) write('j'); // tell the SD file to close if one is open...
        delay(100); //make sure 'j' gets sent to the board
        return 0;
    }

    public void syncWithHardware(int sdSetting) {
        switch (hardwareSyncStep) {
        case 1: //send # of channels (8 or 16) ... (regular or daisy setup)
            println("Cyton: syncWithHardware: [1] Sending channel count (" + nchan + ") to OpenBCI...");
            if (nchan == 8) {
            write('c');
            }
            if (nchan == 16) {
            write('C', false);
            }
            break;
        case 2: //reset hardware to default registers
            println("Cyton: syncWithHardware: [2] Reseting OpenBCI registers to default... writing \'d\'...");
            write('d'); // TODO: Why does this not get a $$$ readyToSend = false?
            break;
        case 3: //ask for series of channel setting ASCII values to sync with channel setting interface in GUI
            println("Cyton: syncWithHardware: [3] Retrieving OpenBCI's channel settings to sync with GUI... writing \'D\'... waiting for $$$...");
            write('D', false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
        case 4: //check existing registers
            println("Cyton: syncWithHardware: [4] Retrieving OpenBCI's full register map for verification... writing \'?\'... waiting for $$$...");
            write('?', false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
        case 5:
            // write("j"); // send OpenBCI's 'j' commaned to make sure any already open SD file is closed before opening another one...
            switch (sdSetting) {
            case 1: //"5 min max"
                write('A', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 2: //"15 min max"
                write('S', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 3: //"30 min max"
                write('F', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 4: //"1 hr max"
                write('G', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 5: //"2 hr max"
                write('H', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 6: //"4 hr max"
                write('J', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 7: //"12 hr max"
                write('K', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            case 8: //"24 hr max"
                write('L', false); //wait for $$$ to iterate... applies to commands expecting a response
                break;
            default:
                break; // Do Nothing
            }
            println("Cyton: syncWithHardware: [5] Writing selected SD setting (" + sdSettingString + ") to OpenBCI...");
            //final hacky way of abandoning initiation if someone selected daisy but doesn't have one connected.
            // if(abandonInit){
            //     haltSystem();
            //     output("No daisy board present. Make sure you selected the correct number of channels.");
            //     controlPanel.open();
            //     abandonInit = false;
            // }
            break;
        case 6:
            println("Cyton: syncWithHardware: The GUI is done initializing. Click outside of the control panel to interact with the GUI.");
            hub.changeState(HubState.STOPPED);
            systemMode = 10;
            controlPanel.close();
            topNav.controlPanelCollapser.setIsActive(false);
            //renitialize GUI if nchan has been updated... needs to be built
            break;
        }
    }

    public boolean write(char val) {
        if (hub.isHubRunning()) {
            hub.sendCommand(val);
            return true;
        }
        return false;
    }

    public boolean write(char val, boolean _readyToSend) {
        return write(val);
    }

    private boolean isSerial () {
        // println("My interface is " + curInterface);
        return curInterface == BoardProtocol.SERIAL;
    }

    private boolean isWifi () {
        return curInterface == BoardProtocol.WIFI;
    }

    public void startDataTransfer() {
        if (isPortOpen()) {
            // Now give the command to start binary data transmission
            if (isSerial()) {
                hub.changeState(HubState.NORMAL);  // make sure it's now interpretting as binary
                println("Cyton: startDataTransfer(): writing \'" + command_startBinary + "\' to the serial port...");
                write(command_startBinary);
            } else if (isWifi()) {
                println("Cyton: startDataTransfer(): writing \'" + command_startBinary + "\' to the wifi shield...");
                write(command_startBinary);
            }

        } else {
            println("Cyton: Port not open");
        }
    }

    public void stopDataTransfer() {
        if (isPortOpen()) {
            hub.changeState(HubState.STOPPED);  // make sure it's now interpretting as binary
            println("Cyton: startDataTransfer(): writing \'" + command_stop + "\' to the serial port...");
            write(command_stop);// + "\n");
        }
    }

    public void printRegisters() {
        if (isPortOpen()) {
            println("Cyton: printRegisters(): Writing ? to OpenBCI...");
            write('?');
        }
    }

    private boolean isPortOpen() {
        if (isWifi() || isSerial()) {
            return hub.isPortOpen();
        } else {
            return false;
        }
    }

    //activate or deactivate an EEG channel...channel counting is zero through nchan-1
    public void changeChannelState(int Ichan, boolean activate) {
        if (isPortOpen()) {
            // if ((Ichan >= 0) && (Ichan < command_activate_channel.length)) {
            if ((Ichan >= 0)) {
                if (activate) {
                    // write(command_activate_channel[Ichan]);
                    // gui.cc.powerUpChannel(Ichan);
                    w_timeSeries.hsc.powerUpChannel(Ichan);
                } else {
                    // write(command_deactivate_channel[Ichan]);
                    // gui.cc.powerDownChannel(Ichan);
                    w_timeSeries.hsc.powerDownChannel(Ichan);
                }
            }
        }
    }

    //deactivate an EEG channel...channel counting is zero through nchan-1
    public void deactivateChannel(int Ichan) {
        if (isPortOpen()) {
            if ((Ichan >= 0) && (Ichan < command_deactivate_channel.length)) {
                write(command_deactivate_channel[Ichan]);
            }
        }
    }

    //activate an EEG channel...channel counting is zero through nchan-1
    public void activateChannel(int Ichan) {
        if (isPortOpen()) {
            if ((Ichan >= 0) && (Ichan < command_activate_channel.length)) {
                write(command_activate_channel[Ichan]);
            }
        }
    }

    public void configureAllChannelsToDefault() {
        write('d');
    };

    /**
      * Used to convert a gain from the hub back into local codes.
      */
    public char getCommandForGain(int gain) {
        switch (gain) {
            case 1:
                return '0';
            case 2:
                return '1';
            case 4:
                return '2';
            case 6:
                return '3';
            case 8:
                return '4';
            case 12:
                return '5';
            case 24:
            default:
                return '6';
        }
    }

    /**
      * Used to convert raw code to hub code
      * @param inputType {String} - The input from a hub sync channel with register settings
      */
    public char getCommandForInputType(String inputType) {
        if (inputType.equals("normal")) return '0';
        if (inputType.equals("shorted")) return '1';
        if (inputType.equals("biasMethod")) return '2';
        if (inputType.equals("mvdd")) return '3';
        if (inputType.equals("temp")) return '4';
        if (inputType.equals("testsig")) return '5';
        if (inputType.equals("biasDrp")) return '6';
        if (inputType.equals("biasDrn")) return '7';
        return '0';
    }

    /**
      * Used to convert a local channel code into a hub gain which is human
      *  readable and in scientific values.
      */
    public int getGainForCommand(char cmd) {
        switch (cmd) {
            case '0':
                return 1;
            case '1':
                return 2;
            case '2':
                return 4;
            case '3':
                return 6;
            case '4':
                return 8;
            case '5':
                return 12;
            case '6':
            default:
                return 24;
        }
    }

    /**
      * Used right before a channel setting command is sent to the hub to convert
      *  local values into the expected form for the hub.
      */
    public String getInputTypeForCommand(char cmd) {
        final String inputTypeShorted = "shorted";
        final String inputTypeBiasMethod = "biasMethod";
        final String inputTypeMvdd = "mvdd";
        final String inputTypeTemp = "temp";
        final String inputTypeTestsig = "testsig";
        final String inputTypeBiasDrp = "biasDrp";
        final String inputTypeBiasDrn = "biasDrn";
        final String inputTypeNormal = "normal";
        switch (cmd) {
            case '1':
                return inputTypeShorted;
            case '2':
                return inputTypeBiasMethod;
            case '3':
                return inputTypeMvdd;
            case '4':
                return inputTypeTemp;
            case '5':
                return inputTypeTestsig;
            case '6':
                return inputTypeBiasDrp;
            case '7':
                return inputTypeBiasDrn;
            case '0':
            default:
                return inputTypeNormal;
        }
    }

    /**
      * Used to convert a local index number to a hub human readable sd setting
      *  command.
      */
    public String getSDSettingForSetting(int setting) {
        switch (setting) {
            case 1:
                return "5min";
            case 2:
                return "15min";
            case 3:
                return "30min";
            case 4:
                return "1hour";
            case 5:
                return "2hour";
            case 6:
                return "4hour";
            case 7:
                return "12hour";
            case 8:
                return "24hour";
            default:
                return "";
        }
    }

    //FULL DISCLAIMER: this method is messy....... very messy... we had to brute force a firmware miscue
    public void writeChannelSettings(int _numChannel, char[][] channelSettingValues) {   //numChannel counts from zero
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_CHANNEL_SETTINGS);
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_SET);
        json.setInt(TCP_JSON_KEY_CHANNEL_NUMBER, _numChannel);
        json.setBoolean(TCP_JSON_KEY_CHANNEL_SET_POWER_DOWN, channelSettingValues[_numChannel][0] == '1');
        json.setInt(TCP_JSON_KEY_CHANNEL_SET_GAIN, getGainForCommand(channelSettingValues[_numChannel][1]));
        json.setString(TCP_JSON_KEY_CHANNEL_SET_INPUT_TYPE, getInputTypeForCommand(channelSettingValues[_numChannel][2]));
        json.setBoolean(TCP_JSON_KEY_CHANNEL_SET_BIAS, channelSettingValues[_numChannel][3] == '1');
        json.setBoolean(TCP_JSON_KEY_CHANNEL_SET_SRB2, channelSettingValues[_numChannel][4] == '1');
        json.setBoolean(TCP_JSON_KEY_CHANNEL_SET_SRB1, channelSettingValues[_numChannel][5] == '1');
        hub.writeJSON(json);
        verbosePrint("done writing channel." + json); //debugging
    }

    public void writeImpedanceSettings(int _numChannel, char[][] impedanceCheckValues) {  //numChannel counts from zero
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_IMPEDANCE);
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_SET);
        json.setInt(TCP_JSON_KEY_CHANNEL_NUMBER, _numChannel);
        json.setBoolean(TCP_JSON_KEY_IMPEDANCE_SET_P_INPUT, impedanceCheckValues[_numChannel-1][0] == '1');
        json.setBoolean(TCP_JSON_KEY_IMPEDANCE_SET_N_INPUT, impedanceCheckValues[_numChannel-1][1] == '1');
        hub.writeJSON(json);
    }

    public int copyDataPacketTo(DataPacket_ADS1299 target) {
        return dataPacket.copyTo(target);
    }
};
