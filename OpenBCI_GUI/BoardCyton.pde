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

import java.io.OutputStream; //for logging raw bytes to an output file

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

final char command_stop = 's';
// final String command_startText = "x";
final char command_startBinary = 'b';
final char command_startBinary_wAux = 'n';  // already doing this with 'b' now
final char command_startBinary_4chan = 'v';  // not necessary now
final char command_activateFilters = 'f';  // swithed from 'F' to 'f'  ... but not necessary because taken out of hardware code
final char command_deactivateFilters = 'g';  // not necessary anymore

final String command_setMode = "/";  // this is used to set the board into different modes

final char[] command_deactivate_channel = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
final char[] command_activate_channel = {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

int channelDeactivateCounter = 0; //used for re-deactivating channels after switching settings...

final int BOARD_MODE_DEFAULT = 0;
final int BOARD_MODE_DEBUG = 1;
final int BOARD_MODE_ANALOG = 2;
final int BOARD_MODE_DIGITAL = 3;
final int BOARD_MODE_MARKER = 4;

//everything below is now deprecated...
// final String[] command_activate_leadoffP_channel = {'!', '@', '#', '$', '%', '^', '&', '*'};  //shift + 1-8
// final String[] command_deactivate_leadoffP_channel = {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};   //letters (plus shift) right below 1-8
// final String[] command_activate_leadoffN_channel = {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K'}; //letters (plus shift) below the letters below 1-8
// final String[] command_deactivate_leadoffN_channel = {'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<'};   //letters (plus shift) below the letters below the letters below 1-8
// final String command_biasAuto = "`";
// final String command_biasFixed = "~";

// ArrayList defaultChannelSettings;

//here is the routine that listens to the serial port.
//if any data is waiting, get it, parse it, and stuff it into our vector of
//pre-allocated dataPacketBuff

//------------------------------------------------------------------------
//                       Classes
//------------------------------------------------------------------------

class Cyton {

  private int nEEGValuesPerPacket = 8; //defined by the data format sent by cyton boards
  private int nAuxValuesPerPacket = 3; //defined by the data format sent by cyton boards
  private DataPacket_ADS1299 rawReceivedDataPacket;
  private DataPacket_ADS1299 missedDataPacket;
  private DataPacket_ADS1299 dataPacket;
  // public int [] validAuxValues = {0, 0, 0};
  // public boolean[] freshAuxValuesAvailable = {false, false, false};
  // public boolean freshAuxValues = false;
  //DataPacket_ADS1299 prevDataPacket;

  private int nAuxValues;
  private boolean isNewDataPacketAvailable = false;
  private OutputStream output; //for debugging  WEA 2014-01-26
  private int prevSampleIndex = 0;
  private int serialErrorCounter = 0;

  private final int fsHzSerialCyton = 250;  //sample rate used by OpenBCI board...set by its Arduino code
  private final int fsHzSerialCytonDaisy = 125;  //sample rate used by OpenBCI board...set by its Arduino code
  private final int fsHzWifi = 1000;  //sample rate used by OpenBCI board...set by its Arduino code
  private final int NfftSerialCyton = 256;
  private final int NfftSerialCytonDaisy = 256;
  private final int NfftWifi = 1024;
  private final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
  private float ADS1299_gain = 24.0;  //assumed gain setting for ADS1299.  set by its Arduino code
  private float openBCI_series_resistor_ohms = 2200; // Ohms. There is a series resistor on the 32 bit board.
  private float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
  //float LIS3DH_full_scale_G = 4;  // +/- 4G, assumed full scale setting for the accelerometer
  private final float scale_fac_accel_G_per_count = 0.002 / ((float)pow(2, 4));  //assume set to +/4G, so 2 mG per digit (datasheet). Account for 4 bits unused
  //private final float scale_fac_accel_G_per_count = 1.0;  //to test stimulations  //final float scale_fac_accel_G_per_count = 1.0;
  private final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code

  boolean isBiasAuto = true; //not being used?

  private int curBoardMode = BOARD_MODE_DEFAULT;

  //data related to Conor's setup for V3 boards
  final char[] EOT = {'$', '$', '$'};
  char[] prev3chars = {'#', '#', '#'};
  public String potentialFailureMessage = "";
  public String defaultChannelSettings = "";
  public String daisyOrNot = "";
  public int hardwareSyncStep = 0; //start this at 0...
  private long timeOfLastCommand = 0; //used when sync'ing to hardware

  private int curInterface = INTERFACE_SERIAL;
  private int sampleRate = fsHzWifi;
  PApplet mainApplet;

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

  // TODO: ADJUST getNfft for new sample variable sample rates
  public int getNfft() {
    if (isWifi()) {
      if (sampleRate == fsHzSerialCyton) {
        return NfftSerialCyton;
      } else {
        return NfftWifi;
      }
    } else {
      if (nchan == NCHAN_CYTON_DAISY) {
        return NfftSerialCytonDaisy;
      } else {
        return NfftSerialCyton;
      }
    }
  }
  public int getBoardMode() {
    return curBoardMode;
  }
  public int getInterface() {
    return curInterface;
  }
  public float get_Vref() {
    return ADS1299_Vref;
  }
  public void set_ADS1299_gain(float _gain) {
    ADS1299_gain = _gain;
    scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.0; //ADS1299 datasheet Table 7, confirmed through experiment
  }
  public float get_ADS1299_gain() {
    return ADS1299_gain;
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
  public String get_defaultChannelSettings() {
    return defaultChannelSettings;
  }

  public void setBoardMode(int boardMode) {
    hub.sendCommand("/" + boardMode);
    curBoardMode = boardMode;
    consolePrint("Cyton: setBoardMode to :" + curBoardMode);
  }

  public void setSampleRate(int _sampleRate) {
    sampleRate = _sampleRate;
    // output("Setting sample rate for Cyton to " + sampleRate + "Hz");
    consolePrint("Setting sample rate for Cyton to " + sampleRate + "Hz");
    hub.setSampleRate(sampleRate);
  }

  public boolean setInterface(int _interface) {
    curInterface = _interface;
    // consolePrint("current interface: " + curInterface);
    consolePrint("setInterface: curInterface: " + getInterface());
    if (isWifi()) {
      setSampleRate((int)fsHzWifi);
      hub.setProtocol(PROTOCOL_WIFI);
    } else if (isSerial()) {
      setSampleRate((int)fsHzSerialCyton);
      hub.setProtocol(PROTOCOL_SERIAL);
    }
    return true;
  }

  //constructors
  Cyton() {
  };  //only use this if you simply want access to some of the constants
  Cyton(PApplet applet, String comPort, int baud, int nEEGValuesPerOpenBCI, boolean useAux, int nAuxValuesPerOpenBCI, int _interface) {
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
    consolePrint("Closing any open SD file. Writing 'j' to OpenBCI.");
    if (isPortOpen()) write('j'); // tell the SD file to close if one is open...
    delay(100); //make sure 'j' gets sent to the board
    return 0;
  }

  public void syncWithHardware(int sdSetting) {
    switch (hardwareSyncStep) {
      case 1: //send # of channels (8 or 16) ... (regular or daisy setup)
        consolePrint("Cyton: syncWithHardware: [1] Sending channel count (" + nchan + ") to OpenBCI...");
        if (nchan == 8) {
          write('c');
        }
        if (nchan == 16) {
          write('C', false);
        }
        break;
      case 2: //reset hardware to default registers
        consolePrint("Cyton: syncWithHardware: [2] Reseting OpenBCI registers to default... writing \'d\'...");
        write('d'); // TODO: Why does this not get a $$$ readyToSend = false?
        break;
      case 3: //ask for series of channel setting ASCII values to sync with channel setting interface in GUI
        consolePrint("Cyton: syncWithHardware: [3] Retrieving OpenBCI's channel settings to sync with GUI... writing \'D\'... waiting for $$$...");
        write('D', false); //wait for $$$ to iterate... applies to commands expecting a response
        break;
      case 4: //check existing registers
        consolePrint("Cyton: syncWithHardware: [4] Retrieving OpenBCI's full register map for verification... writing \'?\'... waiting for $$$...");
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
        consolePrint("Cyton: syncWithHardware: [5] Writing selected SD setting (" + sdSettingString + ") to OpenBCI...");
        //final hacky way of abandoning initiation if someone selected daisy but doesn't have one connected.
        if(abandonInit){
          haltSystem();
          output("No daisy board present. Make sure you selected the correct number of channels.");
          controlPanel.open();
          abandonInit = false;
        }
        break;
      case 6:
        consolePrint("Cyton: syncWithHardware: The GUI is done initializing. Click outside of the control panel to interact with the GUI.");
        hub.changeState(STATE_STOPPED);
        systemMode = 10;
        controlPanel.close();
        topNav.controlPanelCollapser.setIsActive(false);
        //renitialize GUI if nchan has been updated... needs to be built
        break;
    }
  }

  public void writeCommand(String val) {
    if (hub.isHubRunning()) {
      hub.write(String.valueOf(val));
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
    // if (isSerial()) {
    //   iSerial.setReadyToSend(_readyToSend);
    // }
    return write(val);
  }

  public boolean write(String out, boolean _readyToSend) {
    // if (isSerial()) {
    //   iSerial.setReadyToSend(_readyToSend);
    // }
    return write(out);
  }

  public boolean write(String out) {
    if (hub.isHubRunning()) {
      hub.write(out);
      return true;
    }
    return false;
  }

  private boolean isSerial () {
    // consolePrint("My interface is " + curInterface);
    return curInterface == INTERFACE_SERIAL;
  }

  private boolean isWifi () {
    return curInterface == INTERFACE_HUB_WIFI;
  }

  public void startDataTransfer() {
    if (isPortOpen()) {
      // Now give the command to start binary data transmission
      if (isSerial()) {
        hub.changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
        consolePrint("Cyton: startDataTransfer(): writing \'" + command_startBinary + "\' to the serial port...");
        // if (isSerial()) iSerial.clear();  // clear anything in the com port's buffer
        write(command_startBinary);
      } else if (isWifi()) {
        consolePrint("Cyton: startDataTransfer(): writing \'" + command_startBinary + "\' to the wifi shield...");
        write(command_startBinary);
      }

    } else {
      consolePrint("port not open");
    }
  }

  public void stopDataTransfer() {
    if (isPortOpen()) {
      hub.changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
      consolePrint("Cyton: startDataTransfer(): writing \'" + command_stop + "\' to the serial port...");
      write(command_stop);// + "\n");
    }
  }

  public void printRegisters() {
    if (isPortOpen()) {
      consolePrint("Cyton: printRegisters(): Writing ? to OpenBCI...");
      write('?');
    }
  }

  /* **** Borrowed from Chris Viegl from his OpenBCI parser for BrainBay
   Modified by Joel Murphy and Conor Russomanno to read OpenBCI data
   Packet Parser for OpenBCI (1-N channel binary format):
   3-byte data values are stored in 'little endian' formant in AVRs
   so this protocol parser expects the lower bytes first.
   Start Indicator: 0xA0
   EXPECTING STANDARD PACKET LENGTH DON'T NEED: Packet_length  : 1 byte  (length = 4 bytes framenumber + 4 bytes per active channel + (optional) 4 bytes for 1 Aux value)
   Framenumber     : 1 byte (Sequential counter of packets)
   Channel 1 data  : 3 bytes
   ...
   Channel 8 data  : 3 bytes
   Aux Values      : UP TO 6 bytes
   End Indcator    : 0xC0
   TOTAL OF 33 bytes ALL DAY
   ********************************************************************* */
  private int nDataValuesInPacket = 0;
  private int localByteCounter=0;
  private int localChannelCounter=0;
  private int PACKET_readstate = 0;
  // byte[] localByteBuffer = {0,0,0,0};
  private byte[] localAdsByteBuffer = {0, 0, 0};
  private byte[] localAccelByteBuffer = {0, 0};

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

  //return the state
  public boolean isStateNormal() {
    if (hub.get_state() == STATE_NORMAL) {
      return true;
    } else {
      return false;
    }
  }

  private int copyRawDataToFullData() {
    //Prior to the 16-chan OpenBCI, we did NOT have rawReceivedDataPacket along with dataPacket...we just had dataPacket.
    //With the 16-chan OpenBCI, where the first 8 channels are sent and then the second 8 channels are sent, we introduced
    //this extra structure so that we could alternate between them.
    //
    //This function here decides how to join the latest data (rawReceivedDataPacket) into the full dataPacket

    if (dataPacket.values.length < 2*rawReceivedDataPacket.values.length) {
      //this is an 8 channel board, so simply copy the data
      return rawReceivedDataPacket.copyTo(dataPacket);
    } else {
      //this is 16-channels, so copy the raw data into the correct channels of the new data
      int offsetInd_values = 0;  //this is correct assuming we just recevied a  "board" packet (ie, channels 1-8)
      int offsetInd_aux = 0;     //this is correct assuming we just recevied a  "board" packet (ie, channels 1-8)
      if (rawReceivedDataPacket.sampleIndex % 2 == 0) { // even data packets are from the daisy board
        offsetInd_values = rawReceivedDataPacket.values.length;  //start copying to the 8th slot
        //offsetInd_aux = rawReceivedDataPacket.auxValues.length;  //start copying to the 3rd slot
        offsetInd_aux = 0;
      }
      return rawReceivedDataPacket.copyTo(dataPacket, offsetInd_values, offsetInd_aux);
    }
  }

  public int copyDataPacketTo(DataPacket_ADS1299 target) {
    return dataPacket.copyTo(target);
  }


  private long timeOfLastChannelWrite = 0;
  private int channelWriteCounter = 0;
  private boolean isWritingChannel = false;

  public void configureAllChannelsToDefault() {
    write('d');
  };

  public void initChannelWrite(int _numChannel) {  //numChannel counts from zero
    timeOfLastChannelWrite = millis();
    isWritingChannel = true;
  }

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

  // FULL DISCLAIMER: this method is messy....... very messy... we had to brute force a firmware miscue
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
    consolePrint("done writing channel." + json); //debugging
    isWritingChannel = false;
  }

  private long timeOfLastImpWrite = 0;
  private int impWriteCounter = 0;
  private boolean isWritingImp = false;
  public boolean get_isWritingImp() {
    return isWritingImp;
  }

  // public void initImpWrite(int _numChannel) {  //numChannel counts from zero
  //   timeOfLastImpWrite = millis();
  //   isWritingImp = true;
  // }

  public void writeImpedanceSettings(int _numChannel, char[][] impedanceCheckValues) {  //numChannel counts from zero
    JSONObject json = new JSONObject();
    json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_IMPEDANCE);
    json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_SET);
    json.setInt(TCP_JSON_KEY_CHANNEL_NUMBER, _numChannel);
    json.setBoolean(TCP_JSON_KEY_IMPEDANCE_SET_P_INPUT, impedanceCheckValues[_numChannel-1][0] == '1');
    json.setBoolean(TCP_JSON_KEY_IMPEDANCE_SET_N_INPUT, impedanceCheckValues[_numChannel-1][1] == '1');
    hub.writeJSON(json);
    isWritingImp = false;
  }
};
