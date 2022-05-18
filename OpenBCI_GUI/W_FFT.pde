
////////////////////////////////////////////////////
//
// This class creates an FFT Plot
// It extends the Widget class
//
// Conor Russomanno, November 2016
//
// Requires the plotting library from grafica ...
// replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////

class W_fft extends Widget {

    public ChannelSelect fftChanSelect;
    boolean prevChanSelectIsVisible = false;

    GPlot fft_plot; //create an fft plot for each active channel
    GPointsArray[] fft_points;  //create an array of points for each channel of data (4, 8, or 16)
    
    int[] lineColor = {
        (int)color(129, 129, 129),
        (int)color(124, 75, 141),
        (int)color(54, 87, 158),
        (int)color(49, 113, 89),
        (int)color(221, 178, 13),
        (int)color(253, 94, 52),
        (int)TURN_OFF_RED,
        (int)color(162, 82, 49),
        (int)color(129, 129, 129),
        (int)color(124, 75, 141),
        (int)color(54, 87, 158),
        (int)color(49, 113, 89),
        (int)color(221, 178, 13),
        (int)color(253, 94, 52),
        (int)TURN_OFF_RED,
        (int)color(162, 82, 49)
    };

    int[] xLimOptions = {20, 40, 60, 100, 120, 250, 500, 800};
    int[] yLimOptions = {10, 50, 100, 1000};

    int xLim = xLimOptions[2];  //maximum value of x axis ... in this case 20 Hz, 40 Hz, 60 Hz, 120 Hz
    int xMax = xLimOptions[xLimOptions.length-1];   //maximum possible frequency in FFT
    int FFT_indexLim = int(1.0*xMax*(getNfftSafe()/currentBoard.getSampleRate()));   // maxim value of FFT index
    int yLim = yLimOptions[2];  //maximum value of y axis ... 100 uV

    List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();

    W_fft(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Add channel select dropdown to this widget
        fftChanSelect = new ChannelSelect(pApplet, this, x, y, w, navH, "BP_Channels");
        fftChanSelect.activateAllButtons();
        cp5ElementsToCheck.addAll(fftChanSelect.getCp5ElementsForOverlapCheck());

        //Default FFT plot settings
        settings.fftMaxFrqSave = 2;
        settings.fftMaxuVSave = 2;
        settings.fftLogLinSave = 0;
        settings.fftSmoothingSave = 3;
        settings.fftFilterSave = 0;

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("MaxFreq", "Max Freq", Arrays.asList(settings.fftMaxFrqArray), settings.fftMaxFrqSave);
        addDropdown("VertScale", "Max uV", Arrays.asList(settings.fftVertScaleArray), settings.fftMaxuVSave);
        addDropdown("LogLin", "Log/Lin", Arrays.asList(settings.fftLogLinArray), settings.fftLogLinSave);
        addDropdown("Smoothing", "Smooth", Arrays.asList(settings.fftSmoothingArray), smoothFac_ind); //smoothFac_ind is a global variable at the top of W_HeadPlot.pde
        addDropdown("UnfiltFilt", "Filters?", Arrays.asList(settings.fftFilterArray), settings.fftFilterSave);

        fft_points = new GPointsArray[nchan];
        // println("fft_points.length: " + fft_points.length);
        initializeFFTPlot(_parent);

    }

    void initializeFFTPlot(PApplet _parent) {
        //setup GPlot for FFT
        fft_plot = new GPlot(_parent, x, y-navHeight, w, h+navHeight); //based on container dimensions
        fft_plot.setAllFontProperties("Arial", 0, 14);
        fft_plot.getXAxis().setAxisLabelText("Frequency (Hz)");
        fft_plot.getYAxis().setAxisLabelText("Amplitude (uV)");
        fft_plot.setMar(60, 70, 40, 30); //{ bot=60, left=70, top=40, right=30 } by default
        fft_plot.setLogScale("y");

        fft_plot.setYLim(0.1, yLim);
        int _nTicks = int(yLim/10 - 1); //number of axis subdivisions
        fft_plot.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
        fft_plot.setXLim(0.1, xLim);
        fft_plot.getYAxis().setDrawTickLabels(true);
        fft_plot.setPointSize(2);
        fft_plot.setPointColor(0);
        fft_plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        fft_plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        fft_plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        fft_plot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        fft_plot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        fft_plot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);

        //setup points of fft point arrays
        for (int i = 0; i < fft_points.length; i++) {
            fft_points[i] = new GPointsArray(FFT_indexLim);
        }

        //fill fft point arrays
        for (int i = 0; i < fft_points.length; i++) { //loop through each channel
            for (int j = 0; j < FFT_indexLim; j++) {
                GPoint temp = new GPoint(j, 0);
                fft_points[i].set(j, temp);
            }
        }

        //map fft point arrays to fft plots
        fft_plot.setPoints(fft_points[0]);
    }

    void update(){

        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
        float sr = currentBoard.getSampleRate();
        int nfft = getNfftSafe();

        //update the points of the FFT channel arrays for all channels
        for (int i = 0; i < fft_points.length; i++) {
            for (int j = 0; j < FFT_indexLim + 2; j++) {  //loop through frequency domain data, and store into points array
                GPoint powerAtBin = new GPoint((1.0*sr/nfft)*j, fftBuff[i].getBand(j));
                fft_points[i].set(j, powerAtBin);
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
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        //draw FFT Graph w/ all plots
        noStroke();
        fft_plot.beginDraw();
        fft_plot.drawBackground();
        fft_plot.drawBox();
        fft_plot.drawXAxis();
        fft_plot.drawYAxis();
        fft_plot.drawGridLines(GPlot.BOTH);
        //Update and draw active channels that have been selected via channel select for this widget
        for (int j = 0; j < fftChanSelect.activeChan.size(); j++) {
            int chan = fftChanSelect.activeChan.get(j);
            fft_plot.setLineColor(lineColor[chan]);
            //remap fft point arrays to fft plots
            fft_plot.setPoints(fft_points[chan]);
            fft_plot.drawLines();
        }  
        fft_plot.endDraw();

        //for this widget need to redraw the grey bar, bc the FFT plot covers it up...
        fill(200, 200, 200);
        rect(x, y - navHeight, w, navHeight); //button bar

        popStyle();

        fftChanSelect.draw();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //update position/size of FFT plot
        fft_plot.setPos(x, y-navHeight);//update position
        fft_plot.setOuterDim(w, h+navHeight);//update dimensions

        fftChanSelect.screenResized(pApplet);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        fftChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }

    void flexGPlotSizeAndPosition() {
        if (fftChanSelect.isVisible()) {
                fft_plot.setPos(x, y);
                fft_plot.setOuterDim(w, h);
        } else {
            fft_plot.setPos(x, y - navHeight);
            fft_plot.setOuterDim(w, h + navHeight);
        }
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//triggered when there is an event in the MaxFreq. Dropdown
void MaxFreq(int n) {
    /* request the selected item based on index n */
    w_fft.fft_plot.setXLim(0.1, w_fft.xLimOptions[n]); //update the xLim of the FFT_Plot
    settings.fftMaxFrqSave = n; //save the xLim to variable for save/load settings
}

//triggered when there is an event in the VertScale Dropdown
void VertScale(int n) {

    w_fft.fft_plot.setYLim(0.1, w_fft.yLimOptions[n]); //update the yLim of the FFT_Plot
    settings.fftMaxuVSave = n; //save the yLim to variable for save/load settings
}

//triggered when there is an event in the LogLin Dropdown
void LogLin(int n) {
    if (n==0) {
        w_fft.fft_plot.setLogScale("y");
        //store the current setting to save
        settings.fftLogLinSave = 0;
    } else {
        w_fft.fft_plot.setLogScale("");
        //store the current setting to save
        settings.fftLogLinSave = 1;
    }
}

//triggered when there is an event in the Smoothing Dropdown
void Smoothing(int n) {
    smoothFac_ind = n;
    settings.fftSmoothingSave = n;
    //since this function is called by both the BandPower and FFT Widgets the dropdown needs to be updated in both
    w_fft.cp5_widget.getController("Smoothing").getCaptionLabel().setText(settings.fftSmoothingArray[n]);
    w_bandPower.cp5_widget.getController("Smoothing").getCaptionLabel().setText(settings.fftSmoothingArray[n]);

}

//triggered when there is an event in the UnfiltFilt Dropdown
void UnfiltFilt(int n) {
    settings.fftFilterSave = n;
    if (n==0) {
        //have FFT use filtered data -- default
        isFFTFiltered = true;
    } else {
        //have FFT use unfiltered data
        isFFTFiltered = false;
    }
    //since this function is called by both the BandPower and FFT Widgets the dropdown needs to be updated in both
    w_fft.cp5_widget.getController("UnfiltFilt").getCaptionLabel().setText(settings.fftFilterArray[n]);
    w_bandPower.cp5_widget.getController("UnfiltFilt").getCaptionLabel().setText(settings.fftFilterArray[n]);
}
