
import grafica.*;
 
GPlot plot1, plot2;
 
void setup() {
  size(440, 420);
 
  // Create the first plot
  plot1 = new GPlot(this);
  plot1.setPos(0, 0);
  plot1.setMar(60, 70, 40, 70);
  plot1.setDim(300, 300);
  plot1.setAxesOffset(4);
  plot1.setTicksLength(4);
 
  // Create the second plot with the same dimensions
  plot2 = new GPlot(this);
  plot2.setPos(plot1.getPos());
  plot2.setMar(plot1.getMar());
  plot2.setDim(plot1.getDim());
  plot2.setAxesOffset(4);
  plot2.setTicksLength(4);
 
  // Prepare the points
  int nPoints = 50;
  GPointsArray points = new GPointsArray(nPoints);
 
  for (int i = 0; i < nPoints; i++) {
    points.add(i, 30 + 10*noise(i*0.1));
  }  
 
  // Set the points, the title and the axis labels
  plot1.setPoints(points);
  plot1.setTitleText("Temperature");
  plot1.getYAxis().setAxisLabelText("T (Celsius)");
  plot1.getXAxis().setAxisLabelText("Time (minutes)");
 
  plot2.getRightAxis().setAxisLabelText("T (Kelvin)");
 
  // Make the right axis of the second plot visible
  plot2.getRightAxis().setDrawTickLabels(true);
 
  // Activate the panning (only for the first plot)
  plot1.activatePanning();
}
 
void draw() {
  background(255);
 
  // Draw the first plot
  plot1.beginDraw();
  plot1.drawBox();
  plot1.drawXAxis();
  plot1.drawYAxis();
  plot1.drawTitle();
  plot1.drawPoints();
  plot1.drawLines();
  plot1.endDraw();
 
  // Change the second plot vertical scale from Celsius to Kelvin
  plot2.setYLim(celsiusToKelvin(plot1.getYLim()));
 
  // Draw only the right axis
  plot2.beginDraw();
  plot2.drawRightAxis();
  plot2.endDraw();
}
 
//
// Transforms from degree Celsius to degree Kelvin
//
float[] celsiusToKelvin(float[] celsius){
  float[] kelvin = new float[celsius.length];
 
  for(int i = 0; i < celsius.length; i++){
    kelvin[i] = 273.15 + celsius[i];
  }
 
  return kelvin;
}