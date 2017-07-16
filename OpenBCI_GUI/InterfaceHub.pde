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

boolean werePacketsDroppedHub = false;
int numPacketsDroppedHub = 0;

void clientEvent(Client someClient) {
  // print("Server Says:  ");
  int p = hub.tcpBufferPositon;
  hub.tcpBuffer[p] = hub.tcpClient.readChar();
  hub.tcpBufferPositon++;

  if(p > 2) {
    String posMatch  = new String(hub.tcpBuffer, p - 2, 3);
    if (posMatch.equals(hub.TCP_STOP)) {
      if (!hub.nodeProcessHandshakeComplete) {
        hub.nodeProcessHandshakeComplete = true;
        hub.setHubIsRunning(true);
        println("Hub: clientEvent: handshake complete");
      }
      // Get a string from the tcp buffer
      String msg = new String(hub.tcpBuffer, 0, p);
      // Send the new string message to be processed

      if (eegDataSource == DATASOURCE_GANGLION) {
        hub.parseMessage(msg);
        // Check to see if the ganglion ble list needs to be updated
        if (hub.deviceListUpdated) {
          hub.deviceListUpdated = false;
          controlPanel.bleBox.refreshBLEList();
          controlPanel.wifiBox.refreshWifiList();
        }
      } else if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
        // Do stuff for cyton
        hub.parseMessage(msg);
        // Check to see if the ganglion ble list needs to be updated
        if (hub.deviceListUpdated) {
          hub.deviceListUpdated = false;
          controlPanel.wifiBox.refreshWifiList();
        }
      }

      // Reset the buffer position
      hub.tcpBufferPositon = 0;
    }
  }
}

class Hub {
  final static String TCP_CMD_ACCEL = "a";
  final static String TCP_CMD_CONNECT = "c";
  final static String TCP_CMD_COMMAND = "k";
  final static String TCP_CMD_DISCONNECT = "d";
  final static String TCP_CMD_DATA = "t";
  final static String TCP_CMD_ERROR = "e"; //<>//
  final static String TCP_CMD_IMPEDANCE = "i";
  final static String TCP_CMD_LOG = "l";
  final static String TCP_CMD_PROTOCOL = "p";
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
  final static int RESP_WIFI_FOUND = 205;
  final static int RESP_STATUS_CONNECTED = 300;
  final static int RESP_STATUS_DISCONNECTED = 301;
  final static int RESP_STATUS_SCANNING = 302;
  final static int RESP_STATUS_NOT_SCANNING = 303;

  public String[] deviceList = new String[0];
  public boolean deviceListUpdated = false;

  private int bleErrorCounter = 0;
  private int prevSampleIndex = 0;

  private int state = STATE_NOCOM;
  int prevState_millis = 0; // Used for calculating connect time out

  private int nEEGValuesPerPacket = NCHAN_GANGLION; // Defined by the data format sent by cyton boards
  private int nAuxValuesPerPacket = NUM_ACCEL_DIMS; // Defined by the arduino code

  private int tcpHubPort = 10996;
  private String tcpHubIP = "127.0.0.1";
  private String tcpHubFull = tcpHubIP + ":" + tcpHubPort;
  private boolean tcpClientActive = false;
  private int tcpTimeout = 1000;

  private DataPacket_ADS1299 dataPacket;

  public Client tcpClient;
  private boolean portIsOpen = false;
  private boolean connected = false;

  public int numberOfDevices = 0;
  public int maxNumberOfDevices = 10;
  private boolean hubRunning = false;
  public char[] tcpBuffer = new char[1024];
  public int tcpBufferPositon = 0;
  private String curProtocol = PROTOCOL_WIFI;

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
  public int get_state() { return state; }
  public boolean isPortOpen() { return portIsOpen; }
  public boolean isHubRunning() { return hubRunning; }
  public boolean isCheckingImpedance() { return checkingImpedance; }
  public boolean isAccelModeActive() { return accelModeActive; }

  private PApplet mainApplet;

  //constructors
  Hub() {};  //only use this if you simply want access to some of the constants
  Hub(PApplet applet) {
    mainApplet = applet;

    // For storing data into
    dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
    for(int i = 0; i < nEEGValuesPerPacket; i++) {
      dataPacket.values[i] = 0;
    }
    for(int i = 0; i < nAuxValuesPerPacket; i++){
      dataPacket.auxValues[i] = 0;
    }

    // Able to start tcpClient connection?
    startTCPClient(mainApplet);

  }

  /**
   * @descirpiton Used to `try` and start the tcpClient
   * @param applet {PApplet} - The main applet.
   * @return {boolean} - True if able to start.
   */
  public boolean startTCPClient(PApplet applet) {
    try {
      tcpClient = new Client(applet, tcpHubIP, tcpHubPort);
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
      write(TCP_CMD_STATUS + TCP_STOP);
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
        processConnect(msg);
        break;
      case 'a': // Accel
        if (eegDataSource == DATASOURCE_GANGLION) {
          ganglion.processAccel(msg);
        }
        break;
      case 'd': // Disconnect
        processDisconnect(msg);
        break;
      case 'i': // Impedance
        if (eegDataSource == DATASOURCE_GANGLION) {
          ganglion.processImpedance(msg);
        }
        break;
      case 't': // Data
        processData(msg);
        break;
      case 'e': // Error
        println("Hub: parseMessage: error: " + list[2]);
        break;
      case 's': // Scan
        processScan(msg);
        break;
      case 'l':
        println("Hub: Log: " + list[1]);
        break;
      case 'q':
        processStatus(msg);
        break;
      default:
        println("Hub: parseMessage: default: " + msg);
        break;
    }
  }

  private void handleError(int code, String msg) {
    output("Code " + code + "Error: " + msg);
    println("Code " + code + "Error: " + msg);
  }

  private void processConnect(String msg) {
    String[] list = split(msg, ',');
    if (isSuccessCode(Integer.parseInt(list[1]))) {
      systemMode = 10;
      controlPanel.close();
      println("Hub: parseMessage: connect: success!");
      output("Hub: The GUI is done intializing. Click outside of the control panel to interact with the GUI.");
      connected = true;
    } else {
      println("Hub: parseMessage: connect: failure!");
      haltSystem();
      initSystemButton.setString("START SYSTEM");
      controlPanel.open();
      abandonInit = true;
      output("Unable to connect to Ganglion! Please ensure board is powered on and in range!");
      connected = false;
    }
  }

  public void processData(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);
    if ((eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_NORMAL_W_AUX) && systemMode == 10 && isRunning) { //<>//
      if (Integer.parseInt(list[1]) == RESP_SUCCESS_DATA_SAMPLE) { //<>//
        // Sample number stuff
        dataPacket.sampleIndex = int(Integer.parseInt(list[2]));
        if ((dataPacket.sampleIndex - prevSampleIndex) != 1) {
          if(dataPacket.sampleIndex != 0){  // if we rolled over, don't count as error
            bleErrorCounter++;

            werePacketsDroppedHub = true; //set this true to activate packet duplication in serialEvent
            if(dataPacket.sampleIndex < prevSampleIndex){   //handle the situation in which the index jumps from 250s past 255, and back to 0
              numPacketsDroppedHub = (dataPacket.sampleIndex+200) - prevSampleIndex; //calculate how many times the last received packet should be duplicated...
            } else {
              numPacketsDroppedHub = dataPacket.sampleIndex - prevSampleIndex; //calculate how many times the last received packet should be duplicated...
            }
            println("Ganglion: apparent sampleIndex jump from Serial data: " + prevSampleIndex + " to  " + dataPacket.sampleIndex + ".  Keeping packet. (" + bleErrorCounter + ")");
            println("numPacketsDropped = " + numPacketsDroppedHub);
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

        if (eegDataSource == DATASOURCE_GANGLION) {
          ganglion.copyDataPacketTo(dataPacketBuff[curDataPacketInd]);  // Resets isNewDataPacketAvailable to false
        } else {
          cyton.copyDataPacketTo(dataPacketBuff[curDataPacketInd]);  // Resets isNewDataPacketAvailable to false
        }

        // KILL SPIKES!!!
        if(werePacketsDroppedHub){
          // println("Packets Dropped ... doing some stuff...");
          for(int i = numPacketsDroppedHub; i > 0; i--){
            int tempDataPacketInd = curDataPacketInd - i; //
            if(tempDataPacketInd >= 0 && tempDataPacketInd < dataPacketBuff.length){
              // println("i = " + i);
              if (eegDataSource == DATASOURCE_GANGLION) {
                ganglion.copyDataPacketTo(dataPacketBuff[tempDataPacketInd]);
              } else {
                cyton.copyDataPacketTo(dataPacketBuff[tempDataPacketInd]);
              }
            } else {
              if (eegDataSource == DATASOURCE_GANGLION) {
                ganglion.copyDataPacketTo(dataPacketBuff[tempDataPacketInd+200]);
              } else {
                cyton.copyDataPacketTo(dataPacketBuff[tempDataPacketInd+200]);
              }
            }
            //put the last stored packet in # of packets dropped after that packet
          }

          //reset werePacketsDropped & numPacketsDropped
          werePacketsDroppedHub = false;
          numPacketsDroppedHub = 0;
        }

        switch (outputDataSource) {
          case OUTPUT_SOURCE_ODF:
            if (eegDataSource == DATASOURCE_GANGLION) {
              fileoutput_odf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd], ganglion.get_scale_fac_uVolts_per_count(), ganglion.get_scale_fac_accel_G_per_count());
            } else {
              fileoutput_odf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd], cyton.get_scale_fac_uVolts_per_count(), cyton.get_scale_fac_accel_G_per_count());
            }
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

  private void processDisconnect(String msg) {
    if (!waitingForResponse) {
      haltSystem();
      initSystemButton.setString("START SYSTEM");
      controlPanel.open();
      output("Dang! Lost connection to Ganglion. Please move closer or get a new battery!");
    } else {
      waitingForResponse = false;
    }
  }

  private void processStatus(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);
    if (waitingForResponse) {
      waitingForResponse = false;
      println("Node process up!");
    }
    if (code == RESP_ERROR_BAD_NOBLE_START) {
      println("Hub: processStatus: Problem in the Hub");
      output("Problem starting Ganglion Hub. Please make sure compatible USB is configured, then restart this GUI.");
    } else {
      println("Hub: processStatus: Started Successfully");
    }
  }

  private void processScan(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);
    switch(code) {
      case RESP_GANGLION_FOUND:
      case RESP_WIFI_FOUND:
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

  public boolean isSuccessCode(int c) {
    return c == RESP_SUCCESS;
  }

  public void updateSyncState(int sdSetting) {
    //has it been 3000 milliseconds since we initiated the serial port? We want to make sure we wait for the OpenBCI board to finish its setup()
    if ( (millis() - prevState_millis > COM_INIT_MSEC) && (prevState_millis != 0) && (state == STATE_COMINIT) ) {
      state = STATE_SYNCWITHHARDWARE;
      timeOfLastCommand = millis();
      // potentialFailureMessage = "";
      // defaultChannelSettings = ""; //clear channel setting string to be reset upon a new Init System
      // daisyOrNot = ""; //clear daisyOrNot string to be reset upon a new Init System
      println("InterfaceHub: systemUpdate: [0] Sending 'v' to OpenBCI to reset hardware in case of 32bit board...");
      hub.write('v');
    }

    //if we are in SYNC WITH HARDWARE state ... trigger a command
    if ( (state == STATE_SYNCWITHHARDWARE) && (currentlySyncing == false) ) {
      if (millis() - timeOfLastCommand > 200) {
        timeOfLastCommand = millis();
        // hardwareSyncStep++;
        cyton.syncWithHardware(sdSetting);
      }
    }
  }

  // CONNECTION
  public void connectBLE(String id) {
    hub.write(TCP_CMD_CONNECT + "," + id + TCP_STOP);
  }
  public void disconnectBLE() {
    waitingForResponse = true;
    hub.write(TCP_CMD_DISCONNECT + TCP_STOP);
  }

  public void connectWifi(String id) {

    hub.write(TCP_CMD_CONNECT + "," + id + TCP_STOP);
  }
  public int disconnectWifi() {
    waitingForResponse = true;
    hub.write(TCP_CMD_DISCONNECT + TCP_STOP);
    return 0;
  }

  public void setProtocol(String _protocol) {
    curProtocol = _protocol;
    hub.write(TCP_CMD_PROTOCOL + ",start," + curProtocol + TCP_STOP);
  }

  /**
   * @description Write to TCP server
   * @params out {String} - The string message to write to the server.
   * @returns {boolean} - True if able to write, false otherwise.
   */
  public boolean write(String out) {
    try {
      println("out" + out);
      tcpClient.write(out);
      return true;
    } catch (Exception e) {
      println("Error: Attempted to TCP write with no server connection initialized");
      return false;
    }
  }
  public boolean write(char val) {
    return write(String.valueOf(val));
  }

  public int changeState(int newState) {
    state = newState;
    prevState_millis = millis();
    return 0;
  }

  public void searchDeviceStart() {
    deviceList = null;
    numberOfDevices = 0;
    write(TCP_CMD_SCAN + ',' + TCP_ACTION_START + TCP_STOP);
  }

  public void searchDeviceStop() {
    write(TCP_CMD_SCAN + ',' + TCP_ACTION_STOP + TCP_STOP);
  }

  public boolean searchDeviceAdd(String localName) {
    if (numberOfDevices == 0) {
      numberOfDevices++;
      deviceList = new String[numberOfDevices];
      deviceList[0] = localName;
      return true;
    } else {
      boolean willAddToDeviceList = true;
      for (int i = 0; i < numberOfDevices; i++) {
        if (localName.equals(deviceList[i])) {
          willAddToDeviceList = false;
          break;
        }
      }
      if (willAddToDeviceList) {
        numberOfDevices++;
        String[] tempList = new String[numberOfDevices];
        arrayCopy(deviceList, tempList);
        tempList[numberOfDevices - 1] = localName;
        deviceList = tempList;
        return true;
      }
    }
    return false;
  }

};
