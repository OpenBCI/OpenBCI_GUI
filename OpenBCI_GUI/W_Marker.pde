//////////////////////////////////////////////////////
//                                                  //
//                  W_Marker.pde                    //
//                                                  //
//    Created by: Richard Waltman, August 2023      //
//    Purpose: Add software markers to data         //
//    Marker Shortcuts: z x c v Z X C V             //
//                                                  //
//////////////////////////////////////////////////////

class W_Marker extends WidgetWithSettings {
    private ControlP5 localCP5;
    private List<controlP5.Controller> cp5ElementsToCheckForOverlap;

    private final int MARKER_BUTTON_WIDTH = 125;
    private final int MARKER_BUTTON_HEIGHT = 20;
    private final int MARKER_UI_GRID_CELL_HEIGHT = 30;
    private final int MAX_NUMBER_OF_MARKER_BUTTONS = 8;
    private final int MARKER_UI_GRID_EXTERIOR_PADDING = 10;
    private final int MARKER_UI_GRID_ROWS = 4;
    private final int MARKER_UI_GRID_COLUMNS = 4;
    private Button[] markerButtons = new Button[MAX_NUMBER_OF_MARKER_BUTTONS];
    private Grid grid;

    private Textfield markerReceiveIPTextfield;
    private Textfield markerReceivePortTextfield;
    private final String KEY_MARKER_RECEIVE_IP = "markerReceiveIPTextfield";
    private final String KEY_MARKER_RECEIVE_PORT = "markerReceivePortTextfield";
    private final String DEFAULT_RECEIVER_IP = "127.0.0.1";
    private final int DEFAULT_RECEIVER_PORT = 12340;
    private final int MARKER_RECEIVE_TEXTFIELD_WIDTH = 108;
    private final int MARKER_RECEIVE_TEXTFIELD_HEIGHT = 22;

    private Button markerReceiveToggle;
    private final String START_BUTTON_TEXT = "Start Receiver";
    private final String STOP_BUTTON_TEXT = "Stop Receiver";
    private final int START_STOP_BUTTON_WIDTH = 200;

    private hypermedia.net.UDP udpReceiver;

    private MarkerBar markerBar;
    private int graphX, graphY, graphW, graphH;
    private int PAD_FIVE = 5;
    private int GRAPH_PADDING = 30;

    W_Marker() {
        super();
        widgetTitle = "Marker";

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);

        createMarkerButtons();
        
        updateGraphDims();
        MarkerWindow markerWindow = widgetSettings.get(MarkerWindow.class);
        MarkerVertScale markerVertScale = widgetSettings.get(MarkerVertScale.class);
        markerBar = new MarkerBar(ourApplet, MAX_NUMBER_OF_MARKER_BUTTONS, markerWindow.getValue(), markerVertScale.getValue(), graphX, graphY, graphW, graphH);

        grid = new Grid(MARKER_UI_GRID_ROWS, MARKER_UI_GRID_COLUMNS, MARKER_UI_GRID_CELL_HEIGHT);
        grid.setDrawTableBorder(false);
        grid.setDrawTableInnerLines(false);
        grid.setTableFontAndSize(p4, 14);
        grid.setString("Receive IP", 2, 0);
        grid.setString("Receive Port", 2, 2);

        createMarkerReceiveUI();

        //Add all cp5 elements to a list so that they can be checked for overlap
        cp5ElementsToCheckForOverlap = new ArrayList<controlP5.Controller>();
        for (int i = 0; i < MAX_NUMBER_OF_MARKER_BUTTONS; i++) {
            cp5ElementsToCheckForOverlap.add(markerButtons[i]);
        }
        cp5ElementsToCheckForOverlap.add(markerReceiveIPTextfield);
        cp5ElementsToCheckForOverlap.add(markerReceivePortTextfield);
        cp5ElementsToCheckForOverlap.add(markerReceiveToggle);
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        widgetSettings.set(MarkerVertScale.class, MarkerVertScale.EIGHT)
                    .set(MarkerWindow.class, MarkerWindow.FIVE)
                    .setObject(KEY_MARKER_RECEIVE_IP, DEFAULT_RECEIVER_IP)
                    .setObject(KEY_MARKER_RECEIVE_PORT, DEFAULT_RECEIVER_PORT)
                    .saveDefaults();
        
        initDropdown(MarkerVertScale.class, "markerVerticalScaleDropdown", "Vert Scale");
        initDropdown(MarkerWindow.class, "markerWindowDropdown", "Window");
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(MarkerVertScale.class, "markerVerticalScaleDropdown");
        updateDropdownLabel(MarkerWindow.class, "markerWindowDropdown");

        applyVerticalScale();
        applyWindow();

        String ipValue = widgetSettings.getObject(KEY_MARKER_RECEIVE_IP, DEFAULT_RECEIVER_IP).toString();
        String portValue = widgetSettings.getObject(KEY_MARKER_RECEIVE_PORT, DEFAULT_RECEIVER_PORT).toString();

        markerReceiveIPTextfield.setText(ipValue);
        markerReceivePortTextfield.setText(portValue);
    }

    @Override
    protected void saveSettings() {
        // Call the parent method to handle default saving behavior
        super.saveSettings();
        
        // Save our marker-specific settings
        saveMarkerSettings();
    }

    private void saveMarkerSettings() {
        // Get the current values from textfields
        String currentIP = markerReceiveIPTextfield.getText();
        String currentPort = markerReceivePortTextfield.getText();
        
        // Clean up the values
        currentIP = getIpAddrFromStr(currentIP);
        Integer currentPortInt = Integer.parseInt(dropNonPrintableChars(currentPort));
        
        // Save values to widget settings
        widgetSettings.setObject(KEY_MARKER_RECEIVE_IP, currentIP);
        widgetSettings.setObject(KEY_MARKER_RECEIVE_PORT, currentPortInt);
    }

    public void update(){
        super.update();
        markerBar.update();

        textfieldUpdateHelper.checkTextfield(markerReceiveIPTextfield);
        textfieldUpdateHelper.checkTextfield(markerReceivePortTextfield);

        lockElementsOnOverlapCheck(cp5ElementsToCheckForOverlap);
    }

    public void draw(){
        super.draw();

        grid.draw();
        markerBar.draw();

        localCP5.draw();
    }

    public void screenResized(){
        super.screenResized();
      
        localCP5.setGraphics(ourApplet, 0, 0);

        resizeMarkerUIGrid();

        updateGraphDims();
        markerBar.screenResized(graphX, graphY, graphW, graphH);
    }

    private void updateGraphDims() {
        graphW = int(w - PAD_FIVE*4);
        graphH = int(h/2 - GRAPH_PADDING - PAD_FIVE*2);
        graphX = x + PAD_FIVE*2;
        graphY = y + h - graphH - int(GRAPH_PADDING) - PAD_FIVE*2;
    }

    private void resizeMarkerUIGrid() {
        int tableX = x + GRAPH_PADDING;
        int tableY = y + MARKER_UI_GRID_EXTERIOR_PADDING;
        int tableW = w - GRAPH_PADDING * 2;
        int tableH = y - graphY - GRAPH_PADDING * 2;
        grid.setDim(tableX, tableY, tableW);
        grid.setRowHeight(MARKER_UI_GRID_CELL_HEIGHT);
        grid.dynamicallySetTextVerticalPadding(2, 0);
        grid.setHorizontalCenterTextInCells(true);

        final int CELL_PADDING = 8;
        final int CELL_PADDING_TOTAL = CELL_PADDING * 2;
        final int HALF_CELL_PADDING = CELL_PADDING / 2;

        //Update positions of marker buttons
        for (int i = 0; i < MAX_NUMBER_OF_MARKER_BUTTONS; i++) {
            int row = i < MARKER_UI_GRID_COLUMNS ? 0 : 1;
            int column = i % (MARKER_UI_GRID_COLUMNS);
            RectDimensions cellDims = grid.getCellDims(row, column);
            markerButtons[i].setPosition(cellDims.x + CELL_PADDING, cellDims.y + HALF_CELL_PADDING);
            markerButtons[i].setSize(cellDims.w - CELL_PADDING_TOTAL, cellDims.h - CELL_PADDING);
        }

        RectDimensions ipTextfieldPosition = grid.getCellDims(2, 1);
        markerReceiveIPTextfield.setPosition(ipTextfieldPosition.x, ipTextfieldPosition.y + HALF_CELL_PADDING);

        RectDimensions portTextfieldPosition = grid.getCellDims(2, 3);
        markerReceivePortTextfield.setPosition(portTextfieldPosition.x, portTextfieldPosition.y + HALF_CELL_PADDING);

        RectDimensions markerToggleCellPosition = grid.getCellDims(3, 0);
        int markerReceiveToggleX = x + w / 2 - START_STOP_BUTTON_WIDTH / 2;
        markerReceiveToggle.setPosition(markerReceiveToggleX, markerToggleCellPosition.y + HALF_CELL_PADDING);
    }

    private void createMarkerButtons() {
        for (int i = 0; i < MAX_NUMBER_OF_MARKER_BUTTONS; i++) {
            //Marker number is i + 1 because marker numbers start at 1, not 0. Otherwise, will throw BrainFlow error.
            //This initial position is temporary and will be updated in resizeMarkerUIGrid()
            markerButtons[i] = createMarkerButton(i + 1, x + 10 + (i * MARKER_BUTTON_WIDTH), y + 10);
        }
    }

    private Button createMarkerButton(final int markerNumber, int _x, int _y) {
        Button newButton = createButton(localCP5, "markerButton" + markerNumber, "Insert " + markerNumber, _x, _y, MARKER_BUTTON_WIDTH, MARKER_BUTTON_HEIGHT, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        newButton.setBorderColor(OBJECT_BORDER_GREY);
        newButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                insertMarker(markerNumber);
            }
        });
        newButton.setDescription("Click to insert marker " + markerNumber + " into the data stream.");
        return newButton;
    }

    //Called in Interactivity.pde when a key is pressed
    //Returns true if a marker key was pressed, false otherwise
    //Can be used to check for marker key presses even when this widget is not active
    public boolean checkForMarkerKeyPress(char keyPress) {
        switch (keyPress) {
            case 'z':
                insertMarker(1);
                return true;
            case 'x':
                insertMarker(2);
                return true;
            case 'c':
                insertMarker(3);
                return true;
            case 'v':
                insertMarker(4);
                return true;
            case 'Z':
                insertMarker(5);
                return true;
            case 'X':
                insertMarker(6);
                return true;
            case 'C':
                insertMarker(7);
                return true;
            case 'V':
                insertMarker(8);
                return true;
            default:
                return false;
        }
    }

    private void createMarkerReceiveUI() {
        markerReceiveIPTextfield = createTextfield(KEY_MARKER_RECEIVE_IP, DEFAULT_RECEIVER_IP);
        markerReceivePortTextfield = createTextfield(KEY_MARKER_RECEIVE_PORT, Integer.toString(DEFAULT_RECEIVER_PORT));
        createMarkerReceiveToggle();
    }

    /* Create textfields for network parameters */
    private Textfield createTextfield(String name, String default_text) {
        final Textfield myTextfield = localCP5.addTextfield(name).align(10, 100, 10, 100) // Alignment
                .setSize(MARKER_RECEIVE_TEXTFIELD_WIDTH, MARKER_RECEIVE_TEXTFIELD_HEIGHT) // Size of textfield
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
                .setVisible(true) // Initially visible
                .setAutoClear(false) // Don't clear textfield when pressing Enter key
        ;
        //Clear textfield on double click
        myTextfield.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Marker Widget: Enter your Marker Receiver IP Address or Port");
                myTextfield.clear();
            }
        });
        //Autogenerate if user presses Enter key and textfield value is null
        myTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfield.getText().equals("")) {
                    resetMarkerReceiveTextfield(myTextfield);
                } else if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    saveMarkerSettings();
                }
            }
        });
        //Autogenerate name if user leaves textfield and value is null
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    resetMarkerReceiveTextfield(myTextfield);
                }
                saveMarkerSettings();
            }
        });
        return myTextfield;
    }

    private void resetMarkerReceiveTextfield(Textfield tf) {
        if (tf.getName().equals(KEY_MARKER_RECEIVE_IP)) {
            tf.setText(DEFAULT_RECEIVER_IP);
        } else if (tf.getName().equals(KEY_MARKER_RECEIVE_PORT)) {
            tf.setText(Integer.toString(DEFAULT_RECEIVER_PORT));
        }
    }

    private void createMarkerReceiveToggle() {
        markerReceiveToggle = createButton(localCP5, "markerReceiveToggle", START_BUTTON_TEXT, x + MARKER_UI_GRID_EXTERIOR_PADDING, y + MARKER_UI_GRID_EXTERIOR_PADDING, START_STOP_BUTTON_WIDTH, MARKER_RECEIVE_TEXTFIELD_HEIGHT, p5, 12, TURN_ON_GREEN, OPENBCI_DARKBLUE);
        markerReceiveToggle.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (udpReceiver == null) {
                    initUdpMarkerReceiver();
                    markerReceiveToggle.getCaptionLabel().setText(STOP_BUTTON_TEXT);
                    markerReceiveToggle.setColorBackground(TURN_OFF_RED);
                    return;
                }

                if (udpReceiver.isListening()) {
                    markerReceiveToggle.getCaptionLabel().setText(START_BUTTON_TEXT);
                    markerReceiveToggle.setColorBackground(TURN_ON_GREEN);
                    disposeUdpMarkerReceiver();
                } else {
                    markerReceiveToggle.getCaptionLabel().setText(STOP_BUTTON_TEXT);
                    markerReceiveToggle.setColorBackground(TURN_OFF_RED);
                    initUdpMarkerReceiver();
                }
            }
        });
    }

    private void initUdpMarkerReceiver() {
        String currentIP = getIpAddrFromStr(markerReceiveIPTextfield.getText());
        Integer currentPort = Integer.parseInt(dropNonPrintableChars(markerReceivePortTextfield.getText()));
        
        disposeUdpMarkerReceiver();
        
        udpReceiver = new UDP(ourApplet, currentPort, currentIP);
        udpReceiver.listen(true);
        udpReceiver.broadcast(false);
        udpReceiver.log(false);
        udpReceiver.setReceiveHandler("receiveMarkerViaUdp");
        outputSuccess("Marker Widget: Listening for markers on " + currentIP + ":" + currentPort);
    }

    public void disposeUdpMarkerReceiver() {
        if (udpReceiver != null) {
            udpReceiver.close();
            udpReceiver.dispose();
            println("Marker Widget: Stopped listening for markers");
        }
    }

    private void insertMarker(int markerNumber) {
        int markerChannel = ((DataSource)currentBoard).getMarkerChannel();

        if (currentBoard instanceof BoardBrainFlow) {
            if (markerChannel != -1) {
                ((Board)currentBoard).insertMarker(markerNumber);
            }
        }
    }

    public void insertMarkerFromExternal(double markerValue) {
        int markerChannel = ((DataSource)currentBoard).getMarkerChannel();

        if (currentBoard instanceof BoardBrainFlow) {
            if (markerChannel != -1) {
                ((Board)currentBoard).insertMarker(markerValue);
            }
        }
    }

    public void setMarkerWindow(int n) {
        widgetSettings.setByIndex(MarkerWindow.class, n);
        applyWindow();
    }

    public void setMarkerVerticalScale(int n) {
        widgetSettings.setByIndex(MarkerVertScale.class, n);
        applyVerticalScale();
    }

    private void applyWindow() {
        int markerWindowValue = widgetSettings.get(MarkerWindow.class).getValue();
        markerBar.adjustTimeAxis(markerWindowValue);
    }

    private void applyVerticalScale() {
        int markerVertScaleValue = widgetSettings.get(MarkerVertScale.class).getValue();
        markerBar.adjustYAxis(markerVertScaleValue);
    }
};


//The following global functions are used by the Marker widget dropdowns. This method is the least amount of code.
public void markerWindowDropdown(int n) {
    W_Marker markerWidget = (W_Marker) widgetManager.getWidget("W_Marker");
    markerWidget.setMarkerWindow(n);
}

public void markerVerticalScaleDropdown(int n) {
    W_Marker markerWidget = (W_Marker) widgetManager.getWidget("W_Marker");
    markerWidget.setMarkerVerticalScale(n);
}

//Custom UDP receive handler for receiving markers from external sources
public void receiveMarkerViaUdp( byte[] data, String ip, int port ) {
    double markerValue = convertByteArrayToDouble(data);
    //String message = Double.toString(markerValue);
    //println( "received: \""+message+"\" from "+ip+" on port "+port );
    W_Marker markerWidget = (W_Marker) widgetManager.getWidget("W_Marker");
    markerWidget.insertMarkerFromExternal(markerValue);
}

//This class contains the time series plot for displaying the markers over time
class MarkerBar {
    private int x, y, w, h;
    private int X_AXIS_PADDING = 22;
    private int Y_AXIS_PADDING = 30;

    private GPlot plot;
    private GPointsArray markerPointsArray;
    private final String PLOT_LAYER = "layer1";
    private final float AUTOSCALE_SPACING = .2f;
    private GPlotAutoscaler gplotAutoscaler;

    private int nPoints;
    private int numSeconds;
    private int yAxisMax;
    private float timeBetweenPoints;
    private float[] markerTimeArray;
    private int numSamplesToProcess;
    
    private DataSource markerBoard;

    private boolean isAutoscale = false;
    private float autoscaleMin;
    private float autoscaleMax;
    private int previousMillis = 0;

    MarkerBar(PApplet _parentApplet, int _yAxisMax, int markerWindow, float yLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
        
        yAxisMax = _yAxisMax;
        numSeconds = markerWindow;

        markerBoard = (DataSource)currentBoard;

        x = _x;
        y = _y;
        w = _w;
        h = _h;

        plot = new GPlot(_parentApplet);
        plot.setPos(x + 36 + 4, y); //match marker plot position with Time Series
        plot.setDim(w - 36 - 4, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor(WHITE);
        plot.setXLim(-numSeconds, 0); //set the horizontal scale
        plot.setYLim(-AUTOSCALE_SPACING, yLimit + AUTOSCALE_SPACING); //change this to adjust vertical scale
        //plot.setPointSize(2);
        plot.setPointColor(0);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getYAxis().setAxisLabelText("Marker (int)");
        plot.getYAxis().setNTicks(5);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().getAxisLabel().setOffset(float(X_AXIS_PADDING));
        plot.getYAxis().getAxisLabel().setOffset(float(Y_AXIS_PADDING));
        plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        gplotAutoscaler = new GPlotAutoscaler(false, AUTOSCALE_SPACING);

        initArrays();
        
        plot.addLayer(PLOT_LAYER, markerPointsArray);
        plot.getLayer(PLOT_LAYER).setLineColor(ACCEL_X_COLOR);

    }

    private void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        markerTimeArray = new float[nPoints];
        for (int i = 0; i < markerTimeArray.length; i++) {
            markerTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
        }

        float[] tempMarkerFloatArray = new float[nPoints];

        //make a GPoint array using float arrays x[] and y[] instead of plain index points
        markerPointsArray = new GPointsArray(markerTimeArray, tempMarkerFloatArray);
    }

    public void update() {
        updateGPlotPoints();
    }

    public void draw() {
        pushStyle();
        plot.beginDraw();
        plot.drawBox();
        plot.drawGridLines(GPlot.BOTH);
        plot.drawLines(); //Draw a Line graph!
        plot.drawYAxis();
        plot.drawXAxis();
        plot.endDraw();
        popStyle();
    }

    private int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    public void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-numSeconds,0);

        initArrays();

        //Set the number of axis divisions
        if (numSeconds > 1) {
            plot.getXAxis().setNTicks(numSeconds);
        } else {
            plot.getXAxis().setNTicks(10);
        }
    }

    public void adjustYAxis(int _yAxisMax) {
        boolean enableAutoscale = _yAxisMax == 0;
        gplotAutoscaler.setEnabled(enableAutoscale);
        if (enableAutoscale) {
            return;
        }

        yAxisMax = _yAxisMax;
        plot.setYLim(-AUTOSCALE_SPACING, yAxisMax + AUTOSCALE_SPACING);
    }

    //Used to update the Points within the graph
    private void updateGPlotPoints() {
        List<double[]> allData = markerBoard.getData(nPoints);
        int markerChannel = markerBoard.getMarkerChannel();

        for (int i = 0; i < nPoints; i++) {
            markerPointsArray.set(i, markerTimeArray[i], (float)allData.get(i)[markerChannel], "");
        }
        plot.setPoints(markerPointsArray, PLOT_LAYER);

        gplotAutoscaler.update(plot, markerPointsArray);
    }

    public void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4, y);
        plot.setDim(w - 36 - 4, h);

    }
};

