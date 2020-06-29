import java.util.*;

class W_NovaAux extends Widget {

    public int numAuxReadBars;
    private float xF, yF, wF, hF;
    private float arPadding;
    // values for actual time series chart (rectangle encompassing all analogReadBars)
    private float ar_x, ar_y, ar_h, ar_w;
    private float plotBottomWell;
    private float playbackWidgetHeight;
    private int analogReadBarHeight;

    private AuxReadBar[] analogReadBars;

    public int[] xLimOptions = {1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    public int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV
    //Used to set text in dropdown menus when loading Analog Read settings
    private String[] vertScaleOptions = {"Auto", "50", "100", "200", "400", "1000", "10000"};
    private String[] horizScaleOptions = {"1 sec", "3 sec", "5 sec", "10 sec", "20 sec"};
    private boolean allowSpillover = false;
    private boolean visible = true;

    //Initial dropdown settings
    private int arInitialVertScaleIndex = 5;
    private int arInitialHorizScaleIndex = 2;

    W_NovaAux(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("VertScale_NovaAux", "Vert Scale", Arrays.asList(vertScaleOptions), arInitialVertScaleIndex);
        addDropdown("Duration_NovaAux", "Window", Arrays.asList(horizScaleOptions), arInitialHorizScaleIndex);

        //set number of analog reads
        numAuxReadBars = 4;

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
        analogReadBarHeight = int(ar_h/numAuxReadBars);

        analogReadBars = new AuxReadBar[numAuxReadBars];

        //create our channel bars and populate our analogReadBars array!
        for(int i = 0; i < numAuxReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            AuxReadBar tempBar = new AuxReadBar(_parent, i+1, int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //int _channelNumber, totalChannels, int _x, int _y, int _w, int _h
            analogReadBars[i] = tempBar;
            analogReadBars[i].adjustVertScale(yLimOptions[arInitialVertScaleIndex]);
            analogReadBars[i].adjustTimeAxis(xLimOptions[arInitialHorizScaleIndex]);
        }
    }

    public boolean isVisible() {
        return visible;
    }

    public int getNumAnalogReads() {
        return numAuxReadBars;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
    }

    void update() {
        if(visible) {
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < numAuxReadBars; i++) {
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
            for(int i = 0; i < numAuxReadBars; i++) {
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
        analogReadBarHeight = int(ar_h/numAuxReadBars);

        for(int i = 0; i < numAuxReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            analogReadBars[i].screenResized(int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //bar x, bar y, bar w, bar h
        }
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void VertScale_NovaAux(int n) {
    for(int i = 0; i < w_novaAux.numAuxReadBars; i++) {
            w_novaAux.analogReadBars[i].adjustVertScale(w_novaAux.yLimOptions[n]);
    }
}

//triggered when there is an event in the LogLin Dropdown
void Duration_NovaAux(int n) {
    //set analog read x axis to the duration selected from dropdown
    for(int i = 0; i < w_novaAux.numAuxReadBars; i++) {
        w_novaAux.analogReadBars[i].adjustTimeAxis(w_novaAux.xLimOptions[n]);
    }
}

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class AuxReadBar{

    private int auxValuesPosition;
    private String auxChanLabel;
    private int x, y, w, h;
    private boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

    private GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    private GPointsArray auxReadPoints;
    private int nPoints;
    private int numSeconds;
    private float timeBetweenPoints;

    private color channelColor; //color of plot trace

    private boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
    private int autoScaleYLim = 0;

    private TextBox analogValue;
    private TextBox analogPin;

    private boolean drawAnalogValue;
    private int lastProcessedDataPacketInd = 0;

    // todo board may have multiple eda/ppg sensors and EDA/PPGCapableBoard return 2d array due to it
    // this widget should also operate on 2d arrays. Temporary get only the first row from 2d array
    private EDACapableBoard edaBoard;
    private PPGCapableBoard ppgBoard;
    private BatteryInfoCapableBoard batteryBoard;

    AuxReadBar(PApplet _parent, int auxChanNum, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width

        auxValuesPosition = auxChanNum;

        if (auxChanNum == 1 || auxChanNum == 2) {
            auxChanLabel = "PPG_" + auxChanNum; 
        } else if (auxChanNum == 3) {
            auxChanLabel = "EDA";
        } else {
            auxChanLabel = "Battery";
        }
        
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

        initArrays();

        analogValue = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
        analogValue.textColor = color(bgColor);
        analogValue.alignH = RIGHT;
        // analogValue.alignV = TOP;
        analogValue.drawBackground = true;
        analogValue.backgroundColor = color(255,255,255,125);

        analogPin = new TextBox(auxChanLabel, x+3, y + h);
        analogPin.textColor = color(bgColor);
        analogPin.alignH = CENTER;

        drawAnalogValue = true;
        // todo add check that current board implements these interfaces before casting
        // otherwise should throw and exception and maybe popup message
        edaBoard = (EDACapableBoard) currentBoard;
        ppgBoard = (PPGCapableBoard) currentBoard;
        batteryBoard = (BatteryInfoCapableBoard) currentBoard;
    }

    void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;
        auxReadPoints = new GPointsArray(nPoints);

        for (int i = 0; i < nPoints; i++) {
            float time = calcTimeAxis(i);
            float analog_value = 0.0; //0.0 for all points to start
            auxReadPoints.set(i, time, analog_value, "");
        }

        plot.setPoints(auxReadPoints); //set the plot with 0.0 for all auxReadPoints to start
    }

    void update() {
        // early out if unactive
        if (auxValuesPosition == 1 || auxValuesPosition == 2) {
            if (!ppgBoard.isPPGActive()) {
                return;
            }
        } else if (auxValuesPosition == 3) {
            if (!edaBoard.isEDAActive()) {
                return;
            }
        }

        // update data in plot
        updatePlotPoints();
        
        if(isAutoscale) {
            autoScale();
        }

        //Fetch the last value in the buffer to display on screen
        float val = auxReadPoints.getY(nPoints-1);
        analogValue.string = String.format(getFmt(val),val);
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

    float calcTimeAxis(int sampleIndex) {
        return -(float)numSeconds + (float)sampleIndex * timeBetweenPoints;
    }

    void updatePlotPoints() {
        List<double[]> allData = currentBoard.getData(nPoints);
        int[] channels = new int[2];
        int channelNumber = 0;

        if (auxValuesPosition == 1 || auxValuesPosition == 2) {
            channels = ppgBoard.getPPGChannels(); 
            //channelNumber = auxValuesPosition - 1;
        } else if (auxValuesPosition == 3) {
            channels = edaBoard.getEDAChannels(); 
        } else {
            channels[0] = batteryBoard.getBatteryInfo();
        }

        for (int i=0; i < nPoints; i++) {
            float timey = calcTimeAxis(i);
            float value = (float)allData.get(i)[channels[channelNumber]];
            auxReadPoints.set(i, timey, value, "");
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
        
        if(auxValuesPosition == w_novaAux.numAuxReadBars) { //only draw the x axis label on the bottom channel bar
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
        return numSeconds * currentBoard.getSampleRate();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        initArrays();

        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }
        else {
            plot.getXAxis().setNTicks(10);
        }
    }

    void adjustVertScale(int _vertScaleValue) {
        if(_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(0, _vertScaleValue); //Plot Y values >= 0
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
        plot.setYLim(0, autoScaleYLim); //Plot Y values >= 0
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
