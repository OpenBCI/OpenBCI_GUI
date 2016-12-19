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
ControlP5 cp5Popup;
CallbackListener cb = new CallbackListener() { //used by ControlP5 to clear text field on double-click
  public void controlEvent(CallbackEvent theEvent) {

    if (cp5.isMouseOver(cp5.get(Textfield.class, "fileName"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "fileName").clear();
    }else if (cp5.isMouseOver(cp5.get(Textfield.class, "udp_ip"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "udp_ip").clear();
    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "udp_port"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "udp_port").clear();
    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "osc_ip"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "osc_ip").clear();
    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "osc_address"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "osc_address").clear();
    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "lsl_data"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "lsl_data").clear();
    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "lsl_aux"))){
      println("CallbackListener: controlEvent: clearing");
      cp5.get(Textfield.class, "lsl_aux").clear();
    }
  }
};

MenuList sourceList;

//Global buttons and elements for the control panel (changed within the classes below)
MenuList serialList;
String[] serialPorts = new String[Serial.list().length];

MenuList bleList;

MenuList sdTimes;

MenuList channelList;

MenuList pollList;

color boxColor = color(200);
color boxStrokeColor = color(bgColor);
color isSelected_color = color(184, 220, 105);

// Button openClosePort;
// boolean portButtonPressed;

int networkType = 0;

boolean calledForBLEList = false;

Button refreshPort;
Button refreshBLE;
Button autoconnect;
Button initSystemButton;
Button autoFileName;
Button outputBDF;
Button outputODF;
Button chanButton8;
Button chanButton16;
Button selectPlaybackFile;
Button selectSDFile;
Button popOut;

//Radio Button Definitions
Button getChannel;
Button setChannel;
Button ovrChannel;
Button getPoll;
Button setPoll;
Button defaultBAUD;
Button highBAUD;
Button autoscan;
Button autoconnectNoStartDefault;
Button autoconnectNoStartHigh;
Button systemStatus;

Button synthChanButton4;
Button synthChanButton8;
Button synthChanButton16;

Serial board;

ChannelPopup channelPopup;
PollPopup pollPopup;
RadioConfigBox rcBox;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

public void controlEvent(ControlEvent theEvent) {

  if (theEvent.isFrom("serialListConfig")) {
     Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
     serialNameEMG = (String)bob.get("headline");
     println(serialNameEMG);
  }
  if (theEvent.isFrom("baudList")) {
     Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
     baudEMG = (String)bob.get("headline");
     println(baudEMG);
  }
  if (theEvent.isFrom("sourceList")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    String str = (String)bob.get("headline");
    // str = str.substring(0, str.length()-5);
    //output("Data Source = " + str);
    int newDataSource = int(theEvent.getValue());
    eegDataSource = newDataSource; // reset global eegDataSource to the selected value from the list

    if(newDataSource == DATASOURCE_NORMAL_W_AUX){
      updateToNChan(8);
      chanButton8.color_notPressed = isSelected_color;
      chanButton16.color_notPressed = autoFileName.color_notPressed; //default color of button
    } else if(newDataSource == DATASOURCE_GANGLION){
      updateToNChan(4);
    } else if(newDataSource == DATASOURCE_PLAYBACKFILE){
      updateToNChan(8);
    } else if(newDataSource == DATASOURCE_SYNTHETIC){
      updateToNChan(8);
      synthChanButton4.color_notPressed = autoFileName.color_notPressed;
      synthChanButton8.color_notPressed = isSelected_color;
      synthChanButton16.color_notPressed = autoFileName.color_notPressed;
    }

    output("The new data source is " + str + " and NCHAN = [" + nchan + "]");
  }

  if (theEvent.isFrom("serialList")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    openBCI_portName = (String)bob.get("headline");
    output("OpenBCI Port Name = " + openBCI_portName);
  }

  if (theEvent.isFrom("bleList")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    ganglion_portName = (String)bob.get("headline");
    output("Ganglion Device Name = " + ganglion_portName);
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
  if (theEvent.isFrom("networkList")){
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    String str = (String)bob.get("headline");
    int index = int(theEvent.getValue());
    if (index == 0) {
      networkType = 0;
    } else if (index ==1){
      networkType = 1;
    } else if (index == 2){
      networkType = 2;
    } else if (index == 3){
      networkType = 3;
    }
  }

  if (theEvent.isFrom("channelList")){
    int setChannelInt = int(theEvent.getValue()) + 1;
    //Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    cp5Popup.get(MenuList.class, "channelList").setVisible(false);
    channelPopup.setClicked(false);
    if(setChannel.wasPressed){
      set_channel(rcBox,setChannelInt);
      setChannel.wasPressed = false;
    }
    else if(ovrChannel.wasPressed){
      set_channel_over(rcBox,setChannelInt);
      ovrChannel.wasPressed = false;
    }
    println("still goin off");

  }

  if (theEvent.isFrom("pollList")){
    int setChannelInt = int(theEvent.getValue());
    //Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    cp5Popup.get(MenuList.class, "pollList").setVisible(false);
    channelPopup.setClicked(false);
    set_poll(rcBox,setChannelInt);
    setPoll.wasPressed = false;
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
  SyntheticChannelCountBox synthChannelCountBox;

  NetworkingBox networkingBoxLive;
  UDPOptionsBox udpOptionsBox;
  OSCOptionsBox oscOptionsBox;
  LSLOptionsBox lslOptionsBox;

  PlaybackFileBox playbackFileBox;
  SDConverterBox sdConverterBox;
  NetworkingBox networkingBoxPlayback;

  BLEBox bleBox;

  SDBox sdBox;

  boolean drawStopInstructions;

  int globalPadding; //design feature: passed through to all box classes as the global spacing .. in pixels .. for all elements/subelements
  int globalBorder;

  boolean convertingSD = false;

  ControlPanel(OpenBCI_GUI mainClass) {

    x = 3;
    y = 3 + topNav.controlPanelCollapser.but_dy;
    w = topNav.controlPanelCollapser.but_dx;
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
    cp5Popup = new ControlP5(mainClass);
    cp5.setAutoDraw(false);
    cp5Popup.setAutoDraw(false);

    //boxes active when eegDataSource = Normal (OpenBCI)
    dataSourceBox = new DataSourceBox(x, y, w, h, globalPadding);
    serialBox = new SerialBox(x + w, dataSourceBox.y, w, h, globalPadding);
    dataLogBox = new DataLogBox(x + w, (serialBox.y + serialBox.h), w, h, globalPadding);
    channelCountBox = new ChannelCountBox(x + w, (dataLogBox.y + dataLogBox.h), w, h, globalPadding);
    synthChannelCountBox = new SyntheticChannelCountBox(x + w, dataSourceBox.y, w, h, globalPadding);
    sdBox = new SDBox(x + w, (channelCountBox.y + channelCountBox.h), w, h, globalPadding);
    networkingBoxLive = new NetworkingBox(x + w, (sdBox.y + sdBox.h), w, 135, globalPadding);
    udpOptionsBox = new UDPOptionsBox(networkingBoxLive.x + networkingBoxLive.w, (sdBox.y + sdBox.h), w-30, networkingBoxLive.h, globalPadding);
    oscOptionsBox = new OSCOptionsBox(networkingBoxLive.x + networkingBoxLive.w, (sdBox.y + sdBox.h), w-30, networkingBoxLive.h, globalPadding);
    lslOptionsBox = new LSLOptionsBox(networkingBoxLive.x + networkingBoxLive.w, (sdBox.y + sdBox.h), w-30, networkingBoxLive.h, globalPadding);

    //boxes active when eegDataSource = Playback
    playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, w, h, globalPadding);
    sdConverterBox = new SDConverterBox(x + w, (playbackFileBox.y + playbackFileBox.h), w, h, globalPadding);
    //networkingBoxPlayback = new NetworkingBox(x + w, (sdConverterBox.y + sdConverterBox.h), w, h, globalPadding);

    rcBox = new RadioConfigBox(x+w, y, w, h, globalPadding);
    channelPopup = new ChannelPopup(x+w, y, w, h, globalPadding);
    pollPopup = new PollPopup(x+w,y,w,h,globalPadding);

    initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);

    // Ganglion
    bleBox = new BLEBox(x + w, dataSourceBox.y, w, h, globalPadding);
  }

  public void open(){
    isOpen = true;
    topNav.controlPanelCollapser.setIsActive(true);
  }

  public void close(){
    isOpen = false;
    topNav.controlPanelCollapser.setIsActive(false);
  }

  public void update() {
    //toggle view of cp5 / serial list selection table
    if (isOpen) { // if control panel is open
      if (!cp5.isVisible()) {  //and cp5 is not visible
        cp5.show(); // shot it
        cp5Popup.show();
      }
    } else { //the opposite of above
      if (cp5.isVisible()) {
        cp5.hide();
        cp5Popup.hide();
      }
    }

    //update all boxes if they need to be
    dataSourceBox.update();
    serialBox.update();
    bleBox.update();
    dataLogBox.update();
    channelCountBox.update();
    synthChannelCountBox.update();
    sdBox.update();
    rcBox.update();
    initBox.update();
    networkingBoxLive.update();
    //networkingBoxPlayback.update();

    channelPopup.update();
    serialList.updateMenu();
    bleList.updateMenu();


    //SD File Conversion
    while (convertingSD == true) {
      convertSDFile();
    }

    if (isGanglion) {
      if (!calledForBLEList) {
        calledForBLEList = true;
        if (ganglion.isHubRunning()) {
          ganglion.searchDeviceStart();
        }
      }
    }
  }

  public void draw() {

    pushStyle();

    noStroke();

    // //dark overlay of rest of interface to indicate it's not clickable
    // fill(0, 0, 0, 185);
    // rect(0, 0, width, height);

    // pushStyle();
    // noStroke();
    // // fill(255);
    // fill(31,69,110);
    // rect(0, 0, width, navBarHeight);
    // popStyle();
    // // image(logo_blue, width/2 - (128/2) - 2, 6, 128, 22);
    // image(logo_white, width/2 - (128/2) - 2, 6, 128, 22);

    // if(colorScheme == COLOR_SCHEME_DEFAULT){
    //   noStroke();
    //   fill(229);
    //   rect(0, 0, width, topNav_h);
    //   stroke(bgColor);
    //   fill(255);
    //   rect(-1, 0, width+2, navBarHeight);
    //   image(logo_blue, width/2 - (128/2) - 2, 6, 128, 22);
    // } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A){
    //   noStroke();
    //   fill(100);
    //   rect(0, 0, width, topNav_h);
    //   stroke(bgColor);
    //   fill(31,69,110);
    //   rect(-1, 0, width+2, navBarHeight);
    //   image(logo_white, width/2 - (128/2) - 2, 6, 128, 22);
    // }

    initBox.draw();

    if (systemMode == 10) {
      drawStopInstructions = true;
    }

    if (systemMode != 10) { // only draw control panel boxes if system running is false
      dataSourceBox.draw();
      drawStopInstructions = false;
      cp5.setVisible(true);//make sure controlP5 elements are visible

      cp5Popup.setVisible(true);
      if (eegDataSource == 0) {	//when data source is from OpenBCI
        serialBox.draw();
        dataLogBox.y = serialBox.y + serialBox.h;
        dataLogBox.draw();
        channelCountBox.draw();
        sdBox.draw();
        networkingBoxLive.draw();
        if(rcBox.isShowing){
          rcBox.draw();
          if(channelPopup.wasClicked()){
            channelPopup.draw();
            cp5Popup.get(MenuList.class, "channelList").setVisible(true);
            cp5Popup.get(MenuList.class, "pollList").setVisible(false);
            cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
            cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
            cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
          }
          else if(pollPopup.wasClicked()){
            pollPopup.draw();
            cp5Popup.get(MenuList.class, "pollList").setVisible(true);
            cp5Popup.get(MenuList.class, "channelList").setVisible(false);
            cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
            cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
            cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
          }

        }
        cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
        cp5.get(MenuList.class, "bleList").setVisible(false); //make sure the serialList menulist is visible
        cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
        cp5.get(MenuList.class, "networkList").setVisible(true); //make sure the SD time record options menulist is visible
        if (networkType == -1){
          cp5.get(Textfield.class, "udp_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "udp_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_address").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_data").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_aux").setVisible(false); //make sure the SD time record options menulist is visible
        } else if (networkType == 0){
          cp5.get(Textfield.class, "udp_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "udp_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_address").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_data").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_aux").setVisible(false); //make sure the SD time record options menulist is visible

        } else if (networkType == 1){
          cp5.get(Textfield.class, "udp_ip").setVisible(true); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "udp_port").setVisible(true); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_address").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_data").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_aux").setVisible(false); //make sure the SD time record options menulist is visible
          udpOptionsBox.draw();
        } else if (networkType == 2){
          cp5.get(Textfield.class, "udp_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "udp_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_ip").setVisible(true); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_port").setVisible(true); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_address").setVisible(true); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_data").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_aux").setVisible(false); //make sure the SD time record options menulist is visible

          oscOptionsBox.draw();
        } else if (networkType == 3){
          cp5.get(Textfield.class, "udp_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "udp_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_ip").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_port").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "osc_address").setVisible(false); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_data").setVisible(true); //make sure the SD time record options menulist is visible
          cp5.get(Textfield.class, "lsl_aux").setVisible(true); //make sure the SD time record options menulist is visible
          lslOptionsBox.draw();
        }

      } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) { //when data source is from playback file
        hideAllBoxes(); //clear lists, so they don't appear
        playbackFileBox.draw();
        sdConverterBox.draw();
        //networkingBoxPlayback.draw();

        //set other CP5 controllers invisible
        cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(false);
        cp5.get(MenuList.class, "sdTimes").setVisible(false);
        cp5.get(MenuList.class, "networkList").setVisible(false);
        cp5.get(Textfield.class, "udp_ip").setVisible(false); //make sure the SD time record options menulist is visible
        cp5.get(Textfield.class, "udp_port").setVisible(false); //make sure the SD time record options menulist is visible
        cp5.get(Textfield.class, "osc_ip").setVisible(false); //make sure the SD time record options menulist is visible
        cp5.get(Textfield.class, "osc_port").setVisible(false); //make sure the SD time record options menulist is visible
        cp5.get(Textfield.class, "osc_address").setVisible(false); //make sure the SD time record options menulist is visible
        cp5.get(Textfield.class, "lsl_data").setVisible(false); //make sure the SD time record options menulist is visible
        cp5.get(Textfield.class, "lsl_aux").setVisible(false); //make sure the SD time record options menulist is visible

        cp5Popup.get(MenuList.class, "channelList").setVisible(false);
        cp5Popup.get(MenuList.class, "pollList").setVisible(false);
      } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  //synthetic
        //set other CP5 controllers invisible
        hideAllBoxes();
        synthChannelCountBox.draw();
      } else if (eegDataSource == DATASOURCE_GANGLION) {
        hideAllBoxes();

        bleBox.draw();
        dataLogBox.y = bleBox.y + bleBox.h;
        dataLogBox.draw();
        cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
        cp5.get(MenuList.class, "bleList").setVisible(true); //make sure the bleList menulist is visible

      } else {
        //set other CP5 controllers invisible
        hideAllBoxes();
      }
    } else {
      cp5.setVisible(false); // if isRunning is true, hide all controlP5 elements
      cp5Popup.setVisible(false);
      // cp5Serial.setVisible(false);    //%%%
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

    //draw the ControlP5 stuff
    cp5Popup.draw();
    cp5.draw();

    popStyle();

  }

  public void hideAllBoxes() {
    //set other CP5 controllers invisible
    cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
    cp5.get(MenuList.class, "serialList").setVisible(false);
    cp5.get(MenuList.class, "bleList").setVisible(false);
    cp5.get(MenuList.class, "sdTimes").setVisible(false);
    cp5.get(MenuList.class, "networkList").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "udp_ip").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "udp_port").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "osc_ip").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "osc_port").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "osc_address").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "lsl_data").setVisible(false); //make sure the SD time record options menulist is visible
    cp5.get(Textfield.class, "lsl_aux").setVisible(false); //make sure the SD time record options menulist is visible
    cp5Popup.get(MenuList.class, "channelList").setVisible(false);
    cp5Popup.get(MenuList.class, "pollList").setVisible(false);
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

      //active buttons during DATASOURCE_NORMAL_W_AUX
      if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
        if(autoconnect.isMouseHere()){
          autoconnect.setIsActive(true);
          autoconnect.wasPressed = true;
        }

        if (popOut.isMouseHere()){
          popOut.setIsActive(true);
          popOut.wasPressed = true;
        }

        if (refreshPort.isMouseHere()) {
          refreshPort.setIsActive(true);
          refreshPort.wasPressed = true;
        }

        if (autoFileName.isMouseHere()) {
          autoFileName.setIsActive(true);
          autoFileName.wasPressed = true;
        }

        if (outputODF.isMouseHere()) {
          outputODF.setIsActive(true);
          outputODF.wasPressed = true;
          outputODF.color_notPressed = isSelected_color;
          outputBDF.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (outputBDF.isMouseHere()) {
          outputBDF.setIsActive(true);
          outputBDF.wasPressed = true;
          outputBDF.color_notPressed = isSelected_color;
          outputODF.color_notPressed = autoFileName.color_notPressed; //default color of button
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

        if (setChannel.isMouseHere()){
          setChannel.setIsActive(true);
          setChannel.wasPressed = true;
        }

        if (ovrChannel.isMouseHere()){
          ovrChannel.setIsActive(true);
          ovrChannel.wasPressed = true;
        }

        if (getPoll.isMouseHere()){
          getPoll.setIsActive(true);
          getPoll.wasPressed = true;
        }

        if (setPoll.isMouseHere()){
          setPoll.setIsActive(true);
          setPoll.wasPressed = true;
        }

        if (defaultBAUD.isMouseHere()){
          defaultBAUD.setIsActive(true);
          defaultBAUD.wasPressed = true;
        }

        if (highBAUD.isMouseHere()){
          highBAUD.setIsActive(true);
          highBAUD.wasPressed = true;
        }

        if (autoscan.isMouseHere()){
          autoscan.setIsActive(true);
          autoscan.wasPressed = true;
        }

        if (autoconnectNoStartDefault.isMouseHere()){
          autoconnectNoStartDefault.setIsActive(true);
          autoconnectNoStartDefault.wasPressed = true;
        }

        if (autoconnectNoStartHigh.isMouseHere()){
          autoconnectNoStartHigh.setIsActive(true);
          autoconnectNoStartHigh.wasPressed = true;
        }


        if (systemStatus.isMouseHere()){
          systemStatus.setIsActive(true);
          systemStatus.wasPressed = true;
        }

      }

      if (eegDataSource == DATASOURCE_GANGLION) {
        // This is where we check for button presses if we are searching for BLE devices

        if (refreshBLE.isMouseHere()) {
          refreshBLE.setIsActive(true);
          refreshBLE.wasPressed = true;
        }

        if (outputODF.isMouseHere()) {
          outputODF.setIsActive(true);
          outputODF.wasPressed = true;
          outputODF.color_notPressed = isSelected_color;
          outputBDF.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (outputBDF.isMouseHere()) {
          outputBDF.setIsActive(true);
          outputBDF.wasPressed = true;
          outputBDF.color_notPressed = isSelected_color;
          outputODF.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

      }

      //active buttons during DATASOURCE_PLAYBACKFILE
      if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
        if (selectPlaybackFile.isMouseHere()) {
          selectPlaybackFile.setIsActive(true);
          selectPlaybackFile.wasPressed = true;
        }

        if (selectSDFile.isMouseHere()) {
          selectSDFile.setIsActive(true);
          selectSDFile.wasPressed = true;
        }
      }

      //active buttons during DATASOURCE_PLAYBACKFILE
      if (eegDataSource == DATASOURCE_SYNTHETIC) {
        if (synthChanButton4.isMouseHere()) {
          synthChanButton4.setIsActive(true);
          synthChanButton4.wasPressed = true;
          synthChanButton4.color_notPressed = isSelected_color;
          synthChanButton8.color_notPressed = autoFileName.color_notPressed; //default color of button
          synthChanButton16.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (synthChanButton8.isMouseHere()) {
          synthChanButton8.setIsActive(true);
          synthChanButton8.wasPressed = true;
          synthChanButton8.color_notPressed = isSelected_color;
          synthChanButton4.color_notPressed = autoFileName.color_notPressed; //default color of button
          synthChanButton16.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (synthChanButton16.isMouseHere()) {
          synthChanButton16.setIsActive(true);
          synthChanButton16.wasPressed = true;
          synthChanButton16.color_notPressed = isSelected_color;
          synthChanButton4.color_notPressed = autoFileName.color_notPressed; //default color of button
          synthChanButton8.color_notPressed = autoFileName.color_notPressed; //default color of button
        }
      }

    }
    // output("Text File Name: " + cp5.get(Textfield.class,"fileName").getText());
  }

  //mouse released in control panel
  public void CPmouseReleased() {
    //verbosePrint("CPMouseReleased: CPmouseReleased start...");
    if(popOut.isMouseHere() && popOut.wasPressed){
      popOut.wasPressed = false;
      popOut.setIsActive(false);
      if(rcBox.isShowing){
        rcBox.isShowing = false;
        cp5Popup.hide(); // make sure to hide the controlP5 object
        cp5Popup.get(MenuList.class, "channelList").setVisible(false);
        cp5Popup.get(MenuList.class, "pollList").setVisible(false);
        // cp5Popup.hide(); // make sure to hide the controlP5 object
        popOut.setString(">");
      }
      else{
        rcBox.isShowing = true;
        popOut.setString("<");
      }
    }

    if(getChannel.isMouseHere() && getChannel.wasPressed){
      if(board != null) get_channel( rcBox);

      getChannel.wasPressed=false;
      getChannel.setIsActive(false);
    }

    if (setChannel.isMouseHere() && setChannel.wasPressed){
      channelPopup.setClicked(true);
      pollPopup.setClicked(false);
      setChannel.setIsActive(false);
    }

    if (ovrChannel.isMouseHere() && ovrChannel.wasPressed){
      channelPopup.setClicked(true);
      pollPopup.setClicked(false);
      ovrChannel.setIsActive(false);
    }


    if (getPoll.isMouseHere() && getPoll.wasPressed){
      get_poll(rcBox);
      getPoll.setIsActive(false);
      getPoll.wasPressed = false;
    }

    if (setPoll.isMouseHere() && setPoll.wasPressed){
      pollPopup.setClicked(true);
      channelPopup.setClicked(false);
      setPoll.setIsActive(false);
    }

    if (defaultBAUD.isMouseHere() && defaultBAUD.wasPressed){
      set_baud_default(rcBox,openBCI_portName);
      defaultBAUD.setIsActive(false);
      defaultBAUD.wasPressed=false;
    }

    if (highBAUD.isMouseHere() && highBAUD.wasPressed){
      set_baud_high(rcBox,openBCI_portName);
      highBAUD.setIsActive(false);
      highBAUD.wasPressed=false;
    }

    if(autoconnectNoStartDefault.isMouseHere() && autoconnectNoStartDefault.wasPressed){

      if(board == null){
        try{
          board = autoconnect_return_default();
          rcBox.print_onscreen("Successfully connected to board");
        }
        catch (Exception e){
          rcBox.print_onscreen("Error connecting to board...");
        }


      }
     else rcBox.print_onscreen("Board already connected!");
      autoconnectNoStartDefault.setIsActive(false);
      autoconnectNoStartDefault.wasPressed = false;
    }

    if(autoconnectNoStartHigh.isMouseHere() && autoconnectNoStartHigh.wasPressed){

      if(board == null){

        try{

          board = autoconnect_return_high();
          rcBox.print_onscreen("Successfully connected to board");
        }
        catch (Exception e2){
          rcBox.print_onscreen("Error connecting to board...");
        }

      }
     else rcBox.print_onscreen("Board already connected!");
      autoconnectNoStartHigh.setIsActive(false);
      autoconnectNoStartHigh.wasPressed = false;
    }

    if(autoscan.isMouseHere() && autoscan.wasPressed){
      autoscan.wasPressed = false;
      autoscan.setIsActive(false);
      scan_channels(rcBox);

    }

    if(autoconnect.isMouseHere() && autoconnect.wasPressed && eegDataSource != DATASOURCE_PLAYBACKFILE){
      autoconnect();
      initButtonPressed();
      autoconnect.wasPressed = false;
      autoconnect.setIsActive(false);
    }

    if(systemStatus.isMouseHere() && systemStatus.wasPressed){
      system_status(rcBox);
      systemStatus.setIsActive(false);
      systemStatus.wasPressed = false;
    }


    if (initSystemButton.isMouseHere() && initSystemButton.wasPressed) {
      if(board != null) board.stop();
      //if system is not active ... initate system and flip button state
      initButtonPressed();
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
    if (refreshBLE.isMouseHere() && refreshBLE.wasPressed) {
      output("BLE Devices Refreshing");
      ganglion.searchDeviceStart();
    }

    //open or close serial port if serial port button is pressed (left button in serial widget)
    if (autoFileName.isMouseHere() && autoFileName.wasPressed) {
      output("Autogenerated \"File Name\" based on current date/time");
      cp5.get(Textfield.class, "fileName").setText(getDateString());
    }

    if (outputODF.isMouseHere() && outputODF.wasPressed) {
      output("Output has been set to OpenBCI Data Format");
      outputDataSource = OUTPUT_SOURCE_ODF;
    }

    if (outputBDF.isMouseHere() && outputBDF.wasPressed) {
      output("Output has been set to BDF+ (biosemi data format based off EDF)");
      outputDataSource = OUTPUT_SOURCE_BDF;
    }

    if (chanButton8.isMouseHere() && chanButton8.wasPressed) {
      updateToNChan(8);
    }

    if (chanButton16.isMouseHere() && chanButton16.wasPressed ) {
      updateToNChan(16);
    }

    if (synthChanButton4.isMouseHere() && synthChanButton4.wasPressed) {
      updateToNChan(4);
    }

    if (synthChanButton8.isMouseHere() && synthChanButton8.wasPressed) {
      updateToNChan(8);
    }

    if (synthChanButton16.isMouseHere() && synthChanButton16.wasPressed) {
      updateToNChan(16);
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
    refreshBLE.setIsActive(false);
    refreshBLE.wasPressed = false;
    initSystemButton.setIsActive(false);
    initSystemButton.wasPressed = false;
    autoFileName.setIsActive(false);
    autoFileName.wasPressed = false;
    outputBDF.setIsActive(false);
    outputBDF.wasPressed = false;
    outputODF.setIsActive(false);
    outputODF.wasPressed = false;
    chanButton8.setIsActive(false);
    chanButton8.wasPressed = false;
    synthChanButton4.setIsActive(false);
    synthChanButton4.wasPressed = false;
    synthChanButton8.setIsActive(false);
    synthChanButton8.wasPressed = false;
    synthChanButton16.setIsActive(false);
    synthChanButton16.wasPressed = false;
    chanButton16.setIsActive(false);
    chanButton16.wasPressed  = false;
    selectPlaybackFile.setIsActive(false);
    selectPlaybackFile.wasPressed = false;
    selectSDFile.setIsActive(false);
    selectSDFile.wasPressed = false;
  }
};

public void initButtonPressed(){
  if (initSystemButton.but_txt == "START SYSTEM") {

      if (eegDataSource == DATASOURCE_NORMAL_W_AUX && openBCI_portName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
        output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
        output("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_GANGLION && ganglion_portName == "N/A") {
        output("No BLE device selected. Please select your Ganglion device and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      // } else if (eegDataSource == DATASOURCE_SYNTHETIC){
      //   nchan = 16;
      //   output("Starting system with 16 channels of synthetically generated data...");
      //   initSystemButton.wasPressed = false;
      //   initSystemButton.setIsActive(false);
      //   return;
      } else if (eegDataSource == -1) {//if no data source selected
        output("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else { //otherwise, initiate system!
        //verbosePrint("ControlPanel: CPmouseReleased: init");
        initSystemButton.setString("STOP SYSTEM");
        //global steps to START SYSTEM
        // prepare the serial port
        if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
          verbosePrint("ControlPanel — port is open: " + openBCI.isSerialPortOpen());
          if (openBCI.isSerialPortOpen() == true) {
            openBCI.closeSerialPort();
          }
        } else if(eegDataSource == DATASOURCE_GANGLION){
          verbosePrint("ControlPanel — port is open: " + ganglion.isPortOpen());
          if (ganglion.isPortOpen()) {
            ganglion.disconnectBLE();
          }
        }

        //Network Protocol Initiation -- based on Gabe's Code
        if (networkType == 1){
          ip = cp5.get(Textfield.class, "udp_ip").getText();
          port = int(cp5.get(Textfield.class, "udp_port").getText());
          println(port);
          udp = new UDPSend(port, ip);
        } else if (networkType == 2){
          ip = cp5.get(Textfield.class, "osc_ip").getText();
          port = int(cp5.get(Textfield.class, "osc_port").getText());
          address = cp5.get(Textfield.class, "osc_address").getText();
          osc = new OSCSend(port, ip, address);
        } else if (networkType == 3){
          data_stream = cp5.get(Textfield.class, "lsl_data").getText();
          aux_stream = cp5.get(Textfield.class, "lsl_aux").getText();
          lsl = new LSLSend(data_stream, aux_stream);
        }

        fileName = cp5.get(Textfield.class, "fileName").getText(); // store the current text field value of "File Name" to be passed along to dataFiles
        midInit = true;
        initSystem(); //calls the initSystem() funciton of the OpenBCI_GUI.pde file
      }
    }

    //if system is already active ... stop system and flip button state back
    else {
      output("SYSTEM STOPPED");
      initSystemButton.setString("START SYSTEM");
      haltSystem();
    }
}

void updateToNChan(int _nchan) {
  nchan = _nchan;
  fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
  yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
  output("channel count set to " + str(nchan));
  updateChannelArrays(nchan); //make sure to reinitialize the channel arrays with the right number of channels
}

public void set_channel_popup(){;
}


//==============================================================================//
//					BELOW ARE THE CLASSES FOR THE VARIOUS 						//
//					CONTROL PANEL BOXes (control widgets)						//
//==============================================================================//

class DataSourceBox {
  int x, y, w, h, padding; //size and position
  int numItems = 4;
  int boxHeight = 24;
  int spacing = 43;


  CheckBox sourceCheckBox;

  DataSourceBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = spacing + (numItems * boxHeight);
    padding = _padding;

    sourceList = new MenuList(cp5, "sourceList", w - padding*2, numItems * boxHeight, p4);
    // sourceList.itemHeight = 28;
    // sourceList.padding = 9;
    sourceList.setPosition(x + padding, y + padding*2 + 13);
    sourceList.addItem(makeItem("LIVE (from Cyton)"));
    sourceList.addItem(makeItem("LIVE (from Ganglion)"));
    sourceList.addItem(makeItem("PLAYBACK (from file)"));
    sourceList.addItem(makeItem("SYNTHETIC (algorithmic)"));

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
    textFont(h3, 16);
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
    popOut = new Button(x+padding + (w-padding*4), y +5, 20,20,">",fontInfo.buttonLabel_size);

    serialList = new MenuList(cp5, "serialList", w - padding*2, 72, p4);
    // println(w-padding*2);
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("SERIAL/COM PORT", x + padding, y + padding);
    popStyle();

    // openClosePort.draw();
    refreshPort.draw();
    autoconnect.draw();
    popOut.draw();
  }

  public void refreshSerialList() {
  }
};

class BLEBox {
  int x, y, w, h, padding; //size and position
  //connect/disconnect button
  //Refresh list button
  //String port status;

  BLEBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 171 - 24 + _padding;
    padding = _padding;

    refreshBLE = new Button (x + padding, y + padding * 4 + 13 + 71, w - padding * 2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);
    bleList = new MenuList(cp5, "bleList", w - padding * 2, 84, p4);
    // println(w-padding*2);
    bleList.setPosition(x + padding, y + padding * 3);
    // Call to update the list
    // ganglion.getBLEDevices();
  }

  public void update() {
    // Quick check to see if there are just more or less devices in general

  }

  public void draw() {
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("BLE DEVICES", x + padding, y + padding);
    popStyle();

    refreshBLE.draw();
  }

  public void refreshBLEList() {
    bleList.items.clear();
    for (int i = 0; i < ganglion.deviceList.length; i++) {
      String tempPort = ganglion.deviceList[i];
      bleList.addItem(makeItem(tempPort));
    }
    bleList.updateMenu();
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
    h = 127; // Added 24 +
    padding = _padding;
    //instantiate button
    //figure out default file name (from Chip's code)
    isFileOpen = false; //set to true on button push
    fileStatus = "NO FILE CREATED";

    //button to autogenerate file name based on time/date
    autoFileName = new Button (x + padding, y + 66, w-(padding*2), 24, "AUTOGENERATE FILE NAME", fontInfo.buttonLabel_size);
    outputODF = new Button (x + padding, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "OpenBCI", fontInfo.buttonLabel_size);
    if (outputDataSource == OUTPUT_SOURCE_ODF) outputODF.color_notPressed = isSelected_color; //make it appear like this one is already selected
    outputBDF = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "BDF+", fontInfo.buttonLabel_size);
    if (outputDataSource == OUTPUT_SOURCE_BDF) outputBDF.color_notPressed = isSelected_color; //make it appear like this one is already selected


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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("DATA LOG FILE", x + padding, y + padding);
    textFont(p4, 14);;
    text("File Name", x + padding, y + padding*2 + 18);
    popStyle();
    cp5.get(Textfield.class, "fileName").setPosition(x + 90, y + 32);
    autoFileName.but_y = y + 66;
    autoFileName.draw();
    outputODF.but_y = y + padding*2 + 18 + 58;
    outputODF.draw();
    outputBDF.but_y = y + padding*2 + 18 + 58;
    outputBDF.draw();
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("CHANNEL COUNT", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("(" + str(nchan) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    chanButton8.draw();
    chanButton16.draw();
  }
};

class SyntheticChannelCountBox {
  int x, y, w, h, padding; //size and position

  boolean isSystemInitialized;
  // button for init/halt system

  SyntheticChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    synthChanButton4 = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "4 chan", fontInfo.buttonLabel_size);
    if (nchan == 4) synthChanButton4.color_notPressed = isSelected_color; //make it appear like this one is already selected
    synthChanButton8 = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "8 chan", fontInfo.buttonLabel_size);
    if (nchan == 8) synthChanButton8.color_notPressed = isSelected_color; //make it appear like this one is already selected
    synthChanButton16 = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "16 chan", fontInfo.buttonLabel_size);
    if (nchan == 16) synthChanButton16.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("CHANNEL COUNT", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("(" + str(nchan) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    synthChanButton4.draw();
    synthChanButton8.draw();
    synthChanButton16.draw();
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
    textFont(h3, 16);
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

    sdTimes = new MenuList(cp5, "sdTimes", w - padding*2, 108, p4);
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("WRITE TO SD (Y/N)?", x + padding, y + padding);
    popStyle();

    //the drawing of the sdTimes is handled earlier in ControlPanel.draw()

  }
};

class NetworkingBox{
  int x, y, w, h, padding; //size and position
   MenuList networkList;

  //boolean initButtonPressed; //default false

  //boolean isSystemInitialized;
  NetworkingBox(int _x, int _y, int _w, int _h, int _padding){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    padding = _padding;
    networkList = new MenuList(cp5, "networkList", w - padding*2, 96, p4);
    networkList.setPosition(x + padding, y+padding+20);
    networkList.addItem(makeItem("None"));
    networkList.addItem(makeItem("UDP"));
    networkList.addItem(makeItem("OSC"));
    networkList.addItem(makeItem("LabStreamingLayer (LSL)"));
    networkList.scrollerLength = 0;
    networkList.activeItem = 0;
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("NETWORK PROTOCOLS", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    popStyle();
  }
};


class RadioConfigBox {
  int x, y, w, h, padding; //size and position
  String last_message = "";
  Serial board;
  boolean isShowing;

  RadioConfigBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x + _w;
    y = _y;
    w = _w;
    h = 355;
    padding = _padding;
    isShowing = false;

    getChannel = new Button(x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "GET CHANNEL", fontInfo.buttonLabel_size);
    setChannel = new Button(x + padding + (w-padding*2)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "SET CHANNEL", fontInfo.buttonLabel_size);
    ovrChannel = new Button(x + padding, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "OVERRIDE CHAN", fontInfo.buttonLabel_size);
    getPoll = new Button(x + padding + (w-padding*2)/2, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "GET POLL", fontInfo.buttonLabel_size);
    setPoll = new Button(x + padding, y + padding*4 + 18 + 24*2, (w-padding*3)/2, 24, "SET POLL", fontInfo.buttonLabel_size);
    defaultBAUD = new Button(x + padding + (w-padding*2)/2, y + padding*4 + 18 + 24*2, (w-padding*3)/2, 24, "DEFAULT BAUD", fontInfo.buttonLabel_size);
    highBAUD = new Button(x + padding, y + padding*5 + 18 + 24*3, (w-padding*3)/2, 24, "HIGH BAUD", fontInfo.buttonLabel_size);
    autoscan = new Button(x + padding + (w-padding*2)/2, y + padding*5 + 18 + 24*3, (w-padding*3)/2, 24, "AUTOSCAN CHANS", fontInfo.buttonLabel_size);
    autoconnectNoStartDefault = new Button(x + padding, y + padding*6 + 18 + 24*4, (w-padding*3 )/2 , 24, "CONNECT 115200", fontInfo.buttonLabel_size);
    systemStatus = new Button(x + padding + (w-padding*2)/2, y + padding*6 + 18 + 24*4, (w-padding*3 )/2, 24, "STATUS", fontInfo.buttonLabel_size);
    autoconnectNoStartHigh = new Button(x + padding, y + padding*7 + 18 + 24*5, (w-padding*3 )/2, 24, "CONNECT 230400", fontInfo.buttonLabel_size);

    //Set help text
    getChannel.setHelpText("Gets the current channel that your OpenBCI board and radio is on.");
    setChannel.setHelpText("Sets the current channel that your OpenBCI board and radio are on.");
    ovrChannel.setHelpText("Overrides the current channel of the OpenBCI radio, and sets it to that channel.");
    getPoll.setHelpText("Gets the current POLL value.");
    setPoll.setHelpText("Sets the current POLL value.");
    defaultBAUD.setHelpText("Sets the BAUD rate to 115200.");
    highBAUD.setHelpText("Sets the BAUD rate to 230400.");
    autoscan.setHelpText("Scans through channels and finds a nearby OpenBCI board, then connects to that board.");
    systemStatus.setHelpText("Gets the connection status of your OpenBCI board.");
    autoconnectNoStartDefault.setHelpText("Automatically connects to a board with the DEFAULT (115200) BAUD");
    autoconnectNoStartHigh.setHelpText("Automatically connects to a board with the HIGH (230400) BAUD");

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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("RADIO CONFIGURATION (V2)", x + padding, y + padding);
    popStyle();
    getChannel.draw();
    setChannel.draw();
    ovrChannel.draw();
    getPoll.draw();
    setPoll.draw();
    defaultBAUD.draw();
    highBAUD.draw();
    autoscan.draw();
    autoconnectNoStartDefault.draw();
    autoconnectNoStartHigh.draw();
    systemStatus.draw();
    this.print_onscreen(last_message);

    //the drawing of the sdTimes is handled earlier in ControlPanel.draw()

  }

  public void print_onscreen(String localstring){
    textAlign(LEFT);
    fill(0);
    rect(x + padding, y + (padding*8) + 18 + (24*6), (w-padding*3 + 5), 135 - 24 - padding);
    fill(255);
    text(localstring, x + padding + 10, y + (padding*8) + 18 + (24*6) + 15, (w-padding*3 ), 135 - 24 - padding -15);
    this.last_message = localstring;
  }

  public void print_lastmessage(){

    fill(0);
    rect(x + padding, y + (padding*7) + 18 + (24*5), (w-padding*3 + 5), 135);
    fill(255);
    text(this.last_message, 180, 340, 240, 60);
  }
};



class UDPOptionsBox {
  int x, y, w, h, padding; //size and position

  UDPOptionsBox(int _x, int _y, int _w, int _h, int _padding){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    padding = _padding;

    cp5.addTextfield("udp_ip")
      .setPosition(x + 60,y + 50)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("localhost")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;

   cp5.addTextfield("udp_port")
      .setPosition(x + 60,y + 82)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("12345")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("Options", x + padding, y + padding);
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    text("UDP OPTIONS", x + padding, y + padding);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("IP", x + padding, y + 50 + padding);
    textFont(p4, 14);;
    text("Port", x + padding, y + 82 + padding);
    popStyle();
  }
};

class OSCOptionsBox{
  int x, y, w, h, padding; //size and position

  OSCOptionsBox(int _x, int _y, int _w, int _h, int _padding){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    padding = _padding;

    cp5.addTextfield("osc_ip")
      .setPosition(x + 80,y + 35)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("localhost")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;
   cp5.addTextfield("osc_port")
      .setPosition(x + 80,y + 67)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("12345")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;
    cp5.addTextfield("osc_address")
      .setPosition(x + 80,y + 99)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("/openbci")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("Options", x + padding, y + padding);
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    text("OSC OPTIONS", x + padding, y + padding);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("IP", x + padding, y + 35 + padding);
    textFont(p4, 14);;
    text("Port", x + padding, y + 67 + padding);
    text("Address", x + padding, y + 99 + padding);
    popStyle();
  }
};

class LSLOptionsBox {
  int x, y, w, h, padding; //size and position

  LSLOptionsBox(int _x, int _y, int _w, int _h, int _padding){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    padding = _padding;

    cp5.addTextfield("lsl_data")
      .setPosition(x + 115,y + 50)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("openbci_data")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;

   cp5.addTextfield("lsl_aux")
      .setPosition(x + 115,y + 82)
      .setCaptionLabel("")
      .setSize(100,26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26,26,26))
      .setText("openbci_aux")
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setVisible(false)
      .setAutoClear(true)
      ;
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("Options", x + padding, y + padding);
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    text("LSL OPTIONS", x + padding, y + padding);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("Data Stream", x + padding, y + 50 + padding);
    textFont(p4, 14);;
    text("Aux Stream", x + padding, y + 82 + padding);
    popStyle();
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("CONVERT SD FOR PLAYBACK", x + padding, y + padding);
    popStyle();

    selectSDFile.draw();
  }
};


class ChannelPopup {
  int x, y, w, h, padding; //size and position
  //connect/disconnect button
  //Refresh list button
  //String port status;
  boolean clicked;

  ChannelPopup(int _x, int _y, int _w, int _h, int _padding) {
    x = _x + _w * 2;
    y = _y;
    w = _w;
    h = 171 + _padding;
    padding = _padding;
    clicked = false;

    channelList = new MenuList(cp5Popup, "channelList", w - padding*2, 140, p4);
    channelList.setPosition(x+padding, y+padding*3);

    for (int i = 1; i < 26; i++) {
      channelList.addItem(makeItem(String.valueOf(i)));
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("CHANNEL SELECTION", x + padding, y + padding);
    popStyle();

    // openClosePort.draw();
    refreshPort.draw();
    autoconnect.draw();
  }

  public void setClicked(boolean click){this.clicked = click; }

  public boolean wasClicked(){return this.clicked;}

};

class PollPopup {
  int x, y, w, h, padding; //size and position
  //connect/disconnect button
  //Refresh list button
  //String port status;
  boolean clicked;

  PollPopup(int _x, int _y, int _w, int _h, int _padding) {
    x = _x + _w * 2;
    y = _y;
    w = _w;
    h = 171 + _padding;
    padding = _padding;
    clicked = false;


    pollList = new MenuList(cp5Popup, "pollList", w - padding*2, 140, p4);
    pollList.setPosition(x+padding, y+padding*3);

    for (int i = 0; i < 256; i++) {
      pollList.addItem(makeItem(String.valueOf(i)));
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
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("POLL SELECTION", x + padding, y + padding);
    popStyle();

    // openClosePort.draw();
    refreshPort.draw();
    autoconnect.draw();
  }

  public void setClicked(boolean click){this.clicked = click; }

  public boolean wasClicked(){return this.clicked;}

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

public class MenuList extends controlP5.Controller {

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
  PFont menuFont = p4;
  int padding = 7;


  MenuList(ControlP5 c, String theName, int theWidth, int theHeight, PFont theFont) {

    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(),getHeight());

    menuFont = p4;

    setView(new ControllerView<MenuList>() {

      public void display(PGraphics pg, MenuList t) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside()) {
          // if(!drawHand){
          //   cursor(HAND);
          //   drawHand = true;
          // }
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
          // if(drawHand){
          //   drawHand = false;
          //   cursor(ARROW);
          // }
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
    // menu.textFont(cp5.getFont().getFont());
    menu.textFont(menuFont);
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

      //make sure there is something in the Ganglion serial list...
      try {
        menu.text(m.get("headline").toString(), 8, itemHeight - padding); // 5/17
        menu.translate( 0, itemHeight );
      } catch(Exception e){
        println("Nothing in list...");
      }


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
    println("click");
    try{
      if (getPointer().x()>getWidth()-scrollerWidth) {
        if(getHeight() != 0){
          npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
        }
        updateMenu = true;
      } else {
        int len = itemHeight * items.size();
        int index = 0;
        if(len != 0){
          index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
        }
        setValue(index);
        activeItem = index;
      }
      updateMenu = true;
    } finally{}
    // catch(IOException e){
    //   println("Nothing to click...");
    // }
  }

  public void onMove() {
    if (getPointer().x()>getWidth() || getPointer().x()<0 || getPointer().y()<0  || getPointer().y()>getHeight() ) {
      hoverItem = -1;
    } else {
      int len = itemHeight * items.size();
      int index = 0;
      if(len != 0){
        index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      }
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
