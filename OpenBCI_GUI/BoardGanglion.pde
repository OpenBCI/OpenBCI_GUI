///////////////////////////////////////////////////////////////////////////////
//
// This class configures and manages the connection to the OpenBCI Ganglion.
// The connection is implemented via a TCP connection to a TCP port.
// The Gagnlion is configured using single letter text commands sent from the
// PC to the TCP server.  The EEG data streams back from the Ganglion, to the
// TCP server and back to the PC continuously (once started).
//
// Created: AJ Keller, August 2016
//
/////////////////////////////////////////////////////////////////////////////

// import java.io.OutputStream; //for logging raw bytes to an output file

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

class Ganglion {
  final static String TCP_CMD_ACCEL = "a";
  final static String TCP_CMD_CONNECT = "c";
  final static String TCP_CMD_COMMAND = "k";
  final static String TCP_CMD_DISCONNECT = "d";
  final static String TCP_CMD_DATA= "t";
  final static String TCP_CMD_ERROR = "e"; //<>// //<>//
  final static String TCP_CMD_IMPEDANCE = "i";
  final static String TCP_CMD_LOG = "l";
  final static String TCP_CMD_SCAN = "s";
  final static String TCP_CMD_STATUS = "q";
  final static String TCP_STOP = ",;\n";

  final static String TCP_ACTION_START = "start";
  final static String TCP_ACTION_STATUS = "status";
  final static String TCP_ACTION_STOP = "stop";

  final static String GANGLION_BOOTLOADER_MODE = ">";

  final static int NUM_ACCEL_DIMS = 3;

  final static int RESP_ERROR_UNKNOWN = 499;
  final static int RESP_ERROR_BAD_PACKET = 500;
  final static int RESP_ERROR_BAD_NOBLE_START = 501;
  final static int RESP_ERROR_ALREADY_CONNECTED = 408;
  final static int RESP_ERROR_COMMAND_NOT_RECOGNIZED = 406;
  final static int RESP_ERROR_DEVICE_NOT_FOUND = 405;
  final static int RESP_ERROR_NO_OPEN_BLE_DEVICE = 400;
  final static int RESP_ERROR_UNABLE_TO_CONNECT = 402;
  final static int RESP_ERROR_UNABLE_TO_DISCONNECT = 401;
  final static int RESP_ERROR_SCAN_ALREADY_SCANNING = 409;
  final static int RESP_ERROR_SCAN_NONE_FOUND = 407;
  final static int RESP_ERROR_SCAN_NO_SCAN_TO_STOP = 410;
  final static int RESP_ERROR_SCAN_COULD_NOT_START = 412;
  final static int RESP_ERROR_SCAN_COULD_NOT_STOP = 411;
  final static int RESP_GANGLION_FOUND = 201;
  final static int RESP_SUCCESS = 200;
  final static int RESP_SUCCESS_DATA_ACCEL = 202;
  final static int RESP_SUCCESS_DATA_IMPEDANCE = 203;
  final static int RESP_SUCCESS_DATA_SAMPLE = 204;
  final static int RESP_STATUS_CONNECTED = 300;
  final static int RESP_STATUS_DISCONNECTED = 301;
  final static int RESP_STATUS_SCANNING = 302;
  final static int RESP_STATUS_NOT_SCANNING = 303;

  private int nEEGValuesPerPacket = NCHAN_GANGLION; // Defined by the data format sent by cyton boards
  private int nAuxValuesPerPacket = NUM_ACCEL_DIMS; // Defined by the arduino code

  private final float fsHzBLE = 200.0f;  //sample rate used by OpenBCI Ganglion board... set by its Arduino code
  private final float fsHzWifi = 1600.0f;  //sample rate used by OpenBCI Ganglion board on wifi, set by hub
  private final int NfftBLE = 256;
  private final int NfftWifi = 2048;
  private final float MCP3912_Vref = 1.2f;  // reference voltage for ADC in MCP3912 set in hardware
  private float MCP3912_gain = 1.0;  //assumed gain setting for MCP3912.  NEEDS TO BE ADJUSTABLE JM
  private float scale_fac_uVolts_per_count = (MCP3912_Vref * 1000000.f) / (8388607.0 * MCP3912_gain * 1.5 * 51.0); //MCP3912 datasheet page 34. Gain of InAmp = 80
  // private float scale_fac_accel_G_per_count = 0.032;
  private float scale_fac_accel_G_per_count_ble = 0.016;
  private float scale_fac_accel_G_per_count_wifi = 0.001;
  // private final float scale_fac_accel_G_per_count = 0.002 / ((float)pow(2,4));  //assume set to +/4G, so 2 mG per digit (datasheet). Account for 4 bits unused
  // private final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code

  private int curInterface = INTERFACE_NONE;

  private DataPacket_ADS1299 dataPacket;

  private boolean connected = false;

  public int numberOfDevices = 0;
  public int maxNumberOfDevices = 10;

  private boolean checkingImpedance = false;
  private boolean accelModeActive = true;

  public boolean impedanceUpdated = false;
  public int[] impedanceArray = new int[NCHAN_GANGLION + 1];

  private int sampleRate = (int)fsHzWifi;

  // Getters
  public float getSampleRate() {
    if (isBLE()) {
      return fsHzBLE;
    } else {
      return hub.getSampleRate();
    }
  }
  public int getNfft() {
    if (isWifi()) {
      if (hub.getSampleRate() == (int)fsHzBLE) {
        return NfftBLE;
      } else {
        return NfftWifi;
      }
    } else {
      return NfftBLE;
    }
  }
  public float get_scale_fac_uVolts_per_count() { return scale_fac_uVolts_per_count; }
  public float get_scale_fac_accel_G_per_count() {
    if (isWifi()) {
      return scale_fac_accel_G_per_count_wifi;
    } else {
      return scale_fac_accel_G_per_count_ble;
    }
  }
  public boolean isCheckingImpedance() { return checkingImpedance; }
  public boolean isAccelModeActive() { return accelModeActive; }
  public void overrideCheckingImpedance(boolean val) { checkingImpedance = val; }
  public int getInterface() {
    return curInterface;
  }
  public boolean isBLE () {
    return curInterface == INTERFACE_HUB_BLE || curInterface == INTERFACE_HUB_BLED112;
  }

  public boolean isWifi () {
    return curInterface == INTERFACE_HUB_WIFI;
  }

  public boolean isPortOpen() {
    return hub.isPortOpen();
  }

  private PApplet mainApplet;

  //constructors
  Ganglion() {};  //only use this if you simply want access to some of the constants
  Ganglion(PApplet applet) {
    mainApplet = applet;

    initDataPackets(nEEGValuesPerPacket, nAuxValuesPerPacket);
  }

  public void initDataPackets(int _nEEGValuesPerPacket, int _nAuxValuesPerPacket) {
    nEEGValuesPerPacket = _nEEGValuesPerPacket;
    nAuxValuesPerPacket = _nAuxValuesPerPacket;
    // For storing data into
    dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
    for(int i = 0; i < nEEGValuesPerPacket; i++) {
      dataPacket.values[i] = 0;
    }
    for(int i = 0; i < nAuxValuesPerPacket; i++){
      dataPacket.auxValues[i] = 0;
    }
  }

  private void handleError(int code, String msg) {
    output("Code " + code + "Error: " + msg);
    println("Code " + code + "Error: " + msg);
  }

  public void processImpedance(String msg) {
    String[] list = split(msg, ',');
    if (Integer.parseInt(list[1]) == RESP_SUCCESS_DATA_IMPEDANCE) {
      int channel = Integer.parseInt(list[2]);
      if (channel < 5) { //<>// //<>//
        int value = Integer.parseInt(list[3]);
        impedanceArray[channel] = value;
        if (channel == 0) {
          impedanceUpdated = true;
          println("Impedance for channel reference is " + value + " ohms.");
        } else {
          println("Impedance for channel " + channel + " is " + value + " ohms.");
        }
      }
    }
  }

  public void setSampleRate(int _sampleRate) {
    sampleRate = _sampleRate;
    hub.setSampleRate(sampleRate);
    println("Setting sample rate for Ganglion to " + sampleRate + "Hz");
  }

  public void setInterface(int _interface) {
    curInterface = _interface;
    if (isBLE()) {
      setSampleRate((int)fsHzBLE);
      if (_interface == INTERFACE_HUB_BLE) {
        hub.setProtocol(PROTOCOL_BLE);
      } else {
        hub.setProtocol(PROTOCOL_BLED112);
      }
      // hub.searchDeviceStart();
    } else if (isWifi()) {
      setSampleRate((int)fsHzWifi);
      hub.setProtocol(PROTOCOL_WIFI);
      hub.searchDeviceStart();
    }
  }

  public int copyDataPacketTo(DataPacket_ADS1299 target) {
    return dataPacket.copyTo(target);
  }

  // SCANNING/SEARCHING FOR DEVICES
  public int closePort() {
    if (isBLE()) {
      hub.disconnectBLE();
    } else if (isWifi()) {
      hub.disconnectWifi();
    }
    return 0;
  }

  /**
   * @description Sends a start streaming command to the Ganglion Node module.
   */
  void startDataTransfer(){
    hub.changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
    println("Ganglion: startDataTransfer(): sending \'" + command_startBinary);
    if (checkingImpedance) {
      impedanceStop();
      delay(100);
      hub.sendCommand('b');
    } else {
      hub.sendCommand('b');
    }
  }

  /**
   * @description Sends a stop streaming command to the Ganglion Node module.
   */
  public void stopDataTransfer() {
    hub.changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
    println("Ganglion: stopDataTransfer(): sending \'" + command_stop);
    hub.sendCommand('s');
  }

  private void printGanglion(String msg) {
    print("Ganglion: "); println(msg);
  }

  // Channel setting
  //activate or deactivate an EEG channel...channel counting is zero through nchan-1
  public void changeChannelState(int Ichan, boolean activate) {
    if (isPortOpen()) {
      if ((Ichan >= 0)) {
        if (activate) {
          println("Ganglion: changeChannelState(): activate: sending " + command_activate_channel[Ichan]);
          hub.sendCommand(command_activate_channel[Ichan]);
          w_timeSeries.hsc.powerUpChannel(Ichan);
        } else {
          println("Ganglion: changeChannelState(): deactivate: sending " + command_deactivate_channel[Ichan]);
          hub.sendCommand(command_deactivate_channel[Ichan]);
          w_timeSeries.hsc.powerDownChannel(Ichan);
        }
      }
    }
  }

  /**
   * Used to start accel data mode. Accel arrays will arrive asynchronously!
   */
  public void accelStart() {
    println("Ganglion: accell: START");
    hub.write(TCP_CMD_ACCEL + "," + TCP_ACTION_START + TCP_STOP);
    accelModeActive = true;
  }

  /**
   * Used to stop accel data mode. Some accel arrays may arrive after stop command
   *  was sent by this function.
   */
  public void accelStop() {
    println("Ganglion: accel: STOP");
    hub.write(TCP_CMD_ACCEL + "," + TCP_ACTION_STOP + TCP_STOP);
    accelModeActive = false;
  }

  /**
   * Used to start impedance testing. Impedances will arrive asynchronously!
   */
  public void impedanceStart() {
    println("Ganglion: impedance: START");
    hub.write(TCP_CMD_IMPEDANCE + "," + TCP_ACTION_START + TCP_STOP);
    checkingImpedance = true;
  }

  /**
   * Used to stop impedance testing. Some impedances may arrive after stop command
   *  was sent by this function.
   */
  public void impedanceStop() {
    println("Ganglion: impedance: STOP");
    hub.write(TCP_CMD_IMPEDANCE + "," + TCP_ACTION_STOP + TCP_STOP);
    checkingImpedance = false;
  }

  /**
   * Puts the ganglion in bootloader mode.
   */
  public void enterBootloaderMode() {
    println("Ganglion: Entering Bootloader Mode");
    hub.sendCommand(GANGLION_BOOTLOADER_MODE.charAt(0));
    delay(500);
    closePort();
    haltSystem();
    initSystemButton.setString("START SYSTEM");
    controlPanel.open();
    output("Ganglion now in bootloader mode! Enjoy!");
  }
};
