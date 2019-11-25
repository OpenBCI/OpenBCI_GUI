
import processing.pdf.*;
import grafica.*;

GPlot plot;

void setup() {
  size(500, 350, PDF, "graficaPlot.pdf");
  textMode(SHAPE);
  
  // Prepare the points for the plot
  int nPoints = 100;
  GPointsArray points = new GPointsArray(nPoints);

  for (int i = 0; i < nPoints; i++) {
    points.add(i, 10*noise(0.1*i));
  }

  // Create a new plot and set its position on the screen
  plot = new GPlot(this);
  plot.setPos(25, 25);
  // or all in one go
  // plot = new GPlot(this, 25, 25);

  // Set the plot title and the axis labels
  plot.setTitleText("A very simple example");
  plot.getXAxis().setAxisLabelText("x axis");
  plot.getYAxis().setAxisLabelText("y axis");

  // Add the points
  plot.setPoints(points);
}

void draw(){
  background(150);

  // Draw it!
  plot.defaultDraw();
  exit();
}
