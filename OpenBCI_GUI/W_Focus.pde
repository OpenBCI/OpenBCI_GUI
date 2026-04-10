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

class W_Focus extends WidgetWithSettings {

    private ExGChannelSelect focusChanSelect;
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

    private FifoChannelBar focusBar;
    private float focusBarHardYAxisLimit = 1.05f; //Provide slight "breathing room" to avoid GPlot error when metric value == 1.0

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

    List<controlP5.Controller> cp5ElementsToCheck;

    W_Focus() {
        super();
        widgetTitle = "Focus";
        
        auditoryNeurofeedback = new AuditoryNeurofeedback(x + PAD_FIVE, y + PAD_FIVE, w/2 - PAD_FIVE*2, navBarHeight/2);
        cp5ElementsToCheck.add((controlP5.Controller)auditoryNeurofeedback.startStopButton);
        cp5ElementsToCheck.add((controlP5.Controller)auditoryNeurofeedback.modeButton);

        exgChannels = currentBoard.getEXGChannels();
        channelCount = currentBoard.getNumEXGChannels();
        dataArray = new double[channelCount][];

        // initialize graphics parameters
        onColorChange();

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

        //create our focus graph
        updateGraphDims();
        int xLimitValue = widgetSettings.get(FocusXLim.class).getValue();
        focusBar = new FifoChannelBar(ourApplet, "Metric Value", xLimitValue, focusBarHardYAxisLimit, graphX, graphY, graphW, graphH, ACCEL_X_COLOR, FocusXLim.TWENTY.getValue());
        
        initBrainFlowMetric();
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();

        widgetSettings.set(FocusXLim.class, FocusXLim.TEN)
                .set(FocusMetric.class, FocusMetric.RELAXATION)
                .set(FocusClassifier.class, FocusClassifier.REGRESSION)
                .set(FocusThreshold.class, FocusThreshold.EIGHT_TENTHS)
                .set(FocusColors.class, FocusColors.GREEN);
        
        dropdownWidth = 60; //Override the default dropdown width for this widget
        initDropdown(FocusMetric.class, "focusMetricDropdown", "Metric");
        initDropdown(FocusThreshold.class, "focusThresholdDropdown", "Threshold");
        initDropdown(FocusXLim.class, "focusWindowDropdown", "Window");

        //Add channel select dropdown to this widget
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        focusChanSelect = new ExGChannelSelect(ourApplet, x, y, w, navH);
        focusChanSelect.activateAllButtons();
        saveActiveChannels(focusChanSelect.getActiveChannels());
        cp5ElementsToCheck.addAll(focusChanSelect.getCp5ElementsForOverlapCheck());

        widgetSettings.saveDefaults();
    }

    @Override
    protected void applySettings() {
        //Apply settings to dropdowns
        updateDropdownLabel(FocusXLim.class, "focusWindowDropdown");
        updateDropdownLabel(FocusMetric.class, "focusMetricDropdown");
        updateDropdownLabel(FocusThreshold.class, "focusThresholdDropdown");
        applyHorizontalScale();
        initBrainFlowMetric();

        //Apply settings to channel select dropdown
        applyActiveChannels(focusChanSelect);
    }

    @Override
    protected void updateChannelSettings() {
        //Save active channels to settings
        if (focusChanSelect != null) {
            saveActiveChannels(focusChanSelect.getActiveChannels());
        }
    }

    public void update() {
        super.update();

        //Update channel checkboxes and active channels
        focusChanSelect.update(x, y, w);

        //Flex the Gplot graph when channel select dropdown is open/closed
        if (focusChanSelect.isVisible() != prevChanSelectIsVisible) {
            channelSelectFlexWidgetUI();
            prevChanSelectIsVisible = focusChanSelect.isVisible();
        }

        if (currentBoard.isStreaming()) {
            dataGrid.setString(df.format(metricPrediction), 0, 1);
            focusBar.update(metricPrediction);
        }

        lockElementsOnOverlapCheck(cp5ElementsToCheck);
    }

    public void draw() {
        super.draw();
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

        auditoryNeurofeedback.draw();
        
        //Draw the graph
        focusBar.draw();

        focusChanSelect.draw();
    }

    public void screenResized() {
        super.screenResized();

        resizeTable();

        updateStatusCircle();
        updateAuditoryNeurofeedbackPosition();

        updateGraphDims();
        focusBar.screenResized(graphX, graphY, graphW, graphH);
        focusChanSelect.screenResized(ourApplet);

        //Custom resize these dropdowns due to longer text strings as options
        cp5_widget.get(ScrollableList.class, "focusMetricDropdown").setWidth(METRIC_DROPDOWN_W);
        cp5_widget.get(ScrollableList.class, "focusMetricDropdown").setPosition(
            x0 + w0 - (dropdownWidth*2) - METRIC_DROPDOWN_W - (PAD_TWO*3), 
            navH + y0 + PAD_TWO
            );
    }

    void mousePressed() {
        super.mousePressed();
        focusChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
    }

    private void resizeTable() {
        int extraPadding = focusChanSelect.isVisible() ? NAV_HEIGHT : 0;
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
        int extraPadding = focusChanSelect.isVisible() ? NAV_HEIGHT : 0;
        int subContainerMiddleX = x + w/4;
        auditoryNeurofeedback.screenResized(subContainerMiddleX, (int)(y + h/2 - NAV_HEIGHT + extraPadding), w/2 - PAD_FIVE*2, navBarHeight/2);
    }

    private void updateStatusCircle() {
        float upperLeftContainerW = w/2;
        float upperLeftContainerH = h/2;
        float min = min(upperLeftContainerW, upperLeftContainerH);
        xc = x + w/4;
        yc = y + h/4 - NAV_HEIGHT;
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
            int xLimitValue = widgetSettings.get(FocusXLim.class).getValue();
            int windowSize = currentBoard.getSampleRate() * xLimitValue;
            // getData in GUI returns data in shape ndatapoints x nchannels, in BrainFlow its transposed
            List<double[]> currentData = currentBoard.getData(windowSize);

            if (currentData.size() != windowSize || focusChanSelect.getActiveChannels().size() <= 0) {
                return -1.0;
            }

            for (int i = 0; i < channelCount; i++) {
                dataArray[i] = new double[windowSize];
                for (int j = 0; j < currentData.size(); j++) {
                    dataArray[i][j] = currentData.get(j)[exgChannels[i]];
                }
            }

            int[] channelsInDataArray = ArrayUtils.toPrimitive(
                    focusChanSelect.getActiveChannels().toArray(
                        new Integer[focusChanSelect.getActiveChannels().size()]
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
        FocusMetric focusMetric = widgetSettings.get(FocusMetric.class);
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
        if (mlModel != null) {
            endSession();
        }
        FocusMetric focusMetric = widgetSettings.get(FocusMetric.class);
        FocusClassifier focusClassifier = widgetSettings.get(FocusClassifier.class);
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
        FocusColors focusColors = widgetSettings.get(FocusColors.class);
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
        focusBar.setPlotPositionAndOuterDimensions(focusChanSelect.isVisible());
        int factor = focusChanSelect.isVisible() ? 1 : -1;
        yc += NAV_HEIGHT * factor;
        resizeTable();
        updateAuditoryNeurofeedbackPosition();
    }

    public void setFocusHorizontalScale(int n) {
        widgetSettings.setByIndex(FocusXLim.class, n);
        applyHorizontalScale();
    }

    public void setMetric(int n) {
        widgetSettings.setByIndex(FocusMetric.class, n);
        initBrainFlowMetric();
    }

    public void setClassifier(int n) {
        widgetSettings.setByIndex(FocusClassifier.class, n);
        initBrainFlowMetric();
    }

    private void applyHorizontalScale() {
        int windowValue = widgetSettings.get(FocusXLim.class).getValue();
        focusBar.adjustTimeAxis(windowValue);
    }

    public void setThreshold(int n) {
        widgetSettings.setByIndex(FocusThreshold.class, n);
    }

    public int getMetricExceedsThreshold() {
        return predictionExceedsThreshold ? 1 : 0;
    }

    public void killAuditoryFeedback() {
        auditoryNeurofeedback.killAudio();
    }

    //Called in DataProcessing.pde to update data even if widget is closed
    public void updateFocusWidgetData() {
        metricPrediction = updateFocusState();
        float focusThresholdValue = widgetSettings.get(FocusThreshold.class).getValue();
        predictionExceedsThreshold = metricPrediction > focusThresholdValue;
    }

    public void clear() {
        focusBar.clear();
        metricPrediction = 0d;
        dataGrid.setString(df.format(metricPrediction), 0, 1);
        focusBar.update(metricPrediction);
    }
};

//The following global functions are used by the Focus widget dropdowns. This method is the least amount of code.
public void focusWindowDropdown(int n) {
    ((W_Focus) widgetManager.getWidget("W_Focus")).setFocusHorizontalScale(n);
}

public void focusMetricDropdown(int n) {
    ((W_Focus) widgetManager.getWidget("W_Focus")).setMetric(n);
}

public void focusThresholdDropdown(int n) {
    ((W_Focus) widgetManager.getWidget("W_Focus")).setThreshold(n);
}
