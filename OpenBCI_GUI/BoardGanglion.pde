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

boolean werePacketsDroppedGang = false;
int numPacketsDroppedGang = 0;

class Ganglion {
  final static String TCP_CMD_ACCEL = "a";
  final static String TCP_CMD_CONNECT = "c";
  final static String TCP_CMD_COMMAND = "k";
  final static String TCP_CMD_DISCONNECT = "d";
  final static String TCP_CMD_DATA= "t";
  final static String TCP_CMD_ERROR = "e"; //<>//
  final static String TCP_CMD_IMPEDANCE = "i";
  final static String TCP_CMD_LOG = "l";
  final static String TCP_CMD_SCAN = "s";
  final static String TCP_CMD_STATUS = "q";
  final static String TCP_STOP = ",;\n";

  final static String TCP_ACTION_START = "start";
  final static String TCP_ACTION_STATUS = "status";
  final static String TCP_ACTION_STOP = "stop";

  final static String GANGLION_BOOTLOADER_MODE = ">";

  final static byte BYTE_START = (byte)0xA0;
  final static byte BYTE_END = (byte)0xC0;

  // States For Syncing with the hardware
  final static int STATE_NOCOM = 0;
  final static int STATE_COMINIT = 1;
  final static int STATE_SYNCWITHHARDWARE = 2;
  final static int STATE_NORMAL = 3;
  final static int STATE_STOPPED = 4;
  final static int COM_INIT_MSEC = 3000; //you may need to vary this for your computer or your Arduino

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

  private int state = STATE_NOCOM;
  int prevState_millis = 0; // Used for calculating connect time out

  private int nEEGValuesPerPacket = NCHAN_GANGLION; // Defined by the data format sent by cyton boards
  private int nAuxValuesPerPacket = NUM_ACCEL_DIMS; // Defined by the arduino code

  private final float fs_Hz = 200.0f;  //sample rate used by OpenBCI Ganglion board... set by its Arduino code
  private final float MCP3912_Vref = 1.2f;  // reference voltage for ADC in MCP3912 set in hardware
  private float MCP3912_gain = 1.0;  //assumed gain setting for MCP3912.  NEEDS TO BE ADJUSTABLE JM
  private float scale_fac_uVolts_per_count = (MCP3912_Vref * 1000000.f) / (8388607.0 * MCP3912_gain * 1.5 * 51.0); //MCP3912 datasheet page 34. Gain of InAmp = 80
  // private float scale_fac_accel_G_per_count = 0.032;
  private float scale_fac_accel_G_per_count = 0.016;
  // private final float scale_fac_accel_G_per_count = 0.002 / ((float)pow(2,4));  //assume set to +/4G, so 2 mG per digit (datasheet). Account for 4 bits unused
  // private final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code

  private int bleErrorCounter = 0;
  private int prevSampleIndex = 0;

  private DataPacket_ADS1299 dataPacket;

  private boolean connected = false;

  public int numberOfDevices = 0;
  public int maxNumberOfDevices = 10;
  public String[] deviceList = new String[0];
  public boolean deviceListUpdated = false;
  private boolean hubRunning = false;
  public char[] tcpBuffer = new char[1024];
  public int tcpBufferPositon = 0;

  private boolean checkingImpedance = false;
  private boolean accelModeActive = false;
  private boolean newAccelData = false;
  private int[] accelArray = new int[NUM_ACCEL_DIMS];

  public boolean impedanceUpdated = false;
  public int[] impedanceArray = new int[NCHAN_GANGLION + 1];

  // Getters
  public float get_fs_Hz() { return fs_Hz; }
  public float get_scale_fac_uVolts_per_count() { return scale_fac_uVolts_per_count; }
  public float get_scale_fac_accel_G_per_count() { return scale_fac_accel_G_per_count; }
  public boolean isCheckingImpedance() { return checkingImpedance; }
  public boolean isAccelModeActive() { return accelModeActive; }

  private PApplet mainApplet;

  //constructors
  Ganglion() {};  //only use this if you simply want access to some of the constants
  Ganglion(PApplet applet) {
    mainApplet = applet;

    // For storing data into
    dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
    for(int i = 0; i < nEEGValuesPerPacket; i++) {
      dataPacket.values[i] = 0;
    }
    for(int i = 0; i < nAuxValuesPerPacket; i++){
      dataPacket.auxValues[i] = 0;
    }
  }

  public void processAccel(String msg) {
    String[] list = split(msg, ',');
    if (Integer.parseInt(list[1]) == RESP_SUCCESS_DATA_ACCEL) {
      for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
        accelArray[i] = Integer.parseInt(list[i + 2]);
      }
      newAccelData = true;
    }
  }

  public void processData(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);
    if (eegDataSource == DATASOURCE_GANGLION && systemMode == 10 && isRunning) { //<>//
      if (Integer.parseInt(list[1]) == RESP_SUCCESS_DATA_SAMPLE) { //<>//
        // Sample number stuff
        dataPacket.sampleIndex = int(Integer.parseInt(list[2]));
        if ((dataPacket.sampleIndex - prevSampleIndex) != 1) {
          if(dataPacket.sampleIndex != 0){  // if we rolled over, don't count as error
            bleErrorCounter++;

            werePacketsDroppedGang = true; //set this true to activate packet duplication in serialEvent
            if(dataPacket.sampleIndex < prevSampleIndex){   //handle the situation in which the index jumps from 250s past 255, and back to 0
              numPacketsDroppedGang = (dataPacket.sampleIndex+200) - prevSampleIndex; //calculate how many times the last received packet should be duplicated...
            } else {
              numPacketsDroppedGang = dataPacket.sampleIndex - prevSampleIndex; //calculate how many times the last received packet should be duplicated...
            }
            println("Ganglion: apparent sampleIndex jump from Serial data: " + prevSampleIndex + " to  " + dataPacket.sampleIndex + ".  Keeping packet. (" + bleErrorCounter + ")");
            println("numPacketsDropped = " + numPacketsDropped);
          }
        }
        prevSampleIndex = dataPacket.sampleIndex;

        // Channel data storage
        for (int i = 0; i < NCHAN_GANGLION; i++) {
          dataPacket.values[i] = Integer.parseInt(list[3 + i]);
        }
        if (newAccelData) {
          newAccelData = false;
          for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
            dataPacket.auxValues[i] = accelArray[i];
            dataPacket.rawAuxValues[i][0] = byte(accelArray[i]);
          }
        }
        getRawValues(dataPacket);
        // println(binary(dataPacket.values[0], 24) + '\n' + binary(dataPacket.rawValues[0][0], 8) + binary(dataPacket.rawValues[0][1], 8) + binary(dataPacket.rawValues[0][2], 8) + '\n'); //<>//
        curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length; // This is also used to let the rest of the code that it may be time to do something

        ganglion.copyDataPacketTo(dataPacketBuff[curDataPacketInd]);  // Resets isNewDataPacketAvailable to false

        // KILL SPIKES!!!
        if(werePacketsDroppedGang){
          // println("Packets Dropped ... doing some stuff...");
          for(int i = numPacketsDroppedGang; i > 0; i--){
            int tempDataPacketInd = curDataPacketInd - i; //
            if(tempDataPacketInd >= 0 && tempDataPacketInd < dataPacketBuff.length){
              // println("i = " + i);
              ganglion.copyDataPacketTo(dataPacketBuff[tempDataPacketInd]);
            } else {
              ganglion.copyDataPacketTo(dataPacketBuff[tempDataPacketInd+200]);
            }
            //put the last stored packet in # of packets dropped after that packet
          }

          //reset werePacketsDropped & numPacketsDropped
          werePacketsDroppedGang = false;
          numPacketsDroppedGang = 0;
        }

        switch (outputDataSource) {
          case OUTPUT_SOURCE_ODF:
            fileoutput_odf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd], ganglion.get_scale_fac_uVolts_per_count(), get_scale_fac_accel_G_per_count());
            break;
          case OUTPUT_SOURCE_BDF:
            // curBDFDataPacketInd = curDataPacketInd;
            // thread("writeRawData_dataPacket_bdf");
            fileoutput_bdf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd]);
            break;
          case OUTPUT_SOURCE_NONE:
          default:
            // Do nothing...
            break;
        }
        newPacketCounter++;
      } else {
        bleErrorCounter++;
        println("Ganglion: parseMessage: data: bad");
      }
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
      if (channel < 5) { //<>//
        int value = Integer.parseInt(list[3]);
        impedanceArray[channel] = value;
        if (channel == 0) {
          impedanceUpdated = true;
          println("Impedance for channel reference is " + value + " ohms.");
        } else {
          println("? for channel " + channel + " is " + value + " ohms.");
        }
      }
    }
  }

  void writeRawData_dataPacket_bdf() {
    fileoutput_bdf.writeRawData_dataPacket(dataPacketBuff[curBDFDataPacketInd]);
  }

  public int copyDataPacketTo(DataPacket_ADS1299 target) {
    return dataPacket.copyTo(target);
  }

  private void getRawValues(DataPacket_ADS1299 packet) {
    for (int i=0; i < nchan; i++) {
      int val = packet.values[i];
      //println(binary(val, 24));
      byte rawValue[] = new byte[3];
      // Breakdown values into
      rawValue[2] = byte(val & 0xFF);
      //println("rawValue[2] " + binary(rawValue[2], 8));
      rawValue[1] = byte((val & (0xFF << 8)) >> 8);
      //println("rawValue[1] " + binary(rawValue[1], 8));
      rawValue[0] = byte((val & (0xFF << 16)) >> 16);
      //println("rawValue[0] " + binary(rawValue[0], 8));
      // Store to the target raw values
      packet.rawValues[i] = rawValue;
      //println();
    }
  }

  public boolean isSuccessCode(int c) {
    return c == RESP_SUCCESS;
  }

  // SCANNING/SEARHING FOR DEVICES

  public void searchDeviceStart() {
    deviceList = null;
    numberOfDevices = 0;
    hub.safeTCPWrite(TCP_CMD_SCAN + ',' + TCP_ACTION_START + TCP_STOP);
  }

  public void searchDeviceStop() {
    hub.safeTCPWrite(TCP_CMD_SCAN + ',' + TCP_ACTION_STOP + TCP_STOP);
  }

  public boolean searchDeviceAdd(String ganglionLocalName) {
    if (numberOfDevices == 0) {
      numberOfDevices++;
      deviceList = new String[numberOfDevices];
      deviceList[0] = ganglionLocalName;
      return true;
    } else {
      boolean willAddToDeviceList = true;
      for (int i = 0; i < numberOfDevices; i++) {
        if (ganglionLocalName.equals(deviceList[i])) {
          willAddToDeviceList = false;
          break;
        }
      }
      if (willAddToDeviceList) {
        numberOfDevices++;
        String[] tempList = new String[numberOfDevices];
        arrayCopy(deviceList, tempList);
        tempList[numberOfDevices - 1] = ganglionLocalName;
        deviceList = tempList;
        return true;
      }
    }
    return false;
  }

  public int closePort() {
    if (interface == INTERFACE_HUB_BLE) {
      hub.disconnectBLE();
    } else {
      hub.disconnectWifi();
    }
  }

  /**
   * @description Sends a start streaming command to the Ganglion Node module.
   */
  void startDataTransfer(){
    hub.changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
    println("Ganglion: startDataTransfer(): sending \'" + command_startBinary);
    hub.safeTCPWrite(TCP_CMD_COMMAND + "," + command_startBinary + TCP_STOP);
  }

  /**
   * @description Sends a stop streaming command to the Ganglion Node module.
   */
  public void stopDataTransfer() {
    hub.changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
    println("Ganglion: stopDataTransfer(): sending \'" + command_stop);
    hub.safeTCPWrite(TCP_CMD_COMMAND + "," + command_stop + TCP_STOP);
  }


  /**
   * @description Sends a command to ganglion board
   */
  public void passthroughCommand(char c) {
    println("Ganglion: passthroughCommand(): sending \'" + c);
    hub.safeTCPWrite(TCP_CMD_COMMAND + "," + c + TCP_STOP);
  }

  /**
   * @description Write to TCP server
   * @params out {String} - The string message to write to the server.
   * @returns {boolean} - True if able to write, false otherwise.
   */
  public boolean hub.safeTCPWrite(String out) {
    try {
      tcpClient.write(out);
      return true;
    } catch (Exception e) {
      println("Error: Attempted to TCP write with no server connection initialized");
      return false;
    }
    // return false;
    // if (nodeProcessHandshakeComplete) { //<>//
    //   try {
    //     tcpClient.write(out);
    //     return true;
    //   } catch (NullPointerException e) {
    //     println("Error: Attempted to TCP write with no server connection initialized");
    //     return false;
    //   }
    // } else {
    //   println("Waiting on node handshake!");
    //   return false;
    // }
  }

  private void printGanglion(String msg) {
    print("Ganglion: "); println(msg);
  }

  // Channel setting
  //activate or deactivate an EEG channel...channel counting is zero through nchan-1
  public void changeChannelState(int Ichan, boolean activate) {
    if (connected) {
      if ((Ichan >= 0)) {
        if (activate) {
          println("Ganglion: changeChannelState(): activate: sending " + command_activate_channel[Ichan]);
          hub.safeTCPWrite(TCP_CMD_COMMAND + "," + command_activate_channel[Ichan] + TCP_STOP);
          w_timeSeries.hsc.powerUpChannel(Ichan);
        } else {
          println("Ganglion: changeChannelState(): deactivate: sending " + command_deactivate_channel[Ichan]);
          hub.safeTCPWrite(TCP_CMD_COMMAND + "," + command_deactivate_channel[Ichan] + TCP_STOP);
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
    hub.safeTCPWrite(TCP_CMD_ACCEL + "," + TCP_ACTION_START + TCP_STOP);
    accelModeActive = true;
  }

  /**
   * Used to stop accel data mode. Some accel arrays may arrive after stop command
   *  was sent by this function.
   */
  public void accelStop() {
    println("Ganglion: accel: STOP");
    hub.safeTCPWrite(TCP_CMD_ACCEL + "," + TCP_ACTION_STOP + TCP_STOP);
    accelModeActive = false;
  }

  /**
   * Used to start impedance testing. Impedances will arrive asynchronously!
   */
  public void impedanceStart() {
    println("Ganglion: impedance: START");
    hub.safeTCPWrite(TCP_CMD_IMPEDANCE + "," + TCP_ACTION_START + TCP_STOP);
    checkingImpedance = true;
  }

  /**
   * Used to stop impedance testing. Some impedances may arrive after stop command
   *  was sent by this function.
   */
  public void impedanceStop() {
    println("Ganglion: impedance: STOP");
    hub.safeTCPWrite(TCP_CMD_IMPEDANCE + "," + TCP_ACTION_STOP + TCP_STOP);
    checkingImpedance = false;
  }

  /**
   * Puts the ganglion in bootloader mode.
   */
  public void enterBootloaderMode() {
    println("Ganglion: Entering Bootloader Mode");
    hub.safeTCPWrite(TCP_CMD_COMMAND + "," + GANGLION_BOOTLOADER_MODE + TCP_STOP);
    delay(500);
    disconnectBLE();
    haltSystem();
    initSystemButton.setString("START SYSTEM");
    controlPanel.open();
    output("Ganglion now in bootloader mode! Enjoy!");
  }
};
