import java.util.*; 


class W_NovaAux extends Widget {

    private int numAnalogReadBars;
    float xF, yF, wF, hF;
    float arPadding;
    // values for actual time series chart (rectangle encompassing all analogReadBars)
    float ar_x, ar_y, ar_h, ar_w;
    float plotBottomWell;
    float playbackWidgetHeight;
    int analogReadBarHeight;

    AuxReadBar[] analogReadBars;

    int[] xLimOptions = {0, 1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

    private boolean allowSpillover = false;
    private boolean visible = true;
    private boolean updating = true;

    //Initial dropdown settings
    private int arInitialVertScaleIndex = 5;
    private int arInitialHorizScaleIndex = 0;

    //Button analogModeButton;

    W_NovaAux(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Analog Read settings
        settings.arVertScaleSave = 5; //updates in VertScale_AR()
        settings.arHorizScaleSave = 0; //updates in Duration_AR()

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("VertScale_NovaAux", "Vert Scale", Arrays.asList(settings.arVertScaleArray), arInitialVertScaleIndex);
        addDropdown("Duration_NovaAux", "Window", Arrays.asList(settings.arHorizScaleArray), arInitialHorizScaleIndex);
        // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

        //set number of analog reads
        numAnalogReadBars = 2;

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        plotBottomWell = 45.0; //this appears to be an arbitrary vertical space adds GPlot leaves at bottom, I derived it through trial and error
        arPadding = 10.0;
        ar_x = xF + arPadding;
        ar_y = yF + (arPadding);
        ar_w = wF - arPadding*2;
        ar_h = hF - playbackWidgetHeight - plotBottomWell - (arPadding*2);
        analogReadBarHeight = int(ar_h/numAnalogReadBars);

        analogReadBars = new AuxReadBar[numAnalogReadBars];

        //create our channel bars and populate our analogReadBars array!
        for(int i = 0; i < numAnalogReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            AuxReadBar tempBar = new AuxReadBar(_parent, i+1, int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
            analogReadBars[i] = tempBar;
            analogReadBars[i].adjustVertScale(yLimOptions[arInitialVertScaleIndex]);
            //sync horiz axis to Time Series by default
            analogReadBars[i].adjustTimeAxis(20);
        }
    }

    public boolean isVisible() {
        return visible;
    }
    public boolean isUpdating() {
        return updating;
    }

    public int getNumAnalogReads() {
        return numAnalogReadBars;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
    }
    public void setUpdating(boolean _updating) {
        updating = _updating;
    }

    void update() {
        if(visible && updating) {
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < numAnalogReadBars; i++) {
                analogReadBars[i].update();
            }

        }
    }

    void draw() {
        if(visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars 
            for(int i = 0; i < numAnalogReadBars; i++) {
                analogReadBars[i].draw();
            }
            popStyle();
        }
    }

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        ar_x = xF + arPadding;
        ar_y = yF + (arPadding);
        ar_w = wF - arPadding*2;
        ar_h = hF - playbackWidgetHeight - plotBottomWell - (arPadding*2);
        analogReadBarHeight = int(ar_h/numAnalogReadBars);

        for(int i = 0; i < numAnalogReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            analogReadBars[i].screenResized(int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //bar x, bar y, bar w, bar h
        }

        // analogModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void VertScale_NovaAux(int n) {
    for(int i = 0; i < w_novaAux.numAnalogReadBars; i++) {
            w_novaAux.analogReadBars[i].adjustVertScale(w_novaAux.yLimOptions[n]);
    }
}

//triggered when there is an event in the LogLin Dropdown
void Duration_NovaAux(int n) {
    // println("adjust duration to: " + w_analogRead.analogReadBars[i].adjustTimeAxis(n));
    //set analog read x axis to the duration selected from dropdown
    //settings.arHorizScaleSave = n;

    //Sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
    for(int i = 0; i < w_novaAux.numAnalogReadBars; i++) {
        if (n == 0) {
            w_novaAux.analogReadBars[i].adjustTimeAxis(w_novaAux.xLimOptions[settings.tsHorizScaleSave]);
        } else {
            w_novaAux.analogReadBars[i].adjustTimeAxis(w_novaAux.xLimOptions[n]);
        }
    }
    //closeAllDropdowns();
}

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class AuxReadBar{

    int auxValuesPosition;
    String analogInputString;
    int x, y, w, h;
    boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    GPointsArray auxReadPoints;
    int nPoints;
    int numSeconds;
    float timeBetweenPoints;
    int bufferSize;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
    int autoScaleYLim = 0;

    TextBox analogValue;
    TextBox analogPin;

    boolean drawAnalogValue;
    int lastProcessedDataPacketInd = 0;

    double[] auxReadData;

    // todo board may have multiple eda/ppg sensors and EDA/PPGCapableBoard return 2d array due to it
    // this widget should also operate on 2d arrays. Temporary get only the first row from 2d array
    private FixedStack<Double> edaValues = new FixedStack<Double>();
    private FixedStack<Double> ppgValues = new FixedStack<Double>();
    private EDACapableBoard edaBoard;
    private PPGCapableBoard ppgBoard;

    AuxReadBar(PApplet _parent, int auxChanNum, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width

        auxValuesPosition = auxChanNum;

        analogInputString = str(auxValuesPosition);
        isOn = true;

        x = _x;
        y = _y;
        w = _w;
        h = _h;

        numSeconds = 20;
        plot = new GPlot(_parent);
        plot.setPos(x + 36 + 4, y);
        plot.setDim(w - 36 - 4, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(auxValuesPosition)%8]);
        plot.setXLim(-3.2,-2.9);
        plot.setYLim(-200,200);
        plot.setPointSize(2);
        plot.setPointColor(0);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().setAxisLabelText("Time (s)");

        nPoints = nPointsBasedOnDataSource(); //max duration 20s
        bufferSize = nPoints;
        auxReadData = new double[nPoints];
        edaValues.setSize(nPoints);
        ppgValues.setSize(nPoints);
        Double initialValue =  Double.valueOf(0.0);
        edaValues.fill (initialValue);
        ppgValues.fill (initialValue);

        auxReadPoints = new GPointsArray(nPoints);
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        for (int i = 0; i < bufferSize; i++) {
            float time = -(float)numSeconds + (float)i*timeBetweenPoints;
            float analog_value = 0.0; //0.0 for all points to start
            GPoint tempPoint = new GPoint(time, analog_value);
            auxReadPoints.set(i, tempPoint);
        }

        plot.setPoints(auxReadPoints); //set the plot with 0.0 for all auxReadPoints to start

        analogValue = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
        analogValue.textColor = color(bgColor);
        analogValue.alignH = RIGHT;
        // analogValue.alignV = TOP;
        analogValue.drawBackground = true;
        analogValue.backgroundColor = color(255,255,255,125);

        analogPin = new TextBox("Aux" + analogInputString, x+3, y + h);
        analogPin.textColor = color(bgColor);
        analogPin.alignH = CENTER;

        drawAnalogValue = true;
        // todo add check that current board implements these interfaces before casting
        // otherwise should throw and exception and maybe popup message
        edaBoard = (EDACapableBoard) currentBoard;
        ppgBoard = (PPGCapableBoard) currentBoard;
    }

    void update() {
        //update the voltage value text string
        float val = 0f;
        if ((edaBoard == null) || (ppgBoard == null)) {
            System.out.println("Board is not ready yet");
            return;
        }

        double[][] edaData = edaBoard.getEDAValues();
        double[][] ppgData = ppgBoard.getPPGValues();

        // ignore all sensors except the first one temporary
        for (int i = 0; i < edaData[0].length; i++) {
            // ppg and eda sizes are the same
            edaValues.push(edaData[0][i]);
            ppgValues.push(ppgData[0][i]);
        }
        
        if (edaData[0].length > 0) {
            //Fetch the last value in the buffer to display on screen
            if (auxValuesPosition == 1) {
                val = (float) edaData[0][edaData[0].length-1];
            } else {
                val = (float) ppgData[0][ppgData[0].length-1];
            }
        }
        analogValue.string = String.format(getFmt(val),val);

        // update data in plot
        if (isRunning) {
            updatePlotPoints();
        }
        
        if(isAutoscale) {
            autoScale();
        }
    }

    private String getFmt(float val) {
        String fmt;
            if (val > 100.0f) {
                fmt = "%.0f";
            } else if (val > 10.0f) {
                fmt = "%.1f";
            } else {
                fmt = "%.2f";
            }
            return fmt;
    }

    void updatePlotPoints() {
        Enumeration enu = null;
        // its bad we can rewrite it wo auxValuesPosition
        if (auxValuesPosition == 1) {
            enu = edaValues.elements(); 
        } else {
            enu = ppgValues.elements();
        }

        int id = 0;
        while (enu.hasMoreElements()) { // there are exactly nPoints elements
            float timey = -(float)numSeconds + (float)id * timeBetweenPoints;
            //System.out.println("time " + timey);
            Double val = (Double)enu.nextElement();
            double rawVal = val.doubleValue();
            float value = (float)rawVal;
            GPoint tempPoint = new GPoint(timey, value);
            auxReadPoints.set(id, tempPoint);
            id++;
        }
        plot.setPoints(auxReadPoints);
    }

    void draw() {
        pushStyle();

        //draw plot
        stroke(31,69,110, 50);
        fill(color(125,30,12,30));

        rect(x + 36 + 4, y, w - 36 - 4, h);

        plot.beginDraw();
        plot.drawBox(); // we won't draw this eventually ...
        plot.drawGridLines(0);
        plot.drawLines();
        
        if(auxValuesPosition == 2) { //only draw the x axis label on the bottom channel bar
            plot.drawXAxis();
            plot.getXAxis().draw();
        }

        plot.endDraw();

        if(drawAnalogValue) {
            analogValue.draw();
            analogPin.draw();
        }

        popStyle();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * getSampleRateSafe();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();

        auxReadPoints = new GPointsArray(nPoints);
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }
        else {
            plot.getXAxis().setNTicks(10);
        }
        if (w_analogRead != null) {
            if(w_analogRead.isUpdating()) {
                updatePlotPoints();
            }
        }
    }

    void adjustVertScale(int _vertScaleValue) {
        if(_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
        }
    }

    void autoScale() {
        autoScaleYLim = 0;
        if (auxReadPoints.getNPoints() > 0) {
            for(int i = 0; i < nPoints; i++) {
                if(int(abs(auxReadPoints.getY(i))) > autoScaleYLim) {
                    autoScaleYLim = int(abs(auxReadPoints.getY(i)));
                }
            }
        }
        plot.setYLim(-autoScaleYLim, autoScaleYLim);
    }

    void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        plot.setPos(x + 36 + 4, y);
        plot.setDim(w - 36 - 4, h);

        analogValue.x = x + 36 + 4 + (w - 36 - 4) - 2;
        analogValue.y = y + h;

        analogPin.x = x + 14;
        analogPin.y = y + int(h/2.0) + 7;
    }
};
