
////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                    //
//    W_BandPowers.pde                                                                                //
//                                                                                                    //
//    This is a band power visualization widget!                                                      //
//    (Couldn't think up more)                                                                        //
//    This is for visualizing the power of each brainwave band: delta, theta, alpha, beta, gamma      //
//    Averaged over all channels                                                                      //
//                                                                                                    //
//    Created by: Wangshu Sun, May 2017                                                               //
//    Modified by: Richard Waltman, March 2022                                                        //
//    Refactored by: Richard Waltman, April 2025                                                      //
//                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////

class W_BandPower extends WidgetWithSettings {
    private final int DELTA = 0; // 1-4 Hz
    private final int THETA = 1; // 4-8 Hz
    private final int ALPHA = 2; // 8-13 Hz
    private final int BETA = 3; // 13-30 Hz
    private final int GAMMA = 4; // 30-55 Hz
    
    private final int NUM_BANDS = 5;
    private float[] activePower = new float[NUM_BANDS];
    private float[] normalizedBandPowers = new float[NUM_BANDS];

    private GPlot bp_plot;
    public ExGChannelSelect bpChanSelect;
    private boolean prevChanSelectIsVisible = false;

    private List<controlP5.Controller> cp5ElementsToCheck;

    W_BandPower() {
        super();
        widgetTitle = "Band Power";

        createPlot();
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        widgetSettings.set(BPVerticalScale.class, BPVerticalScale.SCALE_100)
                    .set(GraphLogLin.class, GraphLogLin.LOG)
                    .set(FFTSmoothingFactor.class, globalFFTSettings.getSmoothingFactor())
                    .set(FFTFilteredEnum.class, globalFFTSettings.getFilteredEnum());
        
        initDropdown(BPVerticalScale.class, "bandPowerVerticalScaleDropdown", "Max uV");
        initDropdown(GraphLogLin.class, "bandPowerLogLinDropdown", "Log/Lin");
        initDropdown(FFTSmoothingFactor.class, "bandPowerSmoothingDropdown", "Smooth");
        initDropdown(FFTFilteredEnum.class, "bandPowerDataFilteringDropdown", "Filters");

        bpChanSelect = new ExGChannelSelect(ourApplet, x, y, w, navH);
        bpChanSelect.activateAllButtons();
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.addAll(bpChanSelect.getCp5ElementsForOverlapCheck());
        saveActiveChannels(bpChanSelect.getActiveChannels());
        widgetSettings.saveDefaults();
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(BPVerticalScale.class, "bandPowerVerticalScaleDropdown");
        updateDropdownLabel(GraphLogLin.class, "bandPowerLogLinDropdown");
        updateDropdownLabel(FFTSmoothingFactor.class, "bandPowerSmoothingDropdown");
        updateDropdownLabel(FFTFilteredEnum.class, "bandPowerDataFilteringDropdown");
        applyActiveChannels(bpChanSelect);
        applyVerticalScale();
        applyPlotLogScale();
    }

    @Override
    protected void updateChannelSettings() {
        if (bpChanSelect != null) {
            saveActiveChannels(bpChanSelect.getActiveChannels());
        }
    }

    private void createPlot() {
        // Setup for the BandPower plot
        bp_plot = new GPlot(ourApplet, x, y-NAV_HEIGHT, w, h+NAV_HEIGHT);
        // bp_plot.setPos(x, y+NAV_HEIGHT);
        bp_plot.setDim(w, h);
        bp_plot.setLogScale("y");
        bp_plot.setYLim(0.1, 100); // Lower limit must be > 0 for log scale
        bp_plot.setXLim(0, 5);
        bp_plot.getYAxis().setNTicks(4);
        bp_plot.getXAxis().setNTicks(0);
        bp_plot.getTitle().setTextAlignment(LEFT);
        bp_plot.getTitle().setRelativePos(0);
        bp_plot.setAllFontProperties("Arial", 0, 14);
        bp_plot.getYAxis().getAxisLabel().setText("Power — (uV)^2 / Hz");
        bp_plot.getXAxis().setAxisLabelText("EEG Power Bands");
        bp_plot.getXAxis().getAxisLabel().setOffset(42f);
        bp_plot.startHistograms(GPlot.VERTICAL);
        bp_plot.getHistogram().setDrawLabels(true);
        bp_plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        bp_plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        bp_plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        bp_plot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        bp_plot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        bp_plot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);

        //setting border of histograms to match BG
        bp_plot.getHistogram().setLineColors(new color[]{
            color(245), color(245), color(245), color(245), color(245)
          }
        );
        //setting bg colors of histogram bars to match the color scheme of the channel colors w/ an opacity of 150/255
        bp_plot.getHistogram().setBgColors(new color[] {
                color((int)CHANNEL_COLORS[6], 200),
                color((int)CHANNEL_COLORS[4], 200),
                color((int)CHANNEL_COLORS[3], 200),
                color((int)CHANNEL_COLORS[2], 200), 
                color((int)CHANNEL_COLORS[1], 200),
            }
        );
        //setting color of text label for each histogram bar on the x axis
        bp_plot.getHistogram().setFontColor(OPENBCI_DARKBLUE);
        applyPlotLogScale();
    }

    public void update() {
        super.update();
        
        //Update channel checkboxes and active channels
        bpChanSelect.update(x, y, w);
        
        //Flex the Gplot graph when channel select dropdown is open/closed
        if (bpChanSelect.isVisible() != prevChanSelectIsVisible) {
            flexGPlotSizeAndPosition();
            prevChanSelectIsVisible = bpChanSelect.isVisible();
        }

        GPointsArray bp_points = new GPointsArray(dataProcessing.headWidePower.length);
        bp_points.add(DELTA + 0.5, activePower[DELTA], "DELTA\n0.5-4Hz");
        bp_points.add(THETA + 0.5, activePower[THETA], "THETA\n4-8Hz");
        bp_points.add(ALPHA + 0.5, activePower[ALPHA], "ALPHA\n8-13Hz");
        bp_points.add(BETA + 0.5, activePower[BETA], "BETA\n13-32Hz");
        bp_points.add(GAMMA + 0.5, activePower[GAMMA], "GAMMA\n32-100Hz");
        bp_plot.setPoints(bp_points);

        if (bpChanSelect.isVisible()) {
            lockElementsOnOverlapCheck(cp5ElementsToCheck);
        }
    }

    public void draw() {
        super.draw();
        pushStyle();

        bp_plot.beginDraw();
        bp_plot.drawBox();
        bp_plot.drawXAxis();
        bp_plot.drawYAxis();
        bp_plot.drawGridLines(GPlot.HORIZONTAL);
        bp_plot.drawHistograms();
        bp_plot.endDraw();

        popStyle();
        bpChanSelect.draw();
    }

    public void screenResized() {
        super.screenResized();

        flexGPlotSizeAndPosition();

        bpChanSelect.screenResized(ourApplet);
    }

    public void mousePressed() {
        super.mousePressed();
        bpChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
    }

    void flexGPlotSizeAndPosition() {
        if (bpChanSelect.isVisible()) {
            bp_plot.setPos(x, y + bpChanSelect.getHeight() - navH);
            bp_plot.setOuterDim(w, h - bpChanSelect.getHeight() + navH);
        } else {
            bp_plot.setPos(x, y - navH);
            bp_plot.setOuterDim(w, h + navH);
        }
    }

    public float[] getNormalizedBPSelectedChannels() {
        return normalizedBandPowers;
    }

    //Called in DataProcessing.pde to update data even if widget is closed
    public void updateBandPowerWidgetData() {
        float normalizingSum = 0;

        for (int i = 0; i < NUM_BANDS; i++) {
            float sum = 0;
            for (int j = 0; j < bpChanSelect.getActiveChannels().size(); j++) {
                int chan = bpChanSelect.getActiveChannels().get(j);
                sum += dataProcessing.avgPowerInBins[chan][i];
            }
            activePower[i] = sum / bpChanSelect.getActiveChannels().size();
            normalizingSum += activePower[i];
        }

        for (int i = 0; i < NUM_BANDS; i++) {
            normalizedBandPowers[i] = activePower[i] / normalizingSum;
        }
    }

    public void setVerticalScale(int n) {
        widgetSettings.setByIndex(BPVerticalScale.class, n);
        applyVerticalScale();
    }

    public void setLogLin(int n) {
        widgetSettings.setByIndex(GraphLogLin.class, n);
        applyPlotLogScale();
    }

    private void applyVerticalScale() {
        BPVerticalScale scale = widgetSettings.get(BPVerticalScale.class);
        int scaleValue = scale.getValue();
        bp_plot.setYLim(0.1, scaleValue); // Lower limit must be > 0 for log scale
    }

    private void applyPlotLogScale() {
        GraphLogLin logLin = widgetSettings.get(GraphLogLin.class);
        if (logLin == GraphLogLin.LOG) {
            bp_plot.setLogScale("y");
        } else {
            bp_plot.setLogScale("");
        }
    }

    public void setSmoothingDropdownFrontend(FFTSmoothingFactor _smoothingFactor) {
        widgetSettings.set(FFTSmoothingFactor.class, _smoothingFactor);
        updateDropdownLabel(FFTSmoothingFactor.class, "bandPowerSmoothingDropdown");
    }

    public void setFilteringDropdownFrontend(FFTFilteredEnum _filteredEnum) {
        widgetSettings.set(FFTFilteredEnum.class, _filteredEnum);
        updateDropdownLabel(FFTFilteredEnum.class, "bandPowerDataFilteringDropdown");
    }
};

public void bandPowerVerticalScaleDropdown(int n) {
    ((W_BandPower) widgetManager.getWidget("W_BandPower")).setVerticalScale(n);
}

public void bandPowerLogLinDropdown(int n) {
    ((W_BandPower) widgetManager.getWidget("W_BandPower")).setLogLin(n);
}

public void bandPowerSmoothingDropdown(int n) {
    globalFFTSettings.setSmoothingFactor(FFTSmoothingFactor.values()[n]);
    FFTSmoothingFactor smoothingFactor = globalFFTSettings.getSmoothingFactor();
    ((W_BandPower) widgetManager.getWidget("W_BandPower")).setSmoothingDropdownFrontend(smoothingFactor);
    ((W_Fft) widgetManager.getWidget("W_Fft")).setSmoothingDropdownFrontend(smoothingFactor);
}

public void bandPowerDataFilteringDropdown(int n) {
    globalFFTSettings.setFilteredEnum(FFTFilteredEnum.values()[n]);
    FFTFilteredEnum filteredEnum = globalFFTSettings.getFilteredEnum();
    ((W_BandPower) widgetManager.getWidget("W_BandPower")).setFilteringDropdownFrontend(filteredEnum);
    ((W_Fft) widgetManager.getWidget("W_Fft")).setFilteringDropdownFrontend(filteredEnum);
}