
////////////////////////////////////////////////////
//
// This class creates an FFT Plot separate from the old Gui_Manager
//
// Conor Russomanno, July 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////


import grafica.*;
import java.util.Random;

FFT_Widget fft_widget;


class FFT_Widget {

  int x, y, w, h; 
  int[] positioning = {0, 0, 0, 0}; // {x0, y0, w, h} retreived from corresponding container
  GPlot fft_plot; //create an fft plot for each active channel
  GPointsArray[] fft_points = new GPointsArray[nchan]; //create an array of points for each channel of data (4, 8, or 16)

  int nPoints = 256; //resolution of FFT plots

  int parentContainer = 7; //which container is it mapped to by default?

  int[] lineColor = {
    (int)color(129, 129, 129), 
    (int)color(124, 75, 141), 
    (int)color(54, 87, 158), 
    (int)color(49, 113, 89), 
    (int)color(221, 178, 13), 
    (int)color(253, 94, 52), 
    (int)color(224, 56, 45), 
    (int)color(162, 82, 49)

  };

  int xLim = 60;  //maximum value of x axis ... in this case 20 Hz, 40 Hz, 60 Hz, 120 Hz
  int yLim = 100;  //maximum value of y axis ... 100 uV

  //constructor 1
  FFT_Widget(PApplet parent) {
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    //setup GPlot for FFT
    fft_plot =  new GPlot(parent, x, y+navHeight, w, h-navHeight); //based on container dimensions
    fft_plot.getXAxis().setAxisLabelText("Frequency (Hz)");
    fft_plot.getYAxis().setAxisLabelText("EEG Amplitude (uV per bin)");
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
      fft_points[i] = new GPointsArray(xLim);
    }

    //fill fft point arrays
    for (int i = 0; i < fft_points.length; i++) {
      for (int j = 0; j < xLim; j++) {
        //GPoint temp = new GPoint(i, 15*noise(0.1*i));
        //println(i + " " + j);
        GPoint temp = new GPoint(j, 15*random(0.1*j));
        fft_points[i].set(j, temp);
      }
    }

    //map fft point arrays to fft plots
    fft_plot.setPoints(fft_points[0]);
  }

  void update() {

    //update position/size of FFT Plot
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;
    fft_plot.setPos(x, y+navHeight);//update position
    fft_plot.setOuterDim(w, h-navHeight);//update dimensions

    //update the points of the FFT channel arrays
    //update fft point arrays
    for (int i = 0; i < fft_points.length; i++) {
      for (int j = 0; j < xLim + 1; j++) {  //loop through frequency domain data, and store into points array
        //GPoint powerAtBin = new GPoint(j, 15*random(0.1*j));
        GPoint powerAtBin = new GPoint(j, fftBuff[i].getBand(j));
        fft_points[i].set(j, powerAtBin);
        //println("=========================================");
        //println(j);
        //println(fftBuff[i].getBand(j) + " :: " + fft_points[i].getX(j) + " :: " + fft_points[i].getY(j));
        //println("=========================================");
      }
    }

    //remap fft point arrays to fft plots
    fft_plot.setPoints(fft_points[0]);
  }

  void draw() {
    pushStyle();

    //draw FFT Graph w/ all plots
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
      fft_plot.drawPoints(); //draw points
    }
    fft_plot.endDraw();

    fill(200, 200, 200);
    rect(x, y, w, navHeight); //top bar
    fill(bgColor);
    textSize(18);
    text("FFT Plot", x+w/2, y+navHeight/2);
    //fill(255,0,0,150);
    //rect(x,y,w,h);

    popStyle();
  }
}