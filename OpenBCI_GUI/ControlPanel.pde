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
      println("CallbackListener: controlEvent: clearing cyton");
      cp5.get(Textfield.class, "fileName").clear();
      // cp5.get(Textfield.class, "fileNameGanglion").clear();

    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "fileNameGanglion"))){
      println("CallbackListener: controlEvent: clearing ganglion");
      cp5.get(Textfield.class, "fileNameGanglion").clear();

    } else if (cp5.isMouseOver(cp5.get(Textfield.class, "staticIPAddress"))){
      println("CallbackListener: controlEvent: clearing static IP Address");
      cp5.get(Textfield.class, "staticIPAddress").clear();
    }
  }
};

MenuList sourceList;

//Global buttons and elements for the control panel (changed within the classes below)
MenuList serialList;
String[] serialPorts = new String[Serial.list().length];

MenuList bleList;
MenuList wifiList;

MenuList sdTimes;

MenuList channelList;

MenuList pollList;

color boxColor = color(200);
color boxStrokeColor = color(bgColor);
color isSelected_color = color(184, 220, 105);

// Button openClosePort;
// boolean portButtonPressed;

boolean calledForBLEList = false;
boolean calledForWifiList = false;

Button refreshPort;
Button refreshBLE;
Button refreshWifi;
Button protocolSerialCyton;
Button protocolWifiCyton;
Button protocolWifiGanglion;
Button protocolBLED112Ganglion;
Button protocolBLEGanglion;
// Button autoconnect;
Button initSystemButton;
Button autoFileName;
Button outputBDF;
Button outputODF;

Button autoFileNameGanglion;
Button outputODFGanglion;
Button outputBDFGanglion;

Button chanButton8;
Button chanButton16;
Button selectPlaybackFile;
Button selectSDFile;
Button popOutRadioConfigButton;
Button popOutWifiConfigButton;

//Radio Button Definitions
Button getChannel;
Button setChannel;
Button ovrChannel;
// Button getPoll;
// Button setPoll;
// Button defaultBAUD;
// Button highBAUD;
Button autoscan;
// Button autoconnectNoStartDefault;
// Button autoconnectNoStartHigh;
Button systemStatus;

Button eraseCredentials;
Button getIpAddress;
Button getFirmwareVersion;
Button getMacAddress;
Button getTypeOfAttachedBoard;
Button sampleRate200;
Button sampleRate250;
Button sampleRate500;
Button sampleRate1000;
Button sampleRate1600;
Button latencyCyton5ms;
Button latencyCyton10ms;
Button latencyCyton20ms;
Button latencyGanglion5ms;
Button latencyGanglion10ms;
Button latencyGanglion20ms;
Button wifiInternetProtocolCytonTCP;
Button wifiInternetProtocolCytonUDP;
Button wifiInternetProtocolCytonUDPBurst;
Button wifiInternetProtocolGanglionTCP;
Button wifiInternetProtocolGanglionUDP;
Button wifiInternetProtocolGanglionUDPBurst;
Button wifiIPAddressDyanmic;
Button wifiIPAddressStatic;

Button synthChanButton4;
Button synthChanButton8;
Button synthChanButton16;

Serial board;

ChannelPopup channelPopup;
PollPopup pollPopup;
RadioConfigBox rcBox;

WifiConfigBox wcBox;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

public void controlEvent(ControlEvent theEvent) {

  if (theEvent.isFrom("sourceList")) {
    // THIS IS TRIGGERED WHEN A USER SELECTS 'LIVE (from Cyton) or LIVE (from Ganglion), etc...'
    controlPanel.hideAllBoxes();

    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    String str = (String)bob.get("headline");
    controlEventDataSource = str; //Used for output message on system start
    int newDataSource = int(theEvent.getValue());

    if (newDataSource != DATASOURCE_SYNTHETIC && newDataSource != DATASOURCE_PLAYBACKFILE && !hub.nodeProcessHandshakeComplete) {
      if (isWindows()) {
        output("Please launch OpenBCI Hub prior to launching this application. Learn at docs.openbci.com", OUTPUT_LEVEL_ERROR);
      } else {
        output("Unable to establish link to Hub. Checkout tutorial at docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI", OUTPUT_LEVEL_ERROR);
      }
      eegDataSource = -1;
      return;
    }

    protocolBLEGanglion.color_notPressed = autoFileName.color_notPressed;
    protocolWifiGanglion.color_notPressed = autoFileName.color_notPressed;
    protocolBLED112Ganglion.color_notPressed = autoFileName.color_notPressed;
    protocolWifiCyton.color_notPressed = autoFileName.color_notPressed;
    protocolSerialCyton.color_notPressed = autoFileName.color_notPressed;

    eegDataSource = newDataSource; // reset global eegDataSource to the selected value from the list


    ganglion.setInterface(INTERFACE_NONE);
    cyton.setInterface(INTERFACE_NONE);

    if(newDataSource == DATASOURCE_CYTON){
      updateToNChan(8);
      chanButton8.color_notPressed = isSelected_color;
      chanButton16.color_notPressed = autoFileName.color_notPressed; //default color of button
      latencyCyton5ms.color_notPressed = autoFileName.color_notPressed;
      latencyCyton10ms.color_notPressed = isSelected_color;
      latencyCyton20ms.color_notPressed = autoFileName.color_notPressed;
      hub.setLatency(LATENCY_10_MS);
      wifiInternetProtocolCytonTCP.color_notPressed = isSelected_color;
      wifiInternetProtocolCytonUDP.color_notPressed = autoFileName.color_notPressed;
      wifiInternetProtocolCytonUDPBurst.color_notPressed = autoFileName.color_notPressed;
      hub.setWifiInternetProtocol(TCP);
      hub.setWiFiStyle(WIFI_DYNAMIC);
      wifiIPAddressDyanmic.color_notPressed = isSelected_color;
      wifiIPAddressStatic.color_notPressed = autoFileName.color_notPressed;
    } else if(newDataSource == DATASOURCE_GANGLION){
      updateToNChan(4);
      if (isWindows() && isHubInitialized == false) {
        hubInit();
        timeOfSetup = millis();
      }
      latencyGanglion5ms.color_notPressed = autoFileName.color_notPressed;
      latencyGanglion10ms.color_notPressed = isSelected_color;
      latencyGanglion20ms.color_notPressed = autoFileName.color_notPressed;
      hub.setLatency(LATENCY_10_MS);
      wifiInternetProtocolGanglionTCP.color_notPressed = isSelected_color;
      wifiInternetProtocolGanglionUDP.color_notPressed = autoFileName.color_notPressed;
      wifiInternetProtocolGanglionUDPBurst.color_notPressed = autoFileName.color_notPressed;
      hub.setWifiInternetProtocol(TCP);
      hub.setWiFiStyle(WIFI_DYNAMIC);
      wifiIPAddressDyanmic.color_notPressed = isSelected_color;
      wifiIPAddressStatic.color_notPressed = autoFileName.color_notPressed;
    } else if(newDataSource == DATASOURCE_PLAYBACKFILE){
      //GUI auto detects number of channels for playback when file is selected
    } else if(newDataSource == DATASOURCE_SYNTHETIC){
      updateToNChan(8);
      synthChanButton4.color_notPressed = autoFileName.color_notPressed;
      synthChanButton8.color_notPressed = isSelected_color;
      synthChanButton16.color_notPressed = autoFileName.color_notPressed;
    }

    //output("The new data source is " + str + " and NCHAN = [" + nchan + "]. "); //This text has been added to Init 5 checkpoint messages in first tab
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

  if (theEvent.isFrom("wifiList")) {
    Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    wifi_portName = (String)bob.get("headline");
    output("Wifi Device Name = " + wifi_portName);
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

  PlaybackFileBox playbackFileBox;
  SDConverterBox sdConverterBox;

  BLEBox bleBox;
  DataLogBoxGanglion dataLogBoxGanglion;

  // BLEHardwareBox bleHardwareBox;

  WifiBox wifiBox;
  InterfaceBoxCyton interfaceBoxCyton;
  InterfaceBoxGanglion interfaceBoxGanglion;
  SampleRateCytonBox sampleRateCytonBox;
  SampleRateGanglionBox sampleRateGanglionBox;
  LatencyCytonBox latencyCytonBox;
  LatencyGanglionBox latencyGanglionBox;
  WifiTransferProtcolCytonBox wifiTransferProtcolCytonBox;
  WifiTransferProtcolGanglionBox wifiTransferProtcolGanglionBox;

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
    // cp5.set
    cp5Popup.setAutoDraw(false);

    //boxes active when eegDataSource = Normal (OpenBCI)
    dataSourceBox = new DataSourceBox(x, y, w, h, globalPadding);
    interfaceBoxCyton = new InterfaceBoxCyton(x + w, dataSourceBox.y, w, h, globalPadding);
    interfaceBoxGanglion = new InterfaceBoxGanglion(x + w, dataSourceBox.y, w, h, globalPadding);

    serialBox = new SerialBox(x + w, interfaceBoxCyton.y + interfaceBoxCyton.h, w, h, globalPadding);
    wifiBox = new WifiBox(x + w, interfaceBoxCyton.y + interfaceBoxCyton.h, w, h, globalPadding);

    dataLogBox = new DataLogBox(x + w, (serialBox.y + serialBox.h), w, h, globalPadding);
    channelCountBox = new ChannelCountBox(x + w, (dataLogBox.y + dataLogBox.h), w, h, globalPadding);
    synthChannelCountBox = new SyntheticChannelCountBox(x + w, dataSourceBox.y, w, h, globalPadding);
    sdBox = new SDBox(x + w, (channelCountBox.y + channelCountBox.h), w, h, globalPadding);
    sampleRateCytonBox = new SampleRateCytonBox(x + w + x + w - 3, channelCountBox.y, w, h, globalPadding);
    latencyCytonBox = new LatencyCytonBox(x + w + x + w - 3, (sampleRateCytonBox.y + sampleRateCytonBox.h), w, h, globalPadding);
    wifiTransferProtcolCytonBox = new WifiTransferProtcolCytonBox(x + w + x + w - 3, (latencyCytonBox.y + latencyCytonBox.h), w, h, globalPadding);

    //boxes active when eegDataSource = Playback
    playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, w, h, globalPadding);
    sdConverterBox = new SDConverterBox(x + w, (playbackFileBox.y + playbackFileBox.h), w, h, globalPadding);

    rcBox = new RadioConfigBox(x+w, y, w, h, globalPadding);
    channelPopup = new ChannelPopup(x+w, y, w, h, globalPadding);
    pollPopup = new PollPopup(x+w,y,w,h,globalPadding);

    wcBox = new WifiConfigBox(x+w, y, w, h, globalPadding);

    initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);

    // Ganglion
    bleBox = new BLEBox(x + w, interfaceBoxGanglion.y + interfaceBoxGanglion.h, w, h, globalPadding);
    dataLogBoxGanglion = new DataLogBoxGanglion(x + w, (bleBox.y + bleBox.h), w, h, globalPadding);
    sampleRateGanglionBox = new SampleRateGanglionBox(x + w, (dataLogBoxGanglion.y + dataLogBoxGanglion.h), w, h, globalPadding);
    latencyGanglionBox = new LatencyGanglionBox(x + w, (sampleRateGanglionBox.y + sampleRateGanglionBox.h), w, h, globalPadding);
    wifiTransferProtcolGanglionBox = new WifiTransferProtcolGanglionBox(x + w, (latencyGanglionBox.y + latencyGanglionBox.h), w, h, globalPadding);
    // bleHardwareBox = new BLEHardwareBox(x + w, (dataLogBoxGanglion.y + dataLogBoxGanglion.h), w, h, globalPadding);
  }

  public void resetListItems(){
    serialList.activeItem = -1;
    bleList.activeItem = -1;
    wifiList.activeItem = -1;
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

    //auto-update serial list
    if(Serial.list().length != serialPorts.length && systemMode != SYSTEMMODE_POSTINIT){
      println("Refreshing port list...");
      refreshPortList();
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
    wcBox.update();
    initBox.update();

    channelPopup.update();
    serialList.updateMenu();
    bleList.updateMenu();
    wifiList.updateMenu();
    dataLogBoxGanglion.update();
    latencyCytonBox.update();
    wifiTransferProtcolCytonBox.update();

    wifiBox.update();
    interfaceBoxCyton.update();
    interfaceBoxGanglion.update();
    latencyGanglionBox.update();
    wifiTransferProtcolGanglionBox.update();

    //SD File Conversion
    while (convertingSD == true) {
      convertSDFile();
    }

    // if (isHubInitialized && isHubObjectInitialized) {
    //   if (ganglion.getInterface() == INTERFACE_HUB_BLE || ganglion.getInterface() == INTERFACE_HUB_BLED112) {
    //     if (!calledForBLEList) {
    //       calledForBLEList = true;
    //       if (hub.isHubRunning()) {
    //         // Commented out because noble will auto scan
    //         hub.searchDeviceStart();
    //       }
    //     }
    //   }
    //
    //   if (ganglion.getInterface() == INTERFACE_HUB_WIFI || cyton.getInterface() == INTERFACE_HUB_WIFI) {
    //     if (!calledForWifiList) {
    //       calledForWifiList = true;
    //       if (hub.isHubRunning()) {
    //         hub.searchDeviceStart();
    //       }
    //     }
    //   }
    // }
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

      if (eegDataSource == DATASOURCE_CYTON) {	//when data source is from OpenBCI
        if (cyton.getInterface() == INTERFACE_NONE) {
          interfaceBoxCyton.draw();
        } else {
          interfaceBoxCyton.draw();
          if (cyton.getInterface() == INTERFACE_SERIAL) {
            serialBox.y = interfaceBoxCyton.y + interfaceBoxCyton.h;
            serialBox.draw();
            dataLogBox.y = serialBox.y + serialBox.h;
            cp5.get(MenuList.class, "serialList").setVisible(true);
            if (rcBox.isShowing) {
              rcBox.draw();
              if (channelPopup.wasClicked()) {
                channelPopup.draw();
                cp5Popup.get(MenuList.class, "channelList").setVisible(true);
                cp5Popup.get(MenuList.class, "pollList").setVisible(false);
                cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
                cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
              } else if (pollPopup.wasClicked()) {
                pollPopup.draw();
                cp5Popup.get(MenuList.class, "pollList").setVisible(true);
                cp5Popup.get(MenuList.class, "channelList").setVisible(false);
                cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
                // cp5.get(Textfield.class, "fileNameGanglion").setVisible(true); //make sure the data file field is visible
                cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
                cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
                cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
              }
            }
          } else if (cyton.getInterface() == INTERFACE_HUB_WIFI) {
            wifiBox.y = interfaceBoxCyton.y + interfaceBoxCyton.h;

            wifiBox.draw();
            dataLogBox.y = wifiBox.y + wifiBox.h;

            if (hub.getWiFiStyle() == WIFI_STATIC) {
              cp5.get(Textfield.class, "staticIPAddress").setVisible(true);
              cp5.get(MenuList.class, "wifiList").setVisible(false);
            } else {
              cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
              cp5.get(MenuList.class, "wifiList").setVisible(true);
            }
            if(wcBox.isShowing){
              wcBox.draw();
            }
            sampleRateCytonBox.draw();
            latencyCytonBox.draw();
            wifiTransferProtcolCytonBox.draw();
          }
          channelCountBox.y = dataLogBox.y + dataLogBox.h;
          sdBox.y = channelCountBox.y + channelCountBox.h;
          sampleRateCytonBox.y = channelCountBox.y;
          latencyCytonBox.y = sampleRateCytonBox.y + sampleRateCytonBox.h;
          wifiTransferProtcolCytonBox.y = latencyCytonBox.y + latencyCytonBox.h;
          // dataLogBox.y = serialBox.y + serialBox.h;
          dataLogBox.draw();
          channelCountBox.draw();
          sdBox.draw();
          cp5.get(Textfield.class, "fileName").setVisible(true); //make sure the data file field is visible
          cp5.get(Textfield.class, "fileNameGanglion").setVisible(false); //make sure the data file field is not visible
          // cp5.get(Textfield.class, "fileNameGanglion").setVisible(true); //make sure the data file field is visible
          cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
        }
      } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) { //when data source is from playback file
        playbackFileBox.draw();
        sdConverterBox.draw();

        //set other CP5 controllers invisible
        // cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
        // cp5.get(Textfield.class, "fileNameGanglion").setVisible(false); //make sure the data file field is visible
        cp5.get(MenuList.class, "serialList").setVisible(false);
        cp5.get(MenuList.class, "sdTimes").setVisible(false);
        cp5Popup.get(MenuList.class, "channelList").setVisible(false);
        cp5Popup.get(MenuList.class, "pollList").setVisible(false);

      } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  //synthetic
        //set other CP5 controllers invisible
        // hideAllBoxes();
        synthChannelCountBox.draw();
      } else if (eegDataSource == DATASOURCE_GANGLION) {
        if (ganglion.getInterface() == INTERFACE_NONE) {
          interfaceBoxGanglion.draw();
        } else {
          interfaceBoxGanglion.draw();
          if (ganglion.getInterface() == INTERFACE_HUB_BLE || ganglion.getInterface() == INTERFACE_HUB_BLED112) {
            bleBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
            dataLogBoxGanglion.y = bleBox.y + bleBox.h;
            bleBox.draw();
            cp5.get(MenuList.class, "bleList").setVisible(true);
            cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
          } else if (ganglion.getInterface() == INTERFACE_HUB_WIFI) {
            wifiBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
            dataLogBoxGanglion.y = wifiBox.y + wifiBox.h;
            wifiBox.draw();
            if (hub.getWiFiStyle() == WIFI_STATIC) {
              cp5.get(Textfield.class, "staticIPAddress").setVisible(true);
              cp5.get(MenuList.class, "wifiList").setVisible(false);
            } else {
              cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
              cp5.get(MenuList.class, "wifiList").setVisible(true);
            }
            if(wcBox.isShowing){
              wcBox.draw();
            }
            latencyGanglionBox.y = dataLogBoxGanglion.y + dataLogBoxGanglion.h;
            sampleRateGanglionBox.y = latencyGanglionBox.y + latencyGanglionBox.h;
            wifiTransferProtcolGanglionBox.y = wifiTransferProtcolGanglionBox.y + wifiTransferProtcolGanglionBox.h;
            latencyGanglionBox.draw();
            sampleRateGanglionBox.draw();
            wifiTransferProtcolGanglionBox.draw();
          }
          // dataLogBox.y = bleBox.y + bleBox.h;
          dataLogBoxGanglion.draw();
          cp5.get(Textfield.class, "fileName").setVisible(false); //make sure the data file field is visible
          cp5.get(Textfield.class, "fileNameGanglion").setVisible(true); //make sure the data file field is visible
        }
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
      String stopInstructions = "Press the \"STOP SYSTEM\" button to change your data source or edit system settings.";
      textAlign(CENTER, TOP);
      textFont(p4, 14);
      fill(bgColor);
      text(stopInstructions, x + globalPadding*2, y + globalPadding*3, w - globalPadding*4, dataSourceBox.h - globalPadding*4);
      popStyle();
    }

    //draw the ControlP5 stuff
    textFont(p4, 14);
    cp5Popup.draw();
    cp5.draw();

    popStyle();
  }

  public void hideRadioPopoutBox() {
    rcBox.isShowing = false;
    cp5Popup.hide(); // make sure to hide the controlP5 object
    cp5Popup.get(MenuList.class, "channelList").setVisible(false);
    cp5Popup.get(MenuList.class, "pollList").setVisible(false);
    // cp5Popup.hide(); // make sure to hide the controlP5 object
    popOutRadioConfigButton.setString(">");
    rcBox.print_onscreen("");
    if (board != null) {
      board.stop();
    }
    board = null;
  }

  public void hideWifiPopoutBox() {
    wcBox.isShowing = false;
    popOutWifiConfigButton.setString(">");
    wcBox.updateMessage("");
    if (hub.isPortOpen()) hub.closePort();
  }

  public void refreshPortList(){
    serialPorts = new String[Serial.list().length];
    serialPorts = Serial.list();
    serialList.items.clear();
    for (int i = 0; i < serialPorts.length; i++) {
      String tempPort = serialPorts[(serialPorts.length-1) - i]; //list backwards... because usually our port is at the bottom
      serialList.addItem(makeItem(tempPort));
    }
    serialList.updateMenu();
  }

  public void hideAllBoxes() {
    //set other CP5 controllers invisible
    //
    cp5.get(Textfield.class, "fileName").setVisible(false);
    cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
    cp5.get(Textfield.class, "fileNameGanglion").setVisible(false);
    cp5.get(MenuList.class, "serialList").setVisible(false);
    cp5.get(MenuList.class, "bleList").setVisible(false);
    cp5.get(MenuList.class, "sdTimes").setVisible(false);
    cp5.get(MenuList.class, "wifiList").setVisible(false);
    cp5Popup.get(MenuList.class, "channelList").setVisible(false);
    cp5Popup.get(MenuList.class, "pollList").setVisible(false);
  }

  //mouse pressed in control panel
  public void CPmousePressed() {
    // verbosePrint("CPmousePressed");

    if (initSystemButton.isMouseHere()) {
      initSystemButton.setIsActive(true);
      initSystemButton.wasPressed = true;
    }

    //only able to click buttons of control panel when system is not running
    if (systemMode != 10) {

      if ((eegDataSource == DATASOURCE_CYTON || eegDataSource == DATASOURCE_GANGLION) && (cyton.isWifi() || ganglion.isWifi())) {
        if(getIpAddress.isMouseHere()) {
          getIpAddress.setIsActive(true);
          getIpAddress.wasPressed = true;
        }

        if(getFirmwareVersion.isMouseHere()) {
          getFirmwareVersion.setIsActive(true);
          getFirmwareVersion.wasPressed = true;
        }

        if(getMacAddress.isMouseHere()) {
          getMacAddress.setIsActive(true);
          getMacAddress.wasPressed = true;
        }

        if(eraseCredentials.isMouseHere()) {
          eraseCredentials.setIsActive(true);
          eraseCredentials.wasPressed = true;
        }

        if(getTypeOfAttachedBoard.isMouseHere()) {
          getTypeOfAttachedBoard.setIsActive(true);
          getTypeOfAttachedBoard.wasPressed = true;
        }

        if (popOutWifiConfigButton.isMouseHere()){
          popOutWifiConfigButton.setIsActive(true);
          popOutWifiConfigButton.wasPressed = true;
        }

        if(wifiIPAddressDyanmic.isMouseHere()) {
          wifiIPAddressDyanmic.setIsActive(true);
          wifiIPAddressDyanmic.wasPressed = true;
          wifiIPAddressDyanmic.color_notPressed = isSelected_color;
          wifiIPAddressStatic.color_notPressed = autoFileName.color_notPressed;
        }

        if(wifiIPAddressStatic.isMouseHere()) {
          wifiIPAddressStatic.setIsActive(true);
          wifiIPAddressStatic.wasPressed = true;
          wifiIPAddressStatic.color_notPressed = isSelected_color;
          wifiIPAddressDyanmic.color_notPressed = autoFileName.color_notPressed;
        }
      }

      //active buttons during DATASOURCE_CYTON
      if (eegDataSource == DATASOURCE_CYTON) {
        if (cyton.isSerial()) {
          if (popOutRadioConfigButton.isMouseHere()){
            popOutRadioConfigButton.setIsActive(true);
            popOutRadioConfigButton.wasPressed = true;
          }
          if (refreshPort.isMouseHere()) {
            refreshPort.setIsActive(true);
            refreshPort.wasPressed = true;
          }
        }

        if (cyton.isWifi()) {
          if (refreshWifi.isMouseHere()) {
            refreshWifi.setIsActive(true);
            refreshWifi.wasPressed = true;
          }
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



        if (protocolWifiCyton.isMouseHere()) {
          protocolWifiCyton.setIsActive(true);
          protocolWifiCyton.wasPressed = true;
          protocolWifiCyton.color_notPressed = isSelected_color;
          protocolSerialCyton.color_notPressed = autoFileName.color_notPressed;
        }

        if (protocolSerialCyton.isMouseHere()) {
          protocolSerialCyton.setIsActive(true);
          protocolSerialCyton.wasPressed = true;
          protocolWifiCyton.color_notPressed = autoFileName.color_notPressed;
          protocolSerialCyton.color_notPressed = isSelected_color;
        }

        if (autoscan.isMouseHere()){
          autoscan.setIsActive(true);
          autoscan.wasPressed = true;
        }

        if (systemStatus.isMouseHere()){
          systemStatus.setIsActive(true);
          systemStatus.wasPressed = true;
        }

        if (sampleRate250.isMouseHere()) {
          sampleRate250.setIsActive(true);
          sampleRate250.wasPressed = true;
          sampleRate250.color_notPressed = isSelected_color;
          sampleRate500.color_notPressed = autoFileName.color_notPressed;
          sampleRate1000.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (sampleRate500.isMouseHere()) {
          sampleRate500.setIsActive(true);
          sampleRate500.wasPressed = true;
          sampleRate500.color_notPressed = isSelected_color;
          sampleRate250.color_notPressed = autoFileName.color_notPressed;
          sampleRate1000.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (sampleRate1000.isMouseHere()) {
          sampleRate1000.setIsActive(true);
          sampleRate1000.wasPressed = true;
          sampleRate1000.color_notPressed = isSelected_color;
          sampleRate250.color_notPressed = autoFileName.color_notPressed; //default color of button
          sampleRate500.color_notPressed = autoFileName.color_notPressed;
        }

        if (latencyCyton5ms.isMouseHere()) {
          latencyCyton5ms.setIsActive(true);
          latencyCyton5ms.wasPressed = true;
          latencyCyton5ms.color_notPressed = isSelected_color;
          latencyCyton10ms.color_notPressed = autoFileName.color_notPressed; //default color of button
          latencyCyton20ms.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (latencyCyton10ms.isMouseHere()) {
          latencyCyton10ms.setIsActive(true);
          latencyCyton10ms.wasPressed = true;
          latencyCyton10ms.color_notPressed = isSelected_color;
          latencyCyton5ms.color_notPressed = autoFileName.color_notPressed; //default color of button
          latencyCyton20ms.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (latencyCyton20ms.isMouseHere()) {
          latencyCyton20ms.setIsActive(true);
          latencyCyton20ms.wasPressed = true;
          latencyCyton20ms.color_notPressed = isSelected_color;
          latencyCyton5ms.color_notPressed = autoFileName.color_notPressed; //default color of button
          latencyCyton10ms.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (wifiInternetProtocolCytonTCP.isMouseHere()) {
          wifiInternetProtocolCytonTCP.setIsActive(true);
          wifiInternetProtocolCytonTCP.wasPressed = true;
          wifiInternetProtocolCytonTCP.color_notPressed = isSelected_color;
          wifiInternetProtocolCytonUDP.color_notPressed = autoFileName.color_notPressed; //default color of button
          wifiInternetProtocolCytonUDPBurst.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (wifiInternetProtocolCytonUDP.isMouseHere()) {
          wifiInternetProtocolCytonUDP.setIsActive(true);
          wifiInternetProtocolCytonUDP.wasPressed = true;
          wifiInternetProtocolCytonUDP.color_notPressed = isSelected_color;
          wifiInternetProtocolCytonTCP.color_notPressed = autoFileName.color_notPressed; //default color of button
          wifiInternetProtocolCytonUDPBurst.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (wifiInternetProtocolCytonUDPBurst.isMouseHere()) {
          wifiInternetProtocolCytonUDPBurst.setIsActive(true);
          wifiInternetProtocolCytonUDPBurst.wasPressed = true;
          wifiInternetProtocolCytonUDPBurst.color_notPressed = isSelected_color;
          wifiInternetProtocolCytonTCP.color_notPressed = autoFileName.color_notPressed; //default color of button
          wifiInternetProtocolCytonUDP.color_notPressed = autoFileName.color_notPressed; //default color of button
        }
      }

      if (eegDataSource == DATASOURCE_GANGLION) {
        // This is where we check for button presses if we are searching for BLE devices

        if (autoFileNameGanglion.isMouseHere()) {
          autoFileNameGanglion.setIsActive(true);
          autoFileNameGanglion.wasPressed = true;
        }

        if (outputODFGanglion.isMouseHere()) {
          outputODFGanglion.setIsActive(true);
          outputODFGanglion.wasPressed = true;
          outputODFGanglion.color_notPressed = isSelected_color;
          outputBDFGanglion.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (outputBDFGanglion.isMouseHere()) {
          outputBDFGanglion.setIsActive(true);
          outputBDFGanglion.wasPressed = true;
          outputBDFGanglion.color_notPressed = isSelected_color;
          outputODFGanglion.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (ganglion.isWifi()) {
          if (refreshWifi.isMouseHere()) {
            refreshWifi.setIsActive(true);
            refreshWifi.wasPressed = true;
          }
        } else {
          if (refreshBLE.isMouseHere()) {
            refreshBLE.setIsActive(true);
            refreshBLE.wasPressed = true;
          }
        }

        if (protocolBLEGanglion.isMouseHere()) {
          protocolBLEGanglion.setIsActive(true);
          protocolBLEGanglion.wasPressed = true;
          protocolBLED112Ganglion.color_notPressed = autoFileName.color_notPressed;
          protocolBLEGanglion.color_notPressed = isSelected_color;
          protocolWifiGanglion.color_notPressed = autoFileName.color_notPressed;
        }

        if (protocolWifiGanglion.isMouseHere()) {
          protocolWifiGanglion.setIsActive(true);
          protocolWifiGanglion.wasPressed = true;
          protocolBLED112Ganglion.color_notPressed = autoFileName.color_notPressed;
          protocolWifiGanglion.color_notPressed = isSelected_color;
          protocolBLEGanglion.color_notPressed = autoFileName.color_notPressed;
        }

        if (protocolBLED112Ganglion.isMouseHere()) {
          protocolBLED112Ganglion.setIsActive(true);
          protocolBLED112Ganglion.wasPressed = true;
          protocolBLEGanglion.color_notPressed = autoFileName.color_notPressed;
          protocolBLED112Ganglion.color_notPressed = isSelected_color;
          protocolWifiGanglion.color_notPressed = autoFileName.color_notPressed;
        }

        if (sampleRate200.isMouseHere()) {
          sampleRate200.setIsActive(true);
          sampleRate200.wasPressed = true;
          sampleRate200.color_notPressed = isSelected_color;
          sampleRate1600.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (sampleRate1600.isMouseHere()) {
          sampleRate1600.setIsActive(true);
          sampleRate1600.wasPressed = true;
          sampleRate1600.color_notPressed = isSelected_color;
          sampleRate200.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (latencyGanglion5ms.isMouseHere()) {
          latencyGanglion5ms.setIsActive(true);
          latencyGanglion5ms.wasPressed = true;
          latencyGanglion5ms.color_notPressed = isSelected_color;
          latencyGanglion10ms.color_notPressed = autoFileName.color_notPressed; //default color of button
          latencyGanglion20ms.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (latencyGanglion10ms.isMouseHere()) {
          latencyGanglion10ms.setIsActive(true);
          latencyGanglion10ms.wasPressed = true;
          latencyGanglion10ms.color_notPressed = isSelected_color;
          latencyGanglion5ms.color_notPressed = autoFileName.color_notPressed; //default color of button
          latencyGanglion20ms.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (latencyGanglion20ms.isMouseHere()) {
          latencyGanglion20ms.setIsActive(true);
          latencyGanglion20ms.wasPressed = true;
          latencyGanglion20ms.color_notPressed = isSelected_color;
          latencyGanglion5ms.color_notPressed = autoFileName.color_notPressed; //default color of button
          latencyGanglion10ms.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (wifiInternetProtocolGanglionTCP.isMouseHere()) {
          wifiInternetProtocolGanglionTCP.setIsActive(true);
          wifiInternetProtocolGanglionTCP.wasPressed = true;
          wifiInternetProtocolGanglionTCP.color_notPressed = isSelected_color;
          wifiInternetProtocolGanglionUDP.color_notPressed = autoFileName.color_notPressed; //default color of button
          wifiInternetProtocolGanglionUDPBurst.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (wifiInternetProtocolGanglionUDP.isMouseHere()) {
          wifiInternetProtocolGanglionUDP.setIsActive(true);
          wifiInternetProtocolGanglionUDP.wasPressed = true;
          wifiInternetProtocolGanglionUDP.color_notPressed = isSelected_color;
          wifiInternetProtocolGanglionTCP.color_notPressed = autoFileName.color_notPressed; //default color of button
          wifiInternetProtocolGanglionUDPBurst.color_notPressed = autoFileName.color_notPressed; //default color of button
        }

        if (wifiInternetProtocolGanglionUDPBurst.isMouseHere()) {
          wifiInternetProtocolGanglionUDPBurst.setIsActive(true);
          wifiInternetProtocolGanglionUDPBurst.wasPressed = true;
          wifiInternetProtocolGanglionUDPBurst.color_notPressed = isSelected_color;
          wifiInternetProtocolGanglionTCP.color_notPressed = autoFileName.color_notPressed; //default color of button
          wifiInternetProtocolGanglionUDP.color_notPressed = autoFileName.color_notPressed; //default color of button
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

      //active buttons during DATASOURCE_SYNTHETIC
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
    if(popOutRadioConfigButton.isMouseHere() && popOutRadioConfigButton.wasPressed){
      popOutRadioConfigButton.wasPressed = false;
      popOutRadioConfigButton.setIsActive(false);
      if (cyton.isSerial()) {
        if(rcBox.isShowing){
          hideRadioPopoutBox();
        }
        else{
          rcBox.isShowing = true;
          popOutRadioConfigButton.setString("<");
        }
      }
    }

    if (rcBox.isShowing) {
      if(getChannel.isMouseHere() && getChannel.wasPressed){
        // if(board != null) // Radios_Config will handle creating the serial port JAM 1/2017
        get_channel(rcBox);
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

      if(autoscan.isMouseHere() && autoscan.wasPressed){
        autoscan.wasPressed = false;
        autoscan.setIsActive(false);
        scan_channels(rcBox);
      }

      if(systemStatus.isMouseHere() && systemStatus.wasPressed){
        system_status(rcBox);
        systemStatus.setIsActive(false);
        systemStatus.wasPressed = false;
      }
    }

    if(popOutWifiConfigButton.isMouseHere() && popOutWifiConfigButton.wasPressed){
      popOutWifiConfigButton.wasPressed = false;
      popOutWifiConfigButton.setIsActive(false);
      if (cyton.isWifi() || ganglion.isWifi()) {
        if(wcBox.isShowing){
          hideWifiPopoutBox();
        } else {
          if (hub.getWiFiStyle() == WIFI_STATIC) {
            wifi_ipAddress = cp5.get(Textfield.class, "staticIPAddress").getText();
            println("Static IP address of " + wifi_ipAddress);
            output("Static IP address of " + wifi_ipAddress);
            hub.examineWifi(wifi_ipAddress);
            wcBox.isShowing = true;
            popOutWifiConfigButton.setString("<");
          } else {
            if (wifi_portName == "N/A") {
              output("Please select a WiFi Shield first. Can't see your WiFi Shield? Learn how at docs.openbci.com/Tutorials/03-Wifi_Getting_Started_Guide");
            } else {
              output("Attempting to connect to WiFi Shield named " + wifi_portName);
              hub.examineWifi(wifi_portName);
              wcBox.isShowing = true;
              popOutWifiConfigButton.setString("<");
            }
          }
        }
      }
    }

    if (wcBox.isShowing) {
      if(getIpAddress.isMouseHere() && getIpAddress.wasPressed){
        hub.getWifiInfo(TCP_WIFI_GET_IP_ADDRESS);
        getIpAddress.wasPressed = false;
        getIpAddress.setIsActive(false);
      }

      if(getFirmwareVersion.isMouseHere() && getFirmwareVersion.wasPressed){
        hub.getWifiInfo(TCP_WIFI_GET_FIRMWARE_VERSION);
        getFirmwareVersion.wasPressed = false;
        getFirmwareVersion.setIsActive(false);
      }

      if(getMacAddress.isMouseHere() && getMacAddress.wasPressed){
        hub.getWifiInfo(TCP_WIFI_GET_MAC_ADDRESS);
        getMacAddress.wasPressed = false;
        getMacAddress.setIsActive(false);
      }

      if(eraseCredentials.isMouseHere() && eraseCredentials.wasPressed){
        hub.getWifiInfo(TCP_WIFI_ERASE_CREDENTIALS);
        eraseCredentials.wasPressed=false;
        eraseCredentials.setIsActive(false);
      }

      if(getTypeOfAttachedBoard.isMouseHere() && getTypeOfAttachedBoard.wasPressed){
        // Wifi_Config will handle creating the connection
        hub.getWifiInfo(TCP_WIFI_GET_TYPE_OF_ATTACHED_BOARD);
        getTypeOfAttachedBoard.wasPressed=false;
        getTypeOfAttachedBoard.setIsActive(false);
      }
    }

    if (initSystemButton.isMouseHere() && initSystemButton.wasPressed) {
      if (rcBox.isShowing) {
        hideRadioPopoutBox();
      }
      if (wcBox.isShowing) {
        hideWifiPopoutBox();
      }
      //if system is not active ... initate system and flip button state
      initButtonPressed();
      //cursor(ARROW); //this this back to ARROW
    }

    //open or close serial port if serial port button is pressed (left button in serial widget)
    if (refreshPort.isMouseHere() && refreshPort.wasPressed) {
      output("Serial/COM List Refreshed");
      refreshPortList();
    }

    if (refreshBLE.isMouseHere() && refreshBLE.wasPressed) {
      if (isHubObjectInitialized) {
        output("BLE Devices Refreshing");
        bleList.items.clear();
        hub.searchDeviceStart();
      } else {
        output("Please wait till BLE is fully initalized");
      }
    }

    if (refreshWifi.isMouseHere() && refreshWifi.wasPressed) {
      if (isHubObjectInitialized) {
        output("Wifi Devices Refreshing");
        wifiList.items.clear();
        hub.searchDeviceStart();
      } else {
        output("Please wait till hub is fully initalized");
      }
    }

    if(wifiIPAddressDyanmic.isMouseHere() && wifiIPAddressDyanmic.wasPressed) {
      hub.setWiFiStyle(WIFI_DYNAMIC);
      wifiBox.h = 200;
      String output = "Using " + (hub.getWiFiStyle() == WIFI_STATIC ? "Static" : "Dynamic") + " IP address of the WiFi Shield!";
      outputInfo(output);
      println(output);
    }

    if(wifiIPAddressStatic.isMouseHere() && wifiIPAddressStatic.wasPressed) {
      hub.setWiFiStyle(WIFI_STATIC);
      wifiBox.h = 120;
      String output = "Using " + (hub.getWiFiStyle() == WIFI_STATIC ? "Static" : "Dynamic") + " IP address of the WiFi Shield!";
      outputInfo(output);
      println(output);
    }

    if (protocolBLEGanglion.isMouseHere() && protocolBLEGanglion.wasPressed) {
      println("protocolBLEGanglion");

      wifiList.items.clear();
      bleList.items.clear();
      controlPanel.hideAllBoxes();
      if (isHubObjectInitialized) {
        if (isWindows()) {
          outputSuccess("Using CSR Dongle for Ganglion");
        } else {
          outputSuccess("Using built in BLE for Ganglion");
        }
        if (hub.isPortOpen()) hub.closePort();
        ganglion.setInterface(INTERFACE_HUB_BLE);
        // hub.searchDeviceStart();
      } else {
        outputWarn("Please wait till hub is fully initalized");
      }
    }

    if (protocolBLED112Ganglion.isMouseHere() && protocolBLED112Ganglion.wasPressed) {

      wifiList.items.clear();
      bleList.items.clear();
      controlPanel.hideAllBoxes();
      if (isHubObjectInitialized) {
        output("Protocol BLED112 Selected for Ganglion");
        println("Protocol BLED112 Selected for Ganglion");
        if (hub.isPortOpen()) hub.closePort();
        ganglion.setInterface(INTERFACE_HUB_BLED112);
        hub.searchDeviceStart();
      } else {
        outputWarn("Please wait till hub is fully initalized");
      }
    }

    if (protocolWifiGanglion.isMouseHere() && protocolWifiGanglion.wasPressed) {
      println("protocolWifiGanglion");
      wifiList.items.clear();
      bleList.items.clear();
      controlPanel.hideAllBoxes();
      println("isHubObjectInitialized: " + (isHubObjectInitialized ? "true" : "else"));
      if (isHubObjectInitialized) {
        output("Protocol Wifi Selected for Ganglion");
        if (hub.isPortOpen()) hub.closePort();
        ganglion.setInterface(INTERFACE_HUB_WIFI);
        hub.searchDeviceStart();
      } else {
        output("Please wait till hub is fully initalized");
      }
    }

    if (protocolSerialCyton.isMouseHere() && protocolSerialCyton.wasPressed) {
      wifiList.items.clear();
      bleList.items.clear();
      controlPanel.hideAllBoxes();
      if (isHubObjectInitialized) {
        output("Protocol Serial Selected for Cyton");
        if (hub.isPortOpen()) hub.closePort();
        cyton.setInterface(INTERFACE_SERIAL);
      } else {
        output("Please wait till hub is fully initalized");
      }
    }

    if (protocolWifiCyton.isMouseHere() && protocolWifiCyton.wasPressed) {
      wifiList.items.clear();
      bleList.items.clear();
      controlPanel.hideAllBoxes();
      if (isHubObjectInitialized) {
        output("Protocol Wifi Selected for Cyton");
        if (hub.isPortOpen()) hub.closePort();
        cyton.setInterface(INTERFACE_HUB_WIFI);
        hub.searchDeviceStart();
      } else {
        output("Please wait till hub is fully initalized");
      }
    }

    //open or close serial port if serial port button is pressed (left button in serial widget)
    if (autoFileName.isMouseHere() && autoFileName.wasPressed) {
      output("Autogenerated Cyton \"File Name\" based on current date/time");
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

    if (autoFileNameGanglion.isMouseHere() && autoFileNameGanglion.wasPressed) {
      output("Autogenerated Ganglion \"File Name\" based on current date/time");
      cp5.get(Textfield.class, "fileNameGanglion").setText(getDateString());
    }

    if (outputODFGanglion.isMouseHere() && outputODFGanglion.wasPressed) {
      output("Output has been set to OpenBCI Data Format");
      outputDataSource = OUTPUT_SOURCE_ODF;
    }

    if (outputBDFGanglion.isMouseHere() && outputBDFGanglion.wasPressed) {
      output("Output has been set to BDF+ (biosemi data format based off EDF)");
      outputDataSource = OUTPUT_SOURCE_BDF;
    }

    if (chanButton8.isMouseHere() && chanButton8.wasPressed) {
      updateToNChan(8);
    }

    if (chanButton16.isMouseHere() && chanButton16.wasPressed ) {
      updateToNChan(16);
    }

    if (sampleRate200.isMouseHere() && sampleRate200.wasPressed) {
      ganglion.setSampleRate(200);
    }

    if (sampleRate1600.isMouseHere() && sampleRate1600.wasPressed) {
      ganglion.setSampleRate(1600);
    }

    if (sampleRate250.isMouseHere() && sampleRate250.wasPressed) {
      cyton.setSampleRate(250);
    }

    if (sampleRate500.isMouseHere() && sampleRate500.wasPressed) {
      cyton.setSampleRate(500);
    }

    if (sampleRate1000.isMouseHere() && sampleRate1000.wasPressed) {
      cyton.setSampleRate(1000);
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

    if (latencyCyton5ms.isMouseHere() && latencyCyton5ms.wasPressed) {
      hub.setLatency(LATENCY_5_MS);
    }

    if (latencyCyton10ms.isMouseHere() && latencyCyton10ms.wasPressed) {
      hub.setLatency(LATENCY_10_MS);
    }

    if (latencyCyton20ms.isMouseHere() && latencyCyton20ms.wasPressed) {
      hub.setLatency(LATENCY_20_MS);
    }

    if (latencyGanglion5ms.isMouseHere() && latencyGanglion5ms.wasPressed) {
      hub.setLatency(LATENCY_5_MS);
    }

    if (latencyGanglion10ms.isMouseHere() && latencyGanglion10ms.wasPressed) {
      hub.setLatency(LATENCY_10_MS);
    }

    if (latencyGanglion20ms.isMouseHere() && latencyGanglion20ms.wasPressed) {
      hub.setLatency(LATENCY_20_MS);
    }

    if (wifiInternetProtocolCytonTCP.isMouseHere() && wifiInternetProtocolCytonTCP.wasPressed) {
      hub.setWifiInternetProtocol(TCP);
    }

    if (wifiInternetProtocolCytonUDP.isMouseHere() && wifiInternetProtocolCytonUDP.wasPressed) {
      hub.setWifiInternetProtocol(UDP);
    }

    if (wifiInternetProtocolCytonUDPBurst.isMouseHere() && wifiInternetProtocolCytonUDPBurst.wasPressed) {
      hub.setWifiInternetProtocol(UDP_BURST);
    }

    if (wifiInternetProtocolGanglionTCP.isMouseHere() && wifiInternetProtocolGanglionTCP.wasPressed) {
      hub.setWifiInternetProtocol(TCP);
    }

    if (wifiInternetProtocolGanglionUDP.isMouseHere() && wifiInternetProtocolGanglionUDP.wasPressed) {
      hub.setWifiInternetProtocol(UDP);
    }

    if (wifiInternetProtocolGanglionUDPBurst.isMouseHere() && wifiInternetProtocolGanglionUDPBurst.wasPressed) {
      hub.setWifiInternetProtocol(UDP_BURST);
    }

    if (selectPlaybackFile.isMouseHere() && selectPlaybackFile.wasPressed) {
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelectedControlPanel");
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
    refreshWifi.setIsActive(false);
    refreshWifi.wasPressed = false;
    protocolBLEGanglion.setIsActive(false);
    protocolBLEGanglion.wasPressed = false;
    protocolBLED112Ganglion.setIsActive(false);
    protocolBLED112Ganglion.wasPressed = false;
    protocolWifiGanglion.setIsActive(false);
    protocolWifiGanglion.wasPressed = false;
    protocolSerialCyton.setIsActive(false);
    protocolSerialCyton.wasPressed = false;
    protocolWifiCyton.setIsActive(false);
    protocolWifiCyton.wasPressed = false;
    initSystemButton.setIsActive(false);
    initSystemButton.wasPressed = false;
    autoFileName.setIsActive(false);
    autoFileName.wasPressed = false;
    outputBDF.setIsActive(false);
    outputBDF.wasPressed = false;
    outputODF.setIsActive(false);
    outputODF.wasPressed = false;
    autoFileNameGanglion.setIsActive(false);
    autoFileNameGanglion.wasPressed = false;
    wifiIPAddressDyanmic.setIsActive(false);
    wifiIPAddressDyanmic.wasPressed = false;
    wifiIPAddressStatic.setIsActive(false);
    wifiIPAddressStatic.wasPressed = false;
    outputBDFGanglion.setIsActive(false);
    outputBDFGanglion.wasPressed = false;
    outputODFGanglion.setIsActive(false);
    outputODFGanglion.wasPressed = false;
    chanButton8.setIsActive(false);
    chanButton8.wasPressed = false;
    sampleRate200.setIsActive(false);
    sampleRate200.wasPressed = false;
    sampleRate1600.setIsActive(false);
    sampleRate1600.wasPressed = false;
    sampleRate250.setIsActive(false);
    sampleRate250.wasPressed = false;
    sampleRate500.setIsActive(false);
    sampleRate500.wasPressed = false;
    sampleRate1000.setIsActive(false);
    sampleRate1000.wasPressed = false;
    latencyCyton5ms.setIsActive(false);
    latencyCyton5ms.wasPressed = false;
    latencyCyton10ms.setIsActive(false);
    latencyCyton10ms.wasPressed = false;
    latencyCyton20ms.setIsActive(false);
    latencyCyton20ms.wasPressed = false;
    latencyGanglion5ms.setIsActive(false);
    latencyGanglion5ms.wasPressed = false;
    latencyGanglion10ms.setIsActive(false);
    latencyGanglion10ms.wasPressed = false;
    latencyGanglion20ms.setIsActive(false);
    latencyGanglion20ms.wasPressed = false;
    wifiInternetProtocolCytonTCP.setIsActive(false);
    wifiInternetProtocolCytonTCP.wasPressed = false;
    wifiInternetProtocolCytonUDP.setIsActive(false);
    wifiInternetProtocolCytonUDP.wasPressed = false;
    wifiInternetProtocolCytonUDPBurst.setIsActive(false);
    wifiInternetProtocolCytonUDPBurst.wasPressed = false;
    wifiInternetProtocolGanglionTCP.setIsActive(false);
    wifiInternetProtocolGanglionTCP.wasPressed = false;
    wifiInternetProtocolGanglionUDP.setIsActive(false);
    wifiInternetProtocolGanglionUDP.wasPressed = false;
    wifiInternetProtocolGanglionUDPBurst.setIsActive(false);
    wifiInternetProtocolGanglionUDPBurst.wasPressed = false;
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
      if ((eegDataSource == DATASOURCE_CYTON && cyton.getInterface() == INTERFACE_NONE) || (eegDataSource == DATASOURCE_GANGLION && ganglion.getInterface() == INTERFACE_NONE)) {
        output("No Transfer Protocol selected. Please select your Transfer Protocol and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_CYTON && cyton.getInterface() == INTERFACE_SERIAL && openBCI_portName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
        output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_CYTON && cyton.getInterface() == INTERFACE_HUB_WIFI && wifi_portName == "N/A" && hub.getWiFiStyle() == WIFI_DYNAMIC) {
        output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
        output("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_GANGLION && (ganglion.getInterface() == INTERFACE_HUB_BLE || ganglion.getInterface() == INTERFACE_HUB_BLED112) && ganglion_portName == "N/A") {
        output("No BLE device selected. Please select your Ganglion device and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
      } else if (eegDataSource == DATASOURCE_GANGLION && ganglion.getInterface() == INTERFACE_HUB_WIFI && wifi_portName == "N/A" && hub.getWiFiStyle() == WIFI_DYNAMIC) {
        output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
        initSystemButton.wasPressed = false;
        initSystemButton.setIsActive(false);
        return;
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
        if (eegDataSource == DATASOURCE_CYTON) {
          verbosePrint("ControlPanel — port is open: " + cyton.isPortOpen());
          if (cyton.isPortOpen() == true) {
            cyton.closePort();
          }
        } else if(eegDataSource == DATASOURCE_GANGLION){
          verbosePrint("ControlPanel — port is open: " + ganglion.isPortOpen());
          if (ganglion.isPortOpen()) {
            ganglion.closePort();
          }
        }
        if(eegDataSource == DATASOURCE_GANGLION){
          fileName = cp5.get(Textfield.class, "fileNameGanglion").getText(); // store the current text field value of "File Name" to be passed along to dataFiles
        } else if(eegDataSource == DATASOURCE_CYTON){
          fileName = cp5.get(Textfield.class, "fileName").getText(); // store the current text field value of "File Name" to be passed along to dataFiles
        }
        if (hub.getWiFiStyle() == WIFI_STATIC && (cyton.isWifi() || ganglion.isWifi())) {
          wifi_ipAddress = cp5.get(Textfield.class, "staticIPAddress").getText();
          println("Static IP address of " + wifi_ipAddress);
        }
        midInit = true;
        println("initSystem yoo");
        initSystem(); //calls the initSystem() funciton of the OpenBCI_GUI.pde file
      }
    }

    //if system is already active ... stop system and flip button state back
    else {
      outputInfo("Learn how to use this application and more at docs.openbci.com");
      initSystemButton.setString("START SYSTEM");
      cp5.get(Textfield.class, "fileName").setText(getDateString()); //creates new data file name so that you don't accidentally overwrite the old one
      cp5.get(Textfield.class, "fileNameGanglion").setText(getDateString()); //creates new data file name so that you don't accidentally overwrite the old one
      cp5.get(Textfield.class, "staticIPAddress").setText(wifi_ipAddress); // Fills the last (or default) IP address
      haltSystem();
    }
}

void updateToNChan(int _nchan) {
  nchan = _nchan;
  slnchan = _nchan; //used in SoftwareSettings.pde only
  fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
  yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
  println("channel count set to " + str(nchan));
  hub.initDataPackets(_nchan, 3);
  ganglion.initDataPackets(_nchan, 3);
  cyton.initDataPackets(_nchan, 3);
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
    h = 140 + _padding;
    padding = _padding;

    // autoconnect = new Button(x + padding, y + padding*3 + 4, w - padding*2, 24, "AUTOCONNECT AND START SYSTEM", fontInfo.buttonLabel_size);
    refreshPort = new Button (x + padding, y + padding*4 + 72 + 8, w - padding*2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);
    popOutRadioConfigButton = new Button(x+padding + (w-padding*4), y + padding, 20,20,">",fontInfo.buttonLabel_size);

    serialList = new MenuList(cp5, "serialList", w - padding*2, 72, p4);
    // println(w-padding*2);
    serialList.setPosition(x + padding, y + padding*3 + 8);
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
    // autoconnect.draw();
    if (cyton.isSerial()) {
      popOutRadioConfigButton.draw();
    }
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
    h = 140 + _padding;
    padding = _padding;

    refreshBLE = new Button (x + padding, y + padding*4 + 72 + 8, w - padding*5, 24, "START SEARCH", fontInfo.buttonLabel_size);
    bleList = new MenuList(cp5, "bleList", w - padding*2, 72, p4);
    // println(w-padding*2);
    bleList.setPosition(x + padding, y + padding*3 + 8);
    // Call to update the list
    // ganglion.getBLEDevices();
  }

  public void update() {
    // Quick check to see if there are just more or less devices in general

  }

  public void updateListPosition(){
    bleList.setPosition(x + padding, y + padding * 3);
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

    if(isHubInitialized && isHubObjectInitialized && ganglion.isBLE() && hub.isSearching()){
      image(loadingGIF_blue, w + 225,  y + padding*4 + 72 + 10, 20, 20);
      refreshBLE.setString("SEARCHING...");
    } else {
      refreshBLE.setString("START SEARCH");
    }
  }

  public void refreshBLEList() {
    bleList.items.clear();
    for (int i = 0; i < hub.deviceList.length; i++) {
      String tempPort = hub.deviceList[i];
      bleList.addItem(makeItem(tempPort));
    }
    bleList.updateMenu();
  }
};

class WifiBox {
  int x, y, w, h, padding; //size and position
  //connect/disconnect button
  //Refresh list button
  //String port status;

  WifiBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 184 + _padding;
    padding = _padding;

    wifiIPAddressDyanmic = new Button (x + padding, y + padding*2 + 30, (w-padding*3)/2, 24, "DYNAMIC IP", fontInfo.buttonLabel_size);
    if (hub.getWiFiStyle() == WIFI_DYNAMIC) wifiIPAddressDyanmic.color_notPressed = isSelected_color; //make it appear like this one is already selected
    wifiIPAddressStatic = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 30, (w-padding*3)/2, 24, "STATIC IP", fontInfo.buttonLabel_size);
    if (hub.getWiFiStyle() == WIFI_STATIC) wifiIPAddressStatic.color_notPressed = isSelected_color; //make it appear like this one is already selected

    refreshWifi = new Button (x + padding, y + padding*5 + 72 + 8 + 24, w - padding*5, 24, "START SEARCH", fontInfo.buttonLabel_size);
    wifiList = new MenuList(cp5, "wifiList", w - padding*2, 72 + 8, p4);
    popOutWifiConfigButton = new Button(x+padding + (w-padding*4), y + padding, 20,20,">",fontInfo.buttonLabel_size);

    // println(w-padding*2);
    wifiList.setPosition(x + padding, y + padding*4 + 8 + 24);
    // Call to update the list

    cp5.addTextfield("staticIPAddress")
      .setPosition(x + 90, y + 100)
      .setCaptionLabel("")
      .setSize(w - padding*2, 26)
      .setFont(f2)
      .setFocus(false)
      .setColor(color(26, 26, 26))
      .setColorBackground(color(255, 255, 255)) // text field bg color
      .setColorValueLabel(color(0, 0, 0))  // text color
      .setColorForeground(isSelected_color)  // border color when not selected
      .setColorActive(isSelected_color)  // border color when selected
      .setColorCursor(color(26, 26, 26))
      .setText(wifi_ipAddress)
      .align(5, 10, 20, 40)
      .onDoublePress(cb)
      .setAutoClear(true);
  }

  public void update() {
    // Quick check to see if there are just more or less devices in general

  }

  public void updateListPosition(){
    wifiList.setPosition(x + padding, y + padding * 3);
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
    text("WIFI SHIELDS", x + padding, y + padding);
    // wifiIPAddress.setString("STATIC");
    wifiIPAddressDyanmic.draw();
    wifiIPAddressStatic.draw();
    wifiIPAddressDyanmic.but_y = y + padding*2 + 16;
    wifiIPAddressStatic.but_y = wifiIPAddressDyanmic.but_y;

    popStyle();

    popOutWifiConfigButton.but_y = y + padding;
    popOutWifiConfigButton.draw();

    if (hub.getWiFiStyle() == WIFI_STATIC) {
      pushStyle();
      fill(bgColor);
      textFont(h3, 16);
      textAlign(LEFT, TOP);
      text("ENTER IP ADDRESS", x + padding, y + h - 24 - 12 - padding*2);
      popStyle();
      cp5.get(Textfield.class, "staticIPAddress").setPosition(x + padding, y + h - 24 - padding);
    } else {
      wifiList.setPosition(x + padding, wifiIPAddressDyanmic.but_y + 24 + padding);

      refreshWifi.draw();
      refreshWifi.but_y = y + h - padding - 24;
      if(isHubInitialized && isHubObjectInitialized && (ganglion.isWifi() || cyton.isWifi()) && hub.isSearching()){
        image(loadingGIF_blue, w + 225,  refreshWifi.but_y + 4, 20, 20);
        refreshWifi.setString("SEARCHING...");
      } else {
        refreshWifi.setString("START SEARCH");

        pushStyle();
        fill(#999999);
        ellipseMode(CENTER);
        ellipse(w + 225 + 10, refreshWifi.but_y + 12, 12, 12);
        popStyle();
      }
    }
  }

  public void refreshWifiList() {
    println("refreshWifiList");
    wifiList.items.clear();
    if (hub.deviceList != null) {
      for (int i = 0; i < hub.deviceList.length; i++) {
        String tempPort = hub.deviceList[i];
        wifiList.addItem(makeItem(tempPort));
      }
    }
    wifiList.updateMenu();
  }
};

class InterfaceBoxCyton {
  int x, y, w, h, padding; //size and position

  InterfaceBoxCyton(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = (24 + _padding) * 3;
    padding = _padding;

    protocolSerialCyton = new Button (x + padding, y + padding * 3, w - padding * 2, 24, "Serial (from Dongle)", fontInfo.buttonLabel_size);
    protocolWifiCyton = new Button (x + padding, y + padding * 4 + 24, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
  }

  public void update() {}

  public void draw() {
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("PICK TRANSFER PROTOCOL", x + padding, y + padding);
    popStyle();

    protocolSerialCyton.draw();
    protocolWifiCyton.draw();
  }
};

class InterfaceBoxGanglion {
  int x, y, w, h, padding; //size and position

  InterfaceBoxGanglion(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = (24 + _padding) * 4; // Fix height for extra button for BLED112
    padding = _padding;

    if (isMac()) {
      protocolBLEGanglion = new Button (x + padding, y + padding * 3, w - padding * 2, 24, "Bluetooth (Built In)", fontInfo.buttonLabel_size);
      protocolBLED112Ganglion = new Button (x + padding, y + padding * 4 + 24, w - padding * 2, 24, "Bluetooth (BLED112 Dongle)", fontInfo.buttonLabel_size);
      protocolWifiGanglion = new Button (x + padding, y + padding * 5 + 48, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
    } else {
      protocolBLEGanglion = new Button (x + padding, y + padding * 3, w - padding * 2, 24, "Bluetooth (CSR Dongle)", fontInfo.buttonLabel_size);
      protocolBLED112Ganglion = new Button (x + padding, y + padding * 4 + 24, w - padding * 2, 24, "Bluetooth (BLED112 Dongle)", fontInfo.buttonLabel_size);
      protocolWifiGanglion = new Button (x + padding, y + padding * 5 + 48, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
    }
  }

  public void update() {}

  public void draw() {
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("PICK TRANSFER PROTOCOL", x + padding, y + padding);
    popStyle();

    protocolBLEGanglion.draw();
    protocolWifiGanglion.draw();
    protocolBLED112Ganglion.draw();
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
    text("File Name", x + padding, y + padding*2 + 14);
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

class DataLogBoxGanglion {
  int x, y, w, h, padding; //size and position
  String fileName;
  //text field for inputing text
  //create/open/closefile button
  String fileStatus;
  boolean isFileOpen; //true if file has been activated and is ready to write to
  //String port status;

  DataLogBoxGanglion(int _x, int _y, int _w, int _h, int _padding) {
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
    autoFileNameGanglion = new Button (x + padding, y + 66, w-(padding*2), 24, "AUTOGENERATE FILE NAME", fontInfo.buttonLabel_size);
    outputODFGanglion = new Button (x + padding, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "OpenBCI", fontInfo.buttonLabel_size);
    if (outputDataSource == OUTPUT_SOURCE_ODF) outputODFGanglion.color_notPressed = isSelected_color; //make it appear like this one is already selected
    outputBDFGanglion = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "BDF+", fontInfo.buttonLabel_size);
    if (outputDataSource == OUTPUT_SOURCE_BDF) outputODFGanglion.color_notPressed = isSelected_color; //make it appear like this one is already selected


    cp5.addTextfield("fileNameGanglion")
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
    text("File Name", x + padding, y + padding*2 + 14);
    popStyle();
    cp5.get(Textfield.class, "fileNameGanglion").setPosition(x + 90, y + 32);
    autoFileNameGanglion.but_y = y + 66;
    autoFileNameGanglion.draw();
    outputODFGanglion.but_y = y + padding*2 + 18 + 58;
    outputODFGanglion.draw();
    outputBDFGanglion.but_y = y + padding*2 + 18 + 58;
    outputBDFGanglion.draw();
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
    text("CHANNEL COUNT ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("  (" + str(nchan) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    chanButton8.draw();
    chanButton8.but_y = y + padding*2 + 18;
    chanButton16.draw();
    chanButton16.but_y = y + padding*2 + 18;
  }
};

class SampleRateGanglionBox {
  int x, y, w, h, padding; //size and position

  boolean isSystemInitialized;
  // button for init/halt system

  SampleRateGanglionBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    sampleRate200 = new Button (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "200Hz", fontInfo.buttonLabel_size);
    sampleRate1600 = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "1600Hz", fontInfo.buttonLabel_size);
    sampleRate1600.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    text("SAMPLE RATE ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("  " + str((int)ganglion.getSampleRate()) + "Hz", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    sampleRate200.draw();
    sampleRate1600.draw();
    sampleRate200.but_y = y + padding*2 + 18;
    sampleRate1600.but_y = sampleRate200.but_y;
  }
};

class SampleRateCytonBox {
  int x, y, w, h, padding; //size and position

  boolean isSystemInitialized;
  // button for init/halt system

  SampleRateCytonBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    sampleRate250 = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "250Hz", fontInfo.buttonLabel_size);
    sampleRate500 = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "500Hz", fontInfo.buttonLabel_size);
    sampleRate1000 = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "1000Hz", fontInfo.buttonLabel_size);
    sampleRate1000.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    text("SAMPLE RATE ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("  " + str((int)cyton.getSampleRate()) + "Hz", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    sampleRate250.draw();
    sampleRate500.draw();
    sampleRate1000.draw();
    sampleRate250.but_y = y + padding*2 + 18;
    sampleRate500.but_y = sampleRate250.but_y;
    sampleRate1000.but_y = sampleRate250.but_y;
  }
};

class LatencyGanglionBox {
  int x, y, w, h, padding; //size and position

  LatencyGanglionBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    latencyGanglion5ms = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "5ms", fontInfo.buttonLabel_size);
    if (hub.getLatency() == LATENCY_5_MS) latencyGanglion5ms.color_notPressed = isSelected_color; //make it appear like this one is already selected
    latencyGanglion10ms = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "10ms", fontInfo.buttonLabel_size);
    if (hub.getLatency() == LATENCY_10_MS) latencyGanglion10ms.color_notPressed = isSelected_color; //make it appear like this one is already selected
    latencyGanglion20ms = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "20ms", fontInfo.buttonLabel_size);
    if (hub.getLatency() == LATENCY_20_MS) latencyGanglion20ms.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    text("LATENCY ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("  " + str(hub.getLatency()/1000) + "ms", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    latencyGanglion5ms.draw();
    latencyGanglion10ms.draw();
    latencyGanglion20ms.draw();
    latencyGanglion5ms.but_y = y + padding*2 + 18;
    latencyGanglion10ms.but_y = latencyGanglion5ms.but_y;
    latencyGanglion20ms.but_y = latencyGanglion5ms.but_y;
  }
};

class LatencyCytonBox {
  int x, y, w, h, padding; //size and position

  LatencyCytonBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    latencyCyton5ms = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "5ms", fontInfo.buttonLabel_size);
    if (hub.getLatency() == LATENCY_5_MS) latencyCyton5ms.color_notPressed = isSelected_color; //make it appear like this one is already selected
    latencyCyton10ms = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "10ms", fontInfo.buttonLabel_size);
    if (hub.getLatency() == LATENCY_10_MS) latencyCyton10ms.color_notPressed = isSelected_color; //make it appear like this one is already selected
    latencyCyton20ms = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "20ms", fontInfo.buttonLabel_size);
    if (hub.getLatency() == LATENCY_20_MS) latencyCyton20ms.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    text("LATENCY ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("  " + str(hub.getLatency()/1000) + "ms", x + padding + 142, y + padding); // print the channel count in green next to the box title
    popStyle();

    latencyCyton5ms.draw();
    latencyCyton10ms.draw();
    latencyCyton20ms.draw();
    latencyCyton5ms.but_y = y + padding*2 + 18;
    latencyCyton10ms.but_y = latencyCyton5ms.but_y;
    latencyCyton20ms.but_y = latencyCyton5ms.but_y;
  }
};

class WifiTransferProtcolGanglionBox {
  int x, y, w, h, padding; //size and position

  WifiTransferProtcolGanglionBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    wifiInternetProtocolGanglionTCP = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "TCP", fontInfo.buttonLabel_size);
    if (hub.getWifiInternetProtocol().equals(TCP)) wifiInternetProtocolGanglionTCP.color_notPressed = isSelected_color; //make it appear like this one is already selected
    wifiInternetProtocolGanglionUDP = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "UDP", fontInfo.buttonLabel_size);
    if (hub.getWifiInternetProtocol().equals(UDP)) wifiInternetProtocolGanglionUDP.color_notPressed = isSelected_color; //make it appear like this one is already selected
    wifiInternetProtocolGanglionUDPBurst = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "UDPx3", fontInfo.buttonLabel_size);
    if (hub.getWifiInternetProtocol().equals(UDP_BURST)) wifiInternetProtocolGanglionUDPBurst.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    text("WiFi Transfer Protocol ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    String dispText;
    if (hub.getWifiInternetProtocol().equals(TCP)) {
      dispText = "TCP";
    } else if (hub.getWifiInternetProtocol().equals(UDP)) {
      dispText = "UDP";
    } else {
      dispText = "UDPx3";
    }
    text(dispText, x + padding + 184, y + padding); // print the channel count in green next to the box title
    popStyle();

    wifiInternetProtocolGanglionTCP.draw();
    wifiInternetProtocolGanglionUDP.draw();
    wifiInternetProtocolGanglionUDPBurst.draw();
    wifiInternetProtocolGanglionTCP.but_y = y + padding*2 + 18;
    wifiInternetProtocolGanglionUDP.but_y = wifiInternetProtocolGanglionTCP.but_y;
    wifiInternetProtocolGanglionUDPBurst.but_y = wifiInternetProtocolGanglionTCP.but_y;
  }
};

class WifiTransferProtcolCytonBox {
  int x, y, w, h, padding; //size and position

  WifiTransferProtcolCytonBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x;
    y = _y;
    w = _w;
    h = 73;
    padding = _padding;

    wifiInternetProtocolCytonTCP = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "TCP", fontInfo.buttonLabel_size);
    if (hub.getWifiInternetProtocol().equals(TCP)) wifiInternetProtocolCytonTCP.color_notPressed = isSelected_color; //make it appear like this one is already selected
    wifiInternetProtocolCytonUDP = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "UDP", fontInfo.buttonLabel_size);
    if (hub.getWifiInternetProtocol().equals(UDP)) wifiInternetProtocolCytonUDP.color_notPressed = isSelected_color; //make it appear like this one is already selected
    wifiInternetProtocolCytonUDPBurst = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "UDPx3", fontInfo.buttonLabel_size);
    if (hub.getWifiInternetProtocol().equals(UDP_BURST)) wifiInternetProtocolCytonUDPBurst.color_notPressed = isSelected_color; //make it appear like this one is already selected
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
    text("WiFi Transfer Protocol ", x + padding, y + padding);
    fill(bgColor); //set color to green
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    String dispText;
    if (hub.getWifiInternetProtocol().equals(TCP)) {
      dispText = "TCP";
    } else if (hub.getWifiInternetProtocol().equals(UDP)) {
      dispText = "UDP";
    } else {
      dispText = "UDPx3";
    }
    text(dispText, x + padding + 184, y + padding); // print the channel count in green next to the box title
    popStyle();

    wifiInternetProtocolCytonTCP.draw();
    wifiInternetProtocolCytonUDP.draw();
    wifiInternetProtocolCytonUDPBurst.draw();
    wifiInternetProtocolCytonTCP.but_y = y + padding*2 + 18;
    wifiInternetProtocolCytonUDP.but_y = wifiInternetProtocolCytonTCP.but_y;
    wifiInternetProtocolCytonUDPBurst.but_y = wifiInternetProtocolCytonTCP.but_y;
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
    text("  (" + str(nchan) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
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
    sdTimes.setPosition(x + padding, y + padding*2 + 13);
    //the drawing of the sdTimes is handled earlier in ControlPanel.draw()

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
    h = 255;
    padding = _padding;
    isShowing = false;

    getChannel = new Button(x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "GET CHANNEL", fontInfo.buttonLabel_size);
    systemStatus = new Button(x + 2*padding + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "STATUS", fontInfo.buttonLabel_size);
    setChannel = new Button(x + padding, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "CHANGE CHAN.", fontInfo.buttonLabel_size);
    autoscan = new Button(x + 2*padding + (w-padding*3)/2, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "AUTOSCAN", fontInfo.buttonLabel_size);
    ovrChannel = new Button(x + padding, y + padding*4 + 18 + 24*2, w-(padding*2), 24, "OVERRIDE DONGLE", fontInfo.buttonLabel_size);

    //Set help text
    getChannel.setHelpText("Get the current channel of your Cyton and USB Dongle");
    setChannel.setHelpText("Change the channel of your Cyton and USB Dongle");
    ovrChannel.setHelpText("Change the channel of the USB Dongle only");
    autoscan.setHelpText("Scan through channels and connect to a nearby Cyton");
    systemStatus.setHelpText("Get the connection status of your Cyton system");
  }
  public void update() {}

  public void draw() {
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("RADIO CONFIGURATION", x + padding, y + padding);
    popStyle();
    getChannel.draw();
    setChannel.draw();
    ovrChannel.draw();
    systemStatus.draw();
    autoscan.draw();

    this.print_onscreen(last_message);
  }

  public void print_onscreen(String localstring){
    textAlign(LEFT);
    fill(bgColor);
    rect(x + padding, y + (padding*8) + 13 + (24*2), w-(padding*2), 135 - 21 - padding);
    fill(255);
    text(localstring, x + padding + 10, y + (padding*8) + 5 + (24*2) + 15, (w-padding*3 ), 135 - 24 - padding -15);
    this.last_message = localstring;
  }

  public void print_lastmessage(){
    fill(bgColor);
    rect(x + padding, y + (padding*8) + 13 + (24*2), w-(padding*2), 135 - 21 - padding);
    fill(255);
    text(this.last_message, 180, 340, 240, 60);
  }
};

class WifiConfigBox {
  int x, y, w, h, padding; //size and position
  String last_message = "";
  Serial board;
  boolean isShowing;

  WifiConfigBox(int _x, int _y, int _w, int _h, int _padding) {
    x = _x + _w;
    y = _y;
    w = _w;
    h = 255;
    padding = _padding;
    isShowing = false;

    getTypeOfAttachedBoard = new Button(x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "OPENBCI BOARD", fontInfo.buttonLabel_size);
    getIpAddress = new Button(x + 2*padding + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "IP ADDRESS", fontInfo.buttonLabel_size);
    // getIpAddress = new Button(x + w -padding*2)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "IP ADDRESS", fontInfo.buttonLabel_size);
    getMacAddress = new Button(x + padding, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "MAC ADDRESS", fontInfo.buttonLabel_size);
    getFirmwareVersion = new Button(x + 2*padding + (w-padding*3)/2, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "FIRMWARE VERS.", fontInfo.buttonLabel_size);
    eraseCredentials = new Button(x + padding, y + padding*4 + 18 + 24*2, w-(padding*2), 24, "ERASE NETWORK CREDENTIALS", fontInfo.buttonLabel_size);

    //y + padding*4 + 18 + 24*2

    //Set help text
    getTypeOfAttachedBoard.setHelpText("Get the type of OpenBCI board attached to the WiFi Shield");
    getIpAddress.setHelpText("Get the IP Address of the WiFi shield");
    getMacAddress.setHelpText("Get the MAC Address of the WiFi shield");
    getFirmwareVersion.setHelpText("Get the firmware version of the WiFi Shield");
    eraseCredentials.setHelpText("Erase the store credentials on the WiFi Shield to join another wireless network. Always remove WiFi Shield from OpenBCI board prior to erase and WiFi Shield will become a hotspot again.");
  }
  public void update() {}

  public void draw() {
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("WIFI CONFIGURATION", x + padding, y + padding);
    popStyle();
    getTypeOfAttachedBoard.draw();
    getIpAddress.draw();
    getMacAddress.draw();
    getFirmwareVersion.draw();
    eraseCredentials.draw();

    this.print_onscreen(last_message);
  }

  public void updateMessage(String str) {
    last_message = str;
  }

  public void print_onscreen(String localstring){
    textAlign(LEFT);
    fill(bgColor);
    rect(x + padding, y + (padding*8) + 13 + (24*2), w-(padding*2), 135 - 21 - padding);
    fill(255);
    text(localstring, x + padding + 10, y + (padding*8) + 5 + (24*2) + 15, (w-padding*3 ), 135 - 24 - padding -15);
    // this.last_message = localstring;


    // textAlign(LEFT);
    // fill(0);
    // rect(x + padding, y + (padding*8) + 18 + (24*2), (w-padding*3 + 5), 135 - 24 - padding);
    // fill(255);
    // text(localstring, x + padding + 10, y + (padding*8) + 18 + (24*2) + 15, (w-padding*3 ), 135 - 24 - padding -15);
  }

  public void print_lastmessage(){

    fill(bgColor);
    rect(x + padding, y + (padding*8) + 13 + (24*2), w-(padding*2), 135 - 21 - padding);
    fill(255);

    // fill(0);
    // rect(x + padding, y + (padding*7) + 18 + (24*5), (w-padding*3 + 5), 135);
    // fill(255);
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
    // autoconnect.draw();
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
    // autoconnect.draw();
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
    getValueLabel().setSize(14);
    getCaptionLabel().setSize(14);

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
