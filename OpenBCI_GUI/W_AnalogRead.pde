////////////////////////////////////////////////////////////////////////
//                                                                    //
//  W_AnalogRead is used to visualize analog voltage values           //
//                                                                    //
//  Created: AJ Keller                                                //
//  Refactored: Richard Waltman, April 2025                           //
//                                                                    //
//                                                                    //
////////////////////////////////////////////////////////////////////////

class W_AnalogRead extends WidgetWithSettings {
    private float arPadding;
    // values for actual time series chart (rectangle encompassing all analogReadBars)
    private float ar_x, ar_y, ar_h, ar_w;
    private float plotBottomWell;
    private float playbackWidgetHeight;
    private int analogReadBarHeight;

    private final int NUM_ANALOG_READ_BARS = 3;
    private AnalogReadBar[] analogReadBars;

    private boolean allowSpillover = false;

    private Button analogModeButton;

    private AnalogCapableBoard analogBoard;

    W_AnalogRead() {
        super();
        widgetTitle = "AnalogRead";

        analogBoard = (AnalogCapableBoard)currentBoard;

        plotBottomWell = 45.0; //this appears to be an arbitrary vertical space adds GPlot leaves at bottom, I derived it through trial and error
        arPadding = 10.0;
        ar_x = float(x) + arPadding;
        ar_y = float(y) + (arPadding);
        ar_w = float(w) - arPadding*2;
        ar_h = float(h) - playbackWidgetHeight - plotBottomWell - (arPadding*2);

        analogReadBars = new AnalogReadBar[NUM_ANALOG_READ_BARS];
        analogReadBarHeight = int(ar_h / analogReadBars.length);

        //create our channel bars and populate our analogReadBars array!
        for(int i = 0; i < analogReadBars.length; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            AnalogReadBar tempBar = new AnalogReadBar(ourApplet, i+5, int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
            analogReadBars[i] = tempBar;
        }
        
        int verticalScaleValue = widgetSettings.get(AnalogReadVerticalScale.class).getValue();
        int horizontalScaleValue = widgetSettings.get(AnalogReadHorizontalScale.class).getValue();
        applyVerticalScale(verticalScaleValue);
        applyHorizontalScale(horizontalScaleValue);

        createAnalogModeButton("analogModeButton", "Turn Analog Read On", (int)(x0 + 1), (int)(y0 + NAV_HEIGHT + 1), 128, NAV_HEIGHT - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        widgetSettings.set(AnalogReadVerticalScale.class, AnalogReadVerticalScale.ONE_THOUSAND_FIFTY)
                    .set(AnalogReadHorizontalScale.class, AnalogReadHorizontalScale.FIVE_SEC)
                    .saveDefaults();

        initDropdown(AnalogReadVerticalScale.class, "analogReadVerticalScaleDropdown", "Vert Scale");
        initDropdown(AnalogReadHorizontalScale.class, "analogReadHorizontalScaleDropdown", "Window");
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(AnalogReadVerticalScale.class, "analogReadVerticalScaleDropdown");
        updateDropdownLabel(AnalogReadHorizontalScale.class, "analogReadHorizontalScaleDropdown");
    }

    public void update() {
        super.update();

        if (currentBoard instanceof DataSourcePlayback) {
            if (((DataSourcePlayback)currentBoard) instanceof AnalogCapableBoard
                && (!((AnalogCapableBoard)currentBoard).isAnalogActive())) {
                    return;
            }
        }

        //update channel bars ... this means feeding new EEG data into plots
        for(int i = 0; i < analogReadBars.length; i++) {
            analogReadBars[i].update();
        }

        //ignore top left button interaction when widgetSelector dropdown is active
        List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.add((controlP5.Controller)analogModeButton);
        lockElementsOnOverlapCheck(cp5ElementsToCheck);

        if (!analogBoard.canDeactivateAnalog()) {
            analogModeButton.setLock(true);
            analogModeButton.getCaptionLabel().setText("Analog Read On");
            analogModeButton.setColorBackground(BUTTON_LOCKED_GREY);
        }
    }

    public void draw() {
        super.draw();

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        if (analogBoard.isAnalogActive()) {
            for(int i = 0; i < analogReadBars.length; i++) {
                analogReadBars[i].draw();
            }
        }
    }

    public void screenResized() {
        super.screenResized();

        ar_x = float(x) + arPadding;
        ar_y = float(y) + (arPadding);
        ar_w = float(w) - arPadding*2;
        ar_h = float(h) - playbackWidgetHeight - plotBottomWell - (arPadding*2);
        analogReadBarHeight = int(ar_h/analogReadBars.length);

        for(int i = 0; i < analogReadBars.length; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            analogReadBars[i].screenResized(int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //bar x, bar y, bar w, bar h
        }

        analogModeButton.setPosition((int)(x0 + 1), (int)(y0 + NAV_HEIGHT + 1));
    }

    public void mousePressed() {
        super.mousePressed();
    }

    public void mouseReleased() {
        super.mouseReleased();
    }

    private void createAnalogModeButton(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        analogModeButton = createButton(cp5_widget, name, text, _x, _y, _w, _h, 0, _font, _fontSize, _bg, _textColor, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        analogModeButton.setSwitch(true);
        analogModeButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!analogBoard.isAnalogActive()) {
                    analogBoard.setAnalogActive(true);  
                    analogModeButton.getCaptionLabel().setText("Turn Analog Read Off");	
                    output("Starting to read analog inputs on pin marked A5 (D11), A6 (D12) and A7 (D13)");
                    ((W_PulseSensor) widgetManager.getWidget("W_Accelerometer")).toggleAnalogReadButton(true);
                    ((W_Accelerometer) widgetManager.getWidget("W_Accelerometer")).accelBoardSetActive(false);
                    ((W_DigitalRead) widgetManager.getWidget("W_Accelerometer")).toggleDigitalReadButton(false);
                } else {
                    analogBoard.setAnalogActive(false);
                    analogModeButton.getCaptionLabel().setText("Turn Analog Read On");	
                    output("Starting to read accelerometer");
                    ((W_Accelerometer) widgetManager.getWidget("W_Accelerometer")).accelBoardSetActive(true);
                    ((W_DigitalRead) widgetManager.getWidget("W_Accelerometer")).toggleDigitalReadButton(false);
                    ((W_PulseSensor) widgetManager.getWidget("W_Accelerometer")).toggleAnalogReadButton(false);
                }
            }
        });
        String _helpText = "Click this button to activate/deactivate analog read on Cyton pins A5(D11), A6(D12) and A7(D13).";
        analogModeButton.setDescription(_helpText);
    }

    public void toggleAnalogReadButton(boolean _value) {
        String s = _value ? "Turn Analog Read Off" : "Turn Analog Read On";
        analogModeButton.getCaptionLabel().setText(s);
        if (_value) {
            analogModeButton.setOn();
        } else {
            analogModeButton.setOff();
        }
    }

    public void setVerticalScale(int n) {
        widgetSettings.setByIndex(AnalogReadVerticalScale.class, n);
        int verticalScaleValue = widgetSettings.get(AnalogReadVerticalScale.class).getValue();
        applyVerticalScale(verticalScaleValue);
    }

    public void setHorizontalScale(int n) {
        widgetSettings.setByIndex(AnalogReadHorizontalScale.class, n);
        int horizontalScaleValue = widgetSettings.get(AnalogReadHorizontalScale.class).getValue();
        applyHorizontalScale(horizontalScaleValue);
    }

    private void applyVerticalScale(int value) {
         for(int i = 0; i < analogReadBars.length; i++) {
            analogReadBars[i].adjustVertScale(value);
        }
    }

    private void applyHorizontalScale(int value) {
        for(int i = 0; i < analogReadBars.length; i++) {
            analogReadBars[i].adjustTimeAxis(value);
        }
    }
};

public void analogReadVerticalScaleDropdown(int n) {
    ((W_AnalogRead) widgetManager.getWidget("W_AnalogRead")).setVerticalScale(n);
}

public void analogReadHorizontalScaleDropdown(int n) {
    ((W_AnalogRead) widgetManager.getWidget("W_AnalogRead")).setHorizontalScale(n);
}

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class AnalogReadBar{

    private int analogInputPin;
    private int auxValuesPosition;
    private String analogInputString;
    private int x, y, w, h;

    private GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    private GPointsArray analogReadPoints;
    private int nPoints;
    private int numSeconds;
    private float timeBetweenPoints;
    private final float GPLOT_SPACING = 10f;
    private GPlotAutoscaler gplotAutoscaler;

    private color channelColor; //color of plot trace
    
    private TextBox analogValue;
    private TextBox analogPin;
    private TextBox digitalPin;

    private boolean drawAnalogValue;
    private int lastProcessedDataPacketInd = 0;

    private AnalogCapableBoard analogBoard;

    AnalogReadBar(PApplet _parentApplet, int _analogInputPin, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width

        analogInputPin = _analogInputPin;
        int digitalPinNum = 0;
        if (analogInputPin == 7) {
            auxValuesPosition = 2;
            digitalPinNum = 13;
        } else if (analogInputPin == 6) {
            auxValuesPosition = 1;
            digitalPinNum = 12;
        } else {
            analogInputPin = 5;
            auxValuesPosition = 0;
            digitalPinNum = 11;
        }

        analogInputString = str(analogInputPin);

        x = _x;
        y = _y;
        w = _w;
        h = _h;

        numSeconds = 20;
        plot = new GPlot(_parentApplet);
        plot.setPos(x + 36 + 4, y);
        plot.setDim(w - 36 - 4, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(auxValuesPosition)%8]);
        plot.setXLim(-3.2,-2.9);
        plot.setYLim(-200,200);
        plot.setPointSize(2);
        plot.setPointColor(0);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        if(auxValuesPosition == 2) {
            plot.getXAxis().setAxisLabelText("Time (s)");
        }
        
        gplotAutoscaler = new GPlotAutoscaler(GPLOT_SPACING);

        initArrays();
        
        
        analogValue = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
        analogValue.textColor = OPENBCI_DARKBLUE;
        analogValue.alignH = RIGHT;
        analogValue.alignV = BOTTOM;
        analogValue.drawBackground = true;
        analogValue.backgroundColor = color(255,255,255,125);

        analogPin = new TextBox("A" + analogInputString, x+3, y + h);
        analogPin.textColor = OPENBCI_DARKBLUE;
        analogPin.alignH = CENTER;
        digitalPin = new TextBox("(D" + digitalPinNum + ")", x+3, y + h + 12);
        digitalPin.textColor = OPENBCI_DARKBLUE;
        digitalPin.alignH = CENTER;

        drawAnalogValue = true;
        analogBoard = (AnalogCapableBoard) currentBoard;
    }

    void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;
        analogReadPoints = new GPointsArray(nPoints);

        for (int i = 0; i < nPoints; i++) {
            float time = calcTimeAxis(i);
            float analog_value = 0.0; //0.0 for all points to start
            analogReadPoints.set(i, time, analog_value, "");
        }

        plot.setPoints(analogReadPoints); //set the plot with 0.0 for all auxReadPoints to start
    }

    void update() {

         // early out if unactive
        if (!analogBoard.isAnalogActive()) {
            return;
        }

        // update data in plot
        updatePlotPoints();

        //Fetch the last value in the buffer to display on screen
        float val = analogReadPoints.getLastPoint().getY();
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
        List<double[]> allData = analogBoard.getDataWithAnalog(nPoints);
        int[] channels = analogBoard.getAnalogChannels();

        if (channels.length == 0) {
            return;
        }

        for (int i = 0; i < nPoints; i++) {
            float timey = calcTimeAxis(i);
            float value = (float)allData.get(i)[channels[auxValuesPosition]];
            analogReadPoints.set(i, timey, value, "");
        }

        plot.setPoints(analogReadPoints);
        gplotAutoscaler.update(plot, analogReadPoints);
    }

    void draw() {
        pushStyle();

        //draw plot
        stroke(OPENBCI_BLUE_ALPHA50);
        fill(color(125,30,12,30));

        rect(x + 36 + 4, y, w - 36 - 4, h);

        plot.beginDraw();
        plot.drawBox(); // we won't draw this eventually ...
        plot.drawGridLines(GPlot.VERTICAL);
        plot.drawLines();
        if(auxValuesPosition == 2) { //only draw the x axis label on the bottom channel bar
            plot.drawXAxis();
            plot.getXAxis().draw();
        }

        plot.endDraw();

        if(drawAnalogValue) {
            analogValue.draw();
            analogPin.draw();
            digitalPin.draw();
        }

        popStyle();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * ((AnalogCapableBoard)currentBoard).getAnalogSampleRate();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();

        analogReadPoints = new GPointsArray(nPoints);
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }
        else {
            plot.getXAxis().setNTicks(10);
        }
        
        updatePlotPoints();
    }

    void adjustVertScale(int _vertScaleValue) {
        boolean enableAutoscale = _vertScaleValue == 0;
        gplotAutoscaler.setEnabled(enableAutoscale);
        if (enableAutoscale) {
            return;
        }
        
        plot.setYLim(-10, _vertScaleValue);
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
        analogPin.y = y + int(h/2.0);
        digitalPin.x = analogPin.x;
        digitalPin.y = analogPin.y + 12;
    }
};
