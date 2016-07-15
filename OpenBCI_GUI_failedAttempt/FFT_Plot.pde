



FFT_Plot fft;

public void initializeFFT(){
	fft = new FFT_Plot(this);
}

class FFT_Plot extends Container{

	ScatterTrace_FFT fftTrace;
	Graph2D gFFT;
	GridBackground gbMontage, gbFFT;
	TextBox titleFFT;

	//maybe necessary
	int bgColorGraphs = 255;
	int gridColor = 200;
	int borderColor = 50;
	int axisColor = 50;
	int fontColor = 255;

	int bx, by, bw, bh; //button x,y,w,h

	Button maxDisplayFreqButton;
	Button fftNButton;
	Button smoothingButton;

	float vertScale_uV = default_vertScale_uV; //default_vertScale_uV at the top of GUI_Manager.pde
	float vertScaleMin_uV_whenLog = 0.1f;
	private float[] maxDisplayFreq_Hz = {20.0f, 40.0f, 60.0f, 120.0f};
	private int maxDisplayFreq_ind = 2; 

	// float[] axisFFT_relPos = { 
 //      gutter_left + left_right_split, // + 0.1f, 
 //      up_down_split*available_top2bot + height_UI_tray + gutter_topbot, 
 //      (1f-left_right_split)-gutter_left-gutter_right, 
 //      available_top2bot*(1.0f-up_down_split) - gutter_topbot-title_gutter - spacer_top
 //    }; //from left, from top, width, height
 //    axes_x = int(float(win_x)*axisFFT_relPos[2]);  //width of the axis in pixels
 //    axes_y = int(float(win_y)*axisFFT_relPos[3]);  //height of the axis in pixels
 //    gFFT = new Graph2D(parent, int(axes_x), int(axes_y), false);  //last argument is whether the axes cross at zero
 //    setupFFTPlot(gFFT, win_x, win_y, axisFFT_relPos,fontInfo);


	FFT_Plot(PApplet parent){
		super(container[9], "WHOLE"); //grabs x, y, w, h, and other variable settings from container[9]

		gFFT = new Graph2D(parent, int(w), int(h), false);

		gFFT.setAxisColour(axisColor, axisColor, axisColor);
		gFFT.setFontColour(fontColor, fontColor, fontColor);

		gFFT.position.x = x;
		gFFT.position.y = y;
		//gFFT.position.y = 0;

		//setup the y axis
		gFFT.setYAxisMin(vertScaleMin_uV_whenLog);
		gFFT.setYAxisMax(vertScale_uV);
		gFFT.setYAxisTickSpacing(1);
		gFFT.setYAxisMinorTicks(0);
		gFFT.setYAxisLabelAccuracy(0);
		//gFFT.setYAxisLabel("EEG Amplitude (uV/sqrt(Hz))");  // Some people prefer this...but you'll have to change the normalization in OpenBCI_GUI\processNewData()
		gFFT.setYAxisLabel("EEG Amplitude (uV per bin)");  // CHIP 2014-10-24...currently, this matches the normalization in OpenBCI_GUI\processNewData()
		gFFT.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
		gFFT.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);

		//get the Y-axis and make it log
		Axis2D ay=gFFT.getYAxis();
		ay.setLogarithmicAxis(true);

		//setup the x axis
		gFFT.setXAxisMin(0f);
		gFFT.setXAxisMax(maxDisplayFreq_Hz[maxDisplayFreq_ind]); //default to 60 Hz
		gFFT.setXAxisTickSpacing(10f);
		gFFT.setXAxisMinorTicks(2);
		gFFT.setXAxisLabelAccuracy(0);
		gFFT.setXAxisLabel("Frequency (Hz)");
		gFFT.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
		gFFT.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);

		// switching on Grid, with differetn colours for X and Y lines
		gbFFT = new  GridBackground(new GWColour(bgColorGraphs));
		gbFFT.setGridColour(gridColor, gridColor, gridColor, gridColor, gridColor, gridColor);
		gFFT.setBackground(gbFFT);

		gFFT.setBorderColour(borderColor,borderColor,borderColor);

		// add title
		titleFFT = new TextBox("FFT Plot",0,0);
		int x2 = int(x) + int(w/2);
		int y2 = int(y) - 2;  //deflect two pixels upward
		titleFFT.x = x2;
		titleFFT.y = y2;
		titleFFT.textColor = color(255,255,255);
		titleFFT.setFontSize(16);
		titleFFT.alignH = CENTER;

		//buttons
		bx = 0;
    	by = 2;      //button y position, measured top
    	bw = 80; //button width
		bh = 26;     //button height, was 25
		float gutter_between_buttons = 0.005f; //space between buttons
		
		bx = calcButtonXLocation(Ibut++, win_x, w, width/2, gutter_between_buttons);
    	maxDisplayFreqButton = new Button(x,y,w,h,"Max Freq\n" + round(maxDisplayFreq_Hz[maxDisplayFreq_ind]) + " Hz",fontInfo.buttonLabel_size);
	}

	public void initializeFFTTraces(ScatterTrace_FFT fftTrace,FFT[] fftBuff,float[] fftYOffset,Graph2D gFFT) {
	    for (int Ichan = 0; Ichan < fftYOffset.length; Ichan++) {
			//set the Y-offste for the individual traces in the plots
			fftYOffset[Ichan]= 0f;  //set so that there is no additional offset
	    }
	    
	    //make the trace for the FFT and add it to the FFT Plot axis
	    //fftTrace = new ScatterTrace_FFT(fftBuff); //can't put this here...must be in setup()
	    fftTrace.setYOffset(fftYOffset);
	    gFFT.addTrace(fftTrace);
	}

	public void setMaxDisplayFreq_ind(int ind) {
		maxDisplayFreq_ind = max(0,ind);
		if (ind >= maxDisplayFreq_Hz.length) maxDisplayFreq_ind = 0;
		updateMaxDisplayFreq();
	}

	public void incrementMaxDisplayFreq() {
		setMaxDisplayFreq_ind(maxDisplayFreq_ind+1);  //wrap-around is handled inside the function
	}

	public void updateMaxDisplayFreq() {
		//set the frequency limit of the display
		float foo_Hz = maxDisplayFreq_Hz[maxDisplayFreq_ind];
		gFFT.setXAxisMax(foo_Hz);
		if (fftTrace != null) fftTrace.set_plotXlim(0.0f,foo_Hz);
		//gSpectrogram.setYAxisMax(foo_Hz);

		//set the ticks
		if (foo_Hz < 38.0f) {
			foo_Hz = 5.0f;
			} else if (foo_Hz < 78.0f) {
			foo_Hz = 10.0f;
			} else if (foo_Hz < 168.0f) {
			foo_Hz = 20.0f;
			} else {
			foo_Hz = (float)floor(foo_Hz / 50.0) * 50.0f;
		}
		gFFT.setXAxisTickSpacing(foo_Hz);
		//gSpectrogram.setYAxisTickSpacing(foo_Hz);

		if (maxDisplayFreqButton != null) maxDisplayFreqButton.setString("Max Freq\n" + round(maxDisplayFreq_Hz[maxDisplayFreq_ind]) + " Hz");
	}  
};






















