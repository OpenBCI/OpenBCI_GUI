//////////////////////////////////////////////////////
//                                                  //
//                  W_Marker.pde                    //
//                                                  //
//    Created by: Richard Waltman, August 2023      //
//    Purpose: Add software markers to data         //
//    Marker Shortcuts: z x c v Z X C V             //
//                                                  //
//////////////////////////////////////////////////////

class W_Marker extends Widget {

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
    private Grid markerUIGrid;

    private Textfield markerReceiveIPTextfield;
    private Textfield markerReceivePortTextfield;
    private String markerReceiveIP = "127.0.0.1";
    private int markerReceivePort = 12350;
    private final int MARKER_RECEIVE_TEXTFIELD_WIDTH = 240;
    private final int MARKER_RECEIVE_TEXTFIELD_HEIGHT = 22;

    private hypermedia.net.UDP udpReceiver;

    private MarkerBar markerBar;
    private int graphX, graphY, graphW, graphH;
    private int PAD_FIVE = 5;
    private int GRAPH_PADDING = 30;

    private MarkerVertScale markerVertScale = MarkerVertScale.EIGHT;
    private MarkerWindow markerWindow = MarkerWindow.FIVE;

    W_Marker(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);

        createMarkerButtons();

        updateGraphDims();
        addDropdown("markerVertScaleDropdown", "Vert Scale", markerVertScale.getEnumStringsAsList(), markerVertScale.getIndex());
        addDropdown("markerWindowDropdown", "Window", markerWindow.getEnumStringsAsList(), markerWindow.getIndex());
        markerBar = new MarkerBar(_parent, MAX_NUMBER_OF_MARKER_BUTTONS, markerWindow.getValue(), markerVertScale.getValue(), graphX, graphY, graphW, graphH);

        markerUIGrid = new Grid(MARKER_UI_GRID_ROWS, MARKER_UI_GRID_COLUMNS, MARKER_UI_GRID_CELL_HEIGHT);
        markerUIGrid.setDrawTableBorder(false);
        markerUIGrid.setDrawTableInnerLines(false);
        markerUIGrid.setTableFontAndSize(p4, 14);
        markerUIGrid.setString("Receive IP", 3, 0);
        markerUIGrid.setString("Receive Port", 3, 2);

        createMarkerReceiveTextfields();

        initUdpMarkerReceiver();

        //Add all cp5 elements to a list so that they can be checked for overlap
        cp5ElementsToCheckForOverlap = new ArrayList<controlP5.Controller>();
        for (int i = 0; i < MAX_NUMBER_OF_MARKER_BUTTONS; i++) {
            cp5ElementsToCheckForOverlap.add(markerButtons[i]);
        }
        cp5ElementsToCheckForOverlap.add(markerReceiveIPTextfield);
        cp5ElementsToCheckForOverlap.add(markerReceivePortTextfield);
    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        copyPaste.checkForCopyPaste(markerReceiveIPTextfield);
        copyPaste.checkForCopyPaste(markerReceivePortTextfield);

        lockElementsOnOverlapCheck(cp5ElementsToCheckForOverlap);

        if (currentBoard.isStreaming()) {
            markerBar.update();
        }

    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        markerUIGrid.draw();
        markerBar.draw();

        //This draws all cp5 objects in the local instance
        localCP5.draw();
    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Very important to allow users to interact with objects after app resize        
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
        markerUIGrid.setDim(tableX, tableY, tableW);
        markerUIGrid.setRowHeight(MARKER_UI_GRID_CELL_HEIGHT);
        markerUIGrid.dynamicallySetTextVerticalPadding(3, 0);
        markerUIGrid.dynamicallySetTextVerticalPadding(3, 2);
        markerUIGrid.setHorizontalCenterTextInCells(true);

        final int CELL_PADDING = 8;
        final int CELL_PADDING_TOTAL = CELL_PADDING * 2;
        final int HALF_CELL_PADDING = CELL_PADDING / 2;

        //Update positions of marker buttons
        for (int i = 0; i < MAX_NUMBER_OF_MARKER_BUTTONS; i++) {
            int row = i < MARKER_UI_GRID_COLUMNS ? 0 : 1;
            int column = i % (MARKER_UI_GRID_COLUMNS);
            RectDimensions cellDims = markerUIGrid.getCellDims(row, column);
            markerButtons[i].setPosition(cellDims.x + CELL_PADDING, cellDims.y + HALF_CELL_PADDING);
            markerButtons[i].setSize(cellDims.w - CELL_PADDING_TOTAL, cellDims.h - CELL_PADDING);
        }

        RectDimensions ipTextfieldPosition = markerUIGrid.getCellDims(3, 1);
        markerReceiveIPTextfield.setPosition(ipTextfieldPosition.x, ipTextfieldPosition.y + HALF_CELL_PADDING);

        RectDimensions portTextfieldPosition = markerUIGrid.getCellDims(3, 3);
        markerReceivePortTextfield.setPosition(portTextfieldPosition.x, portTextfieldPosition.y + HALF_CELL_PADDING);
    }

    private void createMarkerButtons() {
        for (int i = 0; i < MAX_NUMBER_OF_MARKER_BUTTONS; i++) {
            //Create marker buttons
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

    private void createMarkerReceiveTextfields() {
        markerReceiveIPTextfield = createTextfield("markerReceiveIPTextfield", markerReceiveIP);
        markerReceivePortTextfield = createTextfield("markerReceivePortTextfield", Integer.toString(markerReceivePort));
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
                    initUdpMarkerReceiver();
                }
            }
        });
        //Autogenerate name if user leaves textfield and value is null
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    resetMarkerReceiveTextfield(myTextfield);
                    initUdpMarkerReceiver();
                }
            }
        });
        //Reinitialize UDP receiver if user presses Enter key and textfield value is not null
        myTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && !myTextfield.getText().equals("")) {
                    initUdpMarkerReceiver();
                }
            }
        });
        return myTextfield;
    }

    private void resetMarkerReceiveTextfield(Textfield tf) {
        if (tf.getName().equals("markerReceiveIPTextfield")) {
            tf.setText(markerReceiveIP);
        } else if (tf.getName().equals("markerReceivePortTextfield")) {
            tf.setText(Integer.toString(markerReceivePort));
        }
    }

    private void initUdpMarkerReceiver() {
        markerReceiveIP = getIpAddrFromStr(markerReceiveIPTextfield.getText());
        markerReceivePort = Integer.parseInt(dropNonPrintableChars(markerReceivePortTextfield.getText()));
        if (udpReceiver != null) {
            udpReceiver.close();
        }
        udpReceiver = new UDP(ourApplet, markerReceivePort, markerReceiveIP);
        udpReceiver.listen(true);
        udpReceiver.log(false);
        udpReceiver.setReceiveHandler("receiveMarkerViaUdp");
        outputSuccess("Marker Widget: Listening for markers on " + markerReceiveIP + ":" + markerReceivePort);
    }

    private void insertMarker(int markerNumber) {
        int markerChannel = ((DataSource)currentBoard).getMarkerChannel();

        if (currentBoard instanceof BoardBrainFlow) {
            if (markerChannel != -1) {
                ((Board)currentBoard).insertMarker(markerNumber);
            }
        }
    }

    public void insertMarkerFromExternal(float markerValue) {
        int markerChannel = ((DataSource)currentBoard).getMarkerChannel();

        if (currentBoard instanceof BoardBrainFlow) {
            if (markerChannel != -1) {
                ((Board)currentBoard).insertMarker(markerValue);
            }
        }
    }

    public void setMarkerWindow(int n) {
        markerWindow = markerWindow.values()[n];
        markerBar.adjustTimeAxis(markerWindow.getValue());
    }

    public void setMarkerVertScale(int n) {
        markerVertScale = markerVertScale.values()[n];
        markerBar.adjustYAxis(markerVertScale.getValue());
    }

    public MarkerWindow getMarkerWindow() {
        return markerWindow;
    }

    public MarkerVertScale getMarkerVertScale() {
        return markerVertScale;
    }

    public String getMarkerReceiveIP() {
        return getIpAddrFromStr(markerReceiveIPTextfield.getText());
    }

    public String getMarkerReceivePort() {
        return dropNonPrintableChars(markerReceivePortTextfield.getText());
    }

}; //end class W_Marker

//This class contains the time series plot for displaying the markers over time
class MarkerBar {
    //this class contains the plot for the 2d graph of marker data
    private int x, y, w, h;
    private int X_AXIS_PADDING = 22;
    private int Y_AXIS_PADDING = 30;
    private int xOffset;

    private GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    private GPointsArray markerPointsArray;
    private final String PLOT_LAYER = "layer1";

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

    MarkerBar(PApplet _parent, int _yAxisMax, int markerWindow, float yLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
        
        yAxisMax = _yAxisMax;
        numSeconds = markerWindow;

        // This widget is only instantiated when the board is accel capable, so we don't need to check
        markerBoard = (DataSource)currentBoard;

        x = _x;
        y = _y;
        w = _w;
        h = _h;
        if (eegDataSource == DATASOURCE_CYTON) {
            xOffset = 22;
        } else {
            xOffset = 0;
        }

        plot = new GPlot(_parent);
        plot.setPos(x + 36 + 4 + xOffset, y); //match marker plot position with Time Series
        plot.setDim(w - 36 - 4 - xOffset, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor(WHITE);
        plot.setXLim(-numSeconds, 0); //set the horizontal scale
        plot.setYLim(-0.2, yLimit + .2); //change this to adjust vertical scale
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

    //Used to update the accelerometerBar class
    public void update() {
        updateGPlotPoints();

        if (isAutoscale) {
            adjustYAxis(-1);
        }
    }

    public void draw() {
        pushStyle();
        plot.beginDraw();
        plot.drawBox(); //we won't draw this eventually ...
        plot.drawGridLines(GPlot.BOTH);
        plot.drawLines(); //Draw a Line graph!
        //plot.drawPoints(); //Used to draw Points instead of Lines
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

        //Set the number of axis divisions...
        if (numSeconds > 1) {
            plot.getXAxis().setNTicks(numSeconds);
        } else {
            plot.getXAxis().setNTicks(10);
        }
    }

    public void adjustYAxis(int _yAxisMax) {
        if (_yAxisMax == -1) {
            yAxisMax = 1;
            isAutoscale = true;
            return;
        }
        isAutoscale = false;
        yAxisMax = _yAxisMax;
        plot.setYLim(-0.2, yAxisMax + .2);
    }

    void applyAutoscale() {
        //Do this once a second for all TimeSeries ChannelBars to save on resources
        int newMillis = millis();
        boolean doAutoscale = newMillis > previousMillis + 1000;
        if (isAutoscale && currentBoard.isStreaming() && doAutoscale) {
            autoscaleMin = (int) Math.floor(autoscaleMin);
            autoscaleMax = (int) Math.ceil(autoscaleMax);
            previousMillis = newMillis;
            plot.setYLim(autoscaleMin, autoscaleMax); //<---- This is a very expensive method. Here is the bottleneck.
        }
    }

    //Used to update the Points within the graph
    private void updateGPlotPoints() {
        List<double[]> allData = markerBoard.getData(nPoints);
        int markerChannel = markerBoard.getMarkerChannel();

        autoscaleMax = -Float.MAX_VALUE;
        autoscaleMin = Float.MAX_VALUE;

        for (int i = 0; i < nPoints; i++) {
            markerPointsArray.set(i, markerTimeArray[i], (float)allData.get(i)[markerChannel], "");
            autoscaleMax = Math.max((float)allData.get(i)[markerChannel], autoscaleMax);
            autoscaleMin = Math.min((float)allData.get(i)[markerChannel], autoscaleMin);
        }
        applyAutoscale();
        plot.setPoints(markerPointsArray, PLOT_LAYER);
    }

    public void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4 + xOffset, y);
        plot.setDim(w - 36 - 4 - xOffset, h);

    }
}; //end of class

//Enum for the Marker Window in W_Marker class
public enum MarkerWindow implements IndexingInterface
{
    FIVE (0, 5, "5 sec"),
    TEN (1, 10, "10 sec"),
    TWENTY (2, 20, "20 sec");

    private int index;
    private int value;
    private String label;
    private static MarkerWindow[] vals = values();

    MarkerWindow(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

//Enum for the Marker Vertical Scale in W_Marker class
public enum MarkerVertScale implements IndexingInterface
{
    AUTO (0, -1, "Auto"),
    TWO (1, 2, "2"),
    FOUR (2, 4, "4"),
    EIGHT (3, 8, "8"),
    TEN (4, 10, "10"),
    TWENTY (6, 20, "20");

    private int index;
    private int value;
    private String label;
    private static MarkerVertScale[] vals = values();

    MarkerVertScale(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

//The following global functions are used by the Marker widget dropdowns. This method is the least amount of code.
public void markerWindowDropdown(int n) {
    w_marker.setMarkerWindow(n);
}

public void markerVertScaleDropdown(int n) {
    w_marker.setMarkerVertScale(n);
}

//Custom UDP receive handler for receiving markers from external sources
public void receiveMarkerViaUdp( byte[] data, String ip, int port ) {
    float markerValue = convertByteArrayToFloat(data);
    String message = Float.toString(markerValue);
    
    //println( "received: \""+message+"\" from "+ip+" on port "+port );
    w_marker.insertMarkerFromExternal(markerValue);
}

public float convertByteArrayToFloat(byte[] array) {
    ByteBuffer buffer = ByteBuffer.wrap(array);
    return buffer.getFloat();
}