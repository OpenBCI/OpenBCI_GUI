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

final String command_stop = "s";
// final String command_startText = "x";
final String command_startBinary = "b";
final String command_startBinary_wAux = "n";  // already doing this with 'b' now
final String command_startBinary_4chan = "v";  // not necessary now
final String command_activateFilters = "f";  // swithed from 'F' to 'f'  ... but not necessary because taken out of hardware code
final String command_deactivateFilters = "g";  // not necessary anymore

final String[] command_deactivate_channel = {"1", "2", "3", "4", "5", "6", "7", "8", "q", "w", "e", "r", "t", "y", "u", "i"};
final String[] command_activate_channel = {"!", "@", "#", "$", "%", "^", "&", "*", "Q", "W", "E", "R", "T", "Y", "U", "I"};

int channelDeactivateCounter = 0; //used for re-deactivating channels after switching settings...

boolean threadLock = false;

//these variables are used for "Kill Spikes" ... duplicating the last received data packet if packets were droppeds
boolean werePacketsDropped = false;
int numPacketsDropped = 0;


//everything below is now deprecated...
// final String[] command_activate_leadoffP_channel = {"!", "@", "#", "$", "%", "^", "&", "*"};  //shift + 1-8
// final String[] command_deactivate_leadoffP_channel = {"Q", "W", "E", "R", "T", "Y", "U", "I"};   //letters (plus shift) right below 1-8
// final String[] command_activate_leadoffN_channel = {"A", "S", "D", "F", "G", "H", "J", "K"}; //letters (plus shift) below the letters below 1-8
// final String[] command_deactivate_leadoffN_channel = {"Z", "X", "C", "V", "B", "N", "M", "<"};   //letters (plus shift) below the letters below the letters below 1-8
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
  //int nAuxValuesPerPacket = 3; //defined by the data format sent by cyton boards
  private DataPacket_ADS1299 rawReceivedDataPacket;
  private DataPacket_ADS1299 missedDataPacket;
  private DataPacket_ADS1299 dataPacket;
  public int [] validAuxValues = {0, 0, 0};
  public boolean[] freshAuxValuesAvailable = {false, false, false};
  public boolean freshAuxValues = false;
  //DataPacket_ADS1299 prevDataPacket;

  private int nAuxValues;
  private boolean isNewDataPacketAvailable = false;
  private OutputStream output; //for debugging  WEA 2014-01-26
  private int prevSampleIndex = 0;
  private int serialErrorCounter = 0;

  private final float fs_Hz = 250.0f;  //sample rate used by OpenBCI board...set by its Arduino code
  private final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
  private float ADS1299_gain = 24.0;  //assumed gain setting for ADS1299.  set by its Arduino code
  private float openBCI_series_resistor_ohms = 2200; // Ohms. There is a series resistor on the 32 bit board.
  private float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
  //float LIS3DH_full_scale_G = 4;  // +/- 4G, assumed full scale setting for the accelerometer
  private final float scale_fac_accel_G_per_count = 0.002 / ((float)pow(2, 4));  //assume set to +/4G, so 2 mG per digit (datasheet). Account for 4 bits unused
  //final float scale_fac_accel_G_per_count = 1.0;
  private final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code
  private final String failureMessage = "Failure: Communications timeout - Device failed to poll Host";

  boolean isBiasAuto = true; //not being used?

  //data related to Conor's setup for V3 boards
  final char[] EOT = {'$', '$', '$'};
  char[] prev3chars = {'#', '#', '#'};
  private String potentialFailureMessage = "";
  private String defaultChannelSettings = "";
  private String daisyOrNot = "";
  private int hardwareSyncStep = 0; //start this at 0...
  private long timeOfLastCommand = 0; //used when sync'ing to hardware

  private int interface = INTERFACE_SERIAL;

  //some get methods
  public float get_fs_Hz() {
    return fs_Hz;
  }
  public int get_interface() {
    return interface;
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

  //constructors
  Cyton() {
  };  //only use this if you simply want access to some of the constants
  Cyton(PApplet applet, String comPort, int baud, int nEEGValuesPerOpenBCI, boolean useAux, int nAuxValuesPerPacket, int interfaceType) {
    interface = interfaceType;
    nAuxValues=nAuxValuesPerPacket;

    println("nEEGValuesPerPacket = " + nEEGValuesPerPacket);
    println("nEEGValuesPerOpenBCI = " + nEEGValuesPerOpenBCI);

    //allocate space for data packet
    rawReceivedDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
    missedDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
    dataPacket = new DataPacket_ADS1299(nEEGValuesPerOpenBCI, nAuxValuesPerPacket);            //this could be 8 or 16 channels
    //prevDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket,nAuxValuesPerPacket);
    //set all values to 0 so not null

    println("(2) nEEGValuesPerPacket = " + nEEGValuesPerPacket);
    println("(2) nEEGValuesPerOpenBCI = " + nEEGValuesPerOpenBCI);
    println("missedDataPacket.values.length = " + missedDataPacket.values.length);

    for (int i = 0; i < nEEGValuesPerPacket; i++) {
      rawReceivedDataPacket.values[i] = 0;
      //prevDataPacket.values[i] = 0;
    }

    // %%%%% HAD TO KILL THIS ... not sure why nEEGValuesPerOpenBCI would ever loop to 16... this may be an incongruity due to the way we kludge the 16chan data in 2 packets...
    // for (int i=0; i < nEEGValuesPerOpenBCI; i++) {
    //   println("i = " + i);
    //   dataPacket.values[i] = 0;
    //   missedDataPacket.values[i] = 0;
    // }

    for (int i=0; i < nEEGValuesPerPacket; i++) {
      // println("i = " + i);
      dataPacket.values[i] = 0;
      missedDataPacket.values[i] = 0;
    }
    for (int i = 0; i < nAuxValuesPerPacket; i++) {
      rawReceivedDataPacket.auxValues[i] = 0;
      dataPacket.auxValues[i] = 0;
      missedDataPacket.auxValues[i] = 0;
      //prevDataPacket.auxValues[i] = 0;
    }

    if (isSerial()) {
      //prepare the serial port  ... close if open
      if (isPortOpen()) {
        closeSerialPort();
      }
      iSerial.openSerialPort(applet, comPort, baud);
    } else {
      hub.connectWifi(comPort);
    }
  }

  public int changeState(int newState) {
    if (isHub()) {
      hub.changeState(newState);
    } else {
      iSerial.changeState(newState);
    }
  }

  public int closeSDandPort() {
    closeSDFile();

    if (isSerial()) {
      return iSerial.closeSerialPort();
    } else {
      return hub.disconnectWifi();
    }
  }

  public int closeSDFile() {
    println("Closing any open SD file. Writing 'j' to OpenBCI.");
    if (isPortOpen()) write("j"); // tell the SD file to close if one is open...
    delay(100); //make sure 'j' gets sent to the board
    return 0;
  }

  public void syncWithHardware(int sdSetting) {
    switch (hardwareSyncStep) {
      case 1: //send # of channels (8 or 16) ... (regular or daisy setup)
        println("Cyton: syncWithHardware: [1] Sending channel count (" + nchan + ") to OpenBCI...");
        if (nchan == 8) {
          write('c'); // TODO: Why does this not get a $$$ readyToSend = false?
        }
        if (nchan == 16) {
          write('C', false);
        }
        break;
      case 2: //reset hardware to default registers
        println("Cyton: syncWithHardware: [2] Reseting OpenBCI registers to default... writing \'d\'...");
        write("d"); // TODO: Why does this not get a $$$ readyToSend = false?
        break;
      case 3: //ask for series of channel setting ASCII values to sync with channel setting interface in GUI
        println("Cyton: syncWithHardware: [3] Retrieving OpenBCI's channel settings to sync with GUI... writing \'D\'... waiting for $$$...");
        write("D", false); //wait for $$$ to iterate... applies to commands expecting a response
        break;
      case 4: //check existing registers
        println("Cyton: syncWithHardware: [4] Retrieving OpenBCI's full register map for verification... writing \'?\'... waiting for $$$...");
        write("?", false); //wait for $$$ to iterate... applies to commands expecting a response
        break;
      case 5:
        // write("j"); // send OpenBCI's 'j' commaned to make sure any already open SD file is closed before opening another one...
        switch (sdSetting) {
          case 1: //"5 min max"
            write("A", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 2: //"5 min max"
            write("S", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 3: //"5 min max"
            write("F", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 4: //"5 min max"
            write("G", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 5: //"5 min max"
            write("H", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 6: //"5 min max"
            write("J", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 7: //"5 min max"
            write("K", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          case 8: //"5 min max"
            write("L", false); //wait for $$$ to iterate... applies to commands expecting a response
            break;
          default:
            break; // Do Nothing
        }
        println("Cyton: syncWithHardware: [5] Writing selected SD setting (" + sdSettingString + ") to OpenBCI...");
        //final hacky way of abandoning initiation if someone selected daisy but doesn't have one connected.
        if(abandonInit){
          haltSystem();
          output("No daisy board present. Make sure you selected the correct number of channels.");
          controlPanel.open();
          abandonInit = false;
        }
        break;
      case 6:
        output("Cyton: syncWithHardware: The GUI is done intializing. Click outside of the control panel to interact with the GUI.");
        changeState(STATE_STOPPED);
        systemMode = 10;
        controlPanel.close();
        topNav.controlPanelCollapser.setIsActive(false);
        //renitialize GUI if nchan has been updated... needs to be built
        break;
    }
  }

  public boolean sendChar(char val) {
    if (interface == INTERFACE_HUB_WIFI) {
      if (hub.isHubRunning()) {
        hub.write(key);
        return true;
      }
    } else {
      if (iSerial.isSerialPortOpen()) {
        iSerial.write(key);
        return true;
      }
    }
    return false;
  }

  public boolean write(String out, boolean _readyToSend) {
    if (isSerial()) {
      iSerial.setReadyToSend(_readyToSend);
    }
    return write(out);
  }

  public boolean write(String out) {
    if (interface == INTERFACE_HUB_WIFI) {
      if (hub.isHubRunning()) {
        hub.write(out);
        return true;
      }
    } else {
      if (iSerial.isSerialPortOpen()) {
        iSerial.write(out);
        return true;
      }
    }
    return false;
  }

  private boolean isSerial () {
    return interface == INTERFACE_SERIAL;
  }

  private boolean isHub () {
    return interface == INTERFACE_HUB_WIFI || interface == INTERFACE_HUB_BLE;
  }

  void startDataTransfer() {
    if (isPortOpen()) {
      // stopDataTransfer();
      changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
      println("Cyton: startDataTransfer(): writing \'" + command_startBinary + "\' to the serial port...");
      if (isSerial()) iSerial.clear();  // clear anything in the com port's buffer
      write(command_startBinary);

    }
  }

  public void stopDataTransfer() {
    if (isPortOpen()) {
      if (isSerial()) iSerial.clear();  // clear anything in the com port's buffer
      changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
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
    if (interface == INTERFACE_SERIAL) {
      return iSerial.isSerialPortOpen();
    } else if (interface == INTERFACE_HUB_WIFI) {
      return hub.isHubRunning();
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
    if (state == STATE_NORMAL) {
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
    isNewDataPacketAvailable = false;
    return dataPacket.copyTo(target);
  }


  private long timeOfLastChannelWrite = 0;
  private int channelWriteCounter = 0;
  private boolean isWritingChannel = false;
  public boolean get_isWritingChannel() {
    return isWritingChannel;
  }
  public void configureAllChannelsToDefault() {
    write('d');
  };
  public void initChannelWrite(int _numChannel) {  //numChannel counts from zero
    timeOfLastChannelWrite = millis();
    isWritingChannel = true;
  }

  // FULL DISCLAIMER: this method is messy....... very messy... we had to brute force a firmware miscue
  public void writeChannelSettings(int _numChannel, char[][] channelSettingValues) {   //numChannel counts from zero
    if (millis() - timeOfLastChannelWrite >= 50) { //wait 50 milliseconds before sending next character
      verbosePrint("---");
      switch (channelWriteCounter) {
      case 0: //start sequence by send 'x'
        verbosePrint("x" + " :: " + millis());
        write('x');
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 1: //send channel number
        verbosePrint(str(_numChannel+1) + " :: " + millis());
        if (_numChannel < 8) {
          write((char)('0'+(_numChannel+1)));
        }
        if (_numChannel >= 8) {
          //write((command_activate_channel_daisy[_numChannel-8]));
          write((command_activate_channel[_numChannel])); //command_activate_channel holds non-daisy and daisy
        }
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 2:
        verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
        write(channelSettingValues[_numChannel][channelWriteCounter-2]);
        //value for ON/OF
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 3:
        verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
        write(channelSettingValues[_numChannel][channelWriteCounter-2]);
        //value for ON/OF
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 4:
        verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
        write(channelSettingValues[_numChannel][channelWriteCounter-2]);
        //value for ON/OF
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 5:
        verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
        write(channelSettingValues[_numChannel][channelWriteCounter-2]);
        //value for ON/OF
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 6:
        verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
        write(channelSettingValues[_numChannel][channelWriteCounter-2]);
        //value for ON/OF
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 7:
        verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
        write(channelSettingValues[_numChannel][channelWriteCounter-2]);
        //value for ON/OF
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 8:
        verbosePrint("X" + " :: " + millis());
        write('X'); // send 'X' to end message sequence
        timeOfLastChannelWrite = millis();
        channelWriteCounter++;
        break;
      case 9:
        //turn back off channels that were not active before changing channel settings
        switch(channelDeactivateCounter) {
        case 0:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 1:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 2:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 3:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 4:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 5:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 6:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 7:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          //check to see if it's 8chan or 16chan ... stop the switch case here if it's 8 chan, otherwise keep going
          if (nchan == 8) {
            verbosePrint("done writing channel.");
            isWritingChannel = false;
            channelWriteCounter = 0;
            channelDeactivateCounter = 0;
          } else {
            //keep going
          }
          break;
        case 8:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 9:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 10:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 11:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 12:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 13:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 14:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          channelDeactivateCounter++;
          break;
        case 15:
          if (channelSettingValues[channelDeactivateCounter][0] == '1') {
            verbosePrint("deactivating channel: " + str(channelDeactivateCounter + 1));
            write(command_deactivate_channel[channelDeactivateCounter]);
          }
          verbosePrint("done writing channel.");
          isWritingChannel = false;
          channelWriteCounter = 0;
          channelDeactivateCounter = 0;
          break;
        }

        // verbosePrint("done writing channel.");
        // isWritingChannel = false;
        // channelWriteCounter = -1;
        timeOfLastChannelWrite = millis();
        break;
      }
      // timeOfLastChannelWrite = millis();
      // channelWriteCounter++;
    }
  }

  private long timeOfLastImpWrite = 0;
  private int impWriteCounter = 0;
  private boolean isWritingImp = false;
  public boolean get_isWritingImp() {
    return isWritingImp;
  }
  public void initImpWrite(int _numChannel) {  //numChannel counts from zero
    timeOfLastImpWrite = millis();
    isWritingImp = true;
  }
  public void writeImpedanceSettings(int _numChannel, char[][] impedanceCheckValues) {  //numChannel counts from zero
    //after clicking an impedance button, write the new impedance settings for that channel to OpenBCI
    //after clicking any button, write the new settings for that channel to OpenBCI
    // verbosePrint("Writing impedance settings for channel " + _numChannel + " to OpenBCI!");
    //write setting 1, delay 5ms.. write setting 2, delay 5ms, etc.
    if (millis() - timeOfLastImpWrite >= 50) { //wait 50 milliseconds before sending next character
      verbosePrint("---");
      switch (impWriteCounter) {
      case 0: //start sequence by sending 'z'
        verbosePrint("z" + " :: " + millis());
        write('z');
        break;
      case 1: //send channel number
        verbosePrint(str(_numChannel+1) + " :: " + millis());
        if (_numChannel < 8) {
          write((char)('0'+(_numChannel+1)));
        }
        if (_numChannel >= 8) {
          //cyton.write((command_activate_channel_daisy[_numChannel-8]));
          write((command_activate_channel[_numChannel])); //command_activate_channel holds non-daisy and daisy values
        }
        break;
      case 2:
      case 3:
        verbosePrint(impedanceCheckValues[_numChannel][impWriteCounter-2] + " :: " + millis());
        write(impedanceCheckValues[_numChannel][impWriteCounter-2]);
        //value for ON/OF
        break;
      case 4:
        verbosePrint("Z" + " :: " + millis());
        write('Z'); // send 'X' to end message sequence
        break;
      case 5:
        verbosePrint("done writing imp settings.");
        isWritingImp = false;
        impWriteCounter = -1;
        break;
      }
      timeOfLastImpWrite = millis();
      impWriteCounter++;
    }
  }
};
