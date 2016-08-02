///////////////////////////////////////////////////////////////////////////////
//
//   GUI for controlling the ADS1299-based OpenBCI
//
//   Created: Chip Audette, Oct 2013 - May 2014
//   Modified: Conor Russomanno & Joel Murphy, August 2014 - Dec 2014
//   Modified (v2.0): Conor Russomanno & Joel Murphy, June 2016
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

import ddf.minim.analysis.*; //for FFT
//import ddf.minim.*;  // commented because too broad.. contains "Controller" class which is also contained in ControlP5... need to be more specific // To make sound.  Following minim example "frequencyModulation"
import ddf.minim.ugens.*; // To make sound.  Following minim example "frequencyModulation"
import java.lang.Math; //for exp, log, sqrt...they seem better than Processing's built-in
import processing.core.PApplet;
import java.util.*; //for Array.copyOfRange()
import java.util.Map.Entry; 
import processing.serial.*; //for serial communication to Arduino/OpenBCI
import java.awt.event.*; //to allow for event listener on screen resize

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

//used to switch between application states
int systemMode = -10; /* Modes: -10 = intro sequence; 0 = system stopped/control panel setings; 10 = gui; 20 = help guide */

boolean hasIntroAnimation = false;
PImage cog;

//choose where to get the EEG data
final int DATASOURCE_NORMAL = 3;  //looking for signal from OpenBCI board via Serial/COM port, no Aux data
final int DATASOURCE_PLAYBACKFILE = 1;  //playback from a pre-recorded text file
final int DATASOURCE_SYNTHETIC = 2;  //Synthetically generated data
final int DATASOURCE_NORMAL_W_AUX = 0; // new default, data from serial with Accel data CHIP 2014-11-03
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

////// ---- Define variables related to OpenBCI board operations
//Define number of channels from openBCI...first EEG channels, then aux channels
int nchan = 8; //Normally, 8 or 16.  Choose a smaller number to show fewer on the GUI
int n_aux_ifEnabled = 3;  // this is the accelerometer data CHIP 2014-11-03
//define variables related to warnings to the user about whether the EEG data is nearly railed (and, therefore, of dubious quality)
DataStatus is_railed[];
final int threshold_railed = int(pow(2, 23)-1000);  //fully railed should be +/- 2^23, so set this threshold close to that value
final int threshold_railed_warn = int(pow(2, 23)*0.75); //set a somewhat smaller value as the warning threshold
//OpenBCI SD Card setting (if eegDataSource == 0)
int sdSetting = 0; //0 = do not write; 1 = 5 min; 2 = 15 min; 3 = 30 min; etc...
String sdSettingString = "Do not write to SD";
//openBCI data packet
final int nDataBackBuff = 3*(int)openBCI.get_fs_Hz();
DataPacket_ADS1299 dataPacketBuff[] = new DataPacket_ADS1299[nDataBackBuff]; //allocate the array, but doesn't call constructor.  Still need to call the constructor!
int curDataPacketInd = -1;
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
final int nPointsPerUpdate = 50; //update the GUI after this many data points have been received 

//define some data fields for handling data here in processing
float dataBuffX[];  //define the size later
float dataBuffY_uV[][]; //2D array to handle multiple data channels, each row is a new channel so that dataBuffY[3][] is channel 4
float dataBuffY_filtY_uV[][];
float yLittleBuff[] = new float[nPointsPerUpdate];
float yLittleBuff_uV[][] = new float[nchan][nPointsPerUpdate]; //small buffer used to send data to the filters
float data_elec_imp_ohm[];

//variables for writing EEG data out to a file
OutputFile_rawtxt fileoutput;
String output_fname;
String fileName = "N/A";

// Serial output
String serial_output_portName = "/dev/tty.usbmodem1411";  //must edit this based on the name of the serial/COM port
Serial serial_output;
int serial_output_baud = 115200; //baud rate from the Arduino

//Control Panel for (re)configuring system settings
Button controlPanelCollapser;
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

PImage logo;

PFont f1;
PFont f2;
PFont f3;

EMG_Widget motorWidget;

boolean no_start_connection = false;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//========================SETUP============================//
//========================SETUP============================//
//========================SETUP============================//
void setup() {
  println("Welcome to the Processing-based OpenBCI GUI!"); //Welcome line.
  println("Last update: 6/25/2016"); //Welcome line.
  println("For more information about how to work with this code base, please visit: http://docs.openbci.com/tutorials/01-GettingStarted");
  println("For specific questions, please post them to the Software section of the OpenBCI Forum: http://openbci.com/index.php/forum/#/categories/software");
  //open window
  size(1024, 768, P2D);
  // size(displayWidth, displayHeight, P2D);
  //if (frame != null) frame.setResizable(true);  //make window resizable
  //attach exit handler
  //prepareExitHandler();
  frameRate(30); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
  smooth(); //turn this off if it's too slow

  surface.setResizable(true);  //updated from frame.setResizable in Processing 2
  widthOfLastScreen = width; //for screen resizing (Thank's Tao)
  heightOfLastScreen = height;

  setupContainers();
  //setupGUIWidgets(); 

  //V1 FONTS
  f1 = createFont("fonts/Raleway-SemiBold.otf", 16);
  f2 = createFont("fonts/Raleway-Regular.otf", 15);
  f3 = createFont("fonts/Raleway-SemiBold.otf", 15);

  //V2 FONTS
  //f1 = createFont("fonts/Montserrat-SemiBold.otf", 16);
  //f2 = createFont("fonts/Montserrat-Light.otf", 15);
  //f3 = createFont("fonts/Montserrat-SemiBold.otf", 15);

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

  //set up controlPanelCollapser button
  fontInfo = new PlotFontInfo();
  helpWidget = new HelpWidget(0, win_y - 30, win_x, 30);

  // println("..." + this);
  // controlPanelCollapser = new Button(2, 2, 256, int((float)win_y*(0.03f)), "SYSTEM CONTROL PANEL", fontInfo.buttonLabel_size);
  controlPanelCollapser = new Button(2, 2, 256, 26, "SYSTEM CONTROL PANEL", fontInfo.buttonLabel_size);
  controlPanelCollapser.setIsActive(true);
  controlPanelCollapser.makeDropdownButton(true);

  //from the user's perspective, the program hangs out on the ControlPanel until the user presses "Start System".
  print("Graphics & GUI Library: ");
  controlPanel = new ControlPanel(this);  
  //The effect of "Start System" is that initSystem() gets called, which starts up the conneciton to the OpenBCI
  //hardware (via the "updateSyncState()" process) as well as initializing the rest of the GUI elements.  
  //Once the hardware is synchronized, the main GUI is drawn and the user switches over to the main GUI.

  logo = loadImage("logo2.png");
  cog = loadImage("cog_1024x1024.png");

  playground = new Playground(navBarHeight);

  //attempt to open a serial port for "output"
  try {
    verbosePrint("OpenBCI_GUI.pde:  attempting to open serial port for data output = " + serial_output_portName);
    serial_output = new Serial(this, serial_output_portName, serial_output_baud); //open the com port
    serial_output.clear(); // clear anything in the com port's buffer
  } 
  catch (RuntimeException e) {
    verbosePrint("OpenBCI_GUI.pde: *** ERROR ***: Could not open " + serial_output_portName);
  }

  myPresentation = new Presentation();
}
//====================== END-OF-SETUP ==========================//
//====================== END-OF-SETUP ==========================//
//====================== END-OF-SETUP ==========================//

//======================== DRAW LOOP =============================//
//======================== DRAW LOOP =============================//
//======================== DRAW LOOP =============================//

void draw() {

  drawLoop_counter++; //signPost("10");
  systemUpdate(); //signPost("20");
  systemDraw();   //signPost("30");
}

//====================== END-OF-DRAW ==========================//
//====================== END-OF-DRAW ==========================//
//====================== END-OF-DRAW ==========================//

int pointCounter = 0;
int prevBytes = 0; 
int prevMillis = millis();
int byteRate_perSec = 0;
int drawLoop_counter = 0;

//used to init system based on initial settings...Called from the "Start System" button in the GUI's ControlPanel
void initSystem() {

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 0 --");
  timeOfInit = millis(); //store this for timeout in case init takes too long

  //prepare data variables
  verbosePrint("OpenBCI_GUI: initSystem: Preparing data variables...");
  dataBuffX = new float[(int)(dataBuff_len_sec * openBCI.get_fs_Hz())];
  dataBuffY_uV = new float[nchan][dataBuffX.length];
  dataBuffY_filtY_uV = new float[nchan][dataBuffX.length];
  //data_std_uV = new float[nchan];
  data_elec_imp_ohm = new float[nchan];
  is_railed = new DataStatus[nchan];
  for (int i=0; i<nchan; i++) is_railed[i] = new DataStatus(threshold_railed, threshold_railed_warn);
  for (int i=0; i<nDataBackBuff; i++) { 
    //dataPacketBuff[i] = new DataPacket_ADS1299(nchan+n_aux_ifEnabled);
    // dataPacketBuff[i] = new DataPacket_ADS1299(OpenBCI_Nchannels+n_aux_ifEnabled);
    dataPacketBuff[i] = new DataPacket_ADS1299(nchan, n_aux_ifEnabled);
  }
  dataProcessing = new DataProcessing(nchan, openBCI.get_fs_Hz());
  dataProcessing_user = new DataProcessing_User(nchan, openBCI.get_fs_Hz());
  
  


  //initialize the data
  prepareData(dataBuffX, dataBuffY_uV, openBCI.get_fs_Hz());

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 1 --");

  //initialize the FFT objects
  for (int Ichan=0; Ichan < nchan; Ichan++) { 
    verbosePrint("a--"+Ichan);
    fftBuff[Ichan] = new FFT(Nfft, openBCI.get_fs_Hz());
  };  //make the FFT objects
  verbosePrint("OpenBCI_GUI: initSystem: b");
  initializeFFTObjects(fftBuff, dataBuffY_uV, Nfft, openBCI.get_fs_Hz());

  //prepare some signal processing stuff
  //for (int Ichan=0; Ichan < nchan; Ichan++) { detData_freqDomain[Ichan] = new DetectionData_FreqDomain(); }

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 2 --");

  //prepare the source of the input data
  switch (eegDataSource) {
  case DATASOURCE_NORMAL: 
  case DATASOURCE_NORMAL_W_AUX:

    // int nDataValuesPerPacket = OpenBCI_Nchannels;
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
    println("OpenBCI_GUI: initSystem: loading complete.  " + playbackData_table.getRowCount() + " rows of data, which is " + round(float(playbackData_table.getRowCount())/openBCI.get_fs_Hz()) + " seconds of EEG data");

    //removing first column of data from data file...the first column is a time index and not eeg data
    playbackData_table.removeColumn(0);
    break;
  default:
  }

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 3 --");

  //initilize the GUI
  initializeGUI();
  setupGUIWidgets(); //####

  //final config
  // setBiasState(openBCI.isBiasAuto);
  verbosePrint("OpenBCI_GUI: initSystem: -- Init 4 --");

  //open data file
  if ((eegDataSource == DATASOURCE_NORMAL) || (eegDataSource == DATASOURCE_NORMAL_W_AUX)) openNewLogFile(fileName);  //open a new log file

  nextPlayback_millis = millis(); //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.

  if (eegDataSource != DATASOURCE_NORMAL && eegDataSource != DATASOURCE_NORMAL_W_AUX) {
    systemMode = 10; //tell system it's ok to leave control panel and start interfacing GUI
  }
  //sync GUI default settings with OpenBCI's default settings...
  // openBCI.syncWithHardware(); //this starts the sequence off ... read in OpenBCI_ADS1299 iterates through the rest based on the ASCII trigger "$$$"
  // verbosePrint("OpenBCI_GUI: initSystem: -- Init 5 [COMPLETE] --");
}

//halt the data collection
void haltSystem() {
  println("openBCI_GUI: haltSystem: Halting system for reconfiguration of settings...");
  stopRunning();  //stop data transfer

  //reset variables for data processing
  curDataPacketInd = -1;
  lastReadDataPacketInd = -1;
  pointCounter = 0;
  prevBytes = 0; 
  prevMillis = millis();
  byteRate_perSec = 0;
  drawLoop_counter = 0;
  // eegDataSource = -1;
  //set all data source list items inactive

  // stopDataTransfer(); // make sure to stop data transfer, if data is streaming and being drawn

  if ((eegDataSource == DATASOURCE_NORMAL) || (eegDataSource == DATASOURCE_NORMAL_W_AUX)) {
    closeLogFile();  //close log file
    openBCI.closeSDandSerialPort();
  }
  systemMode = 0;
}

void systemUpdate() { // for updating data values and variables

  //update the sync state with the OpenBCI hardware
  openBCI.updateSyncState(sdSetting);

  //prepare for updating the GUI
  win_x = width;
  win_y = height;

  //updates while in intro screen
  if (systemMode == 0) {
  }
  if (systemMode == 10) {
    if (isRunning) {
      //get the data, if it is available
      pointCounter = getDataIfAvailable(pointCounter);

      //has enough data arrived to process it and update the GUI?
      if (pointCounter >= nPointsPerUpdate) {
        pointCounter = 0;  //reset for next time

        //process the data
        processNewData();

        //try to detect the desired signals, do it in frequency space...for OpenBCI_GUI_Simpler
        //detectInFreqDomain(fftBuff,inband_Hz,guard_Hz,detData_freqDomain);
        //gui.setDetectionData_freqDomain(detData_freqDomain);
        //tell the GUI that it has received new data via dumping new data into arrays that the GUI has pointers to

        // println("packet counter = " + newPacketCounter);
        // for(int i = 0; i < dataProcessing.data_std_uV.length; i++){
        //   println("dataProcessing.data_std_uV[" + i + "] = " + dataProcessing.data_std_uV[i]);
        // }
        if ((millis() - timeOfGUIreinitialize) > reinitializeGUIdelay) { //wait 1 second for GUI to reinitialize
          try {

            //-----------------------------------------------------------            
            //-----------------------------------------------------------
            gui.update(dataProcessing.data_std_uV, data_elec_imp_ohm);
            updateGUIWidgets(); //####
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

        ///add raw data to spectrogram...if the correct channel...
        //...look for the first channel that is active (meaning button is not active) or, if it
        //     hasn't yet sent any data, send the last channel even if the channel is off
        //      if (sendToSpectrogram & (!(gui.chanButtons[Ichan].isActive()) | (Ichan == (nchan-1)))) { //send data to spectrogram
        //        sendToSpectrogram = false;  //prevent us from sending more data after this time through
        //        for (int Idata=0;Idata < nPointsPerUpdate;Idata++) {
        //          gui.spectrogram.addDataPoint(yLittleBuff_uV[Ichan][Idata]);
        //          gui.tellGUIWhichChannelForSpectrogram(Ichan);
        //          //gui.spectrogram.addDataPoint(100.0f+(float)Idata);
        //        }
        //      }

        redrawScreenNow=true;
      } else {
        //not enough data has arrived yet... only update the channel controller
      }
    }

    gui.cc.update(); //update Channel Controller even when not updating certain parts of the GUI... (this is a bit messy...)

    //alternative component listener function (line 177 - 187 frame.addComponentListener) for processing 3,
    if (widthOfLastScreen != width || heightOfLastScreen != height) {
      println("OpenBCI_GUI: setup: RESIZED");
      screenHasBeenResized = true;
      timeOfLastScreenResize = millis();
      widthOfLastScreen = width;
      heightOfLastScreen = height;
    }

    //re-initialize GUI if screen has been resized and it's been more than 1/2 seccond (to prevent reinitialization of GUI from happening too often)
    if(screenHasBeenResized){
      GUIWidgets_screenResized(width, height);
    }
    if (screenHasBeenResized == true && (millis() - timeOfLastScreenResize) > reinitializeGUIdelay) {
      screenHasBeenResized = false;
      println("systemUpdate: reinitializing GUI");
      timeOfGUIreinitialize = millis();
      initializeGUI();
      playground.x = width; //reset the x for the playground...
    }

    playground.update();
  }

  controlPanel.update();
}

void systemDraw() { //for drawing to the screen

  //redraw the screen...not every time, get paced by when data is being plotted    
  background(bgColor);  //clear the screen
  //background(255);  //clear the screen

  if (systemMode == 10) {
    int drawLoopCounter_thresh = 100;
    if ((redrawScreenNow) || (drawLoop_counter >= drawLoopCounter_thresh)) {
      //if (drawLoop_counter >= drawLoopCounter_thresh) println("OpenBCI_GUI: redrawing based on loop counter...");
      drawLoop_counter=0; //reset for next time
      redrawScreenNow = false;  //reset for next time

      //update the title of the figure;
      switch (eegDataSource) {
      case DATASOURCE_NORMAL: 
      case DATASOURCE_NORMAL_W_AUX:
        surface.setTitle(int(frameRate) + " fps, Byte Count = " + openBCI_byteCount + ", bit rate = " + byteRate_perSec*8 + " bps" + ", " + int(float(fileoutput.getRowsWritten())/openBCI.get_fs_Hz()) + " secs Saved, Writing to " + output_fname);
        break;
      case DATASOURCE_SYNTHETIC:
        surface.setTitle(int(frameRate) + " fps, Using Synthetic EEG Data");
        break;
      case DATASOURCE_PLAYBACKFILE:
        surface.setTitle(int(frameRate) + " fps, Playing " + int(float(currentTableRowIndex)/openBCI.get_fs_Hz()) + " of " + int(float(playbackData_table.getRowCount())/openBCI.get_fs_Hz()) + " secs, Reading from: " + playbackData_fname);
        break;
      }
    }

    //wait 1 second for GUI to reinitialize
    if ((millis() - timeOfGUIreinitialize) > reinitializeGUIdelay) { 
      // println("attempting to draw GUI...");
      try {
        // println("GUI DRAW!!! " + millis());
        pushStyle();
        fill(255);
        noStroke();
        rect(0, 0, width, navBarHeight);
        popStyle();

        //----------------------------
        gui.draw(); //draw the GUI
        //updateGUIWidgets(); //####
        drawGUIWidgets();

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

    playground.draw();

    motorWidget.draw();
    //dataProcessing_user.draw();
    drawContainers();
  } else { //systemMode != 10
    //still print title information about fps
    surface.setTitle(int(frameRate) + " fps — OpenBCI GUI");
  }

  //control panel
  if (controlPanel.isOpen) {
    controlPanel.draw();
  }

  controlPanelCollapser.draw();
  helpWidget.draw();

  if ((openBCI.get_state() == openBCI.STATE_COMINIT || openBCI.get_state() == openBCI.STATE_SYNCWITHHARDWARE) && systemMode == 0) {
    //make out blink the text "Initalizing GUI..."
    if (millis()%1000 < 500) {
      output("Iniitializing communication w/ your OpenBCI board...");
    } else {
      output("");
    }

    if (millis() - timeOfInit > 12000) {
      haltSystem();
      initSystemButton.but_txt = "START SYSTEM";
      output("Init timeout. Verify your Serial/COM Port. Power DOWN/UP your OpenBCI & USB Dongle. Then retry Initialization.");
    }
  }

  if (drawPresentation) {
    myPresentation.draw();
    motorWidget.drawTriggerFeedback();
    //dataProcessing_user.drawTriggerFeedback();
  }

  // use commented code below to verify frameRate and check latency
  // println("Time since start: " + millis() + " || Time since last frame: " + str(millis()-timeOfLastFrame));
  // timeOfLastFrame = millis();

  if (systemMode == -10) {
    //intro animation sequence
    if (hasIntroAnimation) {
      introAnimation();
    } else {
      systemMode = 0;
    }
  }
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
  }

  //exit intro animation at t2
  if (millis() >= t3) {
    systemMode = 0;
    controlPanel.isOpen = true;
  }
  popStyle();
}