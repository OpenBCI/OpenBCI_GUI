

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

  ControlPanel(OpenBCI_GUI mainClass) {

    x = 2;
    y = 2 + controlPanelCollapser.but_dy;		
    w = controlPanelCollapser.but_dx;
    h = height - int(helpWidget.h);

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
      initButtonPressed = true;
    }

    //only able to click buttons of control panel when system is not running
    if (systemMode != 10) {
      //active buttons during DATASOURCE_NORMAL
      if (eegDataSource == 0) {
        if (refreshPort.isMouseHere()) {
          refreshPort.setIsActive(true);
          refreshButtonPressed = true;
        }

        if (autoFileName.isMouseHere()) {
          autoFileName.setIsActive(true);
          fileButtonPressed = true;
        }

        if (chanButton8.isMouseHere()) {
          chanButton8.setIsActive(true);
          chanButton8Pressed = true;
          chanButton8.color_notPressed = isSelected_color;
          chanButton16.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (chanButton16.isMouseHere()) {
          chanButton16.setIsActive(true);
          chanButton16Pressed = true;
          chanButton8.color_notPressed = autoFileName.color_notPressed; //default color of button
          chanButton16.color_notPressed = isSelected_color;
        }
      }

      //active buttons during DATASOURCE_PLAYBACKFILE
      if (eegDataSource == 1) {
        if (selectPlaybackFile.isMouseHere()) {
          selectPlaybackFile.setIsActive(true);
          selectPlaybackFilePressed = true;
        }

        if (selectSDFile.isMouseHere()) {
          selectSDFile.setIsActive(true);
          selectSDFilePressed = true;
        }
      }
    }

    // output("Text File Name: " + cp5.get(Textfield.class,"fileName").getText());
  }

  //mouse released in control panel
  public void CPmouseReleased() {
    verbosePrint("CPMouseReleased: CPmouseReleased start...");
    if (initSystemButton.isMouseHere() && initButtonPressed) {

      //if system is not active ... initate system and flip button state
      if (initSystemButton.but_txt == "START SYSTEM") {

        if ((eegDataSource == DATASOURCE_NORMAL || eegDataSource == DATASOURCE_NORMAL_W_AUX) && openBCI_portName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
          output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
          initButtonPressed = false;
          initSystemButton.setIsActive(false);
          return;
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
          output("No playback file selected. Please select a playback file and retry system initiation.");				// tell user that they need to select a file before the system can be started
          initButtonPressed = false;
          initSystemButton.setIsActive(false);
          return;
        } else if (eegDataSource == -1) {//if no data source selected
          output("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
          initButtonPressed = false;
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
      //cursor(ARROW); //this this back to ARROW
    }

    //open or close serial port if serial port button is pressed (left button in serial widget)
    if (refreshPort.isMouseHere() && refreshButtonPressed) {
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
    if (autoFileName.isMouseHere() && fileButtonPressed) {
      output("Autogenerated \"File Name\" based on current date/time");
      cp5.get(Textfield.class, "fileName").setText(getDateString());
    }

    if (chanButton8.isMouseHere() && chanButton8Pressed) {
      nchan = 8;
      fftBuff = new FFT[nchan];   //from the minim library
      yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
      output("channel count set to " + str(nchan));
      updateChannelArrays(nchan); //make sure to reinitialize the channel arrays with the right number of channels
    }

    if (chanButton16.isMouseHere() && chanButton16Pressed) {
      nchan = 16;
      fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
      yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
      output("channel count set to " + str(nchan));
      updateChannelArrays(nchan); //make sure to reinitialize the channel arrays with the right number of channels
    }

    if (selectPlaybackFile.isMouseHere() && selectPlaybackFilePressed) {
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelected");
    }

    if (selectSDFile.isMouseHere() && selectSDFilePressed) {
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
    h = 147;
    padding = _padding;

    // openClosePort = new Button (padding + border, y + padding*3 + 13 + 150, (w-padding*3)/2, 24, "OPEN PORT", fontInfo.buttonLabel_size);
    refreshPort = new Button (x + padding, y + padding*3 + 13 + 71, w - padding*2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);

    serialList = new MenuList(cp5, "serialList", w - padding*2, 72, f2);
    serialList.setPosition(x + padding, y + padding*2 + 13);
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

void playbackSelected(File selection) {
  if (selection == null) {
    println("ControlPanel: playbackSelected: Window was closed or the user hit cancel.");
  } else {
    println("ControlPanel: playbackSelected: User selected " + selection.getAbsolutePath());
    output("You have selected \"" + selection.getAbsolutePath() + "\" for playback.");
    playbackData_fname = selection.getAbsolutePath();
  }
}