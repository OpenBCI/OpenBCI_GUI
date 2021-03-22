
////////////////////////////////////////////////////
//                                                //
//    W_focus.pde (ie "Focus Widget")             //
//                                                //
//                                                //
//    Created by: Richard Waltman, March 2021     //
//                                                //
////////////////////////////////////////////////////

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.tuple.Pair;

import brainflow.BoardIds;
import brainflow.BoardShim;
import brainflow.BrainFlowClassifiers;
import brainflow.BrainFlowInputParams;
import brainflow.BrainFlowMetrics;
import brainflow.BrainFlowModelParams;
import brainflow.DataFilter;
import brainflow.LogLevels;
import brainflow.MLModel;

// color enums
public enum FocusColors {
    GREEN, CYAN, ORANGE
}

interface FocusEnum {
    public int getIndex();
    public int getValue();
    public String getString();
}

public enum FocusXLim implements FocusEnum
{
    TEN (0, 10, "10 sec"),
    TWENTY (1, 20, "20 sec"),
    THIRTY (2, 30, "30 sec"),
    SIXTY (3, 60, "60 sec"),
    ONE_HUNDRED_TWENTY (4, 120, "120 sec");

    private int index;
    private int value;
    private String label;

    private static FocusXLim[] vals = values();

    FocusXLim(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    @Override
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
        for (FocusEnum val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

class W_Focus extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    //put your custom variables here...
    private ControlP5 focus_cp5;
    private Button widgetTemplateButton;

    private Grid dataGrid;
    private final int numTableRows = 6;
    private final int numTableColumns = 2;
    private final int tableWidth = 142;
    private int tableHeight = 0;
    private int cellHeight = 10;

    private final int padding_5 = 5;

    private FocusBar focusBar;
    private float focusBarHardYAxisLimit = 1f;
    FocusXLim xLimit = FocusXLim.TEN;

    private FocusColors focusColors = FocusColors.GREEN;

    private double metricPrediction = 0d;
    private float xc, yc, wc, hc; // crystal ball center xy, width and height
    private int graph_x, graph_y, graph_w, graph_h;
    private int graph_pad = 30;
    private color cBack, cDark, cMark, cFocus, cWave, cPanel;

    W_Focus(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        // initialize graphics parameters
        onColorChange();
        
        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("FocusWindow", "Window", FocusXLim.getEnumStringsAsList(), 0);
        addDropdown("FocusMetric", "Metric", Arrays.asList("Concentration", "Relaxation"), 0);
        addDropdown("FocusClassifier", "Classifier", Arrays.asList("Regression", "KNN", "SVM", "LDA"), 0);
        addDropdown("FocusThreshold", "Threshold", Arrays.asList("0.5", "0.6","0.7", "0.8", "0.9"), 0);

        //Create data table
        dataGrid = new Grid(numTableRows, numTableColumns, cellHeight);
        dataGrid.setTableFontAndSize(p6, 10);
        dataGrid.setDrawTableBorder(true);
        dataGrid.setString("Band Power", 0, 0);

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        focus_cp5 = new ControlP5(ourApplet);
        focus_cp5.setGraphics(ourApplet, 0,0);
        focus_cp5.setAutoDraw(false);

        //createWidgetTemplateButton();

        //create our focus graph
        update_graph_dims();
        focusBar = new FocusBar(_parent, focusBarHardYAxisLimit, graph_x, graph_y, graph_w, graph_h);
        focusBar.adjustTimeAxis(w_timeSeries.getTSHorizScale().getValue()); //sync horiz axis to Time Series by default
       
    }

    public void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if (currentBoard.isStreaming()) {
            metricPrediction = updateFocusState();

            focusBar.update();
        }

        //put your code here...
    }

    public void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)
        //remember to refer to x,y,w,h which are the positioning variables of the Widget class

        //Draw data table
        dataGrid.draw();

        //Draw status graphic
        pushStyle();
        noStroke();
        fill(cFocus);
        stroke(cFocus);
        ellipseMode(CENTER);
        ellipse(xc, yc, wc, hc);
        noStroke();
        textAlign(CENTER);
        text("focused!", xc, yc + hc/2 + 16);
        popStyle();

        if (false) {
            //Draw some guides to help develop this widget faster
            pushStyle();
            stroke(0);
            //Main guides
            line(x, y+(h/2), x+w, y+(h/2));
            line(x+(w/2), y, x+(w/2), y+(h/2));
            //Top left container center
            line(x+(w/4), y, x+(w/4), y+(h/2));
            line(x, y+(h/4), x+(w/2), y+(h/4));
            popStyle();
        }

        //This draws all cp5 objects in the local instance
        //focus_cp5.draw();
        
        //Draw the graph
        focusBar.draw();
    }

    public void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Very important to allow users to interact with objects after app resize        
        focus_cp5.setGraphics(ourApplet, 0, 0);

        resizeTable();

        //We need to set the position of our Cp5 object after the screen is resized
        //widgetTemplateButton.setPosition(x + w/2 - widgetTemplateButton.getWidth()/2, y + h/2 - widgetTemplateButton.getHeight()/2);

        update_crystalball_dims();

        update_graph_dims();
        focusBar.screenResized(graph_x, graph_y, graph_w, graph_h);
    }

    private void resizeTable() {
        float upperLeftContainerW = w/2;
        float upperLeftContainerH = h/2;
        //float min = min(upperLeftContainerW, upperLeftContainerH);
        int tx = x + int(upperLeftContainerW);
        int ty = y + padding_5;
        int tw = int(upperLeftContainerW) - padding_5*2;
        //tableHeight = tw;
        dataGrid.setDim(tx, ty, tw);
        dataGrid.setTableHeight(int(upperLeftContainerH - padding_5*2));
        dataGrid.dynamicallySetTextVerticalPadding(0, 0);
        dataGrid.setHorizontalCenterTextInCells(true);
    }

    private void update_crystalball_dims() {
        //Update "crystal ball" dimensions
        float upperLeftContainerW = w/2;
        float upperLeftContainerH = h/2;
        float min = min(upperLeftContainerW, upperLeftContainerH);
        xc = x + w/4;
        yc = y + h/4;
        wc = min * (3f/5);
        hc = wc;
    }

    private void update_graph_dims() {
        graph_w = int(w - padding_5*4);
        graph_h = int(h/2 - graph_pad - padding_5*2);
        graph_x = x + padding_5*2;
        graph_y = int(y + h/2);
    }

    //When creating new UI objects, follow this rough pattern.
    //Using custom methods like this allows us to condense the code required to create new objects.
    //You can find more detailed examples in the Control Panel, where there are many UI objects with varying functionality.
    private void createWidgetTemplateButton() {
        //This is a generalized createButton method that allows us to save code by using a few patterns and method overloading
        widgetTemplateButton = createButton(focus_cp5, "widgetTemplateButton", "Design Your Own Widget!", x + w/2, y + h/2, 200, navHeight, p4, 14, colorNotPressed, OPENBCI_DARKBLUE);
        //Set the border color explicitely
        widgetTemplateButton.setBorderColor(OBJECT_BORDER_GREY);
        //For this button, only call the callback listener on mouse release
        widgetTemplateButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
                if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
                    openURLInBrowser("https://openbci.github.io/Documentation/docs/06Software/01-OpenBCISoftware/GUIWidgets#custom-widget");
                }
            }
        });
        widgetTemplateButton.setDescription("Here is the description for this UI object. It will fade in as help text when hovering over the object.");
    }

    //Returns a metric value from 0. to 1. When there is an error, returns -1.
    private double updateFocusState() {
        try {
            int window_size = currentBoard.getSampleRate() * xLimit.getValue();
            List<double[]> currentData = currentBoard.getData(window_size);
            double[][] data = new double[currentData.size()][];
            if (currentData.size() == 0) {
                println("OOPS!!!!");
                return -1d;
            }
            data = currentData.toArray(data);
            println(data.length);
            Pair<double[], double[]> bands = DataFilter.get_avg_band_powers (data, currentBoard.getEXGChannels(), currentBoard.getSampleRate(), false);
            double[] feature_vector = ArrayUtils.addAll (bands.getLeft (), bands.getRight ());
            BrainFlowModelParams model_params = new BrainFlowModelParams (BrainFlowMetrics.CONCENTRATION.get_code (),
            BrainFlowClassifiers.REGRESSION.get_code ());
            MLModel concentration = new MLModel (model_params);
            concentration.prepare ();
            double prediction = concentration.predict (feature_vector);
            println("Concentration: " + prediction);
            concentration.release ();
            return prediction;

        } catch (BrainFlowError e) {
            e.printStackTrace();
            println("ERROR UPDATING FOCUS STATE!");
            return -1d;
        }
    }

    private void onColorChange() {
        switch(focusColors) {
            case GREEN:
                cBack = #ffffff;   //white
                cDark = #3068a6;   //medium/dark blue
                cMark = #4d91d9;    //lighter blue
                cFocus = #b8dc69;   //theme green
                cWave = #ffdd3a;    //yellow
                cPanel = #f5f5f5;   //little grey
                break;
            case ORANGE:
                cBack = #ffffff;   //white
                cDark = #377bc4;   //medium/dark blue
                cMark = #5e9ee2;    //lighter blue
                cFocus = #fcce51;   //orange
                cWave = #ffdd3a;    //yellow
                cPanel = #f5f5f5;   //little grey
                break;
            case CYAN:
                cBack = #ffffff;   //white
                cDark = #377bc4;   //medium/dark blue
                cMark = #5e9ee2;    //lighter blue
                cFocus = #91f4fc;   //cyan
                cWave = #ffdd3a;    //yellow
                cPanel = #f5f5f5;   //little grey
                break;
        }
    }

    public void setFocusHorizScale(int n) {
        xLimit = xLimit.values()[n];
        focusBar.adjustTimeAxis(xLimit.getValue());
    }

    //add custom functions here
    private void customFunction() {
        //this is a fake function... replace it with something relevant to this widget

    }

};

class FocusBar {
    //this class contains the plot for the 2d graph of accelerometer data
    int x, y, w, h;
    int focusBarPadding = 30;
    int xOffset;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    GPointsArray accelPointsX;
    GPointsArray accelPointsY;
    GPointsArray accelPointsZ;

    int nPoints;
    int numSeconds = 20; //default to 20 seconds
    float timeBetweenPoints;
    float[] accelTimeArray;
    int numSamplesToProcess;
    float minX, minY, minZ;
    float maxX, maxY, maxZ;
    float minVal;
    float maxVal;
    final float autoScaleSpacing = 0.1;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis will automatically update to scale to the largest visible amplitude
    int lastProcessedDataPacketInd = 0;
    
    private AccelerometerCapableBoard accelBoard;

    FocusBar(PApplet _parent, float accelXyzLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
        
        // This widget is only instantiated when the board is accel capable, so we don't need to check
        accelBoard = (AccelerometerCapableBoard)currentBoard;

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
        plot.setPos(x + 36 + 4 + xOffset, y); //match Accelerometer plot position with Time Series
        plot.setDim(w - 36 - 4 - xOffset, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(NUM_ACCEL_DIMS)%8]);
        plot.setXLim(-numSeconds,0); //set the horizontal scale
        plot.setYLim(0, accelXyzLimit); //change this to adjust vertical scale
        //plot.setPointSize(2);
        plot.setPointColor(0);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getYAxis().setAxisLabelText("Metric Value");
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().getAxisLabel().setOffset(float(22));
        plot.getYAxis().getAxisLabel().setOffset(float(focusBarPadding));

        initArrays();

        //set the plot points for X, Y, and Z axes
        plot.addLayer("layer 1", accelPointsX);
        plot.getLayer("layer 1").setLineColor(ACCEL_X_COLOR);
        plot.addLayer("layer 2", accelPointsY);
        plot.getLayer("layer 2").setLineColor(ACCEL_Y_COLOR);
        plot.addLayer("layer 3", accelPointsZ);
        plot.getLayer("layer 3").setLineColor(ACCEL_Z_COLOR);
    }

    void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        accelTimeArray = new float[nPoints];
        for (int i = 0; i < accelTimeArray.length; i++) {
            accelTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
        }

        float[] accelArrayX = new float[nPoints];
        float[] accelArrayY = new float[nPoints];
        float[] accelArrayZ = new float[nPoints];

        //make a GPoint array using float arrays x[] and y[] instead of plain index points
        accelPointsX = new GPointsArray(accelTimeArray, accelArrayX);
        accelPointsY = new GPointsArray(accelTimeArray, accelArrayY);
        accelPointsZ = new GPointsArray(accelTimeArray, accelArrayZ);
    }

    //Used to update the accelerometerBar class
    void update() {
        //updateGPlotPoints();

        if (isAutoscale) {
            //autoScale();
        }
    }

    void draw() {
        plot.beginDraw();
        plot.drawBox(); //we won't draw this eventually ...
        plot.drawGridLines(2);
        plot.drawLines(); //Draw a Line graph!
        //plot.drawPoints(); //Used to draw Points instead of Lines
        plot.drawYAxis();
        plot.drawXAxis();
        plot.getXAxis().draw();
        plot.endDraw();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        initArrays();

        //Set the number of axis divisions...
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);
        }else{
            plot.getXAxis().setNTicks(10);
        }
    }

    //Used to update the Points within the graph
    void updateGPlotPoints() {
        List<double[]> allData = currentBoard.getData(nPoints);
        int[] accelChannels = accelBoard.getAccelerometerChannels();

        for (int i=0; i < nPoints; i++) {
            accelPointsX.set(i, accelTimeArray[i], (float)allData.get(i)[accelChannels[0]], "");
            accelPointsY.set(i, accelTimeArray[i], (float)allData.get(i)[accelChannels[1]], "");
            accelPointsZ.set(i, accelTimeArray[i], (float)allData.get(i)[accelChannels[2]], "");
        }

        plot.setPoints(accelPointsX, "layer 1");
        plot.setPoints(accelPointsY, "layer 2");
        plot.setPoints(accelPointsZ, "layer 3");
    }

    float[] getLastAccelVals() {
        float[] result = new float[NUM_ACCEL_DIMS];
        result[0] = accelPointsX.getY(nPoints-1);   
        result[1] = accelPointsY.getY(nPoints-1);   
        result[2] = accelPointsZ.getY(nPoints-1);   

        return result;
    }

    void adjustVertScale(int _vertScaleValue) {
        if (_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
        }
    }

    void autoScale() {
        float[] minMaxVals = minMax(accelPointsX, accelPointsY, accelPointsZ);
        plot.setYLim(minMaxVals[0] - autoScaleSpacing, minMaxVals[1] + autoScaleSpacing);
    }

    float[] minMax(GPointsArray arrX, GPointsArray arrY, GPointsArray arrZ) {
        float[] minMaxVals = {0.f, 0.f};
        for (int i = 0; i < arrX.getNPoints(); i++) { //go through the XYZ GPpointArrays for on-screen values
            float[] vals = {arrX.getY(i), arrY.getY(i), arrZ.getY(i)};
            minMaxVals[0] = min(minMaxVals[0], min(vals)); //make room to see
            minMaxVals[1] = max(minMaxVals[1], max(vals));
        }
        return minMaxVals;
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