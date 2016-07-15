import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.analysis.*; 
import ddf.minim.ugens.*; 
import java.lang.Math; 
import processing.core.PApplet; 
import java.util.*; 
import java.util.Map.Entry; 
import processing.serial.*; 
import java.awt.event.*; 
import controlP5.*; 
import org.gwoptics.graphics.*; 
import org.gwoptics.graphics.graph2D.*; 
import org.gwoptics.graphics.graph2D.Graph2D; 
import org.gwoptics.graphics.graph2D.LabelPos; 
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace; 
import org.gwoptics.graphics.graph2D.backgrounds.*; 
import ddf.minim.analysis.*; 
import java.util.*; 
import java.io.OutputStream; 
import org.gwoptics.graphics.*; 
import org.gwoptics.graphics.graph2D.*; 
import org.gwoptics.graphics.graph2D.Graph2D; 
import org.gwoptics.graphics.graph2D.LabelPos; 
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace; 
import org.gwoptics.graphics.graph2D.backgrounds.*; 
import java.awt.Color; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class OpenBCI_GUI extends PApplet {

///////////////////////////////////////////////
//
// GUI for controlling the ADS1299-based OpenBCI
//
// Created: Chip Audette, Oct 2013 - May 2014
// Modified: Conor Russomanno & Joel Murphy, August 2014 - Oct 2014
//
// Requires gwoptics graphing library for processing.  Built on V0.5.0
// http://www.gwoptics.org/processing/gwoptics_p5lib/
//
// Requires ControlP5 library, but an older one.  This will only work
// with the ControlP5 library that is included with this GitHub repository
//
// No warranty.  Use at your own risk.  Use for whatever you'd like.
// 
///////////////////////////////////////////////

 //for FFT
//import ddf.minim.*;  // commented because too broad.. contains "Controller" class which is also contained in ControlP5... need to be more specific // To make sound.  Following minim example "frequencyModulation"
  // To make sound.  Following minim example "frequencyModulation"
 //for exp, log, sqrt...they seem better than Processing's built-in

 //for Array.copyOfRange()

  //for serial communication to Arduino/OpenBCI
 //to allow for event listener on screen resize

boolean isVerbose = true; //set true if you want more verbosity in console

long timeOfLastFrame = 0;
int newPacketCounter = 0;

//used to switch between application states
int systemMode = 0; /* Modes: 0 = system stopped/control panel setings / 10 = gui / 20 = help guide */

//choose where to get the EEG data
final int DATASOURCE_NORMAL = 3;  //looking for signal from OpenBCI board via Serial/COM port, no Aux data
final int DATASOURCE_PLAYBACKFILE = 1;  //playback from a pre-recorded text file
final int DATASOURCE_SYNTHETIC = 2;  //Synthetically generated data
final int DATASOURCE_NORMAL_W_AUX = 0; // new default, data from serial with Accel data CHIP 2014-11-03
public int eegDataSource = -1; //default to none of the options

//Serial communications constants
OpenBCI_ADS1299 openBCI = new OpenBCI_ADS1299(); //dummy creation to get access to constants, create real one later
String openBCI_portName = "N/A";  //starts as N/A but is selected from control panel to match your OpenBCI USB Dongle's serial/COM

int openBCI_baud = 115200; //baud rate from the Arduino
// final int OpenBCI_Nchannels = 8; //normal OpenBCI has 8 channels
//use this for when daisy-chaining two OpenBCI boards
// public int OpenBCI_Nchannels = 8; //daisy chain has 16 channels

//here are variables that are used if loading input data from a CSV text file...double slash ("\\") is necessary to make a single slash
String playbackData_fname = "N/A"; //only used if loading input data from a file
// String playbackData_fname;  //leave blank to cause an "Open File" dialog box to appear at startup.  USEFUL!
float playback_speed_fac = 1.0f;  //make 1.0 for real-time.  larger for faster playback
int currentTableRowIndex = 0;
Table_CSV playbackData_table;
int nextPlayback_millis = -100; //any negative number

// boolean printingRegisters = false;

long timeOfInit;
long timeSinceStopRunning = 1000;

//other data fields
float dataBuffX[];
float dataBuffY_uV[][]; //2D array to handle multiple data channels, each row is a new channel so that dataBuffY[3][] is channel 4
float dataBuffY_filtY_uV[][];
float data_elec_imp_ohm[];

int bgColor = color(1, 18, 41);

//SD Card setting (if eegDataSource == 0)
int sdSetting = 0; //0 = do not write; 1 = 5 min; 2 = 15 min; 3 = 30 min; etc...
String sdSettingString = "Do not write to SD";
//int nchan = 12; //normally, nchan = OpenBCI_Nchannels.  Choose a smaller number to show fewer on the GUI
// int nchan = OpenBCI_Nchannels; //normally, nchan = OpenBCI_Nchannels.  Choose a smaller number to show fewer on the GUI

int nchan = 8; //normally, nchan = OpenBCI_Nchannels.  Choose a smaller number to show fewer on the GUI
// int nchan_active_at_startup = nchan;  //how many channels to be LIVE at startup
int n_aux_ifEnabled = 3;  // this is the accelerometer data CHIP 2014-11-03

int prev_time_millis = 0;
final int nPointsPerUpdate = 50; //update screen after this many data points.  
float yLittleBuff[] = new float[nPointsPerUpdate];
DataStatus is_railed[];
final int threshold_railed = PApplet.parseInt(pow(2,23)-1000);  //fully railed should be +/- 2^23, so set this threshold close to that value
final int threshold_railed_warn = PApplet.parseInt(pow(2,23)*0.75f); //set a somewhat smaller value as the warning threshold

float yLittleBuff_uV[][] = new float[nchan][nPointsPerUpdate]; //small buffer used to send data to the filters

//create objects that'll do the EEG signal processing
EEG_Processing eegProcessing;
EEG_Processing_User eegProcessing_user;

//fft constants
int Nfft = 256; //set resolution of the FFT.  Use N=256 for normal, N=512 for MU waves

FFT fftBuff[] = new FFT[nchan];   //from the minim library
float[] smoothFac = new float[]{0.75f, 0.9f, 0.95f, 0.98f, 0.0f, 0.5f};
final int N_SMOOTHEFAC = 6;
int smoothFac_ind = 0;

//plotting constants
Gui_Manager gui;
float default_vertScale_uV = 200.0f;
float displayTime_sec = 5f;
float dataBuff_len_sec = displayTime_sec+3f; //needs to be wider than actual display so that filter startup is hidden

//Control Panel for (re)configuring system settings
ControlPanel controlPanel;
Button controlPanelCollapser;
PlotFontInfo fontInfo;

Playground playground;
int navBarHeight = 32;

//program constants
boolean isRunning=false;
boolean redrawScreenNow = true;
int openBCI_byteCount = 0;
int inByte = -1;    // Incoming serial data

//Help Widget initiation
HelpWidget helpWidget;

//file writing variables
OutputFile_rawtxt fileoutput;
String output_fname;
String fileName = "N/A";

//serial port open or closed(?)
boolean portIsOpen = false;
Serial serial_openBCI = null;

//for screen resizing
boolean screenHasBeenResized = false;
float timeOfLastScreenResize = 0;
float timeOfGUIreinitialize = 0;
int reinitializeGUIdelay = 125;

//openBCI data packet
final int nDataBackBuff = 3*(int)openBCI.fs_Hz;
DataPacket_ADS1299 dataPacketBuff[] = new DataPacket_ADS1299[nDataBackBuff]; //allocate the array, but doesn't call constructor.  Still need to call the constructor!
int curDataPacketInd = -1;
int lastReadDataPacketInd = -1;

public void appendAndShift(float[] data, float[] newData) {
  int nshift = newData.length;
  int end = data.length-nshift;
  for (int i=0; i < end; i++) {
    data[i]=data[i+nshift];  //shift data points down by 1
  }
  for (int i=0; i<nshift;i++) {
    data[end+i] = newData[i];  //append new data
  }
}

public void prepareData(float[] dataBuffX, float[][] dataBuffY_uV, float fs_Hz) {
  //initialize the x and y data
  int xoffset = dataBuffX.length - 1;
  for (int i=0; i < dataBuffX.length; i++) {
    dataBuffX[i] = ((float)(i-xoffset)) / fs_Hz; //x data goes from minus time up to zero
    for (int Ichan = 0; Ichan < nchan; Ichan++) { 
      dataBuffY_uV[Ichan][i] = 0f;  //make the y data all zeros
    }
  }
}

public void initializeFFTObjects(FFT[] fftBuff, float[][] dataBuffY_uV, int N, float fs_Hz) {

  float[] fooData;
  for (int Ichan=0; Ichan < nchan; Ichan++) {
    //make the FFT objects...Following "SoundSpectrum" example that came with the Minim library
    //fftBuff[Ichan] = new FFT(Nfft, fs_Hz);  //I can't have this here...it must be in setup
    fftBuff[Ichan].window(FFT.HAMMING);

    //do the FFT on the initial data
    fooData = dataBuffY_uV[Ichan];
    fooData = Arrays.copyOfRange(fooData, fooData.length-Nfft, fooData.length); 
    fftBuff[Ichan].forward(fooData); //compute FFT on this channel of data
  }
}

//set window size
int win_x = 1024;  //window width
int win_y = 768; //window height

PImage logo;

PFont f1;
PFont f2;
PFont f3;

//========================SETUP============================//
//========================SETUP============================//
//========================SETUP============================//
public void setup() {
  
  //open window
  size(win_x, win_y, P2D);
  // size(displayWidth, displayHeight, P2D);
  //if (frame != null) frame.setResizable(true);  //make window resizable
  //attach exit handler
  //prepareExitHandler();
  frameRate(16);
  // smooth(); //turn this off if it's too slow

  frame.setResizable(true); 

  f1 = createFont("Raleway-SemiBold.otf", 16);
  f2 = createFont("Raleway-Regular.otf", 15);
  f3 = createFont("Raleway-SemiBold.otf", 15);

  //listen for window resize ... used to adjust elements in application
  frame.addComponentListener(new ComponentAdapter() { 
    public void componentResized(ComponentEvent e) { 
      if(e.getSource()==frame) { 
       println("RESIZED");
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
  controlPanel = new ControlPanel(this); 

  logo = loadImage("logo2.png");

  playground = new Playground(navBarHeight);

}
//====================== END--OF ==========================//
//========================SETUP============================//
//========================SETUP============================//

int pointCounter = 0;
int prevBytes = 0; 
int prevMillis=millis();
int byteRate_perSec = 0;
int drawLoop_counter = 0;

//used to init system based on initial settings
public void initSystem(){

  verbosePrint("-- Init 0 --");
  timeOfInit = millis(); //store this for timeout in case init takes too long

  //prepare data variables
  verbosePrint("Preparing data variables...");
  dataBuffX = new float[(int)(dataBuff_len_sec * openBCI.fs_Hz)];
  dataBuffY_uV = new float[nchan][dataBuffX.length];
  dataBuffY_filtY_uV = new float[nchan][dataBuffX.length];
  //data_std_uV = new float[nchan];
  data_elec_imp_ohm = new float[nchan];
  is_railed = new DataStatus[nchan];
  for (int i=0; i<nchan;i++) is_railed[i] = new DataStatus(threshold_railed,threshold_railed_warn);
  for (int i=0; i<nDataBackBuff;i++) { 
    //dataPacketBuff[i] = new DataPacket_ADS1299(nchan+n_aux_ifEnabled);
    // dataPacketBuff[i] = new DataPacket_ADS1299(OpenBCI_Nchannels+n_aux_ifEnabled);
    dataPacketBuff[i] = new DataPacket_ADS1299(nchan,n_aux_ifEnabled);
  }
  eegProcessing = new EEG_Processing(nchan,openBCI.fs_Hz);
  eegProcessing_user = new EEG_Processing_User(nchan,openBCI.fs_Hz);

  //initialize the data
  prepareData(dataBuffX, dataBuffY_uV,openBCI.fs_Hz);

  verbosePrint("-- Init 1 --");

  //initialize the FFT objects
  for (int Ichan=0; Ichan < nchan; Ichan++) { 
    println("a--"+Ichan);
    fftBuff[Ichan] = new FFT(Nfft, openBCI.fs_Hz);
  };  //make the FFT objects
  println("b");
  initializeFFTObjects(fftBuff, dataBuffY_uV, Nfft, openBCI.fs_Hz);

  //prepare some signal processing stuff
  //for (int Ichan=0; Ichan < nchan; Ichan++) { detData_freqDomain[Ichan] = new DetectionData_FreqDomain(); }

  verbosePrint("-- Init 2 --");

  //prepare the source of the input data
  switch (eegDataSource) {
    case DATASOURCE_NORMAL: case DATASOURCE_NORMAL_W_AUX:
      
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
      println("OpenBCI_GUI: loading playback data from " + playbackData_fname);
      try {
        playbackData_table = new Table_CSV(playbackData_fname);
      } catch (Exception e) {
        println("setup: could not open file for playback: " + playbackData_fname);
        println("   : quitting...");
        exit();
      }
      println("OpenBCI_GUI: loading complete.  " + playbackData_table.getRowCount() + " rows of data, which is " + round(PApplet.parseFloat(playbackData_table.getRowCount())/openBCI.fs_Hz) + " seconds of EEG data");
      
      //removing first column of data from data file...the first column is a time index and not eeg data
      playbackData_table.removeColumn(0);
      break;
    default: 
  }

  verbosePrint("-- Init 3 --");

  //initilize the GUI
  initializeGUI();
  
  //final config
  // setBiasState(openBCI.isBiasAuto);
  verbosePrint("-- Init 4 --");

  //open data file
  if ((eegDataSource == DATASOURCE_NORMAL) || (eegDataSource == DATASOURCE_NORMAL_W_AUX)) openNewLogFile(fileName);  //open a new log file

  nextPlayback_millis = millis(); //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.
  
  if(eegDataSource != DATASOURCE_NORMAL && eegDataSource != DATASOURCE_NORMAL_W_AUX){
    systemMode = 10; //tell system it's ok to leave control panel and start interfacing GUI
  }
  //sync GUI default settings with OpenBCI's default settings...
  // syncWithHardware(); //this starts the sequence off ... read in OpenBCI_ADS1299 iterates through the rest based on the ASCII trigger "$$$"
  // verbosePrint("-- Init 5 [COMPLETE] --");
}

int hardwareSyncStep = 0; //start this at 0...
boolean readyToSend = false; //system waits for $$$ after requesting information from OpenBCI board
boolean currentlySyncing = false;
long timeOfLastCommand = 0;

public void syncWithHardware(){
  switch (hardwareSyncStep) {
    // case 1:
    //   println("[0] Sending 'v' to OpenBCI to reset hardware in case of 32bit board...");
    //   serial_openBCI.write('v');
    //   readyToSend = false; //wait for $$$ to iterate... applies to commands expecting a response
    case 1: //send # of channels (8 or 16) ... (regular or daisy setup)
      println("[1] Sending channel count (" + nchan + ") to OpenBCI...");
      if(nchan == 8){
        serial_openBCI.write('c');
      }
      if(nchan == 16){
        serial_openBCI.write('C');
      }
      break;
    case 2: //reset hardware to default registers 
      println("[2] Reseting OpenBCI registers to default... writing \'d\'...");
      serial_openBCI.write("d"); 
      break;
    case 3: //ask for series of channel setting ASCII values to sync with channel setting interface in GUI
      println("[3] Retrieving OpenBCI's channel settings to sync with GUI... writing \'D\'... waiting for $$$...");
      readyToSend = false; //wait for $$$ to iterate... applies to commands expecting a response
      serial_openBCI.write("D"); 
      break;
    case 4: //check existing registers
      println("[4] Retrieving OpenBCI's full register map for verification... writing \'?\'... waiting for $$$...");
      readyToSend = false; //wait for $$$ to iterate... applies to commands expecting a response
      serial_openBCI.write("?"); 
      break;
    case 5:
      // serial_openBCI.write("j"); // send OpenBCI's 'j' commaned to make sure any already open SD file is closed before opening another one...
      switch (sdSetting){
        case 0: //"Do not write to SD"
          //do nothing
          break;
        case 1: //"5 min max"
          serial_openBCI.write("A");
          break;
        case 2: //"5 min max"
          serial_openBCI.write("S");
          break;
        case 3: //"5 min max"
          serial_openBCI.write("F");
          break;
        case 4: //"5 min max"
          serial_openBCI.write("G");
          break;
        case 5: //"5 min max"
          serial_openBCI.write("H");
          break;
        case 6: //"5 min max"
          serial_openBCI.write("J");
          break;
        case 7: //"5 min max"
          serial_openBCI.write("K");
          break;
        case 8: //"5 min max"
          serial_openBCI.write("L");
          break;
      }
      println("[5] Writing selected SD setting (" + sdSettingString + ") to OpenBCI...");
      if(sdSetting != 0){
        readyToSend = false; //wait for $$$ to iterate... applies to commands expecting a response
      }
      break;
    case 6:
      output("The GUI is done intializing. Click outside of the control panel to interact with the GUI.");
      openBCI.changeState(openBCI.STATE_STOPPED);
      systemMode = 10;
      break; 
  }
}

public void haltSystem(){
  println("Halting system for reconfiguration of settings...");
  stopRunning();  //stop data transfer

  //reset variables for data processing
  curDataPacketInd = -1;
  lastReadDataPacketInd = -1;
  pointCounter = 0;
  prevBytes = 0; 
  prevMillis=millis();
  byteRate_perSec = 0;
  drawLoop_counter = 0;
  // eegDataSource = -1;
  //set all data source list items inactive

  // stopDataTransfer(); // make sure to stop data transfer, if data is streaming and being drawn

  if ((eegDataSource == DATASOURCE_NORMAL) || (eegDataSource == DATASOURCE_NORMAL_W_AUX)){
    closeLogFile();  //close log file
    if (serial_openBCI != null){
      println("Closing any open SD file. Writing 'j' to OpenBCI.");
      serial_openBCI.write("j"); // tell the SD file to close if one is open...
      delay(100); //make sure 'j' gets sent to the board
      readyToSend = false;
      openBCI.closeSerialPort();   //disconnect from serial port
      openBCI.prevState_millis = 0;  //reset OpenBCI_ADS1299 state clock to use as a conditional for timing at the beginnign of systemUpdate()
      hardwareSyncStep = 0; //reset Hardware Sync step to be ready to go again...
    }
  }
  systemMode = 0;
}

public void initializeGUI(){

  println("1");
  String filterDescription = eegProcessing.getFilterDescription();
  println("2");
  gui = new Gui_Manager(this, win_x, win_y, nchan, displayTime_sec,default_vertScale_uV,filterDescription, smoothFac[smoothFac_ind]);
  println("3");
  //associate the data to the GUI traces
  gui.initDataTraces(dataBuffX, dataBuffY_filtY_uV, fftBuff, eegProcessing.data_std_uV, is_railed,eegProcessing.polarity);
  println("4");
  //limit how much data is plotted...hopefully to speed things up a little
  gui.setDoNotPlotOutsideXlim(true);
  println("5");
  gui.setDecimateFactor(2);
  println("6");
  // gui.cc.loadDefaultChannelSettings();
  println("7");
}

//======================== DRAW LOOP =============================//
//======================== DRAW LOOP =============================//
//======================== DRAW LOOP =============================//

public void draw() {
  drawLoop_counter++;
  systemUpdate();
  systemDraw();
}

public void systemUpdate(){ // for updating data values and variables

  //has it been 3000 milliseconds since we initiated the serial port? We want to make sure we wait for the OpenBCI board to finish its setup()
  if(millis() - openBCI.prevState_millis > openBCI.COM_INIT_MSEC && openBCI.prevState_millis != 0 && openBCI.state == openBCI.STATE_COMINIT){
    openBCI.state = openBCI.STATE_SYNCWITHHARDWARE;
    timeOfLastCommand = millis();
    serial_openBCI.clear();
    openBCI.defaultChannelSettings = "";
    println("[0] Sending 'v' to OpenBCI to reset hardware in case of 32bit board...");
    serial_openBCI.write('v');
  }

  //if we are in SYNC WITH HARDWARE state ... trigger a command
  if(openBCI.state == openBCI.STATE_SYNCWITHHARDWARE && currentlySyncing == false){
    if(millis() - timeOfLastCommand > 200 && readyToSend == true){
      timeOfLastCommand = millis();
      hardwareSyncStep++;
      syncWithHardware();
    }
  }
  
  win_x = width;
  win_y = height;
  // println(width + ", " + height);
  
  //updates while in intro screen
  if(systemMode == 0){

  }
  
  if(systemMode == 10){
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
        // for(int i = 0; i < eegProcessing.data_std_uV.length; i++){
        //   println("eegProcessing.data_std_uV[" + i + "] = " + eegProcessing.data_std_uV[i]);
        // }
        if((millis() - timeOfGUIreinitialize) > reinitializeGUIdelay){ //wait 1 second for GUI to reinitialize
          // gui.update(eegProcessing.data_std_uV,data_elec_imp_ohm);
          // println("attempting to update GUI...");
          try{
            gui.update(eegProcessing.data_std_uV,data_elec_imp_ohm);
          } catch (Exception e){
            println(e.getMessage());
            reinitializeGUIdelay = reinitializeGUIdelay * 2;
            println("New GUI reinitialize delay = " + reinitializeGUIdelay);
          }
        }
        else{
          println("reinitializing GUI after resize... not updating GUI");
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
      } 
      else {
        //not enough data has arrived yet... only update the channel controller
      }
    }

    gui.cc.update(); //update Channel Controller even when not updating certain parts of the GUI... (this is a bit messy...)
    updateButtons(); //make sure all system buttons are up to date

    //re-initialize GUI if screen has been resized and it's been more than 1/2 seccond (to prevent reinitialization of GUI from happening too often)
    if(screenHasBeenResized == true && (millis() - timeOfLastScreenResize) > reinitializeGUIdelay){
      screenHasBeenResized = false;
      println("reinitializing GUI");
      timeOfGUIreinitialize = millis();
      initializeGUI();
    }

    playground.update();
  }

  controlPanel.update();
}

public void systemDraw(){ //for drawing to the screen
    
  //redraw the screen...not every time, get paced by when data is being plotted    
  background(bgColor);  //clear the screen

  if(systemMode == 10){
    int drawLoopCounter_thresh = 100;
    if ((redrawScreenNow) || (drawLoop_counter >= drawLoopCounter_thresh)) {
      //if (drawLoop_counter >= drawLoopCounter_thresh) println("OpenBCI_GUI: redrawing based on loop counter...");
      drawLoop_counter=0; //reset for next time
      redrawScreenNow = false;  //reset for next time
      
      //update the title of the figure;
      switch (eegDataSource) {
        case DATASOURCE_NORMAL: case DATASOURCE_NORMAL_W_AUX:
          frame.setTitle(PApplet.parseInt(frameRate) + " fps, Byte Count = " + openBCI_byteCount + ", bit rate = " + byteRate_perSec*8 + " bps" + ", " + PApplet.parseInt(PApplet.parseFloat(fileoutput.getRowsWritten())/openBCI.fs_Hz) + " secs Saved, Writing to " + output_fname);
          break;
        case DATASOURCE_SYNTHETIC:
          frame.setTitle(PApplet.parseInt(frameRate) + " fps, Using Synthetic EEG Data");
          break;
        case DATASOURCE_PLAYBACKFILE:
          frame.setTitle(PApplet.parseInt(frameRate) + " fps, Playing " + PApplet.parseInt(PApplet.parseFloat(currentTableRowIndex)/openBCI.fs_Hz) + " of " + PApplet.parseInt(PApplet.parseFloat(playbackData_table.getRowCount())/openBCI.fs_Hz) + " secs, Reading from: " + playbackData_fname);
          break;
      } 
    }

    //wait 1 second for GUI to reinitialize
    if((millis() - timeOfGUIreinitialize) > reinitializeGUIdelay){ 
      // println("attempting to draw GUI...");
      try{
        // println("GUI DRAW!!! " + millis());
        pushStyle();
          fill(255);
          noStroke();
          rect(0, 0, width, navBarHeight);
        popStyle();
        gui.draw(); //draw the GUI
        // playground.draw();
      } catch (Exception e){
        println(e.getMessage());
        reinitializeGUIdelay = reinitializeGUIdelay * 2;
        println("New GUI reinitialize delay = " + reinitializeGUIdelay);
      }
    }
    else{
      //reinitializing GUI after resize
      println("reinitializing GUI after resize... not drawing GUI");
    }

    playground.draw();

  }

  //control panel
  if(controlPanel.isOpen){
    controlPanel.draw();
  }
  controlPanelCollapser.draw();
  helpWidget.draw();

  if((openBCI.state == openBCI.STATE_COMINIT || openBCI.state == openBCI.STATE_SYNCWITHHARDWARE) && systemMode == 0){
    //make out blink the text "Initalizing GUI..."
    if(millis()%1000 < 500){
      output("Iniitializing communication w/ your OpenBCI board...");
    } else{
      output("");
    }

    if(millis() - timeOfInit > 12000){
      haltSystem();
      initSystemButton.but_txt = "START SYSTEM";
      output("Init timeout. Verify your Serial/COM Port. Power DOWN/UP your OpenBCI & USB Dongle. Then retry Initialization.");
    }
  }

  // use commented code below to verify frameRate and check latency
  // println("Time since start: " + millis() + " || Time since last frame: " + str(millis()-timeOfLastFrame));
  // timeOfLastFrame = millis();
}

//called from systemUpdate when mode=10 and isRunning = true
public int getDataIfAvailable(int pointCounter) {
  
  if ( (eegDataSource == DATASOURCE_NORMAL) || (eegDataSource == DATASOURCE_NORMAL_W_AUX) ) {
    //get data from serial port as it streams in

      //first, get the new data (if any is available)
      // openBCI.finalizeCOMINIT(); //this is trying to listen to the openBCI hardware.  New data is put into dataPacketBuff and increments curDataPacketInd.
      
      //next, gather any new data into the "little buffer"
      while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate)) {
        lastReadDataPacketInd = (lastReadDataPacketInd+1) % dataPacketBuff.length;  //increment to read the next packet
        for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
          //scale the data into engineering units ("microvolts") and save to the "little buffer"
          yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan] * openBCI.scale_fac_uVolts_per_count;
        } 
        pointCounter++; //increment counter for "little buffer"
      }
  } else {
    // make or load data to simulate real time
        
    //has enough time passed?
    int current_millis = millis();
    if (current_millis >= nextPlayback_millis) {
      //prepare for next time
      int increment_millis = PApplet.parseInt(round(PApplet.parseFloat(nPointsPerUpdate)*1000.f/openBCI.fs_Hz)/playback_speed_fac);
      if (nextPlayback_millis < 0) nextPlayback_millis = current_millis;
      nextPlayback_millis += increment_millis;

      // generate or read the data
      lastReadDataPacketInd = 0;
      for (int i = 0; i < nPointsPerUpdate; i++) {
        // println();
        dataPacketBuff[lastReadDataPacketInd].sampleIndex++;
        switch (eegDataSource) {
          case DATASOURCE_SYNTHETIC: //use synthetic data (for GUI debugging)   
            synthesizeData(nchan, openBCI.fs_Hz, openBCI.scale_fac_uVolts_per_count, dataPacketBuff[lastReadDataPacketInd]);
            break;
          case DATASOURCE_PLAYBACKFILE: 
            currentTableRowIndex=getPlaybackDataFromTable(playbackData_table,currentTableRowIndex,openBCI.scale_fac_uVolts_per_count, dataPacketBuff[lastReadDataPacketInd]);
            break;
          default:
            //no action
        }
        //gather the data into the "little buffer"
        for (int Ichan=0; Ichan < nchan; Ichan++) {
          //scale the data into engineering units..."microvolts"
          yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan]* openBCI.scale_fac_uVolts_per_count;
        }
        pointCounter++;
      } //close the loop over data points
      //if (eegDataSource==DATASOURCE_PLAYBACKFILE) println("OpenBCI_GUI: getDataIfAvailable: currentTableRowIndex = " + currentTableRowIndex);
      //println("OpenBCI_GUI: getDataIfAvailable: pointCounter = " + pointCounter);
    } // close "has enough time passed"
  } 
  return pointCounter;
}

public void processNewData() {

  byteRate_perSec = (int)(1000.f * ((float)(openBCI_byteCount - prevBytes)) / ((float)(millis() - prevMillis)));
  prevBytes = openBCI_byteCount; 
  prevMillis=millis();
  float foo_val;
  float prevFFTdata[] = new float[fftBuff[0].specSize()];
  double foo;

  //update the data buffers
  for (int Ichan=0;Ichan < nchan; Ichan++) {
    //append the new data to the larger data buffer...because we want the plotting routines
    //to show more than just the most recent chunk of data.  This will be our "raw" data.
    appendAndShift(dataBuffY_uV[Ichan], yLittleBuff_uV[Ichan]);
    
    //make a copy of the data that we'll apply processing to.  This will be what is displayed on the full montage
    dataBuffY_filtY_uV[Ichan] = dataBuffY_uV[Ichan].clone();
  }
    
  //if you want to, re-reference the montage to make it be a mean-head reference
  if (false) rereferenceTheMontage(dataBuffY_filtY_uV);
  
  //update the FFT (frequency spectrum)
  for (int Ichan=0;Ichan < nchan; Ichan++) {  

    //copy the previous FFT data...enables us to apply some smoothing to the FFT data
    for (int I=0; I < fftBuff[Ichan].specSize(); I++) prevFFTdata[I] = fftBuff[Ichan].getBand(I); //copy the old spectrum values
    
    //prepare the data for the new FFT
    float[] fooData_raw = dataBuffY_uV[Ichan];  //use the raw data for the FFT
    fooData_raw = Arrays.copyOfRange(fooData_raw, fooData_raw.length-Nfft, fooData_raw.length);   //trim to grab just the most recent block of data
    float meanData = mean(fooData_raw);  //compute the mean
    for (int I=0; I < fooData_raw.length; I++) fooData_raw[I] -= meanData; //remove the mean (for a better looking FFT
    
    //compute the FFT
    fftBuff[Ichan].forward(fooData_raw); //compute FFT on this channel of data
    
    
    
//    //convert units on fft data
//    if (false) {
//      //convert units to uV_per_sqrtHz...is this still correct?? CHIP 2014-10-24
//      //final float mean_winpow_sqr = 0.3966;  //account for power lost when windowing...mean(hamming(N).^2) = 0.3966
//      final float mean_winpow = 1.0f/sqrt(2.0f);  //account for power lost when windowing...mean(hamming(N).^2) = 0.3966
//      final float scale_raw_to_rtHz = pow((float)fftBuff[0].specSize(),1)*fs_Hz*mean_winpow; //normalize the amplitude by the number of bins to get the correct scaling to uV/sqrt(Hz)???
//      double foo;
//      for (int I=0; I < fftBuff[Ichan].specSize(); I++) {  //loop over each FFT bin
//        foo = sqrt(pow(fftBuff[Ichan].getBand(I),2)/scale_raw_to_rtHz);
//        fftBuff[Ichan].setBand(I,(float)foo);
//        //if ((Ichan==0) & (I > 5) & (I < 15)) println("processFreqDomain: uV/rtHz = " + I + " " + foo);
//      }
//    } else {
      //convert to uV_per_bin...still need to confirm the accuracy of this code.  
      //Do we need to account for the power lost in the windowing function?   CHIP  2014-10-24
        for (int I=0; I < fftBuff[Ichan].specSize(); I++) {  //loop over each FFT bin
          fftBuff[Ichan].setBand(I,(float)(fftBuff[Ichan].getBand(I) / fftBuff[Ichan].specSize()));
        }       
//    }
    
    //average the FFT with previous FFT data so that it makes it smoother in time
    double min_val = 0.01d;
    for (int I=0; I < fftBuff[Ichan].specSize(); I++) {   //loop over each fft bin
      if (prevFFTdata[I] < min_val) prevFFTdata[I] = (float)min_val; //make sure we're not too small for the log calls
      foo = fftBuff[Ichan].getBand(I); if (foo < min_val) foo = min_val; //make sure this value isn't too small
      
       if (true) {
        //smooth in dB power space
        foo =   (1.0d-smoothFac[smoothFac_ind]) * java.lang.Math.log(java.lang.Math.pow(foo,2));
        foo += smoothFac[smoothFac_ind] * java.lang.Math.log(java.lang.Math.pow((double)prevFFTdata[I],2)); 
        foo = java.lang.Math.sqrt(java.lang.Math.exp(foo)); //average in dB space
      } else { 
        //smooth (average) in linear power space
        foo =   (1.0d-smoothFac[smoothFac_ind]) * java.lang.Math.pow(foo,2);
        foo+= smoothFac[smoothFac_ind] * java.lang.Math.pow((double)prevFFTdata[I],2); 
        // take sqrt to be back into uV_rtHz
        foo = java.lang.Math.sqrt(foo);
      }
      fftBuff[Ichan].setBand(I,(float)foo); //put the smoothed data back into the fftBuff data holder for use by everyone else
    } //end loop over FFT bins
  } //end the loop over channels.
  
  //apply additional processing for the time-domain montage plot (ie, filtering)
  eegProcessing.process(yLittleBuff_uV,dataBuffY_uV,dataBuffY_filtY_uV,fftBuff);
  
  //apply user processing
  // ...yLittleBuff_uV[Ichan] is the most recent raw data since the last call to this processing routine
  // ...dataBuffY_filtY_uV[Ichan] is the full set of filtered data as shown in the time-domain plot in the GUI
  // ...fftBuff[Ichan] is the FFT data structure holding the frequency spectrum as shown in the freq-domain plot in the GUI
  eegProcessing_user.process(yLittleBuff_uV,dataBuffY_uV,dataBuffY_filtY_uV,fftBuff);
  
  //look to see if the latest data is railed so that we can notify the user on the GUI
  for (int Ichan=0;Ichan < nchan; Ichan++) is_railed[Ichan].update(dataPacketBuff[lastReadDataPacketInd].values[Ichan]);

  //compute the electrode impedance. Do it in a very simple way [rms to amplitude, then uVolt to Volt, then Volt/Amp to Ohm]
  for (int Ichan=0;Ichan < nchan; Ichan++) data_elec_imp_ohm[Ichan] = (sqrt(2.0f)*eegProcessing.data_std_uV[Ichan]*1.0e-6f) / openBCI.leadOffDrive_amps;     
}

//here is the routine that listens to the serial port.
//if any data is waiting, get it, parse it, and stuff it into our vector of 
//pre-allocated dataPacketBuff
public void serialEvent(Serial port) {
  //check to see which serial port it is
  // if (port == openBCI.serial_openBCI) {
  // println("SE " + millis());
  if (port == serial_openBCI) {
    // boolean echoBytes = !openBCI.isStateNormal(); 
    boolean echoBytes;

    if(openBCI.isStateNormal() != true){  // || printingRegisters == true){
      echoBytes = true;
    } else{
      echoBytes = false;
    }

    // openBCI.read(true);
    openBCI.read(echoBytes);
    openBCI_byteCount++;
    if (openBCI.isNewDataPacketAvailable) {
      //copy packet into buffer of data packets
      curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length; //this is also used to let the rest of the code that it may be time to do something
      openBCI.copyDataPacketTo(dataPacketBuff[curDataPacketInd]);  //resets isNewDataPacketAvailable to false
      
      // //write this chunk of data to file
      // println("-------------------------------------------------------------------------");
      // println("New Packet Available [" + tempCounter + "]");
      // println("dataPacketBuff[curDataPacketInd] = " + dataPacketBuff[curDataPacketInd]);
      // println("openBCI.scale_fac_uVolts_per_count = " + openBCI.scale_fac_uVolts_per_count);
      // println("nchan = " + nchan);
      newPacketCounter++;

      fileoutput.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd],openBCI.scale_fac_uVolts_per_count,openBCI.scale_fac_accel_G_per_count);
    }
  } 
  else {
    inByte = port.read();
  }
}

public String getDateString() {
    String fname = year() + "-";
    if (month() < 10) fname=fname+"0";
    fname = fname + month() + "-";
    if (day() < 10) fname = fname + "0";
    fname = fname + day(); 
    
    fname = fname + "_";
    if (hour() < 10) fname = fname + "0";
    fname = fname + hour() + "-";
    if (minute() < 10) fname = fname + "0";
    fname = fname + minute() + "-";
    if (second() < 10) fname = fname + "0";
    fname = fname + second();
    return fname;
}
  
//swtich yard if a click is detected
public void mousePressed() {

  verbosePrint("mousePressed");
  
  //if not in initial setup...
  if(systemMode >= 10){

    //limit interactivity of main GUI if control panel is open
    if(controlPanel.isOpen == false){
      //was the stopButton pressed?

      gui.mousePressed(); // trigger mousePressed function in GUI
      //most of the logic below should be migrated into the Gui_manager specific function above

      if (gui.stopButton.isMouseHere()) { 
        gui.stopButton.setIsActive(true);
        stopButtonWasPressed(); 
      }
      
      // //was the gui page button pressed?
      // if (gui.guiPageButton.isMouseHere()) {
      //   gui.guiPageButton.setIsActive(true);
      //   gui.incrementGUIpage();
      // }

      //check the buttons
      switch (gui.guiPage) {
        case Gui_Manager.GUI_PAGE_CHANNEL_ONOFF:
          //check the channel buttons
          for (int Ibut = 0; Ibut < gui.chanButtons.length; Ibut++) {
            if (gui.chanButtons[Ibut].isMouseHere()) { 
              toggleChannelState(Ibut);
            }
          }

          //check the detection button
          //if (gui.detectButton.updateIsMouseHere()) toggleDetectionState();      
          //check spectrogram button
          //if (gui.spectrogramButton.updateIsMouseHere()) toggleSpectrogramState();
          
          break;
        case Gui_Manager.GUI_PAGE_IMPEDANCE_CHECK:
          // ============ DEPRECATED ============== //
          // //check the impedance buttons
          // for (int Ibut = 0; Ibut < gui.impedanceButtonsP.length; Ibut++) {
          //   if (gui.impedanceButtonsP[Ibut].isMouseHere()) { 
          //     toggleChannelImpedanceState(gui.impedanceButtonsP[Ibut],Ibut,0);
          //   }
          //   if (gui.impedanceButtonsN[Ibut].isMouseHere()) { 
          //     toggleChannelImpedanceState(gui.impedanceButtonsN[Ibut],Ibut,1);
          //   }
          // }
          // if (gui.biasButton.isMouseHere()) { 
          //   gui.biasButton.setIsActive(true);
          //   setBiasState(!openBCI.isBiasAuto);
          // }      
          // break;
        case Gui_Manager.GUI_PAGE_HEADPLOT_SETUP:
          if (gui.intensityFactorButton.isMouseHere()) {
            gui.intensityFactorButton.setIsActive(true);
            gui.incrementVertScaleFactor();
          }
          if (gui.loglinPlotButton.isMouseHere()) {
            gui.loglinPlotButton.setIsActive(true);
            gui.set_vertScaleAsLog(!gui.vertScaleAsLog); //toggle the state
          }
          if (gui.filtBPButton.isMouseHere()) {
            gui.filtBPButton.setIsActive(true);
            incrementFilterConfiguration();
          }
          if (gui.smoothingButton.isMouseHere()) {
            gui.smoothingButton.setIsActive(true);
            incrementSmoothing();
          }
          if (gui.showPolarityButton.isMouseHere()) {
            gui.showPolarityButton.setIsActive(true);
            toggleShowPolarity();
          }
          if (gui.maxDisplayFreqButton.isMouseHere()) {
            gui.maxDisplayFreqButton.setIsActive(true);
            gui.incrementMaxDisplayFreq();
          }
          
    //      //check the detection button
    //      if (gui.detectButton.updateIsMouseHere()) {
    //       gui.detectButton.setIsActive(true);
    //       toggleDetectionState();
    //      }      
    //      //check spectrogram button
    //      if (gui.spectrogramButton.updateIsMouseHere()) {
    //        gui.spectrogramButton.setIsActive(true);
    //        toggleSpectrogramState();
    //      }

          break;
        //default:
      }
      
      //check the graphs
      if (gui.isMouseOnFFT(mouseX,mouseY)) {
        GraphDataPoint dataPoint = new GraphDataPoint();
        gui.getFFTdataPoint(mouseX,mouseY,dataPoint);
        println("OpenBCI_GUI: FFT data point: " + String.format("%4.2f",dataPoint.x) + " " + dataPoint.x_units + ", " + String.format("%4.2f",dataPoint.y) + " " + dataPoint.y_units);
      } else if (gui.headPlot1.isPixelInsideHead(mouseX,mouseY)) {
        //toggle the head plot contours
        gui.headPlot1.drawHeadAsContours = !gui.headPlot1.drawHeadAsContours;
      } else if (gui.isMouseOnMontage(mouseX,mouseY)) {
        //toggle the display of the montage values
        gui.showMontageValues  = !gui.showMontageValues;
      }


    }

    
  }

  //=============================//
  // CONTROL PANEL INTERACTIVITY //
  //=============================//

  //was control panel button pushed
  if (controlPanelCollapser.isMouseHere()) {
    if(controlPanelCollapser.isActive && systemMode == 10){
      controlPanelCollapser.setIsActive(false);
      controlPanel.isOpen = false;
    }
    else{
      controlPanelCollapser.setIsActive(true);
      controlPanel.isOpen = true;
    }
  } else{
    if(controlPanel.isOpen){
      controlPanel.CPmousePressed();
    }
  }

  //interacting with control panel
  if(controlPanel.isOpen){
    //close control panel if you click outside...
    if(systemMode == 10){
      if(mouseX > 0 && mouseX < controlPanel.w && mouseY > 0 && mouseY < controlPanel.initBox.y+controlPanel.initBox.h){
        println("clicked in CP box");
        controlPanel.CPmousePressed();
      }
      //if clicked out of panel
      else{
        println("outside of CP clicked");
        controlPanel.isOpen = false;
        controlPanelCollapser.setIsActive(false);
        output("Press the \"Press to Start\" button to initialize the data stream.");
      }
    }
  }

  redrawScreenNow = true;  //command a redraw of the GUI whenever the mouse is pressed

  if(playground.isMouseHere()){
    playground.mousePressed();
  }

  if(playground.isMouseInButton()){
    playground.toggleWindow();
  }
}

public void mouseReleased() {

  verbosePrint("mouseReleased");

  //some buttons light up only when being actively pressed.  Now that we've
  //released the mouse button, turn off those buttons.

  //interacting with control panel
  if(controlPanel.isOpen){
    //if clicked in panel
    controlPanel.CPmouseReleased();
  }

  if(systemMode >= 10){

    gui.mouseReleased();
    redrawScreenNow = true;  //command a redraw of the GUI whenever the mouse is released
  }

  if(screenHasBeenResized){
    println("screen has been resized...");
    screenHasBeenResized = false;
  }

  //Playground Interactivity
  if(playground.isMouseHere()){
    playground.mouseReleased();
  }
  if(playground.isMouseInButton()){
    // playground.toggleWindow();
  }
}

public void printRegisters(){
  if (serial_openBCI != null) {
    println("Writing ? to OpenBCI...");
    serial_openBCI.write('?');
  }
  // printingRegisters = true;
}

public void stopRunning() {
    // openBCI.changeState(0); //make sure it's no longer interpretting as binary
    verbosePrint("stopRunning...");
    output("Data stream stopped.");
    if (openBCI != null) {
      openBCI.stopDataTransfer();
    }
    timeSinceStopRunning = millis(); //used as a timer to prevent misc. bytes from flooding serial...
    isRunning = false;
    // openBCI.changeState(0); //make sure it's no longer interpretting as binary
    // systemMode = 0;
    // closeLogFile();
}

public void startRunning() {
    verbosePrint("startRunning...");
    output("Data stream started.");
    if ((eegDataSource == DATASOURCE_NORMAL) || (eegDataSource == DATASOURCE_NORMAL_W_AUX)) {
      if (openBCI != null) openBCI.startDataTransfer();
    }
    isRunning = true;
}

//execute this function whenver the stop button is pressed
public void stopButtonWasPressed() {
  //toggle the data transfer state of the ADS1299...stop it or start it...
  if (isRunning) {
    println("openBCI_GUI: stopButton was pressed...stopping data transfer...");
    stopRunning();
  } 
  else { //not running
    println("openBCI_GUI: startButton was pressed...starting data transfer...");
    startRunning();
    nextPlayback_millis = millis();  //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.
  }
}

public void updateButtons(){
  //update the stop button with new text based on the current running state
  //gui.stopButton.setActive(isRunning);
  if (isRunning) {
    //println("OpenBCI_GUI: stopButtonWasPressed (a): changing string to " + Gui_Manager.stopButton_pressToStop_txt);
    gui.stopButton.setString(Gui_Manager.stopButton_pressToStop_txt); 
    gui.stopButton.setColorNotPressed(color(224, 56, 45));
  } 
  else {
    //println("OpenBCI_GUI: stopButtonWasPressed (a): changing string to " + Gui_Manager.stopButton_pressToStart_txt);
    gui.stopButton.setString(Gui_Manager.stopButton_pressToStart_txt);
    gui.stopButton.setColorNotPressed(color(184,220,105));
  }
}

final float sine_freq_Hz = 10.0f;
float sine_phase_rad = 0.0f;
public void synthesizeData(int nchan, float fs_Hz, float scale_fac_uVolts_per_count, DataPacket_ADS1299 curDataPacket) {
  float val_uV;
  for (int Ichan=0; Ichan < nchan; Ichan++) {
    if (isChannelActive(Ichan)) { 
      val_uV = randomGaussian()*sqrt(fs_Hz/2.0f); // ensures that it has amplitude of one unit per sqrt(Hz) of signal bandwidth
      //val_uV = random(1)*sqrt(fs_Hz/2.0f); // ensures that it has amplitude of one unit per sqrt(Hz) of signal bandwidth
      if (Ichan==0) val_uV*= 10f;  //scale one channel higher
      
      if (Ichan==1) {
        //add sine wave at 10 Hz at 10 uVrms
        sine_phase_rad += 2.0f*PI * sine_freq_Hz / fs_Hz;
        if (sine_phase_rad > 2.0f*PI) sine_phase_rad -= 2.0f*PI;
        val_uV += 10.0f * sqrt(2.0f)*sin(sine_phase_rad);
      }
    } 
    else {
      val_uV = 0.0f;
    }
    curDataPacket.values[Ichan] = (int) (0.5f+ val_uV / scale_fac_uVolts_per_count); //convert to counts, the 0.5 is to ensure rounding
  }
}

public int getPlaybackDataFromTable(Table datatable, int currentTableRowIndex, float scale_fac_uVolts_per_count, DataPacket_ADS1299 curDataPacket) {
  float val_uV = 0.0f;
  
  //check to see if we can load a value from the table
  if (currentTableRowIndex >= datatable.getRowCount()) {
    //end of file
    println("OpenBCI_GUI: hit the end of the playback data file.  starting over...");
    //if (isRunning) stopRunning();
    currentTableRowIndex = 0;
  } else {
    //get the row
    TableRow row = datatable.getRow(currentTableRowIndex);
    currentTableRowIndex++; //increment to the next row
    
    //get each value
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      if (isChannelActive(Ichan) && (Ichan < datatable.getColumnCount())) {
        val_uV = row.getFloat(Ichan);
      } else {
        //use zeros for the missing channels
        val_uV = 0.0f;
      }

      //put into data structure
      curDataPacket.values[Ichan] = (int) (0.5f+ val_uV / scale_fac_uVolts_per_count); //convert to counts, the 0.5 is to ensure rounding
    }
  }
  return currentTableRowIndex;
}

//toggleChannelState: : Ichan is [0 nchan-1]
public void toggleChannelState(int Ichan) {
  if ((Ichan >= 0) && (Ichan < gui.chanButtons.length)) {
    if (isChannelActive(Ichan)) {
      deactivateChannel(Ichan);      
    } 
    else {
      activateChannel(Ichan);
    }
  }
}

//Ichan is zero referenced (not one referenced)
public boolean isChannelActive(int Ichan) {
  boolean return_val = false;
  
  //account for 16 channel case...because the channel 9-16 (aka 8-15) are coupled to channels 1-8 (aka 0-7)
  // if ((Ichan > 7) && (OpenBCI_Nchannels > 8)) Ichan = Ichan - 8;
  if ((Ichan > 7) && (nchan > 8)) Ichan = Ichan - 8;

    
  //now check the state of the corresponding channel button
  if ((Ichan >= 0) && (Ichan < gui.chanButtons.length)) {
    boolean button_is_pressed = gui.chanButtons[Ichan].isActive();
    if (button_is_pressed) { //button is pressed, which means the channel was NOT active
      return_val = false;
    } else { //button is not pressed, so channel is active
      return_val = true;
    }
  }
  return return_val;
}

//activateChannel: Ichan is [0 nchan-1] (aka zero referenced)
public void activateChannel(int Ichan) {
  println("OpenBCI_GUI: activating channel " + (Ichan+1));
  if(eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX){
    if (serial_openBCI != null){
      verbosePrint("**");
      openBCI.changeChannelState(Ichan, true); //activate
    }
  }
  if (Ichan < gui.chanButtons.length){
    gui.chanButtons[Ichan].setIsActive(false); //an active channel is a light-colored NOT-ACTIVE button
    channelSettingValues[Ichan][0] = '0'; 
    gui.cc.update();
  }
}  
public void deactivateChannel(int Ichan) {
  println("OpenBCI_GUI: deactivating channel " + (Ichan+1));
  if(eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX){
    if (serial_openBCI != null) {
      verbosePrint("***");
      openBCI.changeChannelState(Ichan, false); //de-activate
    }
  }
  if (Ichan < gui.chanButtons.length) {
    gui.chanButtons[Ichan].setIsActive(true); //a deactivated channel is a dark-colored ACTIVE button
    channelSettingValues[Ichan][0] = '1'; 
    gui.cc.update();
  }
}

//void toggleDetectionState() {
//  gui.detectButton.setIsActive(!gui.detectButton.isActive());
//  showFFTFilteringData = gui.detectButton.isActive();
//  gui.showFFTFilteringData(showFFTFilteringData);
//}
//
//void toggleSpectrogramState() {
//  gui.spectrogramButton.setIsActive(!gui.spectrogramButton.isActive());
//  gui.setShowSpectrogram(gui.spectrogramButton.isActive());
//



// void toggleChannelImpedanceState(Button but, int Ichan, int code_P_N_Both) {
//   boolean newstate = false;
//   println("OpenBCI_GUI: toggleChannelImpedanceState: Ichan " + Ichan + ", code_P_N_Both " + code_P_N_Both);
//   if ((Ichan >= 0) && (Ichan < gui.impedanceButtonsP.length)) {

//     //find what state we were, because that sets what state we need
//     newstate = !(but.isActive()); //toggle the state

//     //set the desired impedance state
//     setChannelImpedanceState(Ichan,newstate,code_P_N_Both);
//   }
// }


// ========= DEPRECATED =========== //
// void setChannelImpedanceState(int Ichan,boolean newstate,int code_P_N_Both) {
//   if ((Ichan >= 0) && (Ichan < gui.impedanceButtonsP.length)) {
//     //change the state of the OpenBCI channel itself
//     if (openBCI != null) openBCI.changeImpedanceState(Ichan,newstate,code_P_N_Both);
    
//     //now update the button state
//     if ((code_P_N_Both == 0) || (code_P_N_Both == 2)) {
//       //set the P channel
//       gui.impedanceButtonsP[Ichan].setIsActive(newstate);
//     } else if ((code_P_N_Both == 1) || (code_P_N_Both == 2)) {
//       //set the N channel
//       gui.impedanceButtonsN[Ichan].setIsActive(newstate);
//     }
//   }
// }


//=========== DEPRECATED w/ CHANNEL CONTROLLER ===========//
// void setBiasState(boolean state) {
//   openBCI.isBiasAuto = state;
  
//   //send message to openBCI
//   if (openBCI != null) openBCI.setBiasAutoState(state);
  
//   //change button text
//   if (openBCI.isBiasAuto) {
//     gui.biasButton.but_txt = "Bias\nAuto";
//   } else {
//     gui.biasButton.but_txt = "Bias\nFixed";
//   }
// }

public void openNewLogFile(String _fileName) {
  //close the file if it's open
  if (fileoutput != null) {
    println("OpenBCI_GUI: closing log file");
    closeLogFile();
  }
  
  //open the new file
  fileoutput = new OutputFile_rawtxt(openBCI.fs_Hz, _fileName);
  output_fname = fileoutput.fname;
  println("openBCI: openNewLogFile: opened output file: " + output_fname);
  output("openBCI: openNewLogFile: opened output file: " + output_fname);
}

public void closeLogFile() {
  if (fileoutput != null) fileoutput.closeFile();
}

public void incrementFilterConfiguration() {
  eegProcessing.incrementFilterConfiguration();
  
  //update the button strings
//  gui.filtBPButton.but_txt = "BP Filt\n" + filtCoeff_bp[currentFilt_ind].short_name;
//  gui.titleMontage.string = "EEG Data (" + filtCoeff_bp[currentFilt_ind].name + ", " + filtCoeff_notch[currentFilt_ind].name + ")"; 
  gui.filtBPButton.but_txt = "BP Filt\n" + eegProcessing.getShortFilterDescription();
  gui.titleMontage.string = "EEG Data (" + eegProcessing.getFilterDescription() + ")"; 
  
}
  
public void incrementSmoothing() {
  smoothFac_ind++;
  if (smoothFac_ind >= N_SMOOTHEFAC) smoothFac_ind = 0;
  
  //tell the GUI
  gui.setSmoothFac(smoothFac[smoothFac_ind]);
  
  //update the button
  gui.smoothingButton.but_txt = "Smooth\n" + smoothFac[smoothFac_ind];
}

public void toggleShowPolarity() {
  gui.headPlot1.use_polarity = !gui.headPlot1.use_polarity;
  
  //update the button
  gui.showPolarityButton.but_txt = "Show Polarity\n" + gui.headPlot1.getUsePolarityTrueFalse();
}

public void fileSelected(File selection) {  //called by the Open File dialog box after a file has been selected
  if (selection == null) {
    println("no selection so far...");
  } else {
    //inputFile = selection;
    playbackData_fname = selection.getAbsolutePath();
  }
}

public void verbosePrint(String _string){
  if(isVerbose){
    println(_string);
  }
}

public void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}

// here's a function to catch whenever the window is being closed, so that
// it stops OpenBCI
// from: http://forum.processing.org/one/topic/run-code-on-exit.html

// must add "prepareExitHandler();" in setup() for Processing sketches 
// private void prepareExitHandler () {
//  Runtime.getRuntime().addShutdownHook(
//    new Thread(new Runnable() {
//        public void run () {
//          //System.out.println("SHUTDOWN HOOK");
//          println("OpenBCI_GUI: executing shutdown code...");
//          try {
//            stopRunning();
//            if (openBCI != null) {
//              openBCI.closeSerialPort();
//            }
//            stop();
//          } catch (Exception ex) {
//            ex.printStackTrace(); // not much else to do at this point
//          }
//        }
//      }
//    )
//  );
// }  



////////////////////
//
// This class creates and manages a button for use on the screen to trigger actions.
//
// Created: Chip Audette, Oct 2013.
// Modified: Conor Russomanno, Oct 2014
// 
// Based on Processing's "Button" example code
//
////////////////////

class Button {
  
  int but_x, but_y, but_dx, but_dy;      // Position of square button
  //int rectSize = 90;     // Diameter of rect
  int color_pressed = color(200);
  int color_highlight = color(102);
  int color_notPressed = color(255);
  int buttonStrokeColor = bgColor;
  int textColorActive = color(255);
  int textColorNotActive = bgColor;
  int rectHighlight;
  //boolean isMouseHere = false;
  boolean buttonHasStroke = true;
  boolean isActive = false;
  boolean isDropdownButton = false;
  boolean drawHand = false;
  boolean wasPressed = false;
  public String but_txt;
  PFont buttonFont = f2;

  public Button(int x, int y, int w, int h, String txt, int fontSize) {
    setup(x, y, w, h, txt);
    //println(PFont.list()); //see which fonts are available
    //font = createFont("SansSerif.plain",fontSize);
    //font = createFont("Lucida Sans Regular",fontSize);
    // font = createFont("Arial",fontSize);
    //font = loadFont("SansSerif.plain.vlw");
  }

  public void setup(int x, int y, int w, int h, String txt) {
    but_x = x;
    but_y = y;
    but_dx = w;
    but_dy = h;
    setString(txt);
  }
  
  public void setString(String txt) {
    but_txt = txt;
    //println("Button: setString: string = " + txt);
  }
  
  public boolean isActive() {
    return isActive;
  }
  
  public void setIsActive(boolean val) {
    isActive = val;
  }

  public void makeDropdownButton(boolean val){
    isDropdownButton = val;
  }
  
  public boolean isMouseHere() {
    if ( overRect(but_x, but_y, but_dx, but_dy) ) {
      // cursor(HAND);
      return true;
    } 
    else {
      return false;
    }
  }

  public int getColor() {
    if (isActive) {
      return color_pressed;
    } else {    
      return color_notPressed;
    }
  }

  public void setColorPressed(int _color){
    color_pressed = _color;
  }
  public void setColorNotPressed(int _color){
    color_notPressed = _color;
  }

  public void setStrokeColor(int _color){
    buttonStrokeColor = _color;
  }

  public void hasStroke(boolean _trueORfalse){
    buttonHasStroke = _trueORfalse;
  }

  public boolean overRect(int x, int y, int width, int height) {
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
      return true;
    } 
    else {
      return false;
    }
  }

  public void draw(int _x, int _y){
    but_x = _x;
    but_y = _y;
    draw();
  }

  public void draw() {
    //draw the button
    fill(getColor());
    if(buttonHasStroke){
      stroke(buttonStrokeColor); //button border
    }else{
      noStroke();
    }
    // noStroke();
    rect(but_x,but_y,but_dx,but_dy);
    
    //draw the text
    if(isActive){
      fill(textColorActive);
    }else{
      fill(textColorNotActive);
    }
    stroke(255);
    textFont(buttonFont);  //load f2 ... from control panel 
    textSize(12);
    textAlign(CENTER, CENTER);
    textLeading(round(0.9f*(textAscent()+textDescent())));
//    int x1 = but_x+but_dx/2;
//    int y1 = but_y+but_dy/2;
    int x1, y1;
    if (false) {
      //auto wrap
      x1 = but_x;
      y1 = but_y;
      int w = but_dx-2*2; //use a 2 pixel buffer on the left and right sides 
      int h = but_dy;
      text(but_txt,x1,y1,w,h);
    } else {
      //no auto wrap
      x1 = but_x+but_dx/2;
      y1 = but_y+but_dy/2;
      text(but_txt,x1,y1);
    }

    //draw open/close arrow if it's a dropdown button
    if(isDropdownButton){
      pushStyle();
        fill(255);
        noStroke();
        // smooth();
        // stroke(255);
        // strokeWeight(1);
        if(isActive){
          float point1x = but_x + (but_dx - ((3f*but_dy)/4f));
          float point1y = but_y + but_dy/3f;
          float point2x = but_x + (but_dx-(but_dy/4f));
          float point2y = but_y + but_dy/3f;
          float point3x = but_x + (but_dx - (but_dy/2f));
          float point3y = but_y + (2f*but_dy)/3f;
          triangle(point1x, point1y, point2x, point2y, point3x, point3y); //downward triangle, indicating open
        } else{
          float point1x = but_x + (but_dx - ((3f*but_dy)/4f));
          float point1y = but_y + (2f*but_dy)/3f;
          float point2x = but_x + (but_dx-(but_dy/4f));
          float point2y = but_y + (2f*but_dy)/3f;
          float point3x = but_x + (but_dx - (but_dy/2f));
          float point3y = but_y + but_dy/3f;
          triangle(point1x, point1y, point2x, point2y, point3x, point3y); //upward triangle, indicating closed
        }
      popStyle();
    }

    if(systemMode == 0){
      if(!isMouseHere() && drawHand){
        cursor(ARROW);
        drawHand = false;
        verbosePrint("don't draw hand");
      }
      //if cursor is over button change cursor icon to hand!
      if(isMouseHere() && !drawHand){
        cursor(HAND);
        drawHand = true;
        verbosePrint("draw hand");
      } 
    }
  }
};





//these arrays of channel values need to be global so that they don't reset on screen resize, when GUI reinitializes (there's definitely a more efficient way to do this...)
int numSettingsPerChannel = 6; //each channel has 6 different settings
char[][] channelSettingValues = new char [nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button
char[][] impedanceCheckValues = new char [nchan][2];

// color[] channelColors = new color[16];
int[] channelColors = {
	color(129, 113, 87), 
	color(124, 75, 141), 
	color(54, 87, 158), 
	color(49, 113, 89),
	color(221, 178, 13),
	color(253, 94, 52),
	color(224, 56, 45),
	color(162, 82, 49)
};

class ChannelController {

	public float x1, y1, w1, h1, x2, y2, w2, h2; //all 1 values refer to the left panel that is always visible ... al 2 values refer to the right panel that is only visible when showFullController = true
	public int montage_w, montage_h;
	public int rowHeight;
	public int buttonSpacing;
	boolean showFullController = false;
	boolean[] drawImpedanceValues = new boolean [nchan];

	int spacer1 = 3;
	int spacer2 = 5; //space between buttons

	// [Number of Channels] x 6 array of buttons for channel settings
	Button[][] channelSettingButtons = new Button [nchan][numSettingsPerChannel];  // [channel#][Button#]
	// char[][] channelSettingValues = new char [nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button

	//buttons just to the left of 
	Button[][] impedanceCheckButtons = new Button [nchan][2];
	// char [][] impedanceCheckValues = new char [nchan][2];

	// Array for storing SRB2 history settings of channels prior to shutting off .. so you can return to previous state when reactivating channel
	char[] previousSRB2 = new char [nchan];
	// Array for storing SRB2 history settings of channels prior to shutting off .. so you can return to previous state when reactivating channel
	char[] previousBIAS = new char [nchan];

	//maximum different values for the different settings (Power Down, Gain, Input Type, BIAS, SRB2, SRB1) of 
	//refer to page 44 of ADS1299 Datasheet: http://www.ti.com/lit/ds/symlink/ads1299.pdf
	char[] maxValuesPerSetting = {
		'1', // Power Down :: (0)ON, (1)OFF
		'6', // Gain :: (0) x1, (1) x2, (2) x4, (3) x6, (4) x8, (5) x12, (6) x24 ... default
		'7', // Channel Input :: (0)Normal Electrode Input, (1)Input Shorted, (2)Used in conjunction with BIAS_MEAS, (3)MVDD for supply measurement, (4)Temperature Sensor, (5)Test Signal, (6)BIAS_DRP ... positive electrode is driver, (7)BIAS_DRN ... negative electrode is driver
		'1', // BIAS :: (0) Yes, (1) No
		'1', // SRB2 :: (0) Open, (1) Closed
		'1'}; // SRB1 :: (0) Yes, (1) No ... this setting affects all channels ... either all on or all off

	//variables used for channel write timing in writeChannelSettings()
	long timeOfLastChannelWrite = 0;
	int channelToWrite = -1;
	int channelWriteCounter = 0;
	boolean isWritingChannel = false;

	//variables use for imp write timing with writeImpedanceSettings()
	long timeOfLastImpWrite = 0;
	int impChannelToWrite = -1;
	int impWriteCounter = 0;
	boolean isWritingImp = false;

	boolean rewriteChannelWhenDoneWriting = false;
	int channelToWriteWhenDoneWriting = 0;

	boolean rewriteImpedanceWhenDoneWriting = false;
	int impChannelToWriteWhenDoneWriting = 0;
	char final_pORn = '0';
	char final_onORoff = '0';

	ChannelController(float _xPos, float _yPos, float _width, float _height, float _montage_w, float _montage_h){
		//positioning values for left panel (that is always visible)
		x1 = _xPos;
		y1 = _yPos;
		w1 = _width;
		h1 = _height;

		//positioning values for right panel that is only visible when showFullController = true (behind the graph)
		x2 = x1 + w1;
		// x2 = gui.showMontageButton.but_x;
		y2 = y1;
		w2 = _montage_w;
		h2 = h1;

		createChannelSettingButtons();

		// set on/off buttons to default channel colors
		for(int i = 0; i < nchan; i++){
			channelSettingButtons[i][0].setColorNotPressed(channelColors[i%8]);
		}
	}

	public void loadDefaultChannelSettings(){
		verbosePrint("loading default channel settings to GUI's channel controller...");
		for(int i = 0; i < nchan; i++){
			for(int j = 0; j < numSettingsPerChannel; j++){ //channel setting values
				channelSettingValues[i][j] = PApplet.parseChar(openBCI.defaultChannelSettings.toCharArray()[j]); //parse defaultChannelSettings string created in the OpenBCI_ADS1299 class
				if(j == numSettingsPerChannel - 1){
					println(PApplet.parseChar(openBCI.defaultChannelSettings.toCharArray()[j]));
				} else{
					print(PApplet.parseChar(openBCI.defaultChannelSettings.toCharArray()[j]) + ",");
				}
			}
			for(int k = 0; k < 2; k++){ //impedance setting values
				impedanceCheckValues[i][k] = '0';
			}
		}
		update(); //update 1 time to refresh button values based on new loaded settings
	}

	public void update(){

		//make false to check again below
		for(int i = 0; i < nchan; i++){
			drawImpedanceValues[i] = false;
		}

		for(int i = 0; i < nchan; i++){ //for every channel
			//update buttons based on channelSettingValues[i][j]
			for(int j = 0; j < numSettingsPerChannel; j++){		
				switch(j){  //what setting are we looking at
					case 0: //on/off ??
						if(channelSettingValues[i][j] == '0') channelSettingButtons[i][0].setColorNotPressed(channelColors[i%8]);// power down == false, set color to vibrant
						if(channelSettingValues[i][j] == '1') channelSettingButtons[i][0].setColorNotPressed(color(75)); // channelSettingButtons[i][0].setString("B"); // power down == true, set color to dark gray, indicating power down
						break;
					case 1: //GAIN ??
						if(channelSettingValues[i][j] == '0') channelSettingButtons[i][1].setString("x1");
						if(channelSettingValues[i][j] == '1') channelSettingButtons[i][1].setString("x2");
						if(channelSettingValues[i][j] == '2') channelSettingButtons[i][1].setString("x4");
						if(channelSettingValues[i][j] == '3') channelSettingButtons[i][1].setString("x6");
						if(channelSettingValues[i][j] == '4') channelSettingButtons[i][1].setString("x8");
						if(channelSettingValues[i][j] == '5') channelSettingButtons[i][1].setString("x12");
						if(channelSettingValues[i][j] == '6') channelSettingButtons[i][1].setString("x24");
						break;
					case 2: //input type ??
						if(channelSettingValues[i][j] == '0') channelSettingButtons[i][2].setString("Normal");
						if(channelSettingValues[i][j] == '1') channelSettingButtons[i][2].setString("Shorted");
						if(channelSettingValues[i][j] == '2') channelSettingButtons[i][2].setString("BIAS_MEAS");
						if(channelSettingValues[i][j] == '3') channelSettingButtons[i][2].setString("MVDD");
						if(channelSettingValues[i][j] == '4') channelSettingButtons[i][2].setString("Temp.");
						if(channelSettingValues[i][j] == '5') channelSettingButtons[i][2].setString("Test");
						if(channelSettingValues[i][j] == '6') channelSettingButtons[i][2].setString("BIAS_DRP");
						if(channelSettingValues[i][j] == '7') channelSettingButtons[i][2].setString("BIAS_DRN");
						break;
					case 3: //BIAS ??
						if(channelSettingValues[i][j] == '0') channelSettingButtons[i][3].setString("Don't Include");
						if(channelSettingValues[i][j] == '1') channelSettingButtons[i][3].setString("Include");
						break;
					case 4: // SRB2 ??
						if(channelSettingValues[i][j] == '0') channelSettingButtons[i][4].setString("Off");
						if(channelSettingValues[i][j] == '1') channelSettingButtons[i][4].setString("On");
						break;
					case 5: // SRB1 ??
						if(channelSettingValues[i][j] == '0') channelSettingButtons[i][5].setString("No");
						if(channelSettingValues[i][j] == '1') channelSettingButtons[i][5].setString("Yes");
						break;
				}
			}

			for(int k = 0; k < 2; k++){
				switch(k){
					case 0: // P Imp Buttons
						if(impedanceCheckValues[i][k] == '0'){
							impedanceCheckButtons[i][0].setColorNotPressed(color(75));
							impedanceCheckButtons[i][0].setString("");
						}
						if(impedanceCheckValues[i][k] == '1'){
							impedanceCheckButtons[i][0].setColorNotPressed(greenColor);
							impedanceCheckButtons[i][0].setString("");
							drawImpedanceValues[i] = true;
						}
						break;
					case 1: // N Imp Buttons
						if(impedanceCheckValues[i][k] == '0'){
							impedanceCheckButtons[i][1].setColorNotPressed(color(75));
							impedanceCheckButtons[i][1].setString("");
						}
						if(impedanceCheckValues[i][k] == '1'){
							impedanceCheckButtons[i][1].setColorNotPressed(greenColor);
							impedanceCheckButtons[i][1].setString("");
							drawImpedanceValues[i] = true;
						}
						break;
				}
			}
		}
		//then reset to 1

		//
		if(isWritingChannel){
			writeChannelSettings(channelToWrite);
		}

		if(rewriteChannelWhenDoneWriting == true && isWritingChannel == false){
			initChannelWrite(channelToWriteWhenDoneWriting);
			rewriteChannelWhenDoneWriting = false;
		}

		if(isWritingImp){
			writeImpedanceSettings(impChannelToWrite);
		}

		if(rewriteImpedanceWhenDoneWriting == true && isWritingImp == false){
			initImpWrite(impChannelToWriteWhenDoneWriting, final_pORn, final_onORoff);
			rewriteImpedanceWhenDoneWriting = false;
		}
	}

	public void draw(){

		pushStyle();
		noStroke();

		//draw phantom rectangle to cover up random crap from Graph2D... we are replacing this stuff with the Montage Controller
		fill(bgColor);
		rect(x1 - 2, y1-(height*0.01f), w1, h1+(height*0.02f));

		//draw light green rect behind pane title
		fill(216,233,171);
		rect(x2-2,y2-25,w2+1,25);

		//BG of montage controller (for debugging mainly)
		// fill(255,255,255,123);
		// rect(x1, y1 - 1, w1, h1);

		//draw background pane of impedance buttons
		fill(221);
		rect(x1 + w1/3 + 1, y1, 2*(w1/3) - 3, h1 - 2);

		//draw slightly darker line guides/separators for impedance buttons
		stroke(175);
		strokeWeight(2);
		for(int i = 0; i < nchan; i++){
			line(x1 + w1/3 + 2, y1 + (((h1-1)/(nchan+1))*(i+1)), x2 - 3, y1 + (((h1-1)/(nchan+1))*(i+1)));
		}
		line(x1 + 2*(w1/3) - 1, y1 + 1, x1 + 2*(w1/3) - 1, y1 + (h1-1) - 1);
		strokeWeight(0);

		//channel buttons
		for(int i = 0; i < nchan; i++){
			channelSettingButtons[i][0].draw(); //draw on/off channel buttons
			//draw impedance buttons
			for(int j = 0; j < 2; j++){
				impedanceCheckButtons[i][j].draw();
			}
		}

		//label impedance button columns
		fill(bgColor);
		text("P", x1 + 1*(w1/2), y1 + 12);
		text("N", x1 + 5*(w1/6) - 2, y1 + 12);

		if(showFullController){
			//background
			noStroke();
			fill(0,0,0,100);
			rect(x1 + w1, y1, w2, h2);

			// [numChan] x 5 ... all channel setting buttons (other than on/off) 
			for(int i = 0; i < nchan; i++){
				for(int j = 1; j < 6; j++){
					// println("drawing button " + i + "," + j);
					// println("Button: " + channelSettingButtons[i][j]);
					channelSettingButtons[i][j].draw();
				}
			}

			//draw column headers for channel settings behind EEG graph
			fill(bgColor);
			text("PGA Gain", x2 + (w2/10)*1, y1 - 12);
			text("Input Type", x2 + (w2/10)*3, y1 - 12);
			text("  Bias ", x2 + (w2/10)*5, y1 - 12);
			text("SRB2", x2 + (w2/10)*7, y1 - 12);
			text("SRB1", x2 + (w2/10)*9, y1 - 12);

			//if mode is not from OpenBCI, draw a dark overlay to indicate that you cannot edit these settings
			if(eegDataSource != DATASOURCE_NORMAL && eegDataSource != DATASOURCE_NORMAL_W_AUX){
				fill(0,0,0,200);
				noStroke();
				rect(x2-2,y2,w2+1,h2);
				fill(255);
				textSize(24);
				text("DATA SOURCE (LIVE) only", x2 + (w2/2), y2 + (h2/2));
			}
		}

		if(eegDataSource != DATASOURCE_NORMAL && eegDataSource != DATASOURCE_NORMAL_W_AUX){
			fill(0,0,0,200);
			rect(x1 + w1/3 + 1, y1, 2*(w1/3) - 3, h1 - 2);
		}

		for (int i = 0; i < nchan; i++){
			if(drawImpedanceValues[i] == true){
				gui.impValuesMontage[i].draw();  //impedance values on montage plot
	        }
		}

		popStyle();

	}

	public void mousePressed(){
		//if fullChannelController and one of the buttons (other than ON/OFF) is clicked

		//if dataSource is coming from OpenBCI, allow user to interact with channel controller
		if(eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX){
			if(showFullController){
				for(int i = 0; i < nchan; i++){ //When [i][j] button is clicked
					for(int j = 1; j < numSettingsPerChannel; j++){		
						if(channelSettingButtons[i][j].isMouseHere()){
							//increment [i][j] channelSettingValue by, until it reaches max values per setting [j], 
							channelSettingButtons[i][j].wasPressed = true;
							channelSettingButtons[i][j].isActive = true;
						}
					}
				}	
			}
		}
		//on/off button and Imp buttons can always be clicked/released
		for(int i = 0; i < nchan; i++){
			if(channelSettingButtons[i][0].isMouseHere()){
				channelSettingButtons[i][0].wasPressed = true;
				channelSettingButtons[i][0].isActive = true;
			}

			//only allow editing of impedance if dataSource == from OpenBCI
			if(eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX){
				if(impedanceCheckButtons[i][0].isMouseHere()){
					impedanceCheckButtons[i][0].wasPressed = true;
					impedanceCheckButtons[i][0].isActive = true;
				}
				if(impedanceCheckButtons[i][1].isMouseHere()){
					impedanceCheckButtons[i][1].wasPressed = true;
					impedanceCheckButtons[i][1].isActive = true;
				}
			}
		}

	}

	public void mouseReleased(){
		//if fullChannelController and one of the buttons (other than ON/OFF) is released
		if(showFullController){
			for(int i = 0; i < nchan; i++){ //When [i][j] button is clicked
				for(int j = 1; j < numSettingsPerChannel; j++){		
					if(channelSettingButtons[i][j].isMouseHere() && channelSettingButtons[i][j].wasPressed == true){
						if(channelSettingValues[i][j] < maxValuesPerSetting[j]){
							channelSettingValues[i][j]++;	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j], 
						} else {
							channelSettingValues[i][j] = '0';
						}	
						// if you're not currently writing a channel and not waiting to rewrite after you've finished mashing the button
						if(!isWritingChannel && rewriteChannelWhenDoneWriting == false){
							initChannelWrite(i);//write new ADS1299 channel row values to OpenBCI
						}
						else{ //else wait until a the current write has finished and then write again ... this is to not overwrite the wrong values while writing a channel
							verbosePrint("CONGRATULATIONS, YOU'RE MASHING BUTTONS!");
							rewriteChannelWhenDoneWriting = true;
							channelToWriteWhenDoneWriting = i;
						}

					}

					// if(!channelSettingButtons[i][j].isMouseHere()){
					channelSettingButtons[i][j].isActive = false;
					channelSettingButtons[i][j].wasPressed = false;
					// }
				}
			}
		}
		//ON/OFF button can always be clicked/released
		for(int i = 0; i < nchan; i++){
			//was on/off clicked?
			if(channelSettingButtons[i][0].isMouseHere() && channelSettingButtons[i][0].wasPressed == true){
				if(channelSettingValues[i][0] < maxValuesPerSetting[0]){
					channelSettingValues[i][0] = '1';	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j], 
					// channelSettingButtons[i][0].setColorNotPressed(color(25,25,25));
					// powerDownChannel(i);
					deactivateChannel(i);
				} else {
					channelSettingValues[i][0] = '0';
					// channelSettingButtons[i][0].setColorNotPressed(color(255));
					// powerUpChannel(i);
					activateChannel(i);
				}
				// writeChannelSettings(i);//write new ADS1299 channel row values to OpenBCI
			}

			//was P imp check button clicked?
			if(impedanceCheckButtons[i][0].isMouseHere() && impedanceCheckButtons[i][0].wasPressed == true){
				if(impedanceCheckValues[i][0] < '1'){
					// impedanceCheckValues[i][0] = '1';	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j], 
					// channelSettingButtons[i][0].setColorNotPressed(color(25,25,25));
					// writeImpedanceSettings(i);
					initImpWrite(i, 'p', '1');
					//initImpWrite
					verbosePrint("a");
				} else {
					// impedanceCheckValues[i][0] = '0';
					// channelSettingButtons[i][0].setColorNotPressed(color(255));
					// writeImpedanceSettings(i);
					initImpWrite(i, 'p', '0');
					verbosePrint("b");
				}
				// writeChannelSettings(i);//write new ADS1299 channel row values to OpenBCI
			}

			//was N imp check button clicked?
			if(impedanceCheckButtons[i][1].isMouseHere() && impedanceCheckButtons[i][1].wasPressed == true){
				if(impedanceCheckValues[i][1] < '1'){
					initImpWrite(i, 'n', '1');
					//initImpWrite
					verbosePrint("c");
				} else {
					initImpWrite(i, 'n', '0');
					verbosePrint("d");
				}
				// writeChannelSettings(i);//write new ADS1299 channel row values to OpenBCI
			}

			channelSettingButtons[i][0].isActive = false;
			channelSettingButtons[i][0].wasPressed = false;
			impedanceCheckButtons[i][0].isActive = false;
			impedanceCheckButtons[i][0].wasPressed = false;
			impedanceCheckButtons[i][1].isActive = false;
			impedanceCheckButtons[i][1].wasPressed = false;
		}

		update(); //update once to refresh button values
	}

	public void fillValuesBasedOnDefault(byte _defaultValues){
		//interpret incoming HEX value (from OpenBCI) and pass into all default channelSettingValues
		//dencode byte from OpenBCI and break it apart into the channelSettingValues[][] array
	}

	public void powerDownChannel(int _numChannel){
		verbosePrint("Powering down channel " + str(PApplet.parseInt(_numChannel) + PApplet.parseInt(1)));
		//save SRB2 and BIAS settings in 2D history array (to turn back on when channel is reactivated)
		previousBIAS[_numChannel] = channelSettingValues[_numChannel][3];
		previousSRB2[_numChannel] = channelSettingValues[_numChannel][4];
		channelSettingValues[_numChannel][3] = '0'; //make sure to disconnect from BIAS
		channelSettingValues[_numChannel][4] = '0'; //make sure to disconnect from SRB2

		// initChannelWrite(_numChannel);//writeChannelSettings
		channelSettingValues[_numChannel][0] = '1'; //update powerUp/powerDown value of 2D array
		serial_openBCI.write(command_deactivate_channel[_numChannel]);
	}

	public void powerUpChannel(int _numChannel){
		verbosePrint("Powering up channel " + str(PApplet.parseInt(_numChannel) + PApplet.parseInt(1)));
		//replace SRB2 and BIAS settings with values from 2D history array
		channelSettingValues[_numChannel][3] = previousBIAS[_numChannel];
		channelSettingValues[_numChannel][4] = previousSRB2[_numChannel];

		// initChannelWrite(_numChannel);//writeChannelSettings
		channelSettingValues[_numChannel][0] = '0'; //update powerUp/powerDown value of 2D array
		serial_openBCI.write(command_activate_channel[_numChannel]);
	}

	public void initChannelWrite(int _numChannel){
		//after clicking any button, write the new settings for that channel to OpenBCI
		if(!isWritingImp){ //make sure you aren't currently writing imp settings for a channel
			verbosePrint("Writing channel settings for channel " + str(_numChannel+1) + " to OpenBCI!");
			timeOfLastChannelWrite = millis();
			isWritingChannel = true;
			channelToWrite = _numChannel;
		}
	}

	public void initImpWrite(int _numChannel, char pORn, char onORoff){
		//after clicking any button, write the new settings for that channel to OpenBCI
		if(!isWritingChannel){ //make sure you aren't currently writing imp settings for a channel
			// if you're not currently writing a channel and not waiting to rewrite after you've finished mashing the button
			if(!isWritingImp && rewriteImpedanceWhenDoneWriting == false){
				verbosePrint("Writing impedance check settings (" + pORn + "," + onORoff +  ") for channel " + str(_numChannel+1) + " to OpenBCI!");
				if(pORn == 'p'){
					impedanceCheckValues[_numChannel][0] = onORoff;
				}
				if(pORn == 'n'){
					impedanceCheckValues[_numChannel][1] = onORoff;
				}

				timeOfLastImpWrite = millis();
				isWritingImp = true;
				impChannelToWrite = _numChannel;
			}
			else{ //else wait until a the current write has finished and then write again ... this is to not overwrite the wrong values while writing a channel
				verbosePrint("CONGRATULATIONS, YOU'RE MASHING BUTTONS!");
				rewriteImpedanceWhenDoneWriting = true;
				impChannelToWriteWhenDoneWriting = _numChannel;

				if(pORn == 'p'){
					final_pORn = 'p';
				}
				if(pORn == 'n'){
					final_pORn = 'n';
				}
				final_onORoff = onORoff;
			}
		}
	}

	public void writeChannelSettings(int _numChannel){
		if(millis() - timeOfLastChannelWrite >= 50){
			verbosePrint("---");
			switch (channelWriteCounter){
				case 0: //start sequence by send 'x'
					verbosePrint("x" + " :: " + millis());
					serial_openBCI.write('x');
					break;
				case 1: //send channel number
					verbosePrint(str(_numChannel+1) + " :: " + millis());
					serial_openBCI.write((char) ('0'+(_numChannel+1)));
					break;
				case 2: case 3: case 4: case 5: case 6: case 7:
					verbosePrint(channelSettingValues[_numChannel][channelWriteCounter-2] + " :: " + millis());
					serial_openBCI.write(channelSettingValues[_numChannel][channelWriteCounter-2]);
					//value for ON/OF
					break;
				case 8:
					verbosePrint("X" + " :: " + millis());
					serial_openBCI.write('X'); // send 'X' to end message sequence
					break;
				case 9:
					verbosePrint("done writing channel.");
					isWritingChannel = false;
					channelWriteCounter = -1;
					break;
			}
			timeOfLastChannelWrite = millis();
			channelWriteCounter++;
		}
	}

	public void writeImpedanceSettings(int _numChannel){
		//after clicking an impedance button, write the new impedance settings for that channel to OpenBCI
			//after clicking any button, write the new settings for that channel to OpenBCI
		// verbosePrint("Writing impedance settings for channel " + _numChannel + " to OpenBCI!");
		//write setting 1, delay 5ms.. write setting 2, delay 5ms, etc.
		if(millis() - timeOfLastImpWrite >= 50){
			verbosePrint("---");
			switch (impWriteCounter){
				case 0: //start sequence by send 'x'
					verbosePrint("z" + " :: " + millis());
					serial_openBCI.write('z');
					break;
				case 1: //send channel number
					verbosePrint(str(_numChannel+1) + " :: " + millis());
					serial_openBCI.write((char) ('0'+(_numChannel+1)));
					break;
				case 2: case 3: 
					verbosePrint(impedanceCheckValues[_numChannel][impWriteCounter-2] + " :: " + millis());
					serial_openBCI.write(impedanceCheckValues[_numChannel][impWriteCounter-2]);
					//value for ON/OF
					break;
				case 4:
					verbosePrint("Z" + " :: " + millis());
					serial_openBCI.write('Z'); // send 'X' to end message sequence
					break;
				case 5:
					verbosePrint("done writing imp settings.");
					isWritingImp = false;
					impWriteCounter = -1;
					break;
			}
			timeOfLastImpWrite = millis();
			impWriteCounter++;
		}
	}

	public void createChannelSettingButtons(){
		//the size and space of these buttons are dependendant on the size of the screen and full ChannelController
		
		verbosePrint("creating channel setting buttons...");
		int buttonW = 0;
		int buttonX = 0;
		int buttonH = 0;
		int buttonY = 0; //variables to be used for button creation below
		String buttonString = "";
		Button tempButton;

		//create all activate/deactivate buttons (left-most button in widget left of EEG graph). These buttons are always visible
		for(int i = 0; i < nchan; i++){
			buttonW = PApplet.parseInt((w1 - (spacer1 *4)) / 3);
			buttonX = PApplet.parseInt(x1 + (spacer1));
			// buttonH = int((h1 / (nchan + 1)) - (spacer1/2));
			buttonH = buttonW;
			buttonY = PApplet.parseInt(y1 + ((h1/(nchan+1))*(i+1)) - (buttonH/2));
			buttonString = str(i+1);
			tempButton = new Button (buttonX, buttonY, buttonW, buttonH, buttonString, 14);
			channelSettingButtons[i][0] = tempButton;
		}
		//create all (P)ositive impedance check butttons ... these are the buttons just to the right of activate/deactivate buttons ... These are also always visible
		//create all (N)egative impedance check butttons ... these are the buttons just to the right of activate/deactivate buttons ... These are also always visible

		int downSizer = 6;
		for(int i = 0; i < nchan; i++){
			for(int j = 1; j < 3; j++){
				buttonW = PApplet.parseInt(((w1 - (spacer1 *4)) / 3) - downSizer);
				buttonX = PApplet.parseInt((x1 + j*(buttonW+6) + (j+1)*(spacer1)) + (downSizer/2) + 1);
				// buttonH = int((h2 / (nchan + 1)) - (spacer2/2));
				buttonY = PApplet.parseInt((y1 + (((h1-1)/(nchan+1))*(i+1)) - (buttonH/2)) + (downSizer/2) + 1);
				buttonString = "";
				tempButton = new Button (buttonX, buttonY, buttonW, buttonW, buttonString, 14);
				impedanceCheckButtons[i][j-1] = tempButton;
			}
		}	

		//create all other channel setting buttons... these are only visible when the user toggles to "showFullController = true"
		for(int i = 0; i < nchan; i++){
			for(int j = 1; j < 6; j++){
				buttonW = PApplet.parseInt((w2 - (spacer2*6)) / 5);
				buttonX = PApplet.parseInt((x2 + (spacer2 * (j))) + ((j-1) * buttonW));
				// buttonH = int((h2 / (nchan + 1)) - (spacer2/2));
				buttonY = PApplet.parseInt(y2 + (((h2-1)/(nchan+1))*(i+1)) - (buttonH/2));
				buttonString = "N/A";
				tempButton = new Button (buttonX, buttonY, buttonW, buttonH, buttonString, 14);
				channelSettingButtons[i][j] = tempButton;
			}
		}
	}
};



//////////////////////////////////////////////////////////////////////////
//
//		System Control Panel
//		- Select serial port from dropdown
//		- Select default configuration (EEG, EKG, EMG)
//		- Select Electrode Count (8 vs 16)
//		- Select data mode (synthetic, playback file, real-time)
//		- Record data? (y/n)
//			- select output location
//		- link to help guide
//		- buttons to start/stop/reset application
//
//		Written by: Conor Russomanno (Oct. 2014)
//
//////////////////////////////////////////////////////////////////////////



ControlP5 cp5; //program-wide instance of ControlP5
CallbackListener cb = new CallbackListener() { //used by ControlP5 to clear text field on double-click
    public void controlEvent(CallbackEvent theEvent) {
    	println("clearing");
    	cp5.get(Textfield.class,"fileName").clear();
    }
};

MenuList sourceList;

//Global buttons and elements for the control panel (changed within the classes below)
MenuList serialList;
String[] serialPorts = new String[Serial.list().length];

MenuList sdTimes;

int boxColor = color(200);
// color boxStrokeColor = color(173,183,192);
int boxStrokeColor = color(138,146,153);
int greenColor = color(184,220,105);

// Button openClosePort;
// boolean portButtonPressed;

Button refreshPort;
boolean refreshButtonPressed = false;

Button initSystemButton;
boolean initButtonPressed = false; //default false

Button autoFileName;
boolean fileButtonPressed = false;

Button chanButton8;
boolean chanButton8Pressed = false;

Button chanButton16;
boolean chanButton16Pressed = false;

Button selectPlaybackFile;
boolean selectPlaybackFilePressed = false;

Button selectSDFile;
boolean selectSDFilePressed = false;


class ControlPanel {

	public int x, y, w, h;
	public boolean isOpen;

	boolean showSourceBox, showSerialBox, showFileBox, showChannelBox, showInitBox;
	PlotFontInfo fontInfo;

	//various control panel elements that are unique to specific datasources
	DataSourceBox dataSourceBox;
	SerialBox serialBox;
	DataLogBox dataLogBox;
	ChannelCountBox channelCountBox;
	InitBox initBox;

	PlaybackFileBox playbackFileBox;
	SDConverterBox sdConverterBox;

	SDBox sdBox;

	boolean drawStopInstructions;

	int globalPadding; //design feature: passed through to all box classes as the global spacing .. in pixels .. for all elements/subelements
	int globalBorder;

	boolean convertingSD = false;

	ControlPanel(OpenBCI_GUI mainClass){

		x = 2;
		y = 2 + controlPanelCollapser.but_dy;		
		w = controlPanelCollapser.but_dx;
		h = height - PApplet.parseInt(helpWidget.h);

		isOpen = true;

		fontInfo = new PlotFontInfo();

		// f1 = createFont("Raleway-SemiBold.otf", 16);
		// f2 = createFont("Raleway-Regular.otf", 15);
		// f3 = createFont("Raleway-SemiBold.otf", 15);

		globalPadding = 10;  //controls the padding of all elements on the control panel
		globalBorder = 0;   //controls the border of all elements in the control panel ... using processing's stroke() instead

		cp5 = new ControlP5(mainClass); 

		//boxes active when eegDataSource = Normal (OpenBCI) 
		dataSourceBox = new DataSourceBox(x, y, w, h, globalPadding);
		serialBox = new SerialBox(x + w, dataSourceBox.y, w, h, globalPadding);
		dataLogBox = new DataLogBox(x + w, (serialBox.y + serialBox.h), w, h, globalPadding);
		channelCountBox = new ChannelCountBox(x + w, (dataLogBox.y + dataLogBox.h), w, h, globalPadding);
		sdBox = new SDBox(x + w, (channelCountBox.y + channelCountBox.h), w, h, globalPadding);

		//boxes active when eegDataSource = Playback
		playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, w, h, globalPadding);
		sdConverterBox = new SDConverterBox(x + w, (playbackFileBox.y + playbackFileBox.h), w, h, globalPadding);

		initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);


	}

	public void update(){
		//toggle view of cp5 / serial list selection table
		if(isOpen){ // if control panel is open
			if(!cp5.isVisible()){  //and cp5 is not visible
				cp5.show(); // shot it
			}
		}
		else{ //the opposite of above
			if(cp5.isVisible()){
				cp5.hide();
			}
		}

		//update all boxes if they need to be
		dataSourceBox.update();
		serialBox.update();
		dataLogBox.update();
		channelCountBox.update();
		sdBox.update();
		initBox.update();

		serialList.updateMenu();

		//SD File Conversion
		while(convertingSD == true){
			convertSDFile();
		}

	}

	public void draw(){

		pushStyle();
		noStroke();

		//dark overlay of rest of interface to indicate it's not clickable
		fill(0,0,0,185);
		rect(0,0,width,height);

		pushStyle();
			fill(255);
			noStroke();
			rect(0, 0, width, 32);
		popStyle();

		// //background pane of control panel
		// fill(35,35,35);
		// rect(0,0,w,h);

		popStyle();

		initBox.draw();

		if(systemMode == 10){
			drawStopInstructions = true;
		}

		if(systemMode != 10){ // only draw control panel boxes if system running is false
			dataSourceBox.draw();
			drawStopInstructions = false;
			cp5.setVisible(true);//make sure controlP5 elements are visible
			if(eegDataSource == 0){	//when data source is from OpenBCI
				serialBox.draw();
				dataLogBox.draw();
				channelCountBox.draw();
				sdBox.draw();
				cp5.get(Textfield.class,"fileName").setVisible(true); //make sure the data file field is visible
				cp5.get(MenuList.class,"serialList").setVisible(true); //make sure the serialList menulist is visible
				cp5.get(MenuList.class,"sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
				//make sure serial list is visible
				//set other CP5 controllers invisible
			} else if(eegDataSource == 1){ //when data source is from playback file
				playbackFileBox.draw();
				sdConverterBox.draw();
				//set other CP5 controllers invisible
				cp5.get(Textfield.class,"fileName").setVisible(false); //make sure the data file field is visible
				cp5.get(MenuList.class,"serialList").setVisible(false);
				cp5.get(MenuList.class,"sdTimes").setVisible(false);
			} else if(eegDataSource == 2){
				//make sure serial list is visible
				//set other CP5 controllers invisible
				cp5.get(Textfield.class,"fileName").setVisible(false); //make sure the data file field is visible
				cp5.get(MenuList.class,"serialList").setVisible(false);
				cp5.get(MenuList.class,"sdTimes").setVisible(false);
			} else {
				//set other CP5 controllers invisible
				cp5.get(Textfield.class,"fileName").setVisible(false); //make sure the data file field is visible
				cp5.get(MenuList.class,"serialList").setVisible(false);
				cp5.get(MenuList.class,"sdTimes").setVisible(false);
			}
		} else {
			cp5.setVisible(false); // if isRunning is true, hide all controlP5 elements
		}

		//draw the box that tells you to stop the system in order to edit control settings
		if(drawStopInstructions){
			pushStyle();
				fill(boxColor);
				strokeWeight(1);
				stroke(boxStrokeColor);
				rect(x, y, w, dataSourceBox.h); //draw background of box
				String stopInstructions = "Press the \"STOP SYSTEM\" button to edit system settings.";
				textAlign(CENTER, TOP);
				textFont(f2);
				fill(bgColor);
				text(stopInstructions, x + globalPadding*2, y + globalPadding*4, w - globalPadding*4, dataSourceBox.h - globalPadding*4);
			popStyle();
		}
	}

	//mouse pressed in control panel
	public void CPmousePressed(){
		verbosePrint("CPmousePressed");

		if(initSystemButton.isMouseHere()){
			initSystemButton.setIsActive(true);
			initButtonPressed = true;
		}

		//only able to click buttons of control panel when system is not running
		if(systemMode != 10){
			//active buttons during DATASOURCE_NORMAL
			if(eegDataSource == 0){
				if(refreshPort.isMouseHere()){
					refreshPort.setIsActive(true);
					refreshButtonPressed = true;
				}

				if(autoFileName.isMouseHere()){
					autoFileName.setIsActive(true);
					fileButtonPressed = true;
				}

				if(chanButton8.isMouseHere()){
					chanButton8.setIsActive(true);
					chanButton8Pressed = true;
					chanButton8.color_notPressed = color(184,220,105);
					chanButton16.color_notPressed = color(255);
				}

				if(chanButton16.isMouseHere()){
					chanButton16.setIsActive(true);
					chanButton16Pressed = true;
					chanButton8.color_notPressed = color(255);
					chanButton16.color_notPressed = color(184,220,105);
				}
			}

			//active buttons during DATASOURCE_PLAYBACKFILE
			if(eegDataSource == 1){
				if(selectPlaybackFile.isMouseHere()){
					selectPlaybackFile.setIsActive(true);
					selectPlaybackFilePressed = true;
				}

				if(selectSDFile.isMouseHere()){
					selectSDFile.setIsActive(true);
					selectSDFilePressed = true;
				}
			}
		}

		// output("Text File Name: " + cp5.get(Textfield.class,"fileName").getText());
	}

	//mouse released in control panel
	public void CPmouseReleased(){
		verbosePrint("CPMouseReleased");
		if(initSystemButton.isMouseHere() && initButtonPressed){

			//if system is not active ... initate system and flip button state
			if(initSystemButton.but_txt == "START SYSTEM"){

				if((eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX) && openBCI_portName == "N/A"){ //if data source == normal && if no serial port selected OR no SD setting selected
					output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
					initButtonPressed = false;
					initSystemButton.setIsActive(false);
					return;
				}

				else if(eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A"){ //if data source == playback && playback file == 'N/A'
					output("No playback file selected. Please select a playback file and retry system initiation.");				// tell user that they need to select a file before the system can be started
					initButtonPressed = false;
					initSystemButton.setIsActive(false);
					return;
				}

				else if(eegDataSource == -1){//if no data source selected
					output("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
					initButtonPressed = false;
					initSystemButton.setIsActive(false);
					return;
				}

				else { //otherwise, initiate system!	
					println("init");
					initSystemButton.setString("STOP SYSTEM");
					//global steps to START SYSTEM
					// prepare the serial port
				    println("port is open? ... " + portIsOpen);
				    if(portIsOpen == true){
				      openBCI.closeSerialPort();
				    }
				    fileName = cp5.get(Textfield.class,"fileName").getText(); // store the current text field value of "File Name" to be passed along to dataFiles 
					initSystem();
				}
			}

			//if system is already active ... stop system and flip button state back
			else{
				output("SYSTEM STOPPED");
				initSystemButton.setString("START SYSTEM");
				haltSystem();
			}
		}

		//open or close serial port if serial port button is pressed (left button in serial widget)
		if(refreshPort.isMouseHere() && refreshButtonPressed){
			output("Serial/COM List Refreshed");
			serialPorts = new String[Serial.list().length];
			serialPorts = Serial.list();
			serialList.items.clear();
			for(int i = 0; i < serialPorts.length; i++){
				String tempPort = serialPorts[(serialPorts.length-1) - i]; //list backwards... because usually our port is at the bottom
				serialList.addItem(makeItem(tempPort));
			}
			serialList.updateMenu();
		}

		//open or close serial port if serial port button is pressed (left button in serial widget)
		if(autoFileName.isMouseHere() && fileButtonPressed){
			output("Autogenerated \"File Name\" based on current date/time");
			cp5.get(Textfield.class,"fileName").setText(getDateString());
		}

		if(chanButton8.isMouseHere() && chanButton8Pressed){
			nchan = 8;
			fftBuff = new FFT[nchan];   //from the minim library
			yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
			output("channel count set to " + str(nchan));
		}

		if(chanButton16.isMouseHere() && chanButton16Pressed){
			nchan = 16;
			fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
			yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
			output("channel count set to " + str(nchan));
		}

		if(selectPlaybackFile.isMouseHere() && selectPlaybackFilePressed){
			output("select a file for playback");
			selectInput("Select a pre-recorded file for playback:", "playbackSelected");
		}

		if(selectSDFile.isMouseHere() && selectSDFilePressed){
			output("select an SD file to convert to a playback file");
			createPlaybackFileFromSD();
			selectInput("Select an SD file to convert for playback:", "sdFileSelected");
		}

		//reset all buttons to false
		refreshPort.setIsActive(false);
		refreshButtonPressed = false;
		initSystemButton.setIsActive(false);
		initButtonPressed = false;
		autoFileName.setIsActive(false);
		fileButtonPressed = false;
		chanButton8.setIsActive(false);
		chanButton8Pressed = false;
		chanButton16.setIsActive(false);
		chanButton16Pressed = false;
		selectPlaybackFile.setIsActive(false);
		selectPlaybackFilePressed = false;
		selectSDFile.setIsActive(false);
		selectSDFilePressed = false;
	}
};

public void controlEvent(ControlEvent theEvent) {
	
	if(theEvent.isFrom("sourceList")){
		Map bob = ((MenuList)theEvent.getController()).getItem(PApplet.parseInt(theEvent.getValue()));
		output("Data Source = " + (String)bob.get("headline"));
		int newDataSource = PApplet.parseInt(theEvent.getValue());
		eegDataSource = newDataSource; // reset global eegDataSource to the selected value from the list
		output("The new data source is " + (String)bob.get("headline"));
	}

	if(theEvent.isFrom("serialList")){
		Map bob = ((MenuList)theEvent.getController()).getItem(PApplet.parseInt(theEvent.getValue()));
		openBCI_portName = (String)bob.get("headline");
		output("OpenBCI Port Name = " + openBCI_portName);
	}

	if(theEvent.isFrom("sdTimes")){
		Map bob = ((MenuList)theEvent.getController()).getItem(PApplet.parseInt(theEvent.getValue()));
		sdSettingString = (String)bob.get("headline");
		sdSetting = PApplet.parseInt(theEvent.getValue());
		if(sdSetting != 0){
			output("OpenBCI microSD Setting = " + sdSettingString + " recording time");
		} else{
			output("OpenBCI microSD Setting = " + sdSettingString);
		}
		verbosePrint("SD setting = " + sdSetting);
	}
}

//==============================================================================//
//					BELOW ARE THE CLASSES FOR THE VARIOUS 						//
//					CONTROL PANEL BOXes (control widgets)						//
//==============================================================================//

class DataSourceBox {
	int x, y, w, h, padding; //size and position

	CheckBox sourceCheckBox;

	DataSourceBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 115;
		padding = _padding;

		sourceList = new MenuList(cp5, "sourceList", w - padding*2, 72, f2);
		// sourceList.itemHeight = 28;
		// sourceList.padding = 9;
		sourceList.setPosition(x + padding, y + padding*2 + 13);
		sourceList.addItem(makeItem("LIVE (from OpenBCI)                   >"));
		sourceList.addItem(makeItem("PLAYBACK (from file)                  >"));
		sourceList.addItem(makeItem("SYNTHETIC (algorithmic)           >"));
		sourceList.scrollerLength = 10;
	}

	public void update(){

	}

	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("DATA SOURCE", x + padding, y + padding);
		popStyle();
			//draw contents of Data Source Box at top of control panel
			//Title
			//checkboxes of system states
	}
};

class SerialBox {
	int x, y, w, h, padding; //size and position
	//connect/disconnect button
	//Refresh list button
	//String port status;

	SerialBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 147;
		padding = _padding;

		// openClosePort = new Button (padding + border, y + padding*3 + 13 + 150, (w-padding*3)/2, 24, "OPEN PORT", fontInfo.buttonLabel_size);
		refreshPort = new Button (x + padding, y + padding*3 + 13 + 71, w - padding*2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);

		serialList = new MenuList(cp5, "serialList", w - padding*2, 72, f2);
		serialList.setPosition(x + padding, y + padding*2 + 13);
		serialPorts = Serial.list();
		for(int i = 0; i < serialPorts.length; i++){
			String tempPort = serialPorts[(serialPorts.length-1) - i]; //list backwards... because usually our port is at the bottom
			serialList.addItem(makeItem(tempPort));
		}
	}

	public void update(){
		// serialList.updateMenu();
	}

	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("SERIAL/COM PORT", x + padding, y + padding);
		popStyle();

		// openClosePort.draw();
		refreshPort.draw();
	}

	public void refreshSerialList(){

	}
};

class DataLogBox {
	int x, y, w, h, padding; //size and position
	String fileName;
	//text field for inputing text
	//create/open/closefile button
	String fileStatus;
	boolean isFileOpen; //true if file has been activated and is ready to write to
	//String port status;

	DataLogBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 101;
		padding = _padding;
		//instantiate button
		//figure out default file name (from Chip's code)
		isFileOpen = false; //set to true on button push
		fileStatus = "NO FILE CREATED";

		//button to autogenerate file name based on time/date
		autoFileName = new Button (x + padding, y + 66, w-(padding*2), 24, "AUTOGENERATE FILE NAME", fontInfo.buttonLabel_size);

		cp5.addTextfield("fileName")
			.setPosition(x + 90,y + 32)
			.setCaptionLabel("")
			.setSize(157,26)
			.setFont(f2)
			.setFocus(false)
			.setColor(color(26,26,26))
			.setColorBackground(color(255,255,255)) // text field bg color
			.setColorValueLabel(color(0,0,0))  // text color
			.setColorForeground(greenColor)  // border color when not selected
			.setColorActive(greenColor)  // border color when selected
			.setColorCursor(color(26,26,26)) 
			.setText(getDateString())
			.align(5, 10, 20, 40) 
			.onDoublePress(cb) 
			.setAutoClear(true)
			;

			//clear text field on double click

	}

	public void update(){

	}

	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("DATA LOG FILE", x + padding, y + padding);
			textFont(f3);
			text("File Name", x + padding, y + padding*2 + 18);
		popStyle();
		autoFileName.draw();
	}
};

class ChannelCountBox {
	int x, y, w, h, padding; //size and position

	boolean isSystemInitialized;
	// button for init/halt system

	ChannelCountBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 73;
		padding = _padding;

		chanButton8 = new Button (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "8 CHANNELS", fontInfo.buttonLabel_size);
		chanButton8.color_notPressed = color(184,220,105);
		chanButton16 = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "16 CHANNELS", fontInfo.buttonLabel_size);

	}

	public void update(){

	}
	
	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("CHANNEL COUNT", x + padding, y + padding);
			fill(bgColor); //set color to green
			textFont(f1);
			textAlign(LEFT, TOP);
			text("(" + str(nchan) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
		popStyle();

		chanButton8.draw();
		chanButton16.draw();
	}
};

class PlaybackFileBox {
	int x, y, w, h, padding; //size and position

	PlaybackFileBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 67;
		padding = _padding;

		selectPlaybackFile = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);

	}

	public void update(){

	}
	
	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("PLAYBACK FILE", x + padding, y + padding);
		popStyle();

		selectPlaybackFile.draw();
		// chanButton16.draw();
	}
};

class SDBox {
	int x, y, w, h, padding; //size and position

	SDBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 150;
		padding = _padding;

		sdTimes = new MenuList(cp5, "sdTimes", w - padding*2, 108, f2);
		sdTimes.setPosition(x + padding, y + padding*2 + 13);
		serialPorts = Serial.list();

		//add items for the various SD times
		sdTimes.addItem(makeItem("Do not write to SD..."));
		sdTimes.addItem(makeItem("5 minute maximum"));
		sdTimes.addItem(makeItem("15 minute maximum"));
		sdTimes.addItem(makeItem("30 minute maximum"));
		sdTimes.addItem(makeItem("1 hour maximum"));
		sdTimes.addItem(makeItem("2 hours maximum"));
		sdTimes.addItem(makeItem("4 hour maximum"));
		sdTimes.addItem(makeItem("12 hour maximum"));
		sdTimes.addItem(makeItem("24 hour maximum"));
	}

	public void update(){

	}
	
	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("WRITE TO SD (Y/N)?", x + padding, y + padding);
		popStyle();

		// chanButton8.draw();
		// chanButton16.draw();
	}
};

class SDConverterBox {
	int x, y, w, h, padding; //size and position

	SDConverterBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 67;
		padding = _padding;

		selectSDFile = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT SD FILE", fontInfo.buttonLabel_size);

	}

	public void update(){

	}
	
	public void draw(){
		pushStyle();
			fill(boxColor);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
			fill(bgColor);
			textFont(f1);
			textAlign(LEFT, TOP);
			text("CONVERT SD FOR PLAYBACK", x + padding, y + padding);
		popStyle();

		selectSDFile.draw();
		// chanButton16.draw();
	}
};

class InitBox {
	int x, y, w, h, padding; //size and position

	boolean initButtonPressed; //default false

	boolean isSystemInitialized;
	// button for init/halt system

	InitBox(int _x, int _y, int _w, int _h, int _padding){
		x = _x;
		y = _y;
		w = _w;
		h = 50;
		padding = _padding;

		//init button
		initSystemButton = new Button (padding, y + padding, w-padding*2, h - padding*2, "START SYSTEM", fontInfo.buttonLabel_size);
		initSystemButton.color_notPressed = color(boxColor);
		initSystemButton.buttonStrokeColor = color(boxColor);
		initButtonPressed = false;
	}

	public void update(){

	}

	public void draw(){

		pushStyle();
			fill(255);
			stroke(boxStrokeColor);
			strokeWeight(1);
			rect(x, y, w, h);
		popStyle();
		initSystemButton.draw();

	}

};

public void playbackSelected(File selection){
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    output("You have selected \"" + selection.getAbsolutePath() + "\" for playback.");
    playbackData_fname = selection.getAbsolutePath();
  }
}





//import ddf.minim.analysis.*; //for FFT

class EEG_Processing_User {
  private float fs_Hz;  //sample rate
  private int nchan;  
  
  //add your own variables here
  
 
  //class constructor
  EEG_Processing_User(int NCHAN, float sample_rate_Hz) {
      nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
  }
  
  //add some functions here...if you'd like
  
  //here is the processing routine called by the OpenBCI main program...update this with whatever you'd like to do
  public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
        float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
        float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //for example, you could loop over each EEG channel to do some sort of time-domain processing 
    //using the sample values that have already been filtered, as will be plotted on the display
    float EEG_value_uV;
    for (int Ichan=0;Ichan < nchan; Ichan++) {
      //loop over each NEW sample
      int indexOfNewData = data_forDisplay_uV[Ichan].length - data_newest_uV[Ichan].length;
      for (int Isamp=indexOfNewData; Isamp < data_forDisplay_uV[Ichan].length; Isamp++) {
        EEG_value_uV = data_forDisplay_uV[Ichan][Isamp];  // again, this is from the filtered data that is ready for display
        
        //add your processing here...
        
        
        //println("EEG_Processing_User: Ichan = " + Ichan + ", Isamp = " + Isamp + ", EEG Value = " + EEG_value_uV + " uV");
      }
    }
        
    //OR, you could loop over each EEG channel and do some sort of frequency-domain processing from the FFT data
    float FFT_freq_Hz, FFT_value_uV;
    for (int Ichan=0;Ichan < nchan; Ichan++) {
      //loop over each new sample
      for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++){
        FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin);
        FFT_value_uV = fftData[Ichan].getBand(Ibin);
        
        //add your processing here...
        
        
        
        //println("EEG_Processing_User: Ichan = " + Ichan + ", Freq = " + FFT_freq_Hz + "Hz, FFT Value = " + FFT_value_uV + "uV/bin");
      }
    }  
  }
}
   


class EEG_Processing {
  private float fs_Hz;  //sample rate
  private int nchan;
  final int N_FILT_CONFIGS = 5;
  FilterConstants[] filtCoeff_bp = new FilterConstants[N_FILT_CONFIGS];
  FilterConstants[] filtCoeff_notch = new FilterConstants[N_FILT_CONFIGS];
  private int currentFilt_ind = 0;
  float data_std_uV[];
  float polarity[];


  EEG_Processing(int NCHAN, float sample_rate_Hz) {
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
    data_std_uV = new float[nchan];
    polarity = new float[nchan];
    

    //check to make sure the sample rate is acceptable and then define the filters
    if (abs(fs_Hz-250.0f) < 1.0f) {
      defineFilters();
    } 
    else {
      println("EEG_Processing: *** ERROR *** Filters can currently only work at 250 Hz");
      defineFilters();  //define the filters anyway just so that the code doesn't bomb
    }
  }

  public float getSampleRateHz() { 
    return fs_Hz;
  };

  //define filters...assumes sample rate of 250 Hz !!!!!
  private void defineFilters() {
    int n_filt = filtCoeff_bp.length;
    double[] b, a, b2, a2;
    String filt_txt, filt_txt2;
    String short_txt, short_txt2; 

    //loop over all of the pre-defined filter types
    for (int Ifilt=0;Ifilt<n_filt;Ifilt++) {

      //define common notch filter
      b2 = new double[] { 
        9.650809863447347e-001f, -2.424683201757643e-001f, 1.945391494128786e+000f, -2.424683201757643e-001f, 9.650809863447347e-001f
      };
      a2 = new double[] {    
        1.000000000000000e+000f, -2.467782611297853e-001f, 1.944171784691352e+000f, -2.381583792217435e-001f, 9.313816821269039e-001f
      }; 
      filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 60Hz", "60Hz");

      //define bandpass filter
      switch (Ifilt) {
      case 0:
        //butter(2,[1 50]/(250/2));  %bandpass filter
        b = new double[] { 
          2.001387256580675e-001f, 0.0f, -4.002774513161350e-001f, 0.0f, 2.001387256580675e-001f
        };
        a = new double[] { 
          1.0f, -2.355934631131582e+000f, 1.941257088655214e+000f, -7.847063755334187e-001f, 1.999076052968340e-001f
        };
        filt_txt = "Bandpass 1-50Hz";
        short_txt = "1-50 Hz";
        break;
      case 1:
        //butter(2,[7 13]/(250/2));
        b = new double[] {  
          5.129268366104263e-003f, 0.0f, -1.025853673220853e-002f, 0.0f, 5.129268366104263e-003f
        };
        a = new double[] { 
          1.0f, -3.678895469764040e+000f, 5.179700413522124e+000f, -3.305801890016702e+000f, 8.079495914209149e-001f
        };
        filt_txt = "Bandpass 7-13Hz";
        short_txt = "7-13 Hz";
        break;      
      case 2:
        //[b,a]=butter(2,[15 50]/(250/2)); %matlab command
        b = new double[] { 
          1.173510367246093e-001f, 0.0f, -2.347020734492186e-001f, 0.0f, 1.173510367246093e-001f
        };
        a = new double[] { 
          1.0f, -2.137430180172061e+000f, 2.038578008108517e+000f, -1.070144399200925e+000f, 2.946365275879138e-001f
        };
        filt_txt = "Bandpass 15-50Hz";
        short_txt = "15-50 Hz";  
        break;    
      case 3:
        //[b,a]=butter(2,[5 50]/(250/2)); %matlab command
        b = new double[] {  
          1.750876436721012e-001f, 0.0f, -3.501752873442023e-001f, 0.0f, 1.750876436721012e-001f
        };       
        a = new double[] { 
          1.0f, -2.299055356038497e+000f, 1.967497759984450e+000f, -8.748055564494800e-001f, 2.196539839136946e-001f
        };
        filt_txt = "Bandpass 5-50Hz";
        short_txt = "5-50 Hz";
        break;      
      default:
        //no filtering
        b = new double[] {
          1.0f
        };
        a = new double[] {
          1.0f
        };
        filt_txt = "No BP Filter";
        short_txt = "No Filter";
        b2 = new double[] {
          1.0f
        };
        a2 = new double[] {
          1.0f
        };
        filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "No Notch", "No Notch");
      }  //end switch block  

      //create the bandpass filter    
      filtCoeff_bp[Ifilt] =  new FilterConstants(b, a, filt_txt, short_txt);
    } //end loop over filters
  } //end defineFilters method 

  public String getFilterDescription() {
    return filtCoeff_bp[currentFilt_ind].name + ", " + filtCoeff_notch[currentFilt_ind].name;
  }
  public String getShortFilterDescription() {
    return filtCoeff_bp[currentFilt_ind].short_name;   
  }
  
  public void incrementFilterConfiguration() {
    //increment the index
    currentFilt_ind++;
    if (currentFilt_ind >= N_FILT_CONFIGS) currentFilt_ind = 0;
  }

  public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
        float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
        float[][] data_forDisplay_uV, //put data here that should be plotted on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //loop over each EEG channel
    for (int Ichan=0;Ichan < nchan; Ichan++) {  

      //filter the data in the time domain
      filterIIR(filtCoeff_notch[currentFilt_ind].b, filtCoeff_notch[currentFilt_ind].a, data_forDisplay_uV[Ichan]); //notch
      filterIIR(filtCoeff_bp[currentFilt_ind].b, filtCoeff_bp[currentFilt_ind].a, data_forDisplay_uV[Ichan]); //bandpass

      //compute the standard deviation of the filtered signal...this is for the head plot
      float[] fooData_filt = dataBuffY_filtY_uV[Ichan];  //use the filtered data
      fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
      data_std_uV[Ichan]=std(fooData_filt); //compute the standard deviation for the whole array "fooData_filt"
     
    } //close loop over channels
    
    //find strongest channel
    int refChanInd = findMax(data_std_uV);
    //println("EEG_Processing: strongest chan (one referenced) = " + (refChanInd+1));
    float[] refData_uV = dataBuffY_filtY_uV[refChanInd];  //use the filtered data
    refData_uV = Arrays.copyOfRange(refData_uV, refData_uV.length-((int)fs_Hz), refData_uV.length);   //just grab the most recent second of data
      
    
    //compute polarity of each channel
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      float[] fooData_filt = dataBuffY_filtY_uV[Ichan];  //use the filtered data
      fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
      float dotProd = calcDotProduct(fooData_filt,refData_uV);
      if (dotProd >= 0.0f) {
        polarity[Ichan]=1.0f;
      } else {
        polarity[Ichan]=-1.0f;
      }
      
    }    
  }
}


////////////////////////////////////////////////////
//
// This class creates and manages all of the graphical user interface (GUI) elements
// for the primary display.  This is the display with the head, with the FFT frequency
// traces, and with the montage of time-domain traces.  It also holds all of the buttons.
//
// Chip Audette, Oct 2013 - May 2014
//
// Requires the plotting library from gwoptics.  Built on gwoptics 0.5.0
// http://www.gwoptics.org/processing/gwoptics_p5lib/
//
///////////////////////////////////////////////////


//import processing.core.PApplet;






 //for FFT
 //for Array.copyOfRange()

class Gui_Manager {
  ScatterTrace montageTrace;
  ScatterTrace_FFT fftTrace;
  Graph2D gMontage, gFFT, gSpectrogram;
  GridBackground gbMontage, gbFFT;
  Button stopButton;
  PlotFontInfo fontInfo;
  HeadPlot headPlot1;
  Button[] chanButtons;
  // Button guiPageButton;
  //boolean showImpedanceButtons;
  Button[] impedanceButtonsP;
  Button[] impedanceButtonsN;
  Button biasButton;
  Button intensityFactorButton;
  Button loglinPlotButton;
  Button filtBPButton;
  Button fftNButton;
  Button smoothingButton;
  Button maxDisplayFreqButton;
  Button showPolarityButton;

  //these two buttons toggle between EEG graph state (they are mutually exclusive states)
  Button showMontageButton; // to show uV time graph as opposed to channel controller
  Button showChannelControllerButton; //to drawChannelController on top of gMontage
  boolean isChannelControllerVisible;

  TextBox titleMontage, titleFFT,titleSpectrogram;
  TextBox[] chanValuesMontage;
  TextBox[] impValuesMontage;
  boolean showMontageValues;
  public int guiPage;
  boolean vertScaleAsLog = true;
  Spectrogram spectrogram;
  boolean showSpectrogram;
  int whichChannelForSpectrogram;

  //define some color variables
  int bgColorGraphs = 255;
  int gridColor = 200;
  int borderColor = 50;
  int axisColor = 50;
  int fontColor = 255;

  // MontageController mc;
  ChannelController cc;
  
  private float fftYOffset[];
  private float default_vertScale_uV=200.0f; //this defines the Y-scale on the montage plots...this is the vertical space between traces
  private float[] vertScaleFactor = {1.0f, 2.0f, 5.0f, 50.0f, 0.25f, 0.5f};
  private int vertScaleFactor_ind = 0;
  float vertScale_uV=default_vertScale_uV;
  float vertScaleMin_uV_whenLog = 0.1f;
  float montage_yoffsets[];
  private float[] maxDisplayFreq_Hz = {20.0f, 40.0f, 60.0f, 120.0f};
  private int maxDisplayFreq_ind = 2;
  
  public final static int GUI_PAGE_CHANNEL_ONOFF = 0;
  public final static int GUI_PAGE_IMPEDANCE_CHECK = 1;
  public final static int GUI_PAGE_HEADPLOT_SETUP = 2;
  public final static int N_GUI_PAGES = 3;
  
  public final static String stopButton_pressToStop_txt = "Stop Data Stream";
  public final static String stopButton_pressToStart_txt = "Start Data Stream";
  
  Gui_Manager(PApplet parent,int win_x, int win_y,int nchan,float displayTime_sec, float default_yScale_uV, 
    String filterDescription, float smooth_fac) {  
//  Gui_Manager(PApplet parent,int win_x, int win_y,int nchan,float displayTime_sec, float yScale_uV, float fs_Hz,
//      String montageFilterText, String detectName) {
    showSpectrogram = false;  
    whichChannelForSpectrogram = 0; //assume
    
     //define some layout parameters
    float axes_x, axes_y;
    float spacer_bottom = 30/PApplet.parseFloat(win_y); //want this to be a fixed 30 pixels
    float spacer_top = PApplet.parseFloat(controlPanelCollapser.but_dy)/PApplet.parseFloat(win_y);
    float gutter_topbot = 0.03f;
    float gutter_left = 0.08f;  //edge around the GUI
    float gutter_right = 0.015f;  //edge around the GUI
    float height_UI_tray = 0.1f + spacer_bottom; //0.1f;//0.10f;  //empty space along bottom for UI elements
    float left_right_split = 0.45f;  //notional dividing line between left and right plots, measured from left
    float available_top2bot = 1.0f - 2*gutter_topbot - height_UI_tray;
    float up_down_split = 0.5f;   //notional dividing line between top and bottom plots, measured from top
    float gutter_between_buttons = 0.005f; //space between buttons
    float title_gutter = 0.02f;
    float headPlot_fromTop = 0.12f;
    fontInfo = new PlotFontInfo();

    //montage control panel variables
    // float x_cc = float(win_x)*(left_right_split+gutter_right - 0.01f);
    float x_cc = 5;
    // float y_cc = float(win_y)*(gutter_topbot+title_gutter+spacer_top);
    float y_cc = PApplet.parseFloat(win_y)*(height_UI_tray);
    float w_cc = PApplet.parseFloat(win_x)*(0.09f-gutter_right); //width of montage controls (on left of montage)
    float h_cc = PApplet.parseFloat(win_y)*(available_top2bot-title_gutter-spacer_top); //height of montage controls (on left of montage)
  
    //setup the montage plot...the right side 
    default_vertScale_uV = default_yScale_uV;  //here is the vertical scaling of the traces
    // float[] axisMontage_relPos = { 
    //   left_right_split+gutter_left, 
    //   gutter_topbot+title_gutter+spacer_top, 
    //   (1.0f-left_right_split)-gutter_left-gutter_right, 
    //   available_top2bot-title_gutter-spacer_top
    // }; //from left, from top, width, height

    float[] axisMontage_relPos = {  
      gutter_left, 
      height_UI_tray, 
      (1.0f-left_right_split)-gutter_left-gutter_right, 
      available_top2bot-title_gutter-spacer_top
    }; //from left, from top, width, height
    axes_x = PApplet.parseFloat(win_x)*axisMontage_relPos[2];  //width of the axis in pixels
    axes_y = PApplet.parseFloat(win_y)*axisMontage_relPos[3];  //height of the axis in pixels
    gMontage = new Graph2D(parent, PApplet.parseInt(axes_x), PApplet.parseInt(axes_y), false);  //last argument is whether the axes cross at zero
    setupMontagePlot(gMontage, win_x, win_y, axisMontage_relPos,displayTime_sec,fontInfo,filterDescription);

    println("Buttons: " + PApplet.parseInt(PApplet.parseFloat(win_x)*axisMontage_relPos[0]) + ", " + (PApplet.parseInt(PApplet.parseFloat(win_y)*axisMontage_relPos[1])-40));

    showMontageButton = new Button (PApplet.parseInt(PApplet.parseFloat(win_x)*axisMontage_relPos[0]) - 1, PApplet.parseInt(PApplet.parseFloat(win_y)*axisMontage_relPos[1])-45, 125, 21, "EEG DATA", 14); 
    showMontageButton.makeDropdownButton(true);
    showMontageButton.setColorPressed(color(184,220,105));
    showMontageButton.setColorNotPressed(color(255));
    showMontageButton.hasStroke(false);
    showMontageButton.setIsActive(true);
    showMontageButton.buttonFont = f1;
    showMontageButton.textColorActive = bgColor;


    showChannelControllerButton = new Button (PApplet.parseInt(PApplet.parseFloat(win_x)*axisMontage_relPos[0])+127, PApplet.parseInt(PApplet.parseFloat(win_y)*axisMontage_relPos[1])-45, 125, 21, "CHAN SET", 14);
    showChannelControllerButton.makeDropdownButton(true);
    showChannelControllerButton.setColorPressed(color(184,220,105));
    showChannelControllerButton.setColorNotPressed(color(255));
    showChannelControllerButton.hasStroke(false);
    showChannelControllerButton.setIsActive(false);
    showChannelControllerButton.textColorActive = bgColor;

    //setup montage controller
    cc = new ChannelController(x_cc, y_cc, w_cc, h_cc, axes_x, axes_y);


    //setup the FFT plot...bottom on left side
    //float height_subplot = 0.5f*(available_top2bot-2*gutter_topbot);
    // float[] axisFFT_relPos = { 
    //   gutter_left, 
    //   gutter_topbot+ up_down_split*available_top2bot + gutter_topbot+title_gutter + spacer_top, 
    //   left_right_split-gutter_left-gutter_right, 
    //   available_top2bot*(1.0f-up_down_split) - gutter_topbot-title_gutter - spacer_top
    // }; //from left, from top, width, height
    float[] axisFFT_relPos = { 
      gutter_left + left_right_split + 0.1f, 
      up_down_split*available_top2bot + height_UI_tray + gutter_topbot, 
      left_right_split-gutter_left-gutter_right, 
      available_top2bot*(1.0f-up_down_split) - gutter_topbot-title_gutter - spacer_top
    }; //from left, from top, width, height
    axes_x = PApplet.parseInt(PApplet.parseFloat(win_x)*axisFFT_relPos[2]);  //width of the axis in pixels
    axes_y = PApplet.parseInt(PApplet.parseFloat(win_y)*axisFFT_relPos[3]);  //height of the axis in pixels
    gFFT = new Graph2D(parent, PApplet.parseInt(axes_x), PApplet.parseInt(axes_y), false);  //last argument is whether the axes cross at zero
    setupFFTPlot(gFFT, win_x, win_y, axisFFT_relPos,fontInfo);
        
    //setup the spectrogram plot
//    float[] axisSpectrogram_relPos = axisMontage_relPos;
//    axes_x = int(float(win_x)*axisSpectrogram_relPos[2]);
//    axes_y = int(float(win_y)*axisSpectrogram_relPos[3]);
//    gSpectrogram = new Graph2D(parent, axes_x, axes_y, false);  //last argument is wheter the axes cross at zero
//    setupSpectrogram(gSpectrogram, win_x, win_y, axisMontage_relPos,displayTime_sec,fontInfo);
//    int Nspec = 256;
//    int Nstep = 32;
//    spectrogram = new Spectrogram(Nspec,openBCI.fs_Hz,Nstep,displayTime_sec);
//    spectrogram.clim[0] = java.lang.Math.log(gFFT.getYAxis().getMinValue());   //set the minium value for the color scale on the spectrogram
//    spectrogram.clim[1] = java.lang.Math.log(gFFT.getYAxis().getMaxValue()/10.0); //set the maximum value for the color scale on the spectrogram
//    updateMaxDisplayFreq();
    
    //setup the head plot...top on the left side
    float[] axisHead_relPos = axisFFT_relPos.clone();
    // axisHead_relPos[1] = gutter_topbot + spacer_top;  //set y position to be at top of left side
    axisHead_relPos[1] = headPlot_fromTop;  //set y position to be at top of right side
    axisHead_relPos[3] = available_top2bot*up_down_split  - gutter_topbot;
    headPlot1 = new HeadPlot(axisHead_relPos[0],axisHead_relPos[1],axisHead_relPos[2],axisHead_relPos[3],win_x,win_y,nchan);
    setSmoothFac(smooth_fac);
    
    //setup the buttons
    int w,h,x,y;
           
    //setup stop button
    w = 120;    //button width
    h = 26;     //button height, was 25
    // x = win_x - int(gutter_right*float(win_x)) - w;
    x = width/2 - w;
    // y = win_y - int(0.5*gutter_topbot*float(win_y)) - h - int(spacer_bottom*(float(win_y)));
    // y = int(0.5*gutter_topbot*float(win_y));
    y = 2;
    //int y = win_y - h;
    stopButton = new Button(x,y,w,h,stopButton_pressToStart_txt,fontInfo.buttonLabel_size);
    
    //setup the gui page button

    w = 80; //button width
    x = (int)((3*gutter_between_buttons + left_right_split) * win_x);

    // x = int(float(win_x)*0.3f);
    // guiPageButton = new Button(x,y,w,h,"Page\n" + (guiPage+1) + " of " + N_GUI_PAGES,fontInfo.buttonLabel_size);
        
    //setup the channel on/off buttons...only plot 8 buttons, even if there are more channels
    //because as of 4/3/2014, you can only turn on/off the higher channels (the ones above chan 8)
    //by also turning off the corresponding lower channel.  So, deactiving channel 9 must also
    //deactivate channel 1, therefore, we might as well use just the 1 button.
    // int xoffset = x + w + (int)(2*gutter_between_buttons*win_x);
    // int xoffset = (int)(float(win_x)*gutter_left);
    int xoffset = (int)(PApplet.parseFloat(win_x)*0.5f);

    w = 80;   //button width
    int w_orig = w;
    //if (nchan > 10) w -= (nchan-8)*2; //make the buttons skinnier
    int nChanBut = min(nchan,8);
    chanButtons = new Button[nChanBut];
    String txt;
    for (int Ibut = 0; Ibut < nChanBut; Ibut++) {
      x = calcButtonXLocation(Ibut, win_x, w, xoffset,gutter_between_buttons);
      txt = "Chan\n" + Integer.toString(Ibut+1);
      if (nchan > 8+Ibut) txt = txt + "+" + Integer.toString(Ibut+1+8);
      chanButtons[Ibut] = new Button(x,y,w,h,txt,fontInfo.buttonLabel_size);
    }
    
    //setup the impedance measurement (lead-off) control buttons
    //showImpedanceButtons = false; //by default, do not show the buttons
    int vertspace_pix = max(1,PApplet.parseInt(gutter_between_buttons*win_x/4));
    int w1 = w_orig;  //use same width as for buttons above
    int h1 = h/2-vertspace_pix;  //use buttons with half the height
    impedanceButtonsP = new Button[nchan];
    for (int Ibut = 0; Ibut < nchan; Ibut++) {
      x = calcButtonXLocation(Ibut, win_x, w1, xoffset, gutter_between_buttons);
      impedanceButtonsP[Ibut] = new Button(x,y,w1,h1,"Imp P" + (Ibut+1),fontInfo.buttonLabel_size);
    }    
    impedanceButtonsN = new Button[nchan];
    for (int Ibut = 0; Ibut < nchan; Ibut++) {
      x = calcButtonXLocation(Ibut, win_x, w1, xoffset, gutter_between_buttons);
      impedanceButtonsN[Ibut] = new Button(x,y+h-h1,w1,h1,"Imp N" + (Ibut+1),fontInfo.buttonLabel_size);
    }
    h1 = h;
    x = calcButtonXLocation(nchan, win_x, w1, xoffset, gutter_between_buttons);
    biasButton = new Button(x,y,w1,h1,"Bias\n" + "Auto",fontInfo.buttonLabel_size);


    //setup the buttons to control the processing and frequency displays
    int Ibut=0;    
    w = 70;    
    h = 26;
    y = 2;

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    maxDisplayFreqButton = new Button(x,y,w,h,"Max Freq\n" + round(maxDisplayFreq_Hz[maxDisplayFreq_ind]) + " Hz",fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    showPolarityButton = new Button(x,y,w,h,"Polarity\n" + headPlot1.getUsePolarityTrueFalse(),fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    smoothingButton = new Button(x,y,w,h,"Smooth\n" + headPlot1.smooth_fac,fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    loglinPlotButton = new Button(x,y,w,h,"Vert Scale\n" + get_vertScaleAsLogText(),fontInfo.buttonLabel_size);

    //x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    //fftNButton = new Button(x,y,w,h,"FFT N\n" + Nfft,fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    intensityFactorButton = new Button(x,y,w,h,"Vert Scale\n" + round(vertScale_uV) + "uV",fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    filtBPButton = new Button(x,y,w,h,"BP Filt\n" + eegProcessing.getShortFilterDescription(),fontInfo.buttonLabel_size);

    set_vertScaleAsLog(true);

    //set the initial display page for the GUI
    setGUIpage(GUI_PAGE_HEADPLOT_SETUP);  
  } 
  private int calcButtonXLocation(int Ibut,int win_x,int w, int xoffset, float gutter_between_buttons) {
    // return xoffset + (Ibut * (w + (int)(gutter_between_buttons*win_x)));
    return width - ((Ibut+1) * (w + 2)) - 1;
  }
  
  public void setDefaultVertScale(float val_uV) {
    default_vertScale_uV = val_uV;
    updateVertScale();
  }
  public void setVertScaleFactor_ind(int ind) {
    vertScaleFactor_ind = max(0,ind);
    if (ind >= vertScaleFactor.length) vertScaleFactor_ind = 0;
    updateVertScale();
  }
  public void incrementVertScaleFactor() {
    setVertScaleFactor_ind(vertScaleFactor_ind+1);  //wrap-around is handled inside the function
  }
  public void updateVertScale() {
    vertScale_uV = default_vertScale_uV*vertScaleFactor[vertScaleFactor_ind];
    //println("Gui_Manager: updateVertScale: vertScale_uV = " + vertScale_uV);
    
    //update how the plots are scaled
    if (montageTrace != null) montageTrace.setYScale_uV(vertScale_uV);  //the Y-axis on the montage plot is fixed...the data is simply scaled prior to plotting
    if (gFFT != null) gFFT.setYAxisMax(vertScale_uV);
    headPlot1.setMaxIntensity_uV(vertScale_uV);
    intensityFactorButton.setString("Vert Scale\n" + round(vertScale_uV) + "uV");
    
    //update the Yticks on the FFT plot
    if (gFFT != null) {
      if (vertScaleAsLog) {
        gFFT.setYAxisTickSpacing(1);
      } else {
        gFFT.setYAxisTickSpacing(pow(10.0f,floor(log10(vertScale_uV/4))));
      }
    }
    
  }
  public String get_vertScaleAsLogText() {
    if (vertScaleAsLog) {
      return "Log";
    } else {
      return "Linear";
    }
  }
  public void set_vertScaleAsLog(boolean state) {
    vertScaleAsLog = state;
    
    //change the FFT Plot
    if (gFFT != null) {
      if (vertScaleAsLog) {
          gFFT.setYAxisMin(vertScaleMin_uV_whenLog);
          Axis2D ay=gFFT.getYAxis();
          ay.setLogarithmicAxis(true);
          updateVertScale();  //force a re-do of the Yticks
      } else {
          Axis2D ay=gFFT.getYAxis();
          ay.setLogarithmicAxis(false);
          gFFT.setYAxisMin(0.0f);
          updateVertScale();  //force a re-do of the Yticks
      }
    }
    
    //change the head plot
    headPlot1.set_plotColorAsLog(vertScaleAsLog);
    
    //change the button
    if (loglinPlotButton != null) {
      loglinPlotButton.setString("Vert Scale\n" + get_vertScaleAsLogText());
    }
  }
  
  public void setSmoothFac(float fac) {
    headPlot1.smooth_fac = fac;
  }
  
  public void setMaxDisplayFreq_ind(int ind) {
    maxDisplayFreq_ind = max(0,ind);
    if (ind >= maxDisplayFreq_Hz.length) maxDisplayFreq_ind = 0;
    updateMaxDisplayFreq();
  }
  public void incrementMaxDisplayFreq() {
    setMaxDisplayFreq_ind(maxDisplayFreq_ind+1);  //wrap-around is handled inside the function
  }
  public void updateMaxDisplayFreq() {
    //set the frequency limit of the display
    float foo_Hz = maxDisplayFreq_Hz[maxDisplayFreq_ind];
    gFFT.setXAxisMax(foo_Hz);
    if (fftTrace != null) fftTrace.set_plotXlim(0.0f,foo_Hz);
    //gSpectrogram.setYAxisMax(foo_Hz);
    
    //set the ticks
    if (foo_Hz < 38.0f) {
      foo_Hz = 5.0f;
    } else if (foo_Hz < 78.0f) {
      foo_Hz = 10.0f;
    } else if (foo_Hz < 168.0f) {
      foo_Hz = 20.0f;
    } else {
      foo_Hz = (float)floor(foo_Hz / 50.0f) * 50.0f;
    }
    gFFT.setXAxisTickSpacing(foo_Hz);
    //gSpectrogram.setYAxisTickSpacing(foo_Hz);
    
    if (maxDisplayFreqButton != null) maxDisplayFreqButton.setString("Max Freq\n" + round(maxDisplayFreq_Hz[maxDisplayFreq_ind]) + " Hz");
  }  
  
  
  public void setDoNotPlotOutsideXlim(boolean state) {
    if (state) {
      //println("GUI_Manager: setDoNotPlotAboveXlim: " + gFFT.getXAxis().getMaxValue());
      fftTrace.set_plotXlim(gFFT.getXAxis().getMinValue(),gFFT.getXAxis().getMaxValue());
      montageTrace.set_plotXlim(gMontage.getXAxis().getMinValue(),gMontage.getXAxis().getMaxValue());
    } else {
      fftTrace.set_plotXlim(Float.NaN,Float.NaN);
    }
  }
  public void setDecimateFactor(int fac) {
    montageTrace.setDecimateFactor(fac);
  }
    
  public void setupMontagePlot(Graph2D g, int win_x, int win_y, float[] axis_relPos,float displayTime_sec, PlotFontInfo fontInfo,String filterDescription) {
  
    g.setAxisColour(axisColor, axisColor, axisColor);
    g.setFontColour(fontColor, fontColor, fontColor);
  
    int x1,y1;
    x1 = PApplet.parseInt(axis_relPos[0]*PApplet.parseFloat(win_x));
    g.position.x = x1;
    y1 = PApplet.parseInt(axis_relPos[1]*PApplet.parseFloat(win_y));
    g.position.y = y1;
    //g.position.y = 0;
  
    g.setYAxisMin(-nchan-1.0f);
    g.setYAxisMax(0.0f);
    g.setYAxisTickSpacing(1f);
    g.setYAxisMinorTicks(0);
    g.setYAxisLabelAccuracy(0);
    g.setYAxisLabel("EEG Channel");
    g.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, true);
    g.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
    g.setXAxisMin(-displayTime_sec);
    g.setXAxisMax(0f);
    g.setXAxisTickSpacing(1f);
    g.setXAxisMinorTicks(1);
    g.setXAxisLabelAccuracy(0);
    g.setXAxisLabel("Time (sec)");
    g.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
    // switching on Grid, with different colours for X and Y lines
    gbMontage = new  GridBackground(new GWColour(bgColorGraphs));
    gbMontage.setGridColour(gridColor, gridColor, gridColor, gridColor, gridColor, gridColor);
    g.setBackground(gbMontage);

    g.setBorderColour(borderColor,borderColor,borderColor);
    
    // add title
    titleMontage = new TextBox("EEG Data (" + filterDescription + ")",0,0);
    int x2 = x1 + PApplet.parseInt(round(0.5f*axis_relPos[2]*PApplet.parseFloat(win_x)));
    int y2 = y1 - 2;  //deflect two pixels upward
    titleMontage.x = x2;
    titleMontage.y = y2;
    titleMontage.textColor = color(bgColor);
    titleMontage.setFontSize(14);
    titleMontage.alignH = CENTER;
    
    //add channel data values and impedance values
    int x3, y3;
    //float w = int(round(axis_relPos[2]*win_x));
    TextBox fooBox = new TextBox("",0,0); 
    chanValuesMontage = new TextBox[nchan];
    impValuesMontage = new TextBox[nchan];
    Axis2D xAxis = g.getXAxis();
    Axis2D yAxis = g.getYAxis();
    int h = PApplet.parseInt(round(axis_relPos[3]*win_y));
    for (int i=0; i<nchan; i++) {
      y3 = y1 + h - yAxis.valueToPosition((float)(-(i+1))); //set to be on the centerline of the trace
      for (int j=0; j<2; j++) { //loop over the different text box types
        switch (j) {
          case 0:
            //voltage value text
            x3 = x1 + xAxis.valueToPosition(xAxis.getMaxValue()) - 2;  //set to right edge of plot.  nudge 2 pixels to the left
            fooBox = new TextBox("0.00 uVrms",x3,y3);
            break;
          case 1:
            //impedance value text
            x3 = x1 + xAxis.valueToPosition(xAxis.getMinValue()) + 2;  //set to left edge of plot.  nudge 2 pixels to the right
            fooBox = new TextBox("0.00 kOhm",x3,y3);
            break;
        }
        fooBox.textColor = color(0,0,0);
        fooBox.drawBackground = true;
        fooBox.backgroundColor = color(255,255,255, 125);
        noStroke();
        switch (j) {
          case 0:
            //voltage value text
            fooBox.alignH = RIGHT;
            chanValuesMontage[i] = fooBox;
            break;
          case 1:
            //impedance value text
            fooBox.alignH = LEFT;
            impValuesMontage[i] = fooBox;
            break;
        }
      }
    }
    showMontageValues = true;  // default to having them NOT displayed    
  }
  
  public void setupFFTPlot(Graph2D g, int win_x, int win_y, float[] axis_relPos,PlotFontInfo fontInfo) {
  
    g.setAxisColour(axisColor, axisColor, axisColor);
    g.setFontColour(fontColor, fontColor, fontColor);
  
    int x1,y1;
    x1 = PApplet.parseInt(axis_relPos[0]*PApplet.parseFloat(win_x));
    g.position.x = x1;
    y1 = PApplet.parseInt(axis_relPos[1]*PApplet.parseFloat(win_y));
    g.position.y = y1;
    //g.position.y = 0;
  
    //setup the y axis
    g.setYAxisMin(vertScaleMin_uV_whenLog);
    g.setYAxisMax(vertScale_uV);
    g.setYAxisTickSpacing(1);
    g.setYAxisMinorTicks(0);
    g.setYAxisLabelAccuracy(0);
    //g.setYAxisLabel("EEG Amplitude (uV/sqrt(Hz))");  // Some people prefer this...but you'll have to change the normalization in OpenBCI_GUI\processNewData()
    g.setYAxisLabel("EEG Amplitude (uV per bin)");  // CHIP 2014-10-24...currently, this matches the normalization in OpenBCI_GUI\processNewData()
    g.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
    //get the Y-axis and make it log
    Axis2D ay=g.getYAxis();
    ay.setLogarithmicAxis(true);
  
    //setup the x axis
    g.setXAxisMin(0f);
    g.setXAxisMax(maxDisplayFreq_Hz[maxDisplayFreq_ind]);
    g.setXAxisTickSpacing(10f);
    g.setXAxisMinorTicks(2);
    g.setXAxisLabelAccuracy(0);
    g.setXAxisLabel("Frequency (Hz)");
    g.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
  
    // switching on Grid, with differetn colours for X and Y lines
    gbFFT = new  GridBackground(new GWColour(bgColorGraphs));
    gbFFT.setGridColour(gridColor, gridColor, gridColor, gridColor, gridColor, gridColor);
    g.setBackground(gbFFT);

    g.setBorderColour(borderColor,borderColor,borderColor);
    
    // add title
    titleFFT = new TextBox("EEG Data (As Received)",0,0);
    int x2 = x1 + PApplet.parseInt(round(0.5f*axis_relPos[2]*PApplet.parseFloat(win_x)));
    int y2 = y1 - 2;  //deflect two pixels upward
    titleFFT.x = x2;
    titleFFT.y = y2;
    titleFFT.textColor = color(255,255,255);
    titleFFT.setFontSize(16);
    titleFFT.alignH = CENTER;
  }
  
  public void setupSpectrogram(Graph2D g, int win_x, int win_y, float[] axis_relPos,float displayTime_sec, PlotFontInfo fontInfo) {
    //start by setting up as if it were the montage plot
    //setupMontagePlot(g, win_x, win_y, axis_relPos,displayTime_sec,fontInfo,title);
    
    g.setAxisColour(220, 220, 220);
    g.setFontColour(255, 255, 255);
  
    int x1 = PApplet.parseInt(axis_relPos[0]*PApplet.parseFloat(win_x));
    g.position.x = x1;
    int y1 = PApplet.parseInt(axis_relPos[1]*PApplet.parseFloat(win_y));
    g.position.y = y1;
    
    //setup the x axis
    g.setXAxisMin(-displayTime_sec);
    g.setXAxisMax(0f);
    g.setXAxisTickSpacing(1f);
    g.setXAxisMinorTicks(1);
    g.setXAxisLabelAccuracy(0);
    g.setXAxisLabel("Time (sec)");
    g.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
 
    //setup the y axis...frequency
    g.setYAxisMin(0.0f-0.5f);
    g.setYAxisMax(maxDisplayFreq_Hz[maxDisplayFreq_ind]);
    g.setYAxisTickSpacing(10.0f);
    g.setYAxisMinorTicks(2);
    g.setYAxisLabelAccuracy(0);
    g.setYAxisLabel("Frequency (Hz)");
    g.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
        
        
    //make title
    titleSpectrogram = new TextBox(makeSpectrogramTitle(),0,0);
    int x2 = x1 + PApplet.parseInt(round(0.5f*axis_relPos[2]*PApplet.parseFloat(win_x)));
    int y2 = y1 - 2;  //deflect two pixels upward
    titleSpectrogram.x = x2;
    titleSpectrogram.y = y2;
    titleSpectrogram.textColor = color(255,255,255);
    titleSpectrogram.setFontSize(16);
    titleSpectrogram.alignH = CENTER;
  }
  
  public void initializeMontageTraces(float[] dataBuffX, float [][] dataBuffY) {
    
    //create the trace object, add it to the  plotting object, and set the data and scale factor
    //montageTrace  = new ScatterTrace();  //I can't have this here because it dies. It must be in setup()
    gMontage.addTrace(montageTrace);
    montageTrace.setXYData_byRef(dataBuffX, dataBuffY);
    montageTrace.setYScaleFac(1f / vertScale_uV);
    //montageTrace.setYScaleFac(1.0f); //for OpenBCI_GUI_Simpler
    
    //set the y-offsets for each trace in the fft plot.
    //have each trace bumped down by -1.0.
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      montage_yoffsets[Ichan]=(float)(-(Ichan+1));
    }
    montageTrace.setYOffset_byRef(montage_yoffsets);
  }
  
  
  public void initializeFFTTraces(ScatterTrace_FFT fftTrace,FFT[] fftBuff,float[] fftYOffset,Graph2D gFFT) {
    for (int Ichan = 0; Ichan < fftYOffset.length; Ichan++) {
      //set the Y-offste for the individual traces in the plots
      fftYOffset[Ichan]= 0f;  //set so that there is no additional offset
    }
    
    //make the trace for the FFT and add it to the FFT Plot axis
    //fftTrace = new ScatterTrace_FFT(fftBuff); //can't put this here...must be in setup()
    fftTrace.setYOffset(fftYOffset);
    gFFT.addTrace(fftTrace);
  }
    
    
  public void initDataTraces(float[] dataBuffX,float[][] dataBuffY,FFT[] fftBuff,float[] dataBuffY_std, DataStatus[] is_railed, float[] dataBuffY_polarity) {      
    //initialize the time-domain montage-plot traces
    montageTrace = new ScatterTrace();
    montage_yoffsets = new float[nchan];
    initializeMontageTraces(dataBuffX,dataBuffY);
    montageTrace.set_isRailed(is_railed);
  
    //initialize the FFT traces
    fftTrace = new ScatterTrace_FFT(fftBuff); //can't put this here...must be in setup()
    fftYOffset = new float[nchan];
    initializeFFTTraces(fftTrace,fftBuff,fftYOffset,gFFT);
    
    //link the data to the head plot
    headPlot1.setIntensityData_byRef(dataBuffY_std,is_railed);
    headPlot1.setPolarityData_byRef(dataBuffY_polarity);
  }

  public void setShowSpectrogram(boolean show) {
    showSpectrogram = show;
  } 

  public void tellGUIWhichChannelForSpectrogram(int Ichan) { // Ichan starts at zero
    if (Ichan != whichChannelForSpectrogram) {
      whichChannelForSpectrogram = Ichan;
      titleSpectrogram.string = makeSpectrogramTitle();
    }
  }
  public String makeSpectrogramTitle() {
    return ("Spectrogram, Channel " + (whichChannelForSpectrogram+1) + " (As Received)");
  }
  
 
  public void setGUIpage(int page) {
    if ((page >= 0) && (page < N_GUI_PAGES)) {
      guiPage = page;
    } else {
      guiPage = 0;
    }
    //update the text on the button
    // guiPageButton.setString("Page\n" + (guiPage+1) + " of " + N_GUI_PAGES);
  }
  
  public void incrementGUIpage() {
    setGUIpage( (guiPage+1) % N_GUI_PAGES );
  }
  
  public boolean isMouseOnGraph2D(Graph2D g, int mouse_x, int mouse_y) {
    GraphDataPoint dataPoint = new GraphDataPoint();
    getGraph2DdataPoint(g,mouse_x,mouse_y,dataPoint);
    if ( (dataPoint.x >= g.getXAxis().getMinValue()) &
         (dataPoint.x <= g.getXAxis().getMaxValue()) &
         (dataPoint.y >= g.getYAxis().getMinValue()) &
         (dataPoint.y <= g.getYAxis().getMaxValue()) ) {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean isMouseOnMontage(int mouse_x, int mouse_y) {
    return isMouseOnGraph2D(gMontage,mouse_x,mouse_y);
  }
  public boolean isMouseOnFFT(int mouse_x, int mouse_y) {
    return isMouseOnGraph2D(gFFT,mouse_x,mouse_y);
  }

  public void getGraph2DdataPoint(Graph2D g, int mouse_x,int mouse_y, GraphDataPoint dataPoint) {
    int rel_x = mouse_x - PApplet.parseInt(g.position.x);
    int rel_y = g.getYAxis().getLength() - (mouse_y - PApplet.parseInt(g.position.y));
    dataPoint.x = g.getXAxis().positionToValue(rel_x);
    dataPoint.y = g.getYAxis().positionToValue(rel_y);
  }
  public void getMontageDataPoint(int mouse_x, int mouse_y, GraphDataPoint dataPoint) {
    getGraph2DdataPoint(gMontage,mouse_x,mouse_y,dataPoint);
    dataPoint.x_units = "sec";
    dataPoint.y_units = "uV";  
  }  
  public void getFFTdataPoint(int mouse_x,int mouse_y,GraphDataPoint dataPoint) {
    getGraph2DdataPoint(gFFT, mouse_x,mouse_y,dataPoint);
    dataPoint.x_units = "Hz";
    dataPoint.y_units = "uV/sqrt(Hz)";
  }
    
//  public boolean isMouseOnHeadPlot(int mouse_x, int mouse_y) {
//    return headPlot1.isPixelInsideHead(mouse_x,mouse_y) {
//  }
  
  public void update(float[] data_std_uV,float[] data_elec_imp_ohm) {
    //assume new data has already arrived via the pre-existing references to dataBuffX and dataBuffY and FftBuff
    montageTrace.generate();  //graph doesn't update without this
    fftTrace.generate(); //graph doesn't update without this
    headPlot1.update();
    cc.update();

    //update the text strings
    String fmt; float val;
    for (int Ichan=0; Ichan < data_std_uV.length; Ichan++) {
      //update the voltage values
      val = data_std_uV[Ichan];
      chanValuesMontage[Ichan].string = String.format(getFmt(val),val) + " uVrms";
      if (montageTrace.is_railed != null) {
        if (montageTrace.is_railed[Ichan].is_railed == true) {
          chanValuesMontage[Ichan].string = "RAILED";
        } else if (montageTrace.is_railed[Ichan].is_railed_warn == true) {
          chanValuesMontage[Ichan].string = "NEAR RAILED";
        }
      } 
      
      //update the impedance values
      val = data_elec_imp_ohm[Ichan]/1000;
      impValuesMontage[Ichan].string = String.format(getFmt(val),val) + " kOhm";
      if (montageTrace.is_railed != null) {
        if (montageTrace.is_railed[Ichan].is_railed == true) {
          impValuesMontage[Ichan].string = "RAILED";
        }
      }
    }
  }
  
  private String getFmt(float val) {
    String fmt;
      if (val > 100.0f) {
        fmt = "%.0f";
      } else if (val > 10.0f) {
        fmt = "%.1f";
      } else {
        fmt = "%.2f";
      }
      return fmt;
  }
  
  public void draw() {
    headPlot1.draw();
    
    //draw montage or spectrogram
    if (showSpectrogram == false) {

      //show time-domain montage, only if full channel controller is not visible, to save some processing
      gMontage.draw(); 
    
      //add annotations
      if (showMontageValues) {
        for (int Ichan = 0; Ichan < chanValuesMontage.length; Ichan++) {
          chanValuesMontage[Ichan].draw();
        }
      }
    } else {
      //show the spectrogram
      gSpectrogram.draw();  //draw the spectrogram axes
      titleSpectrogram.draw(); //draw the spectrogram title

      //draw the spectrogram image
      PVector pos = gSpectrogram.position;
      Axis2D ax = gSpectrogram.getXAxis();
      int x = ax.valueToPosition(ax.getMinValue())+(int)pos.x;
      int w = ax.valueToPosition(ax.getMaxValue());
      ax = gSpectrogram.getYAxis();
      int y =  (int) pos.y - ax.valueToPosition(ax.getMinValue()); //position needs top-left.  The MAX value is at the top-left for this plot.
      int h = ax.valueToPosition(ax.getMaxValue());
      //println("gui_Manager.draw(): x,y,w,h = " + x + " " + y + " " + w + " " + h);
      float max_freq_Hz = gSpectrogram.getYAxis().getMaxValue()-0.5f;
      spectrogram.draw(x,y,w,h,max_freq_Hz);
    }

    //draw the regular FFT spectrum display
    gFFT.draw(); 
    titleFFT.draw();//println("completed FFT draw..."); 
   
    //draw the UI buttons and other elements 
    stopButton.draw();

    //commented out because pages 1-2 are being moved to the left of the EEG montage
    // guiPageButton.draw();

    switch (guiPage) {  //the rest of the elements depend upon what GUI page we're on
      //note: GUI_PAGE_CHANNEL_ON_OFF is the default at the end
      case GUI_PAGE_IMPEDANCE_CHECK:
        //show impedance buttons and text
        for (int Ichan = 0; Ichan < chanButtons.length; Ichan++) {
          impedanceButtonsP[Ichan].draw(); //P-channel buttons
          impedanceButtonsN[Ichan].draw(); //N-channel buttons
        }
        for (int Ichan = 0; Ichan < impValuesMontage.length; Ichan++) {
          impValuesMontage[Ichan].draw();  //impedance values on montage plot
        }
        biasButton.draw();
        break;
      case GUI_PAGE_HEADPLOT_SETUP:
        intensityFactorButton.draw();
        loglinPlotButton.draw();
        filtBPButton.draw();
        //fftNButton.draw();
        smoothingButton.draw();
        showPolarityButton.draw();
        maxDisplayFreqButton.draw();
        break;
      default:  //assume GUI_PAGE_CHANNEL_ONOFF:
        //show channel buttons
        for (int Ichan = 0; Ichan < chanButtons.length; Ichan++) { chanButtons[Ichan].draw(); }
        //detectButton.draw();
        //spectrogramButton.draw();
    }
    
    if (showMontageValues) {
      for (int Ichan = 0; Ichan < chanValuesMontage.length; Ichan++) {
        chanValuesMontage[Ichan].draw();
      }
    }

    // if(controlPanelCollapser.isActive){
    //   controlPanel.draw();
    // }
    // controlPanelCollapser.draw();

    cc.draw();
    if(cc.showFullController == false){
      titleMontage.draw();
    }
    showMontageButton.draw();
    showChannelControllerButton.draw();

  }

  public void mousePressed(){
    verbosePrint("gui.mousePressed();");
    //if showMontage button pressed
    if(showMontageButton.isMouseHere()){
      //turn off visibility of channel full controller
      cc.showFullController = false;
      showMontageButton.setIsActive(true);
      showMontageButton.buttonFont = f1;
      showChannelControllerButton.setIsActive(false);
      showChannelControllerButton.buttonFont = f2;
    }
    //if showChannelController is pressed
    if(showChannelControllerButton.isMouseHere()){
      cc.showFullController = true;
      showMontageButton.setIsActive(false);
      showMontageButton.buttonFont = f2;
      showChannelControllerButton.setIsActive(true);
      showChannelControllerButton.buttonFont = f1;
    }

    //if cursor inside channel controller
    // if(mouseX >= cc.x1 && mouseX <= (cc.x2 - cc.w2) && mouseY >= cc.y1 && mouseY <= (cc.y1 + cc.h1) ){ 
      verbosePrint("Channel Controller mouse pressed...");
      cc.mousePressed();
    // }
    

    //turn off visibility of graph
    // turn on drawing and interactivity of channel controller

    //however, the on/off & impedance values must show to the right at all times ... so it should change a boolean in ChannelController

  }

  public void mouseReleased(){
    verbosePrint("gui.mouseReleased();");

    // if(mouseX >= cc.x1 && mouseX <= (cc.x2 - cc.w2) && mouseY >= cc.y1 && mouseY <= (cc.y1 + cc.h1) ){ 
    verbosePrint("Channel Controller mouse released...");
    cc.mouseReleased();


    stopButton.setIsActive(false);
    // guiPageButton.setIsActive(false);
    intensityFactorButton.setIsActive(false);
    loglinPlotButton.setIsActive(false);
    filtBPButton.setIsActive(false);
    smoothingButton.setIsActive(false);
    showPolarityButton.setIsActive(false);
    maxDisplayFreqButton.setIsActive(false);
    biasButton.setIsActive(false);
  }
 
};





//////////////////////////////////////////////////////////////
//
// This class creates and manages the head-shaped plot used by the GUI.
// The head includes circles representing the different EEG electrodes.
// The color (brightness) of the electrodes can be adjusted so that the
// electrodes' brightness values dynamically reflect the intensity of the
// EEG signal.  All EEG processing must happen outside of this class.
//
// Created: Chip Audette, Oct 2013
//
// Note: This routine uses aliasing to know which data should be used to
// set the brightness of the electrodes.
//
///////////////////////////////////////////////////////////////

class HeadPlot {
  private float rel_posX,rel_posY,rel_width,rel_height;
  private int circ_x,circ_y,circ_diam;
  private int earL_x, earL_y, earR_x, earR_y, ear_width, ear_height;
  private int[] nose_x, nose_y;
  private float[][] electrode_xy;
  private float[] ref_electrode_xy;
  private float[][][] electrode_color_weightFac;
  private int[][] electrode_rgb;
  private float[][] headVoltage;
  private int elec_diam;
  PFont font;
  public float[] intensity_data_uV;
  public float[] polarity_data;
  private DataStatus[] is_railed;
  private float intense_min_uV=0.0f, intense_max_uV=1.0f, assumed_railed_voltage_uV=1.0f;
  private float log10_intense_min_uV = 0.0f, log10_intense_max_uV=1.0f;
  PImage headImage;
  private int image_x,image_y;
  public boolean drawHeadAsContours;
  private boolean plot_color_as_log = true;
  public float smooth_fac = 0.0f;  
  private boolean use_polarity = true;

  HeadPlot(float x,float y,float w,float h,int win_x,int win_y,int n) {
    final int n_elec = n;  //8 electrodes assumed....or 16 for 16-channel?  Change this!!!
    nose_x = new int[3];
    nose_y = new int[3];
    electrode_xy = new float[n_elec][2];   //x-y position of electrodes (pixels?) 
    //electrode_relDist = new float[n_elec][n_elec];  //relative distance between electrodes (pixels)
    ref_electrode_xy = new float[2];  //x-y position of reference electrode
    electrode_rgb = new int[3][n_elec];  //rgb color for each electrode
    font = createFont("Arial",16);
    drawHeadAsContours = true; //set this to be false for slower computers
    
    rel_posX = x;
    rel_posY = y;
    rel_width = w;
    rel_height = h;
    setWindowDimensions(win_x,win_y);
    
    setMaxIntensity_uV(200.0f);  //default intensity scaling for electrodes
  }
  
  public void setIntensityData_byRef(float[] data, DataStatus[] is_rail) {
    intensity_data_uV = data;  //simply alias the data held externally.  DOES NOT COPY THE DATA ITSEF!  IT'S SIMPLY LINKED!
    is_railed = is_rail;
  }
  
  public void setPolarityData_byRef(float[] data) {
    polarity_data = data;//simply alias the data held externally.  DOES NOT COPY THE DATA ITSEF!  IT'S SIMPLY LINKED!
    //if (polarity_data != null) use_polarity = true;
  }
  
  public String getUsePolarityTrueFalse() {
    if (use_polarity) {
      return "True";
    } else {
      return "False";
    }
  }
      
  public void setMaxIntensity_uV(float val_uV) {
    intense_max_uV = val_uV;
    intense_min_uV = intense_max_uV / 200.0f * 5.0f;  //set to 200, get 5
    assumed_railed_voltage_uV = intense_max_uV;
    
    log10_intense_max_uV = log10(intense_max_uV);
    log10_intense_min_uV = log10(intense_min_uV);
  }
  
  public void set_plotColorAsLog(boolean state) {
    plot_color_as_log = state;
  }
  
  //this method defines all locations of all the subcomponents
  public void setWindowDimensions(int win_width, int win_height){
    final int n_elec = electrode_xy.length;
    
    //define the head itself
    float nose_relLen = 0.075f;
    float nose_relWidth = 0.05f;
    float nose_relGutter = 0.02f;
    float ear_relLen = 0.15f;
    float ear_relWidth = 0.075f;   
    
    float square_width = min(rel_width*(float)win_width,
                             rel_height*(float)win_height);  //choose smaller of the two
    
    float total_width = square_width;
    float total_height = square_width;
    float nose_width = total_width * nose_relWidth;
    float nose_height = total_height * nose_relLen;
    ear_width = (int)(ear_relWidth * total_width);
    ear_height = (int)(ear_relLen * total_height);
    int circ_width_foo = (int)(total_width - 2.f*((float)ear_width)/2.0f);
    int circ_height_foo = (int)(total_height - nose_height);
    circ_diam = min(circ_width_foo,circ_height_foo);
    //println("headPlot: circ_diam: " + circ_diam);

    //locations: circle center, measured from upper left
    circ_x = (int)((rel_posX+0.5f*rel_width)*(float)win_width);                  //center of head
    circ_y = (int)((rel_posY+0.5f*rel_height)*(float)win_height + nose_height);  //center of head
    
    //locations: ear centers, measured from upper left
    earL_x = circ_x - circ_diam/2;
    earR_x = circ_x + circ_diam/2;
    earL_y = circ_y;
    earR_y = circ_y;
    
    //locations nose vertexes, measured from upper left
    nose_x[0] = circ_x - (int)((nose_relWidth/2.f)*(float)win_width);
    nose_x[1] = circ_x + (int)((nose_relWidth/2.f)*(float)win_width);
    nose_x[2] = circ_x;
    nose_y[0] = circ_y - (int)((float)circ_diam/2.0f - nose_relGutter*(float)win_height);
    nose_y[1] = nose_y[0];
    nose_y[2] = circ_y - (int)((float)circ_diam/2.0f + nose_height);


    //define the electrode positions as the relative position [-1.0 +1.0] within the head
    //remember that negative "Y" is up and positive "Y" is down
    float elec_relDiam = 0.12f; //was 0.1425 prior to 2014-03-23
    elec_diam = (int)(elec_relDiam*((float)circ_diam));
    setElectrodeLocations(n_elec,elec_relDiam);
    
    //define image to hold all of this
    image_x = PApplet.parseInt(round(circ_x - 0.5f*circ_diam - 0.5f*ear_width));
    image_y = nose_y[2];
    headImage = createImage(PApplet.parseInt(total_width),PApplet.parseInt(total_height),ARGB);
    
    //initialize the image
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        headImage.set(Ix,Iy,color(0,0,0,0));
      }
    }  
    
    //define the weighting factors to go from the electrode voltages
    //outward to the full the contour plot
    if (false) {
      //here is a simple distance-based algorithm that works every time, though
      //is not really physically accurate.  It looks decent enough
      computePixelWeightingFactors();
    } else {
      //here is the better solution that is more physical.  It involves an iterative
      //solution, which could be really slow or could fail.  If it does poorly,
      //switch to using the algorithm above.
      int n_wide_full = PApplet.parseInt(total_width); int n_tall_full = PApplet.parseInt(total_height);
      computePixelWeightingFactors_multiScale(n_wide_full,n_tall_full);
    }
  } //end of method
  
      
  private void setElectrodeLocations(int n_elec,float elec_relDiam) {
    //try loading the positions from a file
    int n_elec_to_load = n_elec+1;  //load the n_elec plus the reference electrode
    Table elec_relXY = new Table();
    String default_fname = "electrode_positions_default.txt";
    //String default_fname = "electrode_positions_12elec_scalp9.txt";
    try {
      elec_relXY = loadTable(default_fname,"header,csv"); //try loading the default file
    } catch (NullPointerException e) {};
    
    //get the default locations if the file didn't exist
    if ((elec_relXY == null) || (elec_relXY.getRowCount() < n_elec_to_load)) {
      println("headPlot: electrode position file not found or was wrong size: " + default_fname);
      println("        : using defaults...");
      elec_relXY = createDefaultElectrodeLocations(default_fname,elec_relDiam);
    }
    
    //define the actual locations of the electrodes in pixels
    for (int i=0; i < min(electrode_xy.length,elec_relXY.getRowCount()); i++) {
      electrode_xy[i][0] = circ_x+(int)(elec_relXY.getFloat(i,0)*((float)circ_diam));
      electrode_xy[i][1] = circ_y+(int)(elec_relXY.getFloat(i,1)*((float)circ_diam));
    }
    
    //the referenece electrode is last in the file
    ref_electrode_xy[0] = circ_x+(int)(elec_relXY.getFloat(elec_relXY.getRowCount()-1,0)*((float)circ_diam));
    ref_electrode_xy[1] = circ_y+(int)(elec_relXY.getFloat(elec_relXY.getRowCount()-1,1)*((float)circ_diam));
  }
  
  private Table createDefaultElectrodeLocations(String fname,float elec_relDiam) {
    
    //regular electrodes
    float[][] elec_relXY = new float[16][2]; 
    elec_relXY[0][0] = -0.125f;             elec_relXY[0][1] = -0.5f + elec_relDiam*(0.5f+0.2f); //FP1
    elec_relXY[1][0] = -elec_relXY[0][0];  elec_relXY[1][1] = elec_relXY[0][1]; //FP2
    
    elec_relXY[2][0] = -0.2f;            elec_relXY[2][1] = 0f; //C3
    elec_relXY[3][0] = -elec_relXY[2][0];  elec_relXY[3][1] = elec_relXY[2][1]; //C4
    
    elec_relXY[4][0] = -0.3425f;            elec_relXY[4][1] = 0.27f; //T5 (aka P7)
    elec_relXY[5][0] = -elec_relXY[4][0];  elec_relXY[5][1] = elec_relXY[4][1]; //T6 (aka P8)
    
    elec_relXY[6][0] = -0.125f;             elec_relXY[6][1] = +0.5f - elec_relDiam*(0.5f+0.2f); //O1
    elec_relXY[7][0] = -elec_relXY[6][0];  elec_relXY[7][1] = elec_relXY[6][1];  //O2

    elec_relXY[8][0] = elec_relXY[4][0];  elec_relXY[8][1] = -elec_relXY[4][1]; //F7
    elec_relXY[9][0] = -elec_relXY[8][0];  elec_relXY[9][1] = elec_relXY[8][1]; //F8
    
    elec_relXY[10][0] = -0.18f;            elec_relXY[10][1] = -0.15f; //C3
    elec_relXY[11][0] = -elec_relXY[10][0];  elec_relXY[11][1] = elec_relXY[10][1]; //C4    
    
    elec_relXY[12][0] =  -0.5f +elec_relDiam*(0.5f+0.15f);  elec_relXY[12][1] = 0f; //T3 (aka T7?)
    elec_relXY[13][0] = -elec_relXY[12][0];  elec_relXY[13][1] = elec_relXY[12][1]; //T4 (aka T8)    
    
    elec_relXY[14][0] = elec_relXY[10][0];   elec_relXY[14][1] = -elec_relXY[10][1]; //CP3
    elec_relXY[15][0] = -elec_relXY[14][0];  elec_relXY[15][1] = elec_relXY[14][1]; //CP4    
      
    //reference electrode
    float[] ref_elec_relXY = new float[2];
    ref_elec_relXY[0] = 0.0f;    ref_elec_relXY[1] = 0.0f;   
    
    //put it all into a table
    Table table_elec_relXY = new Table();
    table_elec_relXY.addColumn("X",Table.FLOAT);  
    table_elec_relXY.addColumn("Y",Table.FLOAT);
    for (int I = 0; I < elec_relXY.length; I++) {
      table_elec_relXY.addRow();
      table_elec_relXY.setFloat(I,"X",elec_relXY[I][0]);
      table_elec_relXY.setFloat(I,"Y",elec_relXY[I][1]);
    }
    
    //last one is the reference electrode
    table_elec_relXY.addRow();
    table_elec_relXY.setFloat(table_elec_relXY.getRowCount()-1,"X",ref_elec_relXY[0]);
    table_elec_relXY.setFloat(table_elec_relXY.getRowCount()-1,"Y",ref_elec_relXY[1]);
    
    //try writing it to a file
    String full_fname = "Data\\" + fname;
    try { 
      saveTable(table_elec_relXY,full_fname,"csv"); 
    } catch (NullPointerException e) {
      println("headPlot: createDefaultElectrodeLocations: could not write file to " + full_fname);
    };
    
    //return
    return table_elec_relXY;
  } //end of method
  
  //Here, we do a two-step solution to get the weighting factors.  
  //We do a coarse grid first.  We do our iterative solution on the coarse grid.
  //Then, we formulate the full resolution fine grid.  We interpolate these points
  //from the data resulting from the coarse grid.
  private void computePixelWeightingFactors_multiScale(int n_wide_full, int n_tall_full) {
    int n_elec = electrode_xy.length;
    
    //define the coarse grid data structures and pixel locations
    int decimation = 10;
    int n_wide_small = n_wide_full / decimation + 1;  int n_tall_small = n_tall_full / decimation + 1;
    float weightFac[][][] = new float[n_elec][n_wide_small][n_tall_small];
    int pixelAddress[][][] = new int[n_wide_small][n_tall_small][2];
    for (int Ix=0;Ix<n_wide_small;Ix++) { for(int Iy=0;Iy<n_tall_small;Iy++) { pixelAddress[Ix][Iy][0] = Ix*decimation; pixelAddress[Ix][Iy][1] = Iy*decimation;};};
    
    //compute the weighting factors of the coarse grid
    computePixelWeightingFactors_trueAverage(pixelAddress,weightFac);
    
    //define the fine grid data structures
    electrode_color_weightFac = new float[n_elec][n_wide_full][n_tall_full];
    headVoltage = new float[n_wide_full][n_tall_full];
    
    //interpolate to get the fine grid from the coarse grid
    float dx_frac, dy_frac;
    for (int Ix=0;Ix<n_wide_full;Ix++) {
      int Ix_source = Ix/decimation;
      dx_frac = PApplet.parseFloat(Ix - Ix_source*decimation)/PApplet.parseFloat(decimation);
      for (int Iy=0; Iy < n_tall_full; Iy++) {
        int Iy_source = Iy/decimation;
        dy_frac = PApplet.parseFloat(Iy - Iy_source*decimation)/PApplet.parseFloat(decimation);           
        
        for (int Ielec=0; Ielec<n_elec;Ielec++) {
          //println("    : Ielec = " + Ielec);
          if ((Ix_source < (n_wide_small-1)) && (Iy_source < (n_tall_small-1))) {
            //normal 2-D interpolation    
            electrode_color_weightFac[Ielec][Ix][Iy] = interpolate2D(weightFac[Ielec],Ix_source,Iy_source,Ix_source+1,Iy_source+1,dx_frac,dy_frac);
          } else if (Ix_source < (n_wide_small-1)) {
            //1-D interpolation in X
            dy_frac = 0.0f;
            electrode_color_weightFac[Ielec][Ix][Iy] = interpolate2D(weightFac[Ielec],Ix_source,Iy_source,Ix_source+1,Iy_source,dx_frac,dy_frac);
          } else if (Iy_source < (n_tall_small-1)) {
            //1-D interpolation in Y
            dx_frac = 0.0f;
            electrode_color_weightFac[Ielec][Ix][Iy] = interpolate2D(weightFac[Ielec],Ix_source,Iy_source,Ix_source,Iy_source+1,dx_frac,dy_frac);
          } else { 
            //no interpolation, just use the last value
            electrode_color_weightFac[Ielec][Ix][Iy] = weightFac[Ielec][Ix_source][Iy_source];
          }  //close the if block selecting the interpolation configuration
        } //close Ielec loop
      } //close Iy loop
    } // close Ix loop
    
    //clean up the boundaries of our interpolated results to make the look nicer
    int pixelAddress_full[][][] = new int[n_wide_full][n_tall_full][2];
    for (int Ix=0;Ix<n_wide_full;Ix++) { for(int Iy=0;Iy<n_tall_full;Iy++) { pixelAddress_full[Ix][Iy][0] = Ix; pixelAddress_full[Ix][Iy][1] = Iy; };};
    cleanUpTheBoundaries(pixelAddress_full,electrode_color_weightFac);
  } //end of method
  
  
  private float interpolate2D(float[][] weightFac,int Ix1,int Iy1,int Ix2,int Iy2,float dx_frac,float dy_frac) {
    if (Ix1 >= weightFac.length) {
      println("headPlot: interpolate2D: Ix1 = " + Ix1 + ", weightFac.length = " + weightFac.length);
    }
    float foo1 = (weightFac[Ix2][Iy1] - weightFac[Ix1][Iy1])*dx_frac + weightFac[Ix1][Iy1];
    float foo2 = (weightFac[Ix2][Iy2] - weightFac[Ix1][Iy2])*dx_frac + weightFac[Ix1][Iy2];
    return (foo2 - foo1) * dy_frac + foo1;
  }
  
  
  //here is the simpler and more robust algorithm.  It's not necessarily physically real, though.
  //but, it will work every time.  So, if the other method fails, go with this one.
  private void computePixelWeightingFactors() { 
    int n_elec = electrode_xy.length;
    float dist;
    int withinElecInd = -1;
    float elec_radius = 0.5f*elec_diam;
    int pixel_x, pixel_y;
    float sum_weight_fac = 0.0f;
    float weight_fac[] = new float[n_elec];
    float foo_dist;
    
    //loop over each pixel
    for (int Iy=0; Iy < headImage.height; Iy++) {
      pixel_y = image_y + Iy;
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        pixel_x = image_x + Ix;
                
        if (isPixelInsideHead(pixel_x,pixel_y)==false) {
          for (int Ielec=0; Ielec < n_elec; Ielec++) {
            //outside of head...no color from electrodes
            electrode_color_weightFac[Ielec][Ix][Iy]= -1.0f; //a negative value will be a flag that it is outside of the head
          }
        } else {
          //inside of head, compute weighting factors

          //compute distances of this pixel to each electrode
          sum_weight_fac = 0.0f; //reset for this pixel
          withinElecInd = -1;    //reset for this pixel
          for (int Ielec=0; Ielec < n_elec; Ielec++) {
            //compute distance
            dist = max(1.0f,calcDistance(pixel_x,pixel_y,electrode_xy[Ielec][0],electrode_xy[Ielec][1]));
            if (dist < elec_radius) withinElecInd = Ielec;
            
            //compute the first part of the weighting factor
            foo_dist = max(1.0f,abs(dist - elec_radius));  //remove radius of the electrode
            weight_fac[Ielec] = 1.0f/foo_dist;  //arbitrarily chosen
            weight_fac[Ielec] = weight_fac[Ielec]*weight_fac[Ielec]*weight_fac[Ielec];  //again, arbitrary
            sum_weight_fac += weight_fac[Ielec];
          }
          
          //finalize the weight factor
          for (int Ielec=0; Ielec < n_elec; Ielec++) {
             //is this pixel within an electrode? 
            if (withinElecInd > -1) {
              //yes, it is within an electrode
              if (Ielec == withinElecInd) {
                //use this signal electrode as the color
                electrode_color_weightFac[Ielec][Ix][Iy] = 1.0f;
              } else {
                //ignore all other electrodes
                electrode_color_weightFac[Ielec][Ix][Iy] = 0.0f;
              }
            } else {
              //no, this pixel is not in an electrode.  So, use the distance-based weight factor, 
              //after dividing by the sum of the weight factors, resulting in an averaging operation
              electrode_color_weightFac[Ielec][Ix][Iy] = weight_fac[Ielec]/sum_weight_fac;
            }
          }
        }
      }
    }
  } //end of method
  
  public void computePixelWeightingFactors_trueAverage(int pixelAddress[][][],float weightFac[][][]) {
    int n_wide = pixelAddress.length;
    int n_tall = pixelAddress[0].length;
    int n_elec = electrode_xy.length;
    int withinElectrode[][] = new int[n_wide][n_tall]; //which electrode is this pixel within (-1 means that it is not within any electrode)
    boolean withinHead[][] = new boolean[n_wide][n_tall]; //is the pixel within the head?
    int toPixels[][][][] = new int[n_wide][n_tall][4][2];
    int toElectrodes[][][] = new int[n_wide][n_tall][4];
    //int numConnections[][] = new int[n_wide][n_tall];
        
    //find which pixesl are within the head and which pixels are within an electrode
    whereAreThePixels(pixelAddress,withinHead,withinElectrode);
       
    //loop over the pixels and make all the connections
    makeAllTheConnections(withinHead,withinElectrode,toPixels,toElectrodes);
    
    //compute the pixel values when lighting up each electrode invididually
    for (int Ielec=0;Ielec<n_elec;Ielec++) {
      computeWeightFactorsGivenOneElectrode_iterative(toPixels,toElectrodes,Ielec,weightFac);
    }    
  }
  
  private void cleanUpTheBoundaries(int pixelAddress[][][],float weightFac[][][]) {
    int n_wide = pixelAddress.length;
    int n_tall = pixelAddress[0].length;
    int n_elec = electrode_xy.length;
    int withinElectrode[][] = new int[n_wide][n_tall]; //which electrode is this pixel within (-1 means that it is not within any electrode)
    boolean withinHead[][] = new boolean[n_wide][n_tall]; //is the pixel within the head?
       
    //find which pixesl are within the head and which pixels are within an electrode
    whereAreThePixels(pixelAddress,withinHead,withinElectrode);
    
    //loop over the pixels and change the weightFac to reflext where it is
    for (int Ix=0;Ix<n_wide;Ix++) {
      for (int Iy=0;Iy<n_tall;Iy++) {
        if (withinHead[Ix][Iy]==false) {
            //this pixel is outside of the head
            for (int Ielec=0;Ielec<n_elec;Ielec++){
              weightFac[Ielec][Ix][Iy]=-1.0f;  //this means to ignore this weight
            }
        } else {
          //we are within the head...there are a couple of things to clean up
         
          //first, is this a legit value?  It should be >= 0.0.  If it isn't, it was a
          //quantization problem.  let's clean it up.
          for (int Ielec=0;Ielec<n_elec;Ielec++) {
            if (weightFac[Ielec][Ix][Iy] < 0.0f) {
              weightFac[Ielec][Ix][Iy] = getClosestWeightFac(weightFac[Ielec],Ix,Iy);
            }
          }
          
          //next, is our pixel within an electrode.  If so, ensure it's weights
          //set the value to be the same as the electrode
          if (withinElectrode[Ix][Iy] > -1) {
            //we are!  set the weightFac to reflect this electrode only
            for (int Ielec=0;Ielec<n_elec;Ielec++){
              weightFac[Ielec][Ix][Iy] = 0.0f; //ignore all other electrodes
              if (Ielec == withinElectrode[Ix][Iy]) {
                 weightFac[Ielec][Ix][Iy] = 1.0f;  //become equal to this electrode
              }
            }
          } //close "if within electrode"
        } //close "if within head"
      } //close Iy
    } // close Ix
  } //close method
             
  //find the closest legitimate weightFac          
  private float getClosestWeightFac(float weightFac[][],int Ix,int Iy) {
    int n_wide = weightFac.length;
    int n_tall = weightFac[0].length;
    float sum = 0.0f;
    int n_sum = 0;
    float new_weightFac=-1.0f;
    
    
    int step = 1;
    int Ix_test, Iy_test;
    boolean done = false;
    boolean anyWithinBounds;
    while (!done) {
      anyWithinBounds = false;
      
      //search the perimeter at this distance
      sum = 0.0f;
      n_sum = 0;
      
      //along the top
      Iy_test = Iy + step;
      if ((Iy_test >= 0) && (Iy_test < n_tall)) {
        for (Ix_test=Ix-step;Ix_test<=Ix+step;Ix_test++) {
          if ((Ix_test >=0) && (Ix_test < n_wide)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0f) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
      
      //along the right
      Ix_test = Ix + step;
      if ((Ix_test >= 0) && (Ix_test < n_wide)) {
        for (Iy_test=Iy-step;Iy_test<=Iy+step;Iy_test++) {
          if ((Iy_test >=0) && (Iy_test < n_tall)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0f) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
       //along the bottom
      Iy_test = Iy - step;
      if ((Iy_test >= 0) && (Iy_test < n_tall)) {
        for (Ix_test=Ix-step;Ix_test<=Ix+step;Ix_test++) {
          if ((Ix_test >=0) && (Ix_test < n_wide)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0f) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
      
      //along the left
      Ix_test = Ix - step;
      if ((Ix_test >= 0) && (Ix_test < n_wide)) {
        for (Iy_test=Iy-step;Iy_test<=Iy+step;Iy_test++) {
          if ((Iy_test >=0) && (Iy_test < n_tall)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0f) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
  
      if (n_sum > 0) {
        //some good pixels were found, so we have our answer
        new_weightFac = sum / n_sum; //complete the averaging process
        done = true; //we're done
      } else {
        //we did not find any good pixels.  Step outward one more pixel and repeat the search
        step++;  //step outwward
        if (anyWithinBounds) {  //did the last iteration have some pixels that were at least within the domain
          //some pixels were within the domain, so we have space to try again
          done = false;
        } else {
          //no pixels were within the domain.  We're out of space.  We're done.
          done = true;
        }
      }
    }
    return new_weightFac; //good or bad, return our new value
  }

  private void computeWeightFactorsGivenOneElectrode_iterative(int toPixels[][][][],int toElectrodes[][][],int Ielec,float pixelVal[][][]) {
    //Approach: pretend that one electrode is set to 1.0 and that all other electrodes are set to 0.0.
    //Assume all of the pixels start at zero.  Then, begin the simulation as if it were a transient
    //solution where energy is coming in from the connections.  Any excess energy will accumulate
    //and cause the local pixel's value to increase.  Iterate until the pixel values stabalize.
    
    int n_wide = toPixels.length;
    int n_tall = toPixels[0].length;
    int n_dir = toPixels[0][0].length;
    float prevVal[][] = new float[n_wide][n_tall];
    float total,dVal;
    int Ix_targ, Iy_targ;
    float min_val=0.0f, max_val=0.0f;
    boolean anyConnections = false;
    int pixel_step = 1;

    //initialize all pixels to zero
    //for (int Ix=0; Ix<n_wide;Ix++) { for (int Iy=0; Iy<n_tall;Iy++) { pixelVal[Ielec][Ix][Iy]=0.0f; }; };

    //define the iteration limits
    int lim_iter_count = 2000;  //set to something big enough to get the job done, but not so big that it could take forever
    float dVal_threshold = 0.00001f;  //set to something arbitrarily small
    float change_fac = 0.2f; //must be small enough to keep this iterative solution stable.  Goes unstable above 0.25
    
    //begin iteration
    int iter_count = 0;
    float max_dVal = 10.0f*dVal_threshold;  //initilize to large value to ensure that it starts
    while ((iter_count < lim_iter_count) && (max_dVal > dVal_threshold)) {
      //increment the counter
      iter_count++;
      
      //reset our test value to a large value
      max_dVal = 0.0f;
      
      //reset other values that I'm using for debugging
      min_val = 1000.0f; //init to a big val
      max_val = -1000.f; //init to a small val
      
      //copy current values
      for (int Ix=0; Ix<n_wide;Ix++) { for (int Iy=0; Iy<n_tall;Iy++) { prevVal[Ix][Iy]=pixelVal[Ielec][Ix][Iy]; }; };
      
      //compute the new pixel values
      for (int Ix=0; Ix<n_wide;Ix+=pixel_step) {
        for (int Iy=0; Iy<n_tall;Iy+=pixel_step) {
          //reset variables related to this one pixel
          total=0.0f;
          anyConnections = false;
              
          for (int Idir=0; Idir<n_dir; Idir++) {
            //do we connect to a real pixel?
            if (toPixels[Ix][Iy][Idir][0] > -1) {
              Ix_targ = toPixels[Ix][Iy][Idir][0];  //x index of target pixel
              Iy_targ = toPixels[Ix][Iy][Idir][1];  //y index of target pixel
              total += (prevVal[Ix_targ][Iy_targ]-prevVal[Ix][Iy]);  //difference relative to target pixel
              anyConnections = true;
            }
            //do we connect to an electrode?
            if (toElectrodes[Ix][Iy][Idir] > -1) {
              //do we connect to the electrode that we're stimulating
              if (toElectrodes[Ix][Iy][Idir] == Ielec) {
                //yes, this is the active high one
                total += (1.0f-prevVal[Ix][Iy]);  //difference relative to HIGH electrode
              } else {
                //no, this is a low one
                total += (0.0f-prevVal[Ix][Iy]);  //difference relative to the LOW electrode
              }
              anyConnections = true;
            }
          }
         
          //compute the new pixel value
          //if (numConnections[Ix][Iy] > 0) {
          if (anyConnections) {
            
            //dVal = change_fac * (total - float(numConnections[Ix][Iy])*prevVal[Ix][Iy]);
            dVal = change_fac * total;
            pixelVal[Ielec][Ix][Iy] = prevVal[Ix][Iy] + dVal;
                        
            //is this our worst change in value?
            max_dVal = max(max_dVal,abs(dVal));
            
            //update our other debugging values, too
            min_val = min(min_val,pixelVal[Ielec][Ix][Iy]);
            max_val = max(max_val,pixelVal[Ielec][Ix][Iy]);
            
          } else {
            pixelVal[Ielec][Ix][Iy] = -1.0f; //means that there are no connections
          }
        }
      }
      //println("headPlot: computeWeightFactor: Ielec " + Ielec + ", iter = " + iter_count + ", max_dVal = " + max_dVal);
    }
    //println("headPlot: computeWeightFactor: Ielec " + Ielec + ", solution complete with " + iter_count + " iterations. min and max vals = " + min_val + ", " + max_val);
    if (iter_count >= lim_iter_count) println("headPlot: computeWeightFactor: Ielec " + Ielec + ", solution complete with " + iter_count + " iterations. max_dVal = " + max_dVal);
  } //end of method
    
    
    
//  private void countConnections(int toPixels[][][][],int toElectrodes[][][], int numConnections[][]) {
//    int n_wide = toPixels.length;
//    int n_tall = toPixels[0].length;
//    int n_dir = toPixels[0][0].length;
//    
//    //loop over each pixel
//    for (int Ix=0; Ix<n_wide;Ix++) { 
//      for (int Iy=0; Iy<n_tall;Iy++) {
//        
//        //initialize
//        numConnections[Ix][Iy]=0;
//        
//        //loop through the four directions
//        for (int Idir=0;Idir<n_dir;Idir++) {
//          //is it a connection to another pixel (anything > -1 is a connection)
//          if (toPixels[Ix][Iy][Idir][0] > -1) numConnections[Ix][Iy]++;
//          
//          //is it a connection to an electrode?
//          if (toElectrodes[Ix][Iy][Idir] > -1) numConnections[Ix][Iy]++;
//        }
//      }
//    }
//  }
    
  private void makeAllTheConnections(boolean withinHead[][],int withinElectrode[][], int toPixels[][][][],int toElectrodes[][][]) {
   
    int n_wide = toPixels.length;
    int n_tall = toPixels[0].length;
    int n_elec = electrode_xy.length;
    int curPixel, Ipix, Ielec;
    int n_pixels = n_wide * n_tall;
    int Ix_try, Iy_try;

    
    //loop over every pixel in the image
    for (int Iy=0; Iy < n_tall; Iy++) {
      for (int Ix=0; Ix < n_wide; Ix++) {
        
        //loop over the four connections: left, right, up, down
        for (int Idirection = 0; Idirection < 4; Idirection++) {
          
          Ix_try = -1; Iy_try=-1; //nonsense values
          switch (Idirection) {
              case 0:
                Ix_try = Ix-1; Iy_try = Iy; //left
                break;
              case 1:
                Ix_try = Ix+1; Iy_try = Iy; //right
                break;
              case 2:
                Ix_try = Ix; Iy_try = Iy-1; //up
                break;
              case 3:
                Ix_try = Ix; Iy_try = Iy+1; //down
                break;
           }
          
          //initalize to no connection
          toPixels[Ix][Iy][Idirection][0] = -1;
          toPixels[Ix][Iy][Idirection][1] = -1;
          toElectrodes[Ix][Iy][Idirection] = -1;
          
          //does the target pixel exist
          if ((Ix_try >= 0) && (Ix_try < n_wide)  && (Iy_try >= 0) && (Iy_try < n_tall)) {
            //is the target pixel an electrode
            if (withinElectrode[Ix_try][Iy_try] >= 0) {
              //the target pixel is within an electrode
              toElectrodes[Ix][Iy][Idirection] = withinElectrode[Ix_try][Iy_try];
            } else {
              //the target pixel is not within an electrode.  is it within the head?
              if (withinHead[Ix_try][Iy_try]) {
                toPixels[Ix][Iy][Idirection][0] = Ix_try; //save the address of the target pixel
                toPixels[Ix][Iy][Idirection][1] = Iy_try; //save the address of the target pixel
              }
            }
          }
        } //end loop over direction of the target pixel
      } //end loop over Ix
    } //end loop over Iy 
  } // end of method
  
  private void whereAreThePixels(int pixelAddress[][][], boolean[][] withinHead,int[][] withinElectrode) {
    int n_wide = pixelAddress.length;
    int n_tall = pixelAddress[0].length;
    int n_elec = electrode_xy.length;
    int pixel_x,pixel_y;
    int withinElecInd=-1;
    float dist;
    float elec_radius = 0.5f*elec_diam;
    
    for (int Iy=0; Iy < n_tall; Iy++) {
      //pixel_y = image_y + Iy;
      for (int Ix = 0; Ix < n_wide; Ix++) {
        //pixel_x = image_x + Ix;
        
        pixel_x = pixelAddress[Ix][Iy][0]+image_x;
        pixel_y = pixelAddress[Ix][Iy][1]+image_y;
        
        //is it within the head
        withinHead[Ix][Iy] = isPixelInsideHead(pixel_x,pixel_y);
        
        //compute distances of this pixel to each electrode
        withinElecInd = -1;    //reset for this pixel
        for (int Ielec=0; Ielec < n_elec; Ielec++) {
          //compute distance
          dist = max(1.0f,calcDistance(pixel_x,pixel_y,electrode_xy[Ielec][0],electrode_xy[Ielec][1]));
          if (dist < elec_radius) withinElecInd = Ielec;
        }
        withinElectrode[Ix][Iy] = withinElecInd;  //-1 means not inside an electrode 
      } //close Ix loop
    } //close Iy loop
    
    //ensure that each electrode is at at least one pixel
    for (int Ielec=0; Ielec<n_elec; Ielec++) {
      //find closest pixel
      float min_dist = 1.0e10f;  //some huge number
      int best_Ix=0, best_Iy=0; 
      for (int Iy=0; Iy < n_tall; Iy++) {
        //pixel_y = image_y + Iy;
        for (int Ix = 0; Ix < n_wide; Ix++) {
          //pixel_x = image_x + Ix;
        
          pixel_x = pixelAddress[Ix][Iy][0]+image_x;
          pixel_y = pixelAddress[Ix][Iy][1]+image_y;
          
          dist = calcDistance(pixel_x,pixel_y,electrode_xy[Ielec][0],electrode_xy[Ielec][1]);;
          
          if (dist < min_dist) {
            min_dist = dist;
            best_Ix = Ix;
            best_Iy = Iy;
          }
        } //close Iy loop
      } //close Ix loop
      
      //define this closest point to be within the electrode
      withinElectrode[best_Ix][best_Iy] = Ielec;
    } //close Ielec loop
  } //close method


  //step through pixel-by-pixel to update the image
  private void updateHeadImage() {
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        //is this pixel inside the head?
        if (electrode_color_weightFac[0][Ix][Iy] >= 0.0f) { //zero and positive values are inside the head
          //it is inside the head.  set the color based on the electrodes
          headImage.set(Ix,Iy,calcPixelColor(Ix,Iy));
        } else {  //negative values are outside of the head
          //pixel is outside the head.  set to black.
          headImage.set(Ix,Iy,color(0,0,0,0));
        }
      }
    }
  }
  
  private void convertVoltagesToHeadImage() { 
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        //is this pixel inside the head?
        if (electrode_color_weightFac[0][Ix][Iy] >= 0.0f) { //zero and positive values are inside the head
          //it is inside the head.  set the color based on the electrodes
          headImage.set(Ix,Iy,calcPixelColor(headVoltage[Ix][Iy]));
        } else {  //negative values are outside of the head
          //pixel is outside the head.  set to black.
          headImage.set(Ix,Iy,color(0,0,0,0));
        }
      }
    }
  }
  

  private void updateHeadVoltages() {
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        //is this pixel inside the head?
        if (electrode_color_weightFac[0][Ix][Iy] >= 0.0f) { //zero and positive values are inside the head
          //it is inside the head.  set the voltage based on the electrodes
          headVoltage[Ix][Iy] = calcPixelVoltage(Ix,Iy,headVoltage[Ix][Iy]);

        } else {  //negative values are outside of the head
          //pixel is outside the head.
          headVoltage[Ix][Iy] = -1.0f;
        }
      }
    }
  }    

  int count_call=0;
  private float calcPixelVoltage(int pixel_Ix,int pixel_Iy,float prev_val) {
    float weight,elec_volt;
    int n_elec = electrode_xy.length;
    float voltage = 0.0f;
    float low = intense_min_uV;
    float high = intense_max_uV;
    
    for (int Ielec=0;Ielec<n_elec;Ielec++) {
      weight = electrode_color_weightFac[Ielec][pixel_Ix][pixel_Iy];
      elec_volt = max(low,min(intensity_data_uV[Ielec],high));
      
      if (use_polarity) elec_volt = elec_volt*polarity_data[Ielec];
      
      if (is_railed[Ielec].is_railed) elec_volt = assumed_railed_voltage_uV;
      voltage += weight*elec_volt;
    }
    
    //smooth in time
    if (smooth_fac > 0.0f) voltage = smooth_fac*prev_val + (1.0f-smooth_fac)*voltage;     
    
    return voltage;
  }
      
    
  private int calcPixelColor(float pixel_volt_uV) {
    float new_rgb[] = {255.0f,0.0f,0.0f}; //init to red
    if (pixel_volt_uV < 0.0f) {
      //init to blue instead
      new_rgb[0]=0.0f;new_rgb[1]=0.0f;new_rgb[2]=255.0f;
    }
    float val;
    
    
    float intensity = constrain(abs(pixel_volt_uV),intense_min_uV,intense_max_uV);
    if (plot_color_as_log) {
      intensity = map(log10(intensity), 
                      log10_intense_min_uV,
                      log10_intense_max_uV,
                      0.0f,1.0f);
    } else {
      intensity = map(intensity, 
                intense_min_uV,
                intense_max_uV,
                0.0f,1.0f);
    }
      
    //make the intensity fade NOT from black->color, but from white->color
    for (int i=0; i < 3; i++) {
      val = ((float)new_rgb[i]) / 255.f;
      new_rgb[i] = ((val + (1.0f - val)*(1.0f-intensity))*255.f); //adds in white at low intensity.  no white at high intensity
      new_rgb[i] = constrain(new_rgb[i],0.0f,255.0f);
    }
    
    //quantize the color to make contour-style plot?
    if (true) quantizeColor(new_rgb);

    return color(PApplet.parseInt(new_rgb[0]),PApplet.parseInt(new_rgb[1]),PApplet.parseInt(new_rgb[2]),255);   
  }
  
  private void quantizeColor(float new_rgb[]) {
    int n_colors = 12;
    int ticks_per_color = 256 / (n_colors+1);
    for (int Irgb=0; Irgb<3; Irgb++) new_rgb[Irgb] = min(255.0f,PApplet.parseFloat(PApplet.parseInt(new_rgb[Irgb]/ticks_per_color))*ticks_per_color);
  }
  

  //compute the color of the pixel given the location
  private int calcPixelColor(int pixel_Ix,int pixel_Iy) {
    float weight;
    
    //compute the weighted average using the precomputed factors
    float new_rgb[] = {0.0f,0.0f,0.0f}; //init to zeros
    for (int Ielec=0; Ielec < electrode_xy.length; Ielec++) {
      //int Ielec = 0;
      weight = electrode_color_weightFac[Ielec][pixel_Ix][pixel_Iy];
      for (int Irgb=0; Irgb<3; Irgb++) {
        new_rgb[Irgb] += weight*electrode_rgb[Irgb][Ielec];
      }
    }
    
    //quantize the color to make contour-style plot?
    if (true) quantizeColor(new_rgb);
       
    return color(PApplet.parseInt(new_rgb[0]),PApplet.parseInt(new_rgb[1]),PApplet.parseInt(new_rgb[2]),255);
  }
  
  private float calcDistance(int x,int y,float ref_x,float ref_y) {
    float dx = PApplet.parseFloat(x) - ref_x;
    float dy = PApplet.parseFloat(y) - ref_y;
    return sqrt(dx*dx + dy*dy);
  }
  
  //compute color for the electrode value
  private void updateElectrodeColors() {
    int rgb[] = new int[]{255,0,0}; //color for the electrode when fully light
    float intensity;
    float val;
    int new_rgb[] = new int[3];
    float low = intense_min_uV;
    float high = intense_max_uV;
    float log_low = log10_intense_min_uV;
    float log_high = log10_intense_max_uV;
    for (int Ielec=0; Ielec < electrode_xy.length; Ielec++) {
      intensity = constrain(intensity_data_uV[Ielec],low,high);
      if (plot_color_as_log) {
        intensity = map(log10(intensity),log_low,log_high,0.0f,1.0f);
      } else {
        intensity = map(intensity,low,high,0.0f,1.0f);
      }
      
      //make the intensity fade NOT from black->color, but from white->color
      for (int i=0; i < 3; i++) {
        val = ((float)rgb[i]) / 255.f;
        new_rgb[i] = (int)((val + (1.0f - val)*(1.0f-intensity))*255.f); //adds in white at low intensity.  no white at high intensity
        new_rgb[i] = constrain(new_rgb[i],0,255);
      }
      
      //change color to dark RED if railed
      if (is_railed[Ielec].is_railed)  new_rgb = new int[]{127,0,0};
      
      //set the electrode color
      electrode_rgb[0][Ielec] = new_rgb[0];
      electrode_rgb[1][Ielec] = new_rgb[1];
      electrode_rgb[2][Ielec] = new_rgb[2];
    }
  }
 
  
  public boolean isPixelInsideHead(int pixel_x, int pixel_y) {
    int dx = pixel_x - circ_x;
    int dy = pixel_y - circ_y;
    float r = sqrt(PApplet.parseFloat(dx*dx) + PApplet.parseFloat(dy*dy));
    if (r <= 0.5f*circ_diam) {
      return true;
    } else {
      return false;
    }    
  }
  
  public void update() {
    //do this when new data is available
    
    //update electrode colors
    updateElectrodeColors();
    
    if (false) {
      //update the head image
      if (drawHeadAsContours) updateHeadImage();
    } else {
      //update head voltages
      updateHeadVoltages();
      convertVoltagesToHeadImage();
    }
  }
  
  public void draw() {

    //draw head parts
    fill(255,255,255);
    stroke(63,63,63);
    triangle(nose_x[0], nose_y[0],nose_x[1], nose_y[1],nose_x[2], nose_y[2]);  //nose
    ellipse(earL_x, earL_y, ear_width, ear_height); //little circle for the ear
    ellipse(earR_x, earR_y, ear_width, ear_height); //little circle for the ear
    
    //draw head itself   
   fill(255,255,255,255);  //fill in a white head 
   strokeWeight(2);
   ellipse(circ_x, circ_y, circ_diam, circ_diam); //big circle for the head
    if (drawHeadAsContours) {
      //add the contnours
      image(headImage,image_x,image_y);
      noFill(); //overlay a circle as an outline, but no fill
      strokeWeight(2);
      ellipse(circ_x, circ_y, circ_diam, circ_diam); //big circle for the head
    }
  
    //draw electrodes on the head
    strokeWeight(1);
    for (int Ielec=0; Ielec < electrode_xy.length; Ielec++) {
      if (drawHeadAsContours) {
        noFill(); //make transparent to allow color to come through from below   
      } else {
        fill(electrode_rgb[0][Ielec],electrode_rgb[1][Ielec],electrode_rgb[2][Ielec]);
      }
      ellipse(electrode_xy[Ielec][0], electrode_xy[Ielec][1], elec_diam, elec_diam); //big circle for the head
    }
    
    //add labels to electrodes
    fill(0,0,0);
    textFont(font);
    textAlign(CENTER, CENTER);
    for (int i=0; i < electrode_xy.length; i++) {
            //text(Integer.toString(i),electrode_xy[i][0], electrode_xy[i][1]);
        text(i+1,electrode_xy[i][0], electrode_xy[i][1]);
    }
    text("R",ref_electrode_xy[0],ref_electrode_xy[1]); 
  } //end of draw method
  
};




//this class is used to create the help widget that provides system feedback in response to interactivity
//it is intended to serve as a pseudo-console, allowing us to print useful information to the interface as opposed to an IDE console

class HelpWidget {

	public float x, y, w, h;
	// ArrayList<String> prevOutputs; //growing list of all previous system interactivity

	String currentOutput = "..."; //current text shown in help widget, based on most recent command

	int padding = 5;

	HelpWidget(float _xPos, float _yPos, float _width, float _height){
		x = _xPos;
		y = _yPos;
		w = _width;
		h = _height;
	}

	public void update(){

	}

	public void draw(){

		pushStyle();
		noStroke();

		// draw background of widget
		fill(255);
		rect(x,height-h,width,h);

		//draw bg of text field of widget
		strokeWeight(1);
		stroke(color(0,5,11));
		fill(color(0,5,11));
		rect(x + padding, height-h + padding, width - padding*5 - 128, h - padding *2);

		textSize(14);
		fill(255);
		textAlign(LEFT, TOP);
		text(currentOutput, padding*2, height - h + padding + 4);

		//draw OpenBCI LOGO
		image(logo, width - (128+padding*2), height - 26, 128, 22);

		popStyle();

	}

	public void output(String _output){	
		currentOutput = _output;
		// prevOutputs.add(_output);
	}
};

public void output(String _output){
	helpWidget.output(_output);
}


//===================== MENU LIST CLASS ===========================//
//==================EXTENSION OF CONTROLP5=========================//
//==============USED FOR SOURCEBOX & SERIALBOX=====================//
//
// Created: Conor Russomanno Oct. 2014
// Based on ControlP5 Processing Library example, written by Andreas Schlegel
//
/////////////////////////////////////////////////////////////////////

//makeItem function used by MenuList class below
public Map<String, Object> makeItem(String theHeadline) {
  Map m = new HashMap<String, Object>();
  m.put("headline", theHeadline);
  return m;
}

public class MenuList extends Controller {

  float pos, npos;
  int itemHeight = 24;
  int scrollerLength = 40;
  int scrollerWidth = 15;
  List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
  PGraphics menu;
  boolean updateMenu;
  int hoverItem = -1;
  int activeItem = -1;
  PFont menuFont = f2; 
  int padding = 7;
  

  MenuList(ControlP5 c, String theName, int theWidth, int theHeight, PFont theFont) {
    
    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(), getHeight() );

    menuFont = theFont;

    setView(new ControllerView<MenuList>() {

      public void display(PGraphics pg, MenuList t ) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside() ) {
          menu.beginDraw();
          int len = -(itemHeight * items.size()) + getHeight();
          int ty = PApplet.parseInt(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
          menu.fill(bgColor, 100);
          menu.rect(getWidth()-scrollerWidth-2, ty, scrollerWidth, scrollerLength );
          menu.endDraw();
        }
        pg.image(menu, 0, 0);
      }
    }
    );
    updateMenu();
  }

  /* only update the image buffer when necessary - to save some resources */
  public void updateMenu() {
    int len = -(itemHeight * items.size()) + getHeight();
    npos = constrain(npos, len, 0);
    pos += (npos - pos) * 0.1f;
//    pos += (npos - pos) * 0.1;
    menu.beginDraw();
    menu.noStroke();
    menu.background(255, 64);
    menu.textFont(cp5.getFont().getFont());
    menu.pushMatrix();
    menu.translate( 0, pos );
    menu.pushMatrix();

    int i0 = PApplet.max( 0, PApplet.parseInt(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
    int range = ceil((PApplet.parseFloat(getHeight())/PApplet.parseFloat(itemHeight))+1);
    int i1 = PApplet.min( items.size(), i0 + range );

    menu.translate(0, i0*itemHeight);

    for (int i=i0;i<i1;i++) {
		Map m = items.get(i);
		menu.fill(255, 100);
		if(i == hoverItem){
			menu.fill(127,134,143);
		}
		if(i == activeItem){
			menu.stroke(184,220,105,255);
			menu.strokeWeight(1);
			menu.fill(184,220,105,255);
			menu.rect(0, 0, getWidth()-1, itemHeight-1 );
			menu.noStroke();
		} else{
			menu.rect(0, 0, getWidth(), itemHeight-1 );
		}
			menu.fill(bgColor);
			menu.textFont(menuFont);
			menu.text(m.get("headline").toString(), 8, itemHeight - padding); // 5/17
			menu.translate( 0, itemHeight );
    }
    menu.popMatrix();
    menu.popMatrix();
    menu.endDraw();
    updateMenu = abs(npos-pos)>0.01f ? true:false;
  }
  
  /* when detecting a click, check if the click happend to the far right, if yes, scroll to that position, 
   * otherwise do whatever this item of the list is supposed to do.
   */
  public void onClick() {
    if (getPointer().x()>getWidth()-scrollerWidth) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    } 
    else {
      int len = itemHeight * items.size();
      int index = PApplet.parseInt( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      setValue(index);
      activeItem = index;
    }
    updateMenu = true;
  }
  
  public void onMove() {
    if (getPointer().x()>getWidth() || getPointer().x()<0 || getPointer().y()<0  || getPointer().y()>getHeight() ) {
      hoverItem = -1;
    } 
    else {
      int len = itemHeight * items.size();
      int index = PApplet.parseInt( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      hoverItem = index;
    }
    updateMenu = true;
  }

  public void onDrag() {
    if (getPointer().x()>getWidth()-scrollerWidth) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    } 
    else{
      npos += getPointer().dy() * 2;
      updateMenu = true;
    }
  } 

  public void onScroll(int n) {
    npos += ( n * 4 );
    updateMenu = true;
  }

  public void addItem(Map<String, Object> m) {
    items.add(m);
    updateMenu = true;
  }

  public void removeItem(Map<String, Object> m) {
    items.remove(m);
    updateMenu = true;
  }
  
  public Map<String,Object> getItem(int theIndex) {
    return items.get(theIndex);
  }
};



///////////////////////////////////////////////////////////////////////////////
//
// This class configures and manages the connection to the OpenBCI shield for
// the Arduino.  The connection is implemented via a Serial connection.
// The OpenBCI is configured using single letter text commands sent from the
// PC to the Arduino.  The EEG data streams back from the Arduino to the PC
// continuously (once started).  This class defaults to using binary transfer
// for normal operation.
//
// Created: Chip Audette, Oct 2013
// Modified: through April 2014
// Modified again: Conor Russomanno Sept-Oct 2014
//
// Note: this class now expects the data format produced by OpenBCI V3.
//
/////////////////////////////////////////////////////////////////////////////

//import processing.serial.*;
 //for logging raw bytes to an output file

final String command_stop = "s";
// final String command_startText = "x";
final String command_startBinary = "b";
final String command_startBinary_wAux = "n";  // already doing this with 'b' now
final String command_startBinary_4chan = "v";  // not necessary now
final String command_activateFilters = "f";  // swithed from 'F' to 'f'  ... but not necessary because taken out of hardware code
final String command_deactivateFilters = "g";  // not necessary anymore 

final String[] command_deactivate_channel = {"1", "2", "3", "4", "5", "6", "7", "8"};
final String[] command_activate_channel = {"!", "@", "#", "$", "%", "^", "&", "*"};

final String[] command_deactivate_channel_daisy = {"q", "w", "e", "r", "t", "y", "u", "i"};
final String[] command_activate_channel_daisy = {"Q", "W", "E", "R", "T", "Y", "U", "I"};

//everything below is now deprecated...
// final String[] command_activate_leadoffP_channel = {"!", "@", "#", "$", "%", "^", "&", "*"};  //shift + 1-8
// final String[] command_deactivate_leadoffP_channel = {"Q", "W", "E", "R", "T", "Y", "U", "I"};   //letters (plus shift) right below 1-8
// final String[] command_activate_leadoffN_channel = {"A", "S", "D", "F", "G", "H", "J", "K"}; //letters (plus shift) below the letters below 1-8
// final String[] command_deactivate_leadoffN_channel = {"Z", "X", "C", "V", "B", "N", "M", "<"};   //letters (plus shift) below the letters below the letters below 1-8
// final String command_biasAuto = "`";
// final String command_biasFixed = "~";

// ArrayList defaultChannelSettings;

class OpenBCI_ADS1299 {
  
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
  
  int[] measured_packet_length = {0,0,0,0,0};
  int measured_packet_length_ind = 0;
  int known_packet_length_bytes = 0;
  
  final static byte BYTE_START = (byte)0xA0;
  final static byte BYTE_END = (byte)0xC0;
  
  int prefered_datamode = DATAMODE_BIN_WAUX;
  
  int state = STATE_NOCOM;
  int dataMode = -1;
  int prevState_millis = 0;
  //byte[] serialBuff;
  //int curBuffIndex = 0;
  DataPacket_ADS1299 dataPacket;
  int nAuxValues;
  boolean isNewDataPacketAvailable = false;
  OutputStream output; //for debugging  WEA 2014-01-26
  int prevSampleIndex = 0;
  int serialErrorCounter = 0;
  
  final float fs_Hz = 250.0f;  //sample rate used by OpenBCI board...set by its Arduino code
  final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
  float ADS1299_gain = 24;  //assumed gain setting for ADS1299.  set by its Arduino code
  float scale_fac_uVolts_per_count = ADS1299_Vref / (pow(2,23)-1) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
  //float LIS3DH_full_scale_G = 4;  // +/- 4G, assumed full scale setting for the accelerometer
  //final float scale_fac_accel_G_per_count = 0.002;  //data sheet, 2 mg per "digit", which I assume is per "count"
  final float scale_fac_accel_G_per_count = 1.0f;
  final float leadOffDrive_amps = 6.0e-9f;  //6 nA, set by its Arduino code
  
  boolean isBiasAuto = true;

  final char[] EOT = {'$','$','$'};
  char[] prev3chars = {'#','#','#'};
  String defaultChannelSettings = "";
  
  //constructors
  OpenBCI_ADS1299() {};  //only use this if you simply want access to some of the constants
  OpenBCI_ADS1299(PApplet applet, String comPort, int baud, int nEEGValuesPerPacket, boolean useAux, int nAuxValuesPerPacket) {
    nAuxValues=nAuxValuesPerPacket;
    
    //choose data mode
    println("OpenBCI_ADS1299: prefered_datamode = " + prefered_datamode + ", nValuesPerPacket = " + nEEGValuesPerPacket);
    if (prefered_datamode == DATAMODE_BIN_WAUX) {
      if (!useAux) {
        //must be requesting the aux data, so change the referred data mode
        prefered_datamode = DATAMODE_BIN;
        nAuxValues = 0;
        //println("OpenBCI_ADS1299: nAuxValuesPerPacket = " + nAuxValuesPerPacket + " so setting prefered_datamode to " + prefered_datamode);
      }
    }

    println(" a");

    dataMode = prefered_datamode;

    //allocate space for data packet
    dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket,nAuxValuesPerPacket);

    println(" b");

    //prepare the serial port  ... close if open
    println("port is open? ... " + portIsOpen);
    if(portIsOpen == true){
      closeSerialPort();
    }

    println(" i");
    openSerialPort(applet, comPort, baud);
    println(" j");
    
    //open file for raw bytes
    //output = createOutput("rawByteDumpFromProcessing.bin");  //for debugging  WEA 2014-01-26
  }
  
  // //manage the serial port  
  private int openSerialPort(PApplet applet, String comPort, int baud) {
    
    try {
      println("OpenBCI_ADS1299: attempting to open serial port " + openBCI_portName);
      serial_openBCI = new Serial(applet,comPort,baud); //open the com port
      serial_openBCI.clear(); // clear anything in the com port's buffer    
      portIsOpen = true;
      println("port is open (t)? ... " + portIsOpen);
      changeState(STATE_COMINIT);
      return 0;
    } 
    catch (RuntimeException e){
      if (e.getMessage().contains("<init>")) {
        System.out.println("port in use, trying again later...");
        portIsOpen = false;
      }
      return 0;
    }
  }

  public int changeState(int newState) {
    state = newState;
    prevState_millis = millis();
    return 0;
  }

  public int finalizeCOMINIT() {
    // //wait specified time for COM/serial port to initialize
    // if (state == STATE_COMINIT) {
    //   // println("Initializing Serial: millis() = " + millis());
    //   if ((millis() - prevState_millis) > COM_INIT_MSEC) {
    //     //serial_openBCI.write(command_activates + "\n"); println("Processing: OpenBCI_ADS1299: activating filters");
    //     println("OpenBCI_ADS1299: State = NORMAL");
        changeState(STATE_NORMAL);
    //     // startRunning();
    //   }
    // }
    return 0;
  }    

  public int closeSerialPort() {

    // if (serial_openBCI != null) {
    println(" d");
    portIsOpen = false;
    println(" e");
    serial_openBCI.clear();
    println(" e2");
    serial_openBCI.stop();
    println(" f");
    serial_openBCI = null;
    println(" g");
    state = STATE_NOCOM;
    println(" h");
    return 0;
  }
  
  //start the data transfer using the current mode
  // int startDataTransfer() {
  //   println("OpenBCI_ADS1299: startDataTransfer: using current dataMode..." + dataMode);
  //   return startDataTransfer(dataMode);
  // }
  
  // //start data trasnfer using the given mode
  // int startDataTransfer(int mode) {
  //   dataMode = mode;
  //   if (state == STATE_COMINIT) {
  //     println("OpenBCI_ADS1299: startDataTransfer: cannot start transfer...waiting for comms...");
  //     return -1;
  //   }
  //   // stopDataTransfer();
  //   // println("OpenBCI_ADS1299: startDataTransfer: received command for mode = " + mode);
  //   // switch (mode) {
  //   //   case DATAMODE_BIN:
  //   //     serial_openBCI.write(command_startBinary);// + "\n");
  //   //     // serial_openBCI.write(command_startBinary);
  //   //     println("OpenBCI_ADS1299: startDataTransfer: starting binary transfer");
  //   //     break;
  //   //   case DATAMODE_BIN_WAUX:
  //   //     serial_openBCI.write(command_startBinary_wAux);// + "\n");
  //   //     println("OpenBCI_ADS1299: startDataTransfer: starting binary transfer (with Aux)");
  //   //     break;
  //   // }

  //   return 0;
  // }

  public void startDataTransfer(){
    if (serial_openBCI != null) {
      serial_openBCI.clear(); // clear anything in the com port's buffer
      // stopDataTransfer();
      openBCI.changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
      println("writing \'" + command_startBinary + "\' to the serial port...");
      serial_openBCI.write(command_startBinary);
    }
  }
  
  public void stopDataTransfer() {
    if (serial_openBCI != null) {
      serial_openBCI.clear(); // clear anything in the com port's buffer
      openBCI.changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
      println("writing \'" + command_stop + "\' to the serial port...");
      serial_openBCI.write(command_stop);// + "\n");
    }
  }
  
  //read from the serial port
  public int read() {  return read(false); }
  public int read(boolean echoChar) {
    // print("State: " + state);
    //get the byte
    byte inByte = PApplet.parseByte(serial_openBCI.read());

    //write the most recent char to the console
    if (echoChar){  //if not in interpret binary (NORMAL) mode
      // print(".");
      char inASCII = PApplet.parseChar(inByte); 
      if(isRunning == false && (millis() - timeSinceStopRunning) > 500){
        print(PApplet.parseChar(inByte));
      }

      //keep track of previous three chars coming from OpenBCI
      prev3chars[0] = prev3chars[1];
      prev3chars[1] = prev3chars[2];
      prev3chars[2] = inASCII;

      if(hardwareSyncStep == 3 && inASCII != '$'){ //if we're retrieving channel settings from OpenBCI
        defaultChannelSettings+=inASCII;
      }

      //if the last three chars are $$$, it means we are moving on to the next stage of initialization
      if(prev3chars[0] == EOT[0] && prev3chars[1] == EOT[1] && prev3chars[2] == EOT[2]){
        verbosePrint(" > EOT detected...");
        // hardwareSyncStep++;
        prev3chars[2] = '#';
        if(hardwareSyncStep == 3){
          println(defaultChannelSettings);
          gui.cc.loadDefaultChannelSettings();
        }
        readyToSend = true; 
        // println(hardwareSyncStep);
        // syncWithHardware(); //haha, I'm getting very verbose with my naming... it's late...
      }  
    }
    
    //write raw unprocessed bytes to a binary data dump file
    if (output != null) {
      try {
       output.write(inByte);   //for debugging  WEA 2014-01-26
      } catch (IOException e) {
        System.err.println("OpenBCI_ADS1299: Caught IOException: " + e.getMessage());
        //do nothing
      }
    }
    
    interpretBinaryStream(inByte);  //new 2014-02-02 WEA
    return PApplet.parseInt(inByte);
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
  int nDataValuesInPacket = 0;
  int localByteCounter=0;
  int localChannelCounter=0;
  int PACKET_readstate = 0;
  // byte[] localByteBuffer = {0,0,0,0};
  byte[] localAdsByteBuffer = {0,0,0};
  byte[] localAccelByteBuffer = {0,0};

  public void interpretBinaryStream(byte actbyte)
  { 
    //println("OpenBCI_ADS1299: interpretBinaryStream: PACKET_readstate " + PACKET_readstate);
    switch (PACKET_readstate) {
      case 0:  
         //look for header byte  
         if (actbyte == PApplet.parseByte(0xA0)) {          // look for start indicator
          // println("OpenBCI_ADS1299: interpretBinaryStream: found 0xA0");
          PACKET_readstate++;
         } 
         break;
      case 1: 
        //check the packet counter
        // println("case 1");
        byte inByte = actbyte;
        dataPacket.sampleIndex = PApplet.parseInt(inByte); //changed by JAM
        if ((dataPacket.sampleIndex-prevSampleIndex) != 1) {
          if(dataPacket.sampleIndex != 0){  // if we rolled over, don't count as error
            serialErrorCounter++;
            println("OpenBCI_ADS1299: apparent sampleIndex jump from Serial data: " + prevSampleIndex + " to  " + dataPacket.sampleIndex + ".  Keeping packet. (" + serialErrorCounter + ")");
          }
        }
        prevSampleIndex = dataPacket.sampleIndex;
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
          dataPacket.values[localChannelCounter] = interpret24bitAsInt32(localAdsByteBuffer);
          localChannelCounter++;
          if (localChannelCounter==8) { //nDataValuesInPacket) {  
            // all ADS channels arrived !
            //println("OpenBCI_ADS1299: interpretBinaryStream: localChannelCounter = " + localChannelCounter);
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
        if (localByteCounter==2) {
          dataPacket.auxValues[localChannelCounter]  = interpret16bitAsInt32(localAccelByteBuffer);
          localChannelCounter++;
          if (localChannelCounter==nAuxValues) { //number of accelerometer axis) {  
            // all Accelerometer channels arrived !
            //println("OpenBCI_ADS1299: interpretBinaryStream: Accel Data: " + dataPacket.auxValues[0] + ", " + dataPacket.auxValues[1] + ", " + dataPacket.auxValues[2]);
            PACKET_readstate++;
            localByteCounter = 0;
            //isNewDataPacketAvailable = true;  //tell the rest of the code that the data packet is complete
          } else { 
            //prepare for next data channel
            localByteCounter=0; //prepare for next usage of localByteCounter
          }
        }
        break;
      case 4:
        //look for end byte
        // println("case 4");
        if (actbyte == PApplet.parseByte(0xC0)) {    // if correct end delimiter found:
          // println("... 0xC0 found");
          //println("OpenBCI_ADS1299: interpretBinaryStream: found end byte. Setting isNewDataPacketAvailable to TRUE");
          isNewDataPacketAvailable = true; //original place for this.  but why not put it in the previous case block
        } else {
          serialErrorCounter++;
          println("Actbyte = " + actbyte);
          println("OpenBCI_ADS1299: interpretBinaryStream: expecteding end-of-packet byte is missing.  Discarding packet. (" + serialErrorCounter + ")");
        }
        PACKET_readstate=0;  // either way, look for next packet
        break;
      default: 
          //println("OpenBCI_ADS1299: Unknown byte: " + actbyte + " .  Continuing...");
          println("OpenBCI_ADS1299: interpretBinaryStream: Unknown byte.  Continuing...");
          PACKET_readstate=0;  // look for next packet
    }
  } // end of interpretBinaryStream


  //activate or deactivate an EEG channel...channel counting is zero through nchan-1
  public void changeChannelState(int Ichan,boolean activate) {
    if (serial_openBCI != null) {
      if ((Ichan >= 0) && (Ichan < command_activate_channel.length)) {
        if (activate) {
          // serial_openBCI.write(command_activate_channel[Ichan]);
          gui.cc.powerUpChannel(Ichan);
        } else {
          // serial_openBCI.write(command_deactivate_channel[Ichan]);
          gui.cc.powerDownChannel(Ichan);
        }
      }
    }
  }
  
  //deactivate an EEG channel...channel counting is zero through nchan-1
  public void deactivateChannel(int Ichan) {
    if (serial_openBCI != null) {
      if ((Ichan >= 0) && (Ichan < command_activate_channel.length)) {
        serial_openBCI.write(command_activate_channel[Ichan]);
      }
    }
  }

  //return the state
  public boolean isStateNormal() { 
    if (state == STATE_NORMAL) { 
      return true;
    } else {
      return false;
    }
  }
  
  // ---- DEPRECATED ---- 
  // public void changeImpedanceState(int Ichan,boolean activate,int code_P_N_Both) {
  //   //println("OpenBCI_ADS1299: changeImpedanceState: Ichan " + Ichan + ", activate " + activate + ", code_P_N_Both " + code_P_N_Both);
  //   if (serial_openBCI != null) {
  //     if ((Ichan >= 0) && (Ichan < command_activate_leadoffP_channel.length)) {
  //       if (activate) {
  //         if ((code_P_N_Both == 0) || (code_P_N_Both == 2)) {
  //           //activate the P channel
  //           serial_openBCI.write(command_activate_leadoffP_channel[Ichan]);
  //         } else if ((code_P_N_Both == 1) || (code_P_N_Both == 2)) {
  //           //activate the N channel
  //           serial_openBCI.write(command_activate_leadoffN_channel[Ichan]);
  //         }
  //       } else {
  //         if ((code_P_N_Both == 0) || (code_P_N_Both == 2)) {
  //           //deactivate the P channel
  //           serial_openBCI.write(command_deactivate_leadoffP_channel[Ichan]);
  //         } else if ((code_P_N_Both == 1) || (code_P_N_Both == 2)) {
  //           //deactivate the N channel
  //           serial_openBCI.write(command_deactivate_leadoffN_channel[Ichan]);
  //         }          
  //       }
  //     }
  //   }
  // }
  
  // public void setBiasAutoState(boolean isAuto) {
  //   if (serial_openBCI != null) {
  //     if (isAuto) {
  //       println("OpenBCI_ADS1299: setBiasAutoState: setting bias to AUTO");
  //       serial_openBCI.write(command_biasAuto);
  //     } else {
  //       println("OpenBCI_ADS1299: setBiasAutoState: setting bias to REF ONLY");
  //       serial_openBCI.write(command_biasFixed);
  //     }
  //   }
  // }
  
  private int interpret24bitAsInt32(byte[] byteArray) {     
    //little endian
    int newInt = ( 
      ((0xFF & byteArray[0]) << 16) |
      ((0xFF & byteArray[1]) << 8) | 
      (0xFF & byteArray[2])
      );
    if ((newInt & 0x00800000) > 0) {
      newInt |= 0xFF000000;
    } else {
      newInt &= 0x00FFFFFF;
    }
    return newInt;
  }
  
  private int interpret16bitAsInt32(byte[] byteArray) {
    int newInt = (
      ((0xFF & byteArray[0]) << 8) |
       (0xFF & byteArray[1])
      );
    if ((newInt & 0x00008000) > 0) {
      newInt |= 0xFFFF0000;
    } else {
      newInt &= 0x0000FFFF;
    }
    return newInt;
  }
  
  public int copyDataPacketTo(DataPacket_ADS1299 target) {
    isNewDataPacketAvailable = false;
    dataPacket.copyTo(target);
    return 0;
  }
};
  
//  int measurePacketLength() {
//    
//    //assume curBuffIndex has already been incremented to the next open spot
//    int startInd = curBuffIndex-1;
//    int endInd = curBuffIndex-1;
//
//    //roll backwards to find the start of the packet
//    while ((startInd >= 0) && (serialBuff[startInd] != BYTE_START)) {
//      startInd--;
//    }
//    if (startInd < 0) {
//      //didn't find the start byte..so ignore this data packet
//      return 0;
//    } else if ((endInd - startInd + 1) < 3) {
//      //data packet isn't long enough to hold any data...so ignore this data packet
//      return 0;
//    } else {
//      //int n_bytes = int(serialBuff[startInd + 1]); //this is the number of bytes in the payload
//      //println("OpenBCI_ADS1299: measurePacketLength = " + (endInd-startInd+1));
//      return endInd-startInd+1;
//    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  This file contains all key commands for interactivity with GUI & OpenBCI
//  Created by Chip Audette, Joel Murphy, & Conor Russomanno
//  - Extracted from OpenBCI_GUI because it was getting too klunky
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//interpret a keypress...the key pressed comes in as "key"
public void keyPressed() {
  //note that the Processing variable "key" is the keypress as an ASCII character
  //note that the Processing variable "keyCode" is the keypress as a JAVA keycode.  This differs from ASCII  
  //println("OpenBCI_GUI: keyPressed: key = " + key + ", int(key) = " + int(key) + ", keyCode = " + keyCode);
  
  if(!controlPanel.isOpen){ //don't parse the key if the control panel is open
    if ((PApplet.parseInt(key) >=32) && (PApplet.parseInt(key) <= 126)) {  //32 through 126 represent all the usual printable ASCII characters
      parseKey(key);
    } else {
      parseKeycode(keyCode);
    }
  }
}

public void parseKey(char val) {
  int Ichan; boolean activate; int code_P_N_Both;
  
  //assumes that val is a usual printable ASCII character (ASCII 32 through 126)
  switch (val) {
    case '1':
      deactivateChannel(1-1); 
      break;
    case '2':
      deactivateChannel(2-1); 
      break;
    case '3':
      deactivateChannel(3-1); 
      break;
    case '4':
      deactivateChannel(4-1); 
      break;
    case '5':
      deactivateChannel(5-1); 
      break;
    case '6':
      deactivateChannel(6-1); 
      break;
    case '7':
      deactivateChannel(7-1); 
      break;
    case '8':
      deactivateChannel(8-1); 
      break;

    case 'q':
      if(nchan == 16){
        println("doing this thing...");
        deactivateChannel(9-1); 
      }
      break;
    case 'w':
      if(nchan == 16){
        deactivateChannel(10-1); 
      }
      break;
    case 'e':
      if(nchan == 16){
        deactivateChannel(11-1); 
      }
      break;
    case 'r':
      if(nchan == 16){
        deactivateChannel(12-1); 
      }
      break;
    case 't':
      if(nchan == 16){
        deactivateChannel(13-1); 
      }
      break;
    case 'y':
      if(nchan == 16){
        deactivateChannel(14-1); 
      }
      break;
    case 'u':
      if(nchan == 16){
        deactivateChannel(15-1); 
      }
      break;
    case 'i':
      if(nchan == 16){
        deactivateChannel(16-1); 
      }
      break;
      
    //activate channels 1-8
    case '!':
      activateChannel(1-1);
      break;
    case '@':
      activateChannel(2-1);
      break;
    case '#':
      activateChannel(3-1);
      break;
    case '$':
      activateChannel(4-1);
      break;
    case '%':
      activateChannel(5-1);
      break;
    case '^':
      activateChannel(6-1);
      break;
    case '&':
      activateChannel(7-1);
      break;
    case '*':
      activateChannel(8-1);
      break;
      
    //activate channels 9-16 (DAISY MODE ONLY)
    case 'Q':
      if(nchan == 16){
        println("doing this thing...");
        activateChannel(9-1);
      }
      break;
    case 'W':
      if(nchan == 16){
        activateChannel(10-1);
      }
      break;
    case 'E':
      if(nchan == 16){
        activateChannel(11-1);
      }
      break;
    case 'R':
      if(nchan == 16){
        activateChannel(12-1);
      }
      break;
    case 'T':
      if(nchan == 16){
        activateChannel(13-1);
      }
      break;
    case 'Y':
      if(nchan == 16){
        activateChannel(14-1);
      }
      break;
    case 'U':
      if(nchan == 16){
        activateChannel(15-1);
      }
      break;
    case 'I':
      if(nchan == 16){
        activateChannel(16-1);
      }
      break;

    //other controls
    case 's':
      println("case s...");
      stopRunning();
      // stopButtonWasPressed();
      break;
    case 'b':
      println("case b...");
      startRunning();
      // stopButtonWasPressed();
      break;
    case 'n':
      println("openBCI: " + openBCI);
      break;

    case '?':
      printRegisters();
      break;

    case 'd':
      verbosePrint("Updating GUI's channel settings to default...");
      gui.cc.loadDefaultChannelSettings();
      serial_openBCI.write('d');
      break;
      
    // //change the state of the impedance measurements...activate the N-channels
    // case 'A':
    //   Ichan = 1; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'S':
    //   Ichan = 2; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'D':
    //   Ichan = 3; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'F':
    //   Ichan = 4; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'G':
    //   Ichan = 5; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'H':
    //   Ichan = 6; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'J':
    //   Ichan = 7; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'K':
    //   Ichan = 8; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
      
    // //change the state of the impedance measurements...deactivate the N-channels
    // case 'Z':
    //   Ichan = 1; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'X':
    //   Ichan = 2; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'C':
    //   Ichan = 3; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'V':
    //   Ichan = 4; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'B':
    //   Ichan = 5; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'N':
    //   Ichan = 6; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'M':
    //   Ichan = 7; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case '<':
    //   Ichan = 8; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;

      
    case 'm':
     String picfname = "OpenBCI-" + getDateString() + ".jpg";
     println("OpenBCI_GUI: 'm' was pressed...taking screenshot:" + picfname);
     saveFrame(picfname);    // take a shot of that!
     break;

    default:
     println("OpenBCI_GUI: '" + key + "' Pressed...sending to OpenBCI...");
     // if (openBCI.serial_openBCI != null) openBCI.serial_openBCI.write(key);//send the value as ascii with a newline character
     if (serial_openBCI != null) serial_openBCI.write(key);//send the value as ascii with a newline character
    
     break;
  }
}

public void parseKeycode(int val) { 
  //assumes that val is Java keyCode
  switch (val) {
    case 8:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received BACKSPACE keypress.  Ignoring...");
      break;   
    case 9:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received TAB keypress.  Ignoring...");
      //gui.showImpedanceButtons = !gui.showImpedanceButtons;
      // gui.incrementGUIpage(); //deprecated with new channel controller
      break;    
    case 10:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received ENTER keypress.  Ignoring...");
      break;
    case 16:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received SHIFT keypress.  Ignoring...");
      break;
    case 17:
      //println("OpenBCI_GUI: parseKeycode(" + val + "): received CTRL keypress.  Ignoring...");
      break;
    case 18:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received ALT keypress.  Ignoring...");
      break;
    case 20:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received CAPS LOCK keypress.  Ignoring...");
      break;
    case 27:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received ESC keypress.  Stopping OpenBCI...");
      stopRunning();
      break; 
    case 33:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received PAGE UP keypress.  Ignoring...");
      break;    
    case 34:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received PAGE DOWN keypress.  Ignoring...");
      break;
    case 35:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received END keypress.  Ignoring...");
      break; 
    case 36:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received HOME keypress.  Ignoring...");
      break; 
    case 37:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received LEFT ARROW keypress.  Ignoring...");
      break;  
    case 38:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received UP ARROW keypress.  Ignoring...");
      break;  
    case 39:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received RIGHT ARROW keypress.  Ignoring...");
      break;  
    case 40:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received DOWN ARROW keypress.  Ignoring...");
      break;
    case 112:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F1 keypress.  Ignoring...");
      break;
    case 113:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F2 keypress.  Ignoring...");
      break;  
    case 114:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F3 keypress.  Ignoring...");
      break;  
    case 115:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F4 keypress.  Ignoring...");
      break;  
    case 116:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F5 keypress.  Ignoring...");
      break;  
    case 117:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F6 keypress.  Ignoring...");
      break;  
    case 118:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F7 keypress.  Ignoring...");
      break;  
    case 119:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F8 keypress.  Ignoring...");
      break;  
    case 120:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F9 keypress.  Ignoring...");
      break;  
    case 121:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F10 keypress.  Ignoring...");
      break;  
    case 122:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F11 keypress.  Ignoring...");
      break;  
    case 123:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received F12 keypress.  Ignoring...");
      break;     
    case 127:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received DELETE keypress.  Ignoring...");
      break;
    case 155:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received INSERT keypress.  Ignoring...");
      break; 
    default:
      println("OpenBCI_GUI: parseKeycode(" + val + "): value is not known.  Ignoring...");
      break;
  }
}
//////////////////////////////////////////////////////////////////////////
//
//		Playground Class
//		Created: 11/22/14 by Conor Russomanno
//		An extra interface pane for additional GUI features
//
//////////////////////////////////////////////////////////////////////////


class Playground {

	//button for opening and closing
	float x, y, w, h;
	int boxBG;
	int strokeColor;
	float topMargin, bottomMargin;

	boolean isOpen;
	boolean collapsing;

	Button collapser;

	Playground(int _topMargin){

		topMargin = _topMargin;
		bottomMargin = helpWidget.h;

		isOpen = false;
		collapsing = true;

		boxBG = color(255);
		strokeColor = color(138,146,153);
		collapser = new Button(0, 0, 20, 60, "<", 14);

		x = width;
		y = topMargin;
		w = 0;
		h = height - (topMargin+bottomMargin);

	}

	public void update(){
		// verbosePrint("uh huh");
		if(collapsing){
			collapse();
		} else{
			expand();
		}

		if(x > width){
			x = width;
		}

	}

	public void draw(){
		// verbosePrint("yeaaa");
		pushStyle();
			fill(boxBG);
			stroke(strokeColor);
			rect(width - w, topMargin, w, height - (topMargin + bottomMargin));
			textFont(f1);
			textAlign(LEFT, TOP);
			fill(bgColor);
			text("Developer Playground", x + 10, y + 10);
			fill(255,0,0);
			collapser.draw(PApplet.parseInt(x - collapser.but_dx), PApplet.parseInt(topMargin + (h-collapser.but_dy)/2));
		popStyle();

	}

	public boolean isMouseHere(){
		if(mouseX >= x && mouseX <= width && mouseY >= y && mouseY <= height - bottomMargin){
			return true;
		} else {
			return false;
		}
	}

	public boolean isMouseInButton(){
		verbosePrint("attempting");
		if(mouseX >= collapser.but_x && mouseX <= collapser.but_x+collapser.but_dx && mouseY >= collapser.but_y && mouseY <= collapser.but_y + collapser.but_dy){
			return true;
		} else{
			return false;
		}
	}

	public void toggleWindow(){
		if(isOpen){//if open
			verbosePrint("close");
			collapsing = true;//collapsing = true;
			isOpen = false;
			collapser.but_txt = "<";
		} else {//if closed
			verbosePrint("open");
			collapsing = false;//expanding = true;
			isOpen = true;
			collapser.but_txt = ">";
		}
	}

	public void mousePressed(){
		verbosePrint("Playground >> mousePressed()");
	}

	public void mouseReleased(){
		verbosePrint("Playground >> mouseReleased()");
	}

	public void expand(){
		if(w <= width/3){
			w = w + 50;
			x = width - w;
		}
	}

	public void collapse(){
		if(w >= 0){
			w = w - 50;
			x = width - w;
		}
	}



};

//////////////////////////////////
//
//		This file contains code used to convert HEX files (stored by OpenBCI on the local SD) into 
//		text files that can be used for PLAYBACK mode.
//		Created: Conor Russomanno - 10/22/14 (based on code written by Joel Murphy summer 2014)
//
//////////////////////////////////

//variables for SD file conversion
BufferedReader dataReader;
String dataLine;
PrintWriter dataWriter;
String convertedLine;
String thisLine;
String h;
float[] intData = new float[20];
String logFileName;
long thisTime;
long thatTime;

public void convertSDFile(){
	println("");
	try {
	 	dataLine = dataReader.readLine();
	} catch (IOException e) {
	 	e.printStackTrace();
	 	dataLine = null;
	}

	if (dataLine == null) {
		// Stop reading because of an error or file is empty
		thisTime = millis() - thatTime;
		controlPanel.convertingSD = false;
		println("nothing left in file"); 
		println("SD file conversion took "+thisTime+" mS");
		dataWriter.flush();
		dataWriter.close();
	} else{
		//        println(dataLine);
		String[] hexNums = splitTokens(dataLine,",");

		if(hexNums[0].charAt(0) == '%'){
			//          println(dataLine);
			dataWriter.println(dataLine);
			println(dataLine);
		}
		else{
			for(int i=0; i<hexNums.length; i++){
				h = hexNums[i];
				if(i > 0){
				    if(h.charAt(0) > '7'){  // if the number is negative 
				    	h = "FF" + hexNums[i];   // keep it negative
				    } else{                  // if the number is positive
				    	h = "00" + hexNums[i];   // keep it positive
				    }
				    if(i > 8){ // accelerometer data needs another byte
				    	if(h.charAt(0) == 'F'){
				        	h = "FF" + h;
				      	}else{
				        	h = "00" + h;
				      	}
				    }
			  	}
			  // println(h); // use for debugging
			    if (h.length()%2 == 0){  // make sure this is a real number
					intData[i] = unhex(h);
			    } else{
			    	intData[i] = 0;          
			    }
			  
				//if not first column(sample #) or columns 9-11 (accelerometer), convert to uV
				if(i>=1 && i<=8){
					intData[i] *= openBCI.scale_fac_uVolts_per_count;
				}
			  
				//print the current channel value
				dataWriter.print(intData[i]);
				if(i < hexNums.length-1){
					//print "," separator
			    	dataWriter.print(",");
				}
			}
			//println();
			dataWriter.println();
		} 
	}   
}

public void createPlaybackFileFromSD(){
   logFileName = "data/EEG_Data/SDconverted-"+getDateString()+".txt";
   dataWriter = createWriter(logFileName);
   dataWriter.println("%OBCI Data Log - " + getDateString());
}

public void sdFileSelected(File selection){
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    dataReader = createReader(selection.getAbsolutePath()); // ("positions.txt");
    controlPanel.convertingSD = true;
    println("Timing SD file conversion...");
    thatTime = millis();
  }
}

//////////////////
//
// The ScatterTrace class is used to draw and manage the traces on each
// X-Y line plot created using gwoptics graphing library
//
// Created: Chip Audette, May 2014
//
// Based on examples in gwoptics graphic library v0.5.0
// http://www.gwoptics.org/processing/gwoptics_p5lib/
//
// Note that this class does NOT store any of the data used for the
// plot.  Instead, you point it to the data that lives in your
// own program.  In Java-speak, I believe that this is called
// "aliasing"...in this class, I have made an "alias" to your data.
// Some people consider this dangerous.  Because Processing is slow,
// this was one technique for making it faster.  By making an alias
// to your data, you don't need to pass me the data for every update
// and I don't need to make a copy of it.  Instead, once you update
// your data array, the alias in this class is already pointing to
// the right place.  Cool, huh?
//
////////////////

//import processing.core.PApplet;








class ScatterTrace extends Blank2DTrace {
  private float[] dataX;
  private float[][] dataY;
  private float plotYScale = 1f;  //multiplied to data prior to plotting
  private float plotYOffset[];  //added to data prior to plotting, after applying plotYScale
  private int decimate_factor = 1;  // set to 1 to plot all points, 2 to plot every other point, 3 for every third point
  private DataStatus[] is_railed;
  PFont font = createFont("Arial", 16);
  float[] plotXlim;

  public ScatterTrace() {
    //font = createFont("Arial",10);
    plotXlim = new float[] {
      Float.NaN, Float.NaN
    };
  }

  /* set the plot's X and Y data by overwriting the existing data */
  public void setXYData_byRef(float[] x, float[][] y) {
    //dataX = x.clone();  //makes a copy
    dataX = x;  //just copies the reference!
    setYData_byRef(y);
  }   

  public void setYData_byRef(float[][] y) {
    //dataY = y.clone(); //makes a copy
    dataY = y;//just copies the reference!
  }   

  public void setYOffset_byRef(float[] yoff) {
    plotYOffset = yoff;  //just copies the reference!
  }

  public void setYScale_uV(float yscale_uV) {
    setYScaleFac(1.0f/yscale_uV);
  }

  public void setYScaleFac(float yscale) {
    plotYScale = yscale;
  }

  public void set_plotXlim(float val_low, float val_high) {
    if (val_high < val_low) {
      float foo = val_low;
      val_low = val_high;
      val_high = foo;
    }
    plotXlim[0]=val_low;
    plotXlim[1]=val_high;
  }
  public void set_isRailed(DataStatus[] is_rail) {
    is_railed = is_rail;
  }

  //here is the fucntion that gets called with every call to the GUI's own draw() fucntion
  public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
    float x_val;

    if (dataX.length > 0) {       
      pr.canvas.pushStyle();      //save whatever was the previous style
      //pr.canvas.stroke(255, 0, 0);  //set the new line's color
      //pr.canvas.strokeWeight(1);  //set the new line's linewidth

      //draw all the individual segments
      for (int Ichan = 0; Ichan < dataY.length; Ichan++) {
        
        //if colorMode == 1 ...
        switch (Ichan % 8) {
        case 0:
          pr.canvas.stroke(129, 113, 87);  //set the new line's color;
          break;
        case 1:
          pr.canvas.stroke(124, 75, 141);  //set the new line's color;
          break;
        case 2:
          pr.canvas.stroke(54, 87, 158);  //set the new line's color;
          break;
        case 3:
          pr.canvas.stroke(49, 113, 89);  //set the new line's color;
          break;
        case 4:
          pr.canvas.stroke(221, 178, 13);  //set the new line's color;
          break;
        case 5:
          pr.canvas.stroke(253, 94, 52);  //set the new line's color;
          break;
        case 6:
          pr.canvas.stroke(224, 56, 45);  //set the new line's color;
          break;
        case 7:
          pr.canvas.stroke(162, 82, 49);  //set the new line's color;
          break;
        }

        //if colorMode == 2 ... for future dev work ... want to be able to edit colors of EEG montage traces

        // color _RGB = Color.HSBtoRGB(float((255/OpenBCI_Nchannels)*Ichan), 100.0f, 100.0f);
        // println("_RGB: " + _RGB);
        // pr.canvas.stroke(_RGB);

        // pr.canvas.stroke((int((255/OpenBCI_Nchannels)*Ichan)), 125-(int(((255/OpenBCI_Nchannels)*Ichan)/2)), 255-(int((255/OpenBCI_Nchannels)*Ichan)));
        // pr.canvas.stroke((int((255/nchan)*Ichan)), 125-(int(((255/nchan)*Ichan)/2)), 255-(int((255/nchan)*Ichan)));

        float new_x = pr.valToX(dataX[0]);  //first point, convert from data coordinates to pixel coordinates
        float new_y = pr.valToY(dataY[Ichan][0]*plotYScale+plotYOffset[Ichan]);  //first point, convert from data coordinates to pixel coordinate
        float prev_x, prev_y;
        for (int i=1; i < dataY[Ichan].length; i+= decimate_factor) {
          prev_x = new_x;
          prev_y = new_y;
          x_val = dataX[i];
          if ( (Float.isNaN(plotXlim[0])) || ((x_val >= plotXlim[0]) && (x_val <= plotXlim[1])) ) {
            new_x = pr.valToX(x_val);
            new_y = pr.valToY(dataY[Ichan][i]*plotYScale+plotYOffset[Ichan]);
            pr.canvas.line(prev_x, prev_y, new_x, new_y);
            //if (i==1)  println("ScatterTrace: first point: new_x, new_y = " + new_x + ", " + new_y);
          } else {
            //do nothing
          }
        }

        //add annotation for is_railed...doesn't work right
        //        if (is_railed != null) {
        //          if (Ichan < is_railed.length) {
        //            if (is_railed[Ichan]) {
        //              new_x = pr.valToX(-2.0);  //near time zero
        //              new_y = pr.valToY(0.0+plotYOffset[Ichan]);
        //              println("ScatterTrace: text: new_x, new_y = " + new_x + ", " + new_y);
        //              fill(50,50,50);
        //              textFont(font);
        //              textAlign(RIGHT, BOTTOM);
        //              pr.canvas.text("RAILED",new_x,new_y,100);
        //            }
        //          }
        //       }
      }
      pr.canvas.popStyle(); //restore whatever was the previous style
    }
  }

  public void setDecimateFactor(int val) {
    decimate_factor = max(1, val);
    //println("ScatterTrace: setDecimateFactor to " + decimate_factor);
  }
}


// /////////////////////////////////////////////////////////////////////////////////////////////
class ScatterTrace_FFT extends Blank2DTrace {
  private FFT[] fftData;
  private float plotYOffset[];
  private float[] plotXlim = new float[] {
    Float.NaN, Float.NaN
  };
  private float[] goodBand_Hz = {
    -1.0f, -1.0f
  };
  private float[] badBand_Hz = {
    -1.0f, -1.0f
  };
  private boolean showFFTFilteringData = false;
  private DetectionData_FreqDomain[] detectionData;
  private Oscil wave;

  public ScatterTrace_FFT() {
  }

  public ScatterTrace_FFT(FFT foo_fft[]) {
    setFFT_byRef(foo_fft);
    //    if (foo_fft.length != plotYOffset.length) {
    //      plotYOffset = new float[foo_fft.length];
    //    }
  }

  public void setFFT_byRef(FFT foo_fft[]) {
    fftData = foo_fft;//just copies the reference!
  }   

  public void setYOffset(float yoff[]) {
    plotYOffset = yoff;
  }
  public void set_plotXlim(float val_low, float val_high) {
    if (val_high < val_low) {
      float foo = val_low;
      val_low = val_high;
      val_high = foo;
    }
    plotXlim[0]=val_low;
    plotXlim[1]=val_high;
  }

  public void setGoodBand(float band_Hz[]) {
    for (int i=0; i<2; i++) { 
      goodBand_Hz[i]=band_Hz[i];
    };
  }
  public void setBadBand(float band_Hz[]) {
    for (int i=0; i<2; i++) { 
      badBand_Hz[i]=band_Hz[i];
    };
  }
  public void showFFTFilteringData(boolean show) {
    showFFTFilteringData = show;
  }
  public void setDetectionData_freqDomain(DetectionData_FreqDomain[] data) {
    detectionData = data.clone();
  }
  public void setAudioOscillator(Oscil wave_given) {
    wave = wave_given;
  }

  public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
    float x_val, spec_value;

    //save whatever was the previous style
    pr.canvas.pushStyle();      

    //    //add FFT processing bands
    //    float[] fooBand_Hz;
    //    for (int i=0; i<2; i++) {
    //      if (i==0) {
    //        fooBand_Hz = goodBand_Hz;
    //        pr.canvas.stroke(100,255,100);
    //      } else {
    //        fooBand_Hz = badBand_Hz;
    //        pr.canvas.stroke(255,100,100);
    //      }
    //      pr.canvas.strokeWeight(13);
    //      float x1 = pr.valToX(fooBand_Hz[0]);
    //      float x2 = pr.valToX(fooBand_Hz[1]);
    //      if (!showFFTFilteringData) {
    //        x1 = -1.0f; x2=-1.0f; //draw offscreen when not active
    //      }
    //      float y1 = pr.valToY(0.13f);
    //      float y2 = pr.valToY(0.13f);
    //      pr.canvas.line(x1,y1,x2,y2);
    //    }

    if (fftData != null) {      
      pr.canvas.pushStyle();      //save whatever was the previous style

        //draw all the individual segments
      for (int Ichan=0; Ichan < fftData.length; Ichan++) {
        //if colorMode == 1 ...
        switch (Ichan % 8) {
        case 0:
          pr.canvas.stroke(129, 113, 87);  //set the new line's color;
          break;
        case 1:
          pr.canvas.stroke(124, 75, 141);  //set the new line's color;
          break;
        case 2:
          pr.canvas.stroke(54, 87, 158);  //set the new line's color;
          break;
        case 3:
          pr.canvas.stroke(49, 113, 89);  //set the new line's color;
          break;
        case 4:
          pr.canvas.stroke(221, 178, 13);  //set the new line's color;
          break;
        case 5:
          pr.canvas.stroke(253, 94, 52);  //set the new line's color;
          break;
        case 6:
          pr.canvas.stroke(224, 56, 45);  //set the new line's color;
          break;
        case 7:
          pr.canvas.stroke(162, 82, 49);  //set the new line's color;
          break;
        }

        // //if colorMode == 2...
        // // pr.canvas.stroke((int((255/OpenBCI_Nchannels)*Ichan)), 125-(int(((255/OpenBCI_Nchannels)*Ichan)/2)), 255-(int((255/OpenBCI_Nchannels)*Ichan)));
        // pr.canvas.stroke((int((255/nchan)*Ichan)), 125-(int(((255/nchan)*Ichan)/2)), 255-(int((255/nchan)*Ichan)));


        float new_x = pr.valToX(fftData[Ichan].indexToFreq(0));  //first point, convert from data coordinates to pixel coordinates
        float new_y = pr.valToY(fftData[Ichan].getBand(0)+plotYOffset[Ichan]);  //first point, convert from data coordinates to pixel coordinate
        float prev_x, prev_y;
        for (int i=1; i < fftData[Ichan].specSize (); i++) {
          prev_x = new_x;
          prev_y = new_y;
          x_val = fftData[Ichan].indexToFreq(i);
          //only plot those points that are within the frequency limits of the plot
          if ( (Float.isNaN(plotXlim[0])) || ((x_val >= plotXlim[0]) && (x_val <= plotXlim[1])) ) {
            new_x = pr.valToX(x_val);
            //spec_value = fftData[Ichan].getBand(i)/fftData[Ichan].specSize();  //uV_per_bin...this normalization is now done elsewhere
            spec_value = fftData[Ichan].getBand(i);
            new_y = pr.valToY(spec_value+plotYOffset[Ichan]);
            pr.canvas.line(prev_x, prev_y, new_x, new_y);
          } else {
            //do nothing
          } // end if Float.isNan
        }   //end of loop over spec size

          //        //add detection-related graphics
        //        if (showFFTFilteringData) {
        //          //add ellipse showing peak
        //          float new_x2 = pr.valToX(detectionData[Ichan].inband_freq_Hz);
        //          float new_y2 = pr.valToY(detectionData[Ichan].inband_uV);
        //          int diam = 8;
        //          pr.canvas.strokeWeight(1);  //set the new line's linewidth
        //          if (detectionData[Ichan].isDetected) { //if there is a detection, make more prominent
        //            diam = 8;
        //            pr.canvas.strokeWeight(4);  //set the new line's linewidth 
        //          }
        //          ellipseMode(CENTER);
        //          pr.canvas.ellipse(new_x2,new_y2,diam,diam);
        //          
        //          //add horizontal lines indicating the detction threshold and guard level (use a dashed line)
        //          for (int Iband=0;Iband<2;Iband++) {
        //            float x1, x2,y;
        //            if (Iband==1) {
        //              x1 = pr.valToX(badBand_Hz[0]);
        //              x2 = pr.valToX(badBand_Hz[1]);
        //              y = pr.valToY(detectionData[Ichan].guard_uV);
        //            } else {
        //              x1 = pr.valToX(goodBand_Hz[0]);
        //              x2 = pr.valToX(goodBand_Hz[1]);   
        //              y = pr.valToY(detectionData[Ichan].thresh_uV);
        //            }         
        //
        //            pr.canvas.strokeWeight(1.5);
        //            float dx = 8; //how big is the dash+space
        //            float nudge = 2;
        //            float foo_x=min(x1+dx,x2); //start here
        //            while (foo_x < x2) {
        //              pr.canvas.line(foo_x-dx+nudge,y,foo_x-(5*dx)/8+nudge,y);
        //              foo_x += dx;
        //            }
        //          }
        //        }
      } // end loop over channels

      //      //update the audio
      //      if (showFFTFilteringData & (wave != null)) {
      //        //find if any channels have detected, and which is the strongest SNR
      //        float maxExcessSNR = -100.0f;
      //        for (int Ichan=0; Ichan < detectionData.length; Ichan++) {  
      //          if (detectionData[Ichan].isDetected) {
      //            //how much above the threshold are we
      //            maxExcessSNR = max(maxExcessSNR,(detectionData[Ichan].inband_uV)/(detectionData[Ichan].thresh_uV));
      //          }
      //        }
      //        float audioFreq_Hz = calcDesiredAudioFrequency(maxExcessSNR);
      //        if (audioFreq_Hz > 0) {
      //          wave.amplitude.setLastValue(0.8);  //turn on 
      //          wave.frequency.setLastValue(audioFreq_Hz);  //set the desired frequency
      //          println("ScatterTrace: excessSNR = " + maxExcessSNR  + ", freq = " + audioFreq_Hz + " Hz");
      //        } else {
      //          //turn off
      //          wave.amplitude.setLastValue(0.0);
      //        }
      //      } else {
      //        //ensure that the audio is off
      //        wave.amplitude.setLastValue(0);  
      //      }    


      pr.canvas.popStyle(); //restore whatever was the previous style
    }
  }

  public float calcDesiredAudioFrequency(float excessSNR) {
    //set some constants
    final float excessSNRRange[] = { 
      1.0f, 3.0f
    };  //not dB, just linear units
    final float freqRange_Hz[] = {
      200.0f, 600.0f
    };

    //compute the desired snr
    float outputFreq_Hz = -1.0f;
    if (excessSNR >= excessSNRRange[0]) {
      excessSNR = constrain(excessSNR, excessSNRRange[0], excessSNRRange[1]);
      outputFreq_Hz = map(excessSNR, excessSNRRange[0], excessSNRRange[1], freqRange_Hz[0], freqRange_Hz[1]);
    }
    return outputFreq_Hz;
  }
};

///////////////////////////////////////////////
//
// Created: Chip Audette, Oct 2013
// Modified: through May 2014
//
// No warranty.  Use at your own risk.  Use for whatever you'd like.
// 
///////////////////////////////////////////////


//import ddf.minim.analysis.*; //for FFT

class Spectrogram {
  public int Nfft;
  //public float dataSlices[][];   //holds the data in [Nslices][Nfft] manner
  //public float dT_perSlice_sec;  //time interval between slices
  public float fs_Hz;            //sample rate
  public PImage img;
  public double clim[] = {0.0d, 1.0d};
  private FFT localFftData;
  private float[] localDataBuff;
  private int localDataBuffCounter;
  public int fft_stepsize;
  public int Nslices;
  
  
  Spectrogram(int N, float fs, int fft_step, float tmax_sec) {
    println("Spectrogram: N, fs, fft_step, tmax_sec = " + N + " " + fs + " " + fft_step + " " + tmax_sec);
    Nfft=N;
    fs_Hz = fs;
    //dT_perSlice_sec = ((float)Nfft) / fs;
    fft_stepsize = constrain(fft_step,1,Nfft);
//    clim[0] = java.lang.Math.log(0.01f);
//    clim[1] = java.lang.Math.log(200.0f);
         
    //create zero data for the local time-domain buffer
    localDataBuff = new float[Nfft];
    for (int I=0; I < Nfft; I++) {
      localDataBuff[I] = 0.0f; //initialize
    }
    localDataBuffCounter = Nfft-fft_stepsize;
    
    //initialize FFT 
    localFftData = new FFT(Nfft, fs_Hz);
    localFftData.window(FFT.HAMMING);
    
    //create the image
    int tmax_samps = (int)(tmax_sec * fs_Hz + 0.5f);  //the 0.5 is to round, not truncate
    Nslices = (int)(((float)(tmax_samps-Nfft))/((float)fft_stepsize+0.5f)) + 1;
    img = createImage(Nslices,localFftData.specSize(),RGB);
    println("Spectrogram: image is " + Nslices + " x " + localFftData.specSize());
    img.loadPixels(); //this is apparently necessary to allocate the space for the pixels
    int count=0;
    for (int J=0; J < localFftData.specSize(); J++) {
      for (int I=0; I<Nslices;I++) {
        img.pixels[count]=getColor(java.lang.Math.log(0.0001f));
        count++;
      }
    }
    img.updatePixels();   
  }
  
  public void addDataPoint(float dataPoint) {
    
    //add point
    localDataBuff[localDataBuffCounter] = dataPoint;
    //println("Spectrogram.addDataPoint(): counter = " + localDataBuffCounter + ", data = " + localDataBuff[localDataBuffCounter]);
     
    //increment counter for next time
    localDataBuffCounter++;
    
    //are we full?
    if (localDataBuffCounter >= Nfft) {
      //println("Spectrogra.addDataPoint(): processing the FFT block");
      
      //compute the new FFT and update the overall image
      addDataBlock(localDataBuff);
        
      //shift the data buffer to make space for the next points
      //println("addDataPoint: Nfft, fft_stepsize + " + Nfft + " " + fft_stepsize);
      for (int I=0; I < (Nfft-fft_stepsize); I++) {
        localDataBuff[I]=localDataBuff[(int)(I+fft_stepsize)];
        //println("addDataPoint: Shifting " + I + " from " + (I+fft_stepsize) + ", val = " + (localDataBuff[I]));
      }
      
      //point the counter to the new location to start accumulating data
      localDataBuffCounter = Nfft-fft_stepsize;
    }
  } 

  public void addDataBlock(float[] dataHere) {
    float foo;
        
    //do the FFT on the data block
    float[] localCopy = new float[dataHere.length];
    localCopy = Arrays.copyOfRange(dataHere,0, dataHere.length);
    float meanVal = mean(localCopy);
    for (int I=0; I<localCopy.length;I++) localCopy[I] -= meanVal;  //remove mean before doing FFT
    localFftData.forward(localCopy);
    
    //convert fft data to uV_per_sqrtHz
    //final float mean_winpow_sqr = 0.3966;  //account for power lost when windowing...mean(hamming(N).^2) = 0.3966
    final float mean_winpow = 1.0f/sqrt(2.0f);  //account for power lost when windowing...mean(hamming(N).^2) = 0.3966
    final float scale_rawPSDtoPSDPerHz = ((float)localFftData.specSize())*fs_Hz*mean_winpow; //normalize the amplitude by the number of bins to get the correct scaling to uV/sqrt(Hz)???
    for (int I=0; I < localFftData.specSize(); I++) {  //loop over each FFT bin
      foo = sqrt(pow(localFftData.getBand(I),2)/scale_rawPSDtoPSDPerHz);
      //if ((I > 5) & (I < 15)) println("Spectrogram: uV/rtHz = " + I + " " + foo);
      localFftData.setBand(I,foo);
    }

    //update image...shift all previous pixels to the left
    int pixel_ind=0;
    int nPixelsWide = Nslices;
    for (int J=0; J < localFftData.specSize(); J++) {
      for (int I=0; I < (nPixelsWide-1); I++) {
        pixel_ind = J*nPixelsWide + I;
        img.pixels[pixel_ind] =   img.pixels[pixel_ind+1];
      }
    }

    //update image...set the color based on the latest data
    for (int J=0; J < localFftData.specSize(); J++) {
      pixel_ind = (localFftData.specSize()-J-1)*nPixelsWide + (nPixelsWide-1); //build from bottom-left
      foo = localFftData.getBand(J); foo=max(foo,0.001f);
      img.pixels[pixel_ind] = getColor(java.lang.Math.log(foo));
    }
    
    //we're finished with the pixels, so update the image
    //println("addNewData: updating the pixels");
    img.updatePixels();
  }
  
  //model after matlab's "jet" color scheme
  private int getColor(double given_val) {
    float r,b,g;
    float val = (float)((given_val - clim[0])/(clim[1]-clim[0]));
    val = min(1.0f,max(0.0f,val)); //span [0.0 1.0]
    
    //compute color
    float[] bounds = {1.0f/8.0f, 3.0f/8.0f, 5.0f/8.0f, 7.0f/8.0f};
    if (val < bounds[0]) {
      r = 0.0f;
      g = 0.0f;
      b = map(val,0.0f,bounds[0],0.5f,1.0f);
    } else if (val <  bounds[1]) {
      r = 0.0f;
      g = map(val,bounds[0],bounds[1],0.0f,1.0f);
      b = 1.0f;
    } else if (val < bounds[2]) {
      r = map(val,bounds[1],bounds[2],0.0f,1.0f);
      g = 1.0f;
      b = map(val,bounds[1],bounds[2],1.0f,0.0f);
    } else if (val < bounds[3]) {
      r = 1.0f;
      g = map(val,bounds[2],bounds[3],1.0f,0.0f);
      b = 0.0f;
    } else {
      r = map(val,bounds[3],1.0f,1.0f,0.5f);
      g = 0.0f;
      b = 0.0f;
    } 
    return color((int)(r*255.f),(int)(g*255.f),(int)(b*255.f));
  }
  
  public void draw(int x, int y, int w, int h,float max_freq_Hz) {
    if (false) {
      //draw the whole image
      image(img,x,y,w,h);
    } else {
      //float max_freq_Hz = freq_lim_Hz[1];
      int max_ind = 0;
      while ((localFftData.indexToFreq(max_ind) <= max_freq_Hz) & (max_ind < localFftData.specSize()-1)) max_ind++;
      //println("Spectrogram.draw(): max_ind = " + max_ind);
      //PImage foo = (PImage)(img.get(0,localFftData.specSize()-1-max_ind,Nslices,localFftData.specSize()-1)).clone();
      //println("spectrogram.draw() max freq = " + localFftData.indexToFreq(max_ind));
      int img_x = 0; 
      int img_y = localFftData.specSize()-1-max_ind; 
      int img_w = Nslices - img_x + 1;
      int img_h = localFftData.specSize()-1 - img_y + 1;
      image(img.get(img_x,img_y,img_w,img_h),x,y,w,h); //plot a subset
    }
  }
}

////////////////////////////////////////////////////////////
// Class: OutputFile_rawtxt
// Purpose: handle file creation and writing for the text log file
// Created: Chip Audette  May 2, 2014
//
//write data to a text file
public class OutputFile_rawtxt {
  PrintWriter output;
  String fname;
  private int rowsWritten;

  OutputFile_rawtxt(float fs_Hz) {

    //build up the file name
    fname = "SavedData\\OpenBCI-RAW-";

    //add year month day to the file name
    fname = fname + year() + "-";
    if (month() < 10) fname=fname+"0";
    fname = fname + month() + "-";
    if (day() < 10) fname = fname + "0";
    fname = fname + day(); 

    //add hour minute sec to the file name
    fname = fname + "_";
    if (hour() < 10) fname = fname + "0";
    fname = fname + hour() + "-";
    if (minute() < 10) fname = fname + "0";
    fname = fname + minute() + "-";
    if (second() < 10) fname = fname + "0";
    fname = fname + second();

    //add the extension
    fname = fname + ".txt";

    //open the file
    output = createWriter(fname);

    //add the header
    writeHeader(fs_Hz);
    
    //init the counter
    rowsWritten = 0;
  }

  //variation on constructor to have custom name
  OutputFile_rawtxt(float fs_Hz, String _fileName) {
    fname = "SavedData\\OpenBCI-RAW-";
    fname += _fileName;
    fname += ".txt";
    output = createWriter(fname);        //open the file
    writeHeader(fs_Hz);    //add the header
    rowsWritten = 0;    //init the counter
  }

  public void writeHeader(float fs_Hz) {
    output.println("%OpenBCI Raw EEG Data");
    output.println("%");
    output.println("%Sample Rate = " + fs_Hz + " Hz");
    output.println("%First Column = SampleIndex");
    output.println("%Other Columns = EEG data in microvolts with optional columns at end being unscaled Aux data");
    output.flush();
  }


//  public void writeRawData_dataPacket(DataPacket_ADS1299 data, float scale_to_uV, float scale_for_aux) {
//    writeRawData_dataPacket(data, scale_to_uV, data.values.length);
//  }
  public void writeRawData_dataPacket(DataPacket_ADS1299 data, float scale_to_uV, float scale_for_aux) {
    if (output != null) {
      output.print(Integer.toString(data.sampleIndex));
      writeValues(data.values,scale_to_uV);
      writeValues(data.auxValues,scale_for_aux);
      output.println(); rowsWritten++;
      //output.flush();
    }
  }
  
  private void writeValues(int[] values, float scale_fac) {          
    int nVal = values.length;
    for (int Ival = 0; Ival < nVal; Ival++) {
      output.print(", ");
      output.print(String.format("%.2f", scale_fac * PApplet.parseFloat(values[Ival])));
    }
  }



  public void closeFile() {
    output.flush();
    output.close();
  }

  public int getRowsWritten() {
    return rowsWritten;
  }
}


///////////////////////////////////////////////////////////////
// Class: Table_CSV
// Purpose: Extend the Table class to handle data files with comment lines
// Created: Chip Audette  May 2, 2014
//
// Usage: Only invoke this object when you want to read in a data
//    file in CSV format.  Read it in at the time of creation via
//    
//    String fname = "myfile.csv";
//    TableCSV myTable = new TableCSV(fname);
//
//import java.io.*; 
//import processing.core.PApplet;
class Table_CSV extends Table {
  Table_CSV(String fname) throws IOException {
    init();
    readCSV(PApplet.createReader(createInput(fname)));
  }

  //this function is nearly completely copied from parseBasic from Table.java
  public void readCSV(BufferedReader reader) throws IOException {
    boolean header=false;  //added by Chip, May 2, 2014;
    boolean tsv = false;  //added by Chip, May 2, 2014;

    String line = null;
    int row = 0;
    if (rowCount == 0) {
      setRowCount(10);
    }
    //int prev = 0;  //-1;
    try {
      while ( (line = reader.readLine ()) != null) {
        //added by Chip, May 2, 2014 to ignore lines that are comments
        if (line.charAt(0) == '%') {
          //println("Table_CSV: readCSV: ignoring commented line...");
          continue;
        }

        if (row == getRowCount()) {
          setRowCount(row << 1);
        }
        if (row == 0 && header) {
          setColumnTitles(tsv ? PApplet.split(line, '\t') : splitLineCSV(line));
          header = false;
        } 
        else {
          setRow(row, tsv ? PApplet.split(line, '\t') : splitLineCSV(line));
          row++;
        }

        // this is problematic unless we're going to calculate rowCount first
        if (row % 10000 == 0) {
          /*
        if (row < rowCount) {
           int pct = (100 * row) / rowCount;
           if (pct != prev) {  // also prevents "0%" from showing up
           System.out.println(pct + "%");
           prev = pct;
           }
           }
           */
          try {
            // Sleep this thread so that the GC can catch up
            Thread.sleep(10);
          } 
          catch (InterruptedException e) {
            e.printStackTrace();
          }
        }
      }
    } 
    catch (Exception e) {
      throw new RuntimeException("Error reading table on line " + row, e);
    }
    // shorten or lengthen based on what's left
    if (row != getRowCount()) {
      setRowCount(row);
    }
  }
}


//////////////////////////////////////
//
// This file contains classes that are helfpul in some way.
//
// Created: Chip Audette, Oct 2013
//
/////////////////////////////////////

class DataPacket_ADS1299 {
  int sampleIndex;
  int[] values;
  int[] auxValues;

  //constructor, give it "nValues", which should match the number of values in the
  //data payload in each data packet from the Arduino.  This is likely to be at least
  //the number of EEG channels in the OpenBCI system (ie, 8 channels if a single OpenBCI
  //board) plus whatever auxiliary data the Arduino is sending. 
  DataPacket_ADS1299(int nValues, int nAuxValues) {
    values = new int[nValues];
    auxValues = new int[nAuxValues];
  }
  public int printToConsole() {
    print("printToConsole: DataPacket = ");
    print(sampleIndex);
    for (int i=0; i < values.length; i++) {
      print(", " + values[i]);
    }
    for (int i=0; i < auxValues.length; i++) {
      print(", " + auxValues[i]);
    }
    println();
    return 0;
  }
  public int copyTo(DataPacket_ADS1299 target) {
    target.sampleIndex = sampleIndex;
    //int nvalues = min(values.length, target.values.length); //handles case when nchan < OpenBCI_nchannels
    int nvalues = values.length;
    for (int i=0; i < nvalues; i++) {
      target.values[i] = values[i];
    }
    nvalues = auxValues.length;
    for (int i=0; i < nvalues; i++) {
      target.auxValues[i] = auxValues[i];
    }
    return 0;
  }
};

class DataStatus {
  public boolean is_railed;
  private int threshold_railed;
  public boolean is_railed_warn;
  private int threshold_railed_warn;
  
  DataStatus(int thresh_railed, int thresh_railed_warn) {
    is_railed = false;
    threshold_railed = thresh_railed;
    is_railed_warn = false;
    threshold_railed_warn = thresh_railed_warn;
  }
  public void update(int data_value) {
    is_railed = false;
    if (abs(data_value) >= threshold_railed) is_railed = true;
    is_railed_warn = false;
    if (abs(data_value) >= threshold_railed_warn) is_railed_warn = true;
  }
};
    

public class FilterConstants {
  public double[] a;
  public double[] b;
  public String name;
  public String short_name;
  FilterConstants(double[] b_given, double[] a_given, String name_given, String short_name_given) {
    b = new double[b_given.length];a = new double[b_given.length];
    for (int i=0; i<b.length;i++) { b[i] = b_given[i];}
    for (int i=0; i<a.length;i++) { a[i] = a_given[i];}
    name = name_given;
    short_name = short_name_given;
  }
}

public class DetectionData_FreqDomain {
  public float inband_uV = 0.0f;
  public float inband_freq_Hz = 0.0f;
  public float guard_uV = 0.0f;
  public float thresh_uV = 0.0f;
  public boolean isDetected = false;
  
  DetectionData_FreqDomain() {
  }
};

public class GraphDataPoint {
  public double x;
  public double y;
  public String x_units;
  public String y_units;
};

class PlotFontInfo {
    String fontName = "Raleway-Regular.otf";
    int axisLabel_size = 16;
    int tickLabel_size = 14;
    int buttonLabel_size = 12;
};

public class TextBox {
  public int x, y;
  public int textColor;
  public int backgroundColor;
  private PFont font;
  private int fontSize;
  public String string;
  public boolean drawBackground;
  public int backgroundEdge_pixels;
  public int alignH,alignV;
  
//  textBox(String s,int x1,int y1) {
//    textBox(s,x1,y1,0);
//  }
  TextBox(String s, int x1, int y1) {
    string = s; x = x1; y = y1;
    backgroundColor = color(255,255,255);
    textColor = color(0,0,0);
    fontSize = 12;
    font = createFont("Arial",fontSize);
    backgroundEdge_pixels = 1;
    drawBackground = false;
    alignH = LEFT;
    alignV = BOTTOM;
  }
  public void setFontSize(int size) {
    fontSize = size;
    font = createFont("Raleway-SemiBold.otf",fontSize);
  }
  public void draw() {
    //define text
    noStroke();
    textFont(font);
    
    //draw the box behind the text
    if (drawBackground == true) {
      int w = PApplet.parseInt(round(textWidth(string)));
      int xbox = x - backgroundEdge_pixels;
      switch (alignH) {
        case LEFT:
          xbox = x - backgroundEdge_pixels;
          break;
        case RIGHT:
          xbox = x - w - backgroundEdge_pixels;
          break;
        case CENTER:
          xbox = x - PApplet.parseInt(round(w/2.0f)) - backgroundEdge_pixels;
          break;
      }
      w = w + 2*backgroundEdge_pixels;
      int h = PApplet.parseInt(textAscent())+2*backgroundEdge_pixels;        
      int ybox = y - PApplet.parseInt(round(textAscent())) - backgroundEdge_pixels -2;
      fill(backgroundColor);
      rect(xbox,ybox,w,h);
    }
    //draw the text itself
    fill(textColor);
    textAlign(alignH,alignV);
    text(string,x,y);
    strokeWeight(1);
  }
};


//compute the standard deviation
public float std(float[] data) {
  //calc mean
  float ave = mean(data);
  
  //calc sum of squares relative to mean
  float val = 0;
  for (int i=0; i < data.length; i++) {
    val += pow(data[i]-ave,2);
  }
  
  // divide by n to make it the average
  val /= data.length;
  
  //take square-root and return the standard
  return (float)Math.sqrt(val);
}


public float mean(float[] data) {
  return mean(data,data.length);
}

public int medianDestructive(int[] data) {
  sort(data);
  int midPoint = data.length / 2;
  return data[midPoint];
}
  

//////////////////////////////////////////////////
//
// Some functions to implement some math and some filtering.  These functions
// probably already exist in Java somewhere, but it was easier for me to just
// recreate them myself as I needed them.
//
// Created: Chip Audette, Oct 2013
//
//////////////////////////////////////////////////

public int findMax(float[] data) {
  float maxVal = data[0];
  int maxInd = 0;
  for (int I=1; I<data.length; I++) {
    if (data[I] > maxVal) {
      maxVal = data[I];
      maxInd = I;
    }
  }
  return maxInd;
}

public float mean(float[] data, int Nback) {
  return sum(data,Nback)/Nback;
}

public float sum(float[] data) {
  return sum(data, data.length);
}

public float sum(float[] data, int Nback) {
  float sum = 0;
  if (Nback > 0) {
    for (int i=(data.length)-Nback; i < data.length; i++) {
      sum += data[i];
    }
  }
  return sum;
}

public float calcDotProduct(float[] data1, float[] data2) {
  int len = min(data1.length, data2.length);
  float val=0.0f;
  for (int I=0;I<len;I++) {
    val+=data1[I]*data2[I];
  }
  return val;
}
  

public float log10(float val) {
  return (float)Math.log10(val);
}

public float filterWEA_1stOrderIIR(float[] filty, float learn_fac, float filt_state) {
  float prev = filt_state;
  for (int i=0; i < filty.length; i++) {
    filty[i] = prev*(1-learn_fac) + filty[i]*learn_fac;
    prev = filty[i]; //save for next time
  }
  return prev;
}

public void filterIIR(double[] filt_b, double[] filt_a, float[] data) {
  int Nback = filt_b.length;
  double[] prev_y = new double[Nback];
  double[] prev_x = new double[Nback];
  
  //step through data points
  for (int i = 0; i < data.length; i++) {   
    //shift the previous outputs
    for (int j = Nback-1; j > 0; j--) {
      prev_y[j] = prev_y[j-1];
      prev_x[j] = prev_x[j-1];
    }
    
    //add in the new point
    prev_x[0] = data[i];
    
    //compute the new data point
    double out = 0;
    for (int j = 0; j < Nback; j++) {
      out += filt_b[j]*prev_x[j];
      if (j > 0) {
        out -= filt_a[j]*prev_y[j];
      }
    }
    
    //save output value
    prev_y[0] = out;
    data[i] = (float)out;
  }
}
    

public void removeMean(float[] filty, int Nback) {
  float meanVal = mean(filty,Nback);
  for (int i=0; i < filty.length; i++) {
    filty[i] -= meanVal;
  }
}

public void rereferenceTheMontage(float[][] data) {
  int n_chan = data.length;
  int n_points = data[0].length;
  float sum, mean;
  
  //loop over all data points
  for (int Ipoint=0;Ipoint<n_points;Ipoint++) {
    //compute mean signal right now
    sum=0.0f;
    for (int Ichan=0;Ichan<n_chan;Ichan++) sum += data[Ichan][Ipoint];
    mean = sum / n_chan;
    
    //remove the mean signal from all channels
    for (int Ichan=0;Ichan<n_chan;Ichan++) data[Ichan][Ipoint] -= mean;
  }
}
  

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "OpenBCI_GUI" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
