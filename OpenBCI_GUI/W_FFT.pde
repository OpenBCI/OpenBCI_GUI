
////////////////////////////////////////////////////
//
// This class creates an FFT Plot separate from the old Gui_Manager
// It extends the Widget class
//
// Conor Russomanno, November 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////

//fft global variables
int Nfft; //125Hz, 200Hz, 250Hz -> 256points. 1000Hz -> 1024points. 1600Hz -> 2048 points.  //prev: Use N=256 for normal, N=512 for MU waves
float fs_Hz;
FFT[] fftBuff = new FFT[nchan];    //from the minim library
boolean isFFTFiltered = true; //yes by default ... this is used in dataProcessing.pde to determine which uV array feeds the FFT calculation

class W_fft extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde

  //put your custom variables here...
  GPlot fft_plot; //create an fft plot for each active channel
  GPointsArray[] fft_points;  //create an array of points for each channel of data (4, 8, or 16)
  int[] lineColor = {
    (int)color(129, 129, 129),
    (int)color(124, 75, 141),
    (int)color(54, 87, 158),
    (int)color(49, 113, 89),
    (int)color(221, 178, 13),
    (int)color(253, 94, 52),
    (int)color(224, 56, 45),
    (int)color(162, 82, 49),
    (int)color(129, 129, 129),
    (int)color(124, 75, 141),
    (int)color(54, 87, 158),
    (int)color(49, 113, 89),
    (int)color(221, 178, 13),
    (int)color(253, 94, 52),
    (int)color(224, 56, 45),
    (int)color(162, 82, 49)
  };

  int[] xLimOptions = {20, 40, 60, 120};
  int[] yLimOptions = {10, 50, 100, 1000};

  int xLim = xLimOptions[2];  //maximum value of x axis ... in this case 20 Hz, 40 Hz, 60 Hz, 120 Hz
  int xMax = xLimOptions[3];
  int FFT_indexLim = int(1.0*xMax*(Nfft/getSampleRateSafe()));   // maxim value of FFT index
  int yLim = 100;  //maximum value of y axis ... 100 uV

  W_fft(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("MaxFreq", "Max Freq", Arrays.asList("20 Hz", "40 Hz", "60 Hz", "120 Hz"), 2);
    addDropdown("VertScale", "Max uV", Arrays.asList("10 uV", "50 uV", "100 uV", "1000 uV"), 2);
    addDropdown("LogLin", "Log/Lin", Arrays.asList("Log", "Linear"), 0);
    addDropdown("Smoothing", "Smooth", Arrays.asList("0.0", "0.5", "0.75", "0.9", "0.95", "0.98"), smoothFac_ind); //smoothFac_ind is a global variable at the top of W_headPlot.pde
    addDropdown("UnfiltFilt", "Filters?", Arrays.asList("Filtered", "Unfilt."), 0);

    fft_points = new GPointsArray[nchan];
    println(fft_points.length);
    initializeFFTPlot(_parent);

  }

  void initializeFFTPlot(PApplet _parent) {
    //setup GPlot for FFT
    fft_plot =  new GPlot(_parent, x, y-navHeight, w, h+navHeight); //based on container dimensions
    fft_plot.getXAxis().setAxisLabelText("Frequency (Hz)");
    fft_plot.getYAxis().setAxisLabelText("Amplitude (uV)");
    //fft_plot.setMar(50,50,50,50); //{ bot=60, left=70, top=40, right=30 } by default
    fft_plot.setMar(60, 70, 40, 30); //{ bot=60, left=70, top=40, right=30 } by default
    fft_plot.setLogScale("y");

    fft_plot.setYLim(0.1, yLim);
    int _nTicks = int(yLim/10 - 1); //number of axis subdivisions
    fft_plot.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
    fft_plot.setXLim(0.1, xLim);
    fft_plot.getYAxis().setDrawTickLabels(true);
    fft_plot.setPointSize(2);
    fft_plot.setPointColor(0);

    //setup points of fft point arrays
    for (int i = 0; i < fft_points.length; i++) {
      fft_points[i] = new GPointsArray(FFT_indexLim);
    }

    //fill fft point arrays
    for (int i = 0; i < fft_points.length; i++) { //loop through each channel
      for (int j = 0; j < FFT_indexLim; j++) {
        //GPoint temp = new GPoint(i, 15*noise(0.1*i));
        //println(i + " " + j);
        GPoint temp = new GPoint(j, 0);
        fft_points[i].set(j, temp);
      }
    }

    //map fft point arrays to fft plots
    fft_plot.setPoints(fft_points[0]);
  }

  void update(){

    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
    //update the points of the FFT channel arrays
    //update fft point arrays
    // println("LENGTH = " + fft_points.length);
    // println("LENGTH = " + fftBuff.length);
    // println("LENGTH = " + FFT_indexLim);
    for (int i = 0; i < fft_points.length; i++) {
      for (int j = 0; j < FFT_indexLim + 2; j++) {  //loop through frequency domain data, and store into points array
        //GPoint powerAtBin = new GPoint(j, 15*random(0.1*j));
        GPoint powerAtBin;

        // println("i = " + i);
        // float a = getSampleRateSafe();
        // float aa = fftBuff[i].getBand(j);
        // float b = fftBuff[i].getBand(j);
        // float c = Nfft;

        powerAtBin = new GPoint((1.0*getSampleRateSafe()/Nfft)*j, fftBuff[i].getBand(j));
        fft_points[i].set(j, powerAtBin);
        // GPoint powerAtBin = new GPoint((1.0*getSampleRateSafe()/Nfft)*j, fftBuff[i].getBand(j));

        //println("=========================================");
        //println(j);
        //println(fftBuff[i].getBand(j) + " :: " + fft_points[i].getX(j) + " :: " + fft_points[i].getY(j));
        //println("=========================================");
      }
    }

    //remap fft point arrays to fft plots
    fft_plot.setPoints(fft_points[0]);

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();

    //draw FFT Graph w/ all plots
    noStroke();
    fft_plot.beginDraw();
    fft_plot.drawBackground();
    fft_plot.drawBox();
    fft_plot.drawXAxis();
    fft_plot.drawYAxis();
    //fft_plot.drawTopAxis();
    //fft_plot.drawRightAxis();
    //fft_plot.drawTitle();
    fft_plot.drawGridLines(2);
    //here is where we will update points & loop...
    for (int i = 0; i < fft_points.length; i++) {
      fft_plot.setLineColor(lineColor[i]);
      fft_plot.setPoints(fft_points[i]);
      fft_plot.drawLines();
      // fft_plot.drawPoints(); //draw points
    }
    fft_plot.endDraw();

    //for this widget need to redraw the grey bar, bc the FFT plot covers it up...
    fill(200, 200, 200);
    rect(x, y - navHeight, w, navHeight); //button bar

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    //update position/size of FFT plot
    fft_plot.setPos(x, y-navHeight);//update position
    fft_plot.setOuterDim(w, h+navHeight);//update dimensions

  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...

  }

};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//triggered when there is an event in the MaxFreq. Dropdown
void MaxFreq(int n) {
  /* request the selected item based on index n */
  w_fft.fft_plot.setXLim(0.1, w_fft.xLimOptions[n]); //update the xLim of the FFT_Plot
  closeAllDropdowns();
}

//triggered when there is an event in the VertScale Dropdown
void VertScale(int n) {

  w_fft.fft_plot.setYLim(0.1, w_fft.yLimOptions[n]); //update the yLim of the FFT_Plot
  closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void LogLin(int n) {
  if (n==0) {
    w_fft.fft_plot.setLogScale("y");
  } else {
    w_fft.fft_plot.setLogScale("");
  }
  closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void Smoothing(int n) {
  smoothFac_ind = n;
  closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void UnfiltFilt(int n) {
  if (n==0) {
    //have FFT use filtered data -- default
    isFFTFiltered = true;
  } else {
    //have FFT use unfiltered data
    isFFTFiltered = false;
  }
  closeAllDropdowns();
}
