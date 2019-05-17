
///////////////////////////////////////////////////////////////////////////////
//
//   GUI for controlling the ADS1299-based OpenBCI
//
//   Created: Chip Audette, Oct 2013 - May 2014
//   Modified: Conor Russomanno & Joel Murphy, August 2014 - Dec 2014
//   Modified (v2.0): Conor Russomanno & Joel Murphy (AJ Keller helped too), June 2016
//   Modified (v3.0) AJ Keller (Conor Russomanno & Joel Murphy & Wangshu), September 2017
//   Modified (v4.0) AJ Keller (Richard Waltman), September 2018
//
//   Requires gwoptics graphing library for processing.  Built on V0.5.0
//   http://www.gwoptics.org/processing/gwoptics_p5lib/
//
//   Requires ControlP5 library, but an older one.  This will only work
//   with the ControlP5 library that is included with this GitHub repository
//
//   No warranty. Use at your own risk. Use for whatever you'd like.
//
////////////////////////////////////////////////////////////////////////////////
import ddf.minim.*;  // To make sound.  Following minim example "frequencyModulation"
import ddf.minim.ugens.*; // To make sound.  Following minim example "frequencyModulation"
import java.lang.Math; //for exp, log, sqrt...they seem better than Processing's built-in
import processing.core.PApplet;
import java.util.*; //for Array.copyOfRange()
import java.util.Map.Entry;
import processing.serial.*; //for serial communication to Arduino/OpenBCI
import java.awt.event.*; //to allow for event listener on screen resize
import processing.net.*; // For TCP networking
import grafica.*;
import java.lang.reflect.*; // For callbacks
import java.io.InputStreamReader; // For input
import java.awt.MouseInfo;
import java.lang.Process;
// import java.net.InetAddress; // Used for ping, however not working right now.
import java.util.Random;
import java.awt.Robot; //used for simulating mouse clicks
import java.awt.AWTException;
import netP5.*; // for OSC
import oscP5.*; // for OSC
import hypermedia.net.*; //for UDP
import java.nio.ByteBuffer; //for UDP
import edu.ucsd.sccn.LSL; //for LSL
//These are used by LSL
import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;
import com.sun.jna.Pointer;


import gifAnimation.*;


//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------
//Used to check GUI version in TopNav.pde and displayed on the splash screen on startup
String localGUIVersionString = "v4.1.2-beta.2";
String localGUIVersionDate = "May 2019";
String guiLatestReleaseLocation = "https://github.com/OpenBCI/OpenBCI_GUI/releases/latest";
Boolean guiVersionCheckHasOccured = false;

//used to switch between application states
final int SYSTEMMODE_INTROANIMATION = -10;
final int SYSTEMMODE_PREINIT = 0;
final int SYSTEMMODE_MIDINIT = 5;
final int SYSTEMMODE_POSTINIT = 10;
int systemMode = SYSTEMMODE_INTROANIMATION; /* Modes: -10 = intro sequence; 0 = system stopped/control panel setings; 10 = gui; 20 = help guide */

boolean midInit = false;
boolean abandonInit = false;
boolean systemHasHalted = false;

final int NCHAN_CYTON = 8;
final int NCHAN_CYTON_DAISY = 16;
final int NCHAN_GANGLION = 4;

PImage cog;
Gif loadingGIF;
Gif loadingGIF_blue;

// ---- Define variables related to OpenBCI_GUI UDPMarker functionality
UDP udpRX;

//choose where to get the EEG data
final int DATASOURCE_CYTON = 0; // new default, data from serial with Accel data CHIP 2014-11-03
final int DATASOURCE_GANGLION = 1;  //looking for signal from OpenBCI board via Serial/COM port, no Aux data
final int DATASOURCE_PLAYBACKFILE = 2;  //playback from a pre-recorded text file
final int DATASOURCE_SYNTHETIC = 3;  //Synthetically generated data
public int eegDataSource = -1; //default to none of the options

final int INTERFACE_NONE = -1; // Used to indicate no choice made yet on interface
final int INTERFACE_SERIAL = 0; // Used only by cyton
final int INTERFACE_HUB_BLE = 1; // used only by ganglion
final int INTERFACE_HUB_WIFI = 2; // used by both cyton and ganglion
final int INTERFACE_HUB_BLED112 = 3; // used only by ganglion with bled dongle

boolean showStartupError = false;
String startupErrorMessage = "";
//here are variables that are used if loading input data from a CSV text file...double slash ("\\") is necessary to make a single slash
String playbackData_fname = "N/A"; //only used if loading input data from a file
// String playbackData_fname;  //leave blank to cause an "Open File" dialog box to appear at startup.  USEFUL!
int currentTableRowIndex = 0;
Table_CSV playbackData_table;
int nextPlayback_millis = -100; //any negative number

// Initialize boards for constants
Cyton cyton = new Cyton(); //dummy creation to get access to constants, create real one later
Ganglion ganglion = new Ganglion(); //dummy creation to get access to constants, create real one later
// Intialize interface protocols
InterfaceSerial iSerial = new InterfaceSerial();
Hub hub = new Hub(); //dummy creation to get access to constants, create real one later

String openBCI_portName = "N/A";  //starts as N/A but is selected from control panel to match your OpenBCI USB Dongle's serial/COM
int openBCI_baud = 115200; //baud rate from the Arduino

String ganglion_portName = "N/A";

String wifi_portName = "N/A";
String wifi_ipAddress = "192.168.4.1";

final static String PROTOCOL_BLE = "ble";
final static String PROTOCOL_BLED112 = "bled112";
final static String PROTOCOL_SERIAL = "serial";
final static String PROTOCOL_WIFI = "wifi";

////// ---- Define variables related to OpenBCI board operations
//Define number of channels from cyton...first EEG channels, then aux channels
int nchan = NCHAN_CYTON; //Normally, 8 or 16.  Choose a smaller number to show fewer on the GUI
int n_aux_ifEnabled = 3;  // this is the accelerometer data CHIP 2014-11-03
//define variables related to warnings to the user about whether the EEG data is nearly railed (and, therefore, of dubious quality)
DataStatus is_railed[];
final int threshold_railed = int(pow(2, 23)-1000);  //fully railed should be +/- 2^23, so set this threshold close to that value
final int threshold_railed_warn = int(pow(2, 23)*0.9); //set a somewhat smaller value as the warning threshold
//OpenBCI SD Card setting (if eegDataSource == 0)
int sdSetting = 0; //0 = do not write; 1 = 5 min; 2 = 15 min; 3 = 30 min; etc...
String sdSettingString = "Do not write to SD";
//cyton data packet
int nDataBackBuff;
DataPacket_ADS1299 dataPacketBuff[]; //allocate later in InitSystem
int curDataPacketInd = -1;
int curBDFDataPacketInd = -1;
int lastReadDataPacketInd = -1;
////// ---- End variables related to the OpenBCI boards

// define some timing variables for this program's operation
long timeOfLastFrame = 0;
long timeOfInit;
boolean attemptingToConnect = false;

// Calculate nPointsPerUpdate based on sampling rate and buffer update rate
// @UPDATE_MILLIS: update the buffer every 40 milliseconds
// @nPointsPerUpdate: update the GUI after this many data points have been received.
// The sampling rate should be ideally a multiple of 25, so as to make actual buffer update rate exactly 40ms
final int UPDATE_MILLIS = 40;
int nPointsPerUpdate;   // no longer final, calculate every time in initSystem
// final int nPointsPerUpdate = 50; //update the GUI after this many data points have been received
// final int nPointsPerUpdate = 24; //update the GUI after this many data points have been received
// final int nPointsPerUpdate = 10; //update the GUI after this many data points have been received

//define some data fields for handling data here in processing
float dataBuffX[];  //define the size later
float dataBuffY_uV[][]; //2D array to handle multiple data channels, each row is a new channel so that dataBuffY[3][] is channel 4
float dataBuffY_filtY_uV[][];
float yLittleBuff[];
float yLittleBuff_uV[][]; //small buffer used to send data to the filters
float accelerometerBuff[][]; // accelerometer buff 500 points
float auxBuff[][];
float data_elec_imp_ohm[];

float displayTime_sec = 20f;    //define how much time is shown on the time-domain montage plot (and how much is used in the FFT plot?)
float dataBuff_len_sec = displayTime_sec + 3f; //needs to be wider than actual display so that filter startup is hidden

//variables for writing EEG data out to a file
OutputFile_rawtxt fileoutput_odf;
OutputFile_BDF fileoutput_bdf;
String output_fname;
String fileName = "N/A";
final int OUTPUT_SOURCE_NONE = 0;
final int OUTPUT_SOURCE_ODF = 1; // The OpenBCI CSV Data Format
final int OUTPUT_SOURCE_BDF = 2; // The BDF data format http://www.biosemi.com/faq/file_format.htm
public int outputDataSource = OUTPUT_SOURCE_ODF;
// public int outputDataSource = OUTPUT_SOURCE_BDF;

// Serial output
String serial_output_portName = "/dev/tty.usbmodem1421";  //must edit this based on the name of the serial/COM port
Serial serial_output;
int serial_output_baud = 9600; //baud rate from the Arduino

//Control Panel for (re)configuring system settings
PlotFontInfo fontInfo;

//program variables
boolean isRunning = false;
boolean redrawScreenNow = true;
int openBCI_byteCount = 0;
StringBuilder board_message;

//for screen resizing
boolean screenHasBeenResized = false;
float timeOfLastScreenResize = 0;
float timeOfGUIreinitialize = 0;
int reinitializeGUIdelay = 125;
//Tao's variables
int widthOfLastScreen = 0;
int heightOfLastScreen = 0;

//set window size
int win_x = 1024;  //window width
int win_y = 768; //window height

PImage logo_blue;
PImage logo_white;
PImage consoleImgBlue;
PImage consoleImgWhite;

PFont f1;
PFont f2;
PFont f3;
PFont f4;

PFont h1; //large Montserrat
PFont h2; //large/medium Montserrat
PFont h3; //medium Montserrat
PFont h4; //small/medium Montserrat
PFont h5; //small Montserrat

PFont p0; //large bold Open Sans
PFont p1; //large Open Sans
PFont p2; //large/medium Open Sans
PFont p3; //medium Open Sans
PFont p15;
PFont p4; //medium/small Open Sans
PFont p13;
PFont p5; //small Open Sans
PFont p6; //small Open Sans

ButtonHelpText buttonHelpText;

boolean has_processed = false;
boolean isOldData = false;
//Used for playback file
int indices = 0;
//# columns used by a playback file determines number of channels
final int totalColumns4ChanThresh = 10;
final int totalColumns16ChanThresh = 16;

boolean setupComplete = false;
boolean isHubInitialized = false;
boolean isHubObjectInitialized = false;
color bgColor = color(1, 18, 41);
color openbciBlue = color(31, 69, 110);
int COLOR_SCHEME_DEFAULT = 1;
int COLOR_SCHEME_ALTERNATIVE_A = 2;
// int COLOR_SCHEME_ALTERNATIVE_B = 3;
int colorScheme = COLOR_SCHEME_ALTERNATIVE_A;

Process nodeHubby;
String nodeHubName = "OpenBCIHub";

PApplet ourApplet;

static CustomOutputStream outputStream;

//Variables from TopNav.pde. Used to set text when stopping/starting data stream.
public final static String stopButton_pressToStop_txt = "Stop Data Stream";
public final static String stopButton_pressToStart_txt = "Start Data Stream";

///////////Variables from HardwareSettingsController. This fixes a number of issues.
int numSettingsPerChannel = 6; //each channel has 6 different settings
char[][] channelSettingValues = new char [nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button
char[][] impedanceCheckValues = new char [nchan][2];

SoftwareSettings settings = new SoftwareSettings();

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//========================SETUP============================//

int frameRateCounter = 1; //0 = 24, 1 = 30, 2 = 45, 3 = 60

void settings() {
    //If 1366x768, set GUI to 976x549 to fix #378 regarding some laptop resolutions
    if (displayWidth == 1366 && displayHeight == 768) {
        size(976, 549, P2D);
    } else {
        //default 1024x768 resolution with 2D graphics
        size(1024, 768, P2D);
    }
}

void setup() {
    //V1 FONTS
    f1 = createFont("fonts/Raleway-SemiBold.otf", 16);
    f2 = createFont("fonts/Raleway-Regular.otf", 15);
    f3 = createFont("fonts/Raleway-SemiBold.otf", 15);
    f4 = createFont("fonts/Raleway-SemiBold.otf", 64);  // clear bigger fonts for widgets

    h1 = createFont("fonts/Montserrat-Regular.otf", 20);
    h2 = createFont("fonts/Montserrat-Regular.otf", 18);
    h3 = createFont("fonts/Montserrat-Regular.otf", 16);
    h4 = createFont("fonts/Montserrat-Regular.otf", 14);
    h5 = createFont("fonts/Montserrat-Regular.otf", 12);

    p0 = createFont("fonts/OpenSans-Semibold.ttf", 24);
    p1 = createFont("fonts/OpenSans-Regular.ttf", 20);
    p2 = createFont("fonts/OpenSans-Regular.ttf", 18);
    p3 = createFont("fonts/OpenSans-Regular.ttf", 16);
    p15 = createFont("fonts/OpenSans-Regular.ttf", 15);
    p4 = createFont("fonts/OpenSans-Regular.ttf", 14);
    p13 = createFont("fonts/OpenSans-Regular.ttf", 13);
    p5 = createFont("fonts/OpenSans-Regular.ttf", 12);
    p6 = createFont("fonts/OpenSans-Regular.ttf", 10);

    // check if the current directory is writable
    File dummy = new File(sketchPath());
    if (!dummy.canWrite()) {
        showStartupError = true;
        startupErrorMessage = "OpenBCI GUI was launched from a read-only location.\n\n" +
            "Please move the application to a different location and re-launch.\n" +
            "If you just downloaded the GUI, move it out of the disk image or Downloads folder.\n\n" +
            "If this error persists, contact the OpenBCI team for support.";
        return; // early exit
    }

    // redirect all output to a custom stream that will intercept all prints
    // write them to file and display them in the GUI's console window
    outputStream = new CustomOutputStream(System.out);
    System.setOut(outputStream);
    System.setErr(outputStream);

    println("Screen Resolution: " + displayWidth + " X " + displayHeight);
    println("Welcome to the Processing-based OpenBCI GUI!"); //Welcome line.
    println("For more information, please visit: https://docs.openbci.com/OpenBCI%20Software/");

    //open window
    ourApplet = this;

    if(frameRateCounter==0) {
        frameRate(24); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
    }
    if(frameRateCounter==1) {
        frameRate(30); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
    }
    if(frameRateCounter==2) {
        frameRate(45); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
    }
    if(frameRateCounter==3) {
        frameRate(60); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
    }

    // Bug #426: If setup takes too long, JOGL will time out waiting for the GUI to draw something.
    // moving the setup to a separate thread solves this. We just have to make sure not to
    // start drawing until delayed setup is done.
    thread("delayedSetup");
}

void delayedSetup() {
    if (!isWindows()) hubStop(); //kill any existing hubs before starting a new one..
    hubInit(); // putting down here gives windows time to close any open apps

    smooth(); //turn this off if it's too slow

    surface.setResizable(true);  //updated from frame.setResizable in Processing 2
    widthOfLastScreen = width; //for screen resizing (Thank's Tao)
    heightOfLastScreen = height;

    setupContainers();

    //listen for window resize ... used to adjust elements in application
    frame.addComponentListener(new ComponentAdapter() {
        public void componentResized(ComponentEvent e) {
            if (e.getSource()==frame) {
                println("OpenBCI_GUI: setup: RESIZED");
                screenHasBeenResized = true;
                timeOfLastScreenResize = millis();
                // initializeGUI();
            }
        }
    }
    );

    fontInfo = new PlotFontInfo();
    helpWidget = new HelpWidget(0, win_y - 30, win_x, 30);

    //setup topNav
    topNav = new TopNav();

    logo_blue = loadImage("logo_blue.png");
    logo_white = loadImage("logo_white.png");
    cog = loadImage("cog_1024x1024.png");
    consoleImgBlue = loadImage("console-45x45-dots_blue.png");
    consoleImgWhite = loadImage("console-45x45-dots_white.png");
    loadingGIF = new Gif(this, "ajax_loader_gray_512.gif");
    loadingGIF.loop();
    loadingGIF_blue = new Gif(this, "OpenBCI-LoadingGIF-blue-256.gif");
    loadingGIF_blue.loop();

    buttonHelpText = new ButtonHelpText();

    myPresentation = new Presentation();

    // UDPMarker functionality
    // Setup the UDP receiver // This needs to be done only when marker mode is enabled
    int portRX = 51000;  // this is the UDP port the application will be listening on
    String ip = "127.0.0.1";  // Currently only localhost is supported as UDP Marker source

    //create new object for receiving
    udpRX=new UDP(this,portRX,ip);
    udpRX.setReceiveHandler("udpReceiveHandler");
    udpRX.log(true);
    udpRX.listen(true);
    // Print some useful diagnostics
    println("OpenBCI_GUI::Setup: Is RX mulitcast: "+udpRX.isMulticast());
    println("OpenBCI_GUI::Setup: Has RX joined multicast: "+udpRX.isJoined());

    synchronized(this) {
        // Instantiate ControlPanel in the synchronized block.
        // It's important to avoid instantiating a ControlP5 during a draw() call
        // Otherwise we get a crash on launch 10% of the time
        controlPanel = new ControlPanel(this);

        setupComplete = true; // signal that the setup thread has finished
    }
}

//====================== END-OF-SETUP ==========================//

//====================UDP Packet Handler==========================//
// This function handles the received UDP packet
// See the documentation for the Java UDP class here:
// https://ubaa.net/shared/processing/udp/udp_class_udp.htm

String udpReceiveString = null;

void udpReceiveHandler(byte[] data, String ip, int portRX) {

    String udpString = new String(data);
    println(udpString+" from: "+ip+" and port: "+portRX);
    if (udpString.length() >=5  && udpString.indexOf("MARK") >= 0) {

        int intValue = Integer.parseInt(udpString.substring(4));

        if (intValue > 0 && intValue < 96) { // Since we only send single char ascii value markers (from space to char(126)
            String sendString = "`"+char(intValue+31);
            println("Marker value: "+udpString+" with numeric value of char("+intValue+") as : "+sendString);
            hub.sendCommand(sendString);

        } else {
            println("udpReceiveHandler::Warning:invalid UDP STIM of value: "+intValue+" Received String: "+udpString);
        }
    } else {
            println("udpReceiveHandler::Warning:invalid UDP marker packet: "+udpString);

    }
}

//======================== DRAW LOOP =============================//

synchronized void draw() {
    if (showStartupError) {
        drawStartupError();
    }
    else if (setupComplete) {
        drawLoop_counter++; //signPost("10");
        systemUpdate(); //signPost("20");
        systemDraw();   //signPost("30");
    }
}

//====================== END-OF-DRAW ==========================//

/**
  * This allows us to kill the running node process on quit.
  */
private void prepareExitHandler () {
    Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
        public void run () {
            System.out.println("SHUTDOWN HOOK");
            try {
                if (hubStop()) {
                    System.out.println("SHUTDOWN HUB");
                } else {
                    System.out.println("FAILED TO SHUTDOWN HUB");
                }
                //If user starts system and quits the app,
                //save user settings for current mode!
                if (systemMode == SYSTEMMODE_POSTINIT) {
                    settings.save(settings.getPath("User", eegDataSource, nchan));
                }
            } catch (Exception ex) {
                ex.printStackTrace(); // not much else to do at this point
            }
        }
    }
    ));
}

/**
  * Starts the hub and sets prepares the exit handler.
  */
void hubInit() {
    isHubInitialized = true;
    hubStart();
    prepareExitHandler();
}

/**
  * Starts the node hub working, tested on mac and windows.
  */
void hubStart() {
    println("Launching application from local data dir");
    try {
        // https://forum.processing.org/two/discussion/13053/use-launch-for-applications-kept-in-data-folder
        if (isWindows()) {
            println("OpenBCI_GUI: hubStart: OS Detected: Windows");
            nodeHubby = launch(dataPath("/OpenBCIHub/OpenBCIHub.exe"));
        } else if (isLinux()) {
            println("OpenBCI_GUI: hubStart: OS Detected: Linux");
            nodeHubby = exec(dataPath("./OpenBCIHub/OpenBCIHub"));
        } else {
            println("OpenBCI_GUI: hubStart: OS Detected: Mac");
            nodeHubby = launch(dataPath("OpenBCIHub.app"));
        }
        // hubRunning = true;
    }
    catch (Exception e) {
        println("hubStart: " + e);
    }
}

/**
  * @description Single function to call at the termination program hook.
  */
boolean hubStop() {
    if (isWindows()) {
        return killRunningprocessWin();
    } else {
        killRunningProcessMac();
        return true;
    }
}

/**
  * @description Helper function to determine if the system is linux or not.
  * @return {boolean} true if os is linux, false otherwise.
  */
private boolean isLinux() {
    return System.getProperty("os.name").toLowerCase().indexOf("linux") > -1;
}

/**
  * @description Helper function to determine if the system is windows or not.
  * @return {boolean} true if os is windows, false otherwise.
  */
private boolean isWindows() {
    return System.getProperty("os.name").toLowerCase().indexOf("windows") > -1;
}

/**
  * @description Helper function to determine if the system is macOS or not.
  * @return {boolean} true if os is windows, false otherwise.
  */
private boolean isMac() {
    return !isWindows() && !isLinux();
}

/**
  * @description Parses the running process list for processes whose name have ganglion hub, if found, kills them one by one.
  *  function dubbed "death dealer"
  */
void killRunningProcessMac() {
    try {
        String line;
        Process p = Runtime.getRuntime().exec("ps -e");
        BufferedReader input =
            new BufferedReader(new InputStreamReader(p.getInputStream()));
        while ((line = input.readLine()) != null) {
            if (line.contains(nodeHubName)) {
                try {
                    endProcess(getProcessIdFromLineMac(line));
                    println("Killed: " + line);
                }
                catch (Exception err) {
                    println("Failed to stop process: " + line + "\n\n");
                    err.printStackTrace();
                }
            }
        }
        input.close();
    }
    catch (Exception err) {
        err.printStackTrace();
    }
}

/**
  * @description Parses the running process list for processes whose name have ganglion hub, if found, kills them one by one.
  *  function dubbed "death dealer" aka "cat killer"
  */
boolean killRunningprocessWin() {
    try {
        Runtime.getRuntime().exec("taskkill /F /IM OpenBCIHub.exe");
        return true;
    }
    catch (Exception err) {
        err.printStackTrace();
        return false;
    }
}

/**
  * @description Parses a mac process line and grabs the pid, the first component.
  * @return {int} the process id
  */
int getProcessIdFromLineMac(String line) {
    line = trim(line);
    String[] components = line.split(" ");
    return Integer.parseInt(components[0]);
}

void endProcess(int pid) {
    Runtime rt = Runtime.getRuntime();
    try {
        rt.exec("kill -9 " + pid);
    }
    catch (IOException err) {
        err.printStackTrace();
    }
}

int pointCounter = 0;
int prevBytes = 0;
int prevMillis = millis();
int byteRate_perSec = 0;
int drawLoop_counter = 0;

//used to init system based on initial settings...Called from the "Start System" button in the GUI's ControlPanel

void setupWidgetManager() {
    wm = new WidgetManager(this);
}

//Initialize the system
void initSystem() throws Exception {
    println("");
    println("");
    println("=================================================");
    println("||             INITIALIZING SYSTEM             ||");
    println("=================================================");
    println("");

    timeOfInit = millis(); //store this for timeout in case init takes too long
    verbosePrint("OpenBCI_GUI: initSystem: -- Init 0 -- " + timeOfInit);
    //Checking status here causes "error: resource busy" during init
    /*
    if (eegDataSource == DATASOURCE_CYTON) {
        verbosePrint("OpenBCI_GUI: initSystem: Checking Cyton Connection...");
        system_status(rcBox);
        if (rcStringReceived.startsWith("Cyton dongle could not connect") || rcStringReceived.startsWith("Failure")) {
            throw new Exception("OpenBCI_GUI: initSystem: Dongle failed to connect to Cyton...");
        }
    }
    */
    verbosePrint("OpenBCI_GUI: initSystem: Preparing data variables...");
    //initialize playback file if necessary
    if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
        initPlaybackFileToTable(); //found in W_Playback.pde
    }
    verbosePrint("OpenBCI_GUI: initSystem: Initializing core data objects");
    initCoreDataObjects();

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 1 -- " + millis());
    verbosePrint("OpenBCI_GUI: initSystem: Initializing FFT data objects");
    initFFTObjectsAndBuffer();

    //prepare some signal processing stuff
    //for (int Ichan=0; Ichan < nchan; Ichan++) { detData_freqDomain[Ichan] = new DetectionData_FreqDomain(); }

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 2 -- " + millis());
    verbosePrint("OpenBCI_GUI: initSystem: Closing ControlPanel...");

    controlPanel.close();
    topNav.controlPanelCollapser.setIsActive(false);
    verbosePrint("OpenBCI_GUI: initSystem: Initializing comms with hub....");
    hub.changeState(HubState.COMINIT);
    // hub.searchDeviceStop();

    //prepare the source of the input data
    switch (eegDataSource) {
        case DATASOURCE_CYTON:
            int nEEDataValuesPerPacket = nchan;
            boolean useAux = true;
            if (cyton.getInterface() == INTERFACE_SERIAL) {
                cyton = new Cyton(this, openBCI_portName, openBCI_baud, nEEDataValuesPerPacket, useAux, n_aux_ifEnabled, cyton.getInterface()); //this also starts the data transfer after XX seconds
            } else {
                if (hub.getWiFiStyle() == WIFI_DYNAMIC) {
                    cyton = new Cyton(this, wifi_portName, openBCI_baud, nEEDataValuesPerPacket, useAux, n_aux_ifEnabled, cyton.getInterface()); //this also starts the data transfer after XX seconds
                } else {
                    cyton = new Cyton(this, wifi_ipAddress, openBCI_baud, nEEDataValuesPerPacket, useAux, n_aux_ifEnabled, cyton.getInterface()); //this also starts the data transfer after XX seconds
                }
            }
            break;
        case DATASOURCE_SYNTHETIC:
            //do nothing
            break;
        case DATASOURCE_PLAYBACKFILE:
            break;
        case DATASOURCE_GANGLION:
            if (ganglion.getInterface() == INTERFACE_HUB_BLE || ganglion.getInterface() == INTERFACE_HUB_BLED112) {
                hub.connectBLE(ganglion_portName);
            } else {
                if (hub.getWiFiStyle() == WIFI_DYNAMIC) {
                    hub.connectWifi(wifi_portName);
                } else {
                    hub.connectWifi(wifi_ipAddress);
                }
            }
            break;
        default:
            break;
        }

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 3 -- " + millis());

    if (abandonInit) {
        haltSystem();
        println("Failed to connect to data source... 1");
        outputError("Failed to connect to data source fail point 1");
    } else {
        //initilize the GUI
        topNav.initSecondaryNav();

        //open data file
        if (eegDataSource == DATASOURCE_CYTON) openNewLogFile(fileName);  //open a new log file
        if (eegDataSource == DATASOURCE_GANGLION) openNewLogFile(fileName); // println("open ganglion output file");

        setupWidgetManager();

        if (!abandonInit) {
            nextPlayback_millis = millis(); //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.
            w_timeSeries.hsc.loadDefaultChannelSettings();

            if (eegDataSource != DATASOURCE_GANGLION && eegDataSource != DATASOURCE_CYTON) {
                systemMode = SYSTEMMODE_POSTINIT; //tell system it's ok to leave control panel and start interfacing GUI
            }
            if (!abandonInit) {
                controlPanel.close();
            } else {
                haltSystem();
                println("Failed to connect to data source... 2");
                // output("Failed to connect to data source...");
            }
        } else {
            haltSystem();
            println("Failed to connect to data source... 3");
            // output("Failed to connect to data source...");
        }
    }

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 4 -- " + millis());

    if (eegDataSource == DATASOURCE_CYTON && hub.getFirmwareVersion().equals("v1.0.0")) {
        abandonInit = true;
    }

    if (!abandonInit) {
        //Init software settings: create default settings files, load user settings, etc.
        settings.init();
        settings.initCheckPointFive();
    } else {
        haltSystem();
        if (eegDataSource == DATASOURCE_CYTON) {
            //Normally, this message appears if you have a dongle plugged in, and the Cyton is not On, or on the wrong channel.
            if (!cyton.daisyNotAttached) {
                outputError("Failed to connect to data source. Check that the device is powered on and in range. Also, try pressing AUTOSCAN.");
            } else {
                outputError("Daisy is not attached to the Cyton board. Check connection or select 8 Channels.");
            }
        } else {
            outputError("Failed to connect to data source. Check that the device is powered on and in range.");
        }
        controlPanel.open();
    }

    //reset init variables
    cyton.daisyNotAttached = false;
    midInit = false;
    abandonInit = false;
    systemHasHalted = false;
} //end initSystem

/**
  * @description Useful function to get the correct sample rate based on data source
  * @returns `float` - The frequency / sample rate of the data source
  */
float getSampleRateSafe() {
    if (eegDataSource == DATASOURCE_GANGLION) {
        return ganglion.getSampleRate();
    } else if (eegDataSource == DATASOURCE_CYTON) {
        return cyton.getSampleRate();
    } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
        return playbackData_table.getSampleRate();
    } else {
        return 250;
    }
}

/**
* @description Get the correct points of FFT based on sampling rate
* @returns `int` - Points of FFT. 125Hz, 200Hz, 250Hz -> 256points. 1000Hz -> 1024points. 1600Hz -> 2048 points.
*/
int getNfftSafe() {
    int sampleRate = (int)getSampleRateSafe();
    switch (sampleRate) {
        case 1000:
            return 1024;
        case 1600:
            return 2048;
        case 125:
        case 200:
        case 250:
        default:
            return 256;
    }
}

void initCoreDataObjects() {
    // Nfft = getNfftSafe();
    nDataBackBuff = 3*(int)getSampleRateSafe();
    dataPacketBuff = new DataPacket_ADS1299[nDataBackBuff]; // call the constructor here
    nPointsPerUpdate = int(round(float(UPDATE_MILLIS) * getSampleRateSafe()/ 1000.f));
    dataBuffX = new float[(int)(dataBuff_len_sec * getSampleRateSafe())];
    dataBuffY_uV = new float[nchan][dataBuffX.length];
    dataBuffY_filtY_uV = new float[nchan][dataBuffX.length];
    yLittleBuff = new float[nPointsPerUpdate];
    yLittleBuff_uV = new float[nchan][nPointsPerUpdate]; //small buffer used to send data to the filters
    auxBuff = new float[3][nPointsPerUpdate];
    accelerometerBuff = new float[3][500]; // 500 points = 25Hz * 20secs(Max Window)
    for (int i=0; i<n_aux_ifEnabled; i++) {
        for (int j=0; j<accelerometerBuff[0].length; j++) {
            accelerometerBuff[i][j] = 0;
        }
    }
    //data_std_uV = new float[nchan];
    data_elec_imp_ohm = new float[nchan];
    is_railed = new DataStatus[nchan];
    for (int i=0; i<nchan; i++) is_railed[i] = new DataStatus(threshold_railed, threshold_railed_warn);
    for (int i=0; i<nDataBackBuff; i++) {
        dataPacketBuff[i] = new DataPacket_ADS1299(nchan, n_aux_ifEnabled);
    }
    dataProcessing = new DataProcessing(nchan, getSampleRateSafe());
    dataProcessing_user = new DataProcessing_User(nchan, getSampleRateSafe());

    //initialize the data
    prepareData(dataBuffX, dataBuffY_uV, getSampleRateSafe());
}

void initFFTObjectsAndBuffer() {
    //initialize the FFT objects
    for (int Ichan=0; Ichan < nchan; Ichan++) {
        // verbosePrint("Init FFT Buff – " + Ichan);
        fftBuff[Ichan] = new FFT(getNfftSafe(), getSampleRateSafe());
    }  //make the FFT objects

    //Attempt initialization. If error, print to console and exit function.
    //Fixes GUI crash when trying to load outdated recordings
    try {
        initializeFFTObjects(fftBuff, dataBuffY_uV, getNfftSafe(), getSampleRateSafe());
    } catch (ArrayIndexOutOfBoundsException e) {
        //e.printStackTrace();
        outputError("Playback file load error. Try using a more recent recording.");
        return;
    }
}

void startRunning() {
    verbosePrint("startRunning...");
    output("Data stream started.");
    if (eegDataSource == DATASOURCE_GANGLION) {
        if (ganglion != null) {
            ganglion.startDataTransfer();
        }
    } else if (eegDataSource == DATASOURCE_CYTON) {
        if (cyton != null) {
            cyton.startDataTransfer();
        }
    }
    isRunning = true;
}

void stopRunning() {
    // openBCI.changeState(0); //make sure it's no longer interpretting as binary
    verbosePrint("OpenBCI_GUI: stopRunning: stop running...");
    if (isRunning) {
        output("Data stream stopped.");
    }
    if (eegDataSource == DATASOURCE_GANGLION) {
        if (ganglion != null) {
            ganglion.stopDataTransfer();
        }
    } else {
        if (cyton != null) {
            cyton.stopDataTransfer();
        }
    }

    isRunning = false;
    // openBCI.changeState(0); //make sure it's no longer interpretting as binary
    // systemMode = 0;
    // closeLogFile();
}

//execute this function whenver the stop button is pressed
void stopButtonWasPressed() {
    //toggle the data transfer state of the ADS1299...stop it or start it...
    if (isRunning) {
        verbosePrint("openBCI_GUI: stopButton was pressed...stopping data transfer...");
        wm.setUpdating(false);
        stopRunning();
        topNav.stopButton.setString(stopButton_pressToStart_txt);
        topNav.stopButton.setColorNotPressed(color(184, 220, 105));
        if (eegDataSource == DATASOURCE_GANGLION && ganglion.isCheckingImpedance()) {
            ganglion.impedanceStop();
            w_ganglionImpedance.startStopCheck.but_txt = "Start Impedance Check";
        }
    } else { //not running
        verbosePrint("openBCI_GUI: startButton was pressed...starting data transfer...");
        wm.setUpdating(true);
        // Clear plots when start button is pressed in playback mode
        if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            clearAllTimeSeriesGPlots();
            clearAllAccelGPlots();
        }
        startRunning();
        topNav.stopButton.setString(stopButton_pressToStop_txt);
        topNav.stopButton.setColorNotPressed(color(224, 56, 45));
        nextPlayback_millis = millis();  //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.
        if (eegDataSource == DATASOURCE_GANGLION && ganglion.isCheckingImpedance()) {
            ganglion.impedanceStop();
            w_ganglionImpedance.startStopCheck.but_txt = "Start Impedance Check";
        }
    }
}


//halt the data collection
void haltSystem() {
    if (!systemHasHalted) { //prevents system from halting more than once
        println("openBCI_GUI: haltSystem: Halting system for reconfiguration of settings...");
        if (initSystemButton.but_txt == "STOP SYSTEM") {
            initSystemButton.but_txt = "START SYSTEM";
        }

        stopRunning();  //stop data transfer

        //Save a snapshot of User's GUI settings if the system is stopped, or halted. This will be loaded on next Start System.
        //This method establishes default and user settings for all data modes
        if (systemMode == SYSTEMMODE_POSTINIT) {
            settings.save(settings.getPath("User", eegDataSource, nchan));
        }

        if(cyton.isPortOpen()) { //On halt and the port is open, reset board mode to Default.
            if (w_pulsesensor.analogReadOn || w_analogRead.analogReadOn) {
                cyton.setBoardMode(BoardMode.DEFAULT);
                output("Starting to read accelerometer");
                w_pulsesensor.analogModeButton.setString("Turn Analog Read On");
                w_pulsesensor.analogReadOn = false;
                w_analogRead.analogModeButton.setString("Turn Analog Read On");
                w_analogRead.analogReadOn = false;
            } else if (w_digitalRead.digitalReadOn) {
                cyton.setBoardMode(BoardMode.DEFAULT);
                output("Starting to read accelerometer");
                w_digitalRead.digitalModeButton.setString("Turn Digital Read On");
                w_digitalRead.digitalReadOn = false;
            } else if (w_markermode.markerModeOn) {
                cyton.setBoardMode(BoardMode.DEFAULT);
                output("Starting to read accelerometer");
                w_markermode.markerModeButton.setString("Turn Marker On");
                w_markermode.markerModeOn = false;
            }
        }

        //reset variables for data processing
        curDataPacketInd = -1;
        lastReadDataPacketInd = -1;
        pointCounter = 0;
        currentTableRowIndex = 0;
        prevBytes = 0;
        prevMillis = millis();
        byteRate_perSec = 0;
        drawLoop_counter = 0;
        // eegDataSource = -1;
        //set all data source list items inactive

        //Fix issue for processing successive playback files
        indices = 0;
        hasRepeated = false;
        has_processed = false;
        settings.settingsLoaded = false; //on halt, reset this value

        //reset connect loadStrings
        openBCI_portName = "N/A";  // Fixes inability to reconnect after halding  JAM 1/2017
        ganglion_portName = "N/A";
        wifi_portName = "N/A";

        controlPanel.resetListItems();

        if (eegDataSource == DATASOURCE_CYTON) {
            closeLogFile();  //close log file
            cyton.closeSDandPort();
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            if(ganglion.isCheckingImpedance()) {
                ganglion.impedanceStop();
                w_ganglionImpedance.startStopCheck.but_txt = "Start Impedance Check";
            }
            closeLogFile();  //close log file
            ganglion.closePort();
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            controlPanel.recentPlaybackBox.getRecentPlaybackFiles();
        }
        systemMode = SYSTEMMODE_PREINIT;
        hub.changeState(HubState.NOCOM);

        recentPlaybackFilesHaveUpdated = false;

        // bleList.items.clear();
        // wifiList.items.clear();

        // if (ganglion.isBLE() || ganglion.isWifi() || cyton.isWifi()) {
        //   hub.searchDeviceStart();
        // }

        systemHasHalted = true;
    }

}

void delayedInit() {
    // Initialize a plot
    GPlot plot = new GPlot(this);
}

void systemUpdate() { // for updating data values and variables

    if (isHubInitialized && isHubObjectInitialized == false) {
        hub = new Hub(this);
        println("Instantiating hub object...");
        isHubObjectInitialized = true;
        thread("delayedInit");
    }

    // //update the sync state with the OpenBCI hardware
    // if (iSerial.get_state() == iSerial.HubState.NOCOM || iSerial.get_state() == iSerial.HubState.COMINIT || iSerial.get_state() == iSerial.HubState.SYNCWITHHARDWARE) {
    //   iSerial.updateSyncState(sdSetting);
    // }

    // if (hub.get_state() == HubState.NOCOM || hub.get_state() == HubState.COMINIT || hub.get_state() == HubState.SYNCWITHHARDWARE) {
    //   hub.updateSyncState(sdSetting);
    // }

    //prepare for updating the GUI
    win_x = width;
    win_y = height;

    helpWidget.update();
    topNav.update();
    if (systemMode == SYSTEMMODE_PREINIT) {
        //updates while in system control panel before START SYSTEM
        controlPanel.update();

        if (widthOfLastScreen != width || heightOfLastScreen != height) {
            topNav.screenHasBeenResized(width, height);
            widthOfLastScreen = width;
            heightOfLastScreen = height;
        }
    }
    if (systemMode == SYSTEMMODE_POSTINIT) {
        if (isRunning) {
            //get the data, if it is available
            pointCounter = getDataIfAvailable(pointCounter);

            //has enough data arrived to process it and update the GUI?
            if (pointCounter >= nPointsPerUpdate) {
                pointCounter = 0;  //reset for next time

                //process the data
                processNewData();

                if ((millis() - timeOfGUIreinitialize) > reinitializeGUIdelay) { //wait 1 second for GUI to reinitialize
                    try {

                        //-----------------------------------------------------------
                        //-----------------------------------------------------------
                        // gui.update(dataProcessing.data_std_uV, data_elec_imp_ohm);
                        // topNav.update();
                        // updateGUIWidgets(); //####
                        //-----------------------------------------------------------
                        //-----------------------------------------------------------
                    }
                    catch (Exception e) {
                        println(e.getMessage());
                        reinitializeGUIdelay = reinitializeGUIdelay * 2;
                        println("OpenBCI_GUI: systemUpdate: New GUI reinitialize delay = " + reinitializeGUIdelay);
                    }
                } else {
                    println("OpenBCI_GUI: systemUpdate: reinitializing GUI after resize... not updating GUI");
                }

                redrawScreenNow=true;
            } else {
                //not enough data has arrived yet... only update the channel controller
            }
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && !has_processed && !isOldData) {
            lastReadDataPacketInd = 0;
            pointCounter = 0;
            try {
                process_input_file();
                println("^^^GUI update process file has occurred");
            }
            catch(Exception e) {
                isOldData = true;
                println("^^^Error processing timestamps");
                output("Error processing timestamps, are you using old data?");
            }
        }

        // gui.cc.update(); //update Channel Controller even when not updating certain parts of the GUI... (this is a bit messy...)

        //alternative component listener function (line 177 - 187 frame.addComponentListener) for processing 3,
        if (widthOfLastScreen != width || heightOfLastScreen != height) {
            println("OpenBCI_GUI: setup: RESIZED");
            screenHasBeenResized = true;
            timeOfLastScreenResize = millis();
            widthOfLastScreen = width;
            heightOfLastScreen = height;
        }

        //re-initialize GUI if screen has been resized and it's been more than 1/2 seccond (to prevent reinitialization of GUI from happening too often)
        if (screenHasBeenResized) {
            // GUIWidgets_screenResized(width, height);
            ourApplet = this; //reset PApplet...
            topNav.screenHasBeenResized(width, height);
            wm.screenResized();
        }
        if (screenHasBeenResized == true && (millis() - timeOfLastScreenResize) > reinitializeGUIdelay) {
            screenHasBeenResized = false;
            println("systemUpdate: reinitializing GUI");
            timeOfGUIreinitialize = millis();
            // initializeGUI();
            // GUIWidgets_screenResized(width, height);
        }

        if (wm.isWMInitialized) {
            wm.update();
        }
    }
}

void systemDraw() { //for drawing to the screen
    //redraw the screen...not every time, get paced by when data is being plotted
    background(bgColor);  //clear the screen
    noStroke();
    //background(255);  //clear the screen

    if (systemMode >= SYSTEMMODE_POSTINIT) {
        int drawLoopCounter_thresh = 100;
        if ((redrawScreenNow) || (drawLoop_counter >= drawLoopCounter_thresh)) {
            //if (drawLoop_counter >= drawLoopCounter_thresh) println("OpenBCI_GUI: redrawing based on loop counter...");
            drawLoop_counter=0; //reset for next time
            redrawScreenNow = false;  //reset for next time

            //update the title of the figure;
            switch (eegDataSource) {
            case DATASOURCE_CYTON:
                switch (outputDataSource) {
                case OUTPUT_SOURCE_ODF:
                    surface.setTitle(int(frameRate) + " fps, " + int(float(fileoutput_odf.getRowsWritten())/getSampleRateSafe()) + " secs Saved, Writing to " + output_fname);
                    break;
                case OUTPUT_SOURCE_BDF:
                    surface.setTitle(int(frameRate) + " fps, " + int(fileoutput_bdf.getRecordsWritten()) + " secs Saved, Writing to " + output_fname);
                    break;
                case OUTPUT_SOURCE_NONE:
                default:
                    surface.setTitle(int(frameRate) + " fps");
                    break;
                }
                break;
            case DATASOURCE_SYNTHETIC:
                surface.setTitle(int(frameRate) + " fps, Using Synthetic EEG Data");
                break;
            case DATASOURCE_PLAYBACKFILE:
                surface.setTitle(int(frameRate) + " fps, Playing " + getElapsedTimeInSeconds(currentTableRowIndex) + " of " + int(float(playbackData_table.getRowCount())/getSampleRateSafe()) + " secs, Reading from: " + playbackData_fname);
                break;
            case DATASOURCE_GANGLION:
                surface.setTitle(int(frameRate) + " fps, Ganglion!");
                break;
            }
        }

        //wait 1 second for GUI to reinitialize
        if ((millis() - timeOfGUIreinitialize) > reinitializeGUIdelay) {
            // println("attempting to draw GUI...");
            try {
                // println("GUI DRAW!!! " + millis());

                //----------------------------
                // gui.draw(); //draw the GUI

                wm.draw();
                //updateGUIWidgets(); //####
                // drawGUIWidgets();

                // topNav.draw();

                //----------------------------

                // playground.draw();
            }
            catch (Exception e) {
                println(e.getMessage());
                reinitializeGUIdelay = reinitializeGUIdelay * 2;
                println("OpenBCI_GUI: systemDraw: New GUI reinitialize delay = " + reinitializeGUIdelay);
            }
        } else {
            //reinitializing GUI after resize
            println("OpenBCI_GUI: systemDraw: reinitializing GUI after resize... not drawing GUI");
        }

        //dataProcessing_user.draw();
        drawContainers();
    } else { //systemMode != 10
        //still print title information about fps
        surface.setTitle(int(frameRate) + " fps - OpenBCI GUI");
    }

    if (systemMode >= SYSTEMMODE_PREINIT) {
        topNav.draw();

        //control panel
        if (controlPanel.isOpen) {
            controlPanel.draw();
        }

        helpWidget.draw();
    }


    if (systemMode == SYSTEMMODE_INTROANIMATION) {
        introAnimation();
    }

    if ((hub.get_state() == HubState.COMINIT || hub.get_state() == HubState.SYNCWITHHARDWARE) && systemMode == SYSTEMMODE_PREINIT) {
        if (!attemptingToConnect) {
            output("Attempting to establish a connection with your OpenBCI Board...");
            attemptingToConnect = true;
        } else {
            //@TODO: Fix this so that it shows during successful system inits ex. Cyton+Daisy w/ UserSettings
            pushStyle();
            imageMode(CENTER);
            image(loadingGIF, width/2, height/2, 128, 128);//render loading gif...
            popStyle();
        }

        if (millis() - timeOfInit > settings.initTimeoutThreshold) {
            haltSystem();
            initSystemButton.but_txt = "START SYSTEM";
            output("Init timeout. Verify your Serial/COM Port. Power DOWN/UP your OpenBCI & USB Dongle. Then retry Initialization.");
            controlPanel.open();
            attemptingToConnect = false;
        }
    }

    //draw presentation last, bc it is intended to be rendered on top of the GUI ...
    if (drawPresentation) {
        myPresentation.draw();
        //emg_widget.drawTriggerFeedback();
        //dataProcessing_user.drawTriggerFeedback();
    }

    // use commented code below to verify frameRate and check latency
    // println("Time since start: " + millis() + " || Time since last frame: " + str(millis()-timeOfLastFrame));
    // timeOfLastFrame = millis();

    buttonHelpText.draw();
    mouseOutOfBounds(); // to fix
}

void introAnimation() {
    pushStyle();
    imageMode(CENTER);
    background(255);
    int t1 = 4000;
    int t2 = 6000;
    int t3 = 8000;
    float transparency = 0;

    if (millis() >= t1) {
        transparency = map(millis(), t1, t2, 0, 255);
        tint(255, transparency);
        //draw OpenBCI Logo Front & Center
        image(cog, width/2, height/2, width/6, width/6);
        textFont(p3, 16);
        textLeading(24);
        fill(31, 69, 110, transparency);
        textAlign(CENTER, CENTER);
        String displayVersion = "OpenBCI GUI " + localGUIVersionString;
        text(displayVersion, width/2, height/2 + width/9);
        text(localGUIVersionDate, width/2, height/2 + ((width/8) * 1.125));
    }

    //exit intro animation at t2
    if (millis() >= t3) {
        systemMode = SYSTEMMODE_PREINIT;
        controlPanel.isOpen = true;
    }
    popStyle();
}

void drawStartupError() {
    final int w = 600;
    final int h = 350;
    final int headerHeight = 75;
    final int padding = 20;

    pushStyle();
    background(bgColor);
    stroke(204);
    fill(238);
    rect((width - w)/2, (height - h)/2, w, h);
    noStroke();
    fill(217, 4, 4);
    rect((width - w)/2, (height - h)/2, w, headerHeight);
    textFont(p0, 24);
    fill(255);
    textAlign(LEFT, CENTER);
    text("Error", (width - w)/2 + padding, (height - h)/2, w, headerHeight);
    textFont(p3, 16);
    fill(102);
    textAlign(LEFT, TOP);
    text(startupErrorMessage, (width - w)/2 + padding, (height - h)/2 + padding + headerHeight, w-padding*2, h-padding*2-headerHeight);
    popStyle();
}

void openConsole()
{
    ConsoleWindow.display();
}

//CODE FOR FIXING WEIRD EXIT CRASH ISSUE -- 7/27/16 ===========================
boolean mouseInFrame = false;
boolean windowOriginSet = false;
int appletOriginX = 0;
int appletOriginY = 0;
PVector loc;

void mouseOutOfBounds() {
    if (windowOriginSet && mouseInFrame) {

        try {
            if (MouseInfo.getPointerInfo().getLocation().x <= appletOriginX ||
                MouseInfo.getPointerInfo().getLocation().x >= appletOriginX+width ||
                MouseInfo.getPointerInfo().getLocation().y <= appletOriginY ||
                MouseInfo.getPointerInfo().getLocation().y >= appletOriginY+height) {
                mouseX = 0;
                mouseY = 0;
                // println("Mouse out of bounds!");
                mouseInFrame = false;
            }
        }
        catch (RuntimeException e) {
            verbosePrint("Error happened while cursor left application...");
        }
    } else {
        if (mouseX > 0 && mouseX < width && mouseY > 0 && mouseY < height) {
            loc = getWindowLocation(P2D);
            appletOriginX = (int)loc.x;
            appletOriginY = (int)loc.y;
            windowOriginSet = true;
            mouseInFrame = true;
        }
    }
}

PVector getWindowLocation(String renderer) {
    PVector l = new PVector();
    if (renderer == P2D || renderer == P3D) {
        com.jogamp.nativewindow.util.Point p = new com.jogamp.nativewindow.util.Point();
        ((com.jogamp.newt.opengl.GLWindow)surface.getNative()).getLocationOnScreen(p);
        l.x = p.getX();
        l.y = p.getY();
    } else if (renderer == JAVA2D) {
        java.awt.Frame f =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
        l.x = f.getX();
        l.y = f.getY();
    }
    return l;
}
//END OF CODE FOR FIXING WEIRD EXIT CRASH ISSUE -- 7/27/16 ===========================
