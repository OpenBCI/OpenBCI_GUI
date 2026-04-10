
////////////////////////////////////////////////////
//
// This class creates an FFT Plot
// It extends the Widget class
//
// Conor Russomanno, November 2016
// Refactored: Richard Waltman, March 2025
//
// Requires the plotting library from grafica ...
// replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////

class W_Fft extends WidgetWithSettings {
    public ExGChannelSelect fftChanSelect;
    private boolean prevChanSelectIsVisible = false;

    private GPlot fftPlot; //create an fft plot for each active channel
    private GPointsArray[] fftGplotPoints;

    private int fftFrequencyLimit;

    private List<controlP5.Controller> cp5ElementsToCheck;

    W_Fft() {
        super();
        widgetTitle = "FFT Plot";

        fftGplotPoints = new GPointsArray[globalChannelCount];
        initializeFFTPlot();
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        widgetSettings.set(FFTMaxFrequency.class, FFTMaxFrequency.MAX_60)
                .set(FFTVerticalScale.class, FFTVerticalScale.SCALE_100)
                .set(GraphLogLin.class, GraphLogLin.LOG)
                .set(FFTSmoothingFactor.class, globalFFTSettings.getSmoothingFactor())
                .set(FFTFilteredEnum.class, globalFFTSettings.getFilteredEnum());

        initDropdown(FFTMaxFrequency.class, "fftMaxFrequencyDropdown", "Max Hz");
        initDropdown(FFTVerticalScale.class, "fftVerticalScaleDropdown", "Max uV");
        initDropdown(GraphLogLin.class, "GraphLogLinDropdown", "Log/Lin");
        initDropdown(FFTSmoothingFactor.class, "fftSmoothingDropdown", "Smooth");
        initDropdown(FFTFilteredEnum.class, "fftFilteringDropdown", "Filters");
        
        fftChanSelect = new ExGChannelSelect(ourApplet, x, y, w, navH);
        fftChanSelect.activateAllButtons();
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.addAll(fftChanSelect.getCp5ElementsForOverlapCheck());
        saveActiveChannels(fftChanSelect.getActiveChannels());
        widgetSettings.saveDefaults();

        int maxFrequencyHighestValue = ((FFTMaxFrequency) widgetSettings.get(FFTMaxFrequency.class)).getHighestFrequency();
        fftFrequencyLimit = int(1.0 * maxFrequencyHighestValue * (getNumFFTPoints() / currentBoard.getSampleRate()));
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(FFTMaxFrequency.class, "fftMaxFrequencyDropdown");
        updateDropdownLabel(FFTVerticalScale.class, "fftVerticalScaleDropdown");
        updateDropdownLabel(GraphLogLin.class, "GraphLogLinDropdown");
        updateDropdownLabel(FFTSmoothingFactor.class, "fftSmoothingDropdown");
        updateDropdownLabel(FFTFilteredEnum.class, "fftFilteringDropdown");
        applyActiveChannels(fftChanSelect);
        applyMaxFrequency();
        applyVerticalScale();
        setPlotLogScale();
        FFTSmoothingFactor smoothingFactor = widgetSettings.get(FFTSmoothingFactor.class);
        FFTFilteredEnum filteredEnum = widgetSettings.get(FFTFilteredEnum.class);
        globalFFTSettings.setSmoothingFactor(smoothingFactor);
        globalFFTSettings.setFilteredEnum(filteredEnum);
    }

    @Override
    protected void updateChannelSettings() {
        if (fftChanSelect != null) {
            saveActiveChannels(fftChanSelect.getActiveChannels());
        }
    }


    private void initializeFFTPlot() {
        //setup GPlot for FFT
        fftPlot = new GPlot(ourApplet, x, y-NAV_HEIGHT, w, h+NAV_HEIGHT);
        fftPlot.setAllFontProperties("Arial", 0, 14);
        fftPlot.getXAxis().setAxisLabelText("Frequency (Hz)");
        fftPlot.getYAxis().setAxisLabelText("Amplitude (uV)");
        fftPlot.setMar(60, 70, 40, 30); //{ bot=60, left=70, top=40, right=30 } by default
        setPlotLogScale();

        int verticalScaleValue = widgetSettings.get(FFTVerticalScale.class).getValue();
        int maxFrequencyValue = widgetSettings.get(FFTMaxFrequency.class).getValue();
        fftPlot.setYLim(0.1, verticalScaleValue);
        int _nTicks = 10;
        fftPlot.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
        fftPlot.setXLim(0.1, maxFrequencyValue);
        fftPlot.getYAxis().setDrawTickLabels(true);
        fftPlot.setPointSize(2);
        fftPlot.setPointColor(0);
        fftPlot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        fftPlot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        fftPlot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        fftPlot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        fftPlot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        fftPlot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);

        //setup points of fft point arrays
        for (int i = 0; i < fftGplotPoints.length; i++) {
            fftGplotPoints[i] = new GPointsArray(fftFrequencyLimit);
        }

        //fill fft point arrays
        for (int i = 0; i < fftGplotPoints.length; i++) { //loop through each channel
            for (int j = 0; j < fftFrequencyLimit; j++) {
                GPoint temp = new GPoint(j, 0);
                fftGplotPoints[i].set(j, temp);
            }
        }

        //map fft point arrays to fft plots
        fftPlot.setPoints(fftGplotPoints[0]);
    }

    void update(){

        super.update();
        float sampleRate = currentBoard.getSampleRate();
        int fftPointCount = getNumFFTPoints();

        //update the points of the FFT channel arrays for all channels
        for (int i = 0; i < fftGplotPoints.length; i++) {
            for (int j = 0; j < fftFrequencyLimit + 2; j++) {  //loop through frequency domain data, and store into points array
                GPoint powerAtBin = new GPoint((1.0*sampleRate/fftPointCount)*j, fftBuff[i].getBand(j));
                fftGplotPoints[i].set(j, powerAtBin);
            }
        }

        //Update channel select checkboxes and active channels
        fftChanSelect.update(x, y, w);

        //Flex the Gplot graph when channel select dropdown is open/closed
        if (fftChanSelect.isVisible() != prevChanSelectIsVisible) {
            flexGPlotSizeAndPosition();
            prevChanSelectIsVisible = fftChanSelect.isVisible();
        }

        if (fftChanSelect.isVisible()) {
            lockElementsOnOverlapCheck(cp5ElementsToCheck);
        }
    }

    void draw(){
        super.draw();

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        //draw FFT Graph w/ all plots
        noStroke();
        fftPlot.beginDraw();
        fftPlot.drawBox();
        fftPlot.drawXAxis();
        fftPlot.drawYAxis();
        fftPlot.drawGridLines(GPlot.BOTH);
        //Update and draw active channels that have been selected via channel select for this widget
        for (int j = 0; j < fftChanSelect.getActiveChannels().size(); j++) {
            int chan = fftChanSelect.getActiveChannels().get(j);
            fftPlot.setLineColor((int)CHANNEL_COLORS[chan % 8]);
            //remap fft point arrays to fft plots
            fftPlot.setPoints(fftGplotPoints[chan]);
            fftPlot.drawLines();
        }  
        fftPlot.endDraw();

        popStyle();

        fftChanSelect.draw();
    }

    void screenResized(){
        super.screenResized();

        flexGPlotSizeAndPosition();

        fftChanSelect.screenResized(ourApplet);
    }

    void mousePressed(){
        super.mousePressed();
        fftChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
    }

    void mouseReleased(){
        super.mouseReleased();
    }

    void flexGPlotSizeAndPosition() {
        if (fftChanSelect.isVisible()) {
                fftPlot.setPos(x, y + fftChanSelect.getHeight() - navH);
                fftPlot.setOuterDim(w, h - fftChanSelect.getHeight() + navH);
        } else {
            fftPlot.setPos(x, y - navH);
            fftPlot.setOuterDim(w, h + navH);
        }
    }

    private void applyMaxFrequency() {
        int maxFrequencyValue = widgetSettings.get(FFTMaxFrequency.class).getValue();
        fftPlot.setXLim(0.1, maxFrequencyValue);
    }

    private void applyVerticalScale() {
        int verticalScaleValue = widgetSettings.get(FFTVerticalScale.class).getValue();
        fftPlot.setYLim(0.1, verticalScaleValue);
    }

    public void setMaxFrequency(int n) {
        widgetSettings.setByIndex(FFTMaxFrequency.class, n);
        applyMaxFrequency();
    }

    public void setVerticalScale(int n) {
        widgetSettings.setByIndex(FFTVerticalScale.class, n);
        applyVerticalScale();
    }

    public void setLogLin(int n) {
        widgetSettings.setByIndex(GraphLogLin.class, n);
        setPlotLogScale();
    }

    private void setPlotLogScale() {
        GraphLogLin logLin = widgetSettings.get(GraphLogLin.class);
        if (logLin == GraphLogLin.LOG) {
            fftPlot.setLogScale("y");
        } else {
            fftPlot.setLogScale("");
        }
    }

    public void setSmoothingDropdownFrontend(FFTSmoothingFactor _smoothingFactor) {
        widgetSettings.set(FFTSmoothingFactor.class, _smoothingFactor);
        updateDropdownLabel(FFTSmoothingFactor.class, "fftSmoothingDropdown");
    }

    public void setFilteringDropdownFrontend(FFTFilteredEnum _filteredEnum) {
        widgetSettings.set(FFTFilteredEnum.class, _filteredEnum);
        updateDropdownLabel(FFTFilteredEnum.class, "fftFilteringDropdown");
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
public void fftMaxFrequencyDropdown(int n) {
    ((W_Fft) widgetManager.getWidget("W_Fft")).setMaxFrequency(n);
}

public void fftVerticalScaleDropdown(int n) {
    ((W_Fft) widgetManager.getWidget("W_Fft")).setVerticalScale(n);
}

public void GraphLogLinDropdown(int n) {
    ((W_Fft) widgetManager.getWidget("W_Fft")).setLogLin(n);
}

public void fftSmoothingDropdown(int n) {
    globalFFTSettings.setSmoothingFactor(FFTSmoothingFactor.values()[n]);
    FFTSmoothingFactor smoothingFactor = globalFFTSettings.getSmoothingFactor();
    ((W_BandPower) widgetManager.getWidget("W_BandPower")).setSmoothingDropdownFrontend(smoothingFactor);
    ((W_Fft) widgetManager.getWidget("W_Fft")).setSmoothingDropdownFrontend(smoothingFactor);
}

public void fftFilteringDropdown(int n) {
    globalFFTSettings.setFilteredEnum(FFTFilteredEnum.values()[n]);
    FFTFilteredEnum filteredEnum = globalFFTSettings.getFilteredEnum();
    ((W_BandPower) widgetManager.getWidget("W_BandPower")).setFilteringDropdownFrontend(filteredEnum);
    ((W_Fft) widgetManager.getWidget("W_Fft")).setFilteringDropdownFrontend(filteredEnum);
}