
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
import processing.serial.*; //for serial communication to Arduino/OpenBCI
import java.awt.event.*; //to allow for event listener on screen resize
import processing.net.*; // For TCP networking
import grafica.*; //used for graphs
import gifAnimation.*;  //for animated gifs
import java.lang.reflect.*; // For callbacks
import java.io.InputStreamReader; // For input
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.io.FileNotFoundException;
import java.awt.MouseInfo;
import java.lang.Process;
import java.text.DateFormat; //Used in DataLogging.pde
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
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
//import com.sun.jna.Library;
//import com.sun.jna.Native;
//import com.sun.jna.Platform;
//import com.sun.jna.Pointer;
import com.fazecast.jSerialComm.*; //Helps distinguish serial ports on Windows
import org.apache.commons.lang3.time.StopWatch;
import http.requests.*;


//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------
//Used to check GUI version in TopNav.pde and displayed on the splash screen on startup
String localGUIVersionString = "v5.0.2-beta.1";
String localGUIVersionDate = "November 2020";
String guiLatestVersionGithubAPI = "https://api.github.com/repos/OpenBCI/OpenBCI_GUI/releases/latest";
String guiLatestReleaseLocation = "https://github.com/OpenBCI/OpenBCI_GUI/releases/latest";

PApplet ourApplet;

//used to switch between application states
final int SYSTEMMODE_INTROANIMATION = -10;
final int SYSTEMMODE_PREINIT = 0;
final int SYSTEMMODE_POSTINIT = 10;
int systemMode = SYSTEMMODE_INTROANIMATION; /* Modes: -10 = intro sequence; 0 = system stopped/control panel setings; 10 = gui; 20 = help guide */

ControlPanel controlPanel;

int selectedSamplingRate = -1; //program-wide variable to track sampling rate, which can change depending on selected data source

boolean midInit = false;
boolean midInitCheck2 = false;
boolean abandonInit = false;
boolean systemHasHalted = true;
boolean reinitRequested = false;

final int NCHAN_CYTON = 8;
final int NCHAN_CYTON_DAISY = 16;
final int NCHAN_GANGLION = 4;

//choose where to get the EEG data
final int DATASOURCE_CYTON = 0; // new default, data from serial with Accel data CHIP 2014-11-03
final int DATASOURCE_GANGLION = 1;  //looking for signal from OpenBCI board via Serial/COM port, no Aux data
final int DATASOURCE_PLAYBACKFILE = 2;  //playback from a pre-recorded text file
final int DATASOURCE_SYNTHETIC = 3;  //Synthetically generated data
final int DATASOURCE_GALEA = 4;
final int DATASOURCE_STREAMING = 5;
public int eegDataSource = -1; //default to none of the options
final static int NUM_ACCEL_DIMS = 3;

enum BoardProtocol {
    NONE,
    SERIAL,
    BLE,
    WIFI,
    BLED112
}
public BoardProtocol selectedProtocol = BoardProtocol.NONE;

boolean showStartupError = false;
String startupErrorMessage = "";
//here are variables that are used if loading input data from a CSV text file...double slash ("\\") is necessary to make a single slash
String playbackData_fname = "N/A"; //only used if loading input data from a file
String sdData_fname = "N/A"; //only used if loading input data from a sd file
int nextPlayback_millis = -100; //any negative number

// Initialize board
DataSource currentBoard = new BoardNull();

DataLogger dataLogger = new DataLogger();

// Intialize interface protocols
InterfaceSerial iSerial = new InterfaceSerial(); //This is messy, half-deprecated code. See comments in InterfaceSerial.pde - Nov. 2020
String openBCI_portName = "N/A";  //starts as N/A but is selected from control panel to match your OpenBCI USB Dongle's serial/COM
int openBCI_baud = 115200; //baud rate from the Arduino

String ganglion_portName = "N/A";

String wifi_portName = "N/A";
String wifi_ipAddress = "192.168.4.1";

////// ---- Define variables related to OpenBCI board operations
//Define number of channels from cyton...first EEG channels, then aux channels
int nchan = NCHAN_CYTON; //Normally, 8 or 16.  Choose a smaller number to show fewer on the GUI

//define variables related to warnings to the user about whether the EEG data is nearly railed (and, therefore, of dubious quality)
DataStatus is_railed[];
// thresholds are pecentages of max possible value
final double threshold_railed = 90.0;
final double threshold_railed_warn = 75.0;

//Cyton SD Card setting
CytonSDMode cyton_sdSetting = CytonSDMode.NO_WRITE;

//Galea Default Settings
GaleaMode galea_boardSetting = GaleaMode.DEMO; //default mode
GaleaSR galea_sampleRate = GaleaSR.SR_250;

// Calculate nPointsPerUpdate based on sampling rate and buffer update rate
// @UPDATE_MILLIS: update the buffer every 40 milliseconds
// @nPointsPerUpdate: update the GUI after this many data points have been received.
// The sampling rate should be ideally a multiple of 25, so as to make actual buffer update rate exactly 40ms
final int UPDATE_MILLIS = 40;
int nPointsPerUpdate;   // no longer final, calculate every time in initSystem

//define some data fields for handling data here in processing
float dataProcessingRawBuffer[][]; //2D array to handle multiple data channels, each row is a new channel so that dataBuffY[3][] is channel 4
float dataProcessingFilteredBuffer[][];
float data_elec_imp_ohm[];

//define how much time is shown on the time-domain montage plot (and how much is used in the FFT plot?)
int dataBuff_len_sec = 20 + 2; //Add two seconds to max buffer to account for filter artifact on the left of the graph

StopWatch sessionTimeElapsed;
StopWatch streamTimeElapsed;

String output_fname;

//Used mostly in W_playback.pde
JSONObject savePlaybackHistoryJSON;
JSONObject loadPlaybackHistoryJSON;
String userPlaybackHistoryFile;
boolean playbackHistoryFileExists = false;
String playbackData_ShortName;
boolean recentPlaybackFilesHaveUpdated = false;

// Serial output
Serial serial_output;

//Control Panel for (re)configuring system settings
PlotFontInfo fontInfo;

//program variables
StringBuilder board_message;
boolean textFieldIsActive = false;

//set window size
int win_w;  //window width
int win_h; //window height

PImage cog;
Gif loadingGIF;
Gif loadingGIF_blue;

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

boolean setupComplete = false;

//Starting to collect the GUI-wide color pallet here. Rename constants all caps later...
final color OPENBCI_DARKBLUE = color(1, 18, 41);
final color OPENBCI_BLUE = color(31, 69, 110);
final color boxColor = color(200);
final color boxStrokeColor = OPENBCI_DARKBLUE;
final color isSelected_color = color(184, 220, 105);
final color colorNotPressed = color(255);
final color buttonsLightBlue = color(57,128,204);
final color TURN_ON_GREEN = color(184,220,105);
final color WHITE = color(255);
final color BLACK = color(0);
final color TURN_OFF_RED = color(224, 56, 45);
final color BUTTON_HOVER = color(177, 184, 193);//color(252, 221, 198);
final color BUTTON_PRESSED = color(150,170,200); //OPENBCI_DARKBLUE;

final int COLOR_SCHEME_DEFAULT = 1;
final int COLOR_SCHEME_ALTERNATIVE_A = 2;
// int COLOR_SCHEME_ALTERNATIVE_B = 3;
int colorScheme = COLOR_SCHEME_ALTERNATIVE_A;

WidgetManager wm;
boolean wmVisible = true;
CColor cp5_colors;

//Channel Colors -- Defaulted to matching the OpenBCI electrode ribbon cable
final color[] channelColors = {
    color(129, 129, 129),
    color(124, 75, 141),
    color(54, 87, 158),
    color(49, 113, 89),
    color(221, 178, 13),
    color(253, 94, 52),
    TURN_OFF_RED,
    color(162, 82, 49)
};

//Global variable for general navigation bar height
final int navHeight = 22;

ButtonHelpText buttonHelpText;

static CustomOutputStream outputStream;

//Variables from TopNav.pde. Used to set text when stopping/starting data stream.
public final static String stopButton_pressToStop_txt = "Stop Data Stream";
public final static String stopButton_pressToStart_txt = "Start Data Stream";

SessionSettings settings;
DirectoryManager directoryManager;

final int navBarHeight = 32;
TopNav topNav;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//========================SETUP============================//

void settings() {
    //LINUX GFX FIX #816
    System.setProperty("jogl.disable.openglcore", "false");

    win_w = 1024;
    win_h = 768;

    // If less than 1366x768, set smaller minimum GUI size
    // Nov 2020 - Accomodate as low as 1024 X 640
    if (displayWidth <= 1366 || displayHeight <= 768) {
        win_w = 980;
        win_h = 580;
    }
    size(win_w, win_h, P2D);
}

void setup() {
    frameRate(120);

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

    cog = loadImage("cog_1024x1024.png");

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
    
    directoryManager = new DirectoryManager();

    // redirect all output to a custom stream that will intercept all prints
    // write them to file and display them in the GUI's console window
    outputStream = new CustomOutputStream(System.out);
    System.setOut(outputStream);
    System.setErr(outputStream);

    println("Console Log Started at Local Time: " + directoryManager.getFileNameDateTime());
    println("Screen Resolution: " + displayWidth + " X " + displayHeight);
    println("Welcome to the Processing-based OpenBCI GUI!"); //Welcome line.
    println("For more information, please visit: https://openbci.github.io/Documentation/docs/06Software/01-OpenBCISoftware/GUIDocs");
    
    // Copy sample data to the Users' Documents folder +  create Recordings folder
    directoryManager.init();
    settings = new SessionSettings();
    userPlaybackHistoryFile = directoryManager.getSettingsPath()+"UserPlaybackHistory.json";

    //open window
    ourApplet = this;

    // Bug #426: If setup takes too long, JOGL will time out waiting for the GUI to draw something.
    // moving the setup to a separate thread solves this. We just have to make sure not to
    // start drawing until delayed setup is done.
    thread("delayedSetup");
}

void delayedSetup() {
    smooth(); //turn this off if it's too slow

    surface.setResizable(true);  //updated from frame.setResizable in Processing 2
    settings.widthOfLastScreen = width; //for screen resizing (Thank's Tao)
    settings.heightOfLastScreen = height;

    setupContainers();
    
    //listen for window resize ... used to adjust elements in application
    //Doesn't seem to work...
    frame.addComponentListener(new ComponentAdapter() {
        public void componentResized(ComponentEvent e) {
            if (e.getSource().equals(frame)) {
                settings.screenHasBeenResized = true;
                settings.timeOfLastScreenResize = millis();
                // initializeGUI();
            }
        }
    }
    );

    fontInfo = new PlotFontInfo();
    helpWidget = new HelpWidget(0, win_h - 30, win_w, 30);
    //Instantiate buttonHelpText before any buttons have been made
    buttonHelpText = new ButtonHelpText();

    //setup topNav
    topNav = new TopNav();

    logo_blue = loadImage("logo_blue.png");
    logo_white = loadImage("logo_white.png");
    consoleImgBlue = loadImage("console-45x45-dots_blue.png");
    consoleImgWhite = loadImage("console-45x45-dots_white.png");
    loadingGIF = new Gif(this, "ajax_loader_gray_512.gif");
    loadingGIF.loop();
    loadingGIF_blue = new Gif(this, "OpenBCI-LoadingGIF-blue-256.gif");
    loadingGIF_blue.loop();

    prepareExitHandler();

    sessionTimeElapsed = new StopWatch();
    streamTimeElapsed = new StopWatch();

    synchronized(this) {
        // Instantiate ControlPanel in the synchronized block.
        // It's important to avoid instantiating a ControlP5 during a draw() call
        // Otherwise we get a crash on launch 10% of the time
        controlPanel = new ControlPanel(this);

        setupComplete = true; // signal that the setup thread has finished
        println("OpenBCI_GUI::Setup: Setup is complete!");
    }
}

//====================== END-OF-SETUP ==========================//

//======================== DRAW LOOP =============================//

synchronized void draw() {
    if (showStartupError) {
        drawStartupError();
    } else if (setupComplete && systemMode != SYSTEMMODE_INTROANIMATION) {
        systemUpdate(); //signPost("20");
        systemDraw();   //signPost("30");
        if (midInit) {
            //If Start Session was clicked, wait 2 draw cycles to show overlay, then init session.
            //When Init session is started, the screen will seem to hang.
            systemInitSession();
        }
        if(reinitRequested) {
            haltSystem();
            initSystem();
            reinitRequested = false;
        }
    } else if (systemMode == SYSTEMMODE_INTROANIMATION) {
        if (settings.introAnimationInit == 0) {
            settings.introAnimationInit = millis();
        } else {
            introAnimation();
        }
    }
}

//====================== END-OF-DRAW ==========================//

private void prepareExitHandler () {
    // This callback will run when the GUI quits
    Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
        public void run () {
            System.out.println("SHUTDOWN HOOK");
            
            haltSystem();
        }
    }
    ));
}

//used to init system based on initial settings...Called from the "START SESSION" button in the GUI's ControlPanel

//Initialize the system
void initSystem() {
    println("");
    println("");
    println("=================================================");
    println("||             INITIALIZING SYSTEM             ||");
    println("=================================================");
    println("");

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 0 -- ");

    //reset init variables
    systemHasHalted = false;
    boolean abandonInit = false;

    sessionTimeElapsed.reset();
    sessionTimeElapsed.start();
    sessionTimeElapsed.suspend();

    //prepare the source of the input data
    switch (eegDataSource) {
        case DATASOURCE_CYTON:
            if (selectedProtocol == BoardProtocol.SERIAL) {
                if(nchan == 16) {
                    currentBoard = new BoardCytonSerialDaisy(openBCI_portName);
                }
                else {
                    currentBoard = new BoardCytonSerial(openBCI_portName);
                }
            }
            else if (selectedProtocol == BoardProtocol.WIFI) {
                if(nchan == 16) {
                    currentBoard = new BoardCytonWifiDaisy(wifi_ipAddress, selectedSamplingRate);
                }
                else {
                    currentBoard = new BoardCytonWifi(wifi_ipAddress, selectedSamplingRate);
                }
            }
            break;
        case DATASOURCE_SYNTHETIC:
            currentBoard = new BoardBrainFlowSynthetic(nchan);
            break;
        case DATASOURCE_PLAYBACKFILE:
            if (!playbackData_fname.equals("N/A")) {
                currentBoard = new DataSourcePlayback(playbackData_fname);
            } else {
                if (!sdData_fname.equals("N/A")) {
                    currentBoard = new DataSourceSDCard(sdData_fname);
                }
                else {
                    // no code path to it
                    println("No playback or SD file selected.");
                }
            }
            break;
        case DATASOURCE_GANGLION:
            if (selectedProtocol == BoardProtocol.WIFI) {
                currentBoard = new BoardGanglionWifi(wifi_ipAddress, selectedSamplingRate);
            }
            else {
                // todo[brainflow] temp hardcode
                String ganglionName = (String)(controlPanel.bleBox.bleList.getItem(controlPanel.bleBox.bleList.activeItem).get("headline"));
                String ganglionPort = (String)(controlPanel.bleBox.bleList.getItem(controlPanel.bleBox.bleList.activeItem).get("subline"));
                String ganglionMac = controlPanel.bleBox.bleMACAddrMap.get(ganglionName);
                println("MAC address for Ganglion is " + ganglionMac);
                currentBoard = new BoardGanglionBLE(ganglionPort, ganglionMac);
            }
            break;
        case DATASOURCE_GALEA:
            currentBoard = new BoardGalea(
                    controlPanel.galeaBox.getIPAddress(),
                    galea_boardSetting,
                    galea_sampleRate
                    );
            // Replace line above with line below to test brainflow synthetic
            //currentBoard = new BoardBrainFlowSynthetic(16);
            break;
        case DATASOURCE_STREAMING:
            currentBoard = new BoardBrainFlowStreaming(
                    controlPanel.streamingBoardBox.getBoard().getBoardId(), 
                    controlPanel.streamingBoardBox.getIP(),
                    controlPanel.streamingBoardBox.getPort()
                    );
        default:
            break;
    }

    // initialize the chosen board
    boolean success = currentBoard.initialize();
    abandonInit = !success; // abandon if init fails

    updateToNChan(currentBoard.getNumEXGChannels());

    dataLogger.initialize();

    verbosePrint("OpenBCI_GUI: initSystem: Initializing core data objects");
    initCoreDataObjects();

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 1 -- " + millis());
    verbosePrint("OpenBCI_GUI: initSystem: Initializing FFT data objects");
    initFFTObjectsAndBuffer();

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 2 -- " + millis());
    verbosePrint("OpenBCI_GUI: initSystem: Closing ControlPanel...");

    controlPanel.close();
    topNav.controlPanelCollapser.setOff();

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 3 -- " + millis());

    if (abandonInit) {
        haltSystem();
        outputError("Failed to initialize board. Please check that the board is on and has power.");
        controlPanel.open();
        return;
    } else {
        //initilize the secondary topnav and all applicable widgets
        topNav.initSecondaryNav();
        wm = new WidgetManager(this);
        nextPlayback_millis = millis(); //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.
        systemMode = SYSTEMMODE_POSTINIT; //tell system it's ok to leave control panel and start interfacing GUI
    }

    verbosePrint("OpenBCI_GUI: initSystem: -- Init 4 -- " + millis());

     //don't save default session settings for Galea or StreamingBoard
    if (eegDataSource != DATASOURCE_GALEA && eegDataSource != DATASOURCE_STREAMING) {
        //Init software settings: create default settings file that is datasource unique
        settings.init();
        settings.initCheckPointFive();
    } else if (eegDataSource == DATASOURCE_GALEA) {
        //After TopNav has been instantiated, default to Expert mode for Galea
        topNav.configSelector.toggleExpertMode(true);
    }

    midInit = false;
} //end initSystem

public int getCurrentBoardBufferSize() {
    return dataBuff_len_sec * currentBoard.getSampleRate();
}

/**
* @description Get the correct points of FFT based on sampling rate
* @returns `int` - Points of FFT. 125Hz, 200Hz, 250Hz -> 256points. 1000Hz -> 1024points. 1600Hz -> 2048 points.
*/
int getNfftSafe() {
    int sampleRate = currentBoard.getSampleRate();
    switch (sampleRate) {
        case 500:
            return 512;
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
    nPointsPerUpdate = int(round(float(UPDATE_MILLIS) * currentBoard.getSampleRate()/ 1000.f));
    dataProcessingRawBuffer = new float[nchan][getCurrentBoardBufferSize()];
    dataProcessingFilteredBuffer = new float[nchan][getCurrentBoardBufferSize()];

    data_elec_imp_ohm = new float[nchan];
    is_railed = new DataStatus[nchan];
    for (int i=0; i<nchan; i++) {
        is_railed[i] = new DataStatus(threshold_railed, threshold_railed_warn);
    }

    dataProcessing = new DataProcessing(nchan, currentBoard.getSampleRate());
}

void initFFTObjectsAndBuffer() {
    //initialize the FFT objects
    for (int Ichan=0; Ichan < nchan; Ichan++) {
        // verbosePrint("Init FFT Buff – " + Ichan);
        fftBuff[Ichan] = new FFT(getNfftSafe(), currentBoard.getSampleRate());
    }  //make the FFT objects

    //Attempt initialization. If error, print to console and exit function.
    //Fixes GUI crash when trying to load outdated recordings
    try {
        initializeFFTObjects(fftBuff, dataProcessingRawBuffer, getNfftSafe(), currentBoard.getSampleRate());
    } catch (ArrayIndexOutOfBoundsException e) {
        //e.printStackTrace();
        outputError("Playback file load error. Try using a more recent recording.");
        return;
    }
}

void startRunning() {
    // start streaming on the chosen board
    currentBoard.startStreaming();
    if (currentBoard.isStreaming()) {
        output("Data stream started.");
        dataLogger.onStartStreaming();
        // todo: this should really be some sort of signal that listeners can register for "OnStreamStarted"
        // close hardware settings if user starts streaming
        w_timeSeries.closeADSSettings();
        try {
            streamTimeElapsed.reset();
            streamTimeElapsed.start();
            sessionTimeElapsed.resume();
        } catch (IllegalStateException e) {
            e.printStackTrace();
            outputError("Failed to start Timer.");
        }
    } else {
        outputError("Failed to start data stream. Please check hardware. See Console Log or BrainFlow Log for more details.");
    }
}

void stopRunning() {
    //Check again if board is streaming to avoid IllegalStateException
    if (currentBoard.isStreaming()) {
        //If streaming, attempt to stop stream
        currentBoard.stopStreaming();
        if (!currentBoard.isStreaming()) {
            output("Data stream stopped.");
            try {
                streamTimeElapsed.stop();
                sessionTimeElapsed.suspend();
                dataLogger.onStopStreaming();
            } catch (IllegalStateException e) {
                e.printStackTrace();
                outputError("GUI Error: Failed to stop Timer. Please make an issue on GitHub in the GUI repo.");
            }
        }
    } else {
        output("Data stream is already stopped.");
    }
}

//halt the data collection
void haltSystem() {
    if (!systemHasHalted) { //prevents system from halting more than once\
        println("openBCI_GUI: haltSystem: Halting system for reconfiguration of settings...");
        
        //Reset the text for the Start Session button
        controlPanel.initBox.setInitSessionButtonText("START SESSION");

        if (w_networking != null && w_networking.getNetworkActive()) {
            w_networking.stopNetwork();
            println("openBCI_GUI: haltSystem: Network streams stopped");
        }
        
        stopRunning();  //stop data transfer

        //Save a snapshot of User's GUI settings if the system is stopped, or halted. This will be loaded on next Start System.
        //This method establishes default and user settings for all data modes
        if (systemMode == SYSTEMMODE_POSTINIT && 
            eegDataSource != DATASOURCE_GALEA && 
            eegDataSource != DATASOURCE_STREAMING) {
                settings.save(settings.getPath("User", eegDataSource, nchan));
        }

        //reset connect loadStrings
        openBCI_portName = "N/A";  // Fixes inability to reconnect after halding  JAM 1/2017
        ganglion_portName = "";
        wifi_portName = "";

        controlPanel.resetListItems();

        if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            controlPanel.recentPlaybackBox.getRecentPlaybackFiles();
        }
        systemMode = SYSTEMMODE_PREINIT;

        recentPlaybackFilesHaveUpdated = false;

        dataLogger.uninitialize();

        currentBoard.uninitialize();
        currentBoard = new BoardNull(); // back to null

        sessionTimeElapsed.stop();

        systemHasHalted = true;
    }
} //end of halt system

void systemUpdate() { // for updating data values and variables
    //prepare for updating the GUI
    win_w = width;
    win_h = height;
    textFieldIsActive = false;

    currentBoard.update();

    dataLogger.update();

    helpWidget.update();
    topNav.update();
    if (systemMode == SYSTEMMODE_PREINIT) {
        //updates while in system control panel before START SYSTEM
        controlPanel.update();

        if (settings.widthOfLastScreen != width || settings.heightOfLastScreen != height) {
            topNav.screenHasBeenResized(width, height);
            settings.widthOfLastScreen = width;
            settings.heightOfLastScreen = height;
            //println("W = " + width + " || H = " + height);
        }
    }
    if (systemMode == SYSTEMMODE_POSTINIT) {
        processNewData();
        
        //alternative component listener function (line 177 mouseReleased- 187 frame.addComponentListener) for processing 3,
        //Component listener doesn't seem to work, so staying with this method for now
        if (settings.widthOfLastScreen != width || settings.heightOfLastScreen != height) {
            settings.screenHasBeenResized = true;
            settings.timeOfLastScreenResize = millis();
            settings.widthOfLastScreen = width;
            settings.heightOfLastScreen = height;
        }

        //re-initialize GUI if screen has been resized and it's been more than 1/2 seccond (to prevent reinitialization of GUI from happening too often)
        if (settings.screenHasBeenResized && settings.timeOfLastScreenResize + 500 > millis()) {
            ourApplet = this; //reset PApplet...
            topNav.screenHasBeenResized(width, height);
            wm.screenResized();
            settings.screenHasBeenResized = false;
        }

        if (wm.isWMInitialized) {
            wm.update();
        }
    }
}

void systemDraw() { //for drawing to the screen
    //redraw the screen...not every time, get paced by when data is being plotted
    background(OPENBCI_DARKBLUE);  //clear the screen
    noStroke();
    //background(255);  //clear the screen

    if (systemMode >= SYSTEMMODE_POSTINIT) {
        wm.draw();
        drawContainers();
    }

    if (systemMode >= SYSTEMMODE_PREINIT) {
        topNav.draw();

        //control panel
        if (controlPanel.isOpen) {
            controlPanel.draw();
        }

        //Draw output window at the bottom of the GUI
        helpWidget.draw();
    }

    //Draw button help text close to the top
    buttonHelpText.draw();

    //Draw Session Start overlay on top of everything
    if (midInit) {
        drawOverlay("Starting Session...");
    } else if (controlPanel.comPortBox.isAutoScanningForCytonSerial()) {
        drawOverlay("Auto-Scanning for Cyton...");
    }

    //Display GUI version and FPS in the title bar of the app
    surface.setTitle("OpenBCI GUI " + localGUIVersionString + " - " + localGUIVersionDate + " - " + int(frameRate) + " fps");
}

void requestReinit() {
    reinitRequested = true;
}

//Always Called after systemDraw()
void systemInitSession() {
    if (midInitCheck2) {
        println("OpenBCI_GUI: Start session. Calling initSystem().");
        try {
            initSystem(); //found in OpenBCI_GUI.pde
        } catch (Exception e) {
            e.printStackTrace();
            haltSystem();
        }
        midInitCheck2 = false;
        midInit = false;
    } else {
        midInitCheck2 = true;
    }
}

//Global function to update the number of channels
void updateToNChan(int _nchan) {
    nchan = _nchan;
    settings.slnchan = _nchan; //used in SoftwareSettings.pde only
    fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
    println("Channel count set to " + str(nchan));
}

void introAnimation() {
    pushStyle();
    imageMode(CENTER);
    background(255);
    int t1 = 0;
    float transparency = 0;

    if (millis() >= settings.introAnimationInit) {
        transparency = map(millis() - settings.introAnimationInit, t1, settings.introAnimationDuration, 0, 255);
        verbosePrint(String.valueOf(transparency));
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

    //Exit intro animation when the duration has expired AND the Control Panel is ready
    if ((millis() >= settings.introAnimationInit + settings.introAnimationDuration)
        && controlPanel != null) {
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
    background(OPENBCI_DARKBLUE);
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

void drawOverlay(String text) {
    //Draw a gray overlay when the Start Session button is pressed
    pushStyle();
    //imageMode(CENTER);
    fill(124, 142);
    rect(0, 0, width, height);
    popStyle();

    pushStyle();
    textFont(p0, 24);
    fill(boxColor, 255);
    stroke(OPENBCI_DARKBLUE, 200);
    rect(width/2 - (textWidth(text)+20)/2, height/2 - 80/2, textWidth(text) + 20, 80);
    fill(OPENBCI_DARKBLUE, 255);
    text(text, width/2 - textWidth(text)/2, height/2 + 8);
    popStyle();
}
