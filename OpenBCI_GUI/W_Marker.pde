//////////////////////////////////////////////////////
//                                                  //
//                  W_Marker.pde                    //
//                                                  //
//    Created by: Richard Waltman, August 2023      //
//    Purpose: Add software markers to data         //
//    Marker Shortcuts: z x c v                     //
//                                                  //
//////////////////////////////////////////////////////

class W_Marker extends Widget {

    private ControlP5 localCP5;

    private final int MARKER_BUTTON_WIDTH = 125;
    private final int NUMBER_OF_MARKER_BUTTONS = 4;
    private Button[] markerButtons = new Button[NUMBER_OF_MARKER_BUTTONS];

    private MarkerBar markerBar;
    private int graphX, graphY, graphW, graphH;
    private int PAD_FIVE = 5;
    private int GRAPH_PADDING = 30;
    private float markerBarHardYAxisLimit = NUMBER_OF_MARKER_BUTTONS + 0.05f;
    private MarkerXLim xLimit = MarkerXLim.TEN;

    W_Marker(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);

        createMarkerButtons();

        updateGraphDims();
        addDropdown("markerWindowDropdown", "Window", xLimit.getEnumStringsAsList(), xLimit.getIndex());
        markerBar = new MarkerBar(_parent, NUMBER_OF_MARKER_BUTTONS, xLimit.getValue(), markerBarHardYAxisLimit, graphX, graphY, graphW, graphH);
       
    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if (currentBoard.isStreaming()) {
            markerBar.update();
        }

    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        markerBar.draw();

        //This draws all cp5 objects in the local instance
        localCP5.draw();
    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Very important to allow users to interact with objects after app resize        
        localCP5.setGraphics(ourApplet, 0, 0);

        //Update positions of marker buttons
        for (int i = 0; i < NUMBER_OF_MARKER_BUTTONS; i++) {
            markerButtons[i].setPosition(x + 10 + (i * MARKER_BUTTON_WIDTH), y + 10);
        }

        updateGraphDims();
        markerBar.screenResized(graphX, graphY, graphW, graphH);

    }

    private void updateGraphDims() {
        graphW = int(w - PAD_FIVE*4);
        graphH = int(h/2 - GRAPH_PADDING - PAD_FIVE*2);
        graphX = x + PAD_FIVE*2;
        graphY = y + h - graphH - int(GRAPH_PADDING*2) + GRAPH_PADDING/6;
    }

    private void createMarkerButtons() {
        for (int i = 0; i < NUMBER_OF_MARKER_BUTTONS; i++) {
            //Create marker buttons
            //Marker number is i + 1 because marker numbers start at 1, not 0. Otherwise, will throw BrainFlow error.
            markerButtons[i] = createMarkerButton(i + 1, x + 10 + (i * MARKER_BUTTON_WIDTH), y + 10);
        }
    }

    private Button createMarkerButton(final int markerNumber, int _x, int _y) {
        Button newButton = createButton(localCP5, "markerButton" + markerNumber, "Insert Marker " + markerNumber, _x, _y, 125, navH - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        newButton.setBorderColor(OBJECT_BORDER_GREY);
        newButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                insertMarkerFromKeyboardOrButton(markerNumber);
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
                insertMarkerFromKeyboardOrButton(1);
                return true;
            case 'x':
                insertMarkerFromKeyboardOrButton(2);
                return true;
            case 'c':
                insertMarkerFromKeyboardOrButton(3);
                return true;
            case 'v':
                insertMarkerFromKeyboardOrButton(4);
                return true;
            case 'Z':
                insertMarkerFromKeyboardOrButton(5);
                return true;
            case 'X':
                insertMarkerFromKeyboardOrButton(6);
                return true;
            case 'C':
                insertMarkerFromKeyboardOrButton(7);
                return true;
            case 'V':
                insertMarkerFromKeyboardOrButton(8);
                return true;
            default:
                return false;
        }
    }

    private void insertMarkerFromKeyboardOrButton(int markerNumber) {
        int markerChannel = ((DataSource)currentBoard).getMarkerChannel();

        if (currentBoard instanceof BoardBrainFlow) {
            if (markerChannel != -1) {
                ((Board)currentBoard).insertMarker(markerNumber);
            }
        }
    }

    public void setMarkerHorizScale(int n) {
        xLimit = xLimit.values()[n];
        markerBar.adjustTimeAxis(xLimit.getValue());
    }

};

//The following global functions are used by the Marker widget dropdowns. This method is the least amount of code.
public void markerWindowDropdown(int n) {
    w_marker.setMarkerHorizScale(n);
}

public enum MarkerXLim implements IndexingInterface
{
    FIVE (0, 5, "5 sec"),
    TEN (1, 10, "10 sec"),
    TWENTY (2, 20, "20 sec");

    private int index;
    private int value;
    private String label;
    private static MarkerXLim[] vals = values();

    MarkerXLim(int _index, int _value, String _label) {
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

//This class contains the time series plot for displaying the markers over time
class MarkerBar {
    //this class contains the plot for the 2d graph of marker data
    private int x, y, w, h;
    private int markerBarPadding = 30;
    private int xOffset;

    private GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    private GPointsArray[] markerPointsArrays;
    private int numMarkers;


    private int nPoints;
    private int numSeconds = 20; //default to 20 seconds
    private float timeBetweenPoints;
    private float[] markerTimeArray;
    private int numSamplesToProcess;
    private float minX, minY, minZ;
    private float maxX, maxY, maxZ;
    private float minVal;
    private float maxVal;

    private color[] markerChannelColors;

    private int lastProcessedDataPacketInd = 0;
    
    private DataSource markerBoard;

    MarkerBar(PApplet _parent, int _numMarkers, int xLimit, float yLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
        
        numMarkers = _numMarkers;

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

        numSeconds = xLimit;

        plot = new GPlot(_parent);
        plot.setPos(x + 36 + 4 + xOffset, y); //match marker plot position with Time Series
        plot.setDim(w - 36 - 4 - xOffset, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(numMarkers)%8]);
        plot.setXLim(-numSeconds, 0); //set the horizontal scale
        plot.setYLim(-0.2, yLimit); //change this to adjust vertical scale
        //plot.setPointSize(2);
        plot.setPointColor(0);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getYAxis().setAxisLabelText("Marker (int)");
        plot.getYAxis().setNTicks(3);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().getAxisLabel().setOffset(float(markerBarPadding));
        plot.getYAxis().getAxisLabel().setOffset(float(markerBarPadding));
        plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);

        initArrays();

        for (int i = 0; i < numMarkers; i++) {
            plot.addLayer("layer " + i, markerPointsArrays[i]);
            plot.getLayer("layer " + i).setLineColor(markerChannelColors[i]);
        }

    }

    void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        markerTimeArray = new float[nPoints];
        for (int i = 0; i < markerTimeArray.length; i++) {
            markerTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
        }

        float[] tempMarkerFloatArray = new float[nPoints];

        //make a GPoint array using float arrays x[] and y[] instead of plain index points
        markerPointsArrays = new GPointsArray[numMarkers];
        for (int i = 0; i < numMarkers; i++) {
            markerPointsArrays[i] = new GPointsArray(markerTimeArray, tempMarkerFloatArray);
        }

        markerChannelColors = new color[numMarkers];
        for (int i = 0; i < numMarkers; i++) {
            markerChannelColors[i] = (int)channelColors[i % 8];
        }
    }

    //Used to update the accelerometerBar class
    void update() {
        updateGPlotPoints();
    }

    void draw() {
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

    int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-numSeconds,0);

        initArrays();

        //Set the number of axis divisions...
        if (numSeconds > 1) {
            plot.getXAxis().setNTicks(numSeconds);
        }else{
            plot.getXAxis().setNTicks(10);
        }
    }

    //Used to update the Points within the graph
    void updateGPlotPoints() {
        List<double[]> allData = markerBoard.getData(nPoints);
        int markerChannel = markerBoard.getMarkerChannel();

        for (int marker = 0; marker < numMarkers; marker++) {
            for (int i = 0; i < nPoints; i++) {
                markerPointsArrays[marker].set(i, markerTimeArray[i], (float)allData.get(i)[markerChannel], "");
            }
        }

        for (int i = 0; i < numMarkers; i++) {
            plot.setPoints(markerPointsArrays[i], "layer " + i);
        }
    }

    void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4 + xOffset, y);
        plot.setDim(w - 36 - 4 - xOffset, h);

    }
}; //end of class
