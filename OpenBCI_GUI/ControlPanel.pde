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

import controlP5.*;

//------------------------------------------------------------------------
//                       Global Variables  & Instances
//------------------------------------------------------------------------

ControlPanel controlPanel;

ControlP5 cp5; //program-wide instance of ControlP5
CallbackListener cb = new CallbackListener() { //used by ControlP5 to clear text field on double-click
  public void controlEvent(CallbackEvent theEvent) {
    println("CallbackListener: controlEvent: clearing");
    cp5.get(Textfield.class, "fileName").clear();
  }
};

MenuList sourceList;

//Global buttons and elements for the control panel (changed within the classes below)
MenuList serialList;
String[] serialPorts = new String[Serial.list().length];

MenuList sdTimes;

color boxColor = color(200);
color boxStrokeColor = color(138, 146, 153);
color isSelected_color = color(184, 220, 105);

// Button openClosePort;
// boolean portButtonPressed;

Button refreshPort;
Button autoconnect;
Button initSystemButton;
Button autoFileName;
Button chanButton8;
Button chanButton16;
Button selectPlaybackFile;
Button selectSDFile;

//Radio Button Definitions
Button getChannel;
Button setChannel;
Button ovrChannel;
Button getPoll;
Button setPoll;
Button defaultBAUD;
Button highBAUD;
Button autoscan;
Button autoconnectNoStart;

Serial board;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

public void controlEvent(ControlEvent theEvent) {

  if (theEvent.isFrom("sourceList")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    String str = (String)bob.get("headline");
    str = str.substring(0, str.length()-5);
    //output("Data Source = " + str);
    int newDataSource = int(theEvent.getValue());
    eegDataSource = newDataSource; // reset global eegDataSource to the selected value from the list
    output("The new data source is " + str);
  }

  if (theEvent.isFrom("serialList")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    openBCI_portName = (String)bob.get("headline");
    output("OpenBCI Port Name = " + openBCI_portName);
  }

  if (theEvent.isFrom("sdTimes")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    sdSettingString = (String)bob.get("headline");
    sdSetting = int(theEvent.getValue());
    if (sdSetting != 0) {  
      output("OpenBCI microSD Setting = " + sdSettingString + " recording time");
    } else {
      output("OpenBCI microSD Setting = " + sdSettingString);
    }
    verbosePrint("SD setting = " + sdSetting);
  }
}

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

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
  RadioConfigBox rcBox;

  boolean drawStopInstructions;

  int globalPadding; //design feature: passed through to all box classes as the global spacing .. in pixels .. for all elements/subelements
  int globalBorder;

  boolean convertingSD = false;

  ControlPanel(OpenBCI_GUI mainClass) {

    x = 2;
    y = 2 + controlPanelCollapser.but_dy;		
    w = controlPanelCollapser.but_dx;
    h = height - int(helpWidget.h);
    
    if(hasIntroAnimation){
      isOpen = false;
    } else {
      isOpen = true;
    }

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
    rcBox = new RadioConfigBox(x+w, y, w, h, globalPadding);

    //boxes active when eegDataSource = Playback
    playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, w, h, globalPadding);
    sdConverterBox = new SDConverterBox(x + w, (playbackFileBox.y + playbackFileBox.h), w, h, globalPadding);

    initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);
  }

  public void update() {
    //toggle view of cp5 / serial list selection table
    if (isOpen) { // if control panel is open
      if (!cp5.isVisible()) {  //and cp5 is not visible
        cp5.show(); // shot it
      }
    } else { //the opposite of above
      if (cp5.isVisible()) {
        cp5.hide();
      }
    }

    //update all boxes if they need to be
    dataSourceBox.update();
    serialBox.update();
    dataLogBox.update();
    channelCountBox.update();
    sdBox.update();
    rcBox.update();
    initBox.update();

    serialList.updateMenu();

    //SD File Conversion
    while (convertingSD == true) {
      convertSDFile();
    }
  }

  public void draw() {

    pushStyle();
    noStroke();

    //dark overlay of rest of interface to indicate it's not clickable
    fill(0, 0, 0, 185);
    rect(0, 0, width, height);

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

    if (systemMode == 10) {
      drawStopInstructions = true;
    }

    if (systemMode != 10) { // only draw control panel boxes if system running is false
      dataSourceBox.draw();
      drawStopInstructions = false;
      cp5.setVisible(true);//make sure controlP5 elements are visible
      if (eegDataSource == 0) {	//when data source is from OpenBCI
        serialBox.draw();
        dataLogBox.draw();
        channelCountBox.draw();
        sdBox.draw();
        rcBox.draw();
        cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
        cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
        //make sure serial list is visible
        //set other CP5 controllers invisible
      } else if (eegDataSource == 1) { //when data source is from playback file
        playbackFileBox.draw();
        sdConverterBox.draw();
        //set other CP5 controllers invisible
        cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(false);
        cp5.get(MenuList.class, "sdTimes").setVisible(false);
      } else if (eegDataSource == 2) {
        //make sure serial list is visible
        //set other CP5 controllers invisible
        cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(false);
        cp5.get(MenuList.class, "sdTimes").setVisible(false);
      } else {
        //set other CP5 controllers invisible
        cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(false);
        cp5.get(MenuList.class, "sdTimes").setVisible(false);
      }
    } else {
      cp5.setVisible(false); // if isRunning is true, hide all controlP5 elements
    }

    //draw the box that tells you to stop the system in order to edit control settings
    if (drawStopInstructions) {
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
  public void CPmousePressed() {
    verbosePrint("CPmousePressed");

    if (initSystemButton.isMouseHere()) {
      initSystemButton.setIsActive(true);
      initSystemButton.wasPressed = true;
    }

    //only able to click buttons of control panel when system is not running
    if (systemMode != 10) {
      if(autoconnect.isMouseHere()){
        autoconnect();
        autoconnect.setIsActive(true);
        autoconnect.wasPressed = true;
      }
      //active buttons during DATASOURCE_NORMAL
      if (eegDataSource == 0) {
        if (refreshPort.isMouseHere()) {
          refreshPort.setIsActive(true);
          refreshPort.wasPressed = true;
        }

        if (autoFileName.isMouseHere()) {
          autoFileName.setIsActive(true);
          autoFileName.wasPressed = true;
        }

        if (chanButton8.isMouseHere()) {
          chanButton8.setIsActive(true);
          chanButton8.wasPressed = true;
          chanButton8.color_notPressed = isSelected_color;
          chanButton16.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (chanButton16.isMouseHere()) {
          chanButton16.setIsActive(true);
          chanButton16.wasPressed = true;
          chanButton8.color_notPressed = autoFileName.color_notPressed; //default color of button
          chanButton16.color_notPressed = isSelected_color;
        }
        
        if (getChannel.isMouseHere()){
          getChannel.setIsActive(true);
          getChannel.wasPressed = true;
        }
        
        if (autoconnectNoStart.isMouseHere()){
          autoconnectNoStart.setIsActive(true);
          autoconnectNoStart.wasPressed = true;
        }
      }

      //active buttons during DATASOURCE_PLAYBACKFILE
      if (eegDataSource == 1) {
        if (selectPlaybackFile.isMouseHere()) {
          selectPlaybackFile.setIsActive(true);
          selectPlaybackFile.wasPressed = true;
        }

        if (selectSDFile.isMouseHere()) {
          selectSDFile.setIsActive(true);
          selectSDFile.wasPressed = true;
        }
      }
    }

    // output("Text File Name: " + cp5.get(Textfield.class,"fileName").getText());
  }

  //mouse released in control panel
  public void CPmouseReleased() {
    verbosePrint("CPMouseReleased: CPmouseReleased start...");
    if(getChannel.isMouseHere() && getChannel.wasPressed){
      if(board != null) get_channel(board, rcBox);
      
      getChannel.wasPressed=false;
      getChannel.setIsActive(false);
    }
    if(autoconnectNoStart.isMouseHere() && autoconnectNoStart.wasPressed){
      if(board == null){
        try{
          board = autoconnect_return();
          rcBox.print_onscreen("Successfully connected to board");
        }
        catch (Exception e){
          rcBox.print_onscreen("Error connecting to board...");
        }
      }
      autoconnectNoStart.setIsActive(false);
      autoconnectNoStart.wasPressed = false;
    }
    
    if(autoconnect.isMouseHere() && autoconnect.wasPressed){
      system_init();
      autoconnect.wasPressed = false;
      autoconnect.setIsActive(false);
    }
    if (initSystemButton.isMouseHere() && initSystemButton.wasPressed) {
      //if system is not active ... initate system and flip button state
      system_init();
      //cursor(ARROW); //this this back to ARROW
    }

    //open or close serial port if serial port button is pressed (left button in serial widget)
    if (refreshPort.isMouseHere() && refreshPort.wasPressed) {
      output("Serial/COM List Refreshed");
      serialPorts = new String[Serial.list().length];
      serialPorts = Serial.list();
      serialList.items.clear();
      for (int i = 0; i < serialPorts.length; i++) {
        String tempPort = serialPorts[(serialPorts.length-1) - i]; //list backwards... because usually our port is at the bottom
        serialList.addItem(makeItem(tempPort));
      }
      serialList.updateMenu();
    }

    //open or close serial port if serial port button is pressed (left button in serial widget)
    if (autoFileName.isMouseHere() && autoFileName.wasPressed) {
      output("Autogenerated \"File Name\" based on current date/time");
      cp5.get(Textfield.class, "fileName").setText(getDateString());
    }

    if (chanButton8.isMouseHere() && chanButton8.wasPressed) {
      nchan = 8;
      fftBuff = new FFT[nchan];   //from the minim library
      yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
      output("channel count set to " + str(nchan));
      updateChannelArrays(nchan); //make sure to reinitialize the channel arrays with the right number of channels
    }

    if (chanButton16.isMouseHere() && chanButton16.wasPressed ) {
      nchan = 16;
      fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
      yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
      output("channel count set to " + str(nchan));
      updateChannelArrays(nchan); //make sure to reinitialize the channel arrays with the right number of channels
    }

    if (selectPlaybackFile.isMouseHere() && selectPlaybackFile.wasPressed) {
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelected");
    }

    if (selectSDFile.isMouseHere() && selectSDFile.wasPressed) {
      output("select an SD file to convert to a playback file");
      createPlaybackFileFromSD();
      selectInput("Select an SD file to convert for playback:", "sdFileSelected");
    }

    //reset all buttons to false
    refreshPort.setIsActive(false);
    refreshPort.wasPressed = false;
    initSystemButton.setIsActive(false);
    initSystemButton.wasPressed = false;
    autoFileName.setIsActive(false);
    autoFileName.wasPressed = false;
    chanButton8.setIsActive(false);
    chanButton8.wasPressed = false;
    chanButton16.setIsActive(false);
    chanButton16.wasPressed  = false;
    selectPlaybackFile.setIsActive(false);
    selectPlaybackFile.wasPressed = false;
    selectSDFile.setIsActive(false);
    selectSDFile.wasPressed = false;
  }
};

public void system_init(){
  if (initSystemButton.but_txt == "START SYSTEM") {

      if ((eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX) && openBCI_portName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
        output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
        output("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == -1) {//if no data source selected
        output("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else { //otherwise, initiate system!  
        verbosePrint("ControlPanel: CPmouseReleased: init");
        initSystemButton.setString("STOP SYSTEM");
        //global steps to START SYSTEM
        // prepare the serial port
        verbosePrint("ControlPanel — port is open: " + openBCI.isSerialPortOpen());
        if (openBCI.isSerialPortOpen() == true) {
          openBCI.closeSerialPort();
        }
        fileName = cp5.get(Textfield.class, "fileName").getText(); // store the current text field value of "File Name" to be passed along to dataFiles 
        initSystem();
      }
    }

    //if system is already active ... stop system and flip button state back
    else {
      output("SYSTEM STOPPED");
      initSystemButton.setString("START SYSTEM");
      haltSystem();
    }
}


//==============================================================================//
//					BELOW ARE THE CLASSES FOR THE VARIOUS 						//
//					CONTROL PANEL BOXes (control widgets)						//
//==============================================================================//

class DataSourceBox {
  int x, y, w, h, padding; //size and position

  CheckBox sourceCheckBox;

  DataSourceBox(int _x, int _y, int _w, int _h, int _padding) {
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

  public void update() {

  }

  public void draw() {
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

  SerialBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 171 + _padding;
    padding = _padding;

    autoconnect = new Button(x + padding, y + padding*3, w - padding*2, 24, "AUTOCONNECT AND START SYSTEM", fontInfo.buttonLabel_size);
    refreshPort = new Button (x + padding, y + padding*4 + 13 + 71 + 24, w - padding*2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);

    serialList = new MenuList(cp5, "serialList", w - padding*2, 72, f2);
    serialList.setPosition(x + padding, y + padding*3 + 13 + 24);
    serialPorts = Serial.list();
    for (int i = 0; i < serialPorts.length; i++) {
      String tempPort = serialPorts[(serialPorts.length-1) - i]; //list backwards... because usually our port is at the bottom
      serialList.addItem(makeItem(tempPort));
    }
  }

  public void update() {
    // serialList.updateMenu();
  }

  public void draw() {
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
    autoconnect.draw();
  }

  public void refreshSerialList() {
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

  DataLogBox(int _x, int _y, int _w, int _h, int _padding) {
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
      .setPosition(x + 90, y + 32)
      .setCaptionLabel("")
      .setSize(157, 26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26, 26, 26))
      .setColorBackground(color(255, 255, 255)) // text field bg color
      .setColorValueLabel(color(0, 0, 0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26, 26, 26)) 
      .setText(getDateString())
      .align(5, 10, 20, 40) 
      .onDoublePress(cb) 
      .setAutoClear(true);

    //clear text field on double click
  }

  public void update() {
  }

  public void draw() {
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

  ChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    chanButton8 = new Button (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "8 CHANNELS", fontInfo.buttonLabel_size);
    if (nchan == 8) chanButton8.color_notPressed = isSelected_color; //make it appear like this one is already selected
    chanButton16 = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "16 CHANNELS", fontInfo.buttonLabel_size);
    if (nchan == 16) chanButton16.color_notPressed = isSelected_color; //make it appear like this one is already selected
  }

  public void update() {
  }

  public void draw() {
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

  PlaybackFileBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 67;
    padding = _padding;

    selectPlaybackFile = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);
  }

  public void update() {
  }

  public void draw() {
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

  SDBox(int _x, int _y, int _w, int _h, int _padding) {
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
    
    sdTimes.activeItem = sdSetting; //added to indicate default choice (sdSetting is in OpenBCI_GUI)
  }

  public void update() {
  }

  public void draw() {
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
  
    //the drawing of the sdTimes is handled earlier in ControlPanel.draw()

  }
};

class RadioConfigBox {
  int x, y, w, h, padding; //size and position
  String last_message = "";
  Serial board;

  RadioConfigBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x + _w;
    y = _y;
    w = _w;
    h = 355;
    padding = _padding;

    getChannel = new Button(x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "GET CHANNEL", fontInfo.buttonLabel_size);
    setChannel = new Button(x + padding + (w-padding*2)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "SET CHANNEL", fontInfo.buttonLabel_size);
    ovrChannel = new Button(x + padding, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "OVERRIDE CHAN", fontInfo.buttonLabel_size);
    getPoll = new Button(x + padding + (w-padding*2)/2, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "GET POLL", fontInfo.buttonLabel_size);
    setPoll = new Button(x + padding, y + padding*4 + 18 + 24*2, (w-padding*3)/2, 24, "SET POLL", fontInfo.buttonLabel_size);
    defaultBAUD = new Button(x + padding + (w-padding*2)/2, y + padding*4 + 18 + 24*2, (w-padding*3)/2, 24, "DEFAULT BAUD", fontInfo.buttonLabel_size);    
    highBAUD = new Button(x + padding, y + padding*5 + 18 + 24*3, (w-padding*3)/2, 24, "HIGH BAUD", fontInfo.buttonLabel_size);
    autoscan = new Button(x + padding + (w-padding*2)/2, y + padding*5 + 18 + 24*3, (w-padding*3)/2, 24, "AUTOSCAN CHANS", fontInfo.buttonLabel_size);
    autoconnectNoStart = new Button(x + padding, y + padding*6 + 18 + 24*4, (w-padding*3 + 5), 24, "CONNECT TO BOARD", fontInfo.buttonLabel_size);

    
  }

  public void update() {
  }

  public void draw() {
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(f1);
    textAlign(LEFT, TOP);
    text("RADIO CONFIGURATION", x + padding, y + padding);
   
    
    popStyle();
    getChannel.draw();
    setChannel.draw();
    ovrChannel.draw();
    getPoll.draw();
    setPoll.draw();
    defaultBAUD.draw();
    highBAUD.draw();
    autoscan.draw();
    autoconnectNoStart.draw();
    this.print_onscreen(last_message);
  
    //the drawing of the sdTimes is handled earlier in ControlPanel.draw()

  }
  
  public void print_onscreen(String localstring){
    textAlign(LEFT);
    fill(0);
    rect(x + padding, y + (padding*7) + 18 + (24*5), (w-padding*3 + 5), 135);
    fill(255);
    text(localstring, x + padding + 10, y + (padding*7) + 18 + (24*5) + 15, (w-padding*3 + 35), 135);
    this.last_message = localstring;
  }
  
  public void print_lastmessage(){
  
    fill(0);
    rect(x + padding, y + (padding*7) + 18 + (24*5), (w-padding*3 + 5), 135);
    fill(255);
    text(this.last_message, 180, 340, 240, 60);
  }
};

class SDConverterBox {
  int x, y, w, h, padding; //size and position

  SDConverterBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 67;
    padding = _padding;

    selectSDFile = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT SD FILE", fontInfo.buttonLabel_size);
  }

  public void update() {
  }

  public void draw() {
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
  }
};

class InitBox {
  int x, y, w, h, padding; //size and position

  boolean initButtonPressed; //default false

  boolean isSystemInitialized;
  // button for init/halt system

  InitBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 50;
    padding = _padding;

    //init button
    initSystemButton = new Button (padding, y + padding, w-padding*2, h - padding*2, "START SYSTEM", fontInfo.buttonLabel_size);
    //initSystemButton.color_notPressed = color(boolor);
    //initSystemButton.buttonStrokeColor = color(boxColor);
    initButtonPressed = false;
  }

  public void update() {
  }

  public void draw() {

    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    popStyle();
    initSystemButton.draw();
  }
};

//===================== MENU LIST CLASS =============================//
//================== EXTENSION OF CONTROLP5 =========================//
//============== USED FOR SOURCEBOX & SERIALBOX =====================//
//
// Created: Conor Russomanno Oct. 2014
// Based on ControlP5 Processing Library example, written by Andreas Schlegel
//
/////////////////////////////////////////////////////////////////////

//makeItem function used by MenuList class below
Map<String, Object> makeItem(String theHeadline) {
  Map m = new HashMap<String, Object>();
  m.put("headline", theHeadline);
  return m;
}

//=======================================================================================================================================
//
//                    MenuList Class
//
//The MenuList class is implemented by the Control Panel. It allows you to set up a list of selectable items within a fixed rectangle size
//Currently used for Serial/COM select, SD settings, and System Mode
//
//=======================================================================================================================================

public class MenuList extends Controller {

  float pos, npos;
  int itemHeight = 24;
  int scrollerLength = 40;
  int scrollerWidth = 15;
  List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
  PGraphics menu;
  boolean updateMenu;
  boolean drawHand;
  int hoverItem = -1;
  int activeItem = -1;
  PFont menuFont = f2; 
  int padding = 7;


  MenuList(ControlP5 c, String theName, int theWidth, int theHeight, PFont theFont) {

    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(),getHeight());

    menuFont = theFont;

    setView(new ControllerView<MenuList>() {

      public void display(PGraphics pg, MenuList t) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside()) {
          if(!drawHand){
            cursor(HAND);
            drawHand = true;
          }
          menu.beginDraw();
          int len = -(itemHeight * items.size()) + getHeight();
          int ty;
          if(len != 0){
            ty = int(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
          } else {
            ty = 0;
          }
          menu.fill(bgColor, 100);
          if(ty > 0){
            menu.rect(getWidth()-scrollerWidth-2, ty, scrollerWidth, scrollerLength );
          }
          menu.endDraw();
        } 
        else {
          if(drawHand){
            drawHand = false;
            cursor(ARROW);
          }
        }
        pg.image(menu, 0, 0);
      }
    }
    );
    updateMenu();
  }

  /* only update the image buffer when necessary - to save some resources */
  void updateMenu() {
    int len = -(itemHeight * items.size()) + getHeight();
    npos = constrain(npos, len, 0);
    pos += (npos - pos) * 0.1;
    //    pos += (npos - pos) * 0.1;
    menu.beginDraw();
    menu.noStroke();
    menu.background(255, 64);
    menu.textFont(cp5.getFont().getFont());
    menu.pushMatrix();
    menu.translate( 0, pos );
    menu.pushMatrix();
    
    int i0;
    if((itemHeight * items.size()) != 0){
      i0 = PApplet.max( 0, int(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
    } else{
      i0 = 0; 
    }
    int range = ceil((float(getHeight())/float(itemHeight))+1);
    int i1 = PApplet.min( items.size(), i0 + range );

    menu.translate(0, i0*itemHeight);

    for (int i=i0; i<i1; i++) {
      Map m = items.get(i);
      menu.fill(255, 100);
      if (i == hoverItem) {
        menu.fill(127, 134, 143);
      }
      if (i == activeItem) {
        menu.stroke(184, 220, 105, 255);
        menu.strokeWeight(1);
        menu.fill(184, 220, 105, 255);
        menu.rect(0, 0, getWidth()-1, itemHeight-1 );
        menu.noStroke();
      } else {
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
    updateMenu = abs(npos-pos)>0.01 ? true:false;
  }

  /* when detecting a click, check if the click happend to the far right, if yes, scroll to that position, 
   * otherwise do whatever this item of the list is supposed to do.
   */
  public void onClick() {
    if (getPointer().x()>getWidth()-scrollerWidth) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    } else {
      int len = itemHeight * items.size();
      int index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      setValue(index);
      activeItem = index;
    }
    updateMenu = true;
  }

  public void onMove() {
    if (getPointer().x()>getWidth() || getPointer().x()<0 || getPointer().y()<0  || getPointer().y()>getHeight() ) {
      hoverItem = -1;
    } else {
      int len = itemHeight * items.size();
      int index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      hoverItem = index;
    }
    updateMenu = true;
  }

  public void onDrag() {
    if (getPointer().x() > (getWidth()-scrollerWidth)) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    } else {
      npos += getPointer().dy() * 2;
      updateMenu = true;
    }
  } 

  public void onScroll(int n) {
    npos += ( n * 4 );
    updateMenu = true;
  }

  void addItem(Map<String, Object> m) {
    items.add(m);
    updateMenu = true;
  }

  void removeItem(Map<String, Object> m) {
    items.remove(m);
    updateMenu = true;
  }

  Map<String, Object> getItem(int theIndex) {
    return items.get(theIndex);
  }
};