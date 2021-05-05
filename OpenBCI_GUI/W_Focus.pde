////////////////////////////////////////////////////
//                                                //
//    W_focus.pde (ie "Focus Widget")             //
//    Enums can be found in FocusEnums.pde        //
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

class W_Focus extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    //put your custom variables here...
    private ControlP5 focus_cp5;
    private Button widgetTemplateButton;
    private ChannelSelect focusChanSelect;
    private boolean prevChanSelectIsVisible = false;

    private Grid dataGrid;
    private final int numTableRows = 6;
    private final int numTableColumns = 2;
    private final int tableWidth = 142;
    private int tableHeight = 0;
    private int cellHeight = 10;
    private DecimalFormat df = new DecimalFormat("#.0000");

    private final int PAD_FIVE = 5;
    private final int PAD_TWO = 2;
    private final int METRIC_DROPDOWN_W = 100;
    private final int CLASSIFIER_DROPDOWN_W = 80;

    private FocusBar focusBar;
    private float focusBarHardYAxisLimit = 1f;
    FocusXLim xLimit = FocusXLim.TEN;
    FocusMetric focusMetric = FocusMetric.RELAXATION;
    FocusClassifier focusClassifier = FocusClassifier.REGRESSION;
    FocusThreshold focusThreshold = FocusThreshold.EIGHT_TENTHS;
    private FocusColors focusColors = FocusColors.GREEN;

    int[] exgChannels;
    int channelCount;
    double[][] dataArray;

    MLModel mlModel;
    private double metricPrediction = 0d;
    private boolean predictionExceedsThreshold = false;

    private float xc, yc, wc, hc; // status circle center xy, width and height
    private int graphX, graphY, graphW, graphH;
    private int graphPadding = 30;
    private color cBack, cDark, cMark, cFocus, cWave, cPanel;

    W_Focus(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

         //Add channel select dropdown to this widget
        focusChanSelect = new ChannelSelect(pApplet, this, x, y, w, navH, "FocusChannelSelect");
        focusChanSelect.activateAllButtons();

        exgChannels = currentBoard.getEXGChannels();
        channelCount = currentBoard.getNumEXGChannels();
        dataArray = new double[channelCount][];

        // initialize graphics parameters
        onColorChange();
        
        //This is the protocol for setting up dropdowns.
        dropdownWidth = 60; //Override the default dropdown width for this widget
        addDropdown("focusMetricDropdown", "Metric", FocusMetric.getEnumStringsAsList(), focusMetric.getIndex());
        addDropdown("focusClassifierDropdown", "Classifier", FocusClassifier.getEnumStringsAsList(), focusClassifier.getIndex());
        addDropdown("focusThresholdDropdown", "Threshold", FocusThreshold.getEnumStringsAsList(), focusThreshold.getIndex());
        addDropdown("focusWindowDropdown", "Window", FocusXLim.getEnumStringsAsList(), xLimit.getIndex());
        

        //Create data table
        dataGrid = new Grid(numTableRows, numTableColumns, cellHeight);
        dataGrid.setTableFontAndSize(p6, 10);
        dataGrid.setDrawTableBorder(true);
        dataGrid.setString("Metric Value", 0, 0);

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        focus_cp5 = new ControlP5(ourApplet);
        focus_cp5.setGraphics(ourApplet, 0,0);
        focus_cp5.setAutoDraw(false);

        //create our focus graph
        updateGraphDims();
        focusBar = new FocusBar(_parent, focusBarHardYAxisLimit, graphX, graphY, graphW, graphH);

        initBrainFlowMetric();
    }

    public void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        //Update channel checkboxes and active channels
        focusChanSelect.update(x, y, w);

        //Flex the Gplot graph when channel select dropdown is open/closed
        if (focusChanSelect.isVisible() != prevChanSelectIsVisible) {
            channelSelectFlexWidgetUI();
            prevChanSelectIsVisible = focusChanSelect.isVisible();
        }

        if (currentBoard.isStreaming()) {
            metricPrediction = updateFocusState();
            dataGrid.setString(df.format(metricPrediction), 0, 1);
            focusBar.update(metricPrediction);
            predictionExceedsThreshold = metricPrediction > focusThreshold.getValue();
        }

        //put your code here...
    }

    public void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)
        //remember to refer to x,y,w,h which are the positioning variables of the Widget class

        //Draw data table
        dataGrid.draw();

        drawStatusCircle();

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
        focus_cp5.draw();
        
        //Draw the graph
        focusBar.draw();

        focusChanSelect.draw();
    }

    public void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Very important to allow users to interact with objects after app resize        
        focus_cp5.setGraphics(ourApplet, 0, 0);

        resizeTable();

        //We need to set the position of our Cp5 object after the screen is resized
        //widgetTemplateButton.setPosition(x + w/2 - widgetTemplateButton.getWidth()/2, y + h/2 - widgetTemplateButton.getHeight()/2);

        updateStatusCircle();

        updateGraphDims();
        focusBar.screenResized(graphX, graphY, graphW, graphH);
        focusChanSelect.screenResized(pApplet);

        //Custom resize these dropdowns due to longer text strings as options
        cp5_widget.get(ScrollableList.class, "focusMetricDropdown").setWidth(METRIC_DROPDOWN_W);
        cp5_widget.get(ScrollableList.class, "focusMetricDropdown").setPosition(
            x0 + w0 - (dropdownWidth*2) - METRIC_DROPDOWN_W - CLASSIFIER_DROPDOWN_W - (PAD_TWO*4), 
            navH + y0 + PAD_TWO
            );
        cp5_widget.get(ScrollableList.class, "focusClassifierDropdown").setWidth(CLASSIFIER_DROPDOWN_W);
        cp5_widget.get(ScrollableList.class, "focusClassifierDropdown").setPosition(
            x0 + w0 - (dropdownWidth*2) - CLASSIFIER_DROPDOWN_W - (PAD_TWO*3), 
            navH + y0 + PAD_TWO
            );
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        focusChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
    }

    private void resizeTable() {
        int extraPadding = focusChanSelect.isVisible() ? navHeight : 0;
        float upperLeftContainerW = w/2;
        float upperLeftContainerH = h/2;
        //float min = min(upperLeftContainerW, upperLeftContainerH);
        int tx = x + int(upperLeftContainerW);
        int ty = y + PAD_FIVE + extraPadding;
        int tw = int(upperLeftContainerW) - PAD_FIVE*2;
        //tableHeight = tw;
        dataGrid.setDim(tx, ty, tw);
        dataGrid.setTableHeight(int(upperLeftContainerH - PAD_FIVE*2));
        dataGrid.dynamicallySetTextVerticalPadding(0, 0);
        dataGrid.setHorizontalCenterTextInCells(true);
    }

    private void updateStatusCircle() {
        float upperLeftContainerW = w/2;
        float upperLeftContainerH = h/2;
        float min = min(upperLeftContainerW, upperLeftContainerH);
        xc = x + w/4;
        yc = y + h/4;
        wc = min * (3f/5);
        hc = wc;
    }

    private void updateGraphDims() {
        graphW = int(w - PAD_FIVE*4);
        graphH = int(h/2 - graphPadding - PAD_FIVE*2);
        graphX = x + PAD_FIVE*2;
        graphY = int(y + h/2);
    }

    //Core method to fetch and process data
    //Returns a metric value from 0. to 1. When there is an error, returns -1.
    private double updateFocusState() {
        try {
            int windowSize = currentBoard.getSampleRate() * xLimit.getValue();
            // getData in GUI returns data in shape ndatapoints x nchannels, in BrainFlow its transposed
            List<double[]> currentData = currentBoard.getData(windowSize);

            if (currentData.size() != windowSize || focusChanSelect.activeChan.size() <= 0) {
                return -1.0;
            }

            for (int i = 0; i < channelCount; i++) {
                dataArray[i] = new double[windowSize];
                for (int j = 0; j < currentData.size(); j++) {
                    dataArray[i][j] = currentData.get(j)[exgChannels[i]];
                }
            }

            int[] channelsInDataArray = ArrayUtils.toPrimitive(
                    focusChanSelect.activeChan.toArray(
                        new Integer[focusChanSelect.activeChan.size()]
                    ));

            Pair<double[], double[]> bands = DataFilter.get_avg_band_powers (dataArray, channelsInDataArray, currentBoard.getSampleRate(), true);
            double[] featureVector = ArrayUtils.addAll (bands.getLeft (), bands.getRight ());

            //Keep this here
            double prediction = mlModel.predict(featureVector);
            //println("Concentration: " + prediction);
            
            return prediction;

        } catch (BrainFlowError e) {
            e.printStackTrace();
            println("Error updating focus state!");
            return -1d;
        }
    }

    private void drawStatusCircle() {
        color fillColor;
        color strokeColor;
        StringBuilder sb = new StringBuilder("");
        if (predictionExceedsThreshold) {
            fillColor = cFocus;
            strokeColor = cFocus;
        } else {
            fillColor = cDark;
            strokeColor = cDark;
            sb.append("Not ");
        }
        sb.append(focusMetric.getIdealStateString());
        //Draw status graphic
        pushStyle();
        noStroke();
        fill(fillColor);
        stroke(strokeColor);
        ellipseMode(CENTER);
        ellipse(xc, yc, wc, hc);
        noStroke();
        textAlign(CENTER);
        text(sb.toString(), xc, yc + hc/2 + 16);
        popStyle();
    }

    private void initBrainFlowMetric() {
        BrainFlowModelParams modelParams = new BrainFlowModelParams(
                focusMetric.getMetric().get_code(),
                focusClassifier.getClassifier().get_code()
                );
        mlModel = new MLModel (modelParams);
        try {
            mlModel.prepare();
        } catch (BrainFlowError e) {
            e.printStackTrace();
        }
    }

    //Called on haltSystem() when GUI exits or session stops
    public void endSession() {
        try {
            mlModel.release();
        } catch (BrainFlowError e) {
            e.printStackTrace();
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

    void channelSelectFlexWidgetUI() {
        focusBar.setPlotPosAndOuterDim(focusChanSelect.isVisible());
        int factor = focusChanSelect.isVisible() ? 1 : -1;
        yc += navHeight * factor;
        resizeTable();
    }

    public void setFocusHorizScale(int n) {
        xLimit = xLimit.values()[n];
        focusBar.adjustTimeAxis(xLimit.getValue());
    }

    public void setMetric(int n) {
        focusMetric = focusMetric.values()[n];
        endSession();
        initBrainFlowMetric();
    }

    public void setClassifier(int n) {
        focusClassifier = focusClassifier.values()[n];
        endSession();
        initBrainFlowMetric();
    }

    public void setThreshold(int n) {
        focusThreshold = focusThreshold.values()[n];
    }
}; //end of class

//The following global functions are used by the Focus widget dropdowns. This method is the least amount of code.
public void focusWindowDropdown(int n) {
    w_focus.setFocusHorizScale(n);
}

public void focusMetricDropdown(int n) {
    w_focus.setMetric(n);
}

public void focusClassifierDropdown(int n) {
    w_focus.setClassifier(n);
}

public void focusThresholdDropdown(int n) {
    w_focus.setThreshold(n);
}

//This class contains the time series plot for the focus metric over time
class FocusBar {
    int x, y, w, h;
    int focusBarPadding = 30;
    int xOffset;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    LinkedList<Float> fifoList;
    GPointsArray focusPoints;

    int nPoints;
    int numSeconds = FocusXLim.TWENTY.getValue(); //default to 20 seconds
    float timeBetweenPoints;
    float graphTimer;
    float[] focusTimeArray;
    int numSamplesToProcess;
    float minX, minY, minZ;
    float maxX, maxY, maxZ;
    float minVal;
    float maxVal;
    final float autoScaleSpacing = 0.1;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis will automatically update to scale to the largest visible amplitude
    int lastProcessedDataPacketInd = 0;

    FocusBar(PApplet _parent, float accelXyzLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
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

        adjustTimeAxis(numSeconds);

        initArrays();

        //set the plot points for X, Y, and Z axes
        plot.addLayer("layer 1", focusPoints);
        plot.getLayer("layer 1").setLineColor(ACCEL_X_COLOR);
    }

    private void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;
        focusTimeArray = new float[nPoints];
        fifoList = new LinkedList<Float>();
        for (int i = 0; i < focusTimeArray.length; i++) {
            focusTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
            fifoList.add(0f);
        }
        float[] floatArray = ArrayUtils.toPrimitive(fifoList.toArray(new Float[0]), 0.0F);
        focusPoints = new GPointsArray(focusTimeArray, floatArray);
    }

    public void update(double val) {
        updateGPlotPoints(val);
    }

    public void draw() {
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

    private int nPointsBasedOnDataSource() {
        return numSeconds * 30;
    }

    public void adjustTimeAxis(int _newTimeSize) {
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
    private void updateGPlotPoints(double val) {
        //todo : important to align time with actual elapsed time!
        //if (graphTimer + timeBetweenPoints < millis()) {
            graphTimer = millis();
            fifoList.removeFirst();
            fifoList.addLast((float)val);

            for (int i=0; i < nPoints; i++) {
                focusPoints.set(i, focusTimeArray[i], fifoList.get(i), "");
            }

            plot.setPoints(focusPoints, "layer 1");
        //}
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

    public void setPlotPosAndOuterDim(boolean chanSelectIsVisible) {
        int _y = chanSelectIsVisible ? y + 22 : y;
        int _h = chanSelectIsVisible ? h - 22 : h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4 + xOffset, _y);
        plot.setDim(w - 36 - 4 - xOffset, _h);
    }

}; //end of class