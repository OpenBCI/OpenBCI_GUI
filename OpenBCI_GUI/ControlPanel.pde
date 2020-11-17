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
//        Refactored by: Richard Waltman (Nov. 2020)
//
//////////////////////////////////////////////////////////////////////////

import controlP5.*;

import openbci_gui_helpers.*;

import java.io.IOException;
import java.util.List;

import openbci_gui_helpers.GanglionError;
import com.vmichalak.protocol.ssdp.Device;
import com.vmichalak.protocol.ssdp.SSDPClient;

//------------------------------------------------------------------------//
//                      Main Control Panel Class                          //
//------------------------------------------------------------------------//

class ControlPanel {

    public int x, y, w, h;
    public boolean isOpen;

    PlotFontInfo fontInfo;

    //various control panel elements that are unique to specific datasources
    DataSourceBox dataSourceBox;
    SerialBox serialBox;
    ComPortBox comPortBox;
    public SessionDataBox dataLogBoxCyton;
    ChannelCountBox channelCountBox;
    InitBox initBox;
    SyntheticChannelCountBox synthChannelCountBox;
    RecentPlaybackBox recentPlaybackBox;
    PlaybackFileBox playbackFileBox;
    GaleaBox galeaBox;
    public SessionDataBox dataLogBoxGalea;
    StreamingBoardBox streamingBoardBox;
    BLEBox bleBox;
    public SessionDataBox dataLogBoxGanglion;
    WifiBox wifiBox;
    InterfaceBoxCyton interfaceBoxCyton;
    InterfaceBoxGanglion interfaceBoxGanglion;
    SampleRateCytonBox sampleRateCytonBox;
    SampleRateGanglionBox sampleRateGanglionBox;
    SDBox sdBox;

    ChannelPopup channelPopup;
    RadioConfigBox rcBox;

    //Track Dynamic and Static WiFi mode in Control Panel
    final public String WIFI_DYNAMIC = "dynamic";
    final public String WIFI_STATIC = "static";
    private String wifiSearchStyle = WIFI_DYNAMIC;

    boolean drawStopInstructions;
    int globalPadding; //design feature: passed through to all box classes as the global spacing .. in pixels .. for all elements/subelements
    boolean convertingSD = false;

    ControlPanel(OpenBCI_GUI mainClass) {

        x = 3;
        y = 3 + topNav.controlPanelCollapser.getHeight();
        w = topNav.controlPanelCollapser.getWidth();
        h = height - int(helpWidget.h);

        isOpen = false;
        fontInfo = new PlotFontInfo();

        globalPadding = 10;  //controls the padding of all elements on the control panel

        cp5 = new ControlP5(mainClass);
        cp5.setAutoDraw(false);

        //boxes active when eegDataSource = Normal (OpenBCI)
        dataSourceBox = new DataSourceBox(x, y, w, h, globalPadding);
        interfaceBoxCyton = new InterfaceBoxCyton(x + w, dataSourceBox.y, w, h, globalPadding);
        interfaceBoxGanglion = new InterfaceBoxGanglion(x + w, dataSourceBox.y, w, h, globalPadding);
        
        comPortBox = new ComPortBox(x+w*2, y, w, h, globalPadding);
        rcBox = new RadioConfigBox(x+w, y + comPortBox.h, w, h, globalPadding);

        serialBox = new SerialBox(x + w, interfaceBoxCyton.y + interfaceBoxCyton.h, w, h, globalPadding);
        wifiBox = new WifiBox(x + w, interfaceBoxCyton.y + interfaceBoxCyton.h, w, h, globalPadding);

        dataLogBoxCyton = new SessionDataBox(x + w, (serialBox.y + serialBox.h), w, h, globalPadding, DATASOURCE_CYTON, dataLogger.getDataLoggerOutputFormat(), "sessionNameCyton");
        channelCountBox = new ChannelCountBox(x + w, (dataLogBoxCyton.y + dataLogBoxCyton.h), w, h, globalPadding);
        synthChannelCountBox = new SyntheticChannelCountBox(x + w, dataSourceBox.y, w, h, globalPadding);
        sdBox = new SDBox(x + w, (channelCountBox.y + channelCountBox.h), w, h, globalPadding);
        sampleRateCytonBox = new SampleRateCytonBox(x + w + x + w - 3, channelCountBox.y, w, h, globalPadding);
        
        //boxes active when eegDataSource = Playback
        int playbackWidth = int(w * 1.35);
        playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, playbackWidth, h, globalPadding);
        recentPlaybackBox = new RecentPlaybackBox(x + w, (playbackFileBox.y + playbackFileBox.h), playbackWidth, h, globalPadding);

        galeaBox = new GaleaBox(x + w, dataSourceBox.y, w, h, globalPadding);
        dataLogBoxGalea = new SessionDataBox(x + w, (galeaBox.y + galeaBox.h), w, h, globalPadding, DATASOURCE_GALEA, dataLogger.getDataLoggerOutputFormat(), "sessionNameGalea");
        
        streamingBoardBox = new StreamingBoardBox(x + w, dataSourceBox.y, w, h, globalPadding);

        channelPopup = new ChannelPopup(x+w, y, w, h, globalPadding);

        initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);

        // Ganglion
        bleBox = new BLEBox(x + w, interfaceBoxGanglion.y + interfaceBoxGanglion.h, w, h, globalPadding);
        dataLogBoxGanglion = new SessionDataBox(x + w, (bleBox.y + bleBox.h), w, h, globalPadding, DATASOURCE_GANGLION, dataLogger.getDataLoggerOutputFormat(), "sessionNameGanglion");
        sampleRateGanglionBox = new SampleRateGanglionBox(x + w, (dataLogBoxGanglion.y + dataLogBoxGanglion.h), w, h, globalPadding);
    }

    public void resetListItems(){
        comPortBox.serialList.activeItem = -1;
        bleBox.bleList.activeItem = -1;
        wifiBox.wifiList.activeItem = -1;
    }

    public void open(){
        isOpen = true;
        topNav.controlPanelCollapser.setOn();
    }

    public void close(){
        isOpen = false;
        topNav.controlPanelCollapser.setOff();
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
            }
        } else { //the opposite of above
            if (cp5.isVisible()) {
                cp5.hide();
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

        dataLogBoxGalea.update();
        galeaBox.update();

        streamingBoardBox.update();

        sdBox.update();
        rcBox.update();
        comPortBox.update();
        initBox.update();

        channelPopup.update();

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

            //Carefully draw certain boxes based on UI/UX flow... let each box handle what is drawn inside with localCp5 instances
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
                            }
                        }
                    } else if (selectedProtocol == BoardProtocol.WIFI) {
                        wifiBox.y = interfaceBoxCyton.y + interfaceBoxCyton.h;

                        wifiBox.draw();
                        dataLogBoxCyton.y = wifiBox.y + wifiBox.h;

                        sampleRateCytonBox.draw();
                    }
                    channelCountBox.y = dataLogBoxCyton.y + dataLogBoxCyton.h;
                    sdBox.y = channelCountBox.y + channelCountBox.h;
                    sampleRateCytonBox.y = channelCountBox.y;
                    channelCountBox.draw();
                    sdBox.draw();
                    dataLogBoxCyton.draw(); //Drawing here allows max file size dropdown to be drawn on top
                }
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) { //when data source is from playback file
                recentPlaybackBox.draw();
                playbackFileBox.draw();
            } else if (eegDataSource == DATASOURCE_GALEA) {
                dataLogBoxGalea.y = galeaBox.y + galeaBox.h;  
                dataLogBoxGalea.draw();
                galeaBox.draw();
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
                    } else if (selectedProtocol == BoardProtocol.WIFI) {
                        wifiBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
                        dataLogBoxGanglion.y = wifiBox.y + wifiBox.h;
                        wifiBox.draw();
                        sampleRateGanglionBox.y = dataLogBoxGanglion.y +dataLogBoxGanglion.h;
                        sampleRateGanglionBox.draw();
                    }
                    dataLogBoxGanglion.draw(); //Drawing here allows max file size dropdown to be drawn on top
                }
            } else if (eegDataSource == DATASOURCE_STREAMING) {
                streamingBoardBox.draw();
            }
        } else {
            cp5.setVisible(false);
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
        cp5.draw();

        popStyle();
    }

    public void hideRadioPopoutBox() {
        rcBox.isShowing = false;
        comPortBox.isShowing = false;
        serialBox.popOutRadioConfigButton.getCaptionLabel().setText("Manual >");
        rcBox.closeSerialPort();
    }

    private void hideChannelListCP() {
        channelPopup.setClicked(false);
    }

}; //end of ControlPanel class

//==============================================================================//
//                	BELOW ARE THE CLASSES FOR THE VARIOUS                       //
//                	CONTROL PANEL BOXES (control widgets)                       //
//==============================================================================//

class DataSourceBox {
    public int x, y, w, h, padding; //size and position
    private int numItems;
    private int boxHeight = 24;
    private int spacing = 43;
    private ControlP5 datasource_cp5;
    private MenuList sourceList;

    DataSourceBox(int _x, int _y, int _w, int _h, int _padding) {
        numItems = galeaEnabled ? 6 : 5;
        x = _x;
        y = _y;
        w = _w;
        h = spacing + (numItems * boxHeight);
        padding = _padding;

        //Instantiate local cp5 for this box
        datasource_cp5 = new ControlP5(ourApplet);
        datasource_cp5.setGraphics(ourApplet, 0,0);
        datasource_cp5.setAutoDraw(false);
        createDatasourceList(datasource_cp5, "sourceList", x + padding, y + padding*2 + 13, w - padding*2, numItems * boxHeight, p3);
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
        
        datasource_cp5.draw();
    }

    private void createDatasourceList(ControlP5 _cp5, String name, int _x, int _y, int _w, int _h, PFont font) {
        sourceList = new MenuList(_cp5, name, _w, _h, font);
        sourceList.setPosition(_x, _y);
        // sourceList.itemHeight = 28;
        // sourceList.padding = 9;
        sourceList.addItem("CYTON (live)", DATASOURCE_CYTON);
        sourceList.addItem("GANGLION (live)", DATASOURCE_GANGLION);
        if (galeaEnabled) {
            sourceList.addItem("GALEA (live)", DATASOURCE_GALEA);
        }
        sourceList.addItem("PLAYBACK (from file)", DATASOURCE_PLAYBACKFILE);
        sourceList.addItem("SYNTHETIC (algorithmic)", DATASOURCE_SYNTHETIC);
        sourceList.addItem("STREAMING (from external)", DATASOURCE_STREAMING);
        sourceList.scrollerLength = 10;
        sourceList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    Map bob = sourceList.getItem(int(sourceList.getValue()));
                    String str = (String)bob.get("headline"); // Get the text displayed in the MenuList
                    int newDataSource = (int)bob.get("value");
                    settings.controlEventDataSource = str; //Used for output message on system start
                    eegDataSource = newDataSource;

                    //Reset protocol
                    selectedProtocol = BoardProtocol.NONE;

                    //Perform this check in a way that ignores order of items in the menulist
                    if (eegDataSource == DATASOURCE_CYTON) {
                        controlPanel.channelCountBox.set8ChanButtonActive();
                        controlPanel.interfaceBoxCyton.resetCytonSelectedProtocol();
                        controlPanel.wifiBox.setDefaultToDynamicIP();
                    } else if (eegDataSource == DATASOURCE_GANGLION) {
                        updateToNChan(4);
                        controlPanel.interfaceBoxGanglion.resetGanglionSelectedProtocol();
                        controlPanel.wifiBox.setDefaultToDynamicIP();
                    } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
                        //GUI auto detects number of channels for playback when file is selected
                    } else if (eegDataSource == DATASOURCE_GALEA) {
                        selectedSamplingRate = 250; //default sampling rate
                    } else if (eegDataSource == DATASOURCE_STREAMING) {
                        //do nothing for now
                    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {
                        controlPanel.synthChannelCountBox.set8ChanButtonActive();
                    }
                }
            }
        });
    }
};

class SerialBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 cytonsb_cp5;
    private Button autoConnectButton;
    private Button popOutRadioConfigButton;

    SerialBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 70;
        padding = _padding;

        //Instantiate local cp5 for this box
        cytonsb_cp5 = new ControlP5(ourApplet);
        cytonsb_cp5.setGraphics(ourApplet, 0,0);
        cytonsb_cp5.setAutoDraw(false);

        createAutoConnectButton("cytonAutoConnectButton", "AUTO-CONNECT", x + padding, y + padding*3 + 4, w - padding*3 - 70, 24, fontInfo.buttonLabel_size);
        createRadioConfigButton("cytonRadioConfigButton", "Manual >", x + w - 70 - padding, y + padding*3 + 4, 70, 24, fontInfo.buttonLabel_size);

        //autoConnect.setHelpText("Attempt to auto-connect to Cyton. Try \"Manual\" if this does not work.");
        //popOutRadioConfigButton.setHelpText("Having trouble connecting to Cyton? Click here to access Radio Configuration tools.");
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
            cytonsb_cp5.draw();
        }
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = cytonsb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        return myButton;
    }

    private void createAutoConnectButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        autoConnectButton = createButton(autoConnectButton, name, text, _x, _y, _w, _h, _fontSize);
        autoConnectButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.comPortBox.attemptAutoConnectCyton();
            }
        });
    }

    private void createRadioConfigButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        popOutRadioConfigButton = createButton(popOutRadioConfigButton, name, text, _x, _y, _w, _h, _fontSize);
        popOutRadioConfigButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (selectedProtocol == BoardProtocol.SERIAL) {
                    if (controlPanel.rcBox.isShowing) {
                        controlPanel.hideRadioPopoutBox();
                    } else {
                        controlPanel.rcBox.isShowing = true;
                        controlPanel.rcBox.print_onscreen(controlPanel.rcBox.initial_message);
                        popOutRadioConfigButton.getCaptionLabel().setText("Manual <");
                    }
                }
            }
        });
    }
};

class ComPortBox {
    public int x, y, w, h, padding; //size and position
    public boolean isShowing;
    private ControlP5 cytoncpb_cp5;
    private Button refreshCytonDongles;
    public MenuList serialList;
    public RadioConfig cytonRadioCfg;
    private boolean midAutoScan = false;
    private boolean midAutoScanCheck2 = false;

    ComPortBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w + 10;
        h = 140 + _padding;
        padding = _padding;
        isShowing = false;
        cytonRadioCfg = new RadioConfig();

        //Instantiate local cp5 for this box
        cytoncpb_cp5 = new ControlP5(ourApplet);
        cytoncpb_cp5.setGraphics(ourApplet, 0,0);
        cytoncpb_cp5.setAutoDraw(false);

        createRefreshCytonDonglesButton("refreshCytonDonglesButton", "REFRESH LIST", x + padding, y + padding*4 + 72 + 8, w - padding*2, 24, fontInfo.buttonLabel_size);
        createCytonDongleList(cytoncpb_cp5, "cytonDongleList", x + padding, y + padding*3 + 8,  w - padding*2, 72, p3);
    }

    public void update() {
        serialList.updateMenu();
        //Allow two drawing/update cycles to pass so that overlay can be drawn
        //This lets users know that auto-scan is working and GUI is not frozen
        if (midAutoScan) {
            if (midAutoScanCheck2) {
                cytonAutoConnect_AutoScan();
                midAutoScanCheck2 = false;
                midAutoScan = midAutoScanCheck2;
            }
            midAutoScanCheck2 = midAutoScan;
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
        text("SERIAL/COM PORT", x + padding, y + padding);
        popStyle();

        cytoncpb_cp5.draw();
    }

    private void createRefreshCytonDonglesButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        refreshCytonDongles = cytoncpb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        refreshCytonDongles
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        refreshCytonDongles.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                refreshPortListCyton();
            }
        });
    }

    private void createCytonDongleList(ControlP5 _cp5, String name, int _x, int _y, int _w, int _h, PFont font) {
        serialList = new MenuList(_cp5, name, _w, _h, font);
        serialList.setPosition(_x, _y);
        serialList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    Map bob = serialList.getItem(int(serialList.getValue()));
                    openBCI_portName = (String)bob.get("subline");
                    output("ControlPanel: Selected OpenBCI Port " + openBCI_portName);
                }
            }
        });
    }

    //This is called when the Auto-Connect button is pressed in another Control Panel Box
    public void attemptAutoConnectCyton() {
        println("\n-------------------------------------------------\nControlPanel: Attempting to Auto-Connect to Cyton\n-------------------------------------------------\n");
        LinkedList<String> comPorts = getCytonComPorts();
        if (!comPorts.isEmpty()) {
            openBCI_portName = comPorts.getFirst();
            if (cytonRadioCfg.get_channel()) {
                controlPanel.initBox.initButtonPressed();
            } else {                
                outputWarn("Found a Cyton dongle, but could not connect to the board. Auto-Scanning now...");
                midAutoScan = true;
            }
        } else {
            outputWarn("No Cyton dongles were found.");
        }
    }

    //If Cyton dongle exists, and fails to connect, try to Auto-Scan in the background to align Cyton/Dongle Channel
    //This is called after overlay has a chance to draw on top to inform users the GUI is working and not crashed
    private void cytonAutoConnect_AutoScan() {
        if (cytonRadioCfg.scan_channels()) {
            println("Successfully connected to Cyton using " + openBCI_portName);
            controlPanel.initBox.initButtonPressed();
        } else {
            outputError("Unable to connect to Cyton. Please check hardware and power source.");
        }
    }

    //Refresh the Cyton Dongle list
    public void refreshPortListCyton(){
        serialList.items.clear();

        Thread thread = new Thread(){
            public void run(){
                refreshCytonDongles.getCaptionLabel().setText("SEARCHING...");

                LinkedList<String> comPorts = getCytonComPorts();
                for (String comPort : comPorts) {
                    serialList.addItem("(Cyton) " + comPort, comPort, "");
                }
                serialList.updateMenu();
                refreshCytonDongles.getCaptionLabel().setText("REFRESH LIST");
            }
        };

        thread.start();
    }

    private LinkedList<String> getCytonComPorts() {
        final String[] names = {"FT231X USB UART", "VCP"};
        final SerialPort[] comPorts = SerialPort.getCommPorts();
        LinkedList<String> results = new LinkedList<String>();
        for (SerialPort comPort : comPorts) {
            for (String name : names) {
                if (comPort.toString().startsWith(name)) {
                    // on macos need to drop tty ports
                    if (isMac() && comPort.getSystemPortName().startsWith("tty")) {
                        continue;
                    }
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

    public boolean isAutoScanningForCytonSerial() {
        return midAutoScan;
    }
};

class BLEBox {
    public int x, y, w, h, padding; //size and position
    private volatile boolean bleIsRefreshing = false;
    private ControlP5 bleBox_cp5;
    private MenuList bleList;
    private Button refreshBLE;
    Map<String, String> bleMACAddrMap = new HashMap<String, String>();

    BLEBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 140 + _padding;
        padding = _padding;

        //Instantiate local cp5 for this box
        bleBox_cp5 = new ControlP5(ourApplet);
        bleBox_cp5.setGraphics(ourApplet, 0,0);
        bleBox_cp5.setAutoDraw(false);

        createRefreshBLEButton("refreshGanglionBLEButton", "START SEARCH", x + padding, y + padding*4 + 72 + 8, w - padding*5, 24, fontInfo.buttonLabel_size);
        createGanglionBLEMenuList(bleBox_cp5, "bleList", x + padding, y + padding*3 + 8, w - padding*2, 72, p3);
    }

    public void update() {
        bleList.updateMenu();
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
            image(loadingGIF_blue, w + 225,  refreshBLE.getPosition()[1] + 4, 20, 20);
        } else {
            //Draw small grey circle
            pushStyle();
            fill(#999999);
            ellipseMode(CENTER);
            ellipse(w + 225 + 10, refreshBLE.getPosition()[1] + 12, 12, 12);
            popStyle();
        }

        bleBox_cp5.draw();
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
                refreshBLE.getCaptionLabel().setText("SEARCHING...");
                bleIsRefreshing = true;
                final String comPort = getBLED112Port();
                if (comPort != null) {
                    try {
                        bleMACAddrMap = GUIHelper.scan_for_ganglions (comPort, 3);
                        for (Map.Entry<String, String> entry : bleMACAddrMap.entrySet ())
                        {
                            bleList.addItem(entry.getKey(), comPort, "");
                            bleList.updateMenu();
                        }
                    } catch (GanglionError e)
                    {
                        e.printStackTrace();
                    }
                } else {
                    outputError("No BLED112 Dongle Found");
                }
                refreshBLE.getCaptionLabel().setText("START SEARCH");
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

    private void createRefreshBLEButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        refreshBLE = bleBox_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        refreshBLE
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        refreshBLE.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                refreshGanglionBLEList();
            }
        });
    }

    private void createGanglionBLEMenuList(ControlP5 _cp5, String name, int _x, int _y, int _w, int _h, PFont font) {
        bleList = new MenuList(_cp5, name, _w, _h, font);
        bleList.setPosition(_x, _y);
        bleList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    Map bob = bleList.getItem(int(bleList.getValue()));
                    ganglion_portName = (String)bob.get("headline");
                    output("Ganglion Device Name = " + ganglion_portName);
                }
            }
        });
    }
};

class WifiBox {
    public int x, y, w, h, padding; //size and position
    private boolean wifiIsRefreshing = false;
    private ControlP5 wifiBox_cp5;
    private MenuList wifiList;
    private Button refreshWifi;
    private Button wifiIPAddressDynamic;
    private Button wifiIPAddressStatic;
    private Textfield staticIPAddressTF;
    private int wifiDynamic_x;
    private int wifiStatic_x;
    private int wifiButtons_y;
    private int refreshWifi_x;
    private int refreshWifi_y;

    WifiBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 184 + _padding + 14;
        padding = _padding;

        //Instantiate local cp5 for this box
        wifiBox_cp5 = new ControlP5(ourApplet);
        wifiBox_cp5.setGraphics(ourApplet, 0,0);
        wifiBox_cp5.setAutoDraw(false);

        wifiDynamic_x = x + padding;
        wifiStatic_x = x + padding*2 + (w-padding*3)/2;
        wifiButtons_y = y + padding*2 + 16;
        createDynamicIPAddressButton("wifiIPAddressDynamicButton", "DYNAMIC IP", wifiDynamic_x, wifiButtons_y, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
        createStaticIPAddressButton("wifiIPAddressStaticButton", "STATIC IP", wifiStatic_x, wifiButtons_y, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);

        refreshWifi_x = x + padding;
        refreshWifi_y = y + padding*5 + 72 + 8 + 24;
        createRefreshWifiButton("refreshWifiButton", "START SEARCH", refreshWifi_x, refreshWifi_y, w - padding*5, 24, fontInfo.buttonLabel_size);
        createWifiList(wifiBox_cp5, "wifiList", x + padding, y + padding*4 + 8 + 24, w - padding*2, 72 + 8, p3);
        createStaticIPAddressTextfield();
    }

    public void update() {
        wifiList.updateMenu();
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
        popStyle();

        wifiButtons_y = y + padding*2 + 16;
        wifiIPAddressDynamic.setPosition(wifiDynamic_x, wifiButtons_y);
        wifiIPAddressStatic.setPosition(wifiStatic_x, wifiButtons_y);

        if (controlPanel.getWifiSearchStyle() == controlPanel.WIFI_STATIC) {
            pushStyle();
            fill(bgColor);
            textFont(h3, 16);
            textAlign(LEFT, TOP);
            text("ENTER IP ADDRESS", x + padding, y + h - 24 - 12 - padding*2);
            popStyle();
            staticIPAddressTF.setPosition(x + padding, y + h - 24 - padding);
        } else {
            wifiList.setPosition(x + padding, wifiButtons_y + 24 + padding);

            refreshWifi_y = y + h - padding - 24;
            refreshWifi.setPosition(refreshWifi_x, refreshWifi_y);

            String boardIpInfo = "BOARD IP: ";
            if (wifi_portName != "N/A") { // If user has selected a board from the menulist...
                boardIpInfo += wifi_ipAddress;
            }
            pushStyle();
            fill(bgColor);
            textFont(h3, 16);
            textAlign(LEFT, TOP);
            text(boardIpInfo, x + w/2 - textWidth(boardIpInfo)/2, y + h - padding - 46);

            if (wifiIsRefreshing){
                //Display spinning cog gif
                image(loadingGIF_blue, w + 225,  refreshWifi_y + 4, 20, 20);
            } else {
                //Draw small grey circle
                pushStyle();
                fill(#999999);
                ellipseMode(CENTER);
                ellipse(w + 225 + 10, refreshWifi_y + 12, 12, 12);
                popStyle();
            }
        }

        wifiBox_cp5.draw();
    }

    public void refreshWifiList() {
        output("Wifi Devices Refreshing");
        wifiList.items.clear();
        Thread thread = new Thread(){
            public void run() {
                refreshWifi.getCaptionLabel().setText("SEARCHING...");
                wifiIsRefreshing = true;
                try {
                    List<Device> devices = SSDPClient.discover (3000, "urn:schemas-upnp-org:device:Basic:1");
                    if (devices.isEmpty ()) {
                        println("No WIFI Shields found");
                    }
                    for (int i = 0; i < devices.size(); i++) {
                        wifiList.addItem(devices.get(i).getName(), devices.get(i).getIPAddress(), "");
                    }
                    wifiList.updateMenu();
                } catch (Exception e) {
                    println("Exception in wifi shield scanning");
                    e.printStackTrace ();
                }
                refreshWifi.getCaptionLabel().setText("START SEARCH");
                wifiIsRefreshing = false;
            }
        };
        thread.start();
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = wifiBox_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        return myButton;
    }

    private void createDynamicIPAddressButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        wifiIPAddressDynamic = createButton(wifiIPAddressDynamic, name, text, _x, _y, _w, _h, _fontSize);
        wifiIPAddressDynamic.setSwitch(true);
        wifiIPAddressDynamic.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                h = 208;
                controlPanel.setWiFiSearchStyle(controlPanel.WIFI_DYNAMIC);
                println("ControlPanel: Using Dynamic IP address of the WiFi Shield!");
                wifiIPAddressDynamic.setOn();
                wifiIPAddressStatic.setOff();
                staticIPAddressTF.setVisible(false);
                wifiList.setVisible(true);
            }
        });
        wifiIPAddressDynamic.setOn();
    }

    private void createStaticIPAddressButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        wifiIPAddressStatic = createButton(wifiIPAddressStatic, name, text, _x, _y, _w, _h, _fontSize);
        wifiIPAddressStatic.setSwitch(true);
        wifiIPAddressStatic.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                h = 120;
                controlPanel.setWiFiSearchStyle(controlPanel.WIFI_STATIC);
                println("ControlPanel: Using Static IP address of the WiFi Shield!");
                wifiIPAddressDynamic.setOff();
                wifiIPAddressStatic.setOn();
                staticIPAddressTF.setVisible(true);
                wifiList.setVisible(false);
            }
        });
    }

    private void createRefreshWifiButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        refreshWifi = createButton(wifiIPAddressStatic, name, text, _x, _y, _w, _h, _fontSize);
        refreshWifi.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                refreshWifiList();
            }
        });
    }

    private void createWifiList(ControlP5 _cp5, String name, int _x, int _y, int _w, int _h, PFont font) {
        wifiList = new MenuList(_cp5, name, _w, _h, font);
        wifiList.setPosition(_x, _y);
        wifiList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    Map bob = wifiList.getItem(int(wifiList.getValue()));
                    wifi_portName = (String)bob.get("headline");
                    wifi_ipAddress = (String)bob.get("subline");
                    output("Selected WiFi Board: " + wifi_portName+ ", WiFi IP Address: " + wifi_ipAddress );
                }
            }
        });
    }

    private void createStaticIPAddressTextfield() {
        staticIPAddressTF = wifiBox_cp5.addTextfield("staticIPAddress")
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
            .setAutoClear(true)
            .setVisible(false);
    }

    public void setDefaultToDynamicIP() {
        h = 208;
        controlPanel.setWiFiSearchStyle(controlPanel.WIFI_DYNAMIC);
        wifiIPAddressDynamic.setOn();
        wifiIPAddressStatic.setOff();
        staticIPAddressTF.setVisible(false);
        wifiList.setVisible(true);
    }

    private void setStaticIPTextfield(String text) {
        staticIPAddressTF.getCaptionLabel().setText(text);
    }

    //Clear text field on double-click
    CallbackListener cb = new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
            staticIPAddressTF.clear();
        }
    };
};

class InterfaceBoxCyton {
    public int x, y, w, h, padding; //size and position
    private ControlP5 ifbc_cp5;
    private Button protocolSerialCyton;
    private Button protocolWifiCyton;

    InterfaceBoxCyton(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = (24 + _padding) * 3;
        padding = _padding;

        //Instantiate local cp5 for this box
        ifbc_cp5 = new ControlP5(ourApplet);
        ifbc_cp5.setGraphics(ourApplet, 0,0);
        ifbc_cp5.setAutoDraw(false);

        //Disabled both toggles by default for this box
        createSerialCytonButton("protocolSerialCyton", "Serial (from Dongle)", false, x + padding, y + padding * 3 + 4, w - padding * 2, 24, fontInfo.buttonLabel_size);
        createWifiCytonButton("protocolWifiCyton", "Wifi (from Wifi Shield)", false, x + padding, y + padding * 4 + 24 + 4, w - padding * 2, 24, fontInfo.buttonLabel_size);
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

        ifbc_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = ifbc_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        myButton.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            myButton.setOn();
        }
        return myButton;
    }

    private void createSerialCytonButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        protocolSerialCyton = createButton(protocolSerialCyton, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        protocolSerialCyton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.wifiBox.wifiList.items.clear();
                controlPanel.bleBox.bleList.items.clear();
                selectedProtocol = BoardProtocol.SERIAL;
                controlPanel.comPortBox.refreshPortListCyton();
                protocolSerialCyton.setOn();
                protocolWifiCyton.setOff();
            }
        });
    }

    private void createWifiCytonButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        protocolWifiCyton = createButton(protocolWifiCyton, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        protocolWifiCyton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.wifiBox.wifiList.items.clear();
                controlPanel.bleBox.bleList.items.clear();
                selectedProtocol = BoardProtocol.WIFI;
                protocolSerialCyton.setOff();
                protocolWifiCyton.setOn();
            }
        });
    }

    public void resetCytonSelectedProtocol() {
        protocolSerialCyton.setOff();
        protocolWifiCyton.setOff();
        selectedProtocol = BoardProtocol.NONE;
    }
};

class InterfaceBoxGanglion {
    public int x, y, w, h, padding; //size and position
    private ControlP5 ifbg_cp5;
    private Button protocolBLED112Ganglion;
    private Button protocolWifiGanglion;

    InterfaceBoxGanglion(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        padding = _padding;
        h = (24 + _padding) * 3;
        int buttonHeight = 24;

            //Instantiate local cp5 for this box
        ifbg_cp5 = new ControlP5(ourApplet);
        ifbg_cp5.setGraphics(ourApplet, 0,0);
        ifbg_cp5.setAutoDraw(false);

        createBLED112Button("protocolBLED112Ganglion", "Bluetooth (BLED112 Dongle)", false, x + padding, y + padding * 3 + 4, w - padding * 2, 24, fontInfo.buttonLabel_size);
        createGanglionWifiButton("protocolWifiGanglion", "Wifi (from Wifi Shield)", false, x + padding, y + padding * 4 + 24 + 4, w - padding * 2, 24, fontInfo.buttonLabel_size);
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
        
        ifbg_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = ifbg_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        myButton.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            myButton.setOn();
        }
        return myButton;
    }

    private void createBLED112Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        protocolBLED112Ganglion = createButton(protocolBLED112Ganglion, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        protocolBLED112Ganglion.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.wifiBox.wifiList.items.clear();
                controlPanel.bleBox.bleList.items.clear();
                selectedProtocol = BoardProtocol.BLED112;
                controlPanel.bleBox.refreshGanglionBLEList();
                protocolBLED112Ganglion.setOn();
                protocolWifiGanglion.setOff();
            }
        });
    }

    private void createGanglionWifiButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        protocolWifiGanglion = createButton(protocolWifiGanglion, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        protocolWifiGanglion.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.wifiBox.wifiList.items.clear();
                controlPanel.bleBox.bleList.items.clear();
                selectedProtocol = BoardProtocol.WIFI;
                protocolBLED112Ganglion.setOff();
                protocolWifiGanglion.setOn();
            }
        });
    }

    public void resetGanglionSelectedProtocol() {
        protocolBLED112Ganglion.setOff();
        protocolWifiGanglion.setOff();
        selectedProtocol = BoardProtocol.NONE;
    }
};

class SessionDataBox {
    public int x, y, w, h, padding; //size and position
    private int datasource;
    private final int bdfModeHeight = 127;
    private int odfModeHeight;

    private ControlP5 sessionData_cp5;
    private int maxDurTextWidth = 82;
    private int maxDurText_x = 0;
    private Textfield sessionNameTextfield;
    private Button autoSessionName;
    private Button outputODF;
    private Button outputBDF;
    private ScrollableList maxDurationDropdown;
    private String odfMessage = "Output has been set to OpenBCI Data Format (CSV).";
    private String bdfMessage = "Output has been set to BioSemi Data Format (BDF+).";

    SessionDataBox (int _x, int _y, int _w, int _h, int _padding, int _dataSource, int output, String textfieldName) {
        datasource = _dataSource;
        odfModeHeight = bdfModeHeight + 24 + _padding;
        x = _x;
        y = _y;
        w = _w;
        h = odfModeHeight;
        padding = _padding;
        maxDurText_x = x + padding;
        maxDurTextWidth += padding*5 + 1;

        //Instantiate local cp5 for this box
        sessionData_cp5 = new ControlP5(ourApplet);
        sessionData_cp5.setGraphics(ourApplet, 0,0);
        sessionData_cp5.setAutoDraw(false);

        createSessionNameTextfield(textfieldName);

        //button to autogenerate file name based on time/date
        createAutoSessionNameButton("autoSessionName", "GENERATE SESSION NAME", x + padding, y + 66, w-(padding*2), 24, fontInfo.buttonLabel_size);
        //autoSessionName.setHelpText("Autogenerate a session name based on the date and time.");
        createODFButton("odfButton", "OpenBCI", dataLogger.getDataLoggerOutputFormat(), x + padding, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
        //outputODF.setHelpText("Set GUI data output to OpenBCI Data Format (.txt). A new file will be made in the session folder when the data stream is paused or max file duration is reached.");
        createBDFButton("bdfButton", "BDF+", dataLogger.getDataLoggerOutputFormat(), x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
        //outputBDF.setHelpText("Set GUI data output to BioSemi Data Format (.bdf). All session data is contained in one .bdf file. View using an EDF/BDF browser.");

        createMaxDurationDropdown("maxFileDuration", Arrays.asList(settings.fileDurations));
        
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
        
        //Update the position of UI elements here, as this changes when user selects WiFi mode
        sessionNameTextfield.setPosition(x + 60, y + 32);
        autoSessionName.setPosition(x + padding, y + 66);
        outputODF.setPosition(x + padding, y + padding*2 + 18 + 58);
        outputBDF.setPosition(x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58);
        maxDurationDropdown.setPosition(x + maxDurTextWidth, int(outputODF.getPosition()[1]) + 24 + padding);
        
        boolean odfIsSelected = dataLogger.getDataLoggerOutputFormat() == dataLogger.OUTPUT_SOURCE_ODF;
        maxDurationDropdown.setVisible(odfIsSelected);
        
        if (odfIsSelected) {
            pushStyle();
            //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
            //Dropdown is drawn at the end of ControlPanel.draw()
            fill(bgColor);
            maxDurationDropdown.setPosition(x + maxDurTextWidth, int(outputODF.getPosition()[1]) + 24 + padding);
            //Carefully draw some text to the left of above dropdown, otherwise this text moves when changing WiFi mode
            int extraPadding = (controlPanel.getWifiSearchStyle() == controlPanel.WIFI_STATIC) || selectedProtocol != BoardProtocol.WIFI
                ? 20 
                : 5;
            fill(bgColor);
            textFont(p4, 14);
            text("Max File Duration", maxDurText_x, y + h - 24 - padding + extraPadding);
            popStyle();
        }
        sessionData_cp5.draw();
    }

    private void createSessionNameTextfield(String name) {
        //Create textfield to allow user to type custom session folder name
        sessionNameTextfield = sessionData_cp5.addTextfield(name)
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
            .setAutoClear(false); //Don't clear textfield when pressing Enter key
        //Clear textfield on double click
        sessionNameTextfield.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("SessionData: Enter your custom session name.");
                sessionNameTextfield.clear();
            }
        });
        //Autogenerate session name if user presses Enter key and textfield value is null
        sessionNameTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && sessionNameTextfield.getText().equals("")) {
                    autogenerateSessionName();
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        sessionNameTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!sessionNameTextfield.isActive() && sessionNameTextfield.getText().equals("")) {
                    autogenerateSessionName();
                }
            }
        });
    }

    private void createMaxDurationDropdown(String name, List<String> _items){
        maxDurationDropdown = new CustomScrollableList(sessionData_cp5, name)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            .setBackgroundColor(150)
            //.setColorBackground(color(31,69,110)) // text field bg color
            //.setColorValueLabel(color(0))       // text color
            //.setColorCaptionLabel(color(255))
            //.setColorForeground(color(125))    // border color when not selected
            //.setColorActive(color(150, 170, 200))       // border color when selected
            // .setColorCursor(color(26,26,26))
            .setPosition(x + maxDurTextWidth, int(outputODF.getPosition()[1]) + 24 + padding)
            .setSize((w-padding*3)/2, (_items.size() + 1) * 24)// + maxFreqList.size())
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .addItems(_items) // used to be .addItems(maxFreqList)
            .setVisible(false)
            ;
        maxDurationDropdown
            .getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(settings.fileDurations[settings.defaultOBCIMaxFileSize])
            .setFont(p4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        maxDurationDropdown
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(settings.fileDurations[settings.defaultOBCIMaxFileSize])
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        maxDurationDropdown.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {    
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int n = (int)(theEvent.getController()).getValue();
                    settings.setLogFileDurationChoice(n);
                    println("ControlPanel: Chosen Recording Duration: " + n);
                } else if (theEvent.getAction() == ControlP5.ACTION_ENTER) {
                    lockOutsideElements(true);
                } else if (theEvent.getAction() == ControlP5.ACTION_LEAVE) {
                    ScrollableList theList = (ScrollableList)(theEvent.getController());
                    lockOutsideElements(theList.isOpen());
                }
            }
        });
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = sessionData_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        return myButton;
    }

    private void createAutoSessionNameButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        autoSessionName = createButton(autoSessionName, name, text, _x, _y, _w, _h, _fontSize);
        autoSessionName.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                autogenerateSessionName();
            }
        });
    }

    private void createODFButton(String name, String text, int dataLoggerFormat, int _x, int _y, int _w, int _h, int _fontSize) {
        boolean formatIsODF = dataLoggerFormat == dataLogger.OUTPUT_SOURCE_ODF;
        outputODF = createButton(outputODF, name, text, _x, _y, _w, _h, _fontSize);
        outputODF.setSwitch(true);
        if (formatIsODF) {
            outputODF.setOn();
        } else {
            outputODF.setOff();
        }
        outputODF.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output(odfMessage);
                dataLogger.setDataLoggerOutputFormat(dataLogger.OUTPUT_SOURCE_ODF);
                outputODF.setOn();
                outputBDF.setOff();
                setToODFHeight();
            }
        });
    }

    private void createBDFButton(String name, String text, int dataLoggerFormat, int _x, int _y, int _w, int _h, int _fontSize) {
        boolean formatIsBDF = dataLoggerFormat == dataLogger.OUTPUT_SOURCE_BDF;
        outputBDF = createButton(outputBDF, name, text, _x, _y, _w, _h, _fontSize);
        outputBDF.setSwitch(true);
        if (formatIsBDF) {
            outputBDF.setOn();
        } else {
            outputBDF.setOff();
        }
        outputBDF.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output(bdfMessage);
                dataLogger.setDataLoggerOutputFormat(dataLogger.OUTPUT_SOURCE_BDF);
                outputBDF.setOn();
                outputODF.setOff();
                setToBDFHeight();
            }
        });
    }

    private void autogenerateSessionName() {
        output("Autogenerated Session Name based on current date & time.");
        sessionNameTextfield.setText(directoryManager.getFileNameDateTime());
    }

    public void setToODFHeight() {
        h = odfModeHeight;
    }

    public void setToBDFHeight() {
        h = bdfModeHeight;
    }

    public String getSessionTextfieldString() {
        return sessionNameTextfield.getText();
    }

    public void setSessionTextfieldText(String s) {
        sessionNameTextfield.setText(s);
    }

    // True locks elements, False unlocks elements
    private void lockOutsideElements (boolean _toggle) {
        if (eegDataSource == DATASOURCE_CYTON) {
            //Cyton for Serial and WiFi (WiFi details are drawn to the right, so no need to lock)
            controlPanel.channelCountBox.lockCp5Objects(_toggle);
            if (_toggle) {
                controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).lock();
            } else {
                controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).unlock();
            }
            controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).setUpdate(!_toggle);
        } else {
            controlPanel.sampleRateGanglionBox.lockCp5Objects(_toggle);
        }
    }

    public void lockSessionDataBoxCp5Elements(boolean b) {
        sessionNameTextfield.setLock(b);
        autoSessionName.setLock(b);
        outputODF.setLock(b);
        outputBDF.setLock(b);
    }
};

class ChannelCountBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 ccc_cp5;
    private Button chanButton8;
    private Button chanButton16;
    private int cb8_butX;
    private int cb16_butX;
    private int cb_butY;

    ChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        //Instantiate local cp5 for this box
        ccc_cp5 = new ControlP5(ourApplet);
        ccc_cp5.setGraphics(ourApplet, 0,0);
        ccc_cp5.setAutoDraw(false);

        cb8_butX = x + padding;
        cb16_butX = x + padding*2 + (w-padding*3)/2;
        cb_butY = y + padding*2 + 18;
        boolean is8Channels = (nchan == 8) ? true : false;
        createChan8Button("cyton8ChanButton", "8 CHANNELS", is8Channels, cb8_butX, cb_butY, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
        createChan16Button("cyton16ChanButton", "16 CHANNELS", is8Channels, cb16_butX, cb_butY, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
    }

    public void update() {
    }

    public void draw() {
        cb_butY = y + padding*2 + 18;
        chanButton8.setPosition(cb8_butX, cb_butY);
        chanButton16.setPosition(cb16_butX, cb_butY);

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

        ccc_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = ccc_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        myButton.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            myButton.setOn();
        }
        return myButton;
    }

    private void createChan8Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        chanButton8 = createButton(chanButton8, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        chanButton8.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateToNChan(8);
                chanButton8.setOn();
                chanButton16.setOff();
            }
        });
    }

    private void createChan16Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        chanButton16 = createButton(chanButton16, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        chanButton16.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateToNChan(16);
                chanButton8.setOff();
                chanButton16.setOn();
            }
        });
    }

    public void lockCp5Objects(boolean flag) {
        chanButton8.setLock(flag);
        chanButton16.setLock(flag);
    }

    public void set8ChanButtonActive() {
        updateToNChan(8);
        chanButton8.setOn();
        chanButton16.setOff();
    }
};

class SampleRateGanglionBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 srgb_cp5;
    private Button sampleRate200;
    private Button sampleRate1600;
    private int sr200_butX;
    private int sr1600_butX;
    private int srButton_butY;

    SampleRateGanglionBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        //Instantiate local cp5 for this box
        srgb_cp5 = new ControlP5(ourApplet);
        srgb_cp5.setGraphics(ourApplet, 0,0);
        srgb_cp5.setAutoDraw(false);

        sr200_butX = x + padding;
        sr1600_butX = x + padding*2 + (w-padding*3)/2;
        srButton_butY =  y + padding*2 + 18;
        createSR200Button("cytonSR200", "200Hz", false, sr200_butX, srButton_butY, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
        createSR1600Button("cytonSR1600", "1600Hz", true, sr1600_butX, srButton_butY, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
    }

    public void update() {
    }

    public void draw() {
        srButton_butY =  y + padding*2 + 18;
        sampleRate200.setPosition(sr200_butX, srButton_butY);
        sampleRate1600.setPosition(sr1600_butX, srButton_butY);

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

        srgb_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = srgb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        myButton.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            myButton.setOn();
        }
        return myButton;
    }

    private void createSR200Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        sampleRate200 = createButton(sampleRate200, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        sampleRate200.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectedSamplingRate = 200;
                println("ControlPanel: User selected Ganglion+WiFi 200Hz");
                sampleRate200.setOn();
                sampleRate1600.setOff();
            }
        });
    }

    private void createSR1600Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        sampleRate1600 = createButton(sampleRate1600, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        sampleRate1600.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectedSamplingRate = 1600;
                println("ControlPanel: User selected Ganglion+WiFi 1600Hz");
                sampleRate200.setOff();
                sampleRate1600.setOn();
            }
        });
    }

    public void lockCp5Objects(boolean flag) {
        sampleRate200.setLock(flag);
        sampleRate1600.setLock(flag);
    }
};

class SampleRateCytonBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 srcb_cp5;
    private Button sampleRate250;
    private Button sampleRate500;
    private Button sampleRate1000;
    private int sr250_butX;
    private int sr500_butX;
    private int sr1000_butX;
    private int srButton_butY;

    SampleRateCytonBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        //Instantiate local cp5 for this box
        srcb_cp5 = new ControlP5(ourApplet);
        srcb_cp5.setGraphics(ourApplet, 0,0);
        srcb_cp5.setAutoDraw(false);

        sr250_butX = x + padding;
        sr500_butX = x + padding*2 + (w-padding*4)/3;
        sr1000_butX = x + padding*3 + ((w-padding*4)/3)*2;
        srButton_butY =  y + padding*2 + 18;
        createSR250Button("cytonSR250", "250Hz", false, sr250_butX, srButton_butY, (w-padding*4)/3, 24, fontInfo.buttonLabel_size);
        createSR500Button("cytonSR500", "500Hz", false, sr500_butX, srButton_butY, (w-padding*4)/3, 24, fontInfo.buttonLabel_size);
        //Make 1000Hz option selected by default
        createSR1000Button("cytonSR1000", "1000Hz", true, sr1000_butX, srButton_butY, (w-padding*4)/3, 24, fontInfo.buttonLabel_size);
    }

    public void update() {

    }

    public void draw() {

        srButton_butY =  y + padding*2 + 18;
        sampleRate250.setPosition(sr250_butX, srButton_butY);
        sampleRate500.setPosition(sr500_butX, srButton_butY);
        sampleRate1000.setPosition(sr1000_butX, srButton_butY);

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

        srcb_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = srcb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        myButton.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            myButton.setOn();
        }
        return myButton;
    }

    private void createSR250Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        sampleRate250 = createButton(sampleRate250, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        sampleRate250.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectedSamplingRate = 250;
                println("ControlPanel: User selected Cyton+WiFi 250Hz");
                sampleRate250.setOn();
                sampleRate500.setOff();
                sampleRate1000.setOff();
            }
        });
    }

    private void createSR500Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        sampleRate500 = createButton(sampleRate500, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        sampleRate500.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectedSamplingRate = 500;
                println("ControlPanel: User selected Cyton+WiFi 500Hz");
                sampleRate250.setOff();
                sampleRate500.setOn();
                sampleRate1000.setOff();
            }
        });
    }

    private void createSR1000Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h, int _fontSize) {
        sampleRate1000 = createButton(sampleRate1000, name, text, isToggled, _x, _y, _w, _h, _fontSize);
        sampleRate1000.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectedSamplingRate = 1000;
                println("ControlPanel: User selected Cyton+WiFi 1000Hz");
                sampleRate250.setOff();
                sampleRate500.setOff();
                sampleRate1000.setOn();
            }
        });
    }
};

class SyntheticChannelCountBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 sccb_cp5;
    private Button synthChanButton4;
    private Button synthChanButton8;
    private Button synthChanButton16;

    SyntheticChannelCountBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 73;
        padding = _padding;

        //Instantiate local cp5 for this box
        sccb_cp5 = new ControlP5(ourApplet);
        sccb_cp5.setGraphics(ourApplet, 0,0);
        sccb_cp5.setAutoDraw(false);

        createSynthChan4Button("synthChan4Button", "4 chan", x + padding, y + padding*2 + 18, (w-padding*4)/3, 24, fontInfo.buttonLabel_size);
        createSynthChan8Button("synthChan8Button", "8 chan", x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24, fontInfo.buttonLabel_size);
        createSynthChan16Button("synthChan16Button", "16 chan", x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24, fontInfo.buttonLabel_size);
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

        sccb_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = sccb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        myButton.setSwitch(true); //This turns the button into a switch
        return myButton;
    }

    private void createSynthChan4Button(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        synthChanButton4 = createButton(synthChanButton4, name, text, _x, _y, _w, _h, _fontSize);
        synthChanButton4.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateToNChan(4);
                synthChanButton4.setOn();
                synthChanButton8.setOff();
                synthChanButton16.setOff();
            }
        });
    }

    private void createSynthChan8Button(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        synthChanButton8 = createButton(synthChanButton8, name, text, _x, _y, _w, _h, _fontSize);
        synthChanButton8.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateToNChan(8);
                synthChanButton4.setOff();
                synthChanButton8.setOn();
                synthChanButton16.setOff();
            }
        });
        //Default is 8 channels when app starts
        synthChanButton8.setOn();
    }

    private void createSynthChan16Button(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        synthChanButton16 = createButton(synthChanButton16, name, text, _x, _y, _w, _h, _fontSize);
        synthChanButton16.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateToNChan(16);
                synthChanButton4.setOff();
                synthChanButton8.setOff();
                synthChanButton16.setOn();
            }
        });
    }

    public void set8ChanButtonActive() {
        updateToNChan(8);
        synthChanButton4.setOff();
        synthChanButton8.setOn();
        synthChanButton16.setOff();
    }
};

class RecentPlaybackBox {
    public int x, y, w, h, padding; //size and position
    private StringList shortFileNames = new StringList();
    private StringList longFilePaths = new StringList();
    private String filePickedShort = "Select Recent Playback File";
    private ControlP5 rpb_cp5;
    private ScrollableList recentPlaybackSL;
    private int titleH = 14;
    private int buttonH = 24;

    RecentPlaybackBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = titleH + buttonH + _padding*3;
        padding = _padding;

        rpb_cp5 = new ControlP5(ourApplet);
        rpb_cp5.setGraphics(ourApplet, 0,0);
        rpb_cp5.setAutoDraw(false);

        getRecentPlaybackFiles();

        String[] temp = shortFileNames.array();
        createRecentPlaybackFilesDropdown("recentPlaybackFilesCP", Arrays.asList(temp));
    }

    public void update() {
        //Update the dropdown list if it has not already been done
        if (!recentPlaybackFilesHaveUpdated) {
            recentPlaybackSL.clear();
            getRecentPlaybackFiles();
            String[] temp = shortFileNames.array();
            recentPlaybackSL.addItems(temp);
            recentPlaybackSL.setSize(w - padding*2, (temp.length + 1) * buttonH);
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
        rect(x, y, w, h + recentPlaybackSL.getHeight() - padding*2.5);
        fill(bgColor);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PLAYBACK HISTORY", x + padding, y + padding);
        popStyle();
        recentPlaybackSL.setVisible(true);
        rpb_cp5.draw();
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

    void createRecentPlaybackFilesDropdown(String name, List<String> _items){
        recentPlaybackSL = new CustomScrollableList(rpb_cp5, name)
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
        recentPlaybackSL
            .getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(filePickedShort)
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        recentPlaybackSL
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(filePickedShort)
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        recentPlaybackSL.setPosition(x + padding, y + padding*2 + 13);
        recentPlaybackSL.setSize(w - padding*2, (_items.size() + 1) * buttonH);
        recentPlaybackSL.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int s = (int)recentPlaybackSL.getValue();
                    //println("got a menu event from item " + s);
                    String filePath = longFilePaths.get(s);
                    if (new File(filePath).isFile()) {
                        playbackFileFromList(filePath, s);
                    } else {
                        verbosePrint("Playback History: " + filePath);
                        outputError("Playback History: Selected file does not exist. Try another file or clear settings to remove this entry.");
                    }
                }
            }
        });
    }
};

class GaleaBox {
    public int x, y, w, h, padding; //size and position
    private final String boxLabel = "GALEA CONFIG";
    private final String ipAddressLabel = "IP Address";
    private final String sampleRateLabel = "Sample Rate";
    private String ipAddress = "192.168.4.1";
    private ControlP5 localCP5;
    private Textfield ipAddressTF;
    private ScrollableList srList;
    private ScrollableList modeList;
    private final int titleH = 14;
    private final int uiElementH = 24;

    GaleaBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = titleH + uiElementH*3 + _padding*5;
        padding = _padding;
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false); //Setting this saves code as cp5 elements will only be drawn/visible when [cp5].draw() is called
        createIPTextfield();
        createModeListDropdown();
        createSampleRateDropdown(); //Create this last so it draws on top of Mode List Dropdown
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
        text(sampleRateLabel, x + padding, srList.getPosition()[1] + 2);
        text(ipAddressLabel, x + padding, ipAddressTF.getPosition()[1] + 2);
        popStyle();
        
        //draw cp5 last, on top of everything in this box
        localCP5.draw();
    }

    private void createIPTextfield() {
        ipAddressTF = localCP5.addTextfield("ipAddress")
            .setPosition(x + w - padding*2 - 60*2, y + 16 + padding*2)
            .setCaptionLabel("")
            .setSize(120 + padding, 26)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(color(0, 0, 0))  // text color
            .setColorForeground(isSelected_color)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText(ipAddress)
            .align(5, 10, 20, 40)
            .setAutoClear(false) //Don't clear textfield when pressing Enter key
            ;
        //Clear textfield on double click
        ipAddressTF.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("ControlPanel: Enter IP address of the Galea you wish to connect to.");
                ipAddressTF.clear();
            }
        });
        ipAddressTF.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if ((theEvent.getAction() == ControlP5.ACTION_BROADCAST) || (theEvent.getAction() == ControlP5.ACTION_LEAVE)) {
                    ipAddress = ipAddressTF.getText();
                    ipAddressTF.setFocus(false);
                }
            }
        });
    }

    private ScrollableList createDropdown(String name, GaleaSettingsEnum[] enumValues){
        ScrollableList list = new CustomScrollableList(localCP5, name)
            .setOpen(false)
            .setColorBackground(color(31,69,110)) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            .setBackgroundColor(150)
            .setSize(w - padding*2, uiElementH)//temporary size
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (GaleaSettingsEnum value : enumValues) {
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

    private void createSampleRateDropdown() {
        srList = createDropdown("galea_SampleRates", GaleaSR.values());
        srList.setPosition(x + w - padding*2 - 60*2, y + titleH + uiElementH + padding*3);
        srList.setSize(120 + padding,(srList.getItems().size()+1)*uiElementH);
        srList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int val = (int)srList.getValue();
                    Map bob = srList.getItem(val);
                    // this will retrieve the enum object stored in the dropdown!
                    galea_sampleRate = (GaleaSR)bob.get("value");
                    println("ControlPanel: User selected Galea Sample Rate: " + galea_sampleRate.getName());
                } else if (theEvent.getAction() == ControlP5.ACTION_ENTER) {
                    //Lock the box below this one when user is interacting with this dropdown
                    controlPanel.dataLogBoxGalea.lockSessionDataBoxCp5Elements(true);
                } else if (theEvent.getAction() == ControlP5.ACTION_LEAVE) {
                    controlPanel.dataLogBoxGalea.lockSessionDataBoxCp5Elements(false);
                }
            }
        });
    }

    private void createModeListDropdown() {
        modeList = createDropdown("galea_Modes", GaleaMode.values());
        modeList.setPosition(x + padding, y + titleH + uiElementH*2 + padding*4);
        modeList.setSize(w - padding*2,(modeList.getItems().size()+1)*uiElementH);
        modeList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int val = (int)modeList.getValue();
                    Map bob = modeList.getItem(val);
                    // this will retrieve the enum object stored in the dropdown!
                    galea_boardSetting = (GaleaMode)bob.get("value");
                    println("ControlPanel: User selected Galea Mode: " + galea_boardSetting.getName());
                } else if (theEvent.getAction() == ControlP5.ACTION_ENTER) {
                    //Lock the box below this one when user is interacting with this dropdown
                    controlPanel.dataLogBoxGalea.lockSessionDataBoxCp5Elements(true);
                } else if (theEvent.getAction() == ControlP5.ACTION_LEAVE) {
                    controlPanel.dataLogBoxGalea.lockSessionDataBoxCp5Elements(false);
                }
            }
        });
    }

    public String getIPAddress() {
        return ipAddress;
    }
};

class StreamingBoardBox {
    public int x, y, w, h, padding; //size and position
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

    //Clear text field on double-click
    CallbackListener cb = new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
            port.clear();
        }
    };
};

class PlaybackFileBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 pbfb_cp5;
    private Button sampleDataButton;
    private Button selectPlaybackFile;
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

        //Instantiate local cp5 for this box
        pbfb_cp5 = new ControlP5(ourApplet);
        pbfb_cp5.setGraphics(ourApplet, 0,0);
        pbfb_cp5.setAutoDraw(false);

        createSelectPlaybackFileButton("selectPlaybackFileControlPanel", "SELECT OPENBCI PLAYBACK FILE", x + padding, y + padding*2 + titleH, w - padding*2, buttonH, fontInfo.buttonLabel_size);
        createSampleDataButton("selectSampleDataControlPanel", "Sample Data", x + w - sampleDataButton_w - padding, y + padding - 2, sampleDataButton_w, sampleDataButton_h, 14);
        
        //selectPlaybackFile.setHelpText("Click to open a dialog box to select an OpenBCI playback file (.txt or .csv).");
        //sampleDataButton.setCornerRoundess((int)(sampleDataButton_h));
        //sampleDataButton.setHelpText("Click to open the folder containing OpenBCI GUI Sample Data.");
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

        pbfb_cp5.draw();
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, int _fontSize, color _bgColor, color _textColor) {
        myButton = pbfb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(_bgColor)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            .setColor(_textColor)
            ;
        return myButton;
    }

    private void createSelectPlaybackFileButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        selectPlaybackFile = createButton(selectPlaybackFile, name, text, _x, _y, _w, _h, _fontSize, colorNotPressed, color(0));
        selectPlaybackFile.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Select a file for playback");
                selectInput("Select a pre-recorded file for playback:", 
                            "playbackFileSelected",
                            new File(directoryManager.getGuiDataPath() + "Recordings")
                );
            }
        });
    }

    private void createSampleDataButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        sampleDataButton = createButton(sampleDataButton, name, text, _x, _y, _w, _h, _fontSize, buttonsLightBlue, color(255));
        sampleDataButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Select a file for playback");
                selectInput("Select a pre-recorded file for playback:", 
                            "playbackFileSelected", 
                            new File(directoryManager.getGuiDataPath() + "Sample_Data" + System.getProperty("file.separator") + "OpenBCI-sampleData-2-meditation.txt")
                );
            }
        });
    }
};

class SDBox {
    final private String sdBoxDropdownName = "sdCardTimes";
    public int x, y, w, h, padding; //size and position
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
        cp5_sdBox.setGraphics(ourApplet, 0,0);
        cp5_sdBox.setAutoDraw(false);

        createDropdown(sdBoxDropdownName);

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
        sdList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int val = (int)sdList.getValue();
                    Map bob = sdList.getItem(val);
                    cyton_sdSetting = (CytonSDMode)bob.get("value");
                    String outputString = "OpenBCI microSD Setting = " + cyton_sdSetting.getName();
                    if (cyton_sdSetting != CytonSDMode.NO_WRITE) {
                        outputString += " recording time";
                    }
                    output(outputString);
                    verbosePrint("SD Command = " + cyton_sdSetting.getCommand());
                }
            }
        });
    }

    public void updatePosition() {
        sdList.setPosition(x + padding, y + padding*2 + 14);
    }
};


class RadioConfigBox {
    public int x, y, w, h, padding; //size and position
    private String initial_message = "Having trouble connecting to your Cyton? Try Auto-Scan!\n\nUse this tool to get Cyton status or change settings.";
    private String last_message = initial_message;
    public boolean isShowing;
    private RadioConfig cytonRadioCfg;
    private int headerH = 15;
    private int autoscanH = 45;
    private int buttonH = 24;
    private int statusWindowH = 115;
    private ControlP5 rcb_cp5;
    private Button autoscanButton;
    private Button systemStatusButton;
    private Button setChannelButton;
    private Button ovrChannelButton;

    RadioConfigBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x + _w;
        y = _y;
        w = _w + 10;
        h = (_padding*6) + headerH + (buttonH*2) + autoscanH + statusWindowH;
        padding = _padding;
        isShowing = false;
        cytonRadioCfg = new RadioConfig();

        //Instantiate local cp5 for this box
        rcb_cp5 = new ControlP5(ourApplet);
        rcb_cp5.setGraphics(ourApplet, 0,0);
        rcb_cp5.setAutoDraw(false);

        createAutoscanButton("CytonRadioAutoscan", "AUTO-SCAN",x + padding, y + padding*2 + headerH, w-(padding*2), autoscanH,  fontInfo.buttonLabel_size);
        createSystemStatusButton("CytonSystemStatus", "SYSTEM STATUS", x + padding, y + padding*3 + headerH + autoscanH, w-(padding*2), buttonH, fontInfo.buttonLabel_size);
        createSetChannelButton("CytonSetRadioChannel", "CHANGE CHAN.",x + padding, y + padding*4 + headerH + buttonH + autoscanH, (w-padding*3)/2, 24, fontInfo.buttonLabel_size);
        createOverrideChannelButton("CytonOverrideDongleChannel", "OVERRIDE DONGLE", x + 2*padding + (w-padding*3)/2, y + padding*4 + headerH + buttonH + autoscanH, (w-padding*3)/2, buttonH, fontInfo.buttonLabel_size);
        /*
        //Set help text
        getChannel.setHelpText("Get the current channel of your Cyton and USB Dongle.");
        setChannel.setHelpText("Change the channel of your Cyton and USB Dongle.");
        ovrChannel.setHelpText("Change the channel of the USB Dongle only.");
        autoscan.setHelpText("Scan through channels and connect to a nearby Cyton. This button solves most connection issues!");
        systemStatus.setHelpText("Get the connection status of your Cyton system.");
        */
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

        rcb_cp5.draw();
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

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        myButton = rcb_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        return myButton;
    }

    private void createAutoscanButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        autoscanButton = createButton(autoscanButton, name, text, _x, _y, _w, _h, _fontSize);
        autoscanButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                scanChannels();
                controlPanel.hideChannelListCP();
            }
        });
    }

    private void createSystemStatusButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        systemStatusButton = createButton(systemStatusButton, name, text, _x, _y, _w, _h, _fontSize);
        systemStatusButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                getChannel();
                controlPanel.hideChannelListCP();
            }
        });
    }

    private void createSetChannelButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        setChannelButton = createButton(setChannelButton, name, text, _x, _y, _w, _h, _fontSize);
        setChannelButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.channelPopup.setClicked(true);
                controlPanel.channelPopup.setTitleChangeChannel();
            }
        });
    }

    private void createOverrideChannelButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        ovrChannelButton = createButton(ovrChannelButton, name, text, _x, _y, _w, _h, _fontSize);
        ovrChannelButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.channelPopup.setClicked(true);
                controlPanel.channelPopup.setTitlteOvrDongle();
            }
        });
    }
};

class ChannelPopup {
    public int x, y, w, h, padding; //size and position
    private boolean clicked;
    private final String CHANGE_CHAN = "Change Channel";
    private final String OVR_DONGLE = "Override Dongle";
    private String title = "";
    private ControlP5 cp_cp5;
    private MenuList channelList;

    ChannelPopup(int _x, int _y, int _w, int _h, int _padding) {
        x = _x + _w * 2;
        y = _y;
        w = _w;
        h = 171 + _padding;
        padding = _padding;
        clicked = false;

        //Instantiate local cp5 for this box
        cp_cp5 = new ControlP5(ourApplet);
        cp_cp5.setGraphics(ourApplet, 0,0);
        cp_cp5.setAutoDraw(false);

        channelList = new MenuList(cp_cp5, "channelListCP", w - padding*2, 140, p3);
        channelList.setPosition(x+padding, y+padding*3);
        for (int i = 1; i < 26; i++) {
            channelList.addItem(String.valueOf(i));
        }
        channelList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int setChannelInt = (int)(theEvent.getController()).getValue() + 1;
                    setClicked(false);
                    if (title.equals(CHANGE_CHAN)) {
                        controlPanel.rcBox.setChannel(setChannelInt);
                    } else if (title.equals(OVR_DONGLE)) {
                        controlPanel.rcBox.setChannelOverride(setChannelInt);
                    }
                }
            }
        });
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
        cp_cp5.draw();
    }

    public void setClicked(boolean click) { this.clicked = click; }
    public boolean wasClicked() { return this.clicked; }
    public void setTitleChangeChannel() { title = CHANGE_CHAN; }
    public void setTitlteOvrDongle() { title = OVR_DONGLE; }
};

//This class holds the "Start Session" button
class InitBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 initBox_cp5;
    public Button initSystemButton;

    InitBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = 50;
        padding = _padding;

        //Instantiate local cp5 for this box
        initBox_cp5 = new ControlP5(ourApplet);
        initBox_cp5.setGraphics(ourApplet, 0,0);
        initBox_cp5.setAutoDraw(false);

        createStartSessionButton("startSessionButton", "START SESSION", x + padding, y + padding, w-padding*2, h - padding*2,  fontInfo.buttonLabel_size);
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
        
        initBox_cp5.draw();
    }

    private void createStartSessionButton(String name, String text, int _x, int _y, int _w, int _h, int _fontSize) {
        initSystemButton = initBox_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(colorNotPressed)
            .setColorActive(BUTTON_PRESSED)
            ;
        initSystemButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        initSystemButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (controlPanel.rcBox.isShowing) {
                    controlPanel.hideRadioPopoutBox();
                }
                //if system is not active ... initate system and flip button state
                initButtonPressed();
            }
        });
    }

    //This is the primary method called when Start/Stop Session Button is pressed in Control Panel
    public void initButtonPressed() {
        if (getInitSessionButtonText().equals("START SESSION")) {
            if ((eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.NONE) || (eegDataSource == DATASOURCE_GANGLION && selectedProtocol == BoardProtocol.NONE)) {
                output("No Transfer Protocol selected. Please select your Transfer Protocol and retry system initiation.");
                return;
            } else if (eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.SERIAL && openBCI_portName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
                output("No Serial/COM port selected. Please select your Serial/COM port and retry system initiation.");
                return;
            } else if (eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.WIFI && wifi_portName == "N/A" && controlPanel.getWifiSearchStyle() == controlPanel.WIFI_DYNAMIC) {
                output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
                return;
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A" && sdData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
                output("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
                return;
            } else if (eegDataSource == DATASOURCE_GANGLION && (selectedProtocol == BoardProtocol.BLE || selectedProtocol == BoardProtocol.BLED112) && ganglion_portName == "N/A") {
                output("No BLE device selected. Please select your Ganglion device and retry system initiation.");
                return;
            } else if (eegDataSource == DATASOURCE_GANGLION && selectedProtocol == BoardProtocol.WIFI && wifi_portName == "N/A" && controlPanel.getWifiSearchStyle() == controlPanel.WIFI_DYNAMIC) {
                output("No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.");
                return;
            } else if (eegDataSource == -1) {//if no data source selected
                output("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
                return;
            } else { //otherwise, initiate system!
                //verbosePrint("ControlPanel: CPmouseReleased: init");
                setInitSessionButtonText("STOP SESSION");
                // Global steps to START SESSION
                // Prepare the serial port
                if (eegDataSource == DATASOURCE_CYTON) {
                    // Store the current text field value of "Session Name" to be passed along to dataFiles
                    dataLogger.setSessionName(controlPanel.dataLogBoxCyton.getSessionTextfieldString());
                } else if (eegDataSource == DATASOURCE_GANGLION) {
                    dataLogger.setSessionName(controlPanel.dataLogBoxGanglion.getSessionTextfieldString());
                } else if (eegDataSource == DATASOURCE_GALEA) {
                    dataLogger.setSessionName(controlPanel.dataLogBoxGalea.getSessionTextfieldString());
                } else {
                    dataLogger.setSessionName(directoryManager.getFileNameDateTime());
                }

                if (controlPanel.getWifiSearchStyle() == controlPanel.WIFI_STATIC && (selectedProtocol == BoardProtocol.WIFI || selectedProtocol == BoardProtocol.WIFI)) {
                    wifi_ipAddress = controlPanel.wifiBox.staticIPAddressTF.getText();
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
            setInitSessionButtonText("START SESSION");
            //creates new data file name so that you don't accidentally overwrite the old one
            controlPanel.dataLogBoxCyton.setSessionTextfieldText(directoryManager.getFileNameDateTime());
            controlPanel.dataLogBoxGanglion.setSessionTextfieldText(directoryManager.getFileNameDateTime());
            controlPanel.dataLogBoxGalea.setSessionTextfieldText(directoryManager.getFileNameDateTime());
            controlPanel.wifiBox.setStaticIPTextfield(wifi_ipAddress);
            haltSystem();
        }
    }

    public String getInitSessionButtonText() {
        return initSystemButton.getCaptionLabel().getText();
    }

    public void setInitSessionButtonText(String text) {
        initSystemButton.getCaptionLabel().setText(text);
    }
};


