 //<>//
///////////////////////////////////////////////////////////////////////////////
//
//   GUI for controlling the ADS1299-based OpenBCI
//
//   Created: Chip Audette, Oct 2013 - May 2014
//   Modified: Conor Russomanno & Joel Murphy, August 2014 - Dec 2014
//   Modified (v2.0): Conor Russomanno & Joel Murphy (AJ Keller helped too), June 2016
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
import netP5.*; //for OSC networking
import oscP5.*; //for OSC networking
import hypermedia.net.*; //for UDP networking
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

import gifAnimation.*;


//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

//used to switch between application states

final int SYSTEMMODE_INTROANIMATION = -10;
final int SYSTEMMODE_PREINIT = 0;
final int SYSTEMMODE_MIDINIT = 5;
final int SYSTEMMODE_POSTINIT = 10;
int systemMode = SYSTEMMODE_INTROANIMATION; /* Modes: -10 = intro sequence; 0 = system stopped/control panel setings; 10 = gui; 20 = help guide */

boolean midInit = false;
boolean abandonInit = false;

final int NCHAN_CYTON = 8;
final int NCHAN_CYTON_DAISY = 16;
final int NCHAN_GANGLION = 4;

boolean hasIntroAnimation = true;
PImage cog;
Gif loadingGIF;
Gif loadingGIF_blue;

//choose where to get the EEG data
final int DATASOURCE_NORMAL_W_AUX = 0; // new default, data from serial with Accel data CHIP 2014-11-03
final int DATASOURCE_GANGLION = 1;  //looking for signal from OpenBCI board via Serial/COM port, no Aux data
final int DATASOURCE_PLAYBACKFILE = 2;  //playback from a pre-recorded text file
final int DATASOURCE_SYNTHETIC = 3;  //Synthetically generated data
public int eegDataSource = -1; //default to none of the options

//here are variables that are used if loading input data from a CSV text file...double slash ("\\") is necessary to make a single slash
String playbackData_fname = "N/A"; //only used if loading input data from a file
// String playbackData_fname;  //leave blank to cause an "Open File" dialog box to appear at startup.  USEFUL!
float playback_speed_fac = 1.0f;  //make 1.0 for real-time.  larger for faster playback
int currentTableRowIndex = 0;
Table_CSV playbackData_table;
int nextPlayback_millis = -100; //any negative number

//Global Serial/COM communications constants
OpenBCI_ADS1299 openBCI = new OpenBCI_ADS1299(); //dummy creation to get access to constants, create real one later
String openBCI_portName = "N/A";  //starts as N/A but is selected from control panel to match your OpenBCI USB Dongle's serial/COM
int openBCI_baud = 115200; //baud rate from the Arduino

OpenBCI_Ganglion ganglion; //dummy creation to get access to constants, create real one later
String ganglion_portName = "N/A";

////// ---- Define variables related to OpenBCI board operations
//Define number of channels from openBCI...first EEG channels, then aux channels
int nchan = NCHAN_CYTON; //Normally, 8 or 16.  Choose a smaller number to show fewer on the GUI
int n_aux_ifEnabled = 3;  // this is the accelerometer data CHIP 2014-11-03
//define variables related to warnings to the user about whether the EEG data is nearly railed (and, therefore, of dubious quality)
DataStatus is_railed[];
final int threshold_railed = int(pow(2, 23)-1000);  //fully railed should be +/- 2^23, so set this threshold close to that value
final int threshold_railed_warn = int(pow(2, 23)*0.9); //set a somewhat smaller value as the warning threshold
//OpenBCI SD Card setting (if eegDataSource == 0)
int sdSetting = 0; //0 = do not write; 1 = 5 min; 2 = 15 min; 3 = 30 min; etc...
String sdSettingString = "Do not write to SD";
//openBCI data packet
final int nDataBackBuff = 3*(int)get_fs_Hz_safe();
DataPacket_ADS1299 dataPacketBuff[] = new DataPacket_ADS1299[nDataBackBuff]; //allocate the array, but doesn't call constructor.  Still need to call the constructor!
int curDataPacketInd = -1;
int curBDFDataPacketInd = -1;
int lastReadDataPacketInd = -1;
//related to sync'ing communiction to OpenBCI hardware?
boolean currentlySyncing = false;
long timeOfLastCommand = 0;
////// ---- End variables related to the OpenBCI boards

// define some timing variables for this program's operation
long timeOfLastFrame = 0;
int newPacketCounter = 0;
long timeOfInit;
long timeSinceStopRunning = 1000;
int prev_time_millis = 0;

// final int nPointsPerUpdate = 50; //update the GUI after this many data points have been received
// final int nPointsPerUpdate = 24; //update the GUI after this many data points have been received
final int nPointsPerUpdate = 10; //update the GUI after this many data points have been received


//define some data fields for handling data here in processing
float dataBuffX[];  //define the size later
float dataBuffY_uV[][]; //2D array to handle multiple data channels, each row is a new channel so that dataBuffY[3][] is channel 4
float dataBuffY_filtY_uV[][];
float yLittleBuff[] = new float[nPointsPerUpdate];
float yLittleBuff_uV[][] = new float[nchan][nPointsPerUpdate]; //small buffer used to send data to the filters
float accelerometerBuff[][]; // accelerometer buff 500 points
float auxBuff[][] = new float[3][nPointsPerUpdate];
float data_elec_imp_ohm[];

float displayTime_sec = 5f;    //define how much time is shown on the time-domain montage plot (and how much is used in the FFT plot?)
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

//variables for Networking
int port = 0;
String ip = "";
String address = "";
String data_stream = "";
String aux_stream = "";
UDPSend udp;
OSCSend osc;
LSLSend lsl;

// Serial output

// must edit this based on the name of the serial/COM port
// unused when running on Mac
String serial_output_portName = "/dev/tty.usbmodem1411";  

Serial serial_output;
int serial_output_baud = 115200; //baud rate from the Arduino

//Control Panel for (re)configuring system settings
PlotFontInfo fontInfo;

//program constants
boolean isRunning = false;
boolean redrawScreenNow = true;
int openBCI_byteCount = 0;
byte inByte = -1;    // Incoming serial data
StringBuilder board_message;
StringBuilder scanning_message;

int dollaBillz;
boolean isGettingPoll = false;
boolean spaceFound = false;
boolean scanningChannels = false;
int hexToInt = 0;
boolean dev = false;

//for screen resizing
boolean screenHasBeenResized = false;
float timeOfLastScreenResize = 0;
float timeOfGUIreinitialize = 0;
int reinitializeGUIdelay = 125;
//Tao's variabiles
int widthOfLastScreen = 0;
int heightOfLastScreen = 0;

//set window size
int win_x = 1024;  //window width
int win_y = 768; //window height

PImage logo_blue;
PImage logo_white;

PFont f1;
PFont f2;
PFont f3;
PFont f4;


PFont h1; //large Montserrat
PFont h2; //large/medium Montserrat
PFont h3; //medium Montserrat
PFont h4; //small/medium Montserrat
PFont h5; //small Montserrat

PFont p1; //large Open Sans
PFont p2; //large/medium Open Sans
PFont p3; //medium Open Sans
PFont p15;
PFont p4; //medium/small Open Sans
PFont p13;
PFont p5; //small Open Sans
PFont p6; //small Open Sans

ButtonHelpText buttonHelpText;

//EMG_Widget emg_widget;
PulseSensor_Widget pulseWidget;

boolean no_start_connection = false;
boolean has_processed = false;
boolean isOldData = false;

int indices = 0;

boolean synthesizeData = false;

int timeOfSetup = 0;
boolean isHubInitialized = false;
boolean isGanglionObjectInitialized = false;
color bgColor = color(1, 18, 41);
color openbciBlue = color(31, 69, 110);
int COLOR_SCHEME_DEFAULT = 1;
int COLOR_SCHEME_ALTERNATIVE_A = 2;
// int COLOR_SCHEME_ALTERNATIVE_B = 3;
int colorScheme = COLOR_SCHEME_ALTERNATIVE_A;

Process nodeHubby;
int hubPid = 0;
String nodeHubName = "GanglionHub";
Robot rob3115;

//-----------------------------------------1-------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//========================SETUP============================//  

void setup() {
  // Step 1: Prepare the exit handler that will attempt to close a running node
  //  server on shut down of this app, the main process.
  // prepareExitHandler();
  if (dev == false) {
    // On windows wait to start the hub until Ganglion is clicked on in the control panel.
    //  See issue #111
    hubStop(); //kill any existing hubs before starting a new one..
    if (!isWindows()) {
      hubInit();
    }
  }

  println("Welcome to the Processing-based OpenBCI GUI!"); //Welcome line.
  println("Last update: 12/20/2016"); //Welcome line.
  println("For more information about how to work with this code base, please visit: http://docs.openbci.com/OpenBCI%20Software/");
  //open window
  size(1024, 768, P2D);
  frameRate(60); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
  smooth(); //turn this off if it's too slow

  surface.setResizable(true);  //updated from frame.setResizable in Processing 2
  widthOfLastScreen = width; //for screen resizing (Thank's Tao)
  heightOfLastScreen = height;

  setupContainers();

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

  p1 = createFont("fonts/OpenSans-Regular.ttf", 20);
  p2 = createFont("fonts/OpenSans-Regular.ttf", 18);
  p3 = createFont("fonts/OpenSans-Regular.ttf", 16);
  p15 = createFont("fonts/OpenSans-Regular.ttf", 15);
  p4 = createFont("fonts/OpenSans-Regular.ttf", 14);
  p13 = createFont("fonts/OpenSans-Regular.ttf", 13);
  p5 = createFont("fonts/OpenSans-Regular.ttf", 12);
  p6 = createFont("fonts/OpenSans-Regular.ttf", 10);

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

  //from the user's perspective, the program hangs out on the ControlPanel until the user presses "Start System".
  print("Graphics & GUI Library: ");
  controlPanel = new ControlPanel(this);
  //The effect of "Start System" is that initSystem() gets called, which starts up the conneciton to the OpenBCI
  //hardware (via the "updateSyncState()" process) as well as initializing the rest of the GUI elements.
  //Once the hardware is synchronized, the main GUI is drawn and the user switches over to the main GUI.

  logo_blue = loadImage("logo_blue.png");
  logo_white = loadImage("logo_white.png");
  cog = loadImage("cog_1024x1024.png");
  loadingGIF = new Gif(this, "OpenBCI-LoadingGIF-2.gif");
  loadingGIF.loop();
  loadingGIF_blue = new Gif(this, "OpenBCI-LoadingGIF-blue-256.gif");
  loadingGIF_blue.loop();

  playground = new Playground(navBarHeight);  
  
  // attempt to open a serial port for "output"
  // not neccesary for Mac because Mac doesn't use dongle
  if (isWindows() || isLinux()) {    
    try {
      verbosePrint("OpenBCI_GUI.pde: attempting to open serial/COM port for data output = " + serial_output_portName);
      serial_output = new Serial(this, serial_output_portName, serial_output_baud); //open the com port
      serial_output.clear(); // clear anything in the com port's buffer
    }
    catch (RuntimeException e) {
      verbosePrint("OpenBCI_GUI.pde: could not open " + serial_output_portName);
    }  
  }
  
  // println("OpenBCI_GUI: setup: hub is running " + ganglion.isHubRunning());
  buttonHelpText = new ButtonHelpText();

  myPresentation = new Presentation();

  // try{
  //   rob3115 = new Robot();
  // } catch (AWTException e){
  //   println("couldn't create robot...");
  // }

  // ganglion = new OpenBCI_Ganglion(this);
  // wm = new WidgetManager(this);

  timeOfSetup = millis(); //keep track of time when setup is finished... used to make sure enough time has passed before creating some other objects (such as the Ganglion instance)
}
//====================== END-OF-SETUP ==========================//

//======================== DRAW LOOP =============================//

void draw() {
  drawLoop_counter++; //signPost("10");
  systemUpdate(); //signPost("20");
  systemDraw();   //signPost("30");
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
      }
      catch (Exception ex) {
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
      nodeHubby = launch(dataPath("GanglionHub.exe"));
    } else if (isLinux()) {
      println("OpenBCI_GUI: hubStart: OS Detected: Linux");
      nodeHubby = exec(dataPath("GanglionHub"));
    } else {
      println("OpenBCI_GUI: hubStart: OS Detected: Mac");
      nodeHubby = launch(dataPath("GanglionHub.app"));
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
    Runtime.getRuntime().exec("taskkill /F /IM GanglionHub.exe");
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
  return Integer.parseInt(components[0]); //<>//
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

void initSystem() {

  println();
  println();
  println("=================================================");
  println("||             INITIALIZING SYSTEM             ||");
  println("=================================================");
  println();

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 0 -- " + millis());
  timeOfInit = millis(); //store this for timeout in case init takes too long
  verbosePrint("timeOfInit = " + timeOfInit);

  //prepare data variables
  verbosePrint("OpenBCI_GUI: initSystem: Preparing data variables...");
  dataBuffX = new float[(int)(dataBuff_len_sec * get_fs_Hz_safe())];
  dataBuffY_uV = new float[nchan][dataBuffX.length];
  dataBuffY_filtY_uV = new float[nchan][dataBuffX.length];
  accelerometerBuff = new float[3][500]; // 500 points
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
  dataProcessing = new DataProcessing(nchan, get_fs_Hz_safe());
  dataProcessing_user = new DataProcessing_User(nchan, get_fs_Hz_safe());



  //initialize the data
  prepareData(dataBuffX, dataBuffY_uV, get_fs_Hz_safe());

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 1 -- " + millis());

  //initialize the FFT objects
  for (int Ichan=0; Ichan < nchan; Ichan++) {
    verbosePrint("Init FFT Buff – "+Ichan);
    fftBuff[Ichan] = new FFT(Nfft, get_fs_Hz_safe());
  }  //make the FFT objects

  initializeFFTObjects(fftBuff, dataBuffY_uV, Nfft, get_fs_Hz_safe());

  //prepare some signal processing stuff
  //for (int Ichan=0; Ichan < nchan; Ichan++) { detData_freqDomain[Ichan] = new DetectionData_FreqDomain(); }

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 2 -- " + millis());

  //prepare the source of the input data
  switch (eegDataSource) {
  case DATASOURCE_NORMAL_W_AUX:
    int nEEDataValuesPerPacket = nchan;
    boolean useAux = false;
    if (eegDataSource == DATASOURCE_NORMAL_W_AUX) useAux = true;  //switch this back to true CHIP 2014-11-04
    openBCI = new OpenBCI_ADS1299(this, openBCI_portName, openBCI_baud, nEEDataValuesPerPacket, useAux, n_aux_ifEnabled); //this also starts the data transfer after XX seconds
    break;
  case DATASOURCE_SYNTHETIC:
    //do nothing
    break;
  case DATASOURCE_PLAYBACKFILE:
    //open and load the data file
    println("OpenBCI_GUI: initSystem: loading playback data from " + playbackData_fname);
    try {
      playbackData_table = new Table_CSV(playbackData_fname);
    }
    catch (Exception e) {
      println("OpenBCI_GUI: initSystem: could not open file for playback: " + playbackData_fname);
      println("   : quitting...");
      exit();
    }
    println("OpenBCI_GUI: initSystem: loading complete.  " + playbackData_table.getRowCount() + " rows of data, which is " + round(float(playbackData_table.getRowCount())/get_fs_Hz_safe()) + " seconds of EEG data");
    //removing first column of data from data file...the first column is a time index and not eeg data
    playbackData_table.removeColumn(0);
    break;
  case DATASOURCE_GANGLION:
    ganglion.connectBLE(ganglion_portName);
    break;
  default:
    break;
  }

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 3 -- " + millis());

  if (abandonInit) {
    haltSystem();
    println("Failed to connect to data source...");
    output("Failed to connect to data source...");
  } else {
    println("  3a -- " + millis());
    //initilize the GUI
    // initializeGUI(); //will soon be destroyed... and replaced with ...  wm = new WidgetManager(this);
    topNav.initSecondaryNav();
    println("  3b -- " + millis());

    // wm = new WidgetManager(this);
    setupWidgetManager();

    if (!abandonInit) {
      println("  3c -- " + millis());
      // setupGUIWidgets(); //####

      //open data file
      if (eegDataSource == DATASOURCE_NORMAL_W_AUX) openNewLogFile(fileName);  //open a new log file
      if (eegDataSource == DATASOURCE_GANGLION) openNewLogFile(fileName); // println("open ganglion output file");

      nextPlayback_millis = millis(); //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.

      if (eegDataSource != DATASOURCE_GANGLION && eegDataSource != DATASOURCE_NORMAL_W_AUX) {
        systemMode = SYSTEMMODE_POSTINIT; //tell system it's ok to leave control panel and start interfacing GUI
      }
      if (!abandonInit) {
        println("WOOHOO!!!");
        controlPanel.close();
      } else {
        haltSystem();
        println("Failed to connect to data source...");
        output("Failed to connect to data source...");
      }
    } else {
      haltSystem();
      println("Failed to connect to data source...");
      output("Failed to connect to data source...");
    }
  }

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 4 -- " + millis());

  //reset init variables
  midInit = false;
  abandonInit = false;
}

/**
 * @description Useful function to get the correct sample rate based on data source
 * @returns `float` - The frequency / sample rate of the data source
 */
float get_fs_Hz_safe() {
  if (eegDataSource == DATASOURCE_GANGLION) {
    return ganglion.get_fs_Hz();
  } else {
    return openBCI.get_fs_Hz();
  }
}

//halt the data collection
void haltSystem() {
  println("openBCI_GUI: haltSystem: Halting system for reconfiguration of settings...");
  if (initSystemButton.but_txt == "STOP SYSTEM") {
    initSystemButton.but_txt = "START SYSTEM";
  }
  stopRunning();  //stop data transfer

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

  //reset connect loadStrings
  openBCI_portName = "N/A";  // Fixes inability to reconnect after halding  JAM 1/2017
  ganglion_portName = "";
  controlPanel.resetListItems();

  // stopDataTransfer(); // make sure to stop data transfer, if data is streaming and being drawn

  if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
    closeLogFile();  //close log file
    openBCI.closeSDandSerialPort();
  }
  if (eegDataSource == DATASOURCE_GANGLION) {
    closeLogFile();  //close log file
    ganglion.disconnectBLE();
  }
  systemMode = SYSTEMMODE_PREINIT;
}

void systemUpdate() { // for updating data values and variables

  if (isHubInitialized && isGanglionObjectInitialized == false && millis() - timeOfSetup >= 1500) {
    ganglion = new OpenBCI_Ganglion(this);
    println("Instantiating Ganglion object...");
    isGanglionObjectInitialized = true;
  }

  //update the sync state with the OpenBCI hardware
  if (openBCI.state == openBCI.STATE_NOCOM || openBCI.state == openBCI.STATE_COMINIT || openBCI.state == openBCI.STATE_SYNCWITHHARDWARE) {
    openBCI.updateSyncState(sdSetting);
  }

  //prepare for updating the GUI
  win_x = width;
  win_y = height;


  if (systemMode == SYSTEMMODE_PREINIT) {
    //updates while in system control panel before START SYSTEM
    controlPanel.update();
    topNav.update();

    if (widthOfLastScreen != width || heightOfLastScreen != height) {
      topNav.screenHasBeenResized(width, height);
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
      }
      catch(Exception e) {
        isOldData = true;
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
      topNav.screenHasBeenResized(width, height);
      wm.screenResized();
    }
    if (screenHasBeenResized == true && (millis() - timeOfLastScreenResize) > reinitializeGUIdelay) {
      screenHasBeenResized = false;
      println("systemUpdate: reinitializing GUI");
      timeOfGUIreinitialize = millis();
      // initializeGUI();
      // GUIWidgets_screenResized(width, height);
      playground.x = width; //reset the x for the playground...
    }

    wm.update();
    playground.update();
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
      case DATASOURCE_NORMAL_W_AUX:
        switch (outputDataSource) {
        case OUTPUT_SOURCE_ODF:
          surface.setTitle(int(frameRate) + " fps, Byte Count = " + openBCI_byteCount + ", bit rate = " + byteRate_perSec*8 + " bps" + ", " + int(float(fileoutput_odf.getRowsWritten())/get_fs_Hz_safe()) + " secs Saved, Writing to " + output_fname);
          break;
        case OUTPUT_SOURCE_BDF:
          surface.setTitle(int(frameRate) + " fps, Byte Count = " + openBCI_byteCount + ", bit rate = " + byteRate_perSec*8 + " bps" + ", " + int(fileoutput_bdf.getRecordsWritten()) + " secs Saved, Writing to " + output_fname);
          break;
        case OUTPUT_SOURCE_NONE:
        default:
          surface.setTitle(int(frameRate) + " fps, Byte Count = " + openBCI_byteCount + ", bit rate = " + byteRate_perSec*8 + " bps");
          break;
        }
        break;
      case DATASOURCE_SYNTHETIC:
        surface.setTitle(int(frameRate) + " fps, Using Synthetic EEG Data");
        break;
      case DATASOURCE_PLAYBACKFILE:
        surface.setTitle(int(frameRate) + " fps, Playing " + int(float(currentTableRowIndex)/get_fs_Hz_safe()) + " of " + int(float(playbackData_table.getRowCount())/get_fs_Hz_safe()) + " secs, Reading from: " + playbackData_fname);
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
    surface.setTitle(int(frameRate) + " fps — OpenBCI GUI");
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
    //intro animation sequence
    if (hasIntroAnimation) {
      introAnimation();
    } else {
      systemMode = SYSTEMMODE_PREINIT;
    }
  }


  if ((openBCI.get_state() == openBCI.STATE_COMINIT || openBCI.get_state() == openBCI.STATE_SYNCWITHHARDWARE) && systemMode == SYSTEMMODE_PREINIT) {
    //make out blink the text "Initalizing GUI..."
    pushStyle();
    imageMode(CENTER);
    image(loadingGIF, width/2, height/2, 128, 128);//render loading gif...
    popStyle();
    if (millis()%1000 < 500) {
      output("Attempting to establish a connection with your OpenBCI Board...");
    } else {
      output("");
    }

    if (millis() - timeOfInit > 12000) {
      haltSystem();
      initSystemButton.but_txt = "START SYSTEM";
      output("Init timeout. Verify your Serial/COM Port. Power DOWN/UP your OpenBCI & USB Dongle. Then retry Initialization.");
      controlPanel.open();
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
    text("OpenBCI GUI v2.1.1\nJanuary 2017", width/2, height/2 + width/9);
  }

  //exit intro animation at t2
  if (millis() >= t3) {
    systemMode = SYSTEMMODE_PREINIT;
    controlPanel.isOpen = true;
  }
  popStyle();
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
