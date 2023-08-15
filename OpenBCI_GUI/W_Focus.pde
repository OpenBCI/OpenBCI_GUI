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
    //private ControlP5 focus_cp5;
    //private Button widgetTemplateButton;
    private ChannelSelect focusChanSelect;
    private boolean prevChanSelectIsVisible = false;
    private AuditoryNeurofeedback auditoryNeurofeedback;


    private Grid dataGrid;
    private final int NUM_TABLE_ROWS = 6;
    private final int NUM_TABLE_COLUMNS = 2;
    //private final int TABLE_WIDTH = 142;
    private int tableHeight = 0;
    private int cellHeight = 10;
    private DecimalFormat df = new DecimalFormat("#.0000");

    private final int PAD_FIVE = 5;
    private final int PAD_TWO = 2;
    private final int METRIC_DROPDOWN_W = 100;
    private final int CLASSIFIER_DROPDOWN_W = 80;

    private FocusBar focusBar;
    private float focusBarHardYAxisLimit = 1.05f; //Provide slight "breathing room" to avoid GPlot error when metric value == 1.0
    private FocusXLim xLimit = FocusXLim.TEN;
    private FocusMetric focusMetric = FocusMetric.RELAXATION;
    private FocusClassifier focusClassifier = FocusClassifier.REGRESSION;
    private FocusThreshold focusThreshold = FocusThreshold.EIGHT_TENTHS;
    private FocusColors focusColors = FocusColors.GREEN;

    private int[] exgChannels;
    private int channelCount;
    private double[][] dataArray;

    private MLModel mlModel;
    private double metricPrediction = 0d;
    private boolean predictionExceedsThreshold = false;

    private float xc, yc, wc, hc; // status circle center xy, width and height
    private int graphX, graphY, graphW, graphH;
    private final int GRAPH_PADDING = 30;
    private color cBack, cDark, cMark, cFocus, cWave, cPanel;

    List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();

    W_Focus(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

         //Add channel select dropdown to this widget
        focusChanSelect = new ChannelSelect(pApplet, this, x, y, w, navH, "FocusChannelSelect");
        focusChanSelect.activateAllButtons();
        cp5ElementsToCheck.addAll(focusChanSelect.getCp5ElementsForOverlapCheck());

        auditoryNeurofeedback = new AuditoryNeurofeedback(x + PAD_FIVE, y + PAD_FIVE, w/2 - PAD_FIVE*2, navBarHeight/2);
        cp5ElementsToCheck.add((controlP5.Controller)auditoryNeurofeedback.startStopButton);
        cp5ElementsToCheck.add((controlP5.Controller)auditoryNeurofeedback.modeButton);

        exgChannels = currentBoard.getEXGChannels();
        channelCount = currentBoard.getNumEXGChannels();
        dataArray = new double[channelCount][];

        // initialize graphics parameters
        onColorChange();
        
        //This is the protocol for setting up dropdowns.
        dropdownWidth = 60; //Override the default dropdown width for this widget
        addDropdown("focusMetricDropdown", "Metric", focusMetric.getEnumStringsAsList(), focusMetric.getIndex());
        addDropdown("focusClassifierDropdown", "Classifier", focusClassifier.getEnumStringsAsList(), focusClassifier.getIndex());
        addDropdown("focusThresholdDropdown", "Threshold", focusThreshold.getEnumStringsAsList(), focusThreshold.getIndex());
        addDropdown("focusWindowDropdown", "Window", xLimit.getEnumStringsAsList(), xLimit.getIndex());
        

        //Create data table
        dataGrid = new Grid(NUM_TABLE_ROWS, NUM_TABLE_COLUMNS, cellHeight);
        dataGrid.setTableFontAndSize(p5, 12);
        dataGrid.setDrawTableBorder(true);
        dataGrid.setString("Metric Value", 0, 0);
        dataGrid.setString("Delta (1.5-4Hz)", 1, 0);
        dataGrid.setString("Theta (4-8Hz)", 2, 0);
        dataGrid.setString("Alpha (7.5-13Hz)", 3, 0);
        dataGrid.setString("Beta (13-30Hz)", 4, 0);
        dataGrid.setString("Gamma (30-45Hz)", 5, 0);

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        //focus_cp5 = new ControlP5(ourApplet);
        //focus_cp5.setGraphics(ourApplet, 0,0);
        //focus_cp5.setAutoDraw(false);

        //create our focus graph
        updateGraphDims();
        focusBar = new FocusBar(_parent, xLimit.getValue(), focusBarHardYAxisLimit, graphX, graphY, graphW, graphH);

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

        lockElementsOnOverlapCheck(cp5ElementsToCheck);
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
            stroke(OPENBCI_DARKBLUE);
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
        auditoryNeurofeedback.draw();
        
        //Draw the graph
        focusBar.draw();

        focusChanSelect.draw();
    }

    public void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Very important to allow users to interact with objects after app resize        
        //focus_cp5.setGraphics(ourApplet, 0, 0);

        resizeTable();

        //We need to set the position of our Cp5 object after the screen is resized
        //widgetTemplateButton.setPosition(x + w/2 - widgetTemplateButton.getWidth()/2, y + h/2 - widgetTemplateButton.getHeight()/2);

        updateStatusCircle();
        updateAuditoryNeurofeedbackPosition();

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

    private void updateAuditoryNeurofeedbackPosition() {
        int extraPadding = focusChanSelect.isVisible() ? navHeight : 0;
        int subContainerMiddleX = x + w/4;
        auditoryNeurofeedback.screenResized(subContainerMiddleX, (int)(y + h/2 - navHeight + extraPadding), w/2 - PAD_FIVE*2, navBarHeight/2);
    }

    private void updateStatusCircle() {
        float upperLeftContainerW = w/2;
        float upperLeftContainerH = h/2;
        float min = min(upperLeftContainerW, upperLeftContainerH);
        xc = x + w/4;
        yc = y + h/4 - navHeight;
        wc = min * (3f/5);
        hc = wc;
    }

    private void updateGraphDims() {
        graphW = int(w - PAD_FIVE*4);
        graphH = int(h/2 - GRAPH_PADDING - PAD_FIVE*2);
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

            //Full Source Code for this method: https://github.com/brainflow-dev/brainflow/blob/c5f0ad86683e6eab556e30965befb7c93e389a3b/src/data_handler/data_handler.cpp#L1115
            Pair<double[], double[]> bands = DataFilter.get_avg_band_powers (dataArray, channelsInDataArray, currentBoard.getSampleRate(), true);
            double[] featureVector = bands.getLeft ();

            //Left array is Averages, right array is Standard Deviations. Update values using Averages.
            updateBandPowerTableValues(bands.getLeft());

            //Keep this here
            double prediction = mlModel.predict(featureVector)[0];
            //println("Concentration: " + prediction);

            //Send band power and prediction data to AuditoryNeurofeedback class
            auditoryNeurofeedback.update(bands.getLeft(), (float)prediction);
            
            return prediction;

        } catch (BrainFlowError e) {
            e.printStackTrace();
            println("Error updating focus state!");
            return -1d;
        }
    }

    private void updateBandPowerTableValues(double[] bandPowers) {
        for (int i = 0; i < bandPowers.length; i++) {
            dataGrid.setString(df.format(bandPowers[i]), 1 + i, 1);
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
        updateAuditoryNeurofeedbackPosition();
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

    public int getMetricExceedsThreshold() {
        return predictionExceedsThreshold ? 1 : 0;
    }

    public void killAuditoryFeedback() {
        auditoryNeurofeedback.killAudio();
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
    final int nPoints = 30 * 1000;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    LinkedList<Float> fifoList;
    LinkedList<Float> fifoTimeList;

    int numSeconds;
    color channelColor; //color of plot trace

    FocusBar(PApplet _parent, int xLimit, float yLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
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
        plot.setPos(x + 36 + 4 + xOffset, y); //match Accelerometer plot position with Time Series
        plot.setDim(w - 36 - 4 - xOffset, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(NUM_ACCEL_DIMS)%8]);
        plot.setXLim(-numSeconds,0); //set the horizontal scale
        plot.setYLim(0, yLimit); //change this to adjust vertical scale
        //plot.setPointSize(2);
        plot.setPointColor(0);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getYAxis().setAxisLabelText("Metric Value");
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().getAxisLabel().setOffset(float(22));
        plot.getYAxis().getAxisLabel().setOffset(float(focusBarPadding));
        plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);

        adjustTimeAxis(numSeconds);

        initArrays();

        //set the plot points for X, Y, and Z axes
        plot.addLayer("layer 1", new GPointsArray(30));
        plot.getLayer("layer 1").setLineColor(ACCEL_X_COLOR);
    }

    private void initArrays() {
        fifoList = new LinkedList<Float>();
        fifoTimeList = new LinkedList<Float>();
        for (int i = 0; i < nPoints; i++) {
            fifoList.add(0f);
            fifoTimeList.add(0f);
        }
    }

    public void update(double val) {
        updateGPlotPoints(val);
    }

    public void draw() {
        plot.beginDraw();
        plot.drawBox(); //we won't draw this eventually ...
        plot.drawGridLines(GPlot.BOTH);
        plot.drawLines(); //Draw a Line graph!
        //plot.drawPoints(); //Used to draw Points instead of Lines
        plot.drawYAxis();
        plot.drawXAxis();
        plot.getXAxis().draw();
        plot.endDraw();
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
        float timerVal = (float)millis() / 1000.0;
        fifoTimeList.removeFirst();
        fifoTimeList.addLast(timerVal);
        fifoList.removeFirst();
        fifoList.addLast((float)val);

        int stopId = 0;
        for (stopId = nPoints - 1; stopId > 0; stopId--) {
            if (timerVal - fifoTimeList.get(stopId) > numSeconds) {
                break;
            }
        }
        int size = nPoints - 1 - stopId;
        GPointsArray focusPoints = new GPointsArray(size);
        for (int i = 0; i < size; i++) {
            focusPoints.set(i, fifoTimeList.get(i + stopId) - timerVal, fifoList.get(i + stopId), "");
        }
        plot.setPoints(focusPoints, "layer 1");
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