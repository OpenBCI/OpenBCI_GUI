
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//    W_Networking.pde (Networking Widget)                                   //
//                                                                           //            
//    This widget provides networking capabilities in the OpenBCI GUI.       //
//    The networking protocols can be used for outputting data               //
//    from the OpenBCI GUI to any program that can receive UDP, OSC,         //
//    or LSL input, such as Matlab, MaxMSP, Python, C/C++, etc.              //
//                                                                           //
//    The protocols included are: UDP, OSC, LSL, and Serial                  //
//                                                                           //
//                                                                           //
//    Created by: Gabriel Ibagon (github.com/gabrielibagon), January 2017    //
//    Refactored: Richard Waltman, June-August 2023                          //
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
    private NetworkStreamOut stream1;
    private NetworkStreamOut stream2;
    private NetworkStreamOut stream3;
    private NetworkStreamOut stream4;

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
    private LinkedList<double[]> accelDataAccumulationQueue;
    private LinkedList<double[]> digitalDataAccumulationQueue;
    private LinkedList<double[]> analogDataAccumulationQueue;
    public float[][] dataBufferToSend;
    public float[][] dataBufferToSend_Filtered;
    public float[] markerDataBufferToSend;
    public float[][] accelDataBufferToSend;
    public int[][] digitalDataBufferToSend;
    public float[][] analogDataBufferToSend;
    public AtomicBoolean[] networkingFrameLocks = new AtomicBoolean[4];
    public AtomicBoolean newTimeSeriesDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newTimeSeriesDataToSendFiltered = new AtomicBoolean(false);
    public AtomicBoolean newMarkerDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newAccelDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newDigitalDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newAnalogDataToSend = new AtomicBoolean(false);

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
        if (currentBoard instanceof AccelerometerCapableBoard) {
            AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard)currentBoard;
            accelDataBufferToSend = new float[accelBoard.getAccelerometerChannels().length][nPointsPerUpdate];
            accelDataAccumulationQueue = new LinkedList<double[]>();
        }
        if (currentBoard instanceof DigitalCapableBoard) {
            DigitalCapableBoard digitalBoard = (DigitalCapableBoard)currentBoard;
            digitalDataBufferToSend = new int[digitalBoard.getDigitalChannels().length][nPointsPerUpdate];
            digitalDataAccumulationQueue = new LinkedList<double[]>();
        }
        if (currentBoard instanceof AnalogCapableBoard) {
            AnalogCapableBoard analogBoard = (AnalogCapableBoard)currentBoard;
            analogDataBufferToSend = new float[analogBoard.getAnalogChannels().length][nPointsPerUpdate];
            analogDataAccumulationQueue = new LinkedList<double[]>();
        }

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

        // Check if any textfields are active and also for copy/paste if active
        updateNetworkingTextfields();
    }

    // Call this function in DataProcessing.pde to update the data buffers even if the widget is not visible
    public void updateNetworkingWidgetData() {
        if (!currentBoard.isStreaming()) {
            return;
        }

        accumulateNewData();
        checkIfEnoughDataToSend();
    }

    private void accumulateNewData() {
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

            if (currentBoard instanceof AccelerometerCapableBoard) {
                AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                int[] accelChannels = accelBoard.getAccelerometerChannels();
                double[] accelSample = new double[accelChannels.length];
                for (int iChan = 0; iChan < accelChannels.length; iChan++) {
                    accelSample[iChan] = newData[accelChannels[iChan]][iSample];
                }
                accelDataAccumulationQueue.add(accelSample);
            }

            if (currentBoard instanceof DigitalCapableBoard) {
                DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                if (digitalBoard.isDigitalActive()) {
                    int[] digitalChannels = digitalBoard.getDigitalChannels();
                    double[] digitalSample = new double[digitalChannels.length];
                    for (int iChan = 0; iChan < digitalChannels.length; iChan++) {
                        digitalSample[iChan] = newData[digitalChannels[iChan]][iSample];
                    }
                    digitalDataAccumulationQueue.add(digitalSample);
                }
            }

            if (currentBoard instanceof AnalogCapableBoard) {
                AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                if (analogBoard.isAnalogActive()) {
                    int[] analogChannels = analogBoard.getAnalogChannels();
                    double[] analogSample = new double[analogChannels.length];
                    for (int iChan = 0; iChan < analogChannels.length; iChan++) {
                        analogSample[iChan] = newData[analogChannels[iChan]][iSample];
                    }
                    analogDataAccumulationQueue.add(analogSample);
                }
            }
        }
    }

    private void checkIfEnoughDataToSend() {
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

        if (currentBoard instanceof AccelerometerCapableBoard) {
            newAccelDataToSend.set(accelDataAccumulationQueue.size() >= nPointsPerUpdate);
            if (newAccelDataToSend.get()) {
                for (int iSample = 0; iSample < nPointsPerUpdate; iSample++) {
                    double[] sample = accelDataAccumulationQueue.pop();

                    for (int iChan = 0; iChan < sample.length; iChan++) {
                        accelDataBufferToSend[iChan][iSample] = (float) sample[iChan];
                    }
                }
            }
        }

        if (currentBoard instanceof BoardCyton) {
            newDigitalDataToSend.set(digitalDataAccumulationQueue.size() >= nPointsPerUpdate);
            if (newDigitalDataToSend.get()) {
                for (int iSample = 0; iSample < nPointsPerUpdate; iSample++) {
                    double[] sample = digitalDataAccumulationQueue.pop();

                    for (int iChan = 0; iChan < sample.length; iChan++) {
                        digitalDataBufferToSend[iChan][iSample] = (int) sample[iChan];
                    }
                }
            }

            newAnalogDataToSend.set(analogDataAccumulationQueue.size() >= nPointsPerUpdate);
            if (newAnalogDataToSend.get()) {
                for (int iSample = 0; iSample < nPointsPerUpdate; iSample++) {
                    double[] sample = analogDataAccumulationQueue.pop();

                    for (int iChan = 0; iChan < sample.length; iChan++) {
                        analogDataBufferToSend[iChan][iSample] = (float) sample[iChan];
                    }
                }
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
                stream1 = new NetworkStreamOut(dt1, ip, port, baseAddress, streamNumber);
            } else {
                stream1 = null;
            }
            if (!dt2.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip2").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port2").getText());
                streamNumber = 1;
                stream2 = new NetworkStreamOut(dt2, ip, port, baseAddress, streamNumber);
            } else {
                stream2 = null;
            }
            if (!dt3.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip3").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port3").getText());
                streamNumber = 2;
                stream3 = new NetworkStreamOut(dt3, ip, port, baseAddress, streamNumber);
            } else {
                stream3 = null;
            }
            if (!dt4.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "OSC_ip4").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "OSC_port4").getText());
                streamNumber = 3;
                stream4 = new NetworkStreamOut(dt4, ip, port, baseAddress, streamNumber);
            } else {
                stream4 = null;
            }

            // Establish UDP Streams
        } else if (protocolMode.equals("UDP")) {
            if (!dt1.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "UDP_ip1").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "UDP_port1").getText());
                streamNumber = 0;
                stream1 = new NetworkStreamOut(dt1, ip, port, streamNumber);
            } else {
                stream1 = null;
            }
            if (!dt2.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "UDP_ip2").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "UDP_port2").getText());
                streamNumber = 1;
                stream2 = new NetworkStreamOut(dt2, ip, port, streamNumber);
            } else {
                stream2 = null;
            }
            if (!dt3.equals("None")) {
                ip = cp5_networking.get(Textfield.class, "UDP_ip3").getText();
                port = Integer.parseInt(cp5_networking.get(Textfield.class, "UDP_port3").getText());
                streamNumber = 2;
                stream3 = new NetworkStreamOut(dt3, ip, port, streamNumber);
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
                stream1 = new NetworkStreamOut(dt1, name, type, numLslDataPoints, streamNumber);
            } else {
                stream1 = null;
            }
            if (!dt2.equals("None")) {
                name = cp5_networking.get(Textfield.class, "LSL_name2").getText();
                type = cp5_networking.get(Textfield.class, "LSL_type2").getText();
                numLslDataPoints = getDataTypeNumChanLSL(dt2);
                streamNumber = 1;
                stream2 = new NetworkStreamOut(dt2, name, type, numLslDataPoints, streamNumber);
            } else {
                stream2 = null;
            }
            if (!dt3.equals("None")) {
                name = cp5_networking.get(Textfield.class, "LSL_name3").getText();
                type = cp5_networking.get(Textfield.class, "LSL_type3").getText();
                numLslDataPoints = getDataTypeNumChanLSL(dt3);
                streamNumber = 2;
                stream3 = new NetworkStreamOut(dt3, name, type, numLslDataPoints, streamNumber);
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
                stream1 = new NetworkStreamOut(dt1, name, baudRate, pApplet);
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
            //Send out band powers for each channel sequentially
            //Prepend channel number to each array
            return 5 + 1;
        } else if (dataType.equals("Pulse")) {
            return 2;
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
