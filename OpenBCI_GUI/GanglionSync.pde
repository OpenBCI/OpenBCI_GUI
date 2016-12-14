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

void clientEvent(Client someClient) {
  // print("Server Says:  ");

  int p = ganglion.tcpBufferPositon;
  ganglion.tcpBuffer[p] = ganglion.tcpClient.readChar();
  ganglion.tcpBufferPositon++;

  if(p > 2) {
    String posMatch  = new String(ganglion.tcpBuffer, p - 2, 3);
    if (posMatch.equals(ganglion.TCP_STOP)) {
      if (!ganglion.nodeProcessHandshakeComplete) {
        ganglion.nodeProcessHandshakeComplete = true;
        ganglion.setHubIsRunning(true);
        println("GanglionSync: clientEvent: handshake complete");
      }
      // Get a string from the tcp buffer
      String msg = new String(ganglion.tcpBuffer, 0, p);
      // Send the new string message to be processed
      ganglion.parseMessage(msg);
      // Check to see if the ganglion ble list needs to be updated
      if (ganglion.deviceListUpdated) {
        ganglion.deviceListUpdated = false;
        controlPanel.bleBox.refreshBLEList();
      }
      // Reset the buffer position
      ganglion.tcpBufferPositon = 0;
    }
  } //<>//
}

class OpenBCI_Ganglion {
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
  final static int RESP_STATUS_CONNECTED = 300;
  final static int RESP_STATUS_DISCONNECTED = 301;
  final static int RESP_STATUS_SCANNING = 302;
  final static int RESP_STATUS_NOT_SCANNING = 303;

  private int state = STATE_NOCOM;
  int prevState_millis = 0; // Used for calculating connect time out

  private int nEEGValuesPerPacket = NCHAN_GANGLION; // Defined by the data format sent by openBCI boards
  private int nAuxValuesPerPacket = 0; // Defined by the arduino code

  private int tcpGanglionPort = 10996;
  private String tcpGanglionIP = "127.0.0.1";
  private String tcpGanglionFull = tcpGanglionIP + ":" + tcpGanglionPort;
  private boolean tcpClientActive = false;
  private int tcpTimeout = 1000;

  private final float fs_Hz = 200.0f;  //sample rate used by OpenBCI Ganglion board... set by its Arduino code
  private final float MCP3912_Vref = 1.2f;  // reference voltage for ADC in MCP3912 set in hardware
  private float MCP3912_gain = 1.0;  //assumed gain setting for MCP3912.  NEEDS TO BE ADJUSTABLE JM
  private float scale_fac_uVolts_per_count = (MCP3912_Vref * 1000000.f) / (8388607.0 * MCP3912_gain * 1.5 * 51.0); //MCP3912 datasheet page 34. Gain of InAmp = 80
  private float scale_fac_accel_G_per_count = 0.032;
  // private final float scale_fac_accel_G_per_count = 0.002 / ((float)pow(2,4));  //assume set to +/4G, so 2 mG per digit (datasheet). Account for 4 bits unused
  // private final float leadOffDrive_amps = 6.0e-9;  //6 nA, set by its Arduino code

  private int bleErrorCounter = 0;
  private int prevSampleIndex = 0;

  private DataPacket_ADS1299 dataPacket;

  public Client tcpClient;
  private boolean portIsOpen = false;
  private boolean connected = false;

  public int numberOfDevices = 0;
  public int maxNumberOfDevices = 10;
  public String[] deviceList = new String[0];
  public boolean deviceListUpdated = false;
  private boolean hubRunning = false;
  public char[] tcpBuffer = new char[1024];
  public int tcpBufferPositon = 0;

  private boolean waitingForResponse = false;
  private boolean nodeProcessHandshakeComplete = false;
  public boolean shouldStartNodeApp = false;
  private boolean checkingImpedance = false;
  private boolean accelModeActive = false;
  private boolean newAccelData = false;
  private int[] accelArray = new int[NUM_ACCEL_DIMS];

  public boolean impedanceUpdated = false;
  public int[] impedanceArray = new int[NCHAN_GANGLION + 1];

  // Getters
  public float get_fs_Hz() { return fs_Hz; }
  public boolean isPortOpen() { return portIsOpen; }
  public float get_scale_fac_uVolts_per_count() { return scale_fac_uVolts_per_count; }
  public float get_scale_fac_accel_G_per_count() { return scale_fac_accel_G_per_count; }
  public boolean isHubRunning() { return hubRunning; }
  public boolean isCheckingImpedance() { return checkingImpedance; }
  public boolean isAccelModeActive() { return accelModeActive; }

  private PApplet mainApplet;

  //constructors
  OpenBCI_Ganglion() {};  //only use this if you simply want access to some of the constants
  OpenBCI_Ganglion(PApplet applet) {
    mainApplet = applet;

    // Able to start tcpClient connection?
    startTCPClient(mainApplet);
    // if (getStatus()) {
    //   println("Able to start tcpClient connection -- YES");
    //   hubRunning = true;
    // } else {
    //   println("Able to start tcpClient connection -- NO");
    // }

    // if (getStatus()) {
    //   println("Able to send status message, now waiting for response.");
    // } else {
    //   // We should try to start the node process because we were not able to
    //   //  establish a connection with the node process.
    //   println("Failure: Not able to send status message. Trying to start tcpConnection.");
    //   startTCPClient(applet);
    //   if (getStatus()) {
    //     println("Connection established with node server.");
    //   } else {
    //     println("Connection failed to establish with node server. Recommend trying to launch application from data dir.");
    //     shouldStartNodeApp = true;
    //   }
    // }

    // For storing data into
    dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
    for(int i = 0; i < nEEGValuesPerPacket; i++) {
      dataPacket.values[i] = 0;
    }
    for(int i = 0; i < nAuxValuesPerPacket; i++){
      dataPacket.auxValues[i] = 0;
    }
  }

  /**
   * @descirpiton Used to `try` and start the tcpClient
   * @param applet {PApplet} - The main applet.
   * @return {boolean} - True if able to start.
   */
  public boolean startTCPClient(PApplet applet) {
    try {
      tcpClient = new Client(applet, tcpGanglionIP, tcpGanglionPort);
      return true;
    } catch (Exception e) {
      println("startTCPClient: ConnectException: " + e);
      return false;
    }
  }


  /**
   * Sends a status message to the node process.
   */
  public boolean getStatus() {
    try {
      safeTCPWrite(TCP_CMD_STATUS + TCP_STOP);
      waitingForResponse = true;
      return true;
    } catch (NullPointerException E) {
      // The tcp client is not initalized, try now

      return false;
    }
  }

  public void setHubIsRunning(boolean isRunning) {
    hubRunning = isRunning;
  }

  // Return true if the display needs to be updated for the BLE list
  public void parseMessage(String msg) {
    // println(msg);
    String[] list = split(msg, ',');
    switch (list[0].charAt(0)) {
      case 'c': // Connect
        if (isSuccessCode(Integer.parseInt(list[1]))) {
          println("OpenBCI_Ganglion: parseMessage: connect: success!");
          output("OpenBCI_Ganglion: The GUI is done intializing. Click outside of the control panel to interact with the GUI.");
          systemMode = 10;
          connected = true;
        } else {
          println("OpenBCI_Ganglion: parseMessage: connect: failure :(");
          output("Unable to connect to ganglion!");
          connected = false;
        }
        break;
      case 'a': // Accel
        processAccel(msg);
        break;
      case 'i': // Impedance
        processImpedance(msg);
        break;
      case 't': // Data
        processData(msg);
        break;
      case 'e': // Error
        println("OpenBCI_Ganglion: parseMessage: error: " + list[2]);
        break;
      case 's': // Scan
        processScan(msg);
        break;
      case 'l':
        println("OpenBCI_Ganglion: Log: " + list[1]);
        break;
      case 'q':
        if (waitingForResponse) {
          waitingForResponse = false;
          println("Node process up!");
        }
        println("OpenBCI_Ganglion: Status: 200");
        break;
      default:
        println("OpenBCI_Ganglion: parseMessage: default: " + msg);
        break;
    }
  }

  private void processAccel(String msg) {
    println(msg);
    // String[] list = split(msg, ',');
    // for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
    //   accelArray[i] = Integer.parseInt(list[i + 1]);
    // }
    // newAccelData = true;
  }

  private void processData(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);
    if (eegDataSource == DATASOURCE_GANGLION && systemMode == 10 && isRunning) { //<>//
      if (isSuccessCode(Integer.parseInt(list[1]))) { //<>//
        // Sample number stuff
        dataPacket.sampleIndex = int(Integer.parseInt(list[2]));
        if ((dataPacket.sampleIndex - prevSampleIndex) != 1) {
          if(dataPacket.sampleIndex != 0){  // if we rolled over, don't count as error
            bleErrorCounter++;
            println("OpenBCI_Ganglion: apparent sampleIndex jump from Serial data: " + prevSampleIndex + " to  " + dataPacket.sampleIndex + ".  Keeping packet. (" + bleErrorCounter + ")");
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
        switch (outputDataSource) {
          case OUTPUT_SOURCE_ODF:
            fileoutput_odf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd], ganglion.get_scale_fac_uVolts_per_count(), 0);
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
        println("OpenBCI_Ganglion: parseMessage: data: bad");
      }
    }
  }

  private void handleError(int code, String msg) {
    output("Code " + code + "Error: " + msg);
    println("Code " + code + "Error: " + msg);
  }

  private void processImpedance(String msg) {
    String[] list = split(msg, ',');
    println("Length = " + list.length);
    for(int i = 0; i < list.length; i++){
      println(i + " " + list[i]);
    }
    int channel = Integer.parseInt(list[1]);
    if (channel < 5) { //<>//
      println("channel - " + channel);
      int value = Integer.parseInt(list[2]);
      impedanceArray[channel] = value;

      if (channel == 0) {
        impedanceUpdated = true;
        println("Impedance for channel reference is " + value + " ohms.");
      } else {
        println("? for channel " + channel + " is " + value + " ohms.");
      }
    } else {
      //println("Impedance " + list[2]);
    }

  }

  private void processScan(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);
    switch(code) {
      case RESP_GANGLION_FOUND:
        // Sent every time a new ganglion device is found
        if (searchDeviceAdd(list[2])) {
          deviceListUpdated = true;
        }
        break;
      case RESP_ERROR_SCAN_ALREADY_SCANNING:
        // Sent when a start send command is sent and the module is already
        //  scanning.
        handleError(code, list[2]);
        break;
      case RESP_SUCCESS:
        // Sent when either a scan was stopped or started Successfully
        String action = list[2];
        switch (action) {
          case TCP_ACTION_START:
            break;
          case TCP_ACTION_STOP:
            break;
        }
        break;
      case RESP_ERROR_SCAN_COULD_NOT_START:
        // Sent when err on search start
        handleError(code, list[2]);
        break;
      case RESP_ERROR_SCAN_COULD_NOT_STOP:
        // Send when err on search stop
        handleError(code, list[2]);
        break;
      case RESP_STATUS_SCANNING:
        // Sent when after status action sent to node and module is searching
        break;
      case RESP_STATUS_NOT_SCANNING:
        // Sent when after status action sent to node and module is NOT searching
        break;
      case RESP_ERROR_SCAN_NO_SCAN_TO_STOP:
        // Sent when a 'stop' action is sent to node and there is no scan to stop.
        handleError(code, list[2]);
        break;
      case RESP_ERROR_UNKNOWN:
      default:
        handleError(code, list[2]);
        break;
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

  // TODO: Figure out how to ping the server at localhost listening on port 10996
  // /**
  //  * Used to ping the local hub tcp server and check it's status.
  //  */
  // public boolean pingHub() {
  //   boolean pingStat;
  //
  //   try {
  //     println("GanglionSync: pingHub: trying... ");
  //     pingStat = InetAddress.getByName("127.0.0.1:10996").isReachable(tcpTimeout);
  //     print("GanglionSync: pingHub: ");
  //     println(pingStat);
  //     return pingStat;
  //   }
  //   catch(Exception E){
  //     E.printStackTrace();
  //     return false;
  //   }
  // }

  public boolean isSuccessCode(int c) {
    return c == RESP_SUCCESS;
  }

  // SCANNING/SEARHING FOR DEVICES

  public void searchDeviceStart() {
    deviceList = null;
    numberOfDevices = 0;
    safeTCPWrite(TCP_CMD_SCAN + ',' + TCP_ACTION_START + TCP_STOP);
  }

  public void searchDeviceStop() {
    safeTCPWrite(TCP_CMD_SCAN + ',' + TCP_ACTION_STOP + TCP_STOP);
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
        if (deviceList[i] == ganglionLocalName) {
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

  // CONNECTION
  public void connectBLE(String id) {
    safeTCPWrite(TCP_CMD_CONNECT + "," + id + TCP_STOP);
  }

  public void disconnectBLE() {
    safeTCPWrite(TCP_CMD_DISCONNECT + TCP_STOP);
  }

  public void updateSyncState() {
    //has it been 3000 milliseconds since we initiated the serial port? We want to make sure we wait for the OpenBCI board to finish its setup()
    if ((millis() - prevState_millis > COM_INIT_MSEC) && (prevState_millis != 0) && (state == openBCI.STATE_COMINIT) ) {
      // We are synced and ready to go!
      state = STATE_SYNCWITHHARDWARE;
      println("OpenBCI_Ganglion: Sending reset command");
      // serial_openBCI.write('v');
    }
  }

  /**
   * @description Sends a start streaming command to the Ganglion Node module.
   */
  void startDataTransfer(){
    changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
    println("OpenBCI_Ganglion: startDataTransfer(): sending \'" + command_startBinary);
    safeTCPWrite(TCP_CMD_COMMAND + "," + command_startBinary + TCP_STOP);
  }

  /**
   * @description Sends a stop streaming command to the Ganglion Node module.
   */
  public void stopDataTransfer() {
    changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
    println("OpenBCI_Ganglion: stopDataTransfer(): sending \'" + command_stop);
    safeTCPWrite(TCP_CMD_COMMAND + "," + command_stop + TCP_STOP);
  }

  /**
   * @description Write to TCP server
   * @params out {String} - The string message to write to the server.
   * @returns {boolean} - True if able to write, false otherwise.
   */
  public boolean safeTCPWrite(String out) {
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
    print("OpenBCI_Ganglion: "); println(msg);
  }

  public int changeState(int newState) {
    state = newState;
    prevState_millis = millis();
    return 0;
  }

  // Channel setting
  //activate or deactivate an EEG channel...channel counting is zero through nchan-1
  public void changeChannelState(int Ichan, boolean activate) {
    if (connected) {
      if ((Ichan >= 0)) {
        if (activate) {
          println("OpenBCI_Ganglion: changeChannelState(): activate: sending " + command_activate_channel[Ichan]);
          safeTCPWrite(TCP_CMD_COMMAND + "," + command_activate_channel[Ichan] + TCP_STOP);
          w_timeSeries.hsc.powerUpChannel(Ichan);
        } else {
          println("OpenBCI_Ganglion: changeChannelState(): deactivate: sending " + command_deactivate_channel[Ichan]);
          safeTCPWrite(TCP_CMD_COMMAND + "," + command_deactivate_channel[Ichan] + TCP_STOP);
          w_timeSeries.hsc.powerUpChannel(Ichan);
        }
      }
    }
  }

  /**
   * Used to start accel data mode. Accel arrays will arrive asynchronously!
   */
  public void accelStart() {
    println("OpenBCI_Ganglion: accell: START");
    safeTCPWrite(TCP_CMD_ACCEL + "," + TCP_ACTION_START + TCP_STOP);
    accelModeActive = true;
  }

  /**
   * Used to stop accel data mode. Some accel arrays may arrive after stop command
   *  was sent by this function.
   */
  public void accelStop() {
    println("OpenBCI_Ganglion: accel: STOP");
    safeTCPWrite(TCP_CMD_ACCEL + "," + TCP_ACTION_STOP + TCP_STOP);
    accelModeActive = false;
  }

  /**
   * Used to start impedance testing. Impedances will arrive asynchronously!
   */
  public void impedanceStart() {
    println("OpenBCI_Ganglion: impedance: START");
    safeTCPWrite(TCP_CMD_IMPEDANCE + "," + TCP_ACTION_START + TCP_STOP);
    checkingImpedance = true;
  }

  /**
   * Used to stop impedance testing. Some impedances may arrive after stop command
   *  was sent by this function.
   */
  public void impedanceStop() {
    println("OpenBCI_Ganglion: impedance: STOP");
    safeTCPWrite(TCP_CMD_IMPEDANCE + "," + TCP_ACTION_STOP + TCP_STOP);
    checkingImpedance = false;
  }
};
