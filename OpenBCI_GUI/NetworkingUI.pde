
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//    Networking UI  (formerly Networking Widget)                            //
//                                                                           //            
//    This UI provides networking capabilities in the OpenBCI GUI.           //
//    The networking protocols can be used for outputting data               //
//    from the OpenBCI GUI to any program that can receive UDP, OSC,         //
//    or LSL input, such as Matlab, MaxMSP, Python, C/C++, etc.              //
//                                                                           //
//    The protocols included are: UDP, OSC, LSL, and Serial                  //
//                                                                           //
//                                                                           //
//    Created by: Gabriel Ibagon (github.com/gabrielibagon), January 2017    //
//    Refactored: Richard Waltman, June-August 2023                          //
//    Converted to popup window: Richard Waltman, December 2023              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

public boolean networkingUIPopupIsOpen = false;

class NetworkingUI extends PApplet implements Runnable {
    
    private final String HEADER_MESSAGE = "Networking UI";
    private color backgroundColor = GREY_235;

    private ControlP5 nwCp5;

    NetworkingSettingsValues nwValues;

    private NetworkingGrid grid;
    private final int TOP_PADDING = 15;
    private final int BOT_PADDING = 50;
    private final int HORIZONTAL_PADDING = 15;
    private final int UI_ELEMENT_PADDING = 5;
    private final int NUM_GRID_ROWS = 12;
    private final int NUM_GRID_COLUMNS = 7;
    private final int ITEM_HEIGHT = 22;
    private final int TEXTFIELD_WIDTH = 125;
    private final int TEXTFIELD_HEIGHT = ITEM_HEIGHT;
    private final int START_STOP_BUTTON_WIDTH = 200;

    private final int GRID_HEIGHT = (TEXTFIELD_HEIGHT + (UI_ELEMENT_PADDING * 2)) * NUM_GRID_ROWS;
    private final int GRID_WIDTH = (TEXTFIELD_WIDTH * NUM_GRID_COLUMNS) + (UI_ELEMENT_PADDING * 2 * NUM_GRID_COLUMNS);
    private final int WIDTH = GRID_WIDTH + (HORIZONTAL_PADDING * 2);
    private final int HEIGHT = TOP_PADDING + GRID_HEIGHT + BOT_PADDING;

    private int x = 0;
    private int y = 0;
    private int w = WIDTH;
    private int h = HEIGHT;

    private Button startButton;
    private Button guideButton;
    private Button dataOutputsButton;
    private ScrollableList protocolDropdown;

    private final String NETWORKING_GUIDE_URL = "https://docs.openbci.com/Software/OpenBCISoftware/GUIWidgets/#networking";
    private final String NETWORKING_DATA_OUTPUTS_URL = "https://docs.google.com/document/d/e/2PACX-1vT-JXd4XyheeK_YKw_J22-nK1kDlsEGgDPnAd1FolEMV5TDBZjBZT-mWh6Jbfpxs1BfrTD6EUYhnC6t/pub";
    
    private final ScrollableList[] DATATYPE_DROPDOWNS = new ScrollableList[NETWORKING_STREAMS_COUNT];
    private final Textfield[] FIRST_ROW_TEXTFIELDS = new Textfield[NETWORKING_STREAMS_COUNT];
    private final Textfield[] SECOND_ROW_TEXTFIELDS = new Textfield[NETWORKING_STREAMS_COUNT];
    private boolean[] firstRowTextfieldWasActive = new boolean[NETWORKING_STREAMS_COUNT];
    private boolean[] secondRowTextfieldWasActive = new boolean[NETWORKING_STREAMS_COUNT];

    private List<String> serialNetworkingComPorts;
    private ScrollableList serialPortDropdown;
    private ScrollableList serialBaudDropdown;

    NetworkingUI() {
        super();
        networkingUIPopupIsOpen = true;
        output("Networking UI: Networking UI opened.");

        Thread t = new Thread(this);
        t.start();
    }

    @Override
    public void run() {
        PApplet.runSketch(new String[] {HEADER_MESSAGE}, this);
    }

    @Override
    void settings() {
        size(w, h);
    }

    @Override
    void setup() {

        surface.setTitle(HEADER_MESSAGE);
        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.toFront();
        frame.requestFocus();

        nwValues = dataProcessing.networkingSettings.getValues();

        serialNetworkingComPorts = new ArrayList<String>(getComPorts());

        initializeUI();
        updateUIObjectPositions();
    }

    @Override
    public synchronized void draw() {
        update();
        
        pushStyle();
        background(backgroundColor);
        popStyle();

        grid.draw();

        pushStyle();
        textAlign(RIGHT, CENTER);
        fill(OPENBCI_DARKBLUE);
        RectDimensions protocolCellDims = grid.getCellDims(0, 5);
        textFont(p5, 12);
        text("Protocol", protocolCellDims.x + protocolCellDims.w - UI_ELEMENT_PADDING, protocolCellDims.y + protocolCellDims.h / 2 - 2);
        popStyle();

        //Draw cp5 objects on top of everything
        try {
            nwCp5.draw();
        } catch (ConcurrentModificationException e) {
            outputError("Networking UI: Error drawing cp5: " + e.getMessage());
        }
        
    }

    @Override
    void exit() {
        dispose();
        networkingUIPopupIsOpen = false;
    }

    // Dispose of the popup window externally
    public void exitPopup() {
        output("Networking UI: Closing Networking UI.");
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        networkingUIPopupIsOpen = false;
    }

    private void update() {
        showApplicablenwcp5Elements();

        if (nwValues.getProtocol() == NetworkProtocol.SERIAL) {
            // For serial mode, disable fft output by switching to bandpower instead
            disableCertainSerialOutputs();
        } else {
            for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
                textfieldUpdateHelper.checkTextfield(FIRST_ROW_TEXTFIELDS[i]);
                textfieldUpdateHelper.checkTextfield(SECOND_ROW_TEXTFIELDS[i]);
            }
        }

        if (networkingSettingsChanged) {
            println("Networking UI: Networking settings changed, updating UI...");
            updateAllUIElements();
            networkingSettingsChanged = false;
        }
    }

    private void initializeUI() {
        nwCp5 = new ControlP5(this);
        nwCp5.setGraphics(this, 0, 0);
        nwCp5.setAutoDraw(false);

        grid = new NetworkingGrid(NUM_GRID_ROWS, NUM_GRID_COLUMNS, ITEM_HEIGHT);
        setGridTextLabels();

        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            String firstRowTextfieldString = "";
            String secondRowTextfieldString = "";

            switch (nwValues.getProtocol()) {
                case OSC:
                    firstRowTextfieldString = nwValues.getOSCIp(i);
                    secondRowTextfieldString = nwValues.getOSCPort(i);
                    break;
                case UDP:
                    firstRowTextfieldString = nwValues.getUDPIp(i);
                    secondRowTextfieldString = nwValues.getUDPPort(i);
                    break;
                case LSL:
                    firstRowTextfieldString = nwValues.getLSLName(i);
                    secondRowTextfieldString = nwValues.getLSLType(i);
                    break;
                case SERIAL:
                    break;
            }

            FIRST_ROW_TEXTFIELDS[i] = createTextField(i, "firstRowTextfield" + i, firstRowTextfieldString);
            SECOND_ROW_TEXTFIELDS[i] = createTextField(i, "secondRowTextfield" + i, secondRowTextfieldString);
        }

        createPortDropdown();
        createBaudDropdown();

        createStartButton();

        for (int i = NETWORKING_STREAMS_COUNT - 1; i >= 0; i--) {
            DATATYPE_DROPDOWNS[i] = createDatatypeDropdown(i, "dataType_" + i, nwValues.getDataType(i).getString());
        }

        createGuideButton();
        createDataOutputsButton();
        createProtocolDropdown();

        boolean showAllDataTypeDropdowns = nwValues.getProtocol() != NetworkProtocol.SERIAL;
        showDataTypeDropdownsTwoThroughTen(showAllDataTypeDropdowns);
    }

    private void updateUIObjectPositions() {
        grid.setDim(x + HORIZONTAL_PADDING, y + TOP_PADDING, GRID_WIDTH);
        grid.setTableHeight(GRID_HEIGHT);
        grid.dynamicallySetTextVerticalPadding(3, 0);
        grid.setHorizontalCenterTextInCells(true);
        grid.setDrawTableInnerLines(false);
        grid.setDrawTableBorder(false);

        final int uiPadding = UI_ELEMENT_PADDING;

        RectDimensions guideButtonDims = grid.getCellDims(0, 0);
        guideButton.setPosition(guideButtonDims.x + uiPadding, guideButtonDims.y + uiPadding);

        RectDimensions dataOutputsButtonDims = grid.getCellDims(0, 1);
        dataOutputsButton.setPosition(dataOutputsButtonDims.x + uiPadding, dataOutputsButtonDims.y + uiPadding);

        RectDimensions protocolDropdownDims = grid.getCellDims(0, 6);
        protocolDropdown.setPosition(protocolDropdownDims.x + uiPadding, protocolDropdownDims.y + uiPadding);

        RectDimensions startButtonDims = grid.getCellDims(11, 2);
        final int startButtonX = x + (w / 2) - (START_STOP_BUTTON_WIDTH / 2);
        startButton.setPosition(startButtonX, startButtonDims.y + uiPadding);

        final int dropdownsItemsToShow = nwValues.getAllDataTypeNames().size() + 1;
        final int dropdownHeight = dropdownsItemsToShow * ITEM_HEIGHT;

        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {

            final int datatypeGridRow = i < NETWORKING_STREAMS_COUNT / 2 ? 3 : 7;
            final int gridColumn = i % (NETWORKING_STREAMS_COUNT / 2) + 1;

            RectDimensions datatypeCellDims = grid.getCellDims(datatypeGridRow, gridColumn);
            DATATYPE_DROPDOWNS[i].setPosition(datatypeCellDims.x + uiPadding, datatypeCellDims.y + uiPadding);

            RectDimensions firstTextfieldDims = grid.getCellDims(datatypeGridRow + 1, gridColumn);
            RectDimensions secondTextfieldDims = grid.getCellDims(datatypeGridRow + 2, gridColumn);

            FIRST_ROW_TEXTFIELDS[i].setPosition(firstTextfieldDims.x + uiPadding, firstTextfieldDims.y + uiPadding);
            SECOND_ROW_TEXTFIELDS[i].setPosition(secondTextfieldDims.x + uiPadding, secondTextfieldDims.y + uiPadding);
            
            if (i == 0) {
                serialBaudDropdown.setPosition(firstTextfieldDims.x + uiPadding, firstTextfieldDims.y + uiPadding);
                serialPortDropdown.setPosition(secondTextfieldDims.x + uiPadding, secondTextfieldDims.y + uiPadding);
            }
        }
    }

    private LinkedList<String> getComPorts() {
        final SerialPort[] allCommPorts = SerialPort.getCommPorts();
        LinkedList<String> cuCommPorts = new LinkedList<String>();
        for (SerialPort port : allCommPorts) {
            // Filter out .tty ports for Mac users, to only show .cu addresses
            if (isMac() && port.getSystemPortName().startsWith("tty")) {
                continue;
            }
            StringBuilder found = new StringBuilder("");
            if (isMac() || isLinux())
                found.append("/dev/");
            found.append(port.getSystemPortName());
            cuCommPorts.add(found.toString());
        }
        return cuCommPorts;
    }

    // Shows and Hides appropriate nwCp5 elements within widget
    public void showApplicablenwcp5Elements() {
        boolean isSerialProtocol = nwValues.getProtocol() == NetworkProtocol.SERIAL;
        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            FIRST_ROW_TEXTFIELDS[i].setVisible(!isSerialProtocol);
            SECOND_ROW_TEXTFIELDS[i].setVisible(!isSerialProtocol);
        }
        serialPortDropdown.setVisible(isSerialProtocol);
        serialBaudDropdown.setVisible(isSerialProtocol);
    }

    private Boolean textfieldsAreActive(Textfield[] textfields) {
        boolean isActive = false;
        for (Textfield tf : textfields) {
            if (tf.isFocus()) {
                isActive = true;
            }
        }
        return isActive;
    }

    /* Create textfields for network parameters */
    private Textfield createTextField( int _streamIndex, String name, String default_text) {
        final int streamIndex = _streamIndex;
        Textfield tf = nwCp5.addTextfield(name).align(10, 100, 10, 100) // Alignment
                .setSize(TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT) // Size of textfield
                .setFont(f2)
                .setFocus(false) // Deselects textfield
                .setColor(OPENBCI_DARKBLUE)
                .setColorBackground(color(255, 255, 255)) // text field bg color
                .setColorValueLabel(OPENBCI_DARKBLUE) // text color
                .setColorForeground(OPENBCI_DARKBLUE) // border color when not selected
                .setColorActive(isSelected_color) // border color when selected
                .setColorCursor(OPENBCI_DARKBLUE)
                .setText(default_text) // Default text in the field
                .setCaptionLabel("") // Remove caption label
                .setVisible(false) // Initially hidden
                .setAutoClear(false) // Autoclear
        ;
        tf.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Networking UI: Enter your custom streaming attribute.");
                tf.clear();
            }
        });
        tf.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                String myTextfieldValue = tf.getText();
                boolean isFirstRow = name.startsWith("firstRowTextfield");
                //println("myTextfieldValue = " + myTextfieldValue + ", isFirstRow = " + isFirstRow + ", streamIndex = " + streamIndex);
                //Set to default value if the textfield would be blank
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfieldValue.equals("")) {
                    myTextfieldValue = getStoredTextfieldValue(isFirstRow, streamIndex);
                    setStreamAttributeFromTextfield(isFirstRow, streamIndex, myTextfieldValue);
                }
                //Pressing ENTER in the Textfield triggers a "Broadcast"
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    //Try to clean up typing accidents from user input in Textfield
                    String regexReplace = nwValues.getProtocol() == NetworkProtocol.LSL ? "[!@#$%^&()=/*]" : "[A-Za-z!@#$%^&()=/*_]";
                    String cleanedTextfieldValue = myTextfieldValue.replaceAll(regexReplace,"");
                    tf.setText(cleanedTextfieldValue);
                    setStreamAttributeFromTextfield(isFirstRow, streamIndex, cleanedTextfieldValue);
                }
                if (tf.isActive()) {
                    if (isFirstRow) {
                        firstRowTextfieldWasActive[streamIndex] = true; 
                    } else {
                        secondRowTextfieldWasActive[streamIndex] = true;
                    }
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        tf.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                String myTextfieldValue = tf.getText();
                boolean isFirstRow = name.startsWith("firstRowTextfield");
                if (!tf.isActive() && tf.getText().equals("")) {
                    myTextfieldValue = getStoredTextfieldValue(isFirstRow, streamIndex);
                    tf.setText(myTextfieldValue);
                } else {
                    /// If released outside textfield and a state change has occured, submit, clean, and set the value
                    if (isFirstRow) {
                        if (firstRowTextfieldWasActive[streamIndex] != FIRST_ROW_TEXTFIELDS[streamIndex].isActive()) {
                            tf.submit();
                            firstRowTextfieldWasActive[streamIndex] = false;
                        }
                    } else {
                        if (secondRowTextfieldWasActive[streamIndex] != SECOND_ROW_TEXTFIELDS[streamIndex].isActive()) {
                            tf.submit();
                            secondRowTextfieldWasActive[streamIndex] = false;
                        }
                    }
                }
            }
        });
        return tf;
    }

    private void createStartButton() {
        NetworkingSettings nwSettings = dataProcessing.networkingSettings;
        startButton = createButton(nwCp5, "startStopNetworkStream", "",
                x + w / 2 - 70, y + h - 40, START_STOP_BUTTON_WIDTH, TEXTFIELD_HEIGHT, 
                0, p4, 14, TURN_ON_GREEN, OPENBCI_DARKBLUE, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        startButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!nwSettings.getNetworkingIsStreaming()) {
                    try {
                        nwSettings.initializeStreams();
                        nwSettings.startNetwork();           
                        output("Network Stream Started");
                    } catch (Exception e) {
                        e.printStackTrace();
                        String exception = e.toString();
                        String[] nwError = split(exception, ':');
                        outputError("Networking Error - Port: " + nwError[2]);
                        nwSettings.stopNetwork();
                    }
                } else {
                    nwSettings.stopNetwork();
                    output("Network Stream Stopped");
                }
                updateStartStopButton();
            }
        });
        updateStartStopButton();
        startButton.setDescription("Click here to Start and Stop the network stream for the chosen protocol.");
    }

    private void updateStartStopButton() {
        NetworkingSettings nwSettings = dataProcessing.networkingSettings;
        boolean isStreaming = nwSettings.getNetworkingIsStreaming();
        String protocolToDisplay = isStreaming ?
            nwSettings.getActiveNetworkProtocol().getString() :
            nwValues.getProtocol().getString();
        color buttonColor = isStreaming ? TURN_OFF_RED : TURN_ON_GREEN;
        String buttonText = isStreaming ? 
            "Stop " + protocolToDisplay + " Stream" :
            "Start " + protocolToDisplay + " Stream";
        startButton.setColorBackground(buttonColor);
        startButton.getCaptionLabel().setText(buttonText);
    }

    private void createGuideButton() {
        guideButton = createButton(nwCp5, "networkingGuideButton", "Networking Guide", 
                x, y, TEXTFIELD_WIDTH, ITEM_HEIGHT, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        guideButton.setBorderColor(OBJECT_BORDER_GREY);
        guideButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser(NETWORKING_GUIDE_URL);
                output("Opening Networking Widget Guide using default browser.");
            }
        });
        guideButton.setDescription("Click to open the Networking Widget Guide in your default browser.");
    }

    private void createDataOutputsButton() {
        dataOutputsButton = createButton(nwCp5, "dataOutputsButton", "Data Outputs",
                x, y, TEXTFIELD_WIDTH, ITEM_HEIGHT, p5, 12, colorNotPressed,
                OPENBCI_DARKBLUE);
        dataOutputsButton.setBorderColor(OBJECT_BORDER_GREY);
        dataOutputsButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser(NETWORKING_DATA_OUTPUTS_URL);
                output("Opening Networking Data Outputs Guide using default browser.");
            }
        });
        dataOutputsButton.setDescription("Click to open the Networking Data Outputs Guide in your default browser.");
    }

    private ScrollableList createDatatypeDropdown(int _streamIndex, String name, String default_text) {
        final int maxListItemsToShow = 8;
        final int streamIndex = _streamIndex;
        ScrollableList scrollList = nwCp5.addScrollableList(name)
                .setOpen(false)
                .setOutlineColor(OPENBCI_DARKBLUE)
                .setColorBackground(OPENBCI_BLUE) // text field bg color
                .setColorValueLabel(color(255)) // text color
                .setColorCaptionLabel(color(255))
                .setColorForeground(color(125)) // border color when not selected
                .setColorActive(BUTTON_PRESSED) // border color when selected
                // .setColorCursor(color(26,26,26))
                .setSize(TEXTFIELD_WIDTH, maxListItemsToShow * ITEM_HEIGHT)// + maxFreqList.size())
                .setBarHeight(ITEM_HEIGHT) // height of top/primary bar
                .setItemHeight(ITEM_HEIGHT) // height of all item/dropdown bars
                .addItems(nwValues.getAllDataTypeNames()) // used to be .addItems(maxFreqList)
                .setVisible(true);
        scrollList.getCaptionLabel() // the caption label is the text object in the primary bar
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText(default_text).setFont(h4).setSize(14)
                .getStyle().setPaddingTop(4); // need to grab style before affecting the paddingTop                           
        scrollList.getValueLabel() // the value label is connected to the text objects in the dropdown item bars
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText(default_text).setFont(h5).setSize(12) // set the font size of the item bars to 14pt
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(3); // 4-pixel vertical offset to center text
        scrollList.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int valueIndex = (int)(theEvent.getController()).getValue();
                    println("name = " + name + ", value = " + valueIndex + ", streamIndex = " + streamIndex);
                    nwValues.setDataType(streamIndex, valueIndex);
                }
            }
        });
        return scrollList;
    }

    private void createProtocolDropdown() {
        List<String> protocolList = EnumHelper.getEnumStrings(NetworkProtocol.class);
        protocolDropdown = nwCp5.addScrollableList("networkingProtocolDropdown")
                .setOpen(false)
                .setOutlineColor(OPENBCI_DARKBLUE)
                .setColorBackground(OPENBCI_BLUE) // text field bg color
                .setColorValueLabel(color(255)) // text color
                .setColorCaptionLabel(color(255))
                .setColorForeground(color(125)) // border color when not selected
                .setColorActive(BUTTON_PRESSED) // border color when selected
                // .setColorCursor(color(26,26,26))
                .setSize(TEXTFIELD_WIDTH, (protocolList.size() + 1) * (ITEM_HEIGHT))// + maxFreqList.size())
                .setBarHeight(ITEM_HEIGHT) // height of top/primary bar
                .setItemHeight(ITEM_HEIGHT) // height of all item/dropdown bars
                .addItems(protocolList) // used to be .addItems(maxFreqList)
                .setVisible(true);
        protocolDropdown.getCaptionLabel() // the caption label is the text object in the primary bar
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText(nwValues.getProtocol().getString()).setFont(h4).setSize(14)
                .getStyle().setPaddingTop(4); // need to grab style before affecting the paddingTop                           
        protocolDropdown.getValueLabel() // the value label is connected to the text objects in the dropdown item bars
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText(nwValues.getProtocol().getString()).setFont(h5).setSize(12) // set the font size of the item bars to 14pt
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(3); // 4-pixel vertical offset to center text
        protocolDropdown.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int valueIndex = (int)(theEvent.getController()).getValue();
                    nwValues.setProtocol(valueIndex);
                    updateAllUIElements();
                }
            }
        });
    }

    private void createBaudDropdown() {
        serialBaudDropdown = nwCp5.addScrollableList("baudRate").setOpen(false)
            .setOutlineColor(OPENBCI_DARKBLUE).setColorBackground(OPENBCI_BLUE) // text field bg color
            .setColorValueLabel(color(255)) // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125)) // border color when not selected
            .setColorActive(BUTTON_PRESSED) // border color when selected
            // .setColorCursor(color(26,26,26))
            .setSize(TEXTFIELD_WIDTH, (nwValues.getBaudRateList().size() + 1) * (ITEM_HEIGHT))// + maxFreqList.size())
            .setBarHeight(ITEM_HEIGHT) // height of top/primary bar
            .setItemHeight(ITEM_HEIGHT) // height of all item/dropdown bars
            .addItems(nwValues.getBaudRateList()) // used to be .addItems(maxFreqList)
            .setVisible(true);
        serialBaudDropdown.getCaptionLabel() // the caption label is the text object in the primary bar
            .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
            .setText(nwValues.getSerialBaud()).setFont(h4).setSize(14)
            .getStyle() // need to grab style before affecting the paddingTop
            .setPaddingTop(4);
        serialBaudDropdown.getValueLabel() // the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
            .setText("None").setFont(h5).setSize(12) // set the font size of the item bars to 14pt
            .getStyle() // need to grab style before affecting the paddingTop
            .setPaddingTop(3); // 4-pixel vertical offset to center text
        serialBaudDropdown.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int valueIndex = (int)(theEvent.getController()).getValue();
                    String baudRate = nwValues.getBaudRateList().get(valueIndex);
                    nwValues.setSerialBaud(baudRate);
                }
            }
        });
    }

    private void createPortDropdown() {
        boolean noComPortsFound = serialNetworkingComPorts.size() == 0 ? true : false;
        String currentPort = nwValues.getSerialPort();
        boolean listContainsCurrentPort = serialNetworkingComPorts.contains(currentPort);
        if (noComPortsFound) {
            serialNetworkingComPorts.add(currentPort); // Fix #642 and #637
        } else {
            if (!listContainsCurrentPort) {
                currentPort = "None";
                nwValues.setSerialPort(currentPort);
            }
        }
        serialPortDropdown = nwCp5.addScrollableList("portName").setOpen(false)
            .setOutlineColor(OPENBCI_DARKBLUE)
            .setColorBackground(OPENBCI_BLUE) // text field bg color
            .setColorValueLabel(color(255)) // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125)) // border color when not selected
            .setColorActive(BUTTON_PRESSED) // border color when selected
            // .setColorCursor(color(26,26,26))
            .setSize(TEXTFIELD_WIDTH, (serialNetworkingComPorts.size() + 1) * (ITEM_HEIGHT))// + maxFreqList.size())
            .setBarHeight(ITEM_HEIGHT) // height of top/primary bar
            .setItemHeight(ITEM_HEIGHT) // height of all item/dropdown bars
            .addItems(serialNetworkingComPorts) // used to be .addItems(maxFreqList)
            .setVisible(true);
        serialPortDropdown.getCaptionLabel() // the caption label is the text object in the primary bar
            .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
            .setText(currentPort).setFont(h4).setSize(14)
            .getStyle() // need to grab style before affecting the paddingTop
            .setPaddingTop(4);
        serialPortDropdown.getValueLabel() // the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
            .setText(currentPort).setFont(h5).setSize(12) // set the font size of the item bars to 14pt
            .getStyle() // need to grab style before affecting the paddingTop
            .setPaddingTop(3); // 4-pixel vertical offset to center text
        serialPortDropdown.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    int valueIndex = (int)(theEvent.getController()).getValue();
                    String portName = serialNetworkingComPorts.get(valueIndex);
                    nwValues.setSerialPort(portName);
                }
            }
        });
    }

    public synchronized void updateAllUIElements() {
        nwValues = dataProcessing.networkingSettings.getValues();
        setProtocolDropdown(nwValues.getProtocol().getString());
        setGridTextLabels();
        if (!dataProcessing.networkingSettings.getNetworkingIsStreaming()) {
            updateStartStopButton();
        }
        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            setDataTypeDropdown(i, nwValues.getDataType(i).getString());
            setFirstRowTextfield(i, getStoredTextfieldValue(true, i));
            setSecondRowTextfield(i, getStoredTextfieldValue(false, i));
        }
        boolean showAllDataTypeDropdowns = nwValues.getProtocol() != NetworkProtocol.SERIAL;
        showDataTypeDropdownsTwoThroughTen(showAllDataTypeDropdowns);
        setSerialPortDropdown(nwValues.getSerialPort());
        setSerialBaudDropdown(nwValues.getSerialBaud());
    }

    public void disableCertainSerialOutputs() {
        // Disable serial fft ouput and display message, it's too much data for serial coms
        if (nwValues.getProtocol() == NetworkProtocol.SERIAL) {
            if (DATATYPE_DROPDOWNS[0].getCaptionLabel().getText().equals(NetworkDataType.FFT.getString())) {
                outputError("Please use Band Power instead of FFT for Serial Output. Changing data type...");
                println("Networking: Changing data type from FFT to BandPower. FFT data is too large to send over Serial communication.");
                DATATYPE_DROPDOWNS[0].getCaptionLabel().setText(NetworkDataType.BAND_POWERS.getString());
                DATATYPE_DROPDOWNS[0].setValue(nwValues.getAllDataTypeNames().indexOf(NetworkDataType.BAND_POWERS.getString()));
            }
        }
    }

    private void setGridTextLabels() {
        String firstRowTextfieldLabel = "";
        String secondRowTextfieldLabel = "";
        String firstRowTextfieldLabel2 = "";
        String secondRowTextfieldLabel2 = "";
        String secondRowDataTypeLabel = nwValues.getProtocol() != NetworkProtocol.SERIAL ? "Data Type" : "";
        switch (nwValues.getProtocol()) {
            case OSC:
            case UDP:
                firstRowTextfieldLabel = "IP Address";
                secondRowTextfieldLabel = "Port";
                firstRowTextfieldLabel2 = firstRowTextfieldLabel;
                secondRowTextfieldLabel2 = secondRowTextfieldLabel;
                break;
            case LSL:
                firstRowTextfieldLabel = "Name";
                secondRowTextfieldLabel = "Type";
                firstRowTextfieldLabel2 = firstRowTextfieldLabel;
                secondRowTextfieldLabel2 = secondRowTextfieldLabel;
                break;
            case SERIAL:
                firstRowTextfieldLabel = "Baud Rate";
                secondRowTextfieldLabel = "Port";
                break;
        }
        grid.setString("Data Type", 3, 0);
        grid.setString(firstRowTextfieldLabel, 4, 0);
        grid.setString(secondRowTextfieldLabel, 5, 0);
        grid.setString(secondRowDataTypeLabel, 7, 0);
        grid.setString(firstRowTextfieldLabel2, 8, 0);
        grid.setString(secondRowTextfieldLabel2, 9, 0); 
        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            String streamNumberLabel = "Stream " + (i + 1);
            if (nwValues.getProtocol() == NetworkProtocol.SERIAL && i > 0) {
                streamNumberLabel = "";
            } 
            grid.setString(streamNumberLabel, i < NETWORKING_STREAMS_COUNT / 2 ? 2 : 6, i % (NETWORKING_STREAMS_COUNT / 2) + 1);
        }
    }

    private void showDataTypeDropdownsTwoThroughTen(boolean b) {
        for (int i = 1; i < NETWORKING_STREAMS_COUNT; i++) {
            DATATYPE_DROPDOWNS[i].setVisible(b);
        }
    }

    public ScrollableList getDataTypeDropdown(int i) {
        return DATATYPE_DROPDOWNS[i];
    }

    public Textfield getFirstRowTextfield(int i) {
        return FIRST_ROW_TEXTFIELDS[i];
    }

    public Textfield getSecondRowTextfield(int i) {
        return SECOND_ROW_TEXTFIELDS[i];
    }

    public ScrollableList getSerialPortDropdown() {
        return serialPortDropdown;
    }

    public ScrollableList getSerialBaudDropdown() {
        return serialBaudDropdown;
    }

    public List<String> getSerialNetworkingComPorts() {
        return serialNetworkingComPorts;
    }

    public void setProtocolDropdown(String s) {
        protocolDropdown.getCaptionLabel().setText(s);
    }

    public void setDataTypeDropdown(int i, String s) {
        DATATYPE_DROPDOWNS[i].getCaptionLabel().setText(s);
    }

    public void setFirstRowTextfield(int i, String s) {
        FIRST_ROW_TEXTFIELDS[i].setText(s);
    }

    public void setSecondRowTextfield(int i, String s) {
        SECOND_ROW_TEXTFIELDS[i].setText(s);
    }

    public void setSerialPortDropdown(String s) {
        serialPortDropdown.getCaptionLabel().setText(s);
    }

    public void setSerialBaudDropdown(String s) {
        serialBaudDropdown.getCaptionLabel().setText(s);
    }

    public NetworkingUI getInstance() {
        return this;
    }
    
    private void setStreamAttributeFromTextfield(boolean isFirstRow, int streamIndex, String myTextfieldValue) {
        switch (nwValues.getProtocol()) {
            case OSC:
                if (isFirstRow) {
                    nwValues.setOSCIp(streamIndex, myTextfieldValue);
                } else {
                    nwValues.setOSCPort(streamIndex, myTextfieldValue);
                }
                break;
            case UDP:
                if (isFirstRow) {
                    nwValues.setUDPIp(streamIndex, myTextfieldValue);
                } else {
                    nwValues.setUDPPort(streamIndex, myTextfieldValue);
                }
                break;
            case LSL:
                if (isFirstRow) {
                    nwValues.setLSLName(streamIndex, myTextfieldValue);
                } else {
                    nwValues.setLSLType(streamIndex, myTextfieldValue);
                }
                break;
            case SERIAL:
                break;
        }
    }

    private String getStoredTextfieldValue(boolean isFirstRow, int streamIndex) {
        switch (nwValues.getProtocol()) {
            case OSC:
                if (isFirstRow) {
                    return nwValues.getOSCIp(streamIndex);
                } else {
                    return nwValues.getOSCPort(streamIndex);
                }
            case UDP:
                if (isFirstRow) {
                    return nwValues.getUDPIp(streamIndex);
                } else {
                    return nwValues.getUDPPort(streamIndex);
                }
            case LSL:
                if (isFirstRow) {
                    return nwValues.getLSLName(streamIndex);
                } else {
                    return nwValues.getLSLType(streamIndex);
                }
            case SERIAL:
            default:
                return "";
        }
    }



    class NetworkingGrid {
        private int numRows;
        private int numCols;

        private int[] colOffset;
        private int[] rowOffset;
        private int rowHeight;
        private boolean horizontallyCenterTextInCells = false;
        private boolean drawTableBorder = false;
        private boolean drawTableInnerLines = true;

        private int x, y, w;
        private int pad_horiz = 5;
        private int pad_vert = 5;

        private PFont tableFont = p5;
        private int tableFontSize = 12;

        private color[][] textColors;

        private String[][] strings;

        NetworkingGrid(int _numRows, int _numCols, int _rowHeight) {
            numRows = _numRows;
            numCols = _numCols;
            rowHeight = _rowHeight;

            colOffset = new int[numCols];
            rowOffset = new int[numRows];

            strings = new String[numRows][numCols];
            textColors = new color[numRows][numCols];

            color defaultTextColor = OPENBCI_DARKBLUE;
            for (color[] row: textColors) {
                Arrays.fill(row, defaultTextColor);
            }
        }

        public void draw() {
            pushStyle();
            textAlign(LEFT);        
            stroke(OPENBCI_DARKBLUE);
            textFont(tableFont, tableFontSize);

            if (drawTableInnerLines) {
                // draw row lines
                for (int i = 0; i < numRows - 1; i++) {
                    line(x, y + rowOffset[i], x + w, y + rowOffset[i]);
                }

                // draw column lines
                for (int i = 1; i < numCols; i++) {
                    line(x + colOffset[i], y, x + colOffset[i], y + rowOffset[numRows - 1]);
                }
            }

            // draw cell strings
            for (int row = 0; row < numRows; row++) {
                for (int col = 0; col < numCols; col++) {
                    if (strings[row][col] != null) {
                        fill(textColors[row][col]);
                        textAlign(horizontallyCenterTextInCells ? CENTER : LEFT);
                        text(strings[row][col], x + colOffset[col] + pad_horiz, y + rowOffset[row] - pad_vert);
                    }
                }
            }

            if (drawTableBorder) {
                noFill();
                stroke(OPENBCI_DARKBLUE);
                rect(x, y, w, rowOffset[numRows - 1]);
            }
            
            popStyle();
        }

        public RectDimensions getCellDims(int row, int col) {
            RectDimensions result = new RectDimensions();
            result.x = x + colOffset[col] + 1; // +1 accounts for line thickness
            result.y = y + rowOffset[row] - rowHeight;
            result.w = w / numCols - 1; // -1 account for line thickness
            result.h = rowHeight;

            return result;
        }

        public void setDim(int _x, int _y, int _w) {
            x = _x;
            y = _y;
            w = _w;
            
            final float colFraction = 1.f / numCols;

            for (int i = 0; i < numCols; i++) {
                colOffset[i] = round(w * colFraction * i);
            }

            for (int i = 0; i < numRows; i++) {
                rowOffset[i] = rowHeight * (i + 1);
            }
        }

        public void setString(String s, int row, int col) {
            strings[row][col] = s;
        }

        public void setTableFontAndSize(PFont _font, int _fontSize) {
            tableFont = _font;
            tableFontSize = _fontSize;
        }

        public void setRowHeight(int _height) {
            rowHeight = _height;
        }
        
        //This overrides the rowHeight and rowOffset when setting the total height of the Grid.
        public void setTableHeight(int _height) {
            rowHeight = _height / numRows;
            for (int i = 0; i < numRows; i++) {
                rowOffset[i] = rowHeight * (i + 1);
            }
        }

        public void setTextColor(color c, int row, int col) {
            textColors[row][col] = c;
        }

        //Change vertical padding for all cells based on the string/text height from a given cell
        public void dynamicallySetTextVerticalPadding(int row, int col) {
            float _textH = getFontStringHeight(tableFont, strings[row][col]);
            pad_vert =  int( (rowHeight - _textH) / 2); //Force round down here
        }

        public void setHorizontalCenterTextInCells(boolean b) {
            horizontallyCenterTextInCells = b;
            pad_horiz = b ? getCellDims(0,0).w/2 : 5;
        }

        public void setDrawTableBorder(boolean b) {
            drawTableBorder = b;
        }

        public void setDrawTableInnerLines(boolean b) {
            drawTableInnerLines = b;
        }

        public int getHeight() {
            return rowHeight * numRows;
        }
    }
};
