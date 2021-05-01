
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

    private final int padding_5 = 5;

    private FocusBar focusBar;
    private float focusBarHardYAxisLimit = 1f;
    FocusXLim xLimit = FocusXLim.TWENTY;
    FocusMetric focusMetric = FocusMetric.RELAXATION;
    FocusClassifier focusClassifier = FocusClassifier.REGRESSION;
    FocusThreshold focusThreshold = FocusThreshold.EIGHT_TENTHS;
    private FocusColors focusColors = FocusColors.GREEN;

    MLModel mlModel;
    private double metricPrediction = 0d;
    private boolean predictionExceedsThreshold = false;

    private float xc, yc, wc, hc; // crystal ball center xy, width and height
    private int graph_x, graph_y, graph_w, graph_h;
    private int graph_pad = 30;
    private color cBack, cDark, cMark, cFocus, cWave, cPanel;

    W_Focus(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

         //Add channel select dropdown to this widget
        focusChanSelect = new ChannelSelect(pApplet, this, x, y, w, navH, "Focus_Channels");
        focusChanSelect.activateAllButtons();

        // initialize graphics parameters
        onColorChange();
        
        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("focusWindowDropdown", "Window", FocusXLim.getEnumStringsAsList(), xLimit.getIndex());
        addDropdown("focusMetricDropdown", "Metric", FocusMetric.getEnumStringsAsList(), focusMetric.getIndex());
        addDropdown("focusClassifierDropdown", "Classifier", FocusClassifier.getEnumStringsAsList(), focusClassifier.getIndex());
        addDropdown("focusThresholdDropdown", "Threshold", FocusThreshold.getEnumStringsAsList(), focusThreshold.getIndex());

        //Create data table
        dataGrid = new Grid(numTableRows, numTableColumns, cellHeight);
        dataGrid.setTableFontAndSize(p6, 10);
        dataGrid.setDrawTableBorder(true);
        dataGrid.setString("Metric Value", 0, 0);

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        focus_cp5 = new ControlP5(ourApplet);
        focus_cp5.setGraphics(ourApplet, 0,0);
        focus_cp5.setAutoDraw(false);

        //createWidgetTemplateButton();

        //create our focus graph
        update_graph_dims();
        focusBar = new FocusBar(_parent, focusBarHardYAxisLimit, graph_x, graph_y, graph_w, graph_h);

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
            predictionExceedsThreshold = metricPrediction > focusThreshold.getValue();
            focusBar.update(metricPrediction);
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
        //focus_cp5.draw();
        
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

        update_crystalball_dims();

        update_graph_dims();
        focusBar.screenResized(graph_x, graph_y, graph_w, graph_h);
        focusChanSelect.screenResized(pApplet);
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
        int ty = y + padding_5 + extraPadding;
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

    //Returns a metric value from 0. to 1. When there is an error, returns -1.
    private double updateFocusState() {
        // todo move concentration.prepare() and variable initialization outside from this method, it should be called only once!
        try {
            int window_size = currentBoard.getSampleRate() * xLimit.getValue();
            // getData in GUI returns data in shape ndatapoints x nchannels, in BrainFlow its transposed
            List<double[]> currentData = currentBoard.getData(window_size);
            if (currentData.size() != window_size || focusChanSelect.activeChan.size() <= 0) {
                return -1.0;
            }
            int[] exgChannels = currentBoard.getEXGChannels();
            int channelCount = currentBoard.getNumEXGChannels();
            int[] channelsInDataArray = new int[channelCount];
            /*
            for (int j = 0; j < bpChanSelect.activeChan.size(); j++) {
                int chan = bpChanSelect.activeChan.get(j);
                */

            int activeChanCounter = 0;
            for (int i = 0; (i < channelCount) && (activeChanCounter < focusChanSelect.activeChan.size()); i++) // use this line to use all channels
            {
                int chan = focusChanSelect.activeChan.get(activeChanCounter);
                if (i == chan) {
                    channelsInDataArray[i] = i;
                    activeChanCounter++;
                }
            }
            double[][] data = new double[channelCount][];
            // todo preallocate this array outside from this method
            for (int i = 0; i < channelCount; i++) {
                data[i] = new double[window_size];
                for (int j = 0; j < currentData.size(); j++) {
                    data[i][j] = currentData.get(j)[exgChannels[i]];
                }
            }

            Pair<double[], double[]> bands = DataFilter.get_avg_band_powers (data, channelsInDataArray, currentBoard.getSampleRate(), true);
            double[] feature_vector = ArrayUtils.addAll (bands.getLeft (), bands.getRight ());

            //Keep this here
            double prediction = mlModel.predict(feature_vector);
            //println("Concentration: " + prediction);
            dataGrid.setString(df.format(prediction), 0, 1);
            
            return prediction;

        } catch (BrainFlowError e) {
            e.printStackTrace();
            println("Error updating focus state!");
            return -1d;
        }
    }

    private void drawStatusCircle() {
        color _fill;
        color _stroke;
        StringBuilder sb = new StringBuilder("");
        if (predictionExceedsThreshold) {
            _fill = cFocus;
            _stroke = cFocus;
        } else {
            _fill = cDark;
            _stroke = cDark;
            sb.append("Not ");
        }
        sb.append(focusMetric.getIdealStateString());
        //Draw status graphic
        pushStyle();
        noStroke();
        fill(_fill);
        stroke(_stroke);
        ellipseMode(CENTER);
        ellipse(xc, yc, wc, hc);
        noStroke();
        textAlign(CENTER);
        text(sb.toString(), xc, yc + hc/2 + 16);
        popStyle();
    }

    private void initBrainFlowMetric() {
        BrainFlowModelParams model_params = new BrainFlowModelParams(
                focusMetric.getMetric().get_code(),
                focusClassifier.getClassifier().get_code()
                );
        mlModel = new MLModel (model_params);
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
    LinkedList<Float> fifo_list;
    GPointsArray focusPoints;

    int nPoints;
    int numSeconds = FocusXLim.TWENTY.getValue(); //default to 20 seconds
    float timeBetweenPoints;
    float graph_timer;
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
        fifo_list = new LinkedList<Float>();
        for (int i = 0; i < focusTimeArray.length; i++) {
            focusTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
            fifo_list.add(0f);
        }
        float[] floatArray = ArrayUtils.toPrimitive(fifo_list.toArray(new Float[0]), 0.0F);
        focusPoints = new GPointsArray(focusTimeArray, floatArray);
    }

    //Used to update the accelerometerBar class
    public void update(double val) {
        updateGPlotPoints(val);
        if (isAutoscale) {
            //autoScale();
        }
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
        
        //if (graph_timer + timeBetweenPoints < millis()) {
            graph_timer = millis();
            fifo_list.removeFirst();
            fifo_list.add((float)val);

            for (int i=0; i < nPoints; i++) {
                focusPoints.set(i, focusTimeArray[i], fifo_list.get(i), "");
            }

            plot.setPoints(focusPoints, "layer 1");
        //}
    }

    /*
    void adjustVertScale(int _vertScaleValue) {
        if (_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
        }
    }
    */

    private void autoScale() {
        float[] minMaxVals = minMax(focusPoints);
        plot.setYLim(minMaxVals[0] - autoScaleSpacing, minMaxVals[1] + autoScaleSpacing);
    }

    private float[] minMax(GPointsArray arr) {
        float[] minMaxVals = {0.f, 0.f};
        for (int i = 0; i < arr.getNPoints(); i++) { //go through the XYZ GPpointArrays for on-screen values
            float val = arr.getY(i);
            minMaxVals[0] = min(minMaxVals[0], val); //make room to see
            minMaxVals[1] = max(minMaxVals[1], val);
        }
        return minMaxVals;
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