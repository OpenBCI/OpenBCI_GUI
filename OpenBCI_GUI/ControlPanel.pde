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

import openbci_gui_helpers.*;

import java.io.IOException;
import java.util.List;

import openbci_gui_helpers.GanglionError;
import com.vmichalak.protocol.ssdp.Device;
import com.vmichalak.protocol.ssdp.SSDPClient;

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
MenuList bleList;
MenuList wifiList;
MenuList sdTimes;
MenuList channelList;
MenuList pollList;

color boxColor = color(200);
color boxStrokeColor = color(bgColor);
color isSelected_color = color(184, 220, 105);
color colorNotPressed = color(255);

Button_obci refreshPort;
Button_obci refreshBLE;
Button_obci refreshWifi;
Button_obci protocolSerialCyton;
Button_obci protocolWifiCyton;
Button_obci protocolWifiGanglion;
Button_obci protocolBLED112Ganglion;

Button_obci initSystemButton;
Button_obci autoSessionName; // Reuse these buttons for Cyton and Ganglion
Button_obci outputBDF;
Button_obci outputODF;

Button_obci sampleDataButton; // Used to easily find GUI sample data for Playback mode #645

Button_obci chanButton8;
Button_obci chanButton16;
Button_obci selectPlaybackFile;
Button_obci popOutRadioConfigButton;

//Radio Button_obci Definitions
Button_obci getChannel;
Button_obci setChannel;
Button_obci ovrChannel;
Button_obci autoscan;
Button_obci systemStatus;

Button_obci sampleRate200; //Ganglion
Button_obci sampleRate250; //Cyton
Button_obci sampleRate500; //Cyton
Button_obci sampleRate1000;  //Cyton
Button_obci sampleRate1600; //Ganglion
Button_obci wifiIPAddressDynamic;
Button_obci wifiIPAddressStatic;

Button_obci synthChanButton4;
Button_obci synthChanButton8;
Button_obci synthChanButton16;

ChannelPopup channelPopup;
PollPopup pollPopup;
RadioConfigBox rcBox;

Map<String, String> BLEMACAddrMap = new HashMap<String, String>();
int selectedSamplingRate = -1;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

public void controlEvent(ControlEvent theEvent) {

    if (theEvent.isFrom("sourceList")) {
        // THIS IS TRIGGERED WHEN A USER SELECTS 'LIVE (from Cyton) or LIVE (from Ganglion), etc...'
        controlPanel.hideAllBoxes();

        Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
        String str = (String)bob.get("headline"); // Get the text displayed in the MenuList
        int newDataSource = (int)bob.get("value");
        settings.controlEventDataSource = str; //Used for output message on system start
        eegDataSource = newDataSource;

        protocolWifiGanglion.setColorNotPressed(colorNotPressed);
        protocolBLED112Ganglion.setColorNotPressed(colorNotPressed);
        protocolWifiCyton.setColorNotPressed(colorNotPressed);
        protocolSerialCyton.setColorNotPressed(colorNotPressed);

        //Reset protocol
        selectedProtocol = BoardProtocol.NONE;

        //Perform this check in a way that ignores order of items in the menulist
        if (eegDataSource == DATASOURCE_CYTON) {
            updateToNChan(8);
            chanButton8.setColorNotPressed(isSelected_color);
            chanButton16.setColorNotPressed(colorNotPressed); //default color of button
            // WiFi autoconnect is used for "Dynamic IP"
            wifiIPAddressDynamic.setColorNotPressed(isSelected_color);
            wifiIPAddressStatic.setColorNotPressed(colorNotPressed);
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            updateToNChan(4);
            // WiFi autoconnect is used for "Dynamic IP"
            wifiIPAddressDynamic.setColorNotPressed(isSelected_color);
            wifiIPAddressStatic.setColorNotPressed(colorNotPressed);
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            //GUI auto detects number of channels for playback when file is selected
        } else if (eegDataSource == DATASOURCE_SYNTHETIC) {
            synthChanButton4.setColorNotPressed(colorNotPressed);
            synthChanButton8.setColorNotPressed(isSelected_color);
            synthChanButton16.setColorNotPressed(colorNotPressed);
        } else if (eegDataSource == DATASOURCE_NOVAXR) {
            selectedSamplingRate = 250; //default sampling rate
        } else if (eegDataSource == DATASOURCE_STREAMING) {
            //do nothing for now
        }
    }

    if (theEvent.isFrom("serialList")) {
        Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
        openBCI_portName = (String)bob.get("subline");
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
        wifi_ipAddress = (String)bob.get("subline");
        output("Selected WiFi Board: " + wifi_portName+ ", WiFi IP Address: " + wifi_ipAddress );
    }

    // This dropdown menu sets Cyton maximum SD-Card file size (for users doing very long recordings)
    if (theEvent.isFrom("sdCardTimes")) {
        int val = (int)(theEvent.getController()).getValue();
        Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
        cyton_sdSetting = (CytonSDMode)bob.get("value");
        String outputString = "OpenBCI microSD Setting = " + cyton_sdSetting.getName();
        if (cyton_sdSetting != CytonSDMode.NO_WRITE) {
            outputString += " recording time";
        }
        output(outputString);
        verbosePrint("SD Command = " + cyton_sdSetting.getCommand());
    }

    if (theEvent.isFrom("channelListCP")) {
        int setChannelInt = int(theEvent.getValue()) + 1;
        //Map bob = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
        cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
        channelPopup.setClicked(false);
        if (setChannel.wasPressed) {
            rcBox.setChannel(setChannelInt);
            setChannel.wasPressed = false;
        } else if(ovrChannel.wasPressed) {
            rcBox.setChannelOverride(setChannelInt);
            ovrChannel.wasPressed = false;
        }
    }

    //Check for event in PlaybackHistory Dropdown List in Control Panel
    if (theEvent.isFrom("recentFiles")) {
        int s = (int)(theEvent.getController()).getValue();
        //println("got a menu event from item " + s);
        String filePath = controlPanel.recentPlaybackBox.longFilePaths.get(s);
        if (new File(filePath).isFile()) {
            playbackFileFromList(filePath, s);
        } else {
            verbosePrint("Playback History: " + filePath);
            outputError("Playback History: Selected file does not exist. Try another file or clear settings to remove this entry.");
        }
    }

    //Check for event in NovaXR Mode List in Control Panel
    if (theEvent.isFrom("novaXR_SampleRates")) {
        int val = (int)(theEvent.getController()).getValue();
        Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
        // this will retrieve the enum object stored in the dropdown!
        novaXR_sampleRate = (NovaXRSR)bob.get("value");
        println("ControlPanel: User selected NovaXR Sample Rate: " + novaXR_sampleRate.getName());
    }

    //Check for event in NovaXR Mode List in Control Panel
    if (theEvent.isFrom("novaXR_Modes")) {
        int val = (int)(theEvent.getController()).getValue();
        Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
        // this will retrieve the enum object stored in the dropdown!
        novaXR_boardSetting = (NovaXRMode)bob.get("value");
        println("ControlPanel: User selected NovaXR Mode: " + novaXR_boardSetting.getName());
    }

    //This dropdown is in the SessionData Box
    if (theEvent.isFrom("maxFileDuration")) {
        int n = (int)theEvent.getValue();
        settings.setLogFileDurationChoice(n);
        println("ControlPanel: Chosen Recording Duration: " + n);
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
    StreamingBoardBox streamingBoardBox;
    BLEBox bleBox;
    SessionDataBox dataLogBoxGanglion;
    WifiBox wifiBox;
    InterfaceBoxCyton interfaceBoxCyton;
    InterfaceBoxGanglion interfaceBoxGanglion;
    SampleRateCytonBox sampleRateCytonBox;
    SampleRateGanglionBox sampleRateGanglionBox;
    SDBox sdBox;

    //Track Dynamic and Static WiFi mode in Control Panel
    final public String WIFI_DYNAMIC = "dynamic";
    final public String WIFI_STATIC = "static";
    private String wifiSearchStyle = WIFI_DYNAMIC;

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
        
        //boxes active when eegDataSource = Playback
        int playbackWidth = int(w * 1.35);
        playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, playbackWidth, h, globalPadding);
        recentPlaybackBox = new RecentPlaybackBox(x + w, (playbackFileBox.y + playbackFileBox.h), playbackWidth, h, globalPadding);

        novaXRBox = new NovaXRBox(x + w, dataSourceBox.y, w, h, globalPadding);

        streamingBoardBox = new StreamingBoardBox(x + w, dataSourceBox.y, w, h, globalPadding);
        
        comPortBox = new ComPortBox(x+w*2, y, w, h, globalPadding);
        rcBox = new RadioConfigBox(x+w, y + comPortBox.h, w, h, globalPadding);
        channelPopup = new ChannelPopup(x+w, y, w, h, globalPadding);
        pollPopup = new PollPopup(x+w,y,w,h,globalPadding);

        initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);

        // Ganglion
        bleBox = new BLEBox(x + w, interfaceBoxGanglion.y + interfaceBoxGanglion.h, w, h, globalPadding);
        dataLogBoxGanglion = new SessionDataBox(x + w, (bleBox.y + bleBox.h), w, h, globalPadding, DATASOURCE_GANGLION);
        sampleRateGanglionBox = new SampleRateGanglionBox(x + w, (dataLogBoxGanglion.y + dataLogBoxGanglion.h), w, h, globalPadding);
    }

    public void resetListItems(){
        comPortBox.serialList.activeItem = -1;
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

    public String getWifiSearchStyle() {
        return wifiSearchStyle;
    }

    private void setWiFiSearchStyle(String s) {
        wifiSearchStyle = s;
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
        dataLogBoxCyton.update();
        channelCountBox.update();
        synthChannelCountBox.update();

        //update playback box sizes when dropdown is selected
        recentPlaybackBox.update();
        playbackFileBox.update();

        novaXRBox.update();
        streamingBoardBox.update();

        sdBox.update();
        rcBox.update();
        comPortBox.update();
        initBox.update();

        channelPopup.update();
        bleList.updateMenu();
        wifiList.updateMenu();
        dataLogBoxGanglion.update();

        wifiBox.update();
        interfaceBoxCyton.update();
        interfaceBoxGanglion.update();
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
                            comPortBox.serialList.setVisible(true);
                            if (channelPopup.wasClicked()) {
                                channelPopup.draw();
                                cp5Popup.get(MenuList.class, "channelListCP").setVisible(true);
                                cp5Popup.get(MenuList.class, "pollList").setVisible(false);
                            } else if (pollPopup.wasClicked()) {
                                pollPopup.draw();
                                cp5Popup.get(MenuList.class, "pollList").setVisible(true);
                                cp5Popup.get(MenuList.class, "channelListCP").setVisible(false);
                                cp5.get(Textfield.class, "fileNameCyton").setVisible(true); //make sure the data file field is visible
                                cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
                            }
                        }
                    } else if (selectedProtocol == BoardProtocol.WIFI) {
                        wifiBox.y = interfaceBoxCyton.y + interfaceBoxCyton.h;

                        wifiBox.draw();
                        dataLogBoxCyton.y = wifiBox.y + wifiBox.h;

                        if (getWifiSearchStyle() == WIFI_STATIC) {
                            cp5.get(Textfield.class, "staticIPAddress").setVisible(true);
                            cp5.get(MenuList.class, "wifiList").setVisible(false);
                        } else {
                            cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
                            cp5.get(MenuList.class, "wifiList").setVisible(true);
                        }
                        sampleRateCytonBox.draw();
                    }
                    channelCountBox.y = dataLogBoxCyton.y + dataLogBoxCyton.h;
                    sdBox.y = channelCountBox.y + channelCountBox.h;
                    sampleRateCytonBox.y = channelCountBox.y;
                    channelCountBox.draw();
                    sdBox.draw();
                    cp5.get(Textfield.class, "fileNameCyton").setVisible(true); //make sure the data file field is visible
                    cp5.get(Textfield.class, "fileNameGanglion").setVisible(false); //make sure the data file field is not visible
                    dataLogBoxCyton.draw(); //Drawing here allows max file size dropdown to be drawn on top
                }
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) { //when data source is from playback file
                recentPlaybackBox.draw();
                playbackFileBox.draw();

                //set other CP5 controllers invisible
                comPortBox.serialList.setVisible(false);
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
                    if (selectedProtocol == BoardProtocol.BLED112) {
                        bleBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
                        dataLogBoxGanglion.y = bleBox.y + bleBox.h;
                        bleBox.draw();
                        cp5.get(MenuList.class, "bleList").setVisible(true);
                        cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
                    } else if (selectedProtocol == BoardProtocol.WIFI) {
                        wifiBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
                        dataLogBoxGanglion.y = wifiBox.y + wifiBox.h;
                        wifiBox.draw();
                        if (getWifiSearchStyle() == WIFI_STATIC) {
                            cp5.get(Textfield.class, "staticIPAddress").setVisible(true);
                            cp5.get(MenuList.class, "wifiList").setVisible(false);
                        } else {
                            cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
                            cp5.get(MenuList.class, "wifiList").setVisible(true);
                        }
                        sampleRateGanglionBox.y = dataLogBoxGanglion.y +dataLogBoxGanglion.h;
                        sampleRateGanglionBox.draw();
                    }
                    dataLogBoxGanglion.draw(); //Drawing here allows max file size dropdown to be drawn on top
                    cp5.get(Textfield.class, "fileNameCyton").setVisible(false); //make sure the data file field is visible
                    cp5.get(Textfield.class, "fileNameGanglion").setVisible(true); //make sure the data file field is visible
                }
            } else if (eegDataSource == DATASOURCE_STREAMING) {
                streamingBoardBox.draw();
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
        comPortBox.serialList.setVisible(false);
        popOutRadioConfigButton.setString("Manual >");
        rcBox.closeSerialPort();
    }

    public void hideAllBoxes() {
        //set other CP5 controllers invisible
        cp5.get(Textfield.class, "fileNameCyton").setVisible(false);
        cp5.get(Textfield.class, "staticIPAddress").setVisible(false);
        cp5.get(Textfield.class, "fileNameGanglion").setVisible(false);
        comPortBox.serialList.setVisible(false);
        cp5.get(MenuList.class, "bleList").setVisible(false);
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
        verbosePrint("CPmousePressed");

        if (initSystemButton.isMouseHere()) {
            initSystemButton.setIsActive(true);
            initSystemButton.wasPressed = true;
        }
    
        //only able to click buttons of control panel when system is not running
        if (systemMode != SYSTEMMODE_POSTINIT) {

            //active buttons during DATASOURCE_CYTON
            if (eegDataSource == DATASOURCE_CYTON) {
                
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
            }

            else if (eegDataSource == DATASOURCE_GANGLION) {
                // This is where we check for button presses if we are searching for BLE devices
                
                if (refreshBLE.isMouseHere()) {
                    refreshBLE.setIsActive(true);
                    refreshBLE.wasPressed = true;
                }

                if (protocolWifiGanglion.isMouseHere()) {
                    protocolWifiGanglion.setIsActive(true);
                    protocolWifiGanglion.wasPressed = true;
                    protocolBLED112Ganglion.setColorNotPressed(colorNotPressed);
                    protocolWifiGanglion.setColorNotPressed(isSelected_color);
                }

                if (protocolBLED112Ganglion.isMouseHere()) {
                    protocolBLED112Ganglion.setIsActive(true);
                    protocolBLED112Ganglion.wasPressed = true;
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
            }

            //active buttons during DATASOURCE_PLAYBACKFILE
            else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
                if (selectPlaybackFile.isMouseHere()) {
                    selectPlaybackFile.setIsActive(true);
                    selectPlaybackFile.wasPressed = true;
                }
                if (sampleDataButton.isMouseHere()) {
                    sampleDataButton.setIsActive(true);
                    sampleDataButton.wasPressed = true;
                }
            }

            //active buttons during DATASOURCE_SYNTHETIC
            else if (eegDataSource == DATASOURCE_SYNTHETIC) {
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

            else if (eegDataSource == DATASOURCE_NOVAXR) {
                novaXRBox.mousePressed();
            }

            
            //The following buttons apply only to Cyton and Ganglion Modes for now
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
                if (wifiIPAddressDynamic.isMouseHere()) {		
                    wifiIPAddressDynamic.setIsActive(true);		
                    wifiIPAddressDynamic.wasPressed = true;		
                    wifiIPAddressDynamic.setColorNotPressed(isSelected_color);		
                    wifiIPAddressStatic.setColorNotPressed(colorNotPressed);		
                }		

                if (wifiIPAddressStatic.isMouseHere()) {		
                    wifiIPAddressStatic.setIsActive(true);		
                    wifiIPAddressStatic.wasPressed = true;		
                    wifiIPAddressStatic.setColorNotPressed(isSelected_color);		
                    wifiIPAddressDynamic.setColorNotPressed(colorNotPressed);		
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
            comPortBox.attemptAutoConnectCyton();
        }

        if (rcBox.isShowing) {
            if(getChannel.isMouseHere() && getChannel.wasPressed){
                rcBox.getChannel();
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
                rcBox.scanChannels();
                autoscan.wasPressed = false;
                autoscan.setIsActive(false);
                hideChannelListCP();
            }

            if(systemStatus.isMouseHere() && systemStatus.wasPressed){
                rcBox.getSystemStatus();
                systemStatus.setIsActive(false);
                systemStatus.wasPressed = false;
                hideChannelListCP();
            }
        }

        if (initSystemButton.isMouseHere() && initSystemButton.wasPressed) {
            if (rcBox.isShowing) {
                hideRadioPopoutBox();
            }
            //if system is not active ... initate system and flip button state
            initButtonPressed();
            //cursor(ARROW); //this this back to ARROW
        }

        //open or close serial port if serial port button is pressed (left button in serial widget)
        if (refreshPort.isMouseHere() && refreshPort.wasPressed) {
            comPortBox.refreshPortListCyton();
        }

        if (refreshBLE.isMouseHere() && refreshBLE.wasPressed) {
            bleBox.refreshGanglionBLEList();
        }

        if (refreshWifi.isMouseHere() && refreshWifi.wasPressed) {
            wifiBox.refreshWifiList();
        }

        // Dynamic = Autoconnect, Static = Manually type IP address
        if(wifiIPAddressDynamic.isMouseHere() && wifiIPAddressDynamic.wasPressed) {
            wifiBox.h = 208;
            setWiFiSearchStyle(WIFI_DYNAMIC);
            String output = "Using Dynamic IP address of the WiFi Shield!";
            println("CP: WiFi IP: " + output);
        }

        if(wifiIPAddressStatic.isMouseHere() && wifiIPAddressStatic.wasPressed) {
            wifiBox.h = 120;
            setWiFiSearchStyle(WIFI_STATIC);
            String output = "Using Static IP address of the WiFi Shield!";
            outputInfo(output);
            println("CP: WiFi IP: " + output);
        }

        if (protocolBLED112Ganglion.isMouseHere() && protocolBLED112Ganglion.wasPressed) {
            wifiList.items.clear();
            bleList.items.clear();
            controlPanel.hideAllBoxes();
            selectedProtocol = BoardProtocol.BLED112;
            bleBox.refreshGanglionBLEList();
        }

        if (protocolWifiGanglion.isMouseHere() && protocolWifiGanglion.wasPressed) {
            wifiList.items.clear();
            bleList.items.clear();
            controlPanel.hideAllBoxes();
            selectedProtocol = BoardProtocol.WIFI;
        }

        if (protocolSerialCyton.isMouseHere() && protocolSerialCyton.wasPressed) {
            wifiList.items.clear();
            bleList.items.clear();
            controlPanel.hideAllBoxes();
            selectedProtocol = BoardProtocol.SERIAL;
            comPortBox.refreshPortListCyton();
        }

        if (protocolWifiCyton.isMouseHere() && protocolWifiCyton.wasPressed) {
            wifiList.items.clear();
            bleList.items.clear();
            controlPanel.hideAllBoxes();
            selectedProtocol = BoardProtocol.WIFI;
        }

        if (autoSessionName.isMouseHere() && autoSessionName.wasPressed) {
            String _board = (eegDataSource == DATASOURCE_CYTON) ? "Cyton" : "Ganglion";
            String _textField = (eegDataSource == DATASOURCE_CYTON) ? "fileNameCyton" : "fileNameGanglion";
            output("Autogenerated " + _board + " Session Name based on current date & time.");
            cp5.get(Textfield.class, _textField).setText(directoryManager.getFileNameDateTime());
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
            selectedSamplingRate = 200;
        }

        if (sampleRate1600.isMouseHere() && sampleRate1600.wasPressed) {
            selectedSamplingRate = 1600;
        }

        if (sampleRate250.isMouseHere() && sampleRate250.wasPressed) {
            selectedSamplingRate = 250;
        }

        if (sampleRate500.isMouseHere() && sampleRate500.wasPressed) {
            selectedSamplingRate = 500;
        }

        if (sampleRate1000.isMouseHere() && sampleRate1000.wasPressed) {
            selectedSamplingRate = 1000;
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
            output("Select a file for playback");
            selectInput("Select a pre-recorded file for playback:", 
                        "playbackFileSelected",
                        new File(directoryManager.getGuiDataPath() + "Recordings"));
        }


        if (sampleDataButton.isMouseHere() && sampleDataButton.wasPressed) {
            output("Select a file for playback");
            selectInput("Select a pre-recorded file for playback:", 
                        "playbackFileSelected", 
                        new File(directoryManager.getGuiDataPath() + 
                                "Sample_Data" + System.getProperty("file.separator") + 
                                "OpenBCI-sampleData-2-meditation.txt"));
        }

        novaXRBox.mouseReleased();

        //reset all buttons to false
        refreshPort.setIsActive(false);
        refreshPort.wasPressed = false;
        refreshBLE.setIsActive(false);
        refreshBLE.wasPressed = false;
        refreshWifi.setIsActive(false);
        refreshWifi.wasPressed = false;
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
        } else if (eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.WIFI && wifi_portName == "N/A" && controlPanel.getWifiSearchStyle() == controlPanel.WIFI_DYNAMIC) {
            output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A" && sdData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
            output("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_GANGLION && (selectedProtocol == BoardProtocol.BLE || selectedProtocol == BoardProtocol.BLED112) && ganglion_portName == "N/A") {
            output("No BLE device selected. Please select your Ganglion device and retry system initiation.");
            initSystemButton.wasPressed = false;
            initSystemButton.setIsActive(false);
            return;
        } else if (eegDataSource == DATASOURCE_GANGLION && selectedProtocol == BoardProtocol.WIFI && wifi_portName == "N/A" && controlPanel.getWifiSearchStyle() == controlPanel.WIFI_DYNAMIC) {
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
            initSystemButton.setString("STOP SESSION");
            // Global steps to START SESSION
            // Prepare the serial port
            if (eegDataSource == DATASOURCE_CYTON) {
                sessionName = cp5.get(Textfield.class, "fileNameCyton").getText(); // store the current text field value of "File Name" to be passed along to dataFiles
                controlPanel.serialBox.autoConnect.setIgnoreHover(false); //reset the auto-connect button
                controlPanel.serialBox.autoConnect.setColorNotPressed(255);
            } else if (eegDataSource == DATASOURCE_GANGLION) {
                // store the current text field value of "File Name" to be passed along to dataFiles
                sessionName = cp5.get(Textfield.class, "fileNameGanglion").getText();
            } else {
                sessionName = DirectoryManager.getFileNameDateTime();
            }

            if (controlPanel.getWifiSearchStyle() == controlPanel.WIFI_STATIC && (selectedProtocol == BoardProtocol.WIFI || selectedProtocol == BoardProtocol.WIFI)) {
                wifi_ipAddress = cp5.get(Textfield.class, "staticIPAddress").getText();
                println("Static IP address of " + wifi_ipAddress);
            }

            //Set this flag to true, and draw "Starting Session..." to screen after then next draw() loop
            midInit = true;
            output("Attempting to Start Session..."); // Show this at the bottom of the GUI
            println("initButtonPressed: Calling initSystem() after next draw()");
        }
    } else {
        //if system is already active ... stop session and flip button state back
        outputInfo("Learn how to use this application and more at openbci.github.io/Documentation/");
        initSystemButton.setString("START SESSION");
        cp5.get(Textfield.class, "fileNameCyton").setText(directoryManager.getFileNameDateTime()); //creates new data file name so that you don't accidentally overwrite the old one
        cp5.get(Textfield.class, "fileNameGanglion").setText(directoryManager.getFileNameDateTime()); //creates new data file name so that you don't accidentally overwrite the old one
        cp5.get(Textfield.class, "staticIPAddress").setText(wifi_ipAddress); // Fills the last (or default) IP address
        haltSystem();
    }
}

void updateToNChan(int _nchan) {
    nchan = _nchan;
    settings.slnchan = _nchan; //used in SoftwareSettings.pde only
    fftBuff = new FFT[nchan];  //reinitialize the FFT buffer
    println("Channel count set to " + str(nchan));
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

    DataSourceBox(int _x, int _y, int _w, int _h, int _padding) {
        if (novaXREnabled) numItems = 5;
        x = _x;
        y = _y;
        w = _w;
        h = spacing + (numItems * boxHeight);
        padding = _padding;

        sourceList = new MenuList(cp5, "sourceList", w - padding*2, numItems * boxHeight, p3);
        // sourceList.itemHeight = 28;
        // sourceList.padding = 9;
        sourceList.setPosition(x + padding, y + padding*2 + 13);
        sourceList.addItem(makeItem("CYTON (live)", DATASOURCE_CYTON));
        sourceList.addItem(makeItem("GANGLION (live)", DATASOURCE_GANGLION));
        if (novaXREnabled) sourceList.addItem(makeItem("NOVAXR (live)", DATASOURCE_NOVAXR));
        sourceList.addItem(makeItem("PLAYBACK (from file)", DATASOURCE_PLAYBACKFILE));
        sourceList.addItem(makeItem("SYNTHETIC (algorithmic)", DATASOURCE_SYNTHETIC));
        sourceList.addItem(makeItem("STREAMING (from external)", DATASOURCE_STREAMING));

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
    Button_obci autoConnect;

    SerialBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 70;
        padding = _padding;

        autoConnect = new Button_obci(x + padding, y + padding*3 + 4, w - padding*3 - 70, 24, "AUTO-CONNECT", fontInfo.buttonLabel_size);
        autoConnect.setHelpText("Attempt to auto-connect to Cyton. Try \"Manual\" if this does not work.");
        popOutRadioConfigButton = new Button_obci(x + w - 70 - padding, y + padding*3 + 4, 70, 24,"Manual >",fontInfo.buttonLabel_size);
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
};

class ComPortBox {
    private int x, y, w, h, padding; //size and position
    public boolean isShowing;
    public MenuList serialList;
    RadioConfig cytonRadioCfg;

    ComPortBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w + 10;
        h = 140 + _padding;
        padding = _padding;
        isShowing = false;
        cytonRadioCfg = new RadioConfig();

        refreshPort = new Button_obci (x + padding, y + padding*4 + 72 + 8, w - padding*2, 24, "REFRESH LIST", fontInfo.buttonLabel_size);
        serialList = new MenuList(cp5, "serialList", w - padding*2, 72, p3);
        serialList.setPosition(x + padding, y + padding*3 + 8);
    }

    public void update() {
        serialList.updateMenu();
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

    public void attemptAutoConnectCyton() {
        println("ControlPanel: Attempting to Auto-Connect to Cyton");
        LinkedList<String> comPorts = getCytonComPorts();
        if (!comPorts.isEmpty()) {
            openBCI_portName = comPorts.getFirst();
            if (cytonRadioCfg.get_channel()) {
                initButtonPressed();
                buttonHelpText.setVisible(false);
            }
            else {                
                outputWarn("Found a Cyton dongle, but could not connect to the board.");
            }
        }
        else {
            outputWarn("No Cyton dongles were found.");
        }
    }

    public void refreshPortListCyton(){
        serialList.items.clear();

        Thread thread = new Thread(){
            public void run(){
                refreshPort.setString("SEARCHING...");

                LinkedList<String> comPorts = getCytonComPorts();
                for (String comPort : comPorts) {
                    serialList.addItem(makeItem("(Cyton) " + comPort, comPort, ""));
                }
                serialList.updateMenu();

                refreshPort.setString("REFRESH LIST");
            }
        };

        thread.start();
    }

    private LinkedList<String> getCytonComPorts() {
        final String[] names = {"FT231X USB UART", "VCP0"};
        final SerialPort[] comPorts = SerialPort.getCommPorts();
        LinkedList<String> results = new LinkedList<String>();
        for (SerialPort comPort : comPorts) {
            for (String name : names) {
                if (comPort.toString().equals(name)) {
                    String found = "";
                    if (isMac() || isLinux()) found += "/dev/";
                    found += comPort.getSystemPortName();
                    println("ControlPanel: Found Cyton Dongle on COM port: " + found);
                    results.add(found);
                }
            }
        }

        return results;
    }

};

class BLEBox {
    private int x, y, w, h, padding; //size and position
    private volatile boolean bleIsRefreshing = false;

    BLEBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 140 + _padding;
        padding = _padding;
        refreshBLE = new Button_obci (x + padding, y + padding*4 + 72 + 8, w - padding*5, 24, "START SEARCH", fontInfo.buttonLabel_size);
        bleList = new MenuList(cp5, "bleList", w - padding*2, 72, p3);
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

        if (bleIsRefreshing) {
            //Display spinning cog gif
            image(loadingGIF_blue, w + 225,  refreshBLE.but_y + 4, 20, 20);
        } else {
            //Draw small grey circle
            pushStyle();
            fill(#999999);
            ellipseMode(CENTER);
            ellipse(w + 225 + 10, refreshBLE.but_y + 12, 12, 12);
            popStyle();
        }

        refreshBLE.draw();
    }

    public void mousePressed() {
        
    }

    private void refreshGanglionBLEList() {
        if (bleIsRefreshing) {
            output("BLE Devices Refreshing in progress");
            return;
        }
        output("BLE Devices Refreshing");
        bleList.items.clear();
        
        Thread thread = new Thread(){
            public void run(){
                refreshBLE.setString("SEARCHING...");
                bleIsRefreshing = true;
                final String comPort = getBLED112Port();
                if (comPort != null) {
                    try {
                        BLEMACAddrMap = GUIHelper.scan_for_ganglions (comPort, 3);
                        for (Map.Entry<String, String> entry : BLEMACAddrMap.entrySet ())
                        {
                            bleList.addItem(makeItem(entry.getKey(), comPort, ""));
                            bleList.updateMenu();
                        }
                    } catch (GanglionError e)
                    {
                        e.printStackTrace();
                    }
                } else {
                    outputError("No BLED112 Dongle Found");
                }
                refreshBLE.setString("START SEARCH");
                bleIsRefreshing = false;
            }
        };

        thread.start();
    }

    public String getBLED112Port() {
        String name = "Low Energy Dongle";
        SerialPort[] comPorts = SerialPort.getCommPorts();
        for (int i = 0; i < comPorts.length; i++) {
            if (comPorts[i].toString().equals(name)) {
                String found = "";
                if (isMac() || isLinux()) found += "/dev/";
                found += comPorts[i].getSystemPortName().toString();
                println("ControlPanel: Found BLED112 Dongle on COM port: " + found);
                return found;
            }
        }
        return null;
    }
};

class WifiBox {
    private int x, y, w, h, padding; //size and position
    private boolean wifiIsRefreshing = false;

    WifiBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 184 + _padding + 14;
        padding = _padding;

        wifiIPAddressDynamic = new Button_obci (x + padding, y + padding*2 + 30, (w-padding*3)/2, 24, "DYNAMIC IP", fontInfo.buttonLabel_size);
        wifiIPAddressDynamic.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        wifiIPAddressStatic = new Button_obci (x + padding*2 + (w-padding*3)/2, y + padding*2 + 30, (w-padding*3)/2, 24, "STATIC IP", fontInfo.buttonLabel_size);
        wifiIPAddressStatic.setColorNotPressed(colorNotPressed);

        refreshWifi = new Button_obci (x + padding, y + padding*5 + 72 + 8 + 24, w - padding*5, 24, "START SEARCH", fontInfo.buttonLabel_size);
        wifiList = new MenuList(cp5, "wifiList", w - padding*2, 72 + 8, p3);

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

        if (controlPanel.getWifiSearchStyle() == controlPanel.WIFI_STATIC) {
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

            String boardIpInfo = "BOARD IP: ";
            if (wifi_portName != "N/A") { // If user has selected a board from the menulist...
                boardIpInfo += wifi_ipAddress;
            }
            fill(bgColor);
            textFont(h3, 16);
            textAlign(LEFT, TOP);
            text(boardIpInfo, x + w/2 - textWidth(boardIpInfo)/2, y + h - padding - 46);

            if (wifiIsRefreshing){
                //Display spinning cog gif
                image(loadingGIF_blue, w + 225,  refreshWifi.but_y + 4, 20, 20);
            } else {
                //Draw small grey circle
                pushStyle();
                fill(#999999);
                ellipseMode(CENTER);
                ellipse(w + 225 + 10, refreshWifi.but_y + 12, 12, 12);
                popStyle();
            }
        }
    }

    public void refreshWifiList() {
        output("Wifi Devices Refreshing");
        wifiList.items.clear();
        Thread thread = new Thread(){
            public void run() {
                refreshWifi.setString("SEARCHING...");
                wifiIsRefreshing = true;
                try {
                    List<Device> devices = SSDPClient.discover (3000, "urn:schemas-upnp-org:device:Basic:1");
                    if (devices.isEmpty ()) {
                        println("No WIFI Shields found");
                    }
                    for (int i = 0; i < devices.size(); i++) {
                        wifiList.addItem(makeItem(devices.get(i).getName(), devices.get(i).getIPAddress(), ""));
                    }
                    wifiList.updateMenu();
                } catch (Exception e) {
                    println("Exception in wifi shield scanning");
                    e.printStackTrace ();
                }
                refreshWifi.setString("START SEARCH");
                wifiIsRefreshing = false;
            }
        };
        thread.start();
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

        protocolSerialCyton = new Button_obci (x + padding, y + padding * 3 + 4, w - padding * 2, 24, "Serial (from Dongle)", fontInfo.buttonLabel_size);
        protocolWifiCyton = new Button_obci (x + padding, y + padding * 4 + 24 + 4, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
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
        protocolBLED112Ganglion = new Button_obci (x + padding, y + padding * paddingCount + buttonHeight * paddingCount, w - padding * 2, 24, "Bluetooth (BLED112 Dongle)", fontInfo.buttonLabel_size);
        paddingCount ++;
        protocolWifiGanglion = new Button_obci (x + padding, y + padding * paddingCount + buttonHeight * paddingCount, w - padding * 2, 24, "Wifi (from Wifi Shield)", fontInfo.buttonLabel_size);
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
        autoSessionName = new Button_obci (x + padding, y + 66, w-(padding*2), 24, "GENERATE SESSION NAME", fontInfo.buttonLabel_size);
        autoSessionName.setHelpText("Autogenerate a session name based on the date and time.");
        outputODF = new Button_obci (x + padding, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "OpenBCI", fontInfo.buttonLabel_size);
        outputODF.setHelpText("Set GUI data output to OpenBCI Data Format (.txt). A new file will be made in the session folder when the data stream is paused or max file duration is reached.");
        //Output source is ODF by default
        if (outputDataSource == OUTPUT_SOURCE_ODF) outputODF.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        outputBDF = new Button_obci (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, "BDF+", fontInfo.buttonLabel_size);
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
            .setText(directoryManager.getFileNameDateTime())
            .align(5, 10, 20, 40)
            .onDoublePress(cb)
            .setAutoClear(true);

        //The OpenBCI data format max duration dropdown is controlled by the local cp5 instance
        cp5_dataLog_dropdown = new ControlP5(ourApplet);
        maxDurDropdownName = "maxFileDuration";
        createDropdown(maxDurDropdownName, Arrays.asList(settings.fileDurations));
        cp5_dataLog_dropdown.setGraphics(ourApplet, 0,0);
        cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setPosition(x + maxDurTextWidth, outputODF.but_y + 24 + padding);
        cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setSize((w-padding*3)/2, (settings.fileDurations.length + 1) * 24);
        cp5_dataLog_dropdown.setAutoDraw(false);
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
        text("SESSION DATA", x + padding, y + padding);
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
            //Dropdown is drawn at the end of ControlPanel.draw()
            fill(bgColor);
            cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setVisible(true);
            cp5_dataLog_dropdown.get(ScrollableList.class, maxDurDropdownName).setPosition(x + maxDurTextWidth, outputODF.but_y + 24 + padding);
            //Carefully draw some text to the left of above dropdown, otherwise this text moves when changing WiFi mode
            int extraPadding = (controlPanel.getWifiSearchStyle() == controlPanel.WIFI_STATIC) || selectedProtocol != BoardProtocol.WIFI
                ? 20 
                : 5;
            fill(bgColor);
            textFont(p4, 14);
            text("Max File Duration", maxDurText_x, y + h - 24 - padding + extraPadding);
            popStyle();
            
        }
    }

    void createDropdown(String name, List<String> _items){

        ScrollableList scrollList = new CustomScrollableList(cp5_dataLog_dropdown, name)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            .setBackgroundColor(150)
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

        scrollList.onEnter(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                lockElements(true);
            }
        });

        scrollList.onLeave(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                ScrollableList theList = (ScrollableList)(event.getController());
                lockElements(theList.isOpen());
            }
        });

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

    // True locks elements, False unlocks elements
    void lockElements (boolean _toggle) {
        if (eegDataSource == DATASOURCE_CYTON) {
            //Cyton for Serial and WiFi (WiFi details are drawn to the right, so no need to lock)
            chanButton8.setIgnoreHover(_toggle);
            chanButton16.setIgnoreHover(_toggle);
            if (_toggle) {
                controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).lock();
            } else {
                controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).unlock();
            }
            controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).setUpdate(!_toggle);
        } else {
            //Ganglion + Wifi
            sampleRate200.setIgnoreHover(_toggle);
            sampleRate1600.setIgnoreHover(_toggle);
        }
    }
};

class ChannelCountBox {
    int x, y, w, h, padding; //size and position


    ChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        chanButton8 = new Button_obci (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "8 CHANNELS", fontInfo.buttonLabel_size);
        if (nchan == 8) chanButton8.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        chanButton16 = new Button_obci (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "16 CHANNELS", fontInfo.buttonLabel_size);
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

        sampleRate200 = new Button_obci (x + padding, y + padding*2 + 18, (w-padding*3)/2, 24, "200Hz", fontInfo.buttonLabel_size);
        sampleRate1600 = new Button_obci (x + padding*2 + (w-padding*3)/2, y + padding*2 + 18, (w-padding*3)/2, 24, "1600Hz", fontInfo.buttonLabel_size);
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

        sampleRate250 = new Button_obci (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "250Hz", fontInfo.buttonLabel_size);
        sampleRate500 = new Button_obci (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "500Hz", fontInfo.buttonLabel_size);
        sampleRate1000 = new Button_obci (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "1000Hz", fontInfo.buttonLabel_size);
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
        popStyle();

        sampleRate250.draw();
        sampleRate500.draw();
        sampleRate1000.draw();
        sampleRate250.but_y = y + padding*2 + 18;
        sampleRate500.but_y = sampleRate250.but_y;
        sampleRate1000.but_y = sampleRate250.but_y;
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

        synthChanButton4 = new Button_obci (x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, "4 chan", fontInfo.buttonLabel_size);
        if (nchan == 4) synthChanButton4.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        synthChanButton8 = new Button_obci (x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, "8 chan", fontInfo.buttonLabel_size);
        if (nchan == 8) synthChanButton8.setColorNotPressed(isSelected_color); //make it appear like this one is already selected
        synthChanButton16 = new Button_obci (x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, "16 chan", fontInfo.buttonLabel_size);
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
    private int x, y, w, h, padding; //size and position
    private StringList shortFileNames = new StringList();
    private StringList longFilePaths = new StringList();
    private String filePickedShort = "Select Recent Playback File";
    private ControlP5 cp5_recentPlayback_dropdown;
    private int titleH = 14;
    private int buttonH = 24;

    RecentPlaybackBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = titleH + buttonH + _padding*3;
        padding = _padding;

        cp5_recentPlayback_dropdown = new ControlP5(ourApplet);
        cp5_recentPlayback_dropdown.setAutoDraw(false);
        getRecentPlaybackFiles();

        String[] temp = shortFileNames.array();
        createDropdown("recentFiles", Arrays.asList(temp));
        cp5_recentPlayback_dropdown.setGraphics(ourApplet, 0,0);
        cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setPosition(x + padding, y + padding*2 + 13);
        cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setSize(w - padding*2, (temp.length + 1) * buttonH);
    }

    /////*Update occurs while control panel is open*/////
    public void update() {
        //Update the dropdown list if it has not already been done
        if (!recentPlaybackFilesHaveUpdated) {
            cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").clear();
            getRecentPlaybackFiles();
            String[] temp = shortFileNames.array();
            cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").addItems(temp);
            cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").setSize(w - padding*2, (temp.length + 1) * buttonH);
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
        rect(x, y, w, h + cp5_recentPlayback_dropdown.getController("recentFiles").getHeight() - padding*2.5);
        fill(bgColor);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PLAYBACK HISTORY", x + padding, y + padding);
        popStyle();
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
            for (int i = 0; i < numFilesToShow; i++) {
                JSONObject playbackFile = recentFilesArray.getJSONObject(recentFilesArray.size()-i-1);
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
            println(e.getMessage());
            playbackHistoryFileExists = false;
        }
        recentPlaybackFilesHaveUpdated = true;
    }

    void createDropdown(String name, List<String> _items){

        ScrollableList scrollList = new CustomScrollableList(cp5_recentPlayback_dropdown, name)
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
            .setVisible(true)
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
    private int x, y, w, h, padding; //size and position
    private String boxLabel = "NOVAXR CONFIG";
    private String sampleRateLabel = "SAMPLE RATE";
    private ControlP5 localCP5;
    private ScrollableList srList;
    private ScrollableList modeList;

    NovaXRBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 104;
        padding = _padding;
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false); //Setting this saves code as cp5 elements will only be drawn/visible when [cp5].draw() is called

        modeList = createDropdown("novaXR_Modes", NovaXRMode.values());
        modeList.setPosition(x + padding, y + h - 24 - padding);
        modeList.setSize(w - padding*2,(modeList.getItems().size()+1)*24);
        srList = createDropdown("novaXR_SampleRates", NovaXRSR.values());
        srList.setPosition(x + w - padding*2 - 60*2, y + 16 + padding*2);
        srList.setSize(120 + padding,(srList.getItems().size()+1)*24);
    }

    public void update() {
        // nothing
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        //draw flexible grey background for this box
        rect(x, y, w, h + modeList.getHeight() - padding*2);
        popStyle();

        pushStyle();
        fill(bgColor);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        //draw text labels
        text(boxLabel, x + padding, y + padding);
        textAlign(LEFT, TOP);
        textFont(p4, 14);
        text(sampleRateLabel, x + padding, y + padding*2 + 18);
        popStyle();
        
        //draw cp5 last, on top of everything in this box
        localCP5.draw();
    }

    public void mousePressed() {
    }

    public void mouseReleased() {
    }

    private ScrollableList createDropdown(String name, NovaXRSettingsEnum[] enumValues){
        ScrollableList list = new CustomScrollableList(localCP5, name)
            .setOpen(false)
            .setColorBackground(color(31,69,110)) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            .setBackgroundColor(150)
            .setSize(w - padding*2, 24)//temporary size
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (NovaXRSettingsEnum value : enumValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getName(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(enumValues[0].getName())
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(enumValues[0].getName())
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;

        return list;
    }
};

class StreamingBoardBox {
    private int x, y, w, h, padding; //size and position
    private final String boxLabel = "STREAMING BOARD CONFIG";
    private final String ipLabel = "IP";
    private final String portLabel = "PORT";
    private final String boardLabel = "BOARD";
    private ControlP5 localCP5;
    private ScrollableList boardIdList;
    private Textfield ipAddress;
    private Textfield port;
    private final int headerH = 14;
    private final int objectH = 24;

    StreamingBoardBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w - _padding;
        h = headerH + objectH*2 + _padding*4;
        padding = _padding;
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false); //Setting this saves code as cp5 elements will only be drawn/visible when [cp5].draw() is called

        ipAddress = localCP5.addTextfield("ipAddress")
            .setPosition(x + padding * 3, y + headerH + padding*2)
            .setCaptionLabel("")
            .setSize(w / 3, objectH)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(color(0, 0, 0))  // text color
            .setColorForeground(isSelected_color)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText("") //default ipAddress == ""
            .align(5, 10, 20, 40)
            .onDoublePress(cb)
            .setAutoClear(true);
        
        port = localCP5.addTextfield("port")
            .setPosition(x + padding*5 + w/2, y + headerH + padding*2)
            .setCaptionLabel("")
            .setSize(w / 5 + padding, objectH)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(color(0, 0, 0))  // text color
            .setColorForeground(isSelected_color)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText(Integer.toString(0)) //default port == 0
            .align(5, 10, 20, 40)
            .onDoublePress(cb)
            .setAutoClear(true);
        
        boardIdList = createDropdown("streamingBoard_IDs", BrainFlowStreaming_Boards.values());
        boardIdList.setPosition(x + 48 + padding*2, y + headerH + padding*3 + objectH);
        boardIdList.setSize(170, (boardIdList.getItems().size()+1)*objectH);
    }

    public void update() {
        // nothing
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        popStyle();

        pushStyle();
        fill(bgColor);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        //draw text labels
        text(boxLabel, x + padding, y + padding);
        textAlign(LEFT, TOP);
        textFont(p4, 14);
        text(ipLabel, x + padding, y + padding*2 + headerH + 4);
        text(portLabel, x + w/2, y + padding*2 + headerH + 4);
        text(boardLabel, x + padding, y + padding*3 + objectH + headerH + 4);
        popStyle();
        
        //draw cp5 last, on top of everything in this box
        localCP5.draw();
    }

    private ScrollableList createDropdown(String name, BrainFlowStreaming_Boards[] enumValues){
        ScrollableList list = new CustomScrollableList(localCP5, name)
            .setOpen(false)
            .setColorBackground(color(31,69,110)) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            .setBackgroundColor(150)
            .setSize(w - padding*2, objectH)//temporary size
            .setBarHeight(objectH) //height of top/primary bar
            .setItemHeight(objectH) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (BrainFlowStreaming_Boards value : enumValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getName(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(enumValues[0].getName())
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(enumValues[0].getName())
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        return list;
    }
    
    public BrainFlowStreaming_Boards getBoard() {
        int val = (int)boardIdList.getValue();
        Map bob = boardIdList.getItem(val);
        // this will retrieve the enum object stored in the dropdown!
        return (BrainFlowStreaming_Boards)bob.get("value");
    }

    public String getIP() {
        return ipAddress.getText();
    }

    public int getPort() {
        return Integer.parseInt(port.getText());
    }
};

class PlaybackFileBox {
    private int x, y, w, h, padding; //size and position
    private int sampleDataButton_w = 100;
    private int sampleDataButton_h = 20;
    private int titleH = 14;
    private int buttonH = 24;

    PlaybackFileBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = buttonH + (_padding * 3) + titleH;
        padding = _padding;

        selectPlaybackFile = new Button_obci (x + padding, y + padding*2 + titleH, w - padding*2, buttonH, "SELECT OPENBCI PLAYBACK FILE", fontInfo.buttonLabel_size);
        selectPlaybackFile.setHelpText("Click to open a dialog box to select an OpenBCI playback file (.txt or .csv).");
    
        // Sample data button
        sampleDataButton = new Button_obci(x + w - sampleDataButton_w - padding, y + padding - 2, sampleDataButton_w, sampleDataButton_h, "Sample Data", 14);
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
    private int x, y, w, h, padding; //size and position
    private ControlP5 cp5_sdBox;
    private ScrollableList sdList;
    private int prevY;

    SDBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;
        prevY = y;

        cp5_sdBox = new ControlP5(ourApplet);
        cp5_sdBox.setAutoDraw(false);
        createDropdown(sdBoxDropdownName);
        cp5_sdBox.setGraphics(ourApplet, 0,0);
        updatePosition();
        sdList.setSize(w - padding*2, (int((sdList.getItems().size()+1)/1.5)) * 24);
    }

    public void update() {
        if (y != prevY) { //When box's absolute y position changes, update cp5
            updatePosition();
            prevY = y;
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
        text("WRITE TO SD CARD?", x + padding, y + padding);
        //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
        popStyle();

        pushStyle();
        fill(150);
        popStyle();
        cp5_sdBox.draw();
    }

    private void createDropdown(String name){

        sdList = new CustomScrollableList(cp5_sdBox, name)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            .setBackgroundColor(150)
            .setSize(w - padding*2, 2*24)//temporary size
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .setVisible(true)
            ;
         // for each entry in the enum, add it to the dropdown.
        for (CytonSDMode mode : CytonSDMode.values()) {
            // this will store the *actual* enum object inside the dropdown!
            sdList.addItem(mode.getName(), mode);
        }
        sdList.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(CytonSDMode.NO_WRITE.getName())
            .setFont(p4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        sdList.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(CytonSDMode.NO_WRITE.getName())
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
    }

    public void updatePosition() {
        sdList.setPosition(x + padding, y + padding*2 + 14);
    }
};


class RadioConfigBox {
    private int x, y, w, h, padding; //size and position
    private String initial_message = "Having trouble connecting to your Cyton? Try AutoScan!\n\nUse this tool to get Cyton status or change settings.";
    private String last_message = initial_message;
    public boolean isShowing;
    private RadioConfig cytonRadioCfg;
    private int headerH = 15;
    private int autoscanH = 45;
    private int buttonH = 24;
    private int statusWindowH = 115;

    RadioConfigBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x + _w;
        y = _y;
        w = _w + 10;
        h = (_padding*6) + headerH + (buttonH*2) + autoscanH + statusWindowH;
        padding = _padding;
        isShowing = false;
        cytonRadioCfg = new RadioConfig();

        //typical button height + 20 for larger autoscan button, full box width minus padding
        autoscan = new Button_obci(x + padding, y + padding*2 + headerH, w-(padding*2), autoscanH, "AUTOSCAN", fontInfo.buttonLabel_size);
        //smaller buttons below autoscan - left column
        systemStatus = new Button_obci(x + padding, y + padding*3 + headerH + autoscanH, (w-padding*4)/2, buttonH, "STATUS", fontInfo.buttonLabel_size);
        getChannel = new Button_obci(x + padding, y + padding*4 + headerH + buttonH + autoscanH, (w-padding*4)/2, buttonH, "GET CHANNEL", fontInfo.buttonLabel_size);
        //right column
        setChannel = new Button_obci(x + 2*padding + (w-padding*3)/2, y + padding*3 + headerH + autoscanH, (w-padding*3)/2, 24, "CHANGE CHAN.", fontInfo.buttonLabel_size);
        ovrChannel = new Button_obci(x + 2*padding + (w-padding*3)/2, y + padding*4 + headerH + buttonH + autoscanH, (w-padding*3)/2, buttonH, "OVERRIDE DONGLE", fontInfo.buttonLabel_size);
        

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
        pushStyle();
        textAlign(LEFT);
        fill(bgColor);
        rect(x + padding, y + padding*5 + headerH + buttonH*2 + autoscanH, w-(padding*2), statusWindowH);
        fill(255);
        textFont(h3, 15);
        text(localstring, x + padding + 5, y + padding*6 + headerH + buttonH*2 + autoscanH, w - padding*3, statusWindowH - padding);
        popStyle();
        this.last_message = localstring;
    }

    public void getChannel() {
        cytonRadioCfg.get_channel(RadioConfigBox.this);
    }

    public void setChannel(int val) {
        cytonRadioCfg.set_channel(RadioConfigBox.this, val);
    }

    public void setChannelOverride(int val) {
        cytonRadioCfg.set_channel_over(RadioConfigBox.this, val);
    }

    public void scanChannels() {
        cytonRadioCfg.scan_channels(RadioConfigBox.this);
    }

    public void getSystemStatus() {
        cytonRadioCfg.system_status(RadioConfigBox.this);
    }

    public void closeSerialPort() {
        print_onscreen("");
        cytonRadioCfg.closeSerialPort();
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

        channelList = new MenuList(cp5Popup, "channelListCP", w - padding*2, 140, p3);
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

        pollList = new MenuList(cp5Popup, "pollList", w - padding*2, 140, p3);
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

        initSystemButton = new Button_obci (padding, y + padding, w-padding*2, h - padding*2, "START SESSION", fontInfo.buttonLabel_size);
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
Map<String, Object> makeItem(String theHeadline, int value) {
    Map m = new HashMap<String, Object>();
    m.put("headline", theHeadline);
    m.put("value", value);
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
    PFont menuFont;
    int padding = 7;

    MenuList(ControlP5 c, String theName, int theWidth, int theHeight, PFont theFont) {

        super( c, theName, 0, 0, theWidth, theHeight );
        c.register( this );
        menu = createGraphics(getWidth(),getHeight());
        final ControlP5 cc = c; //allows check for isLocked() below
        final String _theName = theName;

        menuFont = theFont;

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
