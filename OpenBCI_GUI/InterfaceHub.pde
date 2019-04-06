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
    int p;
    char newChar;

    newChar = hub.tcpClient.readChar();
    while(newChar != (char)-1) {
        p = hub.tcpBufferPositon;
        hub.tcpBuffer[p] = newChar;
        hub.tcpBufferPositon++;

        if(p > 2) {
            String posMatch  = new String(hub.tcpBuffer, p - 1, 2);
            if (posMatch.equals(TCP_STOP)) {
                // println("MATCH");
                if (!hub.isHubRunning()) {
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
                        if (ganglion.isBLE()) {
                            controlPanel.bleBox.refreshBLEList();
                        } else {
                            controlPanel.wifiBox.refreshWifiList();
                        }
                    }
                } else if (eegDataSource == DATASOURCE_CYTON) {
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
        newChar = hub.tcpClient.readChar();
    }
}

final static String BLE_HARDWARE_NOBLE = "noble";
final static String BLE_HARDWARE_BLED112 = "bled112";

final static String TCP_JSON_KEY_ACTION = "action";
final static String TCP_JSON_KEY_ACCEL_DATA_COUNTS = "accelDataCounts";
final static String TCP_JSON_KEY_AUX_DATA = "auxData";
final static String TCP_JSON_KEY_BOARD_TYPE = "boardType";
final static String TCP_JSON_KEY_CHANNEL_DATA_COUNTS = "channelDataCounts";
final static String TCP_JSON_KEY_CHANNEL_NUMBER = "channelNumber";
final static String TCP_JSON_KEY_CHANNEL_SET_CHANNEL_NUMBER = "channelNumber";
final static String TCP_JSON_KEY_CHANNEL_SET_POWER_DOWN = "powerDown";
final static String TCP_JSON_KEY_CHANNEL_SET_GAIN = "gain";
final static String TCP_JSON_KEY_CHANNEL_SET_INPUT_TYPE = "inputType";
final static String TCP_JSON_KEY_CHANNEL_SET_BIAS = "bias";
final static String TCP_JSON_KEY_CHANNEL_SET_SRB2 = "srb2";
final static String TCP_JSON_KEY_CHANNEL_SET_SRB1 = "srb1";
final static String TCP_JSON_KEY_CODE = "code";
final static String TCP_JSON_KEY_COMMAND = "command";
final static String TCP_JSON_KEY_DATA = "data";
final static String TCP_JSON_KEY_FIRMWARE = "firmware";
final static String TCP_JSON_KEY_IMPEDANCE_VALUE = "impedanceValue";
final static String TCP_JSON_KEY_IMPEDANCE_SET_P_INPUT = "pInputApplied";
final static String TCP_JSON_KEY_IMPEDANCE_SET_N_INPUT = "nInputApplied";
final static String TCP_JSON_KEY_LATENCY = "latency";
final static String TCP_JSON_KEY_LOWER = "lower";
final static String TCP_JSON_KEY_MESSAGE = "message";
final static String TCP_JSON_KEY_NAME = "name";
final static String TCP_JSON_KEY_PROTOCOL = "protocol";
final static String TCP_JSON_KEY_SAMPLE_NUMBER = "sampleNumber";
final static String TCP_JSON_KEY_SAMPLE_RATE = "sampleRate";
final static String TCP_JSON_KEY_SHIELD_NAME = "shieldName";
final static String TCP_JSON_KEY_STOP_BYTE = "stopByte";
final static String TCP_JSON_KEY_TIMESTAMP = "timestamp";
final static String TCP_JSON_KEY_TYPE = "type";

final static String TCP_TYPE_ACCEL = "accelerometer";
final static String TCP_TYPE_BOARD_TYPE = "boardType";
final static String TCP_TYPE_CHANNEL_SETTINGS = "channelSettings";
final static String TCP_TYPE_COMMAND = "command";
final static String TCP_TYPE_CONNECT = "connect";
final static String TCP_TYPE_DISCONNECT = "disconnect";
final static String TCP_TYPE_DATA = "data";
final static String TCP_TYPE_ERROR = "error";
final static String TCP_TYPE_EXAMINE = "examine";
final static String TCP_TYPE_IMPEDANCE = "impedance";
final static String TCP_TYPE_LOG = "log";
final static String TCP_TYPE_PROTOCOL = "protocol";
final static String TCP_TYPE_SCAN = "scan";
final static String TCP_TYPE_SD = "sd";
final static String TCP_TYPE_STATUS = "status";
final static String TCP_TYPE_WIFI = "wifi";
final static String TCP_STOP = "\r\n";

final static String TCP_ACTION_SET = "set";
final static String TCP_ACTION_START = "start";
final static String TCP_ACTION_STATUS = "status";
final static String TCP_ACTION_STOP = "stop";


final static String TCP_WIFI_ERASE_CREDENTIALS = "eraseCredentials";
final static String TCP_WIFI_GET_FIRMWARE_VERSION = "getFirmwareVersion";
final static String TCP_WIFI_GET_IP_ADDRESS = "getIpAddress";
final static String TCP_WIFI_GET_MAC_ADDRESS = "getMacAddress";
final static String TCP_WIFI_GET_TYPE_OF_ATTACHED_BOARD = "getTypeOfAttachedBoard";

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
final static int RESP_ERROR_ALREADY_CONNECTED = 408;
final static int RESP_ERROR_BAD_PACKET = 500;
final static int RESP_ERROR_BAD_NOBLE_START = 501;
final static int RESP_ERROR_CHANNEL_SETTINGS = 423;
final static int RESP_ERROR_CHANNEL_SETTINGS_SYNC_IN_PROGRESS = 422;
final static int RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_SET_CHANNEL = 424;
final static int RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_PARSE = 425;
final static int RESP_ERROR_COMMAND_NOT_ABLE_TO_BE_SENT = 406;
final static int RESP_ERROR_COMMAND_NOT_RECOGNIZED = 434;
final static int RESP_ERROR_DEVICE_NOT_FOUND = 405;
final static int RESP_ERROR_IMPEDANCE_COULD_NOT_START = 414;
final static int RESP_ERROR_IMPEDANCE_COULD_NOT_STOP = 415;
final static int RESP_ERROR_IMPEDANCE_FAILED_TO_SET_IMPEDANCE = 430;
final static int RESP_ERROR_IMPEDANCE_FAILED_TO_PARSE = 431;
final static int RESP_ERROR_NO_OPEN_BLE_DEVICE = 400;
final static int RESP_ERROR_UNABLE_TO_CONNECT = 402;
final static int RESP_ERROR_UNABLE_TO_DISCONNECT = 401;
final static int RESP_ERROR_PROTOCOL_UNKNOWN = 418;
final static int RESP_ERROR_PROTOCOL_BLE_START = 419;
final static int RESP_ERROR_PROTOCOL_NOT_STARTED = 420;
final static int RESP_ERROR_UNABLE_TO_SET_BOARD_TYPE = 421;
final static int RESP_ERROR_SCAN_ALREADY_SCANNING = 409;
final static int RESP_ERROR_SCAN_NONE_FOUND = 407;
final static int RESP_ERROR_SCAN_NO_SCAN_TO_STOP = 410;
final static int RESP_ERROR_SCAN_COULD_NOT_START = 412;
final static int RESP_ERROR_SCAN_COULD_NOT_STOP = 411;
final static int RESP_ERROR_TIMEOUT_SCAN_STOPPED = 432;
final static int RESP_ERROR_WIFI_ACTION_NOT_RECOGNIZED = 427;
final static int RESP_ERROR_WIFI_COULD_NOT_ERASE_CREDENTIALS = 428;
final static int RESP_ERROR_WIFI_COULD_NOT_SET_LATENCY = 429;
final static int RESP_ERROR_WIFI_NEEDS_UPDATE = 435;
final static int RESP_ERROR_WIFI_NOT_CONNECTED = 426;
final static int RESP_GANGLION_FOUND = 201;
final static int RESP_SUCCESS = 200;
final static int RESP_SUCCESS_DATA_ACCEL = 202;
final static int RESP_SUCCESS_DATA_IMPEDANCE = 203;
final static int RESP_SUCCESS_DATA_SAMPLE = 204;
final static int RESP_WIFI_FOUND = 205;
final static int RESP_SUCCESS_CHANNEL_SETTING = 207;
final static int RESP_STATUS_CONNECTED = 300;
final static int RESP_STATUS_DISCONNECTED = 301;
final static int RESP_STATUS_SCANNING = 302;
final static int RESP_STATUS_NOT_SCANNING = 303;

final static int LATENCY_5_MS = 5000;
final static int LATENCY_10_MS = 10000;
final static int LATENCY_20_MS = 20000;

final static String TCP = "tcp";
final static String UDP = "udp";
final static String UDP_BURST = "udpBurst";

final static String WIFI_DYNAMIC = "dynamic";
final static String WIFI_STATIC = "static";

class Hub {

    public int curLatency = LATENCY_10_MS;

    public String[] deviceList = new String[0];
    public boolean deviceListUpdated = false;

    private int bleErrorCounter = 0;
    private int prevSampleIndex = 0;

    private int requestedSampleRate = 0;
    private boolean setSampleRate = false;

    private int state = STATE_NOCOM;
    int prevState_millis = 0; // Used for calculating connect time out

    private int nEEGValuesPerPacket = 8;
    private int nAuxValuesPerPacket = 3;

    private int tcpHubPort = 10996;
    private String tcpHubIP = "127.0.0.1";
    private String tcpHubFull = tcpHubIP + ":" + tcpHubPort;
    private int tcpTimeout = 1000;

    private String firmwareVersion = "";

    private DataPacket_ADS1299 dataPacket;

    public Client tcpClient;
    private boolean portIsOpen = false;

    public int numberOfDevices = 0;
    public int maxNumberOfDevices = 10;
    private boolean hubRunning = false;
    public char[] tcpBuffer = new char[4096];
    public int tcpBufferPositon = 0;
    private String curProtocol = PROTOCOL_WIFI;
    private String curInternetProtocol = TCP;
    private String curWiFiStyle = WIFI_DYNAMIC;

    private boolean waitingForResponse = false;
    private boolean searching = false;
    public boolean shouldStartNodeApp = false;
    private boolean checkingImpedance = false;
    private boolean connectForWifiConfig = false;
    private boolean accelModeActive = false;
    private boolean newAccelData = false;
    public int[] accelArray = new int[NUM_ACCEL_DIMS];
    public int[] validAccelValues = {0, 0, 0};
    public int validLastMarker;
    public boolean validNewAccelData = false;

    public int[] impedanceArray = new int[NCHAN_GANGLION + 1];

    private String curBLEHardware = BLE_HARDWARE_NOBLE;

    // Getters
    public int get_state() { return state; }
    public int getLatency() { return curLatency; }
    public String getCurBLEHardware() { return curBLEHardware; }
    public String getWifiInternetProtocol() { return curInternetProtocol; }
    public String getWiFiStyle() { return curWiFiStyle; }
    public boolean isPortOpen() { return portIsOpen; }
    public boolean isHubRunning() { return hubRunning; }
    public boolean isSearching() { return searching; }
    public boolean isCheckingImpedance() { return checkingImpedance; }
    public boolean isAccelModeActive() { return accelModeActive; }
    public void setLatency(int latency) {
        curLatency = latency;
        println("Setting Latency to " + latency);
    }
    public void setCurBLEHardware(String bleHardware) {
        curBLEHardware = bleHardware;
        println("Setting BLE Hardware to " + bleHardware);
    }
    public void setWifiInternetProtocol(String internetProtocol) {
        curInternetProtocol = internetProtocol;
        println("Setting WiFi Internet Protocol to " + internetProtocol);
    }
    public void setWiFiStyle(String wifiStyle) {
        curWiFiStyle = wifiStyle;
        println("Setting WiFi style to " + wifiStyle);
    }

    private PApplet mainApplet;

    //constructors
    Hub() {};  //only use this if you simply want access to some of the constants
    Hub(PApplet applet) {
        mainApplet = applet;

        // Able to start tcpClient connection?
        if(!startTCPClient()) {
            outputWarn("Failed to connect to OpenBCIHub background application. LIVE functionality will be disabled.");
        }
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

    /**
      * @description Used to `try` and start the tcpClient
      * @param applet {PApplet} - The main applet.
      * @return {boolean} - True if able to start.
      */
    public boolean startTCPClient() {
        tcpClient = new Client(mainApplet, tcpHubIP, tcpHubPort);
        return tcpClient.active();
    }


    /**
      * Sends a status message to the node process.
      */
    public boolean getStatus() {
        try {
            JSONObject json = new JSONObject();
            json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_STATUS);
            writeJSON(json);
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
    public void parseMessage(String data) {
        JSONObject json = parseJSONObject(data);
        if (json == null) {
            println("JSONObject could not be parsed" + data);
        } else {
            String type = json.getString(TCP_JSON_KEY_TYPE);
            if (type.equals(TCP_TYPE_ACCEL)) {
                processAccel(json);
            } else if (type.equals(TCP_TYPE_BOARD_TYPE)) {
                processBoardType(json);
            } else if (type.equals(TCP_TYPE_CHANNEL_SETTINGS)) {
                processRegisterQuery(json);
            } else if (type.equals(TCP_TYPE_COMMAND)) {
                processCommand(json);
            } else if (type.equals(TCP_TYPE_CONNECT)) {
                processConnect(json);
            } else if (type.equals(TCP_TYPE_DATA)) {
                processData(json);
            } else if (type.equals(TCP_TYPE_DISCONNECT)) {
                processDisconnect(json);
            } else if (type.equals(TCP_TYPE_ERROR)) {
                int code = json.getInt(TCP_JSON_KEY_CODE);
                String errorMessage = json.getString(TCP_JSON_KEY_MESSAGE);
                println("Hub: parseMessage: error: " + errorMessage);
                if (code == RESP_ERROR_COMMAND_NOT_RECOGNIZED) {
                    output("Hub in data folder outdated. Download a new hub for your OS at https://github.com/OpenBCI/OpenBCI_Hub/releases/latest");
                }
            } else if (type.equals(TCP_TYPE_EXAMINE)) {
                processExamine(json);
            } else if (type.equals(TCP_TYPE_IMPEDANCE)) {
                processImpedance(json);
            } else if (type.equals(TCP_TYPE_LOG)) {
                String logMessage = json.getString(TCP_JSON_KEY_MESSAGE);
                println("Hub: Log: " + logMessage);
            } else if (type.equals(TCP_TYPE_PROTOCOL)) {
                processProtocol(json);
            } else if (type.equals(TCP_TYPE_SCAN)) {
                processScan(json);
            } else if (type.equals(TCP_TYPE_SD)) {
                processSDCard(json);
            } else if (type.equals(TCP_TYPE_STATUS)) {
                processStatus(json);
            } else if (type.equals(TCP_TYPE_WIFI)) {
                processWifi(json);
            } else {
                println("Hub: parseMessage: default: " + data);
                output("Hub in data folder outdated. Download a new hub for your OS at https://github.com/OpenBCI/OpenBCI_Hub/releases/latest");
            }
        }
    }

    private void writeJSON(JSONObject json) {
        write(json.toString() + TCP_STOP);
    }

    private void handleError(int code, String msg) {
        output("Code " + code + " Error: " + msg);
    }

    public void setBoardType(String boardType) {
        println("Hub: setBoardType(): sending \'" + boardType + " -- " + millis());
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_BOARD_TYPE);
        json.setString(TCP_JSON_KEY_BOARD_TYPE, boardType);
        writeJSON(json);
    }

    private void processBoardType(JSONObject json) {
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_SUCCESS:
                if (sdSetting > 0) {
                    println("Hub: processBoardType: success, starting SD card now -- " + millis());
                    sdCardStart(sdSetting);
                } else {
                    println("Hub: processBoardType: success -- " + millis());
                    initAndShowGUI();
                }
                break;
            case RESP_ERROR_UNABLE_TO_SET_BOARD_TYPE:
            default:
                String msg = json.getString(TCP_JSON_KEY_MESSAGE);
                killAndShowMsg(msg);
                break;
        }
    }

    private void processConnect(JSONObject json) {
        int code = json.getInt(TCP_JSON_KEY_CODE);
        println("Hub: processConnect: made it -- " + millis() + " code: " + code);
        switch (code) {
            case RESP_SUCCESS:
            case RESP_ERROR_ALREADY_CONNECTED:
                firmwareVersion = json.getString(TCP_JSON_KEY_FIRMWARE);
                changeState(STATE_SYNCWITHHARDWARE);
                if (eegDataSource == DATASOURCE_CYTON) {
                    if (nchan == 8) {
                        setBoardType("cyton");
                    } else {
                        setBoardType("daisy");
                    }
                } else {
                    println("Hub: parseMessage: connect: success! -- " + millis());
                    initAndShowGUI();
                }
                break;
            case RESP_ERROR_UNABLE_TO_CONNECT:
                println("Error in processConnect: RESP_ERROR_UNABLE_TO_CONNECT");
                String message = json.getString(TCP_JSON_KEY_MESSAGE);
                if (message.equals("Error: Invalid sample rate")) {
                    if (eegDataSource == DATASOURCE_CYTON) {
                        killAndShowMsg("WiFi Shield is connected to a Ganglion. Please select LIVE (from Ganglion) instead of LIVE (from Cyton)");
                    } else {
                        killAndShowMsg("WiFi Shield is connected to a Cyton. Please select LIVE (from Cyton) instead LIVE (from Cyton)");
                    }
                } else {
                    killAndShowMsg(message);
                }
                break;
            case RESP_ERROR_WIFI_NEEDS_UPDATE:
                println("Error in processConnect: RESP_ERROR_WIFI_NEEDS_UPDATE");
                killAndShowMsg("WiFi Shield Firmware is out of date. Learn to update: docs.openbci.com/Hardware/12-Wifi_Programming_Tutorial");
                break;
            default:
                println("Error in processConnect");
                message = json.getString(TCP_JSON_KEY_MESSAGE, "none");
                handleError(code, message);
                break;
        }
    }

    private void processExamine(JSONObject json) {
        // println(msg);
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_SUCCESS:
                portIsOpen = true;
                output("Connected to WiFi Shield named " + wifi_portName);
                if (wcBox.isShowing) {
                    wcBox.updateMessage("Connected to WiFi Shield named " + wifi_portName);
                }
                break;
            case RESP_ERROR_ALREADY_CONNECTED:
                portIsOpen = true;
                output("WiFi Shield is still connected to " + wifi_portName);
                break;
            case RESP_ERROR_UNABLE_TO_CONNECT:
                output("No WiFi Shield found, visit docs.openbci.com/Tutorials/03-Wifi_Getting_Started_Guide to learn how to connect.");
                break;
            default:
                if (wcBox.isShowing) println("it is showing"); //controlPanel.hideWifiPopoutBox();
                String message = json.getString(TCP_JSON_KEY_MESSAGE, "none");
                handleError(code, message);
                break;
        }
    }

    private void initAndShowGUI() {
        changeState(STATE_NORMAL);
        systemMode = SYSTEMMODE_POSTINIT;
        controlPanel.close();
        topNav.controlPanelCollapser.setIsActive(false);
        String firmwareString = " Cyton firmware ";
        String settingsString = "Settings Loaded! ";
        if (eegDataSource == DATASOURCE_CYTON) {
            firmwareString += firmwareVersion;
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            firmwareString = ganglion_portName;
        } else {
            firmwareString = "";
        }
        //This success message appears in Ganglion mode
        if (loadErrorCytonEvent == true) {
            outputError("Connection Error: Failed to apply channel settings to Cyton.");
        } else {
            outputSuccess("The GUI is done initializing. " + settingsString + "Press \"Start Data Stream\" to start streaming! -- " + firmwareString);
        }
        portIsOpen = true;
        controlPanel.hideAllBoxes();
    }

    private void killAndShowMsg(String msg) {
        println("InterfaceHub: Stopping system...");
        abandonInit = true;
        initSystemButton.setString("START SYSTEM");
        controlPanel.open();
        outputError(msg);
        portIsOpen = false;
        haltSystem();
    }

    /**
      * @description Sends a command to ganglion board
      */
    public void sendCommand(char c) {
        println("Hub: sendCommand(char): sending \'" + c + "\'");
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_COMMAND);
        json.setString(TCP_JSON_KEY_COMMAND, Character.toString(c));
        writeJSON(json);
    }

    /**
      * @description Sends a command to ganglion board
      */
    public void sendCommand(String s) {
        println("Hub: sendCommand(String): sending \'" + s + "\'");
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_COMMAND);
        json.setString(TCP_JSON_KEY_COMMAND, s);
        writeJSON(json);
    }

    public void processCommand(JSONObject json) {
        String message = "";
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_SUCCESS:
                println("Hub: processCommand: success -- " + millis());
                break;
            case RESP_ERROR_COMMAND_NOT_ABLE_TO_BE_SENT:
                message = json.getString(TCP_JSON_KEY_MESSAGE, "");
                println("Hub: processCommand: ERROR_COMMAND_NOT_ABLE_TO_BE_SENT -- " + millis() + " " + message);
                break;
            case RESP_ERROR_PROTOCOL_NOT_STARTED:
                message = json.getString(TCP_JSON_KEY_MESSAGE, "");
                println("Hub: processCommand: RESP_ERROR_PROTOCOL_NOT_STARTED -- " + millis() + " " + message);
                break;
            default:
                break;
        }
    }

    public void processAccel(JSONObject json) {
        int code = json.getInt(TCP_JSON_KEY_CODE);
        if (code == RESP_SUCCESS_DATA_ACCEL) {
            JSONArray accelDataCounts = json.getJSONArray(TCP_JSON_KEY_ACCEL_DATA_COUNTS);
            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                    accelArray[i] = accelDataCounts.getInt(i);
            }
            newAccelData = true;
            if (accelArray[0] > 0 || accelArray[1] > 0 || accelArray[2] > 0) {
                for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                    validAccelValues[i] = accelArray[i];
                }
            }
        }
    }

    public void processData(JSONObject json) {
        try {
            int code = json.getInt(TCP_JSON_KEY_CODE);
            int stopByte = 0xC0;
            if ((eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON) && systemMode == 10 && isRunning) { //<>//
                if (code == RESP_SUCCESS_DATA_SAMPLE) {
                    // Sample number stuff
                    dataPacket.sampleIndex = json.getInt(TCP_JSON_KEY_SAMPLE_NUMBER);

                    if ((dataPacket.sampleIndex - prevSampleIndex) != 1) {
                        if(dataPacket.sampleIndex != 0){  // if we rolled over, don't count as error
                            bleErrorCounter++;

                            werePacketsDroppedHub = true; //set this true to activate packet duplication in serialEvent
                            if(dataPacket.sampleIndex < prevSampleIndex){   //handle the situation in which the index jumps from 250s past 255, and back to 0
                                numPacketsDroppedHub = (dataPacket.sampleIndex+(curProtocol == PROTOCOL_BLE ? 200 : 255)) - prevSampleIndex; //calculate how many times the last received packet should be duplicated...
                            } else {
                                numPacketsDroppedHub = dataPacket.sampleIndex - prevSampleIndex; //calculate how many times the last received packet should be duplicated...
                            }
                            println("Hub: apparent sampleIndex jump from Serial data: " + prevSampleIndex + " to  " + dataPacket.sampleIndex + ".  Keeping packet. (" + bleErrorCounter + ")");
                            println("numPacketsDropped = " + numPacketsDroppedHub);
                        }
                    }
                    prevSampleIndex = dataPacket.sampleIndex;

                    // Channel data storage
                    JSONArray eegChannelDataCounts = json.getJSONArray(TCP_JSON_KEY_CHANNEL_DATA_COUNTS);
                    for (int i = 0; i < nEEGValuesPerPacket; i++) {
                        dataPacket.values[i] = eegChannelDataCounts.getInt(i);
                    }
                    if (newAccelData) {
                        newAccelData = false;
                        for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                            dataPacket.auxValues[i] = accelArray[i];
                            dataPacket.rawAuxValues[i][0] = byte(accelArray[i]);
                        }
                    } else {
                        stopByte = json.getInt(TCP_JSON_KEY_STOP_BYTE);
                        if (stopByte == 0xC0) {
                            JSONArray accelValues = json.getJSONArray(TCP_JSON_KEY_ACCEL_DATA_COUNTS);
                            for (int i = 0; i < accelValues.size(); i++) {
                                accelArray[i] = accelValues.getInt(i);
                                dataPacket.auxValues[i] = accelArray[i];
                                dataPacket.rawAuxValues[i][0] = byte(accelArray[i]);
                                dataPacket.rawAuxValues[i][1] = byte(accelArray[i] >> 8);
                            }
                            if (accelArray[0] > 0 || accelArray[1] > 0 || accelArray[2] > 0) {
                                // println(msg);
                                for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                                    validAccelValues[i] = accelArray[i];
                                }
                            }
                        } else {
                            JSONObject auxData = json.getJSONObject(TCP_JSON_KEY_AUX_DATA);
                            JSONArray auxDataValues;
                            if (nchan == NCHAN_CYTON_DAISY) {
                                JSONObject lowerAuxData = auxData.getJSONObject(TCP_JSON_KEY_LOWER);
                                auxDataValues = lowerAuxData.getJSONArray(TCP_JSON_KEY_DATA);
                            } else {
                                auxDataValues = auxData.getJSONArray(TCP_JSON_KEY_DATA);
                            }
                            int j = 0;
                            for (int i = 0; i < auxDataValues.size(); i+=2) {
                                int val1 = auxDataValues.getInt(i);
                                int val2 = auxDataValues.getInt(i+1);

                                dataPacket.auxValues[j] = (val1 << 8) | val2;
                                validAccelValues[j] = (val1 << 8) | val2;

                                dataPacket.rawAuxValues[j][0] = byte(val2);
                                dataPacket.rawAuxValues[j][1] = byte(val1 << 8);
                                j++;
                            }
                        }
                    }
                    getRawValues(dataPacket);
                    // println(binary(dataPacket.values[0], 24) + '\n' + binary(dataPacket.rawValues[0][0], 8) + binary(dataPacket.rawValues[0][1], 8) + binary(dataPacket.rawValues[0][2], 8) + '\n'); //<>//
                    // println(dataPacket.values[7]);
                    curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length; // This is also used to let the rest of the code that it may be time to do something
                    copyDataPacketTo(dataPacketBuff[curDataPacketInd]);

                    // KILL SPIKES!!!
                    // if(werePacketsDroppedHub){
                    //   // println("Packets Dropped ... doing some stuff...");
                    //   for(int i = numPacketsDroppedHub; i > 0; i--){
                    //     int tempDataPacketInd = curDataPacketInd - i; //
                    //     if(tempDataPacketInd >= 0 && tempDataPacketInd < dataPacketBuff.length){
                    //       // println("i = " + i);
                    //       copyDataPacketTo(dataPacketBuff[tempDataPacketInd]);
                    //     } else {
                    //       if (eegDataSource == DATASOURCE_GANGLION) {
                    //         copyDataPacketTo(dataPacketBuff[tempDataPacketInd+200]);
                    //       } else {
                    //         copyDataPacketTo(dataPacketBuff[tempDataPacketInd+255]);
                    //       }
                    //     }
                    //     //put the last stored packet in # of packets dropped after that packet
                    //   }
                    //
                    //   //reset werePacketsDropped & numPacketsDropped
                    //   werePacketsDroppedHub = false;
                    //   numPacketsDroppedHub = 0;
                    // }

                    switch (outputDataSource) {
                        case OUTPUT_SOURCE_ODF:
                            if (eegDataSource == DATASOURCE_GANGLION) {
                                fileoutput_odf.writeRawData_dataPacket(
                                    dataPacketBuff[curDataPacketInd],
                                    ganglion.get_scale_fac_uVolts_per_count(),
                                    ganglion.get_scale_fac_accel_G_per_count(),
                                    stopByte,
                                    json.getLong(TCP_JSON_KEY_TIMESTAMP)
                                );
                            } else {
                                fileoutput_odf.writeRawData_dataPacket(
                                    dataPacketBuff[curDataPacketInd],
                                    cyton.get_scale_fac_uVolts_per_count(),
                                    cyton.get_scale_fac_accel_G_per_count(),
                                    stopByte,
                                    json.getLong(TCP_JSON_KEY_TIMESTAMP)
                                );
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
                    println("Hub: parseMessage: data: bad");
                }
            }
        } catch (Exception e) {
            println("\n\n" + json + "\nHub: parseMessage: error: " + e);
        }
    }

    private void processDisconnect(JSONObject json) {
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_SUCCESS:
                if (!waitingForResponse) {
                    if (eegDataSource == DATASOURCE_CYTON) {
                        killAndShowMsg("Dang! Lost connection to Cyton. Please move closer or get a new battery!");
                    } else {
                        killAndShowMsg("Dang! Lost connection to Ganglion. Please move closer or get a new battery!");
                    }
                } else {
                    waitingForResponse = false;
                }
                break;
            case RESP_ERROR_UNABLE_TO_DISCONNECT:
                break;
        }
        portIsOpen = false;
    }

    private void processImpedance(JSONObject json) {
        String action = "";
        String message = "";
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_ERROR_IMPEDANCE_COULD_NOT_START:
                ganglion.overrideCheckingImpedance(false);
            case RESP_ERROR_IMPEDANCE_COULD_NOT_STOP:
            case RESP_ERROR_IMPEDANCE_FAILED_TO_SET_IMPEDANCE:
            case RESP_ERROR_IMPEDANCE_FAILED_TO_PARSE:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                handleError(code, message);
                break;
            case RESP_SUCCESS_DATA_IMPEDANCE:
                ganglion.processImpedance(json);
                break;
            case RESP_SUCCESS:
                action = json.getString(TCP_JSON_KEY_ACTION);
                output("Success: Impedance " + action + ".");
                break;
            default:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                handleError(code, message);
                break;
        }
    }

    private void processProtocol(JSONObject json) {
        String message, protocol;
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_SUCCESS:
                protocol = json.getString(TCP_JSON_KEY_PROTOCOL);
                output("Transfer Protocol set to " + protocol);
                if (eegDataSource == DATASOURCE_GANGLION && ganglion.isBLE()) {
                    // hub.searchDeviceStart();
                    outputInfo("BLE was powered up sucessfully, now searching for BLE devices.");
                }
                break;
            case RESP_ERROR_PROTOCOL_BLE_START:
                outputError("Failed to start Ganglion BLE Driver, please see http://docs.openbci.com/Tutorials/02-Ganglion_Getting%20Started_Guide");
                break;
            default:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                handleError(code, message);
                break;
        }
    }

    private void processStatus(JSONObject json) {
        int code = json.getInt(TCP_JSON_KEY_CODE);
        if (waitingForResponse) {
            waitingForResponse = false;
            println("Node process is up!");
        }
        if (code == RESP_ERROR_BAD_NOBLE_START) {
            println("Hub: processStatus: Problem in the Hub");
            output("Problem starting Ganglion Hub. Please make sure compatible USB is configured, then restart this GUI.");
        } else {
            println("Hub: processStatus: Started Successfully");
        }
    }

    private void processRegisterQuery(JSONObject json) {
        String action = "";
        String message = "";
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_ERROR_CHANNEL_SETTINGS:
                killAndShowMsg("Failed to sync with Cyton, please power cycle your dongle and board.");
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                println("RESP_ERROR_CHANNEL_SETTINGS general error: " + message);
                break;
            case RESP_ERROR_CHANNEL_SETTINGS_SYNC_IN_PROGRESS:
                println("tried to sync channel settings but there was already one in progress");
                break;
            case RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_SET_CHANNEL:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                println("an error was thrown trying to set the channels | error: " + message);
                break;
            case RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_PARSE:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                println("an error was thrown trying to call the function to set the channels | error: " + message);
                break;
            case RESP_SUCCESS:
                // Sent when either a scan was stopped or started Successfully
                action = json.getString(TCP_JSON_KEY_ACTION);
                if (action.equals(TCP_ACTION_START)) {
                    println("Query registers for cyton channel settings");
                } else if (action.equals(TCP_ACTION_SET)) {
                    checkForSuccessTS = json.getInt(TCP_JSON_KEY_CODE);
                    println("Success writing channel " + json.getInt(TCP_JSON_KEY_CHANNEL_NUMBER));

                }
                break;
            case RESP_SUCCESS_CHANNEL_SETTING:
                int channelNumber = json.getInt(TCP_JSON_KEY_CHANNEL_SET_CHANNEL_NUMBER);
                // power down comes in as either 'true' or 'false', 'true' is a '1' and false is a '0'
                channelSettingValues[channelNumber][0] = json.getBoolean(TCP_JSON_KEY_CHANNEL_SET_POWER_DOWN) ? '1' : '0';
                // gain comes in as an int, either 1, 2, 4, 6, 8, 12, 24 and must get converted to
                //  '0', '1', '2', '3', '4', '5', '6' respectively, of course.
                channelSettingValues[channelNumber][1] = cyton.getCommandForGain(json.getInt(TCP_JSON_KEY_CHANNEL_SET_GAIN));
                // input type comes in as a string version and must get converted to char
                channelSettingValues[channelNumber][2] = cyton.getCommandForInputType(json.getString(TCP_JSON_KEY_CHANNEL_SET_INPUT_TYPE));
                // bias is like power down
                channelSettingValues[channelNumber][3] = json.getBoolean(TCP_JSON_KEY_CHANNEL_SET_BIAS) ? '1' : '0';
                // srb2 is like power down
                channelSettingValues[channelNumber][4] = json.getBoolean(TCP_JSON_KEY_CHANNEL_SET_SRB2) ? '1' : '0';
                // srb1 is like power down
                channelSettingValues[channelNumber][5] = json.getBoolean(TCP_JSON_KEY_CHANNEL_SET_SRB1) ? '1' : '0';
                break;
        }
    }

    private void processScan(JSONObject json) {
        String action = "";
        String message = "";
        String name = "";
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_GANGLION_FOUND:
            case RESP_WIFI_FOUND:
                // Sent every time a new ganglion device is found
                name = json.getString(TCP_JSON_KEY_NAME, "");
                if (searchDeviceAdd(name)) {
                    deviceListUpdated = true;
                }
                break;
            case RESP_ERROR_SCAN_ALREADY_SCANNING:
                // Sent when a start send command is sent and the module is already
                //  scanning.
                // handleError(code, list[2]);
                searching = true;
                break;
            case RESP_SUCCESS:
                // Sent when either a scan was stopped or started Successfully
                action = json.getString(TCP_JSON_KEY_ACTION);
                switch (action) {
                    case TCP_ACTION_START:
                        searching = true;
                        break;
                    case TCP_ACTION_STOP:
                        searching = false;
                        break;
                }
                break;
            case RESP_ERROR_TIMEOUT_SCAN_STOPPED:
                searching = false;
                break;
            case RESP_ERROR_SCAN_COULD_NOT_START:
                // Sent when err on search start
                message = json.getString(TCP_JSON_KEY_MESSAGE, "");
                handleError(code, message);
                searching = false;
                break;
            case RESP_ERROR_SCAN_COULD_NOT_STOP:
                // Send when err on search stop
                message = json.getString(TCP_JSON_KEY_MESSAGE, "");
                handleError(code, message);
                searching = false;
                break;
            case RESP_STATUS_SCANNING:
                // Sent when after status action sent to node and module is searching
                searching = true;
                break;
            case RESP_STATUS_NOT_SCANNING:
                // Sent when after status action sent to node and module is NOT searching
                searching = false;
                break;
            case RESP_ERROR_SCAN_NO_SCAN_TO_STOP:
                // Sent when a 'stop' action is sent to node and there is no scan to stop.
                // handleError(code, list[2]);
                searching = false;
                break;
            case RESP_ERROR_UNKNOWN:
            default:
                message = json.getString(TCP_JSON_KEY_MESSAGE, "");
                handleError(code, message);
                break;
        }
    }

    public void sdCardStart(int sdSetting) {
        String sdSettingStr = cyton.getSDSettingForSetting(sdSetting);
        println("Hub: sdCardStart(): sending \'" + sdSettingStr + "\' with value " + sdSetting);
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_START);
        json.setString(TCP_JSON_KEY_COMMAND, sdSettingStr);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_SD);
        writeJSON(json);
    }

    private void processSDCard(JSONObject json) {
        String action, message;
        int code = json.getInt(TCP_JSON_KEY_CODE);
        action = json.getString(TCP_JSON_KEY_ACTION);

        switch(code) {
            case RESP_SUCCESS:
                // Sent when either a scan was stopped or started Successfully
                switch (action) {
                    case TCP_ACTION_START:
                        println("sd card setting set so now attempting to sync channel settings");
                        // cyton.syncChannelSettings();
                        initAndShowGUI();
                        break;
                    case TCP_ACTION_STOP:
                        message = json.getString(TCP_JSON_KEY_MESSAGE);
                        println("ProcessSDcard::Success:Stop: " + message);
                        break;
                }
                break;
            case RESP_ERROR_UNKNOWN:
                switch (action) {
                    case TCP_ACTION_START:
                        message = json.getString(TCP_JSON_KEY_MESSAGE);
                        killAndShowMsg(message);
                        break;
                    case TCP_ACTION_STOP:
                        message = json.getString(TCP_JSON_KEY_MESSAGE);
                        println("ProcessSDcard::Unknown:Stop: " + message);
                        break;
                }
                break;
            default:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                handleError(code, message);
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
        }
    }

    public boolean isSuccessCode(int c) {
        return c == RESP_SUCCESS;
    }

    public void updateSyncState(int sdSetting) {
        //has it been 3000 milliseconds since we initiated the serial port? We want to make sure we wait for the OpenBCI board to finish its setup()
        if ( (millis() - prevState_millis > COM_INIT_MSEC) && (prevState_millis != 0) && (state == STATE_COMINIT) ) {
            state = STATE_SYNCWITHHARDWARE;
            println("InterfaceHub: systemUpdate: [0] Sending 'v' to OpenBCI to reset hardware in case of 32bit board...");
        }
    }

    public void closePort() {
        switch (curProtocol) {
            case PROTOCOL_BLE:
                disconnectBLE();
                break;
            case PROTOCOL_WIFI:
                disconnectWifi();
                break;
            case PROTOCOL_SERIAL:
                disconnectSerial();
                break;
            default:
                break;
        }
        changeState(STATE_NOCOM);
    }

    // CONNECTION
    public void connectBLE(String id) {
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_NAME, id);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_CONNECT);
        writeJSON(json);
        verbosePrint("OpenBCI_GUI: hub : Sent connect to Hub - Id: " + id);

    }
    public void disconnectBLE() {
        waitingForResponse = true;
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_PROTOCOL, PROTOCOL_BLE);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_DISCONNECT);
        writeJSON(json);
    }

    public void connectWifi(String id) {
        JSONObject json = new JSONObject();
        json.setInt(TCP_JSON_KEY_LATENCY, curLatency);
        json.setString(TCP_JSON_KEY_PROTOCOL, curInternetProtocol);
        json.setInt(TCP_JSON_KEY_SAMPLE_RATE, requestedSampleRate);
        json.setString(TCP_JSON_KEY_NAME, id);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_CONNECT);
        writeJSON(json);
        verbosePrint("OpenBCI_GUI: hub : Sent connect to Hub - Id: " + id + " SampleRate: " + requestedSampleRate + "Hz Latency: " + curLatency + "ms");
    }

    public void examineWifi(String id) {
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_NAME, id);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_EXAMINE);
        writeJSON(json);
    }

    public int disconnectWifi() {
        waitingForResponse = true;
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_PROTOCOL, PROTOCOL_WIFI);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_DISCONNECT);
        writeJSON(json);
        return 0;
    }

    public void connectSerial(String id) {
        waitingForResponse = true;
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_PROTOCOL, PROTOCOL_SERIAL);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_CONNECT);
        json.setString(TCP_JSON_KEY_NAME, id);
        writeJSON(json);
        verbosePrint("OpenBCI_GUI: hub : Sent connect to Hub - Id: " + id);
        delay(1000);

    }
    public int disconnectSerial() {
        println("Disconnecting serial...");
        waitingForResponse = true;
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_PROTOCOL, PROTOCOL_SERIAL);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_DISCONNECT);
        writeJSON(json);
        return 0;
    }

    public void setProtocol(String _protocol) {
        curProtocol = _protocol;
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_START);
        json.setString(TCP_JSON_KEY_PROTOCOL, curProtocol);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_PROTOCOL);
        writeJSON(json);
    }

    public int getSampleRate() {
        return requestedSampleRate;
    }

    public void setSampleRate(int _sampleRate) {
        requestedSampleRate = _sampleRate;
        setSampleRate = true;
        println("\n\nsample rate set to: " + _sampleRate);
    }

    public void getWifiInfo(String info) {
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, info);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_WIFI);
        writeJSON(json);
    }

    private void processWifi(JSONObject json) {
        String action = "";
        String message = "";
        int code = json.getInt(TCP_JSON_KEY_CODE);
        switch (code) {
            case RESP_ERROR_WIFI_ACTION_NOT_RECOGNIZED:
                output("Sent an action to hub for wifi info but the command was unrecognized");
                break;
            case RESP_ERROR_WIFI_NOT_CONNECTED:
                output("Tried to get wifi info but no WiFi Shield was connected.");
                break;
            case RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_SET_CHANNEL:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                println("an error was thrown trying to set the channels | error: " + message);
                break;
            case RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_PARSE:
                message = json.getString(TCP_JSON_KEY_MESSAGE);
                println("an error was thrown trying to call the function to set the channels | error: " + message);
                break;
            case RESP_SUCCESS:
                // Sent when either a scan was stopped or started Successfully
                if (wcBox.isShowing) {
                    String msgForWcBox = json.getString(TCP_JSON_KEY_MESSAGE);
                    String command = json.getString(TCP_JSON_KEY_COMMAND);
                    switch (command) {
                        case TCP_WIFI_GET_TYPE_OF_ATTACHED_BOARD:
                            switch(message) {
                                case "none":
                                    msgForWcBox = "No OpenBCI Board attached to WiFi Shield";
                                    break;
                                case "ganglion":
                                    msgForWcBox = "4-channel Ganglion attached to WiFi Shield";
                                    break;
                                case "cyton":
                                    msgForWcBox = "8-channel Cyton attached to WiFi Shield";
                                    break;
                                case "daisy":
                                    msgForWcBox = "16-channel Cyton with Daisy attached to WiFi Shield";
                                    break;
                            }
                            break;
                        case TCP_WIFI_ERASE_CREDENTIALS:
                            output("WiFi credentials have been erased and WiFi Shield is in hotspot mode. If erase fails, remove WiFi Shield from OpenBCI Board.");
                            msgForWcBox = "";
                            controlPanel.hideWifiPopoutBox();
                            wifi_portName = "N/A";
                            clearDeviceList();
                            controlPanel.wifiBox.refreshWifiList();
                            break;
                    }
                    println("Success for wifi " + command + ": " + msgForWcBox);
                    wcBox.updateMessage(msgForWcBox);
                }
                break;
        }
    }

    /**
      * @description Write to TCP server
      * @params out {String} - The string message to write to the server.
      * @returns {boolean} - True if able to write, false otherwise.
      */
    public boolean write(String out) {
        try {
            // println("out " + out);
            tcpClient.write(out);
            return true;
        } catch (Exception e) {
            if (isWindows()) {
                killAndShowMsg("Please start OpenBCIHub before launching this application.");
            } else {
                killAndShowMsg("Hub has crashed, please restart your application.");
            }
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

    public void clearDeviceList() {
        deviceList = null;
        numberOfDevices = 0;
    }

    public void searchDeviceStart() {
        clearDeviceList();
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_START);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_SCAN);
        writeJSON(json);
    }

    public void searchDeviceStop() {
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_STOP);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_SCAN);
        writeJSON(json);
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
