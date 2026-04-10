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
    StreamingBoardBox streamingBoardBox;
    BLEBox bleBox;
    public SessionDataBox dataLogBoxGanglion;
    InterfaceBoxGanglion interfaceBoxGanglion;
    SampleRateGanglionBox sampleRateGanglionBox;
    SDBox sdBox;
    BrainFlowStreamerBox bfStreamerBoxCyton;
    BrainFlowStreamerBox bfStreamerBoxGanglion;
    BrainFlowStreamerBox bfStreamerBoxSynthetic;

    ChannelPopup channelPopup;
    RadioConfigBox rcBox;

    //Track Dynamic and Static WiFi mode in Control Panel
    final public String WIFI_DYNAMIC = "dynamic";
    final public String WIFI_STATIC = "static";
    private String wifiSearchStyle = WIFI_DYNAMIC;

    boolean drawStopInstructions;
    int globalPadding; //design feature: passed through to all box classes as the global spacing .. in pixels .. for all elements/subelements
    boolean convertingSD = false;
    private final int PAD_3 = 3;

    ControlPanel(OpenBCI_GUI mainClass) {

        x = PAD_3;
        y = PAD_3 + topNav.controlPanelCollapser.getHeight();
        w = topNav.controlPanelCollapser.getWidth();
        h = height - int(helpWidget.h);

        isOpen = false;

        globalPadding = 10;  //controls the padding of all elements on the control panel

        dataSourceBox = new DataSourceBox(x, y, w, h, globalPadding);
        interfaceBoxGanglion = new InterfaceBoxGanglion(x + w, dataSourceBox.y, w, h, globalPadding);
        
        comPortBox = new ComPortBox(x+w*2, y, w, h, globalPadding);
        rcBox = new RadioConfigBox(x+w, y + comPortBox.h, w, h, globalPadding);

        serialBox = new SerialBox(x + w, dataSourceBox.y, w, h, globalPadding);

        channelCountBox = new ChannelCountBox(x + w, (serialBox.y + serialBox.h), w, h, globalPadding);
        dataLogBoxCyton = new SessionDataBox(x + w, (channelCountBox.y + channelCountBox.h), w, h, globalPadding, DATASOURCE_CYTON, dataLogger.getDataLoggerOutputFormat(), "sessionNameCyton");
        bfStreamerBoxCyton = new BrainFlowStreamerBox(x + w, (dataLogBoxCyton.y + dataLogBoxCyton.h), w, h, globalPadding, "bfStreamerCyton");
        sdBox = new SDBox(x + w, (bfStreamerBoxCyton.y + bfStreamerBoxCyton.h), w, h, globalPadding);
        
        int playbackWidth = int(w * 1.35);
        playbackFileBox = new PlaybackFileBox(x + w, dataSourceBox.y, playbackWidth, h, globalPadding);
        recentPlaybackBox = new RecentPlaybackBox(x + w, (playbackFileBox.y + playbackFileBox.h), playbackWidth, h, globalPadding);

        synthChannelCountBox = new SyntheticChannelCountBox(x + w, dataSourceBox.y, w, h, globalPadding);
        bfStreamerBoxSynthetic = new BrainFlowStreamerBox(x + w, (synthChannelCountBox.y + synthChannelCountBox.h), w, h, globalPadding, "bfStreamerSynthetic");
        
        streamingBoardBox = new StreamingBoardBox(x + w, dataSourceBox.y, w, h, globalPadding);

        channelPopup = new ChannelPopup(x+w, y, w, h, globalPadding);

        initBox = new InitBox(x, (dataSourceBox.y + dataSourceBox.h), w, h, globalPadding);

        // Ganglion
        bleBox = new BLEBox(x + w, interfaceBoxGanglion.y + interfaceBoxGanglion.h, w, h, globalPadding);
        dataLogBoxGanglion = new SessionDataBox(x + w, (bleBox.y + bleBox.h), w, h, globalPadding, DATASOURCE_GANGLION, dataLogger.getDataLoggerOutputFormat(), "sessionNameGanglion");
        bfStreamerBoxGanglion = new BrainFlowStreamerBox(x + w, (dataLogBoxGanglion.y + dataLogBoxGanglion.h), w, h, globalPadding, "bfStreamerGanglion");
        sampleRateGanglionBox = new SampleRateGanglionBox(x + w, (bfStreamerBoxGanglion.y + bfStreamerBoxGanglion.h), w, h, globalPadding);

    }

    public void resetListItems(){
        comPortBox.serialList.activeItem = -1;
        bleBox.bleList.activeItem = -1;
    }

    public void open(){
        isOpen = true;
        topNav.controlPanelCollapser.setOn();
        topNav.setDropdownMenuIsOpen(true);
    }

    public void close(){
        isOpen = false;
        topNav.controlPanelCollapser.setOff();
        topNav.setDropdownMenuIsOpen(false);
    }

    public String getWifiSearchStyle() {
        return wifiSearchStyle;
    }

    private void setWiFiSearchStyle(String s) {
        wifiSearchStyle = s;
    }

    public void update() {
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

        streamingBoardBox.update();

        bfStreamerBoxCyton.update();
        bfStreamerBoxGanglion.update();
        bfStreamerBoxSynthetic.update();

        sdBox.update();
        rcBox.update();
        comPortBox.update();
        initBox.update();

        channelPopup.update();

        dataLogBoxGanglion.update();
        interfaceBoxGanglion.update();
    }

    public void draw() {

        initBox.draw();

        if (systemMode == 10) {
            drawStopInstructions = true;
        }

        if (systemMode != 10) { // only draw control panel boxes if system running is false
            dataSourceBox.draw();
            drawStopInstructions = false;

            //Carefully draw certain boxes based on UI/UX flow... let each box handle what is drawn inside with localCp5 instances
            if (eegDataSource == DATASOURCE_CYTON) {	//when data source is from OpenBCI
                serialBox.draw();
                channelCountBox.y = serialBox.y + serialBox.h;
                if (rcBox.isShowing) {
                    comPortBox.draw();
                    rcBox.draw();
                    comPortBox.serialList.setVisible(true);
                    if (channelPopup.wasClicked()) {
                        channelPopup.draw();
                    }
                }
                dataLogBoxCyton.y = channelCountBox.y + channelCountBox.h;
                bfStreamerBoxCyton.y = dataLogBoxCyton.y + dataLogBoxCyton.h;
                sdBox.y = bfStreamerBoxCyton.y + bfStreamerBoxCyton.h;
                channelCountBox.draw();
                sdBox.draw();
                bfStreamerBoxCyton.draw();
                dataLogBoxCyton.draw(); //Drawing here allows max file size dropdown to be drawn on top
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) { //when data source is from playback file
                recentPlaybackBox.draw();
                playbackFileBox.draw();
            } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  //synthetic
                synthChannelCountBox.draw();
                bfStreamerBoxSynthetic.draw();
            } else if (eegDataSource == DATASOURCE_GANGLION) {
                if (selectedProtocol == BoardProtocol.NONE) {
                    interfaceBoxGanglion.draw();
                } else {
                    interfaceBoxGanglion.draw();
                    if (selectedProtocol == BoardProtocol.BLED112 || selectedProtocol == BoardProtocol.NATIVE_BLE) {
                        bleBox.y = interfaceBoxGanglion.y + interfaceBoxGanglion.h;
                        dataLogBoxGanglion.y = bleBox.y + bleBox.h;
                        bleBox.draw();
                    }
                    bfStreamerBoxGanglion.y = dataLogBoxGanglion.y + dataLogBoxGanglion.h;
                    bfStreamerBoxGanglion.draw();
                    dataLogBoxGanglion.draw(); //Drawing here allows max file size dropdown to be drawn on top
                }
            } else if (eegDataSource == DATASOURCE_STREAMING) {
                streamingBoardBox.draw();
            }
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
            fill(OPENBCI_DARKBLUE);
            text(stopInstructions, x + globalPadding*2, y + globalPadding*3, w - globalPadding*4, dataSourceBox.h - globalPadding*4);
            popStyle();
        }
    }

    public void hideRadioPopoutBox() {
        rcBox.isShowing = false;
        comPortBox.isShowing = false;
        serialBox.popOutRadioConfigButton.setOff();
        rcBox.closeSerialPort();
    }

    private void hideChannelListCP() {
        channelPopup.setClicked(false);
    }

    public void fetchSessionNameTextfieldAllBoards() {
        String s = "";
        if (eegDataSource == DATASOURCE_CYTON) {
            // Store the current text field value of "Session Name" to be passed along to dataFiles
            s = dataLogBoxCyton.getSessionTextfieldString();
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            s = dataLogBoxGanglion.getSessionTextfieldString();
        } else {
            s = directoryManager.getFileNameDateTime();
        }
        dataLogger.setSessionName(s);
        StringBuilder sb = new StringBuilder(directoryManager.getRecordingsPath());
        sb.append("OpenBCISession_");
        sb.append(dataLogger.getSessionName());
        sb.append(File.separator);
        dataLogger.setSessionPath(sb.toString());
    }

    public void setBrainFlowStreamerOutput() {
        if (getIsBrainFlowSteamerDefaultFileOutput()) {
            dataLogger.setBfWriterDefaultFolder();
        }

        if (eegDataSource == DATASOURCE_CYTON) {
            brainflowStreamer = bfStreamerBoxCyton.getBrainFlowStreamerString();
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            brainflowStreamer = bfStreamerBoxGanglion.getBrainFlowStreamerString();
        } else if (eegDataSource == DATASOURCE_SYNTHETIC) {
            brainflowStreamer = bfStreamerBoxSynthetic.getBrainFlowStreamerString();
        }
    }

    private boolean getIsBrainFlowSteamerDefaultFileOutput() {
        boolean b = false;
        if (eegDataSource == DATASOURCE_CYTON) {
            b = bfStreamerBoxCyton.getIsBrainFlowStreamerDefaultLocation();
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            b = bfStreamerBoxGanglion.getIsBrainFlowStreamerDefaultLocation();
        } else if (eegDataSource == DATASOURCE_SYNTHETIC) {
            b = bfStreamerBoxSynthetic.getIsBrainFlowStreamerDefaultLocation();
        }
        return b;
    }

}; //end of ControlPanel class

//==============================================================================//
//                	BELOW ARE THE CLASSES FOR THE VARIOUS                       //
//                	CONTROL PANEL BOXES (control widgets)                       //
//==============================================================================//

class DataSourceBox {
    public int x, y, w, h, padding; //size and position
    private final int NUM_ITEMS = 5;
    private int boxHeight = 24;
    private int spacing = 43;
    private ControlP5 datasource_cp5;
    private MenuList sourceList;
    private boolean initialUpdate = false;

    DataSourceBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = spacing + (NUM_ITEMS * boxHeight);
        padding = _padding;

        //Instantiate local cp5 for this box
        datasource_cp5 = new ControlP5(ourApplet);
        datasource_cp5.setGraphics(ourApplet, 0,0);
        datasource_cp5.setAutoDraw(false);
        createDatasourceList(datasource_cp5, "DataSourceList", x + padding, y + padding*2 + 13, w - padding*2, NUM_ITEMS * boxHeight, p3);
    }

    public void update() {
        if (!initialUpdate) {
            initialUpdate = true;
            if (eegDataSource >= 0) {
                sourceList.selectItem(0); //Select the first item in the list on startup
            }
        }
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("DATA SOURCE", x + padding, y + padding);
        popStyle();
        
        datasource_cp5.draw();
    }

    private void createDatasourceList(ControlP5 _cp5, String name, int _x, int _y, int _w, int _h, PFont font) {
        sourceList = new MenuList(_cp5, name, _w, _h, font);
        sourceList.setPosition(_x, _y);
        sourceList.addItem("CYTON (live)", DATASOURCE_CYTON);
        sourceList.addItem("GANGLION (live)", DATASOURCE_GANGLION);
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
                    sessionSettings.controlEventDataSource = str; //Used for output message on system start
                    eegDataSource = newDataSource;

                    //Reset protocol
                    selectedProtocol = BoardProtocol.NONE;

                    //Perform this check in a way that ignores order of items in the menulist
                    if (eegDataSource == DATASOURCE_CYTON) {
                        controlPanel.channelCountBox.set8ChanButtonActive();
                        selectedProtocol = BoardProtocol.SERIAL;
                    } else if (eegDataSource == DATASOURCE_GANGLION) {
                        updateGlobalChannelCount(4);
                        controlPanel.interfaceBoxGanglion.resetGanglionSelectedProtocol();
                    } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
                        //GUI auto detects number of channels for playback when file is selected
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

        createAutoConnectButton("cytonAutoConnectButton", "AUTO-CONNECT", x + padding, y + padding*3 + 4, w - padding*3 - 70, 24);
        createRadioConfigButton("cytonRadioConfigButton", "Settings", x + w - 70 - padding, y + padding*3 + 4, 70, 24);
    }

    public void update() {
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("SERIAL CONNECT", x + padding, y + padding);
        popStyle();

        cytonsb_cp5.draw();
    }

    private Button createSBButton(String name, String text, int _x, int _y, int _w, int _h) {
        return createButton(cytonsb_cp5, name, text, _x, _y, _w, _h, 0, p5, 12, colorNotPressed, OPENBCI_DARKBLUE, BUTTON_HOVER, BUTTON_PRESSED, OPENBCI_DARKBLUE, 0);
    }

    private void createAutoConnectButton(String name, String text, int _x, int _y, int _w, int _h) {
        autoConnectButton = createSBButton(name, text, _x, _y, _w, _h);
        autoConnectButton.setColorBackground(TURN_ON_GREEN);
        autoConnectButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.comPortBox.attemptAutoConnectCyton();
            }
        });
        autoConnectButton.setDescription("Attempt to auto-connect to Cyton. Try \"Manual\" if this does not work.");
    }

    private void createRadioConfigButton(String name, String text, int _x, int _y, int _w, int _h) {
        popOutRadioConfigButton = createSBButton(name, text, _x, _y, _w, _h);
        popOutRadioConfigButton.setSwitch(true);
        popOutRadioConfigButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean showRadioBox = popOutRadioConfigButton.isOn();
                if (!showRadioBox) {
                    controlPanel.hideRadioPopoutBox();
                } else {
                    controlPanel.rcBox.isShowing = true;
                    controlPanel.rcBox.print_onscreen(controlPanel.rcBox.initial_message);
                }
            }
        });
        popOutRadioConfigButton.setDescription("Having trouble connecting to Cyton? Click here to access Radio Configuration tools.");
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

        createRefreshCytonDonglesButton("refreshCytonDonglesButton", "REFRESH LIST", x + padding, y + padding*4 + 72 + 8, w - padding*2, 24);
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
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("SERIAL/COM PORT", x + padding, y + padding);
        popStyle();

        cytoncpb_cp5.draw();
    }

    private void createRefreshCytonDonglesButton(String name, String text, int _x, int _y, int _w, int _h) {
        refreshCytonDongles = createButton(cytoncpb_cp5, name, text, _x, _y, _w, _h);
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
                    cytonDonglePortName = (String)bob.get("subline");
                    output("ControlPanel: Selected OpenBCI Port " + cytonDonglePortName);
                }
            }
        });
    }

    //This is called when the Auto-Connect button is pressed in another Control Panel Box
    public void attemptAutoConnectCyton() {
        println("\n-------------------------------------------------\nControlPanel: Attempting to Auto-Connect to Cyton\n-------------------------------------------------\n");
        LinkedList<String> comPorts = getCytonComPorts();
        if (!comPorts.isEmpty()) {
            cytonDonglePortName = comPorts.getFirst();
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
            println("Successfully connected to Cyton using " + cytonDonglePortName);
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

        createRefreshBLEButton("refreshGanglionBLEButton", "START SEARCH", x + padding, y + padding*4 + 72 + 8, w - padding*5, 24);
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
        fill(OPENBCI_DARKBLUE);
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

private void refreshGanglionNativeList() {
        if (bleIsRefreshing) {
            output("Search for Ganglions using Native Bluetooth is in progress.");
            return;
        }
        output("Refreshing available Ganglions using Native Bluetooth...");
        bleList.items.clear();
        
        Thread thread = new Thread(){
            public void run(){
                refreshBLE.getCaptionLabel().setText("SEARCHING...");
                bleIsRefreshing = true;

                try {
                    bleMACAddrMap = GUIHelper.scan_for_ganglions (3);
                    for (Map.Entry<String, String> entry : bleMACAddrMap.entrySet ())
                    {
                        bleList.addItem(entry.getKey(),  entry.getValue(), "");
                        bleList.updateMenu();
                        println("Found Ganglion Board: " + entry.getKey() + " " + entry.getValue());
                    }
                } catch (GanglionError e)
                {
                    e.printStackTrace();
                }

                refreshBLE.getCaptionLabel().setText("START SEARCH");
                bleIsRefreshing = false;
            }
        };

        thread.start();
    }

    private void refreshGanglionBLEList() {
        if (bleIsRefreshing) {
            output("Search for Ganglions using BLED112 Dongle is in progress.");
            return;
        }
        output("Refreshing available Ganglions using BLED112 Dongle...");
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

    private void createRefreshBLEButton(String name, String text, int _x, int _y, int _w, int _h) {
        refreshBLE = createButton(bleBox_cp5, name, text, _x, _y, _w, _h);
        refreshBLE.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (selectedProtocol == BoardProtocol.BLED112) {
                    refreshGanglionBLEList();
                } else {
                    refreshGanglionNativeList();
                } 
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

class InterfaceBoxGanglion {
    public int x, y, w, h, padding; //size and position
    private ControlP5 ifbg_cp5;
    private Button protocolGanglionNativeBLE;
    private Button protocolBLED112Ganglion;

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

        createGanglionNativeBLEButton("protocolNativeBLEGanglion", "Bluetooth (Native)", false, x + padding, y + padding * 3 + 4, w - padding * 2, 24);
        createBLED112Button("protocolBLED112Ganglion", "Bluetooth (BLED112 Dongle)", false, x + padding, y + (padding * 4) + 24 + 4, w - padding * 2, 24);
    }

    public void update() {}

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PICK TRANSFER PROTOCOL", x + padding, y + padding);
        popStyle();
        
        ifbg_cp5.draw();
    }


    private Button createIFBGButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        final Button b = createButton(ifbg_cp5, name, text, _x, _y, _w, _h);
        b.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            b.setOn();
        }
        return b;
    }

    private void createGanglionNativeBLEButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        protocolGanglionNativeBLE = createIFBGButton(name, text, isToggled, _x, _y, _w, _h);
        protocolGanglionNativeBLE.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.bleBox.bleList.items.clear();
                selectedProtocol = BoardProtocol.NATIVE_BLE;
                controlPanel.bleBox.refreshGanglionNativeList();
                protocolGanglionNativeBLE.setOn();
                protocolBLED112Ganglion.setOff();
            }
        });
    }

    private void createBLED112Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        protocolBLED112Ganglion = createIFBGButton(name, text, isToggled, _x, _y, _w, _h);
        protocolBLED112Ganglion.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.bleBox.bleList.items.clear();
                selectedProtocol = BoardProtocol.BLED112;
                controlPanel.bleBox.refreshGanglionBLEList();
                protocolGanglionNativeBLE.setOff();
                protocolBLED112Ganglion.setOn();
            }
        });
    }

    public void resetGanglionSelectedProtocol() {
        protocolGanglionNativeBLE.setOff();
        protocolBLED112Ganglion.setOff();
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
        createAutoSessionNameButton("autoSessionName", "GENERATE SESSION NAME", x + padding, y + 66, w-(padding*2), 24);
        createODFButton("odfButton", "OpenBCI", dataLogger.getDataLoggerOutputFormat(), x + padding, y + padding*2 + 18 + 58, (w-padding*3)/2, 24);
        createBDFButton("bdfButton", "BDF+", dataLogger.getDataLoggerOutputFormat(), x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58, (w-padding*3)/2, 24);

        List<String> fileDurationList = EnumHelper.getEnumStrings(OdfFileDuration.class);
        createMaxDurationDropdown("maxFileDuration", fileDurationList, odfFileDuration);
    }

    public void update() {
        textfieldUpdateHelper.checkTextfield(sessionNameTextfield);

        //Update the position of UI elements here, as this changes when user selects WiFi mode
        sessionNameTextfield.setPosition(x + 60, y + 32);
        autoSessionName.setPosition(x + padding, y + 66);
        outputODF.setPosition(x + padding, y + padding*2 + 18 + 58);
        outputBDF.setPosition(x + padding*2 + (w-padding*3)/2, y + padding*2 + 18 + 58);

        boolean odfIsSelected = dataLogger.getDataLoggerOutputFormat() == dataLogger.OUTPUT_SOURCE_ODF;
        h = odfIsSelected ? odfModeHeight : bdfModeHeight;
        maxDurationDropdown.setVisible(odfIsSelected);
        if (odfIsSelected && outputBDF.isOn()) {
            outputODF.setOn();
            outputBDF.setOff();
        } else if (!odfIsSelected && outputODF.isOn()) {
            outputBDF.setOn();
            outputODF.setOff();
        }
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("SESSION DATA", x + padding, y + padding);
        textFont(p4, 14);
        text("Name", x + padding, y + padding*2 + 14);
        popStyle();

        boolean odfIsSelected = dataLogger.getDataLoggerOutputFormat() == dataLogger.OUTPUT_SOURCE_ODF;
        maxDurationDropdown.setVisible(odfIsSelected);
        if (odfIsSelected) {
            pushStyle();
            //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
            //Dropdown is drawn at the end of ControlPanel.draw()
            fill(OPENBCI_DARKBLUE);
            maxDurationDropdown.setPosition(x + maxDurTextWidth, int(outputODF.getPosition()[1]) + 24 + padding);
            //Carefully draw some text to the left of above dropdown, otherwise this text moves when changing WiFi mode
            int extraPadding = 20;
            fill(OPENBCI_DARKBLUE);
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
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(OPENBCI_DARKBLUE)  // border color when not selected
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

    private void createMaxDurationDropdown(String name, List<String> _items, OdfFileDuration defaultValue) {
        maxDurationDropdown = sessionData_cp5.addScrollableList(name)
            .setOpen(false)
            .setColor(dropdownColorsGlobal)
            .setOutlineColor(150)
            //.setColorBackground(OPENBCI_BLUE) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)       // text color
            //.setColorCaptionLabel(color(255))
            //.setColorForeground(color(125))    // border color when not selected
            //.setColorActive(BUTTON_PRESSED)       // border color when selected
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
            .setText(defaultValue.getString())
            .setFont(p4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        maxDurationDropdown
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(defaultValue.getString())
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        maxDurationDropdown.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {    
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int n = (int)(theEvent.getController()).getValue();
                    dataLogger.setLogFileDurationChoice(n);
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

    private Button createGUIOutputToggle(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        final Button b = createButton(sessionData_cp5, name, text, _x, _y, _w, _h);
        b.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            b.setOn();
        }
        return b;
    }

    private void createAutoSessionNameButton(String name, String text, int _x, int _y, int _w, int _h) {
        autoSessionName = createButton(sessionData_cp5, name, text, _x, _y, _w, _h);
        autoSessionName.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                autogenerateSessionName();
            }
        });
        autoSessionName.setDescription("Autogenerate a session name based on the date and time.");
    }

    private void createODFButton(String name, String text, int dataLoggerFormat, int _x, int _y, int _w, int _h) {
        boolean formatIsODF = dataLoggerFormat == dataLogger.OUTPUT_SOURCE_ODF;
        outputODF = createGUIOutputToggle(name, text, formatIsODF, _x, _y, _w, _h);
        outputODF.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output(odfMessage);
                dataLogger.setDataLoggerOutputFormat(dataLogger.OUTPUT_SOURCE_ODF);
                outputODF.setOn();
                outputBDF.setOff();
                setToODFHeight();
            }
        });
        outputODF.setDescription("Set GUI data output to OpenBCI Data Format (.txt). A new file will be made in the session folder when the data stream is paused or max file duration is reached.");
    }

    private void createBDFButton(String name, String text, int dataLoggerFormat, int _x, int _y, int _w, int _h) {
        boolean formatIsBDF = dataLoggerFormat == dataLogger.OUTPUT_SOURCE_BDF;
        outputBDF = createGUIOutputToggle(name, text, formatIsBDF, _x, _y, _w, _h);
        outputBDF.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output(bdfMessage);
                dataLogger.setDataLoggerOutputFormat(dataLogger.OUTPUT_SOURCE_BDF);
                outputBDF.setOn();
                outputODF.setOff();
                setToBDFHeight();
            }
        });
        outputBDF.setDescription("Set GUI data output to BioSemi Data Format (.bdf). All session data is contained in one .bdf file. View using an EDF/BDF browser.");
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

    private void lockOutsideElements (boolean _toggle) {
        if (eegDataSource == DATASOURCE_CYTON) {
            controlPanel.channelCountBox.lockCp5Objects(_toggle);
            controlPanel.sdBox.lockCp5Objects(_toggle);
            controlPanel.bfStreamerBoxCyton.lockCp5Objects(_toggle);
            controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).setUpdate(!_toggle);
        } else if (eegDataSource == DATASOURCE_GANGLION) {
            controlPanel.sampleRateGanglionBox.lockCp5Objects(_toggle);
        }
    }

    public void lockCp5Objects(boolean lock) {
        sessionNameTextfield.setLock(lock);
        autoSessionName.setLock(lock);
        outputODF.setLock(lock);
        outputBDF.setLock(lock);
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
        boolean is8Channels = (globalChannelCount == 8) ? true : false;
        createChan8Button("cyton8ChanButton", "8 CHANNELS", is8Channels, cb8_butX, cb_butY, (w-padding*3)/2, 24);
        createChan16Button("cyton16ChanButton", "16 CHANNELS", is8Channels, cb16_butX, cb_butY, (w-padding*3)/2, 24);
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
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("CHANNEL COUNT ", x + padding, y + padding);
        fill(OPENBCI_DARKBLUE); //set color to green
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("  (" + str(globalChannelCount) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
        popStyle();

        ccc_cp5.draw();
    }

    private Button createCCCButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        final Button b = createButton(ccc_cp5, name, text, _x, _y, _w, _h);
        b.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            b.setOn();
        }
        return b;
    }

    private void createChan8Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        chanButton8 = createCCCButton(name, text, isToggled, _x, _y, _w, _h);
        chanButton8.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateGlobalChannelCount(8);
                chanButton8.setOn();
                chanButton16.setOff();
            }
        });
    }

    private void createChan16Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        chanButton16 = createCCCButton(name, text, isToggled, _x, _y, _w, _h);
        chanButton16.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateGlobalChannelCount(16);
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
        updateGlobalChannelCount(8);
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
        createSR200Button("cytonSR200", "200Hz", false, sr200_butX, srButton_butY, (w-padding*3)/2, 24);
        createSR1600Button("cytonSR1600", "1600Hz", true, sr1600_butX, srButton_butY, (w-padding*3)/2, 24);
    }

    public void update() {
    }

    public void draw() {
        sr200_butX = x + padding;
        sr1600_butX = x + padding*2 + (w-padding*3)/2;
        srButton_butY =  y + padding*2 + 18;
        sampleRate200.setPosition(sr200_butX, srButton_butY);
        sampleRate1600.setPosition(sr1600_butX, srButton_butY);

        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("SAMPLE RATE ", x + padding, y + padding);
        fill(OPENBCI_DARKBLUE); //set color to green
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        popStyle();

        srgb_cp5.draw();
    }

    private Button createSRGBButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        final Button b = createButton(srgb_cp5, name, text, _x, _y, _w, _h);
        b.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            b.setOn();
        }
        return b;
    }

    private void createSR200Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        sampleRate200 = createSRGBButton(name, text, isToggled, _x, _y, _w, _h);
        sampleRate200.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectedSamplingRate = 200;
                println("ControlPanel: User selected Ganglion+WiFi 200Hz");
                sampleRate200.setOn();
                sampleRate1600.setOff();
            }
        });
    }

    private void createSR1600Button(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        sampleRate1600 = createSRGBButton(name, text, isToggled, _x, _y, _w, _h);
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

        createSynthChan4Button("synthChan4Button", "4 chan", x + padding, y + padding*2 + 18, (w-padding*4)/3, 24);
        createSynthChan8Button("synthChan8Button", "8 chan", x + padding*2 + (w-padding*4)/3, y + padding*2 + 18, (w-padding*4)/3, 24);
        createSynthChan16Button("synthChan16Button", "16 chan", x + padding*3 + ((w-padding*4)/3)*2, y + padding*2 + 18, (w-padding*4)/3, 24);
    }

    public void update() {
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("CHANNEL COUNT", x + padding, y + padding);
        fill(OPENBCI_DARKBLUE); //set color to green
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("  (" + str(globalChannelCount) + ")", x + padding + 142, y + padding); // print the channel count in green next to the box title
        popStyle();

        sccb_cp5.draw();
    }

    private Button createSCCBButton(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        final Button b = createButton(sccb_cp5, name, text, _x, _y, _w, _h);
        b.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            b.setOn();
        }
        return b;
    }

    private void createSynthChan4Button(String name, String text, int _x, int _y, int _w, int _h) {
        synthChanButton4 = createSCCBButton(name, text, false,_x, _y, _w, _h);
        synthChanButton4.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateGlobalChannelCount(4);
                synthChanButton4.setOn();
                synthChanButton8.setOff();
                synthChanButton16.setOff();
            }
        });
    }

    private void createSynthChan8Button(String name, String text, int _x, int _y, int _w, int _h) {
        //Default is 8 channels when app starts
        synthChanButton8 = createSCCBButton(name, text, true, _x, _y, _w, _h);
        synthChanButton8.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateGlobalChannelCount(8);
                synthChanButton4.setOff();
                synthChanButton8.setOn();
                synthChanButton16.setOff();
            }
        });
    }

    private void createSynthChan16Button(String name, String text, int _x, int _y, int _w, int _h) {
        synthChanButton16 = createSCCBButton(name, text, false, _x, _y, _w, _h);
        synthChanButton16.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                updateGlobalChannelCount(16);
                synthChanButton4.setOff();
                synthChanButton8.setOff();
                synthChanButton16.setOn();
            }
        });
    }

    public void set8ChanButtonActive() {
        updateGlobalChannelCount(8);
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
    private int TITLE_HEIGHT = 14;
    private int buttonH = 24;

    RecentPlaybackBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = TITLE_HEIGHT + buttonH + _padding*3;
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
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PLAYBACK HISTORY", x + padding, y + padding);
        popStyle();
        recentPlaybackSL.setVisible(true);
        rpb_cp5.draw();
    }

    private void getRecentPlaybackFiles() {
        int numFilesToShow = 10;

        File f = new File(userPlaybackHistoryFile);
        if (!f.exists()) {
            println("OpenBCI_GUI::Control Panel: Playback history file not found.");
            recentPlaybackFilesHaveUpdated = true;
            playbackHistoryFileExists = false;
            return;
        }

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
            println("OpenBCI_GUI::Control Panel: Other error! Please submit an issue on Github and share this console log.");
            println(e.getMessage());
            playbackHistoryFileExists = false;
        }
        recentPlaybackFilesHaveUpdated = true;
    }

    void createRecentPlaybackFilesDropdown(String name, List<String> _items){
        recentPlaybackSL = rpb_cp5.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(OPENBCI_BLUE) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
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

class BrainFlowStreamerBox {
    public int x, y, w, h, padding; //size and position
    private ControlP5 bfStreamerCp5;
    private int maxDurTextWidth = 82;
    private int maxDurText_x = 0;
    private Textfield ipAddressTextfield;
    private Textfield portTextfield;
    private Button outputToNetwork;
    private Button outputToFile;
    private ScrollableList bfFileSaveOption;
    private DataWriterBFEnum dataWriterBfEnum = DataWriterBFEnum.DEFAULT;
    private final int HEADER_H = 14;
    private final int OBJECT_H = 24;
    private final String DEFAULT_IP_ADDRESS = "225.1.1.1";
    private final String DEFAULT_PORT = "6677";

    BrainFlowStreamerBox (int _x, int _y, int _w, int _h, int _padding, String textfieldName) {
        x = _x;
        y = _y;
        w = _w;
        h = HEADER_H + OBJECT_H*2 + _padding*4;
        padding = _padding;

        //Instantiate local cp5 for this box
        bfStreamerCp5 = new ControlP5(ourApplet);
        bfStreamerCp5.setGraphics(ourApplet, 0,0);
        bfStreamerCp5.setAutoDraw(false);

        createDropdown("bfFileSaveOption");
        createNetworkTextfields();

        //button to autogenerate file name based on time/date
        createStreamNetworkButton("networkButton", "Network", x + padding, y + 32, (w-padding*3)/2, OBJECT_H);
        createStreamFileButton("fileButton", "File", x + padding*2 + (w-padding*3)/2, y + 32, (w-padding*3)/2, OBJECT_H);
    }

    public void update() {
        textfieldUpdateHelper.checkTextfield(ipAddressTextfield);
        textfieldUpdateHelper.checkTextfield(portTextfield);
    }

    public void draw() {
        int streamerTextfieldY = y + padding*3 + HEADER_H + OBJECT_H;

        bfFileSaveOption.setVisible(outputToFile.isOn());
        ipAddressTextfield.setVisible(outputToNetwork.isOn());
        portTextfield.setVisible(outputToNetwork.isOn());

        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("BRAINFLOW STREAMER", x + padding, y + padding);
        textFont(p4, 14);
        if (outputToFile.isOn()) {
            text("Location", x + padding, streamerTextfieldY + 2);
        } else if (outputToNetwork.isOn()) {
            text("IP", x + padding, streamerTextfieldY + 2);
            text("Port", x + w - padding*2 - portTextfield.getWidth() - 14 - padding, streamerTextfieldY + 2);
        }
        popStyle();
        
        //Update the position of UI elements here
        outputToNetwork.setPosition(x + padding, y + HEADER_H + padding*2);
        outputToFile.setPosition(x + padding*2 + (w-padding*3)/2, y + HEADER_H + padding*2);
        bfFileSaveOption.setPosition(x + 80, streamerTextfieldY);
        ipAddressTextfield.setPosition(x + padding * 3, streamerTextfieldY);
        portTextfield.setPosition(x + w - padding - portTextfield.getWidth(), streamerTextfieldY);
        
        bfStreamerCp5.draw();
    }

    private void createNetworkTextfields() {
        ipAddressTextfield = bfStreamerCp5.addTextfield("ipAddressTextfield")
            .setPosition(x + padding * 3, y + HEADER_H + padding*2)
            .setCaptionLabel("")
            .setSize(120, OBJECT_H)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(OPENBCI_DARKBLUE)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText(DEFAULT_IP_ADDRESS)
            .align(5, 10, 20, 40)
            //.onDoublePress(cb)
            .addCallback(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && ipAddressTextfield.getText().equals("")) {
                            ipAddressTextfield.setText(DEFAULT_IP_ADDRESS);
                        }
                    }
                })
            .onReleaseOutside(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                        if (!ipAddressTextfield.isActive() && ipAddressTextfield.getText().equals("")) {
                            ipAddressTextfield.setText(DEFAULT_IP_ADDRESS);
                        }
                    }
                })
            .onDoublePress(cb);
        
        portTextfield = bfStreamerCp5.addTextfield("portTextfield")
            .setPosition(x + padding*5 + w/2, y + HEADER_H + padding*2)
            .setCaptionLabel("")
            .setSize(50, OBJECT_H)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(OPENBCI_DARKBLUE)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText(DEFAULT_PORT)
            .align(5, 10, 20, 40)
            //.onDoublePress(cb)
            .addCallback(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && portTextfield.getText().equals("")) {
                            portTextfield.setText(DEFAULT_PORT);
                        }
                    }
                })
            .onReleaseOutside(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                        if (!portTextfield.isActive() && portTextfield.getText().equals("")) {
                            portTextfield.setText(DEFAULT_PORT);
                        }
                    }
                })
            .onDoublePress(cb);
    }

    private Button createBrainFlowOutputToggle(String name, String text, boolean isToggled, int _x, int _y, int _w, int _h) {
        final Button b = createButton(bfStreamerCp5, name, text, _x, _y, _w, _h);
        b.setSwitch(true); //This turns the button into a switch
        if (isToggled) {
            b.setOn();
        }
        return b;
    }

    private void createStreamNetworkButton(String name, String text, int _x, int _y, int _w, int _h) {
        outputToNetwork = createBrainFlowOutputToggle(name, text, false, _x, _y, _w, _h);
        outputToNetwork.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                outputToNetwork.setOn();
                outputToFile.setOff();
            }
        });
        outputToNetwork.setDescription("Use BrainFlow Streamer to output to network address. You can accept this data stream using a separate process which utilizes any BrainFlow binding. This is a helpful feature for developers.");
    }

    private void createStreamFileButton(String name, String text, int _x, int _y, int _w, int _h) {
        outputToFile = createBrainFlowOutputToggle(name, text, true, _x, _y, _w, _h);
        outputToFile.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                outputToNetwork.setOff();
                outputToFile.setOn();
            }
        });
        outputToFile.setDescription("Set BrainFlow Streamer output to stream over network. A new file will be made in the session folder when the data stream is paused or max file duration is reached.");
    }

    private void createDropdown(String name){
        bfFileSaveOption = bfStreamerCp5.addScrollableList(name)
            .setOpen(false)
            .setColor(dropdownColorsGlobal)
            .setOutlineColor(150)
            .setSize(167, (dataWriterBfEnum.values().length + 1) * 24)
            .setBarHeight(24) //height of top/primary bar
            .setItemHeight(24) //height of all item/dropdown bars
            .setVisible(true)
            ;
        for (DataWriterBFEnum value : dataWriterBfEnum.values()) {
            // this will store the *actual* enum object inside the dropdown!
            bfFileSaveOption.addItem(value.getString(), value);
        }
        bfFileSaveOption.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(dataWriterBfEnum.getString())
            .setFont(p4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        bfFileSaveOption.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(dataWriterBfEnum.getString())
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        bfFileSaveOption.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int val = (int)(theEvent.getController()).getValue();
                    Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                    dataWriterBfEnum = (DataWriterBFEnum)bob.get("value");
                    StringBuilder sb = new StringBuilder("BrainFlow File Streamer: User selected ");
                    sb.append(dataWriterBfEnum.getString());
                    sb.append(" file location.");
                    output(sb.toString());
                    if (dataWriterBfEnum.getIsCustomLocation()) {
                        FileChooser chooser = new FileChooser(
                            FileChooserMode.SAVE,
                            "bfSelectedFolder",
                            new File(directoryManager.getRecordingsPath()),
                            "Save BrainFlow CSV to file");
                    }
                } else if (theEvent.getAction() == ControlP5.ACTION_ENTER) {
                    lockOutsideElements(true);
                } else if (theEvent.getAction() == ControlP5.ACTION_LEAVE) {
                    lockOutsideElements(false);
                }
            }
        });
        bfFileSaveOption.setPosition(x + 10, y + 10); //Set arbitrary position to start, gets reset on every draw
    }

    private String getBFNetworkTextfieldsAsString() {
        StringBuilder sb = new StringBuilder("streaming_board://");
        sb.append(ipAddressTextfield.getText());
        sb.append(":");
        sb.append(portTextfield.getText());
        return sb.toString();
    }

    private String getBFFileLocationAsString() {
        if (dataLogger.getBfWriterFilePath() == null || dataWriterBfEnum.getIsTurnedOff()) {
            return null;
        }
        return dataLogger.getBfWriterFilePath();
    }

    public String getBrainFlowStreamerString() {
        String s = outputToNetwork.isOn() ? getBFNetworkTextfieldsAsString() : getBFFileLocationAsString();
        return s;
    }

    public boolean getIsBrainFlowStreamerDefaultLocation() {
        return outputToFile.isOn() && dataWriterBfEnum.getIsDefaultLocation();
    }

    private void lockOutsideElements (boolean _toggle) {
        if (eegDataSource == DATASOURCE_CYTON) {
            controlPanel.channelCountBox.lockCp5Objects(_toggle);
            controlPanel.sdBox.lockCp5Objects(_toggle);
            controlPanel.sdBox.cp5_sdBox.get(ScrollableList.class, controlPanel.sdBox.sdBoxDropdownName).setUpdate(!_toggle);
        }
    }

    //Clear text field on double-click
    CallbackListener cb = new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
            Textfield tf = ((Textfield)theEvent.getController());
            tf.clear();
        }
    };

    public void lockCp5Objects(boolean lock) {
        ipAddressTextfield.setLock(lock);
        portTextfield.setLock(lock);
        outputToNetwork.setLock(lock);
        outputToFile.setLock(lock);
        bfFileSaveOption.setLock(lock);
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
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(OPENBCI_DARKBLUE)  // border color when not selected
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
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(OPENBCI_DARKBLUE)  // border color when not selected
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
        textfieldUpdateHelper.checkTextfield(ipAddress);
        textfieldUpdateHelper.checkTextfield(port);
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        popStyle();

        pushStyle();
        fill(OPENBCI_DARKBLUE);
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
        ScrollableList list = localCP5.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(OPENBCI_BLUE) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setOutlineColor(150)
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
            ((Textfield)(theEvent.getController())).clear();
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
    private int TITLE_HEIGHT = 14;
    private int buttonH = 24;

    PlaybackFileBox(int _x, int _y, int _w, int _h, int _padding) {
        x = _x;
        y = _y;
        w = _w;
        h = buttonH + (_padding * 3) + TITLE_HEIGHT;
        padding = _padding;

        //Instantiate local cp5 for this box
        pbfb_cp5 = new ControlP5(ourApplet);
        pbfb_cp5.setGraphics(ourApplet, 0,0);
        pbfb_cp5.setAutoDraw(false);

        createSelectPlaybackFileButton("selectPlaybackFileControlPanel", "SELECT OPENBCI PLAYBACK FILE", x + padding, y + padding*2 + TITLE_HEIGHT, w - padding*2, buttonH);
        createSampleDataButton("selectSampleDataControlPanel", "Sample Data", x + w - sampleDataButton_w - padding, y + padding - 2, sampleDataButton_w, sampleDataButton_h);
    }

    public void update() {
    }

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PLAYBACK FILE", x + padding, y + padding);
        popStyle();

        pbfb_cp5.draw();
    }

    private void createSelectPlaybackFileButton(String name, String text, int _x, int _y, int _w, int _h) {
        selectPlaybackFile = createButton(pbfb_cp5, name, text, _x, _y, _w, _h);
        selectPlaybackFile.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Select a file for playback");
                FileChooser chooser = new FileChooser(
                    FileChooserMode.LOAD,
                    "playbackFileSelected",
                    new File(directoryManager.getGuiDataPath() + "Recordings"),
                    "Select a file for playback");
            }
        });
        selectPlaybackFile.setDescription("Click to open a dialog box to select an OpenBCI playback file (.txt or .csv).");
    }

    private void createSampleDataButton(String name, String text, int _x, int _y, int _w, int _h) {
        sampleDataButton = createButton(pbfb_cp5, name, text, _x, _y, _w, _h, p5, 12, buttonsLightBlue, color(255));
        sampleDataButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Select a file for playback");
                File sampleDataFile = new File(directoryManager.getGuiDataPath() + "Sample_Data" + System.getProperty("file.separator") + "OpenBCI_GUI-v6-meditation.txt");
                FileChooser chooser = new FileChooser(
                    FileChooserMode.LOAD,
                    "playbackFileSelected",
                    sampleDataFile,
                    "Select a file for playback");
            }
        });
        //sampleDataButton.setCornerRoundness((int)(sampleDataButton_h));
        sampleDataButton.setDescription("Click to open the folder containing OpenBCI GUI Sample Data.");
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
        fill(OPENBCI_DARKBLUE);
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

        sdList = cp5_sdBox.addScrollableList(name)
            .setOpen(false)
            .setColor(dropdownColorsGlobal)
            .setOutlineColor(150)
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

    public void lockCp5Objects(boolean lock) {
        sdList.setLock(lock);
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

        createAutoscanButton("CytonRadioAutoscan", "AUTO-SCAN",x + padding, y + padding*2 + headerH, w-(padding*2), autoscanH);
        createSystemStatusButton("CytonSystemStatus", "SYSTEM STATUS", x + padding, y + padding*3 + headerH + autoscanH, w-(padding*2), buttonH);
        createSetChannelButton("CytonSetRadioChannel", "CHANGE CHAN.",x + padding, y + padding*4 + headerH + buttonH + autoscanH, (w-padding*3)/2, 24);
        createOverrideChannelButton("CytonOverrideDongleChannel", "OVERRIDE DONGLE", x + 2*padding + (w-padding*3)/2, y + padding*4 + headerH + buttonH + autoscanH, (w-padding*3)/2, buttonH);
    }
    public void update() {}

    public void draw() {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(OPENBCI_DARKBLUE);
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
        fill(OPENBCI_DARKBLUE);
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

    private void createAutoscanButton(String name, String text, int _x, int _y, int _w, int _h) {
        autoscanButton = createButton(rcb_cp5, name, text, _x, _y, _w, _h);
        autoscanButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                scanChannels();
                controlPanel.hideChannelListCP();
            }
        });
        autoscanButton.setDescription("Scan through channels and connect to a nearby Cyton. This button solves most connection issues!");
    }

    private void createSystemStatusButton(String name, String text, int _x, int _y, int _w, int _h) {
        systemStatusButton = createButton(rcb_cp5, name, text, _x, _y, _w, _h);
        systemStatusButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                getChannel();
                controlPanel.hideChannelListCP();
            }
        });
        systemStatusButton.setDescription("Get connection status and the current channel of your Cyton and USB Dongle.");
    }

    private void createSetChannelButton(String name, String text, int _x, int _y, int _w, int _h) {
        setChannelButton = createButton(rcb_cp5, name, text, _x, _y, _w, _h);
        setChannelButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.channelPopup.setClicked(true);
                controlPanel.channelPopup.setTitleChangeChannel();
            }
        });
        setChannelButton.setDescription("Change the channel of your Cyton and USB Dongle.");
    }

    private void createOverrideChannelButton(String name, String text, int _x, int _y, int _w, int _h) {
        ovrChannelButton = createButton(rcb_cp5, name, text, _x, _y, _w, _h);
        ovrChannelButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                controlPanel.channelPopup.setClicked(true);
                controlPanel.channelPopup.setTitlteOvrDongle();
            }
        });
        ovrChannelButton.setDescription("Change the channel of the USB Dongle only.");
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
        fill(OPENBCI_DARKBLUE);
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

        createStartSessionButton("startSessionButton", "START SESSION", x + padding, y + padding, w-padding*2, h - padding*2);
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

    private void createStartSessionButton(String name, String text, int _x, int _y, int _w, int _h) {
        initSystemButton = createButton(initBox_cp5, name, text, _x, _y, _w, _h);
        initSystemButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (controlPanel.rcBox.isShowing) {
                    controlPanel.hideRadioPopoutBox();
                }
                //If session is not active, start session and flip button state
                initButtonPressed();
            }
        });
    }

    //This is the primary method called when Start/Stop Session Button is pressed in Control Panel
    public void initButtonPressed() {
        if (getInitSessionButtonText().equals("START SESSION")) {
            if ((eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.NONE) || (eegDataSource == DATASOURCE_GANGLION && selectedProtocol == BoardProtocol.NONE)) {
                outputWarn("No Transfer Protocol selected. Please select your Transfer Protocol and retry system initiation.");
                return;
            } else if (eegDataSource == DATASOURCE_CYTON && selectedProtocol == BoardProtocol.SERIAL && cytonDonglePortName == "N/A") { //if data source == normal && if no serial port selected OR no SD setting selected
                outputWarn("No Serial/COM port selected. Attempting to AUTO-CONNECT to Cyton.");
                controlPanel.comPortBox.attemptAutoConnectCyton();   
                return;
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && playbackData_fname == "N/A" && sdData_fname == "N/A") { //if data source == playback && playback file == 'N/A'
                outputWarn("No playback file selected. Please select a playback file and retry system initiation.");        // tell user that they need to select a file before the system can be started
                return;
            } else if (eegDataSource == DATASOURCE_GANGLION && (selectedProtocol == BoardProtocol.NATIVE_BLE || selectedProtocol == BoardProtocol.BLED112) && ganglion_portName == "N/A") {
                outputWarn("No BLE device selected. Please select your Ganglion device and retry system initiation.");
                return;
            } else if (eegDataSource == -1) {//if no data source selected
                outputWarn("No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.");//tell user they must select a data source before initiating system
                return;
            } else { //otherwise, initiate system!
                //verbosePrint("ControlPanel: CPmouseReleased: init");
                setInitSessionButtonText("STOP SESSION");
                // Global steps to START SESSION
                // Prepare the serial port

                controlPanel.fetchSessionNameTextfieldAllBoards();

                //Set this flag to true, and draw "Starting Session..." to screen after then next draw() loop
                midInit = true;
                output("Attempting to Start Session..."); // Show this at the bottom of the GUI
                println("initButtonPressed: Calling initSystem() after next draw()");
            }
        } else {
            //if system is already active ... stop session and flip button state back
            setInitSessionButtonText("START SESSION");
            topNav.setLockTopLeftSubNavCp5Objects(false); //Unlock top left subnav buttons
            //creates new data file name so that you don't accidentally overwrite the old one
            controlPanel.dataLogBoxCyton.setSessionTextfieldText(directoryManager.getFileNameDateTime());
            controlPanel.dataLogBoxGanglion.setSessionTextfieldText(directoryManager.getFileNameDateTime());
            W_Focus focusWidget = (W_Focus) widgetManager.getWidget("W_Focus");
            W_Marker markerWidget = (W_Marker) widgetManager.getWidget("W_Marker");
            focusWidget.killAuditoryFeedback();
            markerWidget.disposeUdpMarkerReceiver();
            haltSystem();
            widgetManager.setAllWidgetsNull();
        }
    }

    public String getInitSessionButtonText() {
        return initSystemButton.getCaptionLabel().getText();
    }

    public void setInitSessionButtonText(String text) {
        initSystemButton.getCaptionLabel().setText(text);
    }
};


