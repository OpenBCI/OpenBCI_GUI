
import grafica.*;
import java.util.Random;

int padding = 25;
Random r = new Random();
boolean logScale_FFT;

int nPoints = 60;
GPlot plot, plot2;
GPointsArray points, points2;

int widthOfLastScreen;
int heightOfLastScreen;

void setup() {
  size(1024, 768);
  background(255,0,0);
  
  frameRate(30);
  
  surface.setResizable(true);
  widthOfLastScreen = width; //for screen resizing (Thank's Tao)
  heightOfLastScreen = height;

  // Prepare the points for the plot
  points = new GPointsArray(nPoints);
  points2 = new GPointsArray(nPoints);
  
  for (int i = 0; i < nPoints; i++) {
    points.add(i, 15*noise(0.1*i));
  }
  
  for (int i = 0; i < nPoints; i++) {
    float x = 10 + random(200);
    float y = 10*exp(0.015*x);
    float xErr = 2*((float) r.nextGaussian());
    float yErr = 2*((float) r.nextGaussian());
    points2.add(x + xErr, y + yErr);
  }

  // Create a new plot and set its position on the screen
  plot = new GPlot(this, padding, padding, (width-(4*padding))/2, 300);
  plot2 = new GPlot(this, width/2 + padding, padding, (width-(4*padding))/2, 300);
  plot.setPos(padding, padding);
  //plot2.setPos(padding, padding);
  // or all in one go
  // GPlot plot = new GPlot(this, 25, 25);
  
  logScale_FFT = true;

  // Set the plot title and the axis labels
  plot.setTitleText("EEG Montage");
  plot.getXAxis().setAxisLabelText("x axis");
  plot.getYAxis().setAxisLabelText("y axis");
  
  //plot 2
  plot2.setTitleText("FFT Plot");
  plot2.getXAxis().setAxisLabelText("x axis");
  plot2.getYAxis().setAxisLabelText("y axis");
  //plot2.setMar(50,50,50,50); //{ bot=60, left=70, top=40, right=30 } by default
  plot2.setMar(60,70,40,30); //{ bot=60, left=70, top=40, right=30 } by default
  plot2.setLogScale("y");
  
  int upperY = 100;
  plot2.setYLim(0.1,100);
  int _nTicks = int(upperY/10 - 1);
  plot2.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
  plot2.setXLim(0.1,60);
  plot2.getYAxis().setDrawTickLabels(true);
  plot2.setPointSize(2);
  plot2.setPointColor(0);
  
  //plot2.setLogScale(""); //sets it back to non-logarithmic

  // Add the points
  plot.setPoints(points);
  plot2.setPoints(points);
}

void draw(){
  
  if (widthOfLastScreen != width || heightOfLastScreen != height) {
    println("OpenBCI_GUI: setup: RESIZED");
    //screenHasBeenResized = true;
    //timeOfLastScreenResize = millis();
    updateGraphs();
    widthOfLastScreen = width;
    heightOfLastScreen = height;
  }
  
  //updatePoints
  for (int i = 0; i < nPoints; i++) {
    //GPoint temp = new GPoint(i, 15*noise(0.1*i));
    GPoint temp = new GPoint(i, 15*random(0.1*i));
    points.set(i, temp);
  }
  
  plot.setPoints(points);
  plot2.setPoints(points);
  
  
  // Draw it!
  plot.defaultDraw();
  
  plot2.beginDraw();
  plot2.drawBackground();
  plot2.drawBox();
  plot2.drawXAxis();
  plot2.drawYAxis();
  plot2.drawTopAxis();
  plot2.drawRightAxis();
  plot2.drawTitle();
  plot2.drawGridLines(2);
  plot2.drawLines();
  plot2.drawPoints(); //draw points
  plot2.endDraw();
  
}

void updateGraphs(){
  //plot1
  plot.setPos(padding, padding);//update position
  plot.setOuterDim((width-(4*padding))/2, 300);//update dim
  
  //plot2
  plot2.setPos(width/2 + padding, padding);//update position
  plot2.setOuterDim((width-(4*padding))/2, 300);//update dim
}

void mouseClicked() {
  // Change the log scale
  logScale_FFT = !logScale_FFT;
  
  if (logScale_FFT) {
    plot2.setLogScale("y");
    plot2.getYAxis().setAxisLabelText("log y");
  }
  else {
    plot2.setLogScale("");
    plot2.getYAxis().setAxisLabelText("y");
  }
}