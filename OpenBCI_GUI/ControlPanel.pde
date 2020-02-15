//////////////////////////////////////////////////////////////////////////
//
//    System Control Panel
//    - Select serial port from dropdown
//        - Select default configuration (EEG, EKG, EMG)
//        - Select Electrode Count (8 vs 16)
//        - Select data mode (synthetic, playback file, real-time)
//        - Record data? (y/n)
//            - select output location
//        - link to help guide
//        - buttons to start/stop/reset application
//
//        Written by: Conor Russomanno (Oct. 2014)
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

        if (cp5.isMouseOver(cp5.get(Textfield.class, "fileNameCyton"))){
            println("CallbackListener: controlEvent: clearing cyton");
            cp5.get(Textfield.class, "fileNameCyton").clear();
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
color colorNotPressed = color(255);

Button refreshPort;
Button refreshBLE;
Button refreshWifi;
Button protocolSerialCyton;
Button protocolWifiCyton;
Button protocolWifiGanglion;
Button protocolBLED112Ganglion;
Button protocolBLEGanglion;

Button initSystemButton;
Button autoSessionName; // Reuse these buttons for Cyton and Ganglion
Button outputBDF;
Button outputODF;

Button sampleDataButton; // Used to easily find GUI sample data for Playback mode #645

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
Button autoscan;
Button systemStatus;

Button eraseCredentials;
Button getIpAddress;
Button getFirmwareVersion;
Button getMacAddress;
Button getTypeOfAttachedBoard;
Button sampleRate200; //Ganglion
Button sampleRate250;
Button sampleRate500;
Button sampleRate1000;
Button sampleRate1600; //Ganglion
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
Button wifiIPAddressDynamic;
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
        settings.controlEventDataSource = str; //Used for output message on system start
        int newDataSource = int(theEvent.getValue());

        eegDataSource = newDataSource; // reset global eegDataSource to the selected value from the list

        // this button only used on mac
        if(isMac()) {
            protocolBLEGanglion.setColorNotPressed(colorNotPressed);
        }
        protocolWifiGanglion.setColorNotPressed(colorNotPressed);
        protocolBLED112Ganglion.setColorNotPressed(colorNotPressed);
        protocolWifiCyton.setColorNotPressed(colorNotPressed);
        protocolSerialCyton.setColorNotPressed(colorNotPressed);

        selectedProtocol = BoardProtocol.NONE;
        controlPanel.novaXRBox.isShowing = false;

        if(newDataSource == DATASOURCE_CYTON){
            updateToNChan(8);
            chanButton8.setColorNotPressed(isSelected_color);
            chanButton16.setColorNotPressed(colorNotPressed); //default color of button
            latencyCyton5ms.setColorNotPressed(colorNotPressed);
            latencyCyton10ms.setColorNotPressed(isSelected_color);
            latencyCyton20ms.setColorNotPressed(colorNotPressed);
            hub.setLatency(LATENCY_10_MS);
            wifiInternetProtocolCytonTCP.setColorNotPressed(colorNotPressed);
            wifiInternetProtocolCytonUDP.setColorNotPressed(colorNotPressed);
            wifiInternetProtocolCytonUDPBurst.setColorNotPressed(isSelected_color);
            hub.setWifiInternetProtocol(UDP_BURST);
            hub.setWiFiStyle(WIFI_DYNAMIC);
            wifiIPAddressDynamic.setColorNotPressed(isSelected_color);
            wifiIPAddressStatic.setColorNotPressed(colorNotPressed);
        } else if(newDataSource == DATASOURCE_GANGLION){
            updateToNChan(4);
            latencyGanglion5ms.setColorNotPressed(colorNotPressed);
            latencyGanglion10ms.setColorNotPressed(isSelected_color);
            latencyGanglion20ms.setColorNotPressed(colorNotPressed);
            hub.setLatency(LATENCY_10_MS);
            wifiInternetProtocolGanglionTCP.setColorNotPressed(isSelected_color);
            wifiInternetProtocolGanglionUDP.setColorNotPressed(colorNotPressed);
            wifiInternetProtocolGanglionUDPBurst.setColorNotPressed(colorNotPressed);
            hub.setWifiInternetProtocol(TCP);
            hub.setWiFiStyle(WIFI_DYNAMIC);
            wifiIPAddressDynamic.setColorNotPressed(isSelected_color);
            wifiIPAddressStatic.setColorNotPressed(colorNotPressed);
        } else if(newDataSource == DATASOURCE_PLAYBACKFILE){
            //GUI auto detects number of channels for playback when file is selected
        } else if(newDataSource == DATASOURCE_SYNTHETIC){
            synthChanButton4.setColorNotPressed(colorNotPressed);
            synthChanButton8.setColorNotPressed(isSelected_color);
            synthChanButton16.setColorNotPressed(colorNotPressed);
        } else if (newDataSource == DATASOURCE_NOVAXR) {
            controlPanel.novaXRBox.isShowing = true;
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

    if (theEvent.isFrom("channelListCP")) {
        int setChannelInt = int(theEvent.getValue()) + 1;
        //Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
        cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
        channelPopup.setClicked(false);
        if (setChannel.wasPressed) {
            set_channel(rcBox, setChannelInt);
            setChannel.wasPressed = false;
        } else if(ovrChannel.wasPressed) {
            set_channel_over(rcBox, setChannelInt);
            ovrChannel.wasPressed = false;
        }
    }

    //Check for event in PlaybackHistory Dropdown List in Control Panel
    if (theEvent.isFrom("recentFiles")) {
        int s = (int)(theEvent.getController()).getValue();
        //println("got a menu event from item " + s);
        String filePath = controlPanel.recentPlaybackBox.longFilePaths.get(s);
        if (new File(filePath).isFile()) {
            playbackFileSelected(filePath, s);
        } else {
            outputError("Playback History: Selected file does not exist. Try another file or clear settings to remove this entry.");
        }
    }

    //Check control events from widgets
    if (systemMode >= SYSTEMMODE_POSTINIT) {
        //Check for event in PlaybackHistory Widget MenuList
        if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            if(theEvent.isFrom("playbackMenuList")) {
                //Check to make sure value of clicked item is in valid range. Fixes #480
                float valueOfItem = theEvent.getValue();
                if (valueOfItem < 0 || valueOfItem > (((MenuList)theEvent.getController()).items.size() - 1) ) {
                    //println("CP: No such item " + value + " found in list.");
                } else {
                    Map m = ((MenuList)theEvent.getController()).getItem(int(valueOfItem));
                    //println("got a menu event from item " + value + " : " + m);
                    userSelectedPlaybackMenuList(m.get("copy").toString(), int(valueOfItem));
                }
            }
        }
        //Check for event in band power channel select checkBoxes, if needed
        /*
        if (theEvent.isFrom(w_bandPower.bpChanSelect.checkList)) {
            println(w_bandPower.bpChanSelect.checkList.getArrayValue());
        }
        */
    }
}

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

class ControlPanel {

    public int x, y, w, h;
    public boolean isOpen;

    PlotFontInfo fontInfo;

    //various control panel elements that are unique to specific datasources
    DataSourceBox dataSourceBox;
    SerialBox serialBox;
    ComPortBox comPortBox;
    SessionDataBox dataLogBoxCyton;
    ChannelCountBox channelCountBox;
    InitBox initBox;
    SyntheticChannelCountBox synthChannelCountBox;
    RecentPlaybackBox recentPlaybackBox;
    PlaybackFileBox playbackFileBox;
    NovaXRBox novaXRBox;
    SDConverterBox sdConverterBox;
    BLEBox bleBox;
    SessionDataBox dataLogBoxGanglion;
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
    boolean convertingSD = false;
    String bdfMessage = "Output has been set to BioSemi Data Format (BDF+).";

    ControlPanel(OpenBCI_GUI mainClass) {

        x = 3;
        y = 3 + topNav.controlPanelCollapser.but_dy;
        w = topNav.controlPanelCollapser.but_dx;
        h = height - int(helpWidget.h);

        isOpen = false;
        fontInfo = new PlotFontInfo();

        globalPadding = 10;  //controls the padding of all elements on the control panel

        cp5 = new ControlP5(mainClass);
        cp5Popup = new ControlP5(mainClass);
        cp5.setAutoDraw(false);
        cp5Popup.setAutoDraw(false);

        //boxes active when eegDataSource = Normal (OpenBCI)
        dataSourceBox = new DataSourceBox(x, y, w, h, globalPadding);
        interfaceBoxCyton = new InterfaceBoxCyton(x + w, dataSourceBox.y, w, h, globalPadding);
        interfaceBoxGanglion = new InterfaceBoxGanglion(x + w, dataSourceBox.y, w, h, globalPadding);

        serialBox = new SerialBox(x + w, interfaceBoxCyton.y + interfaceBoxCyton.h, w, h, globalPadding);
        wifiBox = new WifiBox(x + w, interfaceBoxCyton.y + interfaceBoxCyton.h, w, h, globalPadding);

        dataLogBoxCyton = new SessionDataBox(x + w, (serialBox.y + serialBox.h), w, h, globalPadding, DATASOURCE_CYTON);
        channelCountBox = new ChannelCountBox(x + w, (dataLogBoxCyton.y + dataLogBoxCyton.h), w, h, globalPadding);
        synthChannelCountBox = new SyntheticChannelCountBox(x + w, dataSourceBox.y, w, h, globalPadding);
        sdBox = new SDBox(x + w, (channelCountBox.y + channelCountBox.h), w, h, globalPadding);
        sampleRateCytonBox = new SampleRateCytonBox(x + w + x + w - 3, channelCountBox.y, w, h, globalPadding);
        latencyCytonBox = new LatencyCytonBox(x + w + x + w - 3, (sampleRateCytonBox.y + sampleRateCytonBox.h), w, h, globalPadding);
        wifiTransferProtcolCytonBox = new WifiTransferProtcolCytonBox(x + w + x + w - 3, (latencyCytonBox.y + latencyCytonBox.h), w, h, globalPadding);

        //boxes active when eegDataSource = Playback
        int playbackWidth = int(w * 1.35);
        playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, playbackWidth, h, globalPadding);
        sdConverterBox = new SDConverterBox(x + w, (playbackFileBox.y + playbackFileBox.h), playbackWidth, h, globalPadding);
        recentPlaybackBox = new RecentPlaybackBox(x + w, (sdConverterBox.y + sdConverterBox.h), playbackWidth, h, globalPadding);

        novaXRBox = new NovaXRBox(x + w, dataSourceBox.y, w, h, globalPadding);
        
        comPortBox = new ComPortBox(x+w*2, y, w, h, globalPadding);
        rcBox = new RadioConfigBox(x+w, y + comPortBox.h, w, h, globalPadding);
        channelPopup = new ChannelPopup(x+w, y, w, h, globalPadding);
        pollPopup = new PollPopup(x+w,y,w,h,globalPadding);

        wcBox = new WifiConfigBox(x+w, y, w, h, globalPadding);

        initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);

        // Ganglion
        bleBox = new BLEBox(x + w, interfaceBoxGanglion.y + interfaceBoxGanglion.h, w, h, globalPadding);
        dataLogBoxGanglion = new SessionDataBox(x + w, (bleBox.y + bleBox.h), w, h, globalPadding, DATASOURCE_GANGLION);
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
        dataLogBoxCyton.update();
        channelCountBox.update();
        synthChannelCountBox.update();

        //update playback box sizes when dropdown is selected
        recentPlaybackBox.update();
        playbackFileBox.update();
        sdConverterBox.update();

        novaXRBox.update();

        sdBox.update();
        rcBox.update();
        comPortBox.update();
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
    }

    public void draw() {

        pushStyle();

        noStroke();

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
                if (selectedProtocol == BoardProtocol.NONE) {
                    interfaceBoxCyton.draw();
                } else {
                    interfaceBoxCyton.draw();
                    if (selectedProtocol == BoardProtocol.SERIAL) {
                        serialBox.y = interfaceBoxCyton.y + interfaceBoxCyton.h;
                        serialBox.draw();
                        dataLogBoxCyton.y = serialBox.y + serialBox.h; 
                        if (rcBox.isShowing) {
                            comPortBox.draw();
                            rcBox.draw();
                            cp5.get(MenuList.class, "serialList").setVisible(true);
                            if (channelPopup.wasClicked()) {
                                channelPopup.draw();
                                cp5Popup.get(MenuList.class, "channelListCP").setVisible(true);
                                cp5Popup.get(MenuList.class, "pollList").setVisible(false);
                                cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
                                //cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
                            } else if (pollPopup.wasClicked()) {
                                pollPopup.draw();
                                cp5Popup.get(MenuList.class, "pollList").setVisible(true);
                                cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
                                cp5.get(Textfield.class, "fileNameCyton").setVisible(true); //make sure the data file field is visible
                                // cp5.get(Textfield.class, "fileNameGanglion").setVisible(true); //make sure the data file field is visible
                                cp5.get(MenuList.class, "serialList").setVisible(true); //make sure the serialList menulist is visible
                                //cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
                                cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
                            }
                        }
                    } else if (selectedProtocol == BoardProtocol.WIFI) {
                        wifiBox.y = interfaceBoxCyton.y + interfaceBoxCyton.h;

                        wifiBox.draw();
                        dataLogBoxCyton.y = wifiBox.y + wifiBox.h;

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
                    channelCountBox.y = dataLogBoxCyton.y + dataLogBoxCyton.h;
                    sdBox.y = channelCountBox.y + channelCountBox.h;
                    sampleRateCytonBox.y = channelCountBox.y;
                    latencyCytonBox.y = sampleRateCytonBox.y + sampleRateCytonBox.h;
                    wifiTransferProtcolCytonBox.y = latencyCytonBox.y + latencyCytonBox.h;
                    channelCountBox.draw();
                    sdBox.draw();
                    cp5.get(Textfield.class, "fileNameCyton").setVisible(true); //make sure the data file field is visible
                    cp5.get(Textfield.class, "fileNameGanglion").setVisible(false); //make sure the data file field is not visible
                    //cp5.get(MenuList.class, "sdTimes").setVisible(true); //make sure the SD time record options menulist is visible
                    dataLogBoxCyton.draw(); //Drawing here allows max file size dropdown to be drawn on top
                }
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) { //when data source is from playback file
                recentPlaybackBox.draw();
                playbackFileBox.draw();
                sdConverterBox.draw();

                //set other CP5 controllers invisible
                // cp5.get(Textfield.class, "fileNameCyton").setVisible(false); //make sure the data file field is visible
                // cp5.get(Textfield.class, "fileNameGanglion").setVisible(false); //make sure the data file field is visible
                cp5.get(MenuList.class, "serialList").setVisible(false);
                //cp5.get(MenuList.class, "sdTimes").setVisible(false);
                cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
                cp5Popup.get(MenuList.class, "pollList").setVisible(false);

            } else if (eegDataSource == DATASOURCE_NOVAXR) {
                novaXRBox.draw();
            } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  //synthetic
                synthChannelCountBox.draw();
            } else if (eegDataSource == DATASOURCE_GANGLION) {
                if (selectedProtocol == BoardProtocol.NONE) {
                    interfaceBoxGanglion.draw();
                } else {
                    interfaceBoxGanglion.draw();
                    if (selectedProtocol == BoardProtocol.BLE || selectedProtocol == BoardProtocol.BLED112) {
                        bleBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
                        dataLogBoxGanglion.y = bleBox.y + bleBox.h;
                        bleBox.draw();
                        cp5.get(MenuList.class, "bleList").setVisible(true);
                        cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
                    } else if (selectedProtocol == BoardProtocol.WIFI) {
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
                    dataLogBoxGanglion.draw(); //Drawing here allows max file size dropdown to be drawn on top
                    cp5.get(Textfield.class, "fileNameCyton").setVisible(false); //make sure the data file field is visible
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
            String stopInstructions = "Press the \"STOP SESSION\" button to change your data source or edit system settings.";
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

        //Drawing here allows max file size dropdown to be drawn on top of all other cp5 elements
        if (systemMode != 10 && outputDataSource == OUTPUT_SOURCE_ODF) {
            if (eegDataSource == DATASOURCE_CYTON && selectedProtocol != BoardProtocol.NONE) {
                dataLogBoxCyton.cp5_dataLog_dropdown.draw();
            } else if (eegDataSource == DATASOURCE_GANGLION && selectedProtocol != BoardProtocol.NONE) {
                dataLogBoxGanglion.cp5_dataLog_dropdown.draw();
            }
        }

        popStyle();
    }

    public void hideRadioPopoutBox() {
        rcBox.isShowing = false;
        comPortBox.isShowing = false;
        cp5Popup.hide(); // make sure to hide the controlP5 object
        cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
        cp5Popup.get(MenuList.class, "pollList").setVisible(false);
        cp5.get(MenuList.class, "serialList").setVisible(false);
        // cp5Popup.hide(); // make sure to hide the controlP5 object
        popOutRadioConfigButton.setString("Manual >");
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
        cp5.get(Textfield.class, "fileNameCyton").setVisible(false);
        cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
        cp5.get(Textfield.class, "fileNameGanglion").setVisible(false);
        cp5.get(MenuList.class, "serialList").setVisible(false);
        cp5.get(MenuList.class, "bleList").setVisible(false);
        //cp5.get(MenuList.class, "sdTimes").setVisible(false);
        cp5.get(MenuList.class, "wifiList").setVisible(false);
        cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
        cp5Popup.get(MenuList.class, "pollList").setVisible(false);
    }

    private void hideChannelListCP() {
        cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
        channelPopup.setClicked(false);
        if (setChannel.wasPressed) {
            setChannel.wasPressed = false;
        } else if(ovrChannel.wasPressed) {
            ovrChannel.wasPressed = false;
        }
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

            if ((eegDataSource == DATASOURCE_CYTON || eegDataSource == DATASOURCE_GANGLION) && selectedProtocol == BoardProtocol.WIFI) {
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

                if(wifiIPAddressDynamic.isMouseHere()) {
                    wifiIPAddressDynamic.setIsActive(true);
                    wifiIPAddressDynamic.wasPressed = true;
                    wifiIPAddressDynamic.setColorNotPressed(isSelected_color);
                    wifiIPAddressStatic.setColorNotPressed(colorNotPressed);
                }

                if(wifiIPAddressStatic.isMouseHere()) {
                    wifiIPAddressStatic.setIsActive(true);
                    wifiIPAddressStatic.wasPressed = true;
                    wifiIPAddressStatic.setColorNotPressed(isSelected_color);
                    wifiIPAddressDynamic.setColorNotPressed(colorNotPressed);
                }
            }

            //active buttons during DATASOURCE_CYTON
            else if (eegDataSource == DATASOURCE_CYTON) {
                
                if (selectedProtocol == BoardProtocol.SERIAL) {
                    if (popOutRadioConfigButton.isMouseHere()){
                        popOutRadioConfigButton.setIsActive(true);
                        popOutRadioConfigButton.wasPressed = true;
                    }
                    if (refreshPort.isMouseHere()) {
                        refreshPort.setIsActive(true);
                        refreshPort.wasPressed = true;
                    }
                    if (serialBox.autoConnect.isMouseHere()) {
                        serialBox.autoConnect.setIsActive(true);
                        serialBox.autoConnect.wasPressed = true;
                    }
                }

                if (selectedProtocol == BoardProtocol.WIFI) {
                    if (refreshWifi.isMouseHere()) {
                        refreshWifi.setIsActive(true);
                        refreshWifi.wasPressed = true;
                    }
                }


                if (autoSessionName.isMouseHere()) {
                    autoSessionName.setIsActive(true);
                    autoSessionName.wasPressed = true;
                }

                if (outputODF.isMouseHere()) {
                    outputODF.setIsActive(true);
                    outputODF.wasPressed = true;
                }

                if (outputBDF.isMouseHere()) {
                    outputBDF.setIsActive(true);
                    outputBDF.wasPressed = true;
                }

                if (chanButton8.isMouseHere()) {
                    chanButton8.setIsActive(true);
                    chanButton8.wasPressed = true;
                    chanButton8.setColorNotPressed(isSelected_color);
                    chanButton16.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (chanButton16.isMouseHere()) {
                    chanButton16.setIsActive(true);
                    chanButton16.wasPressed = true;
                    chanButton8.setColorNotPressed(colorNotPressed); //default color of button
                    chanButton16.setColorNotPressed(isSelected_color);
                }

                if (getChannel.isMouseHere()){
                    getChannel.setIsActive(true);
                    getChannel.wasPressed = true;
                }

                if (setChannel.isMouseHere()){
                    setChannel.setIsActive(true);
                    setChannel.wasPressed = true;
                    ovrChannel.wasPressed = false;
                }

                if (ovrChannel.isMouseHere()){
                    ovrChannel.setIsActive(true);
                    ovrChannel.wasPressed = true;
                    setChannel.wasPressed = false;
                }



                if (protocolWifiCyton.isMouseHere()) {
                    protocolWifiCyton.setIsActive(true);
                    protocolWifiCyton.wasPressed = true;
                    protocolWifiCyton.setColorNotPressed(isSelected_color);
                    protocolSerialCyton.setColorNotPressed(colorNotPressed);
                }

                if (protocolSerialCyton.isMouseHere()) {
                    protocolSerialCyton.setIsActive(true);
                    protocolSerialCyton.wasPressed = true;
                    protocolWifiCyton.setColorNotPressed(colorNotPressed);
                    protocolSerialCyton.setColorNotPressed(isSelected_color);
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
                    sampleRate250.setColorNotPressed(isSelected_color);
                    sampleRate500.setColorNotPressed(colorNotPressed);
                    sampleRate1000.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (sampleRate500.isMouseHere()) {
                    sampleRate500.setIsActive(true);
                    sampleRate500.wasPressed = true;
                    sampleRate500.setColorNotPressed(isSelected_color);
                    sampleRate250.setColorNotPressed(colorNotPressed);
                    sampleRate1000.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (sampleRate1000.isMouseHere()) {
                    sampleRate1000.setIsActive(true);
                    sampleRate1000.wasPressed = true;
                    sampleRate1000.setColorNotPressed(isSelected_color);
                    sampleRate250.setColorNotPressed(colorNotPressed); //default color of button
                    sampleRate500.setColorNotPressed(colorNotPressed);
                }

                if (latencyCyton5ms.isMouseHere()) {
                    latencyCyton5ms.setIsActive(true);
                    latencyCyton5ms.wasPressed = true;
                    latencyCyton5ms.setColorNotPressed(isSelected_color);
                    latencyCyton10ms.setColorNotPressed(colorNotPressed); //default color of button
                    latencyCyton20ms.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (latencyCyton10ms.isMouseHere()) {
                    latencyCyton10ms.setIsActive(true);
                    latencyCyton10ms.wasPressed = true;
                    latencyCyton10ms.setColorNotPressed(isSelected_color);
                    latencyCyton5ms.setColorNotPressed(colorNotPressed); //default color of button
                    latencyCyton20ms.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (latencyCyton20ms.isMouseHere()) {
                    latencyCyton20ms.setIsActive(true);
                    latencyCyton20ms.wasPressed = true;
                    latencyCyton20ms.setColorNotPressed(isSelected_color);
                    latencyCyton5ms.setColorNotPressed(colorNotPressed); //default color of button
                    latencyCyton10ms.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (wifiInternetProtocolCytonTCP.isMouseHere()) {
                    wifiInternetProtocolCytonTCP.setIsActive(true);
                    wifiInternetProtocolCytonTCP.wasPressed = true;
                    wifiInternetProtocolCytonTCP.setColorNotPressed(isSelected_color);
                    wifiInternetProtocolCytonUDP.setColorNotPressed(colorNotPressed); //default color of button
                    wifiInternetProtocolCytonUDPBurst.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (wifiInternetProtocolCytonUDP.isMouseHere()) {
                    wifiInternetProtocolCytonUDP.setIsActive(true);
                    wifiInternetProtocolCytonUDP.wasPressed = true;
                    wifiInternetProtocolCytonUDP.setColorNotPressed(isSelected_color);
                    wifiInternetProtocolCytonTCP.setColorNotPressed(colorNotPressed); //default color of button
                    wifiInternetProtocolCytonUDPBurst.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (wifiInternetProtocolCytonUDPBurst.isMouseHere()) {
                    wifiInternetProtocolCytonUDPBurst.setIsActive(true);
                    wifiInternetProtocolCytonUDPBurst.wasPressed = true;
                    wifiInternetProtocolCytonUDPBurst.setColorNotPressed(isSelected_color);
                    wifiInternetProtocolCytonTCP.setColorNotPressed(colorNotPressed); //default color of button
                    wifiInternetProtocolCytonUDP.setColorNotPressed(colorNotPressed); //default color of button
                }
            }

            else if (eegDataSource == DATASOURCE_GANGLION) {

                // This is where we check for button presses if we are searching for BLE devices
                if (autoSessionName.isMouseHere()) {
                    autoSessionName.setIsActive(true);
                    autoSessionName.wasPressed = true;
                }

                if (outputODF.isMouseHere()) {
                    outputODF.setIsActive(true);
                    outputODF.wasPressed = true;
                }

                if (outputBDF.isMouseHere()) {
                    outputBDF.setIsActive(true);
                    outputBDF.wasPressed = true;
                }

                if (selectedProtocol == BoardProtocol.WIFI) {
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

                // this button only used on mac
                if (isMac() && protocolBLEGanglion.isMouseHere()) {
                    protocolBLEGanglion.setIsActive(true);
                    protocolBLEGanglion.wasPressed = true;
                    protocolBLED112Ganglion.setColorNotPressed(colorNotPressed);
                    protocolBLEGanglion.setColorNotPressed(isSelected_color);
                    protocolWifiGanglion.setColorNotPressed(colorNotPressed);
                }

                if (protocolWifiGanglion.isMouseHere()) {
                    protocolWifiGanglion.setIsActive(true);
                    protocolWifiGanglion.wasPressed = true;
                    protocolBLED112Ganglion.setColorNotPressed(colorNotPressed);
                    protocolWifiGanglion.setColorNotPressed(isSelected_color);
                    if(isMac()) {
                        protocolBLEGanglion.setColorNotPressed(colorNotPressed);
                    }
                }

                if (protocolBLED112Ganglion.isMouseHere()) {
                    protocolBLED112Ganglion.setIsActive(true);
                    protocolBLED112Ganglion.wasPressed = true;
                    if(isMac()) {
                        protocolBLEGanglion.setColorNotPressed(colorNotPressed);
                    }
                    protocolBLED112Ganglion.setColorNotPressed(isSelected_color);
                    protocolWifiGanglion.setColorNotPressed(colorNotPressed);
                }

                if (sampleRate200.isMouseHere()) {
                    sampleRate200.setIsActive(true);
                    sampleRate200.wasPressed = true;
                    sampleRate200.setColorNotPressed(isSelected_color);
                    sampleRate1600.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (sampleRate1600.isMouseHere()) {
                    sampleRate1600.setIsActive(true);
                    sampleRate1600.wasPressed = true;
                    sampleRate1600.setColorNotPressed(isSelected_color);
                    sampleRate200.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (latencyGanglion5ms.isMouseHere()) {
                    latencyGanglion5ms.setIsActive(true);
                    latencyGanglion5ms.wasPressed = true;
                    latencyGanglion5ms.setColorNotPressed(isSelected_color);
                    latencyGanglion10ms.setColorNotPressed(colorNotPressed); //default color of button
                    latencyGanglion20ms.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (latencyGanglion10ms.isMouseHere()) {
                    latencyGanglion10ms.setIsActive(true);
                    latencyGanglion10ms.wasPressed = true;
                    latencyGanglion10ms.setColorNotPressed(isSelected_color);
                    latencyGanglion5ms.setColorNotPressed(colorNotPressed); //default color of button
                    latencyGanglion20ms.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (latencyGanglion20ms.isMouseHere()) {
                    latencyGanglion20ms.setIsActive(true);
                    latencyGanglion20ms.wasPressed = true;
                    latencyGanglion20ms.setColorNotPressed(isSelected_color);
                    latencyGanglion5ms.setColorNotPressed(colorNotPressed); //default color of button
                    latencyGanglion10ms.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (wifiInternetProtocolGanglionTCP.isMouseHere()) {
                    wifiInternetProtocolGanglionTCP.setIsActive(true);
                    wifiInternetProtocolGanglionTCP.wasPressed = true;
                    wifiInternetProtocolGanglionTCP.setColorNotPressed(isSelected_color);
                    wifiInternetProtocolGanglionUDP.setColorNotPressed(colorNotPressed); //default color of button
                    wifiInternetProtocolGanglionUDPBurst.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (wifiInternetProtocolGanglionUDP.isMouseHere()) {
                    wifiInternetProtocolGanglionUDP.setIsActive(true);
                    wifiInternetProtocolGanglionUDP.wasPressed = true;
                    wifiInternetProtocolGanglionUDP.setColorNotPressed(isSelected_color);
                    wifiInternetProtocolGanglionTCP.setColorNotPressed(colorNotPressed); //default color of button
                    wifiInternetProtocolGanglionUDPBurst.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (wifiInternetProtocolGanglionUDPBurst.isMouseHere()) {
                    wifiInternetProtocolGanglionUDPBurst.setIsActive(true);
                    wifiInternetProtocolGanglionUDPBurst.wasPressed = true;
                    wifiInternetProtocolGanglionUDPBurst.setColorNotPressed(isSelected_color);
                    wifiInternetProtocolGanglionTCP.setColorNotPressed(colorNotPressed); //default color of button
                    wifiInternetProtocolGanglionUDP.setColorNotPressed(colorNotPressed); //default color of button
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
                if (sampleDataButton.isMouseHere()) {
                    sampleDataButton.setIsActive(true);
                    sampleDataButton.wasPressed = true;
                }
            }

            //active buttons during DATASOURCE_SYNTHETIC
            if (eegDataSource == DATASOURCE_SYNTHETIC) {
                if (synthChanButton4.isMouseHere()) {
                    synthChanButton4.setIsActive(true);
                    synthChanButton4.wasPressed = true;
                    synthChanButton4.setColorNotPressed(isSelected_color);
                    synthChanButton8.setColorNotPressed(colorNotPressed); //default color of button
                    synthChanButton16.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (synthChanButton8.isMouseHere()) {
                    synthChanButton8.setIsActive(true);
                    synthChanButton8.wasPressed = true;
                    synthChanButton8.setColorNotPressed(isSelected_color);
                    synthChanButton4.setColorNotPressed(colorNotPressed); //default color of button
                    synthChanButton16.setColorNotPressed(colorNotPressed); //default color of button
                }

                if (synthChanButton16.isMouseHere()) {
                    synthChanButton16.setIsActive(true);
                    synthChanButton16.wasPressed = true;
                    synthChanButton16.setColorNotPressed(isSelected_color);
                    synthChanButton4.setColorNotPressed(colorNotPressed); //default color of button
                    synthChanButton8.setColorNotPressed(colorNotPressed); //default color of button
                }
            }

        }
        // output("Text File Name: " + cp5.get(Textfield.class,"fileNameCyton").getText());
    }

    //mouse released in control panel
    public void CPmouseReleased() {
        //verbosePrint("CPMouseReleased: CPmouseReleased start...");
        if (popOutRadioConfigButton.isMouseHere() && popOutRadioConfigButton.wasPressed) {
            popOutRadioConfigButton.wasPressed = false;
            popOutRadioConfigButton.setIsActive(false);
            if (selectedProtocol == BoardProtocol.SERIAL) {
                if (rcBox.isShowing) {
                    hideRadioPopoutBox();
                    serialBox.autoConnect.setIgnoreHover(false);
                    serialBox.autoConnect.setColorNotPressed(255);
                } else {
                    rcBox.isShowing = true;
                    rcBox.print_onscreen(rcBox.initial_message);
                    popOutRadioConfigButton.setString("Manual <");
                    serialBox.autoConnect.setIgnoreHover(true);
                    serialBox.autoConnect.setColorNotPressed(140);
                }
            }
        }

        if (serialBox.autoConnect.isMouseHere() && serialBox.autoConnect.wasPressed) {
            serialBox.autoConnect.wasPressed = false;
            serialBox.autoConnect.setIsActive(false);
            serialBox.attemptAutoConnectCyton();
        }

        if (rcBox.isShowing) {
            if(getChannel.isMouseHere() && getChannel.wasPressed){
                // if(board != null) // Radios_Config will handle creating the serial port JAM 1/2017
                get_channel(rcBox);
                getChannel.wasPressed = false;
                getChannel.setIsActive(false);
                hideChannelListCP();
            }

            if (setChannel.isMouseHere() && setChannel.wasPressed){
                channelPopup.setClicked(true);
                channelPopup.setTitle("Change Channel");
                pollPopup.setClicked(false);
                setChannel.setIsActive(false);
            }

            if (ovrChannel.isMouseHere() && ovrChannel.wasPressed){
                channelPopup.setClicked(true);
                channelPopup.setTitle("Override Dongle");
                pollPopup.setClicked(false);
                ovrChannel.setIsActive(false);
            }

            if(autoscan.isMouseHere() && autoscan.wasPressed){
                autoscan.wasPressed = false;
                autoscan.setIsActive(false);
                scan_channels(rcBox);
                hideChannelListCP();
            }

            if(systemStatus.isMouseHere() && systemStatus.wasPressed){
                system_status(rcBox);
                systemStatus.setIsActive(false);
                systemStatus.wasPressed = false;
                hideChannelListCP();
            }
        }

        if(popOutWifiConfigButton.isMouseHere() && popOutWifiConfigButton.wasPressed){
            popOutWifiConfigButton.wasPressed = false;
            popOutWifiConfigButton.setIsActive(false);
            if (selectedProtocol == BoardProtocol.WIFI || selectedProtocol == BoardProtocol.WIFI) {
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
                            output("Please select a WiFi Shield first. Can't see your WiFi Shield? Learn how at openbci.github.io/Documentation/");
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

        if(wifiIPAddressDynamic.isMouseHere() && wifiIPAddressDynamic.wasPressed) {
            hub.setWiFiStyle(WIFI_DYNAMIC);
            wifiBox.h = 200;
            String output = "Using " + (hub.getWiFiStyle() == WIFI_STATIC ? "Static" : "Dynamic") + " IP address of the WiFi Shield!";
            outputInfo(output);
            println("CP: WiFi IP: " + output);
        }

        if(wifiIPAddressStatic.isMouseHere() && wifiIPAddressStatic.wasPressed) {
            hub.setWiFiStyle(WIFI_STATIC);
            wifiBox.h = 120;
            String output = "Using " + (hub.getWiFiStyle() == WIFI_STATIC ? "Static" : "Dynamic") + " IP address of the WiFi Shield!";
            outputInfo(output);
            println("CP: WiFi IP: " + output);
        }

        // this button only used on mac
        if (isMac() && protocolBLEGanglion.isMouseHere() && protocolBLEGanglion.wasPressed) {
            println("protocolBLEGanglion");

            wifiList.items.clear();
            bleList.items.clear();
            controlPanel.hideAllBoxes();
            if (isHubObjectInitialized) {
                outputSuccess("Using built in BLE for Ganglion");
                if (hub.isPortOpen()) hub.closePort();
                ganglion.setInterface(BoardProtocol.BLE);
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
                if (hub.isPortOpen()) hub.closePort();
                ganglion.setInterface(BoardProtocol.BLED112);
                // hub.searchDeviceStart();
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
                ganglion.setInterface(BoardProtocol.WIFI);
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
                selectedProtocol = BoardProtocol.SERIAL; 
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
                selectedProtocol = BoardProtocol.WIFI;
                hub.searchDeviceStart();
            } else {
                output("Please wait till hub is fully initalized");
            }
        }

        if (autoSessionName.isMouseHere() && autoSessionName.wasPressed) {
            String _board = (eegDataSource == DATASOURCE_CYTON) ? "Cyton" : "Ganglion";
            String _textField = (eegDataSource == DATASOURCE_CYTON) ? "fileNameCyton" : "fileNameGanglion";
            output("Autogenerated " + _board + " Session Name based on current date & time.");
            cp5.get(Textfield.class, _textField).setText(getDateString());
        }

        if (outputODF.isMouseHere() && outputODF.wasPressed) {
            output("Output has been set to OpenBCI Data Format.");
            outputDataSource = OUTPUT_SOURCE_ODF;
            outputODF.setColorNotPressed(isSelected_color);
            outputBDF.setColorNotPressed(colorNotPressed);
            if (eegDataSource == DATASOURCE_CYTON) {
                controlPanel.dataLogBoxCyton.setToODFHeight();
            } else {
                controlPanel.dataLogBoxGanglion.setToODFHeight();
            }
        }

        if (outputBDF.isMouseHere() && outputBDF.wasPressed) {
            output(bdfMessage);
            outputDataSource = OUTPUT_SOURCE_BDF;
            outputBDF.setColorNotPressed(isSelected_color);
            outputODF.setColorNotPressed(colorNotPressed);
            if (eegDataSource == DATASOURCE_CYTON) {
                controlPanel.dataLogBoxCyton.setToBDFHeight();
            } else {
                controlPanel.dataLogBoxGanglion.setToBDFHeight();
            }
        }

        if (chanButton8.isMouseHere() && chanButton8.wasPressed) {
            updateToNChan(8);
        }

        if (chanButton16.isMouseHere() && chanButton16.wasPressed ) {
            updateToNChan(16);
        }

        if (sampleRate200.isMouseHere() && sampleRate200.wasPressed) {
            currentBoard.setSampleRate(200);
        }

        if (sampleRate1600.isMouseHere() && sampleRate1600.wasPressed) {
            currentBoard.setSampleRate(1600);
        }

        if (sampleRate250.isMouseHere() && sampleRate250.wasPressed) {
            currentBoard.setSampleRate(250);
        }

        if (sampleRate500.isMouseHere() && sampleRate500.wasPressed) {
            currentBoard.setSampleRate(500);
        }

        if (sampleRate1000.isMouseHere() && sampleRate1000.wasPressed) {
            currentBoard.setSampleRate(1000);
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
            output("Select a file for playback");
            selectInput("Select a pre-recorded file for playback:", 
                        "playbackFileSelected",
                        new File(settings.guiDataPath + "Recordings"));
        }

        if (selectSDFile.isMouseHere() && selectSDFile.wasPressed) {
            output("Select an SD file to convert to a playback file");
            createPlaybackFileFromSD();
            selectInput("Select an SD file to convert for playback:", "sdFileSelected");
        }

        if (sampleDataButton.isMouseHere() && sampleDataButton.wasPressed) {
            output("Select a file for playback");
            selectInput("Select a pre-recorded file for playback:", 
                        "playbackFileSelected", 
                        new File(settings.guiDataPath + 
                                "Sample_Data" + System.getProperty("file.separator") + 
                                "OpenBCI-sampleData-2-meditation.txt"));
        }

        //reset all buttons to false
        refreshPort.setIsActive(false);
        refreshPort.wasPressed = false;
        refreshBLE.setIsActive(false);
        refreshBLE.wasPressed = false;
        refreshWifi.setIsActive(false);
        refreshWifi.wasPressed = false;

        // this button used on mac only
        if (isMac()) {
            protocolBLEGanglion.setIsActive(false);
            protocolBLEGanglion.wasPressed = false;
        }

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
        autoSessionName.setIsActive(false);
        autoSessionName.wasPressed = false;
        outputBDF.setIsActive(false);
        outputBDF.wasPressed = false;
        outputODF.setIsActive(false);
        outputODF.wasPressed = false;
        wifiIPAddressDynamic.setIsActive(false);
        wifiIPAddressDynamic.wasPressed = false;
        wifiIPAddressStatic.setIsActive(false);
        wifiIPAddressStatic.wasPressed = false;
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
        sampleDataButton.setIsActive(false);
        sampleDataButton.wasPressed = false;
    }
};

public void initButtonPressed(){
    if (initSystemButton.but_txt == "START SESSION") {
        if ((eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.NONE) || (eegDataSource == DATASOURCE_GANGLION && selectedProtocol == BoardProtocol.NONE)) {
            output("No Transfer Protocol selected. Please select your Transfer Protocol and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.SERIAL && openBCI_portName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
            output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.WIFI && wifi_portName == "N/A" && hub.getWiFiStyle() == WIFI_DYNAMIC) {
            output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
            output("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_GANGLION && (selectedProtocol == BoardProtocol.BLE || selectedProtocol == BoardProtocol.BLED112) && ganglion_portName == "N/A") {
            output("No BLE device selected. Please select your Ganglion device and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_GANGLION && selectedProtocol == BoardProtocol.WIFI && wifi_portName == "N/A" && hub.getWiFiStyle() == WIFI_DYNAMIC) {
            output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == -1) {//if no data source selected
            output("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (playbackFileIsEmpty) {
            outputError("Playback file appears empty. Try loading a different file.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else { //otherwise, initiate system!
            //verbosePrint("ControlPanel: CPmouseReleased: init");
            initSystemButton.setString("STOP SESSION");
            // Global steps to START SESSION
            // Prepare the serial port
            if (eegDataSource == DATASOURCE_CYTON) {
                sessionName = cp5.get(Textfield.class, "fileNameCyton").getText(); // store the current text field value of "File Name" to be passed along to dataFiles
                controlPanel.serialBox.autoConnect.setIgnoreHover(false); //reset the auto-connect button
                controlPanel.serialBox.autoConnect.setColorNotPressed(255);
            } else if(eegDataSource == DATASOURCE_GANGLION){
                verbosePrint("ControlPanel — port is open: " + ganglion.isPortOpen());
                if (ganglion.isPortOpen()) {
                    ganglion.closePort();
                }
                sessionName = cp5.get(Textfield.class, "fileNameGanglion").getText(); // store the current text field value of "File Name" to be passed along to dataFiles
            }

            if (outputDataSource == OUTPUT_SOURCE_ODF && eegDataSource < DATASOURCE_PLAYBACKFILE) {
                settings.setLogFileMaxDuration();
            }

            if (hub.getWiFiStyle() == WIFI_STATIC && (selectedProtocol == BoardProtocol.WIFI || selectedProtocol == BoardProtocol.WIFI)) {
                wifi_ipAddress = cp5.get(Textfield.class, "staticIPAddress").getText();
                println("Static IP address of " + wifi_ipAddress);
            }

            novaXR_ipAddress = cp5.get(Textfield.class, "novaXR_IP").getText();

            //Set this flag to true, and draw "Starting Session..." to screen after then next draw() loop
            midInit = true;
            output("Attempting to Start Session..."); // Show this at the bottom of the GUI
            println("initButtonPressed: Calling initSystem() after next draw()");
        }
    } else {
        //if system is already active ... stop session and flip button state back
        outputInfo("Learn how to use this application and more at openbci.github.io/Documentation/");
        initSystemButton.setString("START SESSION");
        cp5.get(Textfield.class, "fileNameCyton").setText(getDateString()); //creates new data file name so that you don't accidentally overwrite the old one
        cp5.get(Textfield.class, "fileNameGanglion").setText(getDateString()); //creates new data file name so that you don't accidentally overwrite the old one
        cp5.get(Textfield.class, "staticIPAddress").setText(wifi_ipAddress); // Fills the last (or default) IP address
        haltSystem();
    }
}

void updateToNChan(int _nchan) {
    nchan = _nchan;
    settings.slnchan = _nchan; //used in SoftwareSettings.pde only
    fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
    yLittleBuff_uV = new float[nchan][nPointsPerUpdate];
    println("channel count set to " + str(nchan));
    hub.initDataPackets(_nchan, 3);
    ganglion.initDataPackets(_nchan, 3);
    updateChannelArrays(nchan); //make sure to reinitialize the channel arrays with the right number of channels
}

//==============================================================================//
//                	BELOW ARE THE CLASSES FOR THE VARIOUS                         //
//                	CONTROL PANEL BOXes (control widgets)                        //
//==============================================================================//

class DataSourceBox {
    int x, y, w, h, padding; //size and position
    int numItems = 5;
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
        sourceList.addItem(makeItem("LIVE (from NovaXR)"));
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
    Button autoConnect;

    SerialBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 70;
        padding = _padding;

        autoConnect = new Button(x + padding, y + padding*3 + 4, w - padding*3 - 70, 24, "AUTO-CONNECT", fontInfo.buttonLabel_size);
        autoConnect.setHelpText("Attempt to auto-connect to Cyton. Try \"Manual\" if this does not work.");
        popOutRadioConfigButton = new Button(x + w - 70 - padding, y + padding*3 + 4, 70, 24,"Manual >",fontInfo.buttonLabel_size);
        popOutRadioConfigButton.setHelpText("Having trouble connecting to Cyton? Click here to access Radio Configuration tools.");
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
        text("SERIAL CONNECT", x + padding, y + padding);
        popStyle();

        if (selectedProtocol == BoardProtocol.SERIAL) {
            popOutRadioConfigButton.draw();
            autoConnect.draw();
        }
    }

    public void attemptAutoConnectCyton() {
        println("ControlPanel: Attempting to Auto-Connect to Cyton");
        //Fetch the number of com ports...
        int numComPorts = cp5.get(MenuList.class, "serialList").getListSize();
        String _regex = "";
        //Then look for matching cyton dongle
        //Try the last matching comPort. They are already reverse sorted, so get item 0.
        String comPort = (String)cp5.get(MenuList.class, "serialList").getItem(0).get("headline");
        if (isMac()) {
            _regex = "^/dev/tty.usbserial-DM.*$";
        } else if (isWindows()) {
            _regex = "COM.*$";
        } else if (isLinux()) {
            _regex = "^/dev/ttyUSB.*$";
        }
        if (ableToConnect(comPort, _regex)) return;
        
    } //end attempAutoConnectCyton 

    private boolean ableToConnect(String _comPort, String _regex) {
        if (systemMode < SYSTEMMODE_POSTINIT) {
            //There are quite a few serial ports on Linux, but not many that start with /dev/ttyUSB
            String[] foundCytonPort = match(_comPort, _regex);
            if (foundCytonPort != null) {  // If not null, then a match was found
                println("ControlPanel: Connect using comPort: " + _comPort);
                openBCI_portName = foundCytonPort[0];
                initButtonPressed();
                return true;
            }
            return false;
        } else {
            return true;
        }
    }
};

class ComPortBox {
    int x, y, w, h, padding; //size and position
    boolean isShowing;

    ComPortBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w + 10;
        h = 140 + _padding;
        padding = _padding;
        isShowing = false;

        refreshPort = new Button (x + padding, y + padding*4 + 72 + 8, w - padding*2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);
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
        refreshPort.draw();
        popStyle();
    }
};

class BLEBox {
    int x, y, w, h, padding; //size and position

    BLEBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 140 + _padding;
        padding = _padding;

        refreshBLE = new Button (x + padding, y + padding*4 + 72 + 8, w - padding*5, 24, "START SEARCH", fontInfo.buttonLabel_size);
        bleList = new MenuList(cp5, "bleList", w - padding*2, 72, p4);
        bleList.setPosition(x + padding, y + padding*3 + 8);
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

    WifiBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 184 + _padding;
        padding = _padding;

        wifiIPAddressDynamic = new Button (x + padding, y + padding*2 + 30, (w-padding*3)/2, 24, "DYNAMIC IP", fontInfo.buttonLabel_size);
        if (hub.getWiFiStyle() == WIFI_DYNAMIC) wifiIPAddressDynamic.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        wifiIPAddressStatic = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 30, (w-padding*3)/2, 24, "STATIC IP", fontInfo.buttonLabel_size);
        if (hub.getWiFiStyle() == WIFI_STATIC) wifiIPAddressStatic.setColorNotPressed(isSelected_color); //make it appear like this one is already selected

        refreshWifi = new Button (x + padding, y + padding*5 + 72 + 8 + 24, w - padding*5, 24, "START SEARCH", fontInfo.buttonLabel_size);
        wifiList = new MenuList(cp5, "wifiList", w - padding*2, 72 + 8, p4);
        popOutWifiConfigButton = new Button(x+padding + (w-padding*4), y + padding, 20,20,">",fontInfo.buttonLabel_size);

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
        wifiIPAddressDynamic.draw();
        wifiIPAddressStatic.draw();
        wifiIPAddressDynamic.but_y = y + padding*2 + 16;
        wifiIPAddressStatic.but_y = wifiIPAddressDynamic.but_y;

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
            wifiList.setPosition(x + padding, wifiIPAddressDynamic.but_y + 24 + padding);

            refreshWifi.draw();
            refreshWifi.but_y = y + h - padding - 24;
            if(isHubInitialized && isHubObjectInitialized && (selectedProtocol == BoardProtocol.WIFI || selectedProtocol == BoardProtocol.WIFI) && hub.isSearching()){
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

        protocolSerialCyton = new Button (x + padding, y + padding * 3 + 4, w - padding * 2, 24, "Serial (from Dongle)", fontInfo.buttonLabel_size);
        protocolWifiCyton = new Button (x + padding, y + padding * 4 + 24 + 4, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
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
        padding = _padding;
        h = (24 + _padding) * 3;
        int buttonHeight = 24;

        int paddingCount = 1;
        if (isMac()) {
            protocolBLEGanglion = new Button (x + padding, y + padding * paddingCount + buttonHeight, w - padding * 2, 24, "Bluetooth (Built In)", fontInfo.buttonLabel_size);
            paddingCount ++;
            // Fix height for extra button
            h += padding + buttonHeight;
        }

        protocolBLED112Ganglion = new Button (x + padding, y + padding * paddingCount + buttonHeight * paddingCount, w - padding * 2, 24, "Bluetooth (BLED112 Dongle)", fontInfo.buttonLabel_size);
        paddingCount ++;
        protocolWifiGanglion = new Button (x + padding, y + padding * paddingCount + buttonHeight * paddingCount, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
        paddingCount ++;
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

        if (isMac()) {
            protocolBLEGanglion.draw();
        }
        protocolWifiGanglion.draw();
        protocolBLED112Ganglion.draw();
    }
};

class SessionDataBox {
    int x, y, w, h, padding; //size and position
    int i; //0 for Cyton, 1 for Ganglion
    String textfieldName;
    final int bdfModeHeight = 127;
    int odfModeHeight;

    ControlP5 cp5_dataLog_dropdown;
    int maxDurTextWidth = 82;
    int maxDurText_x = 0;
    String maxDurDropdownName;
    boolean dropdownWasClicked = false;

    SessionDataBox (int _x, int _y, int _w, int _h, int _padding, int _dataSource) {
        odfModeHeight = bdfModeHeight + 24 + _padding;
        x = _x;
        y = _y;
        w = _w;
        h = odfModeHeight;
        padding = _padding;
        maxDurText_x = x + padding;
        maxDurTextWidth += padding*5 + 1;

        //button to autogenerate file name based on time/date
        autoSessionName = new Button (x + padding, y + 66, w-(padding*2), 24, "GENERATE SESSION NAME", fontInfo.buttonLabel_size);
        autoSessionName.setHelpText("Autogenerate a session name based on the date and time.");
        outputODF = new Button (x + padding, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "OpenBCI", fontInfo.buttonLabel_size);
        outputODF.setHelpText("Set GUI data output to OpenBCI Data Format (.txt). A new file will be made in the session folder when the data stream is paused or max file duration is reached.");
        //Output source is ODF by default
        if (outputDataSource == OUTPUT_SOURCE_ODF) outputODF.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        outputBDF = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "BDF+", fontInfo.buttonLabel_size);
        outputBDF.setHelpText("Set GUI data output to BioSemi Data Format (.bdf). All session data is contained in one .bdf file. View using an EDF/BDF browser.");
        if (outputDataSource == OUTPUT_SOURCE_BDF) outputBDF.setColorNotPressed(isSelected_color); //make it appear like this one is already selected

        //This textfield is controlled by the global cp5 instance
        textfieldName = (_dataSource == DATASOURCE_CYTON) ? "fileNameCyton" : "fileNameGanglion";
        cp5.addTextfield(textfieldName)
            .setPosition(x + 60, y + 32)
            .setCaptionLabel("")
            .setSize(187, 26)
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

        //The OpenBCI data format max duration dropdown is controlled by the local cp5 instance
        cp5_dataLog_dropdown = new ControlP5(ourApplet);
        maxDurDropdownName = (_dataSource == DATASOURCE_CYTON) ? "maxFileDurationCyton" : "maxFileDurationGanglion";
        createDropdown(maxDurDropdownName, Arrays.asList(settings.fileDurations));
        cp5_dataLog_dropdown.setGraphics(ourApplet, 0,0);
        cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setPosition(x + maxDurTextWidth, outputODF.but_y + 24 + padding);
        cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setSize((w-padding*3)/2, (settings.fileDurations.length + 1) * 24);
        cp5_dataLog_dropdown.setAutoDraw(false);
    }

    public void update() {
        openCloseDropdown();
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
        text("Session Data", x + padding, y + padding);
        textFont(p4, 14);
        text("Name", x + padding, y + padding*2 + 14);
        popStyle();
        cp5.get(Textfield.class, textfieldName).setPosition(x + 60, y + 32);
        autoSessionName.but_y = y + 66;
        autoSessionName.draw();
        outputODF.but_y = y + padding*2 + 18 + 58;
        outputODF.draw();
        outputBDF.but_y = y + padding*2 + 18 + 58;
        outputBDF.draw();
        if (outputDataSource == OUTPUT_SOURCE_ODF) {
            pushStyle();
            //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
            fill(bgColor);
            rect(cp5_dataLog_dropdown.getController(maxDurDropdownName).getPosition()[0]-1, cp5_dataLog_dropdown.getController(maxDurDropdownName).getPosition()[1]-1, cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).getWidth()+2, cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).getHeight()+2);
            fill(bgColor);
            textFont(p4, 14);
            text("Max File Duration", maxDurText_x, outputODF.but_y + outputODF.but_dy + padding*3 - 3);
            popStyle();
            cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setVisible(true);
            cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setPosition(x + maxDurTextWidth, outputODF.but_y + 24 + padding);
            //Dropdown is drawn at the end of ControlPanel.draw()
        }
    }

    void createDropdown(String name, List<String> _items){

        cp5_dataLog_dropdown.addScrollableList(name)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            /*
            .setColorBackground(color(31,69,110)) // text field bg color
            .setColorValueLabel(color(0))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            */
            // .setColorCursor(color(26,26,26))

            .setSize(w - padding*2,(_items.size()+1)*24)// + maxFreqList.size())
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .addItems(_items) // used to be .addItems(maxFreqList)
            .setVisible(false)
            ;
        cp5_dataLog_dropdown.getController(name)
            .getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(settings.fileDurations[settings.defaultOBCIMaxFileSize])
            .setFont(p4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        cp5_dataLog_dropdown.getController(name)
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(settings.fileDurations[settings.defaultOBCIMaxFileSize])
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
    }

    //Returns: 0 for Cyton, 1 for Ganglion
    public int getBoardType() {
        return i;
    }

    public void setToODFHeight() {
        h = odfModeHeight;
    }

    public void setToBDFHeight() {
        h = bdfModeHeight;
    }

    private void openCloseDropdown() {
        //Close the dropdown if it is open and mouse is no longer over it
        if (cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).isOpen()){
            if (!cp5_dataLog_dropdown.getController(maxDurDropdownName).isMouseOver()){
                //println("----Closing dropdown " + maxDurDropdownName);
                cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).close();
                lockElements(false);
            }

        }
        // Open the dropdown if it's not open, but not if it was recently clicked
        // Makes sure dropdown stays closed after user selects an option
        if (!dropdownWasClicked) {
            if (!cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).isOpen()){
                if (cp5_dataLog_dropdown.getController(maxDurDropdownName).isMouseOver()){
                    //println("++++Opening dropdown " + maxDurDropdownName);
                    cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).open();
                    lockElements(true);
                }
            }
        } else {
            // This flag is used to gate opening/closing the dropdown
            dropdownWasClicked = false;
        }
    }

    // True locks elements, False unlocks elements
    void lockElements (boolean _toggle) {
        if (eegDataSource == DATASOURCE_CYTON) {
            //Cyton for Serial and WiFi (WiFi details are drawn to the right, so no need to lock)
            chanButton8.setIgnoreHover(_toggle);
            chanButton16.setIgnoreHover(_toggle);
            /*
            if (_toggle) {
                cp5.get(MenuList.class, "sdTimes").lock();
            } else {
                cp5.get(MenuList.class, "sdTimes").unlock();
            }
            cp5.get(MenuList.class, "sdTimes").setUpdate(!_toggle);
            */
            if (_toggle) {
                controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).lock();
            } else {
                controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).unlock();
            }
            controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).setUpdate(!_toggle);
        } else {
            //Ganglion + Wifi
            latencyGanglion5ms.setIgnoreHover(_toggle);
            latencyGanglion10ms.setIgnoreHover(_toggle);
            latencyGanglion20ms.setIgnoreHover(_toggle);
            sampleRate200.setIgnoreHover(_toggle);
            sampleRate1600.setIgnoreHover(_toggle);
        }
    }

    void closeDropdown() {
        cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).close();
        dropdownWasClicked = true;
        lockElements(false);
        //println("---- DROPDOWN CLICKED -> CLOSING DROPDOWN");
    }
};
//////////////////////////////////////////////////////////////
// Global functions used by the above SessionDataBox dropdowns
void maxFileDurationCyton (int n) {
    settings.cytonOBCIMaxFileSize = n;
    controlPanel.dataLogBoxCyton.closeDropdown();
    println("ControlPanel: Cyton Max Recording Duration: " + settings.fileDurations[n]);
}

void maxFileDurationGanglion (int n) {
    settings.ganglionOBCIMaxFileSize = n;
    controlPanel.dataLogBoxGanglion.closeDropdown();
    println("ControlPanel: Ganglion Max Recording Duration: " + settings.fileDurations[n]);
}
//////////////////////////////////////////////////////////////

class ChannelCountBox {
    int x, y, w, h, padding; //size and position


    ChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        chanButton8 = new Button (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "8 CHANNELS", fontInfo.buttonLabel_size);
        if (nchan == 8) chanButton8.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        chanButton16 = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "16 CHANNELS", fontInfo.buttonLabel_size);
        if (nchan == 16) chanButton16.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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

    SampleRateGanglionBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        sampleRate200 = new Button (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "200Hz", fontInfo.buttonLabel_size);
        sampleRate1600 = new Button (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "1600Hz", fontInfo.buttonLabel_size);
        sampleRate1600.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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

    SampleRateCytonBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        sampleRate250 = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "250Hz", fontInfo.buttonLabel_size);
        sampleRate500 = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "500Hz", fontInfo.buttonLabel_size);
        sampleRate1000 = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "1000Hz", fontInfo.buttonLabel_size);
        sampleRate1000.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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
        text("  " + str(getSampleRateSafe()) + "Hz", x + padding + 142, y + padding); // print the channel count in green next to the box title
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
        if (hub.getLatency() == LATENCY_5_MS) latencyGanglion5ms.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        latencyGanglion10ms = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "10ms", fontInfo.buttonLabel_size);
        if (hub.getLatency() == LATENCY_10_MS) latencyGanglion10ms.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        latencyGanglion20ms = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "20ms", fontInfo.buttonLabel_size);
        if (hub.getLatency() == LATENCY_20_MS) latencyGanglion20ms.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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
        if (hub.getLatency() == LATENCY_5_MS) latencyCyton5ms.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        latencyCyton10ms = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "10ms", fontInfo.buttonLabel_size);
        if (hub.getLatency() == LATENCY_10_MS) latencyCyton10ms.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        latencyCyton20ms = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "20ms", fontInfo.buttonLabel_size);
        if (hub.getLatency() == LATENCY_20_MS) latencyCyton20ms.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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
        if (hub.getWifiInternetProtocol().equals(TCP)) wifiInternetProtocolGanglionTCP.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        wifiInternetProtocolGanglionUDP = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "UDP", fontInfo.buttonLabel_size);
        if (hub.getWifiInternetProtocol().equals(UDP)) wifiInternetProtocolGanglionUDP.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        wifiInternetProtocolGanglionUDPBurst = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "UDPx3", fontInfo.buttonLabel_size);
        if (hub.getWifiInternetProtocol().equals(UDP_BURST)) wifiInternetProtocolGanglionUDPBurst.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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
        if (hub.getWifiInternetProtocol().equals(TCP)) wifiInternetProtocolCytonTCP.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        wifiInternetProtocolCytonUDP = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "UDP", fontInfo.buttonLabel_size);
        if (hub.getWifiInternetProtocol().equals(UDP)) wifiInternetProtocolCytonUDP.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        wifiInternetProtocolCytonUDPBurst = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "UDPx3", fontInfo.buttonLabel_size);
        if (hub.getWifiInternetProtocol().equals(UDP_BURST)) wifiInternetProtocolCytonUDPBurst.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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

    SyntheticChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        synthChanButton4 = new Button (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "4 chan", fontInfo.buttonLabel_size);
        if (nchan == 4) synthChanButton4.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        synthChanButton8 = new Button (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "8 chan", fontInfo.buttonLabel_size);
        if (nchan == 8) synthChanButton8.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        synthChanButton16 = new Button (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "16 chan", fontInfo.buttonLabel_size);
        if (nchan == 16) synthChanButton16.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
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

class RecentPlaybackBox {
    int x, y, w, h, padding; //size and position
    StringList shortFileNames = new StringList();
    StringList longFilePaths = new StringList();
    private String filePickedShort = "Select Recent Playback File";
    ControlP5 cp5_recentPlayback_dropdown;

    RecentPlaybackBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 67;
        padding = _padding;

        cp5_recentPlayback_dropdown = new ControlP5(ourApplet);
        getRecentPlaybackFiles();

        String[] temp = shortFileNames.array();
        createDropdown("recentFiles", Arrays.asList(temp));
        cp5_recentPlayback_dropdown.setGraphics(ourApplet, 0,0);
        cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setPosition(x + padding, y + padding*2 + 13);
        cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setSize(w - padding*2, (temp.length + 1) * 24);
        cp5_recentPlayback_dropdown.setAutoDraw(false);
    }

    /////*Update occurs while control panel is open*/////
    public void update() {
        //Update the dropdown list if it has not already been done
        if (!recentPlaybackFilesHaveUpdated) {
            cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").clear();
            getRecentPlaybackFiles();
            String[] temp = shortFileNames.array();
            cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").addItems(temp);
            cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setSize(w - padding*2, (temp.length + 1) * 24);
        }
    }

    public String getFilePickedShort() {
        return filePickedShort;
    }

    public void setFilePickedShort(String _fileName) {
        filePickedShort = _fileName;
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h + cp5_recentPlayback_dropdown.getController("recentFiles").getHeight() - padding*2);
        fill(bgColor);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PLAYBACK HISTORY", x + padding, y + padding);
        popStyle();
        cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setVisible(true);
        cp5_recentPlayback_dropdown.draw();
    }

    private void getRecentPlaybackFiles() {
        int numFilesToShow = 10;
        try {
            JSONObject playbackHistory = loadJSONObject(userPlaybackHistoryFile);
            JSONArray recentFilesArray = playbackHistory.getJSONArray("playbackFileHistory");
            if (recentFilesArray.size() < 10) {
                println("CP: Playback History Size = " + recentFilesArray.size());
                numFilesToShow = recentFilesArray.size();
            }
            shortFileNames.clear();
            longFilePaths.clear();
            for (int i = numFilesToShow - 1; i >= 0; i--) {
                JSONObject playbackFile = recentFilesArray.getJSONObject(i);
                String shortFileName = playbackFile.getString("id");
                String longFilePath = playbackFile.getString("filePath");
                //truncate display name, if needed
                shortFileName = shortenString(shortFileName, w-padding*2.f, h3);
                //store to arrays to set recent playback buttons text and function
                shortFileNames.append(shortFileName);
                longFilePaths.append(longFilePath);
                //println(shortFileName + " " + longFilePath);
            }

            playbackHistoryFileExists = true;
        } catch (Exception e) {
            println("OpenBCI_GUI::Control Panel: Playback history file not found or other error.");
            playbackHistoryFileExists = false;
        }
        recentPlaybackFilesHaveUpdated = true;
    }

    void closeAllDropdowns(){
        cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").close();
    }

    void createDropdown(String name, List<String> _items){

        cp5_recentPlayback_dropdown.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(color(31,69,110)) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            // .setColorCursor(color(26,26,26))

            .setSize(w - padding*2,(_items.size()+1)*24)// + maxFreqList.size())
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .addItems(_items) // used to be .addItems(maxFreqList)
            .setVisible(false)
            ;
        cp5_recentPlayback_dropdown.getController(name)
            .getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(filePickedShort)
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        cp5_recentPlayback_dropdown.getController(name)
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(filePickedShort)
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
    }
};

class NovaXRBox {
    int x, y, w, h, padding; //size and position
    boolean isShowing;
    private boolean previousIsShowing;

    NovaXRBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 67;
        padding = _padding;
        isShowing = false;
        previousIsShowing = false;

        cp5.addTextfield("novaXR_IP")
            .setPosition(x + 60, y + 32)
            .setCaptionLabel("")
            .setSize(187, 26)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(color(0, 0, 0))  // text color
            .setColorForeground(isSelected_color)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText(novaXR_ipAddress)
            .align(5, 10, 20, 40)
            .onDoublePress(cb)
            .setVisible(false)
            .setAutoClear(true); 
    }

    public void update() {
        //Check for state change so we don't call setVisible() every update
        if (isShowing != previousIsShowing) {
            cp5.get(Textfield.class, "novaXR_IP").setVisible(isShowing);
            previousIsShowing = isShowing;
        }
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
        text("IP", x + padding, y + padding);
        popStyle();
        cp5.get(Textfield.class, "novaXR_IP").setPosition(x + 60, y + 32);
    }
};

class PlaybackFileBox {
    int x, y, w, h, padding; //size and position
    int sampleDataButton_w = 100;
    int sampleDataButton_h = 20;

    PlaybackFileBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 67;
        padding = _padding;

        selectPlaybackFile = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);
        selectPlaybackFile.setHelpText("Click to open a dialog box to select an OpenBCI playback file (.txt or .csv).");
    
        // Sample data button
        sampleDataButton = new Button(x + w - sampleDataButton_w - padding, y + padding - 2, sampleDataButton_w, sampleDataButton_h, "Sample Data", 14);
        sampleDataButton.setCornerRoundess((int)(sampleDataButton_h));
        sampleDataButton.setFont(p4, 14);
        sampleDataButton.setColorNotPressed(color(57,128,204));
        sampleDataButton.setFontColorNotActive(color(255));
        sampleDataButton.setHelpText("Click to open the folder containing OpenBCI GUI Sample Data.");
        sampleDataButton.hasStroke(false);
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
        sampleDataButton.draw();
    }
};

class SDBox {
    final private String sdBoxDropdownName = "sdCardTimes";
    final private String[] sdTimesStrings = {
                        "Do not write to SD...", 
                        "5 minute maximum", 
                        "15 minute maximum", 
                        "30 minute maximum",
                        "1 hour maximum",
                        "2 hours maximum",
                        "4 hour maximum",
                        "12 hour maximum",
                        "24 hour maximum"
                        };
    int x, y, w, h, padding; //size and position
    ControlP5 cp5_sdBox;
    boolean dropdownWasClicked = false;

    SDBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        cp5_sdBox = new ControlP5(ourApplet);
        createDropdown(sdBoxDropdownName, Arrays.asList(sdTimesStrings));
        cp5_sdBox.setGraphics(ourApplet, 0,0);
        cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).setPosition(x + padding, y + padding*2 + 14);
        cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).setSize(w - padding*2, int((sdTimesStrings.length / 2) + 1) * 24);
        cp5_sdBox.setAutoDraw(false);
        //sdTimes = new MenuList(cp5, "sdTimes", w - padding*2, 108, p4);
        //sdTimes.setPosition(x + padding, y + padding*2 + 13);
        
        serialPorts = Serial.list();

        /*
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
        */
    }

    public void update() {
        openCloseDropdown();
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
        text("WRITE TO SD CARD?", x + padding, y + padding);
        //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
        popStyle();

        pushStyle();
        fill(150);
        rect(cp5_sdBox.getController(sdBoxDropdownName).getPosition()[0]-1, cp5_sdBox.getController(sdBoxDropdownName).getPosition()[1]-1, cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).getWidth()+2, cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).getHeight()+2);
        //cp5_sdBox.draw();
        popStyle();

        //set the correct position of the dropdown and make it visible if the SDBox class is being drawn
        cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).setPosition(x + padding, y + padding*2 + 14);
        cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).setVisible(true);
        cp5_sdBox.draw();
        
        //sdTimes.setPosition(x + padding, y + padding*2 + 13);
        //the drawing of the sdTimes is handled earlier in ControlPanel.draw()
    }

    void createDropdown(String name, List<String> _items){

        cp5_sdBox.addScrollableList(name)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            /*
            .setColorBackground(color(31,69,110)) // text field bg color
            .setColorValueLabel(color(0))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            */
            // .setColorCursor(color(26,26,26))

            .setSize(w - padding*2,(_items.size()+1)*24)// + maxFreqList.size())
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .addItems(_items) // used to be .addItems(maxFreqList)
            .setVisible(false)
            ;
        cp5_sdBox.getController(name)
            .getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(sdTimesStrings[0])
            .setFont(p4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        cp5_sdBox.getController(name)
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(sdTimesStrings[0])
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
    }

    private void openCloseDropdown() {
        //Close the dropdown if it is open and mouse is no longer over it
        if (cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).isOpen()){
            if (!cp5_sdBox.getController(sdBoxDropdownName).isMouseOver()){
                //println("----Closing dropdown " + maxDurDropdownName);
                cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).close();
                //lockElements(false);
            }

        }
        // Open the dropdown if it's not open, but not if it was recently clicked
        // Makes sure dropdown stays closed after user selects an option
        if (!dropdownWasClicked) {
            if (!cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).isOpen()){
                if (cp5_sdBox.getController(sdBoxDropdownName).isMouseOver()){
                    //println("++++Opening dropdown " + maxDurDropdownName);
                    cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).open();
                    //lockElements(true);
                }
            }
        } else {
            // This flag is used to gate opening/closing the dropdown
            dropdownWasClicked = false;
        }
    }

    void closeDropdown() {
        cp5_sdBox.get(ScrollableList.class, sdBoxDropdownName).close();
        dropdownWasClicked = true;
        //lockElements(false);
        //println("---- DROPDOWN CLICKED -> CLOSING DROPDOWN");
    }
};

//////////////////////////////////////////////////////////////
// Global function used by the above SDBox dropdown
void sdCardTimes (int n) {
    //settings.cytonOBCIMaxFileSize = n;
    sdSetting = n;
    if (sdSetting != 0) {
        output("OpenBCI microSD Setting = " + controlPanel.sdBox.sdTimesStrings[n] + " recording time");
    } else {
        output("OpenBCI microSD Setting = " + controlPanel.sdBox.sdTimesStrings[n]);
    }
    verbosePrint("SD setting = " + controlPanel.sdBox.sdTimesStrings[n]);

    controlPanel.sdBox.closeDropdown();
    //println("ControlPanel: Cyton SD Card Duration: " + controlPanel.sdBox.sdTimesStrings[n]);
}

class RadioConfigBox {
    int x, y, w, h, padding; //size and position
    String initial_message = "Having trouble connecting to your Cyton? Try AutoScan!\n\nUse this tool to get Cyton status or change settings.";
    String last_message = initial_message;
    public boolean isShowing;

    RadioConfigBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x + _w;
        y = _y;
        w = _w + 10;
        h = 275; //255 + 20 for larger autoscan button
        padding = _padding;
        isShowing = false;

        //typical button height + 20 for larger autoscan button
        autoscan = new Button(x + padding, y + padding + 18, w-(padding*2), 24 + 20, "AUTOSCAN", fontInfo.buttonLabel_size);
        //smaller buttons below autoscan
        getChannel = new Button(x + padding, y + padding*3 + 18 + 24 + 44, (w-padding*3)/2, 24, "GET CHANNEL", fontInfo.buttonLabel_size);
        systemStatus = new Button(x + padding, y + padding*2 + 18 + 44, (w-padding*3)/2, 24, "STATUS", fontInfo.buttonLabel_size);
        setChannel = new Button(x + 2*padding + (w-padding*3)/2, y + padding*2 + 18 + 44, (w-padding*3)/2, 24, "CHANGE CHAN.", fontInfo.buttonLabel_size);
        ovrChannel = new Button(x + 2*padding + (w-padding*3)/2, y + padding*3 + 18 + 24 + 44, (w-padding*3)/2, 24, "OVERRIDE DONGLE", fontInfo.buttonLabel_size);
        

        //Set help text
        getChannel.setHelpText("Get the current channel of your Cyton and USB Dongle.");
        setChannel.setHelpText("Change the channel of your Cyton and USB Dongle.");
        ovrChannel.setHelpText("Change the channel of the USB Dongle only.");
        autoscan.setHelpText("Scan through channels and connect to a nearby Cyton. This button solves most connection issues!");
        systemStatus.setHelpText("Get the connection status of your Cyton system.");
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
        rect(x + padding, y + (padding*8) + 33 + (24*2), w-(padding*2), 135 - 21 - padding); //13 + 20 = 33 for larger autoscan
        fill(255);
        textFont(h3, 15);
        text(localstring, x + padding + 5, y + (padding*8) + 5 + (24*2) + 35, (w-padding*3 ), 135 - 24 - padding -15); //15 + 20 = 35
        this.last_message = localstring;
    }
};

class WifiConfigBox {
    int x, y, w, h, padding; //size and position
    String last_message = "";
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
        getMacAddress = new Button(x + padding, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "MAC ADDRESS", fontInfo.buttonLabel_size);
        getFirmwareVersion = new Button(x + 2*padding + (w-padding*3)/2, y + padding*3 + 18 + 24, (w-padding*3)/2, 24, "FIRMWARE VERS.", fontInfo.buttonLabel_size);
        eraseCredentials = new Button(x + padding, y + padding*4 + 18 + 24*2, w-(padding*2), 24, "ERASE NETWORK CREDENTIALS", fontInfo.buttonLabel_size);

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
        textFont(h3, 15);
        text(localstring, x + padding + 10, y + (padding*8) + 5 + (24*2) + 15, (w-padding*3 ), 135 - 24 - padding -15);
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
        selectSDFile.setHelpText("Click here to select an SD file generated by Cyton or Cyton+Daisy and convert to plain text format.");
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
    boolean clicked;
    String title = "";

    ChannelPopup(int _x, int _y, int _w, int _h, int _padding) {
        x = _x + _w * 2;
        y = _y;
        w = _w;
        h = 171 + _padding;
        padding = _padding;
        clicked = false;

        channelList = new MenuList(cp5Popup, "channelListCP", w - padding*2, 140, p4);
        channelList.setPosition(x+padding, y+padding*3);

        for (int i = 1; i < 26; i++) {
            channelList.addItem(makeItem(String.valueOf(i)));
        }
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
        text(title, x + padding, y + padding);
        popStyle();
    }

    public void setClicked(boolean click) { this.clicked = click; }
    public boolean wasClicked() { return this.clicked; }
    public void setTitle(String s) { title = s; }
};

class PollPopup {
    int x, y, w, h, padding; //size and position
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
    }

    public void setClicked(boolean click) { this.clicked = click; }
    public boolean wasClicked() { return this.clicked; }
};

class InitBox {
    int x, y, w, h, padding; //size and position

    InitBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 50;
        padding = _padding;

        initSystemButton = new Button (padding, y + padding, w-padding*2, h - padding*2, "START SESSION", fontInfo.buttonLabel_size);
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

//makeItem function used by MenuList class below
Map<String, Object> makeItem(String theHeadline, String theSubline, String theCopy) {
    Map m = new HashMap<String, Object>();
    m.put("headline", theHeadline);
    m.put("subline", theSubline);
    m.put("copy", theCopy);
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
    int hoverItem = -1;
    int activeItem = -1;
    PFont menuFont = p4;
    int padding = 7;

    MenuList(ControlP5 c, String theName, int theWidth, int theHeight, PFont theFont) {

        super( c, theName, 0, 0, theWidth, theHeight );
        c.register( this );
        menu = createGraphics(getWidth(),getHeight());
        final ControlP5 cc = c; //allows check for isLocked() below
        final String _theName = theName;

        menuFont = p4;
        getValueLabel().setSize(14);
        getCaptionLabel().setSize(14);

        setView(new ControllerView<MenuList>() {

            public void display(PGraphics pg, MenuList t) {
                if (updateMenu && !cc.get(MenuList.class, _theName).isLock()) {
                    updateMenu();
                }
                if (isMouseOver()) {
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
        println(getName() + ": click! ");
        if (items.size() > 0) { //Fixes #480
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
        }
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

    //Returns null if selecting an item that does not exist
    Map<String, Object> getItem(int theIndex) {
        Map<String, Object> m = new HashMap<String, Object>();
        try {
            m = items.get(theIndex);
        } catch (Exception e) {
            //println("Item " + theIndex + " does not exist.");
        }
        return m;
    }

    int getListSize() {
       return items.size(); 
    }
};
