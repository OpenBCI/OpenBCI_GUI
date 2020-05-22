///////////////////////////////////////////////////////////////////////////////
//
// This class configures and manages the connection to the Serial port for
// the Arduino.
//
// Created: Chip Audette, Oct 2013
// Modified: through April 2014
// Modified again: Conor Russomanno Sept-Oct 2014
// Modified for Daisy (16-chan) OpenBCI V3: Conor Russomanno Nov 2014
// Modified Daisy Behaviors: Chip Audette Dec 2014
// Modified For Wifi Addition: AJ Keller July 2017
//
// Note: this class now expects the data format produced by OpenBCI V3.
//
// Update July 2019:
//      - Portions of this are DEPRECATED
//      - serialEvent() is still used when checking Cyton status from Control Panel
//
/////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

int _myCounter;
int newPacketCounter = 0;
boolean no_start_connection = false;
byte inByte = -1;    // Incoming serial data
boolean isOpenBCI;
boolean isGettingPoll = false;
boolean spaceFound = false;
int hexToInt = 0;
boolean currentlySyncing = false;
long timeSinceStopRunning = 1000;

//these variables are used for "Kill Spikes" ... duplicating the last received data packet if packets were droppeds
boolean werePacketsDroppedSerial = false;
int numPacketsDroppedSerial = 0;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

void serialEvent(Serial port){
    //check to see which serial port it is
    if (iSerial.isOpenBCISerial(port)) {

        boolean echoBytes;

        if (iSerial.isStateNormal() != true) {  // || printingRegisters == true){
            echoBytes = true;
        } else {
            echoBytes = false;
        }
        iSerial.read(echoBytes);
        if (iSerial.get_isNewDataPacketAvailable()) {
            println("woo got a new packet");
            //copy packet into buffer of data packets

            iSerial.set_isNewDataPacketAvailable(false); //resets isNewDataPacketAvailable to false

            newPacketCounter++;
        }
    } else {

        //Used for serial communications, primarily everything in no_start_connection
        if (no_start_connection) {


            if (board_message == null || _myCounter>2) {
                board_message = new StringBuilder();
                _myCounter = 0;
            }

            inByte = byte(port.read());
            print(inByte);
            if (char(inByte) == 'S' || char(inByte) == 'F') isOpenBCI = true;

            // print(char(inByte));
            if (inByte != -1) {
                if (isGettingPoll) {
                    if (inByte != '$') {
                        if (!spaceFound) board_message.append(char(inByte));
                        else hexToInt = Integer.parseInt(String.format("%02X", inByte), 16);

                        if (char(inByte) == ' ') spaceFound = true;
                    } else _myCounter++;
                } else {
                    if (inByte != '$') board_message.append(char(inByte));
                    else _myCounter++;
                }
            }
        } else {
            //println("Recieved serial data not from OpenBCI"); //this is a bit of a lie
            inByte = byte(port.read());
            if (isOpenBCI) {

                if (board_message == null || _myCounter >2) {
                    board_message = new StringBuilder();
                    _myCounter=0;
                }
                if(inByte != '$'){
                    board_message.append(char(inByte));
                } else { _myCounter++; }
            } else if(char(inByte) == 'S' || char(inByte) == 'F'){
                isOpenBCI = true;
                if(board_message == null){
                    board_message = new StringBuilder();
                    board_message.append(char(inByte));
                }
            }
        }
    }
}

//------------------------------------------------------------------------
//                       Classes
//------------------------------------------------------------------------

class InterfaceSerial {

    //here is the serial port for this OpenBCI board
    private Serial serial_openBCI = null;
    private boolean portIsOpen = false;

    //final static int DATAMODE_TXT = 0;
    final static int DATAMODE_BIN = 2;
    final static int DATAMODE_BIN_WAUX = 1;  //switched to this value so that receiving Accel data is now the default
    //final static int DATAMODE_BIN_4CHAN = 4;

    final static int STATE_NOCOM = 0;
    final static int STATE_COMINIT = 1;
    final static int STATE_SYNCWITHHARDWARE = 2;
    final static int STATE_NORMAL = 3;
    final static int STATE_STOPPED = 4;
    final static int COM_INIT_MSEC = 3000; //you may need to vary this for your computer or your Arduino

    //int[] measured_packet_length = {0,0,0,0,0};
    //int measured_packet_length_ind = 0;
    //int known_packet_length_bytes = 0;

    final static byte BYTE_START = (byte)0xA0;
    final static byte BYTE_END = (byte)0xC0;

    int prefered_datamode = DATAMODE_BIN_WAUX;

    private int state = STATE_NOCOM;
    int dataMode = -1;
    int prevState_millis = 0;

    private int nEEGValuesPerPacket = 8; //defined by the data format sent by cyton boards
    private int nAuxValuesPerPacket = 3; //defined by the data format sent by cyton boards

    public int [] validAuxValues = {0, 0, 0};
    public boolean[] freshAuxValuesAvailable = {false, false, false};
    public boolean freshAuxValues = false;
    //DataPacket_ADS1299 prevDataPacket;

    private int nAuxValues;
    private boolean isNewDataPacketAvailable = false;
    private OutputStream output; //for debugging  WEA 2014-01-26
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
    private boolean readyToSend = false; //system waits for $$$ after requesting information from OpenBCI board
    private long timeOfLastCommand = 0; //used when sync'ing to hardware

    //wait for $$$ to iterate... applies to commands expecting a response
    public boolean isReadyToSend() {
        return readyToSend;
    }
    public void setReadyToSend(boolean _readyToSend) {
        readyToSend = _readyToSend;
    }
    public int get_state() {
        return state;
    };
    public boolean get_isNewDataPacketAvailable() {
        return isNewDataPacketAvailable;
    }
    public void set_isNewDataPacketAvailable(boolean _isNewDataPacketAvailable) {
        isNewDataPacketAvailable = _isNewDataPacketAvailable;
    }

    //constructors
    InterfaceSerial() {
    };  //only use this if you simply want access to some of the constants
    InterfaceSerial(PApplet applet, String comPort, int baud, int nEEGValuesPerOpenBCI, boolean useAux, int nAuxValuesPerOpenBCI) {
        //choose data mode
        println("InterfaceSerial: prefered_datamode = " + prefered_datamode + ", nValuesPerPacket = " + nEEGValuesPerPacket);
        if (prefered_datamode == DATAMODE_BIN_WAUX) {
            if (!useAux) {
                //must be requesting the aux data, so change the referred data mode
                prefered_datamode = DATAMODE_BIN;
                nAuxValues = 0;
                //println("InterfaceSerial: nAuxValuesPerPacket = " + nAuxValuesPerPacket + " so setting prefered_datamode to " + prefered_datamode);
            }
        }

        dataMode = prefered_datamode;
    }

    // //manage the serial port
    public int openSerialPort(PApplet applet, String comPort, int baud) {

        output("Attempting to open Serial/COM port: " + openBCI_portName);
        try {
            println("InterfaceSerial: openSerialPort: attempting to open serial port: " + openBCI_portName);
            serial_openBCI = new Serial(applet, comPort, baud); //open the com port
            serial_openBCI.clear(); // clear anything in the com port's buffer
            portIsOpen = true;
            println("InterfaceSerial: openSerialPort: port is open (t)? ... " + portIsOpen);
            changeState(STATE_COMINIT);
            return 0;
        }
        catch (RuntimeException e) {
            if (e.getMessage().contains("<init>")) {
                serial_openBCI = null;
                System.out.println("InterfaceSerial: openSerialPort: port in use, trying again later...");
                portIsOpen = false;
            } else {
                println("RunttimeException: " + e);
                output("Error connecting to selected Serial/COM port. Make sure your board is powered up and your dongle is plugged in.");
                //abandonInit = true; //global variable in OpenBCI_GUI.pde
            }
            return 0;
        }
    }

    public int changeState(int newState) {
        state = newState;
        prevState_millis = millis();
        return 0;
    }

    int finalizeCOMINIT() {
        changeState(STATE_NORMAL);
        return 0;
    }

    public int closeSDandSerialPort() {
        int returnVal=0;

        readyToSend = false;
        returnVal = closeSerialPort();
        prevState_millis = 0;  //reset Serial state clock to use as a conditional for timing at the beginnign of systemUpdate()

        return returnVal;
    }

    public int closeSerialPort() {
        portIsOpen = false;
        if (serial_openBCI != null) {
            serial_openBCI.stop();
        }
        serial_openBCI = null;
        state = STATE_NOCOM;
        println("InterfaceSerial: closeSerialPort: closed");
        return 0;
    }

    public void updateSyncState(int sdSetting) {
        //Has it been 3000 milliseconds since we initiated the serial port?
        //We want to make sure we wait for the OpenBCI board to finish its setup()

        if ( (millis() - prevState_millis > COM_INIT_MSEC) && (prevState_millis != 0) && (state == STATE_COMINIT) ) {
            state = STATE_SYNCWITHHARDWARE;
            timeOfLastCommand = millis();
            serial_openBCI.clear();
            println("InterfaceSerial: systemUpdate: [0] Sending 'v' to OpenBCI to reset hardware in case of 32bit board...");
            serial_openBCI.write('v');
        }

        //if we are in SYNC WITH HARDWARE state ... trigger a command
        if ( (state == STATE_SYNCWITHHARDWARE) && (currentlySyncing == false) ) {
            if (millis() - timeOfLastCommand > 200 && readyToSend == true) {
                println("sdSetting: " + sdSetting);
                timeOfLastCommand = millis();
            }
        }
    }

    public void sendChar(char val) {
        if (isSerialPortOpen()) {
            println("sending out: " + val);
            serial_openBCI.write(val);//send the value as ascii (with a newline character?)
        } else {
            println("nope no out: " + val);

        }
    }

    public void write(String msg) {
        if (isSerialPortOpen()) {
            serial_openBCI.write(msg);
        }
    }

    public boolean isSerialPortOpen() {
        if (portIsOpen & (serial_openBCI != null)) {
            return true;
        } else {
            return false;
        }
    }
    public boolean isOpenBCISerial(Serial port) {
        if (serial_openBCI == port) {
            return true;
        } else {
            return false;
        }
    }

    public void clear() {
        if (serial_openBCI != null) {
            serial_openBCI.clear();
        }
    }

    //read from the serial port
    public int read() {
        return read(false);
    }
    public int read(boolean echoChar) {
        //println("InterfaceSerial: read(): State: " + state);
        //get the byte
        byte inByte;
        if (isSerialPortOpen()) {
            inByte = byte(serial_openBCI.read());
        } else {
            println("InterfaceSerial port not open aborting.");
            return 0;
        }
        print(inByte);
        //write the most recent char to the console
        // If the GUI is in streaming mode then echoChar will be false
        if (echoChar) {  //if not in interpret binary (NORMAL) mode
            // print("hardwareSyncStep: "); println(hardwareSyncStep);
            // print(".");
            char inASCII = char(inByte);
            if (isRunning == false && (millis() - timeSinceStopRunning) > 500) {
                print(char(inByte));
            }

            //keep track of previous three chars coming from OpenBCI
            prev3chars[0] = prev3chars[1];
            prev3chars[1] = prev3chars[2];
            prev3chars[2] = inASCII;

            //if the last three chars are $$$, it means we are moving on to the next stage of initialization
            if (prev3chars[0] == EOT[0] && prev3chars[1] == EOT[1] && prev3chars[2] == EOT[2]) {
                verbosePrint(" > EOT detected...");
                // Added for V2 system down rejection line

                // hardwareSyncStep++;
                prev3chars[2] = '#';

                readyToSend = true;
                // println(hardwareSyncStep);
            }
        }

        //write raw unprocessed bytes to a binary data dump file
        if (output != null) {
            try {
                output.write(inByte);   //for debugging  WEA 2014-01-26
            }
            catch (IOException e) {
                println("InterfaceSerial: read(): Caught IOException: " + e.getMessage());
                //do nothing
            }
        }

        interpretBinaryStream(inByte);  //new 2014-02-02 WEA
        return int(inByte);
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

    void interpretBinaryStream(byte actbyte) {
        boolean flag_copyRawDataToFullData = false;

        //println("InterfaceSerial: interpretBinaryStream: PACKET_readstate " + PACKET_readstate);
        switch (PACKET_readstate) {
        case 0:
            //look for header byte
            if (actbyte == byte(0xA0)) {          // look for start indicator
                // println("InterfaceSerial: interpretBinaryStream: found 0xA0");
                PACKET_readstate++;
            }
            break;
        case 1:
            //check the packet counter
            // println("case 1");
            byte inByte = actbyte;

            localByteCounter=0;//prepare for next usage of localByteCounter
            localChannelCounter=0; //prepare for next usage of localChannelCounter
            PACKET_readstate++;
            break;
        case 2:
            // get ADS channel values
            // println("case 2");
            localAdsByteBuffer[localByteCounter] = actbyte;
            localByteCounter++;
            if (localByteCounter==3) {
                localChannelCounter++;
                if (localChannelCounter==8) { //nDataValuesInPacket) {
                    // all ADS channels arrived !
                    // println("InterfaceSerial: interpretBinaryStream: localChannelCounter = " + localChannelCounter);
                    PACKET_readstate++;
                    if (prefered_datamode != DATAMODE_BIN_WAUX) PACKET_readstate++;  //if not using AUX, skip over the next readstate
                    localByteCounter = 0;
                    localChannelCounter = 0;
                    //isNewDataPacketAvailable = true;  //tell the rest of the code that the data packet is complete
                } else {
                    //prepare for next data channel
                    localByteCounter=0; //prepare for next usage of localByteCounter
                }
            }
            break;
        case 3:
            // get LIS3DH channel values 2 bytes times 3 axes
            // println("case 3");
            localAccelByteBuffer[localByteCounter] = actbyte;
            localByteCounter++;

            break;
        case 4:
            //look for end byte
            // println("case 4");
            if (actbyte == byte(0xC0) || actbyte == byte(0xC1)) {    // if correct end delimiter found:
                // println("... 0xCx found");
                // println("InterfaceSerial: interpretBinaryStream: found end byte. Setting isNewDataPacketAvailable to TRUE");
                isNewDataPacketAvailable = true; //original place for this.  but why not put it in the previous case block
                flag_copyRawDataToFullData = true;  //time to copy the raw data packet into the full data packet (mainly relevant for 16-chan OpenBCI)
            } else {
                serialErrorCounter++;
                println("InterfaceSerial: interpretBinaryStream: Actbyte = " + actbyte);
                println("InterfaceSerial: interpretBinaryStream: expecteding end-of-packet byte is missing.  Discarding packet. (" + serialErrorCounter + ")");
            }
            PACKET_readstate=0;  // either way, look for next packet
            break;
        default:
            println("InterfaceSerial: interpretBinaryStream: Unknown byte: " + actbyte + " .  Continuing...");
            PACKET_readstate=0;  // look for next packet
        }


    } // end of interpretBinaryStream



    //return the state
    public boolean isStateNormal() {
        if (state == STATE_NORMAL) {
            return true;
        } else {
            return false;
        }
    }


};
