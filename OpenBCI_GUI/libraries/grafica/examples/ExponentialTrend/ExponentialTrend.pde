
import grafica.*;
import java.util.Random;

GPlot plot;
boolean logScale;
Random r = new Random();

void setup() {
  size(450, 450);

  // Prepare the points for the plot
  int nPoints = 1000;
  GPointsArray points = new GPointsArray(nPoints);

  for (int i = 0; i < nPoints; i++) {
    float x = 10 + random(200);
    float y = 10*exp(0.015*x);
    float xErr = 2*((float) r.nextGaussian());
    float yErr = 2*((float) r.nextGaussian());
    points.add(x + xErr, y + yErr);
  }

  // Create the plot
  plot = new GPlot(this);
  plot.setPos(25, 25);
  plot.setDim(300, 300);
  // or all in one go
  // plot = new GPlot(this, 25, 25, 300, 300);

  // Set the plot title and the axis labels
  plot.setTitleText("Exponential law");
  plot.getXAxis().setAxisLabelText("x");

  if(logScale){
    plot.setLogScale("y");
    plot.getYAxis().setAxisLabelText("log y");
  }
  else{
    plot.setLogScale("");
    plot.getYAxis().setAxisLabelText("y");
  }

  // Add the points to the plot
  plot.setPoints(points);
  plot.setPointColor(color(100, 100, 255, 50));
}

void draw() {
  background(150);

  plot.beginDraw();
  plot.drawBackground();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTopAxis();
  plot.drawRightAxis();
  plot.drawTitle();
  plot.drawPoints();
  plot.endDraw();
}

void mouseClicked() {
  // Change the log scale
  logScale = !logScale;

  if (logScale) {
    plot.setLogScale("y");
    plot.getYAxis().setAxisLabelText("log y");
  }
  else {
    plot.setLogScale("");
    plot.getYAxis().setAxisLabelText("y");
  }
}
