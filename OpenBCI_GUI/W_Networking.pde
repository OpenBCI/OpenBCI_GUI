
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//    W_Networking.pde (Networking Widget)                                   //
//                                                                           //            
//    This widget provides networking capabilities in the OpenBCI GUI.       //
//    The networking protocols can be used for outputting data               //
//    from the OpenBCI GUI to any program that can receive UDP, OSC,         //
//    or LSL input, such as Matlab, MaxMSP, Python, C/C++, etc.              //
//                                                                           //
//    The protocols included are: UDP, OSC, and LSL.                         //
//                                                                           //
//                                                                           //
//    Created by: Gabriel Ibagon (github.com/gabrielibagon), January 2017    //
//    Refactored: Richard Waltman, June 2023                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

class W_Networking extends Widget {

    /* Variables for protocol selection */
    public int protocolIndex;
    public String protocolMode;

    /* Widget CP5 */
    public ControlP5 cp5_networking;
    public ControlP5 cp5_networking_dropdowns;
    public ControlP5 cp5_networking_baudRate;
    public ControlP5 cp5_networking_portName;

    /* UI Organization */
    /* Widget grid */
    private int column0, column1, column2, column3, column4;
    private int fullColumnWidth;
    private int halfWidth;
    private int row0, row1, row2, row3, row4, row5;
    private int itemWidth = 96;
    private final float datatypeDropdownScaling = .45;

    /* UI */
    private Boolean osc_visible;
    private Boolean udp_visible;
    private Boolean lsl_visible;
    private Boolean serial_visible;

    private Boolean cp5ElementsAreActive = false;
    private Boolean previousCP5State = false;
    private Button startButton;
    private Button guideButton;
    private Button dataOutputsButton;

    /* Networking */
    private Boolean networkActive;

    /* Streams Objects */
    private Stream stream1;
    private Stream stream2;
    private Stream stream3;
    private Stream stream4;

    private List<String> serialNetworkingComPorts;
    private int comPortToSave;
    private String defaultBaud;

    public LinkedList<String> protocols = new LinkedList<String>(Arrays.asList("UDP", "LSL", "OSC", "Serial"));
    public LinkedList<String> dataTypes = new LinkedList<String>(Arrays.asList("None", "Focus", "EMGJoystick", "AvgBandPower",
            "TimeSeriesFilt", "TimeSeriesRaw", "EMG", "Accel/Aux", "Marker", "Pulse", "BandPower", "FFT"));
    public LinkedList<String> baudRates = new LinkedList<String>(Arrays.asList("57600", "115200", "250000", "500000"));
    public LinkedList<String> dataTypeNames = new LinkedList<String>(
            Arrays.asList("dataType1", "dataType2", "dataType3", "dataType4"));

    private String[] oscTextFieldNames = { "OSC_ip1", "OSC_port1", "OSC_ip2", "OSC_port2",
            "OSC_ip3", "OSC_port3", "OSC_ip4", "OSC_port4" };
    private String[] oscTextDefaultVals = { "127.0.0.1", "12345", "127.0.0.1", "12346", "127.0.0.1",
            "12347", "127.0.0.1", "12348" };
    private String[] udpTextFieldNames = { "UDP_ip1", "UDP_port1", "UDP_ip2", "UDP_port2", "UDP_ip3", "UDP_port3" };
    private String[] udpTextDefaultVals = { "127.0.0.1", "12345", "127.0.0.1", "12346", "127.0.0.1", "12347", "127.0.0.1",
            "12348" };
    private String[] lslTextFieldNames = { "LSL_name1", "LSL_type1", "LSL_name2", "LSL_type2", "LSL_name3", "LSL_type3" };
    private String[] lslTextDefaultVals = { "obci_eeg1", "EEG", "obci_eeg2", "EEG", "obci_eeg3", "EEG" };
    private final String NETWORKING_GUIDE_URL = "https://docs.openbci.com/Software/OpenBCISoftware/GUIWidgets/#networking";
    private final String NETWORKING_DATA_OUTPUTS_URL = "https://docs.google.com/document/d/e/2PACX-1vR_4DXPTh1nuiOwWKwIZN3NkGP3kRwpP4Hu6fQmy3jRAOaydOuEI1jket6V4V6PG4yIG15H1N7oFfdV/pub";
    private boolean configIsVisible = false;
    private boolean layoutIsVisible = false;

    private LinkedList<double[]> dataAccumulationQueue;
    private LinkedList<float[]> dataAccumulationQueueFiltered;
    private LinkedList<Double> markerDataAccumulationQueue;
    public float[][] dataBufferToSend;
    public float[][] dataBufferToSend_Filtered;
    public float[] markerDataBufferToSend;
    public AtomicBoolean[] networkingFrameLocks = new AtomicBoolean[4];
    public AtomicBoolean newTimeSeriesDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newTimeSeriesDataToSendFiltered = new AtomicBoolean(false);
    public AtomicBoolean newMarkerDataToSend = new AtomicBoolean(false);

    public HashMap<String, Object> cp5Map = new HashMap<String, Object>();

    private List<controlP5.Controller> cp5ElementsToCheck;

    W_Networking(PApplet _parent) {
        super(_parent);
        // ourApplet = _parent;

        networkActive = false;
        stream1 = null;
        stream2 = null;
        stream3 = null;
        stream4 = null;

        networkingFrameLocks[0] = new AtomicBoolean(false);
        networkingFrameLocks[1] = new AtomicBoolean(false);
        networkingFrameLocks[2] = new AtomicBoolean(false);
        networkingFrameLocks[3] = new AtomicBoolean(false);

        // default data types for streams 1-4 in Networking widget
        settings.nwDataType1 = 0;
        settings.nwDataType2 = 0;
        settings.nwDataType3 = 0;
        settings.nwDataType4 = 0;
        settings.nwSerialPort = "None";
        settings.nwProtocolSave = protocolIndex;
                                                 
        // Only show pulse data type when using Cyton in Live
        if (eegDataSource != DATASOURCE_CYTON) {
            dataTypes.remove("Pulse");
        }
        
        protocolMode = "UDP"; // Set Default to UDP
        protocolIndex = 0; // Set Default to UDP
        addDropdown("Protocol", "Protocol", protocols, protocolIndex);
        serialNetworkingComPorts = new ArrayList<String>(getComPorts());
        defaultBaud = "57600";
        verbosePrint("serialNetworkingComPorts = " + serialNetworkingComPorts);
        comPortToSave = 0;

        initialize_UI();

        putCP5DataIntoMap();

        dataBufferToSend = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
        dataAccumulationQueue = new LinkedList<double[]>();
        dataBufferToSend_Filtered = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
        dataAccumulationQueueFiltered = new LinkedList<float[]>();
        markerDataBufferToSend = new float[nPointsPerUpdate];
        markerDataAccumulationQueue = new LinkedList<Double>();

        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.add((controlP5.Controller) guideButton);
        cp5ElementsToCheck.add((controlP5.Controller) dataOutputsButton);
        cp5ElementsToCheck.add((controlP5.Controller) cp5_networking_dropdowns.get(ScrollableList.class, "dataType1"));
        cp5ElementsToCheck.add((controlP5.Controller) cp5_networking_baudRate.get(ScrollableList.class, "baud_rate"));
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

    // Used to update the Hashmap
    public void putCP5DataIntoMap() {
        for (int i = 0; i < dataTypeNames.size(); i++) {
            //datatypes
            cp5Map.put(dataTypeNames.get(i), int(cp5_networking_dropdowns.get(ScrollableList.class, dataTypeNames.get(i)).getValue()));
        }
        //osc textfields
        copyCP5TextToMap(oscTextFieldNames, cp5Map);
        //udp textfields
        copyCP5TextToMap(udpTextFieldNames, cp5Map);
        //lsl textfields
        copyCP5TextToMap(lslTextFieldNames, cp5Map);
        //Serial baud rate and port name
        cp5Map.put("baud_rate", int(cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").getValue()));
        String s = cp5_networking_portName.get(ScrollableList.class, "port_name").getItem(comPortToSave).get("name").toString();
        cp5Map.put("port_name", s);
        //println(cp5Map);
    }

    private void copyCP5TextToMap(String[] keys, HashMap m) {
        for (int i = 0; i < keys.length; i++) {
            m.put(keys[i], cp5_networking.get(Textfield.class, keys[i]).getText());
        }
    }

    public Map getCP5Map() {
        return cp5Map;
    }

    public void update() {
        super.update();
        if (protocolMode.equals("LSL")) {
            if (stream1 != null) {
                stream1.run();
            }
            if (stream2 != null) {
                stream2.run();
            }
            if (stream3 != null) {
                stream3.run();
            }
        }

        checkTopNavEvents();

        // ignore top left button interaction when widgetSelector dropdown is active
        List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.add((controlP5.Controller) guideButton);
        cp5ElementsToCheck.add((controlP5.Controller) dataOutputsButton);
        // lock left button interaction and certain dropdowns when widgetSelector
        // dropdown is active
        lockElementsOnOverlapCheck(cp5ElementsToCheck);
        checkOverlappingSerialDropdown();

        if (protocolMode.equals("OSC")) {
            cp5ElementsAreActive = textfieldsAreActive(oscTextFieldNames);
            for (int i = 0; i < oscTextFieldNames.length; i++) {
                copyPaste.checkForCopyPaste(cp5_networking.get(Textfield.class, oscTextFieldNames[i]));
            }
        } else if (protocolMode.equals("UDP")) {
            cp5ElementsAreActive = textfieldsAreActive(udpTextFieldNames);
            for (int i = 0; i < udpTextFieldNames.length; i++) {
                copyPaste.checkForCopyPaste(cp5_networking.get(Textfield.class, udpTextFieldNames[i]));
            }
        } else if (protocolMode.equals("LSL")) {
            cp5ElementsAreActive = textfieldsAreActive(lslTextFieldNames);
            for (int i = 0; i < lslTextFieldNames.length; i++) {
                copyPaste.checkForCopyPaste(cp5_networking.get(Textfield.class, lslTextFieldNames[i]));
            }
        } else {
            // For serial mode, disable fft output by switching to bandpower instead
            this.disableCertainOutputs((int) getCP5Map().get(dataTypeNames.get(0)));
        }

        if (cp5ElementsAreActive != previousCP5State) {
            if (!cp5ElementsAreActive) {
                // Cp5 textfield elements state change from 1 to 0, so save cp5 data
                putCP5DataIntoMap();
            }
            previousCP5State = cp5ElementsAreActive;
        }

        if (currentBoard.isStreaming()) {
            accumulateNewData();
            checkIfEnoughDataToSend();
        }

        // Check if any textfields are active and also for copy/paste if active
        updateNetworkingTextfields();
    }

    public void accumulateNewData() {
        // accumulate data
        double[][] newData = currentBoard.getFrameData();
        int[] exgChannels = currentBoard.getEXGChannels();
        int markerChannel = currentBoard.getMarkerChannel();

        if (newData[exgChannels[0]].length == 0) {
            return;
        }

        int start = dataProcessingFilteredBuffer[0].length - newData[exgChannels[0]].length;

        for (int iSample = 0; iSample < newData[exgChannels[0]].length; iSample++) {

            double[] sample = new double[exgChannels.length];
            float[] sample_filtered = new float[exgChannels.length];

            for (int iChan = 0; iChan < exgChannels.length; iChan++) {
                sample[iChan] = newData[exgChannels[iChan]][iSample];
                sample_filtered[iChan] = dataProcessingFilteredBuffer[iChan][start + iSample];
                // println("CHAN== "+iChan+" || SAMPLE== "+iSample+" DATA=="+sample[iChan]);
            }
            dataAccumulationQueue.add(sample);
            dataAccumulationQueueFiltered.add(sample_filtered);
            markerDataAccumulationQueue.add(newData[markerChannel][iSample]);
        }
    }

    public void checkIfEnoughDataToSend() {
        newTimeSeriesDataToSend.set(dataAccumulationQueue.size() >= nPointsPerUpdate);

        if (newTimeSeriesDataToSend.get()) {
            for (int iSample = 0; iSample < nPointsPerUpdate; iSample++) {
                double[] sample = dataAccumulationQueue.pop();

                for (int iChan = 0; iChan < sample.length; iChan++) {
                    dataBufferToSend[iChan][iSample] = (float) sample[iChan];
                }
            }
        }

        newTimeSeriesDataToSendFiltered.set(dataAccumulationQueueFiltered.size() >= nPointsPerUpdate);

        if (newTimeSeriesDataToSendFiltered.get()) {
            for (int iSample = 0; iSample < nPointsPerUpdate; iSample++) {
                float[] sample = dataAccumulationQueueFiltered.pop();

                for (int iChan = 0; iChan < sample.length; iChan++) {
                    dataBufferToSend_Filtered[iChan][iSample] = sample[iChan];
                }
            }
        }

        newMarkerDataToSend.set(markerDataAccumulationQueue.size() >= nPointsPerUpdate);
        if (newMarkerDataToSend.get()) {
            for (int iSample = 0; iSample < nPointsPerUpdate; iSample++) {
                markerDataBufferToSend[iSample] = markerDataAccumulationQueue.pop().floatValue();
            }
        }
    }

    private Boolean textfieldsAreActive(String[] names) {
        boolean isActive = false;
        for (String name : names) {
            if (cp5_networking.get(Textfield.class, name).isFocus()) {
                isActive = true;
            }
        }
        return isActive;
    }

    public void draw() {
        super.draw();
        pushStyle();

        showCP5();

        cp5_networking.draw();

        if (protocolMode.equals("Serial")) {
            cp5_networking_portName.draw();
            cp5_networking_baudRate.draw();
        }

        // Draw background boxes behind data type dropdowns
        for (int i = 0; i < dataTypeNames.size(); i++) {
            if (cp5_networking_dropdowns.get(ScrollableList.class, dataTypeNames.get(i)).isVisible()
                    && cp5_networking_dropdowns.get(ScrollableList.class, dataTypeNames.get(i)).isOpen()) {
                float[] pos = cp5_networking_dropdowns.get(ScrollableList.class, dataTypeNames.get(i)).getPosition();
                int width = itemWidth + 2;
                int height = cp5_networking_dropdowns.get(ScrollableList.class, dataTypeNames.get(i)).getHeight();
                fill(0, 0, 0);
                rect(pos[0] - 1, pos[1] - 1, width, height);
            }
        }

        cp5_networking_dropdowns.draw();

        int headerFontSize = 18;
        fill(OPENBCI_DARKBLUE);
        textFont(h1, headerFontSize);

        if (!protocolMode.equals("Serial")) {
            text(" Stream 1", column1, row0);
            text(" Stream 2", column2, row0);
            text(" Stream 3", column3, row0);
        }
        if (protocolMode.equals("OSC")) {
            text(" Stream 4", column4, row0);
        }
        text("Data Type", column0, row1);

        if (protocolMode.equals("OSC")) {
            textFont(f4, 40);
            text("OSC", x + 20, y + h / 8 + 15);
            textFont(h1, headerFontSize);
            text("IP", column0, row2);
            text("Port", column0, row3);
        } else if (protocolMode.equals("UDP")) {
            textFont(f4, 40);
            text("UDP", x + 20, y + h / 8 + 15);
            textFont(h1, headerFontSize);
            text("IP", column0, row2);
            text("Port", column0, row3);
        } else if (protocolMode.equals("LSL")) {
            textFont(f4, 40);
            text("LSL", x + 20, y + h / 8 + 15);
            textFont(h1, headerFontSize);
            text("Name", column0, row2);
            text("Type", column0, row3);
        } else if (protocolMode.equals("Serial")) {
            textFont(f4, 40);
            text("Serial", x + 20, y + h / 8 + 15);
            textFont(h1, headerFontSize);
            text("Baud/Port", column0, row2);
            // text("Port Name", column0,row3);
        }
        popStyle();

    }

    private void initialize_UI() {
        cp5_networking = new ControlP5(pApplet);
        cp5_networking_dropdowns = new ControlP5(pApplet);
        cp5_networking_baudRate = new ControlP5(pApplet);
        cp5_networking_portName = new ControlP5(pApplet);

        cp5_networking.setAutoDraw(false);
        cp5_networking_dropdowns.setAutoDraw(false);
        cp5_networking_portName.setAutoDraw(false);
        cp5_networking_baudRate.setAutoDraw(false);

        createTextFields(oscTextFieldNames, oscTextDefaultVals);
        createTextFields(udpTextFieldNames, udpTextDefaultVals);
        createTextFields(lslTextFieldNames, lslTextDefaultVals);

        // Serial
        boolean noComPortsFound = serialNetworkingComPorts.size() == 0 ? true : false;
        createPortDropdown("port_name", serialNetworkingComPorts, noComPortsFound);
        createBaudDropdown("baud_rate", baudRates);

        for (int i = 0; i < dataTypeNames.size(); i++) {
            createDropdown(dataTypeNames.get(i), dataTypes);
        }

        createStartButton();
        createGuideButton();
        createDataOutputsButton();
    }

    // Shows and Hides appropriate CP5 elements within widget
    public void showCP5() {

        osc_visible = false;
        udp_visible = false;
        lsl_visible = false;
        serial_visible = false;

        if (protocolMode.equals("OSC")) {
            osc_visible = true;
        } else if (protocolMode.equals("UDP")) {
            udp_visible = true;
        } else if (protocolMode.equals("LSL")) {
            lsl_visible = true;
        } else if (protocolMode.equals("Serial")) {
            serial_visible = true;
        }

        setTextFieldVisible(oscTextFieldNames, osc_visible);
        setTextFieldVisible(udpTextFieldNames, udp_visible);
        setTextFieldVisible(lslTextFieldNames, lsl_visible);

        cp5_networking_portName.get(ScrollableList.class, "port_name").setVisible(serial_visible);
        cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").setVisible(serial_visible);

        cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setVisible(true);
        if (!serial_visible) {
            cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setVisible(true);
            cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setVisible(true);
        } else {
            cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setVisible(false);
            cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setVisible(false);
        }

        // Draw a 4th Data Type dropdown menu if we are using OSC!
        if (protocolMode.equals("OSC")) {
            cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").setVisible(true);
        } else {
            cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").setVisible(false);
        }
    }

    private void setTextFieldVisible(String[] textFieldNames, boolean isVisible) {
        for (int i = 0; i < textFieldNames.length; i++) {
            cp5_networking.get(Textfield.class, textFieldNames[i]).setVisible(isVisible);
        }
    }

    // Lock text fields by setting _lock = true, unlock using false
    private void lockTextFields(String[] textFieldNames, boolean _lock) {
        for (int i = 0; i < textFieldNames.length; i++) {
            if (_lock) {
                cp5_networking.get(Textfield.class, textFieldNames[i]).lock();
            } else {
                cp5_networking.get(Textfield.class, textFieldNames[i]).unlock();
            }
        }
    }

    private void createTextFields(String[] textFieldNames, String[] defaultValues) {
        for (int i = 0; i < textFieldNames.length; i++) {
            createTextField(textFieldNames[i], defaultValues[i]);
        }
    }

    /* Create textfields for network parameters */
    private void createTextField(String name, String default_text) {
        cp5_networking.addTextfield(name).align(10, 100, 10, 100) // Alignment
                .setSize(120, 20) // Size of textfield
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
                .setAutoClear(true) // Autoclear
        ;
    }

    private void createStartButton() {
        startButton = createButton(cp5_networking, "startStopNetworkStream", "Start " + protocolMode + " Stream",
                x + w / 2 - 70, y + h - 40, 200, 20, 0, p4, 14, TURN_ON_GREEN, OPENBCI_DARKBLUE, BUTTON_HOVER,
                BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        startButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!networkActive) {
                    try {
                        startButton.setColorBackground(TURN_OFF_RED);
                        startButton.getCaptionLabel().setText("Stop " + protocolMode + " Stream");
                        initializeStreams(); // Establish stream
                        startNetwork(); // Begin streaming
                        output("Network Stream Started");
                    } catch (Exception e) {
                        e.printStackTrace();
                        String exception = e.toString();
                        String[] nwError = split(exception, ':');
                        outputError("Networking Error - Port: " + nwError[2]);
                        shutDown();
                        networkActive = false;
                        startButton.setColorBackground(TURN_ON_GREEN);
                        startButton.getCaptionLabel().setText("Start " + protocolMode + " Stream");
                        return;
                    }
                } else {
                    startButton.setColorBackground(TURN_ON_GREEN);
                    startButton.getCaptionLabel().setText("Start " + protocolMode + " Stream");
                    stopNetwork(); // Stop streams
                    output("Network Stream Stopped");
                }
            }
        });
        startButton.setDescription("Click here to Start and Stop the network stream for the chosen protocol.");
    }

    // Change appearance of networking start/stop button to Off
    private void turnOffButton() {
        startButton.setColorBackground(TURN_ON_GREEN);
        startButton.getCaptionLabel().setText("Start " + protocolMode + " Stream");
    }

    private void createGuideButton() {
        guideButton = createButton(cp5_networking, "networkingGuideButton", "Networking Guide", (int) (x0 + 1),
                (int) (y0 + navH + 1), 125, navH - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
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
        dataOutputsButton = createButton(cp5_networking, "dataOutputsButton", "Data Outputs",
                x0 + 1 + 3 + guideButton.getWidth(), y0 + navH + 1, 100, navH - 3, p5, 12, colorNotPressed,
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

    /* Creating DataType Dropdowns */
    private void createDropdown(String name, List<String> _items) {

        ScrollableList scrollList = cp5_networking_dropdowns.addScrollableList(name)
                .setOpen(false)
                .setOutlineColor(OPENBCI_DARKBLUE)
                .setColorBackground(OPENBCI_BLUE) // text field bg color
                .setColorValueLabel(color(255)) // text color
                .setColorCaptionLabel(color(255))
                .setColorForeground(color(125)) // border color when not selected
                .setColorActive(BUTTON_PRESSED) // border color when selected
                // .setColorCursor(color(26,26,26))
                .setSize(itemWidth, (_items.size() + 1) * (navH - 4))// + maxFreqList.size())
                .setBarHeight(navH - 4) // height of top/primary bar
                .setItemHeight(navH - 4) // height of all item/dropdown bars
                .addItems(_items) // used to be .addItems(maxFreqList)
                .setVisible(false);
        cp5_networking_dropdowns.getController(name)
                .getCaptionLabel() // the caption label is the text object in the primary bar
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText("None").setFont(h4).setSize(14)
                .getStyle().setPaddingTop(4); // need to grab style before affecting the paddingTop                           
        cp5_networking_dropdowns.getController(name)
                .getValueLabel() // the value label is connected to the text objects in the dropdown item bars
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText("None").setFont(h5).setSize(12) // set the font size of the item bars to 14pt
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(3) // 4-pixel vertical offset to center text
        ;
    }

    private void createBaudDropdown(String name, List<String> _items) {
        ScrollableList scrollList = cp5_networking_baudRate.addScrollableList(name).setOpen(false)
                .setOutlineColor(OPENBCI_DARKBLUE).setColorBackground(OPENBCI_BLUE) // text field bg color
                .setColorValueLabel(color(255)) // text color
                .setColorCaptionLabel(color(255))
                .setColorForeground(color(125)) // border color when not selected
                .setColorActive(BUTTON_PRESSED) // border color when selected
                // .setColorCursor(color(26,26,26))
                .setSize(itemWidth, (_items.size() + 1) * (navH - 4))// + maxFreqList.size())
                .setBarHeight(navH - 4) // height of top/primary bar
                .setItemHeight(navH - 4) // height of all item/dropdown bars
                .addItems(_items) // used to be .addItems(maxFreqList)
                .setVisible(false);
        cp5_networking_baudRate.getController(name)
                .getCaptionLabel() // the caption label is the text object in the primary bar
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText(defaultBaud).setFont(h4).setSize(14)
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(4);
        cp5_networking_baudRate.getController(name)
                .getValueLabel() // the value label is connected to the text objects in the dropdown item bars
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText("None").setFont(h5).setSize(12) // set the font size of the item bars to 14pt
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(3) // 4-pixel vertical offset to center text
        ;
    }

    private void createPortDropdown(String name, List<String> _items, boolean isEmpty) {
        if (isEmpty)
            _items.add("None"); // Fix #642 and #637
        ScrollableList scrollList = cp5_networking_portName.addScrollableList(name).setOpen(false)
                .setOutlineColor(OPENBCI_DARKBLUE)
                .setColorBackground(OPENBCI_BLUE) // text field bg color
                .setColorValueLabel(color(255)) // text color
                .setColorCaptionLabel(color(255))
                .setColorForeground(color(125)) // border color when not selected
                .setColorActive(BUTTON_PRESSED) // border color when selected
                // .setColorCursor(color(26,26,26))
                .setSize(itemWidth, (_items.size() + 1) * (navH - 4))// + maxFreqList.size())
                .setBarHeight(navH - 4) // height of top/primary bar
                .setItemHeight(navH - 4) // height of all item/dropdown bars
                .addItems(_items) // used to be .addItems(maxFreqList)
                .setVisible(false);
        cp5_networking_portName.getController(name)
                .getCaptionLabel() // the caption label is the text object in the primary bar
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText("None").setFont(h4).setSize(14)
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(4);
        cp5_networking_portName.getController(name)
                .getValueLabel() // the value label is connected to the text objects in the dropdown item bars
                .toUpperCase(false) // DO NOT AUTOSET TO UPPERCASE!!!
                .setText("None").setFont(h5).setSize(12) // set the font size of the item bars to 14pt
                .getStyle() // need to grab style before affecting the paddingTop
                .setPaddingTop(3) // 4-pixel vertical offset to center text
        ;
    }

    // loop through networking textfields and find out if any are active
    private void updateNetworkingTextfields() {
        List<Textfield> allTextfields = cp5_networking.getAll(Textfield.class);
        for (int i = 0; i < allTextfields.size(); i++) {
            textfieldUpdateHelper.checkTextfield(allTextfields.get(i));
        }
    }

    public void screenResized() {
        super.screenResized();

        //Very important to allow users to interact with objects after app resize
        cp5_networking.setGraphics(pApplet, 0,0);
        cp5_networking_dropdowns.setGraphics(pApplet, 0,0);
        cp5_networking_baudRate.setGraphics(pApplet, 0,0);
        cp5_networking_portName.setGraphics(pApplet, 0,0);

        //scale the item width of all elements in the networking widget
        itemWidth = int(map(width, 1024, 1920, 100, 120)) - 4;

        column0 = x+w/22-12;
        int widthd = 46;//This value has been fine-tuned to look proper in windowed mode 1024*768 and fullscreen on 1920x1080

        if (protocolMode.equals("UDP") || protocolMode.equals("LSL")) {
            widthd = 38;
            itemWidth = int(map(width, 1024, 1920, 120, 140)) - 4;
        }

        column1 = x+12*w/widthd-25;//This value has been fine-tuned to look proper in windowed mode 1024*768 and fullscreen on 1920x1080
        column2 = x+(12+9*1)*w/widthd-25;
        column3 = x+(12+9*2)*w/widthd-25;
        column4 = x+(12+9*3)*w/widthd-25;
        halfWidth = (column2+100) - column1;
        fullColumnWidth = (column4+100) - column1;
        row0 = y+h/4+10;
        row1 = y+4*h/10;
        row2 = y+5*h/10;
        row3 = y+6*h/10;
        row4 = y+7*h/10;
        row5 = y+8*h/10;
        int offset = 15;//This value has been fine-tuned to look proper in windowed mode 1024*768 and fullscreen on 1920x1080

        //reset the button positions using new x and y
        startButton.setPosition(x + w/2 - 70, y + h - 40 );
        guideButton.setPosition(x0 + 1, y0 + navH + 1);
        dataOutputsButton.setPosition(x0 + 1 + 2 + guideButton.getWidth() , y0 + navH + 1);

        //Responsively scale the data types dropdown height
        int dropdownsItemsToShow = min(floor((this.h0 * datatypeDropdownScaling) / (this.navH - 4)), dataTypes.size());
        int dropdownHeight = (dropdownsItemsToShow) * (this.navH - 4);
        int maxDropdownHeight = (dataTypes.size() + 1) * (this.navH - 4);
        if (dropdownHeight > maxDropdownHeight) dropdownHeight = maxDropdownHeight;

        for (String datatypeName : dataTypeNames) {
            cp5_networking_dropdowns.get(ScrollableList.class, datatypeName).setSize(itemWidth, dropdownHeight);
        }

        if (protocolMode.equals("OSC")) {
            for (String textField : oscTextFieldNames) {
                cp5_networking.get(Textfield.class, textField).setWidth(itemWidth);
            }
            cp5_networking.get(Textfield.class, "OSC_ip1").setPosition(column1, row2 - offset);
            cp5_networking.get(Textfield.class, "OSC_port1").setPosition(column1, row3 - offset);
            cp5_networking.get(Textfield.class, "OSC_ip2").setPosition(column2, row2 - offset);
            cp5_networking.get(Textfield.class, "OSC_port2").setPosition(column2, row3 - offset);
            cp5_networking.get(Textfield.class, "OSC_ip3").setPosition(column3, row2 - offset);
            cp5_networking.get(Textfield.class, "OSC_port3").setPosition(column3, row3 - offset);
            cp5_networking.get(Textfield.class, "OSC_ip4").setPosition(column4, row2 - offset);
            cp5_networking.get(Textfield.class, "OSC_port4").setPosition(column4, row3 - offset);
        } else if (protocolMode.equals("UDP")) {
            for (String textField : udpTextFieldNames) {
                cp5_networking.get(Textfield.class, textField).setWidth(itemWidth);
            }
            cp5_networking.get(Textfield.class, "UDP_ip1").setPosition(column1, row2 - offset);
            cp5_networking.get(Textfield.class, "UDP_port1").setPosition(column1, row3 - offset);
            cp5_networking.get(Textfield.class, "UDP_ip2").setPosition(column2, row2 - offset);
            cp5_networking.get(Textfield.class, "UDP_port2").setPosition(column2, row3 - offset);
            cp5_networking.get(Textfield.class, "UDP_ip3").setPosition(column3, row2 - offset);
            cp5_networking.get(Textfield.class, "UDP_port3").setPosition(column3, row3 - offset);
        } else if (protocolMode.equals("LSL")) {
            for (String textField : lslTextFieldNames) {
                cp5_networking.get(Textfield.class, textField).setWidth(itemWidth);
            }
            cp5_networking.get(Textfield.class, "LSL_name1").setPosition(column1,row2 - offset);
            cp5_networking.get(Textfield.class, "LSL_type1").setPosition(column1,row3 - offset);
            cp5_networking.get(Textfield.class, "LSL_name2").setPosition(column2,row2 - offset);
            cp5_networking.get(Textfield.class, "LSL_type2").setPosition(column2,row3 - offset);
            cp5_networking.get(Textfield.class, "LSL_name3").setPosition(column3,row2 - offset);
            cp5_networking.get(Textfield.class, "LSL_type3").setPosition(column3,row3 - offset);
        } else if (protocolMode.equals("Serial")) {
            //Serial Specific
            cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").setPosition(column1, row2-offset);
            cp5_networking_portName.get(ScrollableList.class, "port_name").setPosition(column2, row2-offset);
            cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").setSize(itemWidth, (baudRates.size()+1)*(navH-4));
            cp5_networking_portName.get(ScrollableList.class, "port_name").setSize(halfWidth, (5)*(navH-4));
        }

        cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setPosition(column1, row1-offset);
        cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setPosition(column2, row1-offset);
        cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setPosition(column3, row1-offset);
        cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").setPosition(column4, row1-offset);
    }

    private void hideAllTextFields(String[] textFieldNames) {
        for (int i = 0; i < textFieldNames.length; i++) {
            cp5_networking.get(Textfield.class, textFieldNames[i]).setVisible(false);
        }
    }

    /* Function call to hide all widget CP5 elements */
    private void hideElements() {
        String[] allTextFields = concat(oscTextFieldNames, udpTextFieldNames);
        allTextFields = concat(allTextFields, lslTextFieldNames);
        hideAllTextFields(allTextFields);

        cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setVisible(false);
        cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setVisible(false);
        cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setVisible(false);
        cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").setVisible(false);
        cp5_networking_portName.get(ScrollableList.class, "port_name").setVisible(false);
        cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").setVisible(false);
    }

    public boolean getNetworkActive() {
        return networkActive;
    }

    /*
     * Call to shutdown some UI stuff. Called from W_manager, maybe do this
     * differently..
     */
    public void shutDown() {
        hideElements();
    }

    private void initializeStreams() {
        String ip;
        int port;
        String name;
        int numLslDataPoints;
        int baudRate;
        String type;
        int streamNumber;

        String dt1 = dataTypes.get((int) cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue());
        String dt2 = dataTypes.get((int) cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue());
        String dt3 = dataTypes.get((int) cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue());
        String dt4 = dataTypes.get((int) cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").getValue());
        networkActive = true;

        // Establish OSC Streams
        if (protocolMode.equals("OSC")) {
            final String baseAddress = "/openbci";
            if (!dt1.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip1").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port1").getText());
                streamNumber = 0;
                stream1 = new Stream(dt1, ip, port, baseAddress, streamNumber);
            } else {
                stream1 = null;
            }
            if (!dt2.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip2").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port2").getText());
                streamNumber = 1;
                stream2 = new Stream(dt2, ip, port, baseAddress, streamNumber);
            } else {
                stream2 = null;
            }
            if (!dt3.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip3").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port3").getText());
                streamNumber = 2;
                stream3 = new Stream(dt3, ip, port, baseAddress, streamNumber);
            } else {
                stream3 = null;
            }
            if (!dt4.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip4").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port4").getText());
                streamNumber = 3;
                stream4 = new Stream(dt4, ip, port, baseAddress, streamNumber);
            } else {
                stream4 = null;
            }

            // Establish UDP Streams
        } else if (protocolMode.equals("UDP")) {
            if (!dt1.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "UDP_ip1").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "UDP_port1").getText());
                streamNumber = 0;
                stream1 = new Stream(dt1, ip, port, streamNumber);
            } else {
                stream1 = null;
            }
            if (!dt2.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "UDP_ip2").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "UDP_port2").getText());
                streamNumber = 1;
                stream2 = new Stream(dt2, ip, port, streamNumber);
            } else {
                stream2 = null;
            }
            if (!dt3.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "UDP_ip3").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "UDP_port3").getText());
                streamNumber = 2;
                stream3 = new Stream(dt3, ip, port, streamNumber);
            } else {
                stream3 = null;
            }

            // Establish LSL Streams
        } else if (protocolMode.equals("LSL")) {
            if (!dt1.equals("None")) {
                name = cp5_networking.get(Textfield.class, "LSL_name1").getText();
                type = cp5_networking.get(Textfield.class, "LSL_type1").getText();
                numLslDataPoints = getDataTypeNumChanLSL(dt1);
                streamNumber = 0;
                stream1 = new Stream(dt1, name, type, numLslDataPoints, streamNumber);
            } else {
                stream1 = null;
            }
            if (!dt2.equals("None")) {
                name = cp5_networking.get(Textfield.class, "LSL_name2").getText();
                type = cp5_networking.get(Textfield.class, "LSL_type2").getText();
                numLslDataPoints = getDataTypeNumChanLSL(dt2);
                streamNumber = 1;
                stream2 = new Stream(dt2, name, type, numLslDataPoints, streamNumber);
            } else {
                stream2 = null;
            }
            if (!dt3.equals("None")) {
                name = cp5_networking.get(Textfield.class, "LSL_name3").getText();
                type = cp5_networking.get(Textfield.class, "LSL_type3").getText();
                numLslDataPoints = getDataTypeNumChanLSL(dt3);
                streamNumber = 2;
                stream3 = new Stream(dt3, name, type, numLslDataPoints, streamNumber);
            } else {
                stream3 = null;
            }
        } else if (protocolMode.equals("Serial")) {
            if (!dt1.equals("None")) {
                name = serialNetworkingComPorts
                        .get((int) (cp5_networking_portName.get(ScrollableList.class, "port_name").getValue()));
                println("ComPort: " + name);
                println("Baudrate: " + Integer.parseInt(baudRates
                        .get((int) (cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").getValue()))));
                baudRate = Integer.parseInt(baudRates
                        .get((int) (cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").getValue())));
                stream1 = new Stream(dt1, name, baudRate, pApplet);
            } else {
                stream1 = null;
            }
        }
    }

    /* Start networking */
    public void startNetwork() {
        if (stream1 != null) {
            stream1.start();
        }
        if (stream2 != null) {
            stream2.start();
        }
        if (stream3 != null) {
            stream3.start();
        }
        if (stream4 != null) {
            stream4.start();
        }
    }

    /* Stop networking */
    public void stopNetwork() {
        networkActive = false;

        if (stream1 != null) {
            stream1.quit();
            stream1 = null;
        }
        if (stream2 != null) {
            stream2.quit();
            stream2 = null;
        }
        if (stream3 != null) {
            stream3.quit();
            stream3 = null;
        }
        if (stream4 != null) {
            stream4.quit();
            stream4 = null;
        }
    }

    // Fix #644 - Remove confusing #Chan textfield from Networking Widget and
    // account for this here
    private int getDataTypeNumChanLSL(String dataType) {
        if (dataType.equals("TimeSeriesFilt") || dataType.equals("TimeSeriesRaw")) {
            return currentBoard.getNumEXGChannels();
        } else if (dataType.equals("Focus")) {
            return 1;
        } else if (dataType.equals("FFT")) {
            return 125;
        } else if (dataType.equals("EMG")) {
            return currentBoard.getNumEXGChannels();
        } else if (dataType.equals("AvgBandPower")) {
            return 5;
        } else if (dataType.equals("BandPower")) {
            return 5;
        } else if (dataType.equals("Pulse")) {
            return 3;
        } else if (dataType.equals("Accel/Aux")) {
            if (currentBoard instanceof AccelerometerCapableBoard) {
                AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                if (accelBoard.isAccelerometerActive()) {
                    return accelBoard.getAccelerometerChannels().length;
                }
            }
            if (currentBoard instanceof AnalogCapableBoard) {
                AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                if (analogBoard.isAnalogActive()) {
                    return analogBoard.getAnalogChannels().length;
                }
            }
            if (currentBoard instanceof DigitalCapableBoard) {
                DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                if (digitalBoard.isDigitalActive()) {
                    return digitalBoard.getDigitalChannels().length;
                }
            }
        } else if (dataType.equals("EMGJoystick")) {
            return 2;
        } else if (dataType.equals("Marker")) {
            return 1;
        }
        throw new IllegalArgumentException("IllegalArgumentException: Error detecting number of channels for LSL stream data... please fix!");
    }

    private void checkOverlappingSerialDropdown() {
        // When using serial mode, lock baud rate dropdown when datatype dropdown is in
        // use
        if (protocolMode.equals("Serial")) {

            if (cp5_networking_dropdowns.get(ScrollableList.class, dataTypeNames.get(0)).isOpen()) {
                cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").lock();
            } else {
                if (cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").isLock()) {
                    cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").unlock();
                }
            }
        }
    }

    private void checkTopNavEvents() {
        // Check if a change has occured in TopNav
        if ((topNav.configSelector.isVisible != configIsVisible)
                || (topNav.layoutSelector.isVisible != layoutIsVisible)) {
            // lock/unlock the controllers within networking widget when using TopNav
            // Objects
            if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").lock();
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").lock();
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").lock();
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").lock();
                cp5_networking_portName.getController("port_name").lock();
                lockTextFields(oscTextFieldNames, true);
                lockTextFields(udpTextFieldNames, true);
                lockTextFields(lslTextFieldNames, true);
                // println("##LOCKED NETWORKING CP5 CONTROLLERS##");
            } else {
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").unlock();
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").unlock();
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").unlock();
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").unlock();
                cp5_networking_portName.getController("port_name").unlock();
                lockTextFields(oscTextFieldNames, false);
                lockTextFields(udpTextFieldNames, false);
                lockTextFields(lslTextFieldNames, false);
            }
            configIsVisible = topNav.configSelector.isVisible;
            layoutIsVisible = topNav.layoutSelector.isVisible;
        }
    }

    public void setComPortToSave(int n) {
        comPortToSave = n;
    }

    public void disableCertainOutputs(int n) {
        // Disable serial fft ouput and display message, it's too much data for serial
        // coms
        if (w_networking.protocolMode.equals("Serial")) {
            if (n == dataTypes.indexOf("FFT")) {
                outputError("Please use Band Power instead of FFT for Serial Output. Changing data type...");
                println("Networking: Changing data type from FFT to BandPower. FFT data is too large to send over Serial communication.");
                cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText("BandPower");
                cp5_networking_dropdowns.get(ScrollableList.class, "dataType1")
                        .setValue(dataTypes.indexOf("BandPower"));
            }
            ;
        }
    }

    public void compareAndSetNetworkingFrameLocks() {
        for (int i = 0; i < networkingFrameLocks.length; i++) {
            networkingFrameLocks[i].compareAndSet(false, true);
        }
    }
}; // End of w_networking class

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

class Stream extends Thread {
    private String protocol;
    private int streamNumber;
    private String dataType;
    private String ip;
    private int port;
    private String baseOscAddress;
    private String streamType;
    private String streamName;
    private int numLslDataPoints;
    private int numExgChannels;
    private DecimalFormat threeDecimalPlaces;
    private DecimalFormat fourLeadingPlaces;

    public Boolean isStreaming;
    private int start;
    private float[] dataToSend;
    private double[][] previousFrameData;

    private int samplesSent = 0;
    private int sampleRateClock = 0;
    private int sampleRateClockInterval = 10000;

    // OSC Objects
    private OscP5 osc;
    private NetAddress oscNetAddress;
    private OscMessage msg;
    // UDP Objects
    private UDP udp;
    // LSL objects
    private LSL.StreamInfo info_data;
    private LSL.StreamOutlet outlet_data;

    // Serial objects %%%%%
    private processing.serial.Serial serial_networking;
    private String portName;
    private int baudRate;
    private String serialMessage = "";

    private PApplet pApplet;

    // OSC Stream
    Stream(String dataType, String ip, int port, String baseAddress, int _streamNumber) {
        this.protocol = "OSC";
        this.streamNumber = _streamNumber;
        this.dataType = dataType;
        this.ip = ip;
        this.port = port;
        this.baseOscAddress = baseAddress;
        this.isStreaming = false;
        updateNumChan();
        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating OSC Stream: " + e);
        }
    }

    // UDP Stream
    Stream(String dataType, String ip, int port, int _streamNumber) {
        this.protocol = "UDP";
        this.streamNumber = _streamNumber;
        this.dataType = dataType;
        this.ip = ip;
        this.port = port;
        this.isStreaming = false;
        updateNumChan();

        // Force decimal formatting for all Locales
        Locale currentLocale = Locale.getDefault();
        DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(currentLocale);
        otherSymbols.setDecimalSeparator('.');
        otherSymbols.setGroupingSeparator(',');
        threeDecimalPlaces = new DecimalFormat("0.000", otherSymbols);
        fourLeadingPlaces = new DecimalFormat("####", otherSymbols);

        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating UDP Stream: " + e);
        }
    }

    // LSL Stream
    Stream(String dataType, String streamName, String streamType, int numLslDataPoints, int _streamNumber) {
        this.protocol = "LSL";
        this.streamNumber = _streamNumber;
        this.dataType = dataType;
        this.streamName = streamName;
        this.streamType = streamType;
        this.numLslDataPoints = numLslDataPoints;
        this.isStreaming = false;
        updateNumChan();
        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating LSL Stream: " + e);
        }
    }

    // Serial Stream
    Stream(String dataType, String portName, int baudRate, PApplet _this) {
        this.protocol = "Serial";
        this.streamNumber = 0;
        this.dataType = dataType;
        this.portName = portName;
        this.baudRate = baudRate;
        this.isStreaming = false;
        this.pApplet = _this;
        updateNumChan();

        // Force decimal formatting for all Locales
        Locale currentLocale = Locale.getDefault();
        DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(currentLocale);
        otherSymbols.setDecimalSeparator('.');
        otherSymbols.setGroupingSeparator(',');
        threeDecimalPlaces = new DecimalFormat("0.000", otherSymbols);
        fourLeadingPlaces = new DecimalFormat("####", otherSymbols);

        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating Serial Stream: " + e);
        }
    }

    public void start() {
        this.isStreaming = true;
        if (!this.protocol.equals("LSL")) {
            super.start();
        } else {
            openNetwork();
        }
    }

    public void run() {
        if (!this.protocol.equals("LSL")) {
            openNetwork();
            while (this.isStreaming) {
                if (!currentBoard.isStreaming()) {
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException e) {
                        println(e.getMessage());
                    }
                } else {
                    if (checkForData()) {
                        sendData();
                    } else {
                        try {
                            Thread.sleep(1);
                        } catch (InterruptedException e) {
                            println(e.getMessage());
                        }
                    }
                }
            }
        } else if (this.protocol.equals("LSL")) {
            if (!currentBoard.isStreaming()) {
                try {
                    Thread.sleep(1);
                } catch (InterruptedException e) {
                    println(e.getMessage());
                }
            } else {
                // This method has been updated to reduce duplicate packets - RW 3/15/23
                if (checkForData()) {
                    sendData();
                }
            }
        }
    }

    private void updateNumChan() {
        numExgChannels = currentBoard.getNumEXGChannels();
        dataToSend = new float[numExgChannels * nPointsPerUpdate];
        // Bug #638: ArrayOutOfBoundsException was thrown if
        // nPointsPerUpdate was larger than 10, as start was
        // set to dataProcessingFilteredBuffer[0].length - 10.
        start = dataProcessingFilteredBuffer[0].length - nPointsPerUpdate;
    }

    // This method has been updated to reduce duplicate packets - RW 3/15/23
    private synchronized Boolean checkForData() {
        if (this.dataType.equals("TimeSeriesRaw")) {
            return w_networking.newTimeSeriesDataToSend.compareAndSet(true, false);
        }

        if (this.dataType.equals("TimeSeriesFilt")) {
            return w_networking.newTimeSeriesDataToSendFiltered.compareAndSet(true, false);
        }

        if (this.dataType.equals("Marker")) {
            return w_networking.newMarkerDataToSend.compareAndSet(true, false);
        }

        if (w_networking.networkingFrameLocks[this.streamNumber].compareAndSet(true, false)) {
            return true;
        } else {
            return false;
        }
    }

    private void sendData() {
        if (this.dataType.equals("TimeSeriesFilt") || this.dataType.equals("TimeSeriesRaw")) {
            sendTimeSeriesData();
        } else if (this.dataType.equals("Focus")) {
            sendFocusData();
        } else if (this.dataType.equals("FFT")) {
            sendFFTData();
        } else if (this.dataType.equals("EMG")) {
            sendEMGData();
        } else if (this.dataType.equals("AvgBandPower")) {
            sendNormalizedPowerBandData();
        } else if (this.dataType.equals("BandPower")) {
            sendPowerBandData();
        } else if (this.dataType.equals("Accel/Aux")) {
            if (currentBoard instanceof AccelerometerCapableBoard) {
                AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                if (accelBoard.isAccelerometerActive()) {
                    sendAccelerometerData();
                }
            }
            if (currentBoard instanceof AnalogCapableBoard) {
                AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                if (analogBoard.isAnalogActive()) {
                    sendAnalogReadData();
                }
            }
            if (currentBoard instanceof DigitalCapableBoard) {
                DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                if (digitalBoard.isDigitalActive()) {
                    sendDigitalReadData();
                }
            }
        } else if (this.dataType.equals("Pulse")) {
            sendPulseData();
        } else if (this.dataType.equals("EMGJoystick")) {
            sendEMGJoystickData();
        } else if (this.dataType.equals("Marker")) {
            sendMarkerData();
        }
    }

    private void sendTimeSeriesData() {

        float[][] newDataFromBuffer = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
        String udpDataTypeName = "timeSeriesRaw";
        String oscDataTypeName = "time-series-raw";

        if (this.dataType.equals("TimeSeriesRaw")) {
            // Unfiltered
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                newDataFromBuffer[i] = w_networking.dataBufferToSend[i];
            }
        } else {
            // Filtered
            udpDataTypeName = "timeSeriesFilt";
            oscDataTypeName = "time-series-filtered";
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                newDataFromBuffer[i] = w_networking.dataBufferToSend_Filtered[i];
            }
        }

        /*
        // This code is used to check the sample rate of the data stream
        if (sampleRateClock == 0) sampleRateClock = millis(); 
        samplesSent = samplesSent + nPointsPerUpdate;
        if (millis() > sampleRateClock + sampleRateClockInterval) { 
            float timeDelta = float(millis() - sampleRateClock) / 1000;
            float sampleRateCheck = samplesSent / timeDelta;
            println("\nNumber of samples collected = " + samplesSent);
            println("Time Interval (Desired) = " + (sampleRateClockInterval / 1000));
            println("Time Interval (Actual) = " + timeDelta);
            println("Sample Rate (Desired) = " + currentBoard.getSampleRate());
            println("Sample Rate (Actual) = " + sampleRateCheck);
            sampleRateClock = 0;
            samplesSent = 0;
        }
        */

        if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"");
            output.append(udpDataTypeName);
            output.append("\",\"data\":[");

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                output.append("[");
                for (int j = 0; j < newDataFromBuffer[i].length; j++) {
                    output.append(str(newDataFromBuffer[i][j]));
                    if (j != newDataFromBuffer[i].length - 1) {
                        output.append(",");
                    }
                }
                String channelArrayEnding = i != newDataFromBuffer.length - 1 ? "]," : "]";
                output.append(channelArrayEnding);
            }

            // End of entire packet
            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("OSC")) {

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/" + oscDataTypeName + "/ch" + i);
                for (int j = 0; j < newDataFromBuffer[i].length; j++) {
                    msg.add(newDataFromBuffer[i][j]);
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        } else if (this.protocol.equals("LSL")) {
            int numChannels = newDataFromBuffer.length;
            int numSamples = newDataFromBuffer[0].length;
            float[] _dataToSend = new float[numChannels * numSamples];
            for (int sample = 0; sample < numSamples; sample++) {
                for (int channel = 0; channel < numChannels; channel++) {
                    _dataToSend[channel + sample * numChannels] = newDataFromBuffer[channel][sample];
                }
            }
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(_dataToSend);

        } else if (this.protocol.equals("Serial")) {

            // Time Series over serial port should be disabled as there is no reasonable usage for this
            StringBuilder serialMessage = new StringBuilder();
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                serialMessage.append("[");
                for (int j = 0; j < newDataFromBuffer[i].length; j++) {
                    float chan_uV = newDataFromBuffer[i][j];
                    
                    serialMessage.append(threeDecimalPlaces.format(chan_uV));
                    if (i < numExgChannels - 1) {
                        // add a comma to serialMessage to separate chan values, as long as it isn't last value...
                        serialMessage.append(","); 
                    }
                }
                serialMessage.append("]"); // close the message w/ "]"
                try {
                    // Write message to serial
                    this.serial_networking.write(serialMessage.toString());
                    // println(serialMesage.toString());
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        }
    }

    // Send out 1 or 0 as an integer over all networking data types for "Focus" data
    private void sendFocusData() {
        final int IS_METRIC = w_focus.getMetricExceedsThreshold();
        if (this.protocol.equals("OSC")) {
            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/focus");
            msg.add(IS_METRIC);
            try {
                this.osc.send(msg, this.oscNetAddress);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("UDP")) {
            StringBuilder sb = new StringBuilder("{\"type\":\"focus\",\"data\":");
            sb.append(str(IS_METRIC));
            sb.append("}\r\n");
            try {
                this.udp.send(sb.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            float[] output = new float[] { (float) IS_METRIC };
            outlet_data.push_sample(output);
            // Serial
        } else if (this.protocol.equals("Serial")) {
            StringBuilder sb = new StringBuilder();
            sb.append(IS_METRIC);
            sb.append("\n");
            try {
                // println("SerialMessage: " + serialMessage);
                this.serial_networking.write(sb.toString());
            } catch (Exception e) {
                println("Networking Serial: Focus Error");
                println(e.getMessage());
            }
        }
    }

    private void sendFFTData() {
        // UNFILTERED & FILTERED ... influenced globally by the FFT filters dropdown
        // EEG/FFT readings above 125Hz don't typically travel through the skull
        // So for now, only send out 0-125Hz with 1 bin per Hz
        // Bin 10 == 10Hz frequency range
        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < 125; j++) {
                    msg.clearArguments();
                    msg.setAddrPattern(baseOscAddress + "/fft/ch" + i + "/bin" + j);
                    msg.add(fftBuff[i].getBand(j));
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"fft\",\"data\":[[";
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < 125; j++) {
                    outputter += str(fftBuff[i].getBand(j));
                    if (j != 125 - 1) {
                        outputter += ",";
                    }
                }
                if (i != numExgChannels - 1) {
                    outputter += "],[";
                } else {
                    outputter += "]]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            float[] _dataToSend = new float[numExgChannels * 125];
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < 125; j++) {
                    _dataToSend[j + 125 * i] = fftBuff[i].getBand(j);
                }
            }
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(_dataToSend);
        } else if (this.protocol.equals("Serial")) {
            ///////////////////////////////// THIS OUTPUT IS DISABLED
            // Send FFT Data over Serial ...
            /*
                * for (int i=0;i<numExgChannels;i++) { serialMessage = "[" + (i+1) + ","; //clear
                * message for (int j=0;j<125;j++) { float fft_band = fftBuff[i].getBand(j);
                * String fft_band_3dec = threeDecimalPlaces.format(fft_band); serialMessage +=
                * fft_band_3dec; if (j < 125-1) { serialMessage += ","; //add a comma to
                * serialMessage to separate chan values, as long as it isn't last value... } }
                * serialMessage += "]"; try { // println(serialMessage);
                * this.serial_networking.write(serialMessage); } catch (Exception e) {
                * println(e.getMessage()); } }
                */
        }
    }

    private void sendPowerBandData() {
        // UNFILTERED & FILTERED ... influenced globally by the FFT filters dropdown
        // just like the FFT data
        int numBandPower = 5; // DELTA, THETA, ALPHA, BETA, GAMMA

        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < numExgChannels; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/band-power/" + i);
                for (int j = 0; j < numBandPower; j++) {
                    msg.add(dataProcessing.avgPowerInBins[i][j]); // [CHAN][BAND]
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            // DELTA, THETA, ALPHA, BETA, GAMMA
            String outputter = "{\"type\":\"bandPower\",\"data\":[[";
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < numBandPower; j++) {
                    outputter += str(dataProcessing.avgPowerInBins[i][j]); // [CHAN][BAND]
                    if (j != numBandPower - 1) {
                        outputter += ",";
                    }
                }
                if (i != numExgChannels - 1) {
                    outputter += "],[";
                } else {
                    outputter += "]]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            // DELTA, THETA, ALPHA, BETA, GAMMA
            float[] avgPowerLSL = new float[numExgChannels * numBandPower];
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < numBandPower; j++) {
                    avgPowerLSL[j + numBandPower * i] = dataProcessing.avgPowerInBins[i][j];
                }
            }
            outlet_data.push_chunk(avgPowerLSL);
        } else if (this.protocol.equals("Serial")) {
            for (int i = 0; i < numExgChannels; i++) {
                serialMessage = "[" + (i + 1) + ","; // clear message
                for (int j = 0; j < numBandPower; j++) {
                    float power_band = dataProcessing.avgPowerInBins[i][j];
                    String power_band_3dec = threeDecimalPlaces.format(power_band);
                    serialMessage += power_band_3dec;
                    if (j < numBandPower - 1) {
                        serialMessage += ","; // add a comma to serialMessage to separate chan values, as long as it
                                                // isn't last value...
                    }
                }
                serialMessage += "]";
                try {
                    // println(serialMessage);
                    this.serial_networking.write(serialMessage);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        }
    }

    private void sendNormalizedPowerBandData() {
        // UNFILTERED & FILTERED ... influenced globally by the FFT filters dropdown ...
        // just like the FFT data
        // Band Power order: DELTA, THETA, ALPHA, BETA, GAMMA
        int numBandPower = 5; 

        if (this.protocol.equals("OSC")) {

            msg.clearArguments();
            for (int i = 0; i < numBandPower; i++) {
                msg.setAddrPattern(baseOscAddress + "/average-band-power/" + i);
                msg.add(w_bandPower.getNormalizedBPSelectedChannels()[i]); // [CHAN][BAND]
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
            
        } else if (this.protocol.equals("UDP")) {

            StringBuilder outputter = new StringBuilder("{\"type\":\"averageBandPower\",\"data\":[");
            for (int i = 0; i < numBandPower; i++) {
                outputter.append(str(w_bandPower.getNormalizedBPSelectedChannels()[i]));
                if (i != numBandPower - 1) {
                    outputter.append(",");
                } else {
                    outputter.append("]}\r\n");
                }
            }
            // println(outputter.toString());
            try {
                this.udp.send(outputter.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            float[] avgPowerLSL = w_bandPower.getNormalizedBPSelectedChannels();
            outlet_data.push_sample(avgPowerLSL);

        } else if (this.protocol.equals("Serial")) {

            serialMessage = "[";
            for (int i = 0; i < numBandPower; i++) {
                float power_band = w_bandPower.getNormalizedBPSelectedChannels()[i];
                String power_band_3dec = threeDecimalPlaces.format(power_band);
                serialMessage += power_band_3dec;
                if (i < numBandPower - 1) {
                    // add a comma to serialMessage to separate chan values, as long as it isn't last value...
                    serialMessage += ","; 
                }
            }
            serialMessage += "]";
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }

        }
    }

    private void sendEMGData() {
        EmgSettingsValues emgSettingsValues = dataProcessing.emgSettings.values;
        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < numExgChannels; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/emg/" + i);
                msg.add(emgSettingsValues.getOutputNormalized(i));
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"emg\",\"data\":[";
            for (int i = 0; i < numExgChannels; i++) {
                outputter += str(emgSettingsValues.getOutputNormalized(i));
                if (i != numExgChannels - 1) {
                    outputter += ",";
                } else {
                    outputter += "]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            for (int i = 0; i < numExgChannels; i++) {
                dataToSend[i] = emgSettingsValues.getOutputNormalized(i);
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            serialMessage = "";
            for (int i = 0; i < numExgChannels; i++) {
                float emg_normalized = emgSettingsValues.getOutputNormalized(i);
                String emg_normalized_3dec = threeDecimalPlaces.format(emg_normalized);
                serialMessage += emg_normalized_3dec;
                if (i != numExgChannels - 1) {
                    serialMessage += ",";
                } else {
                    serialMessage += "\n";
                }
            }
            try {
                println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendAccelerometerData() {
        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                msg.clearArguments();
                if (i == 0) {
                    msg.setAddrPattern(baseOscAddress + "/accelerometer/x");
                } else if (i == 1) {
                    msg.setAddrPattern(baseOscAddress + "/accelerometer/y");
                } else if (i == 2) {
                    msg.setAddrPattern(baseOscAddress + "/accelerometer/z");
                }
                msg.add(w_accelerometer.getLastAccelVal(i));
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"accelerometer\",\"data\":[";
            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                float accelData = w_accelerometer.getLastAccelVal(i);
                // Formatting in this way is resilient to internationalization
                String accelData_3dec = threeDecimalPlaces.format(accelData);
                outputter += accelData_3dec;
                if (i != NUM_ACCEL_DIMS - 1) {
                    outputter += ",";
                } else {
                    outputter += "]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                dataToSend[i] = w_accelerometer.getLastAccelVal(i);
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            // Data Format: +0.900,-0.042,+0.254\n
            // 7 chars per axis, including \n char for Z
            serialMessage = "";
            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                float accelData = w_accelerometer.getLastAccelVal(i);
                String accelData_3dec = threeDecimalPlaces.format(accelData);
                if (accelData >= 0)
                    serialMessage += "+";
                serialMessage += accelData_3dec;
                if (i != NUM_ACCEL_DIMS - 1) {
                    serialMessage += ",";
                } else {
                    serialMessage += "\n";
                }
            }
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendAnalogReadData() {
        // this function is only called if the board is analog capable
        int[] analogChannels = ((AnalogCapableBoard) currentBoard).getAnalogChannels();
        List<double[]> lastData = ((AnalogCapableBoard) currentBoard).getDataWithAnalog(1);
        double[] lastSample = lastData.get(0);

        final int NUM_ANALOG_READS = analogChannels.length;

        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/analog/" + i);
                msg.add((int) lastSample[analogChannels[i]]);
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"analog\",\"data\":[";
            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                int auxData = (int) lastSample[analogChannels[i]];
                String auxData_formatted = fourLeadingPlaces.format(auxData);
                outputter += auxData_formatted;
                if (i != NUM_ANALOG_READS - 1) {
                    outputter += ",";
                } else {
                    outputter += "]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                dataToSend[i] = (int) lastSample[analogChannels[i]];
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            // Data Format: 0001,0002,0003\n or 0001,0002\n depending if Wi-Fi Shield is used
            // 5 chars per pin, including \n char for Z
            serialMessage = "";
            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                int auxData = (int) lastSample[analogChannels[i]];
                String auxData_formatted = fourLeadingPlaces.format(auxData);
                serialMessage += auxData_formatted;
                if (i != NUM_ANALOG_READS - 1) {
                    serialMessage += ",";
                } else {
                    serialMessage += "\n";
                }
            }
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendDigitalReadData() {
        final int NUM_DIGITAL_READS = w_digitalRead.getNumDigitalReads();

        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/digital/" + i);
                msg.add(w_digitalRead.digitalReadDots[i].getDigitalReadVal());
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"digital\",\"data\":[";
            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                int auxData = w_digitalRead.digitalReadDots[i].getDigitalReadVal();
                String auxData_formatted = String.format("%d", auxData);
                outputter += auxData_formatted;
                if (i != NUM_DIGITAL_READS - 1) {
                    outputter += ",";
                } else {
                    outputter += "]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                dataToSend[i] = w_digitalRead.digitalReadDots[i].getDigitalReadVal();
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            // Data Format: 0,1,0,1,0\n or 0,1,0\n depending if WiFi Shield is used
            // 2 chars per pin, including \n char last pin
            serialMessage = "";
            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                int auxData = w_digitalRead.digitalReadDots[i].getDigitalReadVal();
                String auxData_formatted = String.format("%d", auxData);
                serialMessage += auxData_formatted;
                if (i != NUM_DIGITAL_READS - 1) {
                    serialMessage += ",";
                } else {
                    serialMessage += "\n";
                }
            }
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendPulseData() {
        // Get data from Board that
        int numDataPoints = 2;

        if (this.protocol.equals("OSC")) {

            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/pulse/bpm");
            msg.add(w_pulsesensor.getBPM());
            try {
                this.osc.send(msg, this.oscNetAddress);
            } catch (Exception e) {
                println(e.getMessage());
            }

            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/pulse/ibi");
            msg.add(w_pulsesensor.getIBI());
            try {
                this.osc.send(msg, this.oscNetAddress);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder("{\"type\":\"pulse\",\"data\":[");
            output.append(str(w_pulsesensor.getBPM()));
            output.append(",");
            output.append(str(w_pulsesensor.getIBI()));
            output.append("]}\r\n");
            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            float[] _dataToSend = new float[2];
            _dataToSend[0] = w_pulsesensor.getBPM();
            _dataToSend[1] = w_pulsesensor.getIBI();
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(_dataToSend);

        } else if (this.protocol.equals("Serial")) {

            serialMessage = ""; // clear message
            serialMessage += w_pulsesensor.getBPM() + ",";
            serialMessage += w_pulsesensor.getIBI();
            try {
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }

        }
    }// End sendPulseData

    private void sendEMGJoystickData() {

        final float[] emgJoystickXY = w_emgJoystick.getJoystickXY();

        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < emgJoystickXY.length; i++) {
                msg.clearArguments();
                if (i == 0) {
                    msg.setAddrPattern(baseOscAddress + "/emg-joystick/x");
                } else if (i == 1) {
                    msg.setAddrPattern(baseOscAddress + "/emg-joystick/y");
                }
                msg.add(emgJoystickXY[i]);
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            StringBuilder output = new StringBuilder("{\"type\":\"emgJoystick\",\"data\":[");
            for (int i = 0; i < emgJoystickXY.length; i++) {
                // Formatting in this way is resilient to internationalization
                String dataFormatted = threeDecimalPlaces.format(emgJoystickXY[i]);
                output.append(dataFormatted);
                if (i != emgJoystickXY.length - 1) {
                    output.append(",");
                } else {
                    output.append("]}\r\n");
                }
            }
            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            for (int i = 0; i < emgJoystickXY.length; i++) {
                dataToSend[i] = emgJoystickXY[i];
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            // Data Format: +0.900,-0.042\n
            // 7 chars per axis, including \n char
            StringBuilder output = new StringBuilder();
            for (int i = 0; i < emgJoystickXY.length; i++) {
                float data = emgJoystickXY[i];
                String dataFormatted = threeDecimalPlaces.format(data);
                if (data >= 0)
                    output.append("+");
                    output.append(dataFormatted);
                if (i != emgJoystickXY.length - 1) {
                    output.append(",");
                } else {
                    output.append("\n");
                }
            }
            try {
                // println(serialMessage);
                this.serial_networking.write(output.toString());
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendMarkerData() {

        float[] newDataFromBuffer = new float[nPointsPerUpdate];

        for (int i = 0; i < newDataFromBuffer.length; i++) {
            newDataFromBuffer[i] = w_networking.markerDataBufferToSend[i];
        }

        /*
        // Check sampling rate for every networking protocol for this data type
        if (sampleRateClock == 0) sampleRateClock = millis(); 
        samplesSent = samplesSent + nPointsPerUpdate;
        if (millis() > sampleRateClock + sampleRateClockInterval) { 
            float timeDelta = float(millis() - sampleRateClock) / 1000;
            float sampleRateCheck = samplesSent / timeDelta;
            println("\nNumber of samples collected = " + samplesSent);
            println("Time Interval (Desired) = " + (sampleRateClockInterval / 1000));
            println("Time Interval (Actual) = " + timeDelta);
            println("Sample Rate (Desired) = " + currentBoard.getSampleRate());
            println("Sample Rate (Actual) = " + sampleRateCheck);
            sampleRateClock = 0;
            samplesSent = 0;
        }
        */

        if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"");
            output.append("marker");
            output.append("\",\"data\":[");

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                output.append(str(newDataFromBuffer[i]));
                if (i != newDataFromBuffer.length - 1) {
                    output.append(",");
                }
            }

            // End of entire packet
            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("OSC")) {

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/marker");
                msg.add(newDataFromBuffer[i]);
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        } else if (this.protocol.equals("LSL")) {
            // In this case, the newDataFromBuffer array is already formatted in an acceptable way.
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(newDataFromBuffer);

        } else if (this.protocol.equals("Serial")) {

            // Time Series over serial port should be disabled as there is no reasonable usage for this
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                StringBuilder serialMessage = new StringBuilder();
                float markerValue = newDataFromBuffer[i];    
                serialMessage.append(threeDecimalPlaces.format(markerValue));
                serialMessage.append("\n");
                try {
                    // Write message to serial
                    this.serial_networking.write(serialMessage.toString());
                    //println(serialMessage.toString());
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        }
    }

    //// Add new stream function here (ex. sendWidgetData) in the same format as
    //// above

    public void quit() {
        this.isStreaming = false;
        closeNetwork();
        interrupt();
    }

    private void closeNetwork() {
        if (this.protocol.equals("OSC")) {
            try {
                this.osc.stop();
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("UDP")) {
            this.udp.close();
        } else if (this.protocol.equals("LSL")) {
            outlet_data.close();
        } else if (this.protocol.equals("Serial")) {
            // Close Serial Port %%%%%
            try {
                serial_networking.clear();
                serial_networking.stop();
                println("Successfully closed SERIAL/COM port " + this.portName);
            } catch (Exception e) {
                println("Failed to close SERIAL/COM port " + this.portName);
            }
        }
    }

    private void openNetwork() {
        println("Networking: " + getAttributes());
        if (this.protocol.equals("OSC")) {
            // Possibly enter a nice custom exception here
            // try {
            this.osc = new OscP5(this, this.port + 1000);
            this.oscNetAddress = new NetAddress(this.ip, this.port);
            this.msg = new OscMessage(this.baseOscAddress);
            // } catch (Exception e) {
            // }
        } else if (this.protocol.equals("UDP")) {
            this.udp = new UDP(this);
            this.udp.setBuffer(20000);
            this.udp.listen(false);
            this.udp.log(false);
            output("UDP successfully connected");
        } else if (this.protocol.equals("LSL")) {
            String stream_id = "openbcigui";
            info_data = new LSL.StreamInfo(this.streamName, this.streamType, this.numLslDataPoints,
                    currentBoard.getSampleRate(), LSL.ChannelFormat.float32, stream_id);
            outlet_data = new LSL.StreamOutlet(info_data);
        } else if (this.protocol.equals("Serial")) {
            // Open Serial Port! %%%%%
            try {
                serial_networking = new processing.serial.Serial(this.pApplet, this.portName, this.baudRate);
                serial_networking.clear();
                verbosePrint("Successfully opened SERIAL/COM: " + this.portName);
                output("Successfully opened SERIAL/COM (" + this.baudRate + "): " + this.portName);
            } catch (Exception e) {
                verbosePrint("W_Networking.pde: could not open SERIAL PORT: " + this.portName);
                println("Error: " + e);
            }
        }
    }

    // Used only to print attributes to the screen
    private StringList getAttributes() {
        StringList attributes = new StringList();
        if (this.protocol.equals("OSC")) {
            attributes.append(this.dataType);
            attributes.append(this.ip);
            attributes.append(str(this.port));
            attributes.append(this.baseOscAddress);
        } else if (this.protocol.equals("UDP")) {
            attributes.append(this.dataType);
            attributes.append(this.ip);
            attributes.append(str(this.port));
        } else if (this.protocol.equals("LSL")) {
            attributes.append(this.dataType);
            attributes.append(this.streamName);
            attributes.append(this.streamType);
            attributes.append(str(this.numLslDataPoints));
        } else if (this.protocol.equals("Serial")) {
            attributes.append(this.dataType);
            attributes.append(this.portName);
            attributes.append(str(this.baudRate));
        }
        return attributes;
    }

}

/* Dropdown Menu Callback Functions */
/**
 * @description Sets the selected protocol mode from the widget's dropdown menu
 * @param `n` {int} - Index of protocol item selected in menu
 */
public void Protocol(int protocolIndex) {
    settings.nwProtocolSave = protocolIndex;
    if (protocolIndex == 0) {
        w_networking.protocolMode = "UDP";
    } else if (protocolIndex == 1) {
        w_networking.protocolMode = "LSL";
    } else if (protocolIndex == 2) {
        w_networking.protocolMode = "OSC";
    } else if (protocolIndex == 3) {
        w_networking.protocolMode = "Serial";
        w_networking.disableCertainOutputs(
                (int) w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue());
    }
    println("Networking: Protocol mode set to " + w_networking.protocolMode + ". Stopping network");
    w_networking.screenResized();
    w_networking.showCP5();
    if (!w_networking.getNetworkActive()) {
        w_networking.turnOffButton();
    }
}

public void dataType1(int n) {
    w_networking.putCP5DataIntoMap();
}

public void dataType2(int n) {
    w_networking.putCP5DataIntoMap();
}

public void dataType3(int n) {
    w_networking.putCP5DataIntoMap();
}

public void dataType4(int n) {
    w_networking.putCP5DataIntoMap();
}

public void port_name(int n) {
    w_networking.setComPortToSave(n);
    w_networking.putCP5DataIntoMap();
}

public void baud_rate(int n) {
    w_networking.putCP5DataIntoMap();
}
