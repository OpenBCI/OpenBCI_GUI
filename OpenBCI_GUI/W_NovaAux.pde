import java.util.*;

class W_NovaAux extends Widget {
    private EDACapableBoard edaBoard;
    private PPGCapableBoard ppgBoard;
    private BatteryInfoCapableBoard batteryBoard;

    private int numAuxReadBars = 3;
    private float xF, yF, wF, hF;
    private float arPadding;
    private float ar_x, ar_y, ar_h, ar_w; // values for rectangle encompassing all auxReadBars
    private float plotBottomWell;
    private int channelBarHeight;
    private int batteryMeterH = 24;

    private PPGReadBar ppgReadBar1;
    private PPGReadBar ppgReadBar2;
    private EDAReadBar edaReadBar;
    private BatteryMeter batteryMeter;

    public int[] xLimOptions = {1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    public int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV
    private String[] vertScaleOptions = {"Auto", "50", "100", "200", "400", "1000", "10000"};
    private String[] horizScaleOptions = {"1 sec", "3 sec", "5 sec", "10 sec", "20 sec"};
    private boolean allowSpillover = false;
    private boolean visible = true;

    //Initial dropdown settings
    private int naInitialVertScaleIndex = 0;
    private int naInitialHorizScaleIndex = 2;

    W_NovaAux(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        // todo add check that current board implements these interfaces before casting
        // otherwise should throw and exception and maybe popup message
        edaBoard = (EDACapableBoard) currentBoard;
        ppgBoard = (PPGCapableBoard) currentBoard;
        batteryBoard = (BatteryInfoCapableBoard) currentBoard;

        addDropdown("VertScale_NovaAux", "Vert Scale", Arrays.asList(vertScaleOptions), naInitialVertScaleIndex);
        addDropdown("Duration_NovaAux", "Window", Arrays.asList(horizScaleOptions), naInitialHorizScaleIndex);

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        plotBottomWell = 40.0; // Allow space at the bottom for X axis and X axis label
        arPadding = 10.0;
        ar_x = xF + arPadding;
        ar_y = yF + (arPadding*2) + batteryMeterH;
        ar_w = wF - arPadding*2;
        ar_h = hF - plotBottomWell - (arPadding*2);
        channelBarHeight = (int)(ar_h/numAuxReadBars);
        
        batteryMeter = new BatteryMeter(_parent, batteryBoard, "Battery", int(xF), int(yF), int(wF), batteryMeterH, int(arPadding));

        int counter = 0;
        ppgReadBar1 = new PPGReadBar(_parent, counter+1, ppgBoard, 0, "PPG_1", false, int(ar_x), int(ar_y) + counter*(channelBarHeight), int(ar_w), channelBarHeight, plotBottomWell);
        counter++;
        ppgReadBar2 = new PPGReadBar(_parent, counter+1, ppgBoard, 1, "PPG_2", false, int(ar_x), int(ar_y) + counter*(channelBarHeight), int(ar_w), channelBarHeight, plotBottomWell);
        counter++;
        edaReadBar = new EDAReadBar(_parent, counter+1, edaBoard, "EDA", true, int(ar_x), int(ar_y) + counter*(channelBarHeight), int(ar_w), channelBarHeight, plotBottomWell);

        adjustTimeAxisAllPlots(xLimOptions[naInitialHorizScaleIndex]);
        adjustVertScaleAllPlots(yLimOptions[naInitialVertScaleIndex]);
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
    }

    public void update() {
        if(visible) {
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
            batteryMeter.update();
            //Feed new data into plots
            ppgReadBar1.update();
            ppgReadBar2.update();
            edaReadBar.update();
        }
    }

    public void draw() {
        if(visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)
            batteryMeter.draw();
            ppgReadBar1.draw();
            ppgReadBar2.draw();
            edaReadBar.draw();
        }
    }

    public void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        ar_x = xF + arPadding;
        ar_y = yF + (arPadding*2) + batteryMeterH;
        ar_w = wF - arPadding*2;
        ar_h = hF - plotBottomWell - (arPadding*3) - batteryMeterH;
        channelBarHeight = (int)(ar_h/numAuxReadBars);

        batteryMeter.screenResized(int(xF), int(yF), int(wF), batteryMeterH);

        int counter = 0;
        ppgReadBar1.screenResized(int(ar_x), int(ar_y) + counter*(channelBarHeight), int(ar_w), channelBarHeight);
        counter++;
        ppgReadBar2.screenResized(int(ar_x), int(ar_y) + counter*(channelBarHeight), int(ar_w), channelBarHeight);
        counter++;
        edaReadBar.screenResized(int(ar_x), int(ar_y) + counter*(channelBarHeight), int(ar_w), channelBarHeight);
    }

    public void adjustTimeAxisAllPlots(int _newTimeSize) {
        ppgReadBar1.adjustTimeAxis(_newTimeSize);
        ppgReadBar2.adjustTimeAxis(_newTimeSize);
        edaReadBar.adjustTimeAxis(_newTimeSize);
    }

    public void adjustVertScaleAllPlots(int _vertScaleValue) {
        ppgReadBar1.adjustVertScale(_vertScaleValue);
        ppgReadBar2.adjustVertScale(_vertScaleValue);
        edaReadBar.adjustVertScale(_vertScaleValue);
    }
};

//triggered when there is an event in the LogLin Dropdown
void Duration_NovaAux(int n) {
    w_novaAux.adjustTimeAxisAllPlots(w_novaAux.xLimOptions[n]);
}

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//^^^not true. we can do this in the class above with a CallbackListener
void VertScale_NovaAux(int n) {
    w_novaAux.adjustVertScaleAllPlots(w_novaAux.yLimOptions[n]);
}

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
abstract class AuxReadBar{

    private int auxValuesPosition;
    private String auxChanLabel;
    private boolean isBottomBar = false;
    private float plotBottomWellH;
    private int channel = 0; //used to track Board channel number
    private int x, y, w, h;

    private GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    private GPointsArray auxReadPoints;
    private int nPoints;
    private int numSeconds;
    private float timeBetweenPoints;

    private color channelColor; //color of plot trace

    //When isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to minimum and maximum value found in the plot
    private boolean isAutoscale;
    private int autoScaleYLim = 0;

    private TextBox analogValue;
    private TextBox analogPin;

    private boolean drawAnalogValue;
    private int lastProcessedDataPacketInd = 0;

    AuxReadBar(PApplet _parent, int auxChanNum, String label, boolean isBotBar, int _x, int _y, int _w, int _h, float _plotAxisH) {

        auxValuesPosition = auxChanNum;
        auxChanLabel = label;
        isBottomBar = isBotBar;
        plotBottomWellH = _plotAxisH;

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
        plot.setXLim(-5,0);
        plot.setYLim(-200,200);
        plot.setPointSize(2);
        plot.setPointColor(0);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getXAxis().getAxisLabel().setOffset(plotBottomWellH/2 + 5f);

        initArrays();

        analogValue = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
        analogValue.textColor = color(bgColor);
        analogValue.alignH = RIGHT;
        analogValue.drawBackground = true;
        analogValue.backgroundColor = color(255,255,255,125);

        analogPin = new TextBox(auxChanLabel, x+3, y + h);
        analogPin.textColor = color(bgColor);
        analogPin.alignH = CENTER;

        drawAnalogValue = true;

    }

    private void initArrays() {
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

    public void update() {
        // early out if unactive
        if (!isBoardActive()) {
            return;
        }

        channel = getChannel();
        
        if(isAutoscale) {
            updatePlotPointsAutoScaled();
        } else {
            // update data in plot
            updatePlotPoints();
        }

        //Fetch the last value in the buffer to display on screen
        float val = auxReadPoints.getLastPoint().getY();
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

    private float calcTimeAxis(int sampleIndex) {
        return -(float)numSeconds + (float)sampleIndex * timeBetweenPoints;
    }

    private void updatePlotPointsAutoScaled() {
        List<double[]> allData = currentBoard.getData(nPoints);
        
        int max = (int) Math.floor(allData.get(0)[channel] + .5d);
        int min = max;

        for (int i=0; i < nPoints; i++) {
            float timey = calcTimeAxis(i);
            float value = (float)allData.get(i)[channel];
            auxReadPoints.set(i, timey, value, "");

            max = (int)value > max ? (int)value : max;
            min = (int)value < min ? (int)value : min;
        }
        plot.setYLim(min, max);
        plot.setPoints(auxReadPoints);
    }

    private void updatePlotPoints() {
        List<double[]> allData = currentBoard.getData(nPoints);

        for (int i=0; i < nPoints; i++) {
            float timey = calcTimeAxis(i);
            float value = (float)allData.get(i)[channel];
            auxReadPoints.set(i, timey, value, "");
        }

        plot.setPoints(auxReadPoints);
    }

    public void draw() {
        pushStyle();

        //draw plot
        stroke(31,69,110, 50);
        fill(color(125,30,12,30));

        rect(x + 36 + 4, y, w - 36 - 4, h);

        plot.beginDraw();
        plot.drawBox(); // we won't draw this eventually ...
        plot.drawGridLines(0);
        plot.drawLines();
        
        
        if (isBottomBar) { //only draw the x axis label on the bottom channel bar
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

    private int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    public void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        initArrays();
        
        //sets the number of axis divisions
        plot.getXAxis().setNTicks(_newTimeSize > 1 ? _newTimeSize : 10);
    }

    public void adjustVertScale(int _vertScaleValue) {
        if(_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(0, _vertScaleValue); //Plot Y values >= 0
        }
    }

    public void screenResized(int _x, int _y, int _w, int _h) {
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

    protected abstract boolean isBoardActive();

    protected abstract int getChannel();
};


class PPGReadBar extends AuxReadBar {
    private PPGCapableBoard ppgBoard;
    private int ppgChan;

    public PPGReadBar (PApplet _parent, int auxChanNum, PPGCapableBoard _ppgBoard, int _ppgChan, String _label, boolean isBotBar, int _x, int _y, int _w, int _h, float axisH) {
        super(_parent, auxChanNum, _label, isBotBar, _x, _y, _w, _h, axisH);
        ppgBoard = _ppgBoard;
        ppgChan = _ppgChan;
    }

    @Override
    protected boolean isBoardActive() {
        return ppgBoard.isPPGActive();
    }

    @Override
    protected int getChannel() {
        return ppgBoard.getPPGChannels()[ppgChan]; //There are two ppg sensors
    }
}

class EDAReadBar extends AuxReadBar {
    private EDACapableBoard edaBoard;

    public EDAReadBar (PApplet _parent, int auxChanNum, EDACapableBoard _edaBoard, String _label, boolean isBotBar, int _x, int _y, int _w, int _h, float axisH) {
        super(_parent, auxChanNum, _label, isBotBar, _x, _y, _w, _h, axisH);
        edaBoard = _edaBoard;
    }

    @Override
    protected boolean isBoardActive() {
        return edaBoard.isEDAActive();
    }

    @Override
    protected int getChannel() {
        return edaBoard.getEDAChannels()[0]; //There is one EDA sensor
    }
}

class BatteryMeter {
    private int x, y, w, h, padding;
    private BatteryInfoCapableBoard batteryBoard;
    private String displayLabel;
    private int nPoints;
    private int meterX;
    private int meterW = 200;
    private int meterH;
    private float meterIndicatorW;
    private color green = color(0,255,100,100);
    private color yellow = color(254,211,0,100);
    private color red = color(255,0,0,100);

    public BatteryMeter (PApplet _parent, BatteryInfoCapableBoard _batteryBoard, String _label, int _x, int _y, int _w, int _h, int _padding) {
        batteryBoard = _batteryBoard;
        displayLabel = _label;
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        padding = _padding;
        nPoints = nPointsBasedOnDataSource();
        meterH = h;
        meterIndicatorW = meterW;
    }

    public void update() {
        meterIndicatorW = map(getBatteryValue(), 0, 100, 0, meterW);
    }

    public void draw() {
        meterX = x + w/2 - meterW/2;
        String batteryLevel = Integer.toString(getBatteryValue()) + "%";

        pushStyle();

        stroke(0);
        fill(color(0));
        text(displayLabel, meterX - padding - textWidth(displayLabel), y + padding + 4, 200, h);
        text(batteryLevel, meterX + meterW + padding, y + padding + 4, 50, h);

        //Fill battery meter with level
        noStroke();
        fill(getBatteryColor());
        rect(meterX, y + padding, meterIndicatorW, meterH);

        //Draw bounding box for meter with no fill on top of indicator rectangle
        stroke(0);
        noFill();
        rect(meterX, y + padding, meterW, meterH);
        
        popStyle();
    }

    private int nPointsBasedOnDataSource() {
        return 1 * currentBoard.getSampleRate();
    }

    private int getChannel() {
        return batteryBoard.getBatteryChannel();
    }

    private int getBatteryValue() {
        List<double[]> allData = currentBoard.getData(nPoints);
        return (int)allData.get(nPoints-1)[getChannel()];
    }

    private color getBatteryColor() {
        int val = getBatteryValue();
        if (val > 50) {
            return green;
        } else if (val <= 50 && val > 20) {
            return yellow;
        } else {
            return red;
        }
    }

    public void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        meterH = h;
    }
}