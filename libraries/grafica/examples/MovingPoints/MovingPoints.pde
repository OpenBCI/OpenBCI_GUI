
import grafica.*;

GPlot plot;
int step = 0;
int stepsPerCycle = 100;
int lastStepTime = 0;
boolean clockwise = true;
float scale = 5;

void setup() {
  size(450, 450);

  // Prepare the first set of points
  int nPoints1 = stepsPerCycle/10;
  GPointsArray points1 = new GPointsArray(nPoints1);

  for (int i = 0; i < nPoints1; i++) {
    points1.add(calculatePoint(step, stepsPerCycle, scale));
    step = (clockwise)? step + 1 : step - 1;
  }

  lastStepTime = millis();

  // Prepare the second set of points
  int nPoints2 = stepsPerCycle + 1;
  GPointsArray points2 = new GPointsArray(nPoints2);

  for (int i = 0; i < nPoints2; i++) {
    points2.add(calculatePoint(i, stepsPerCycle, 0.9*scale));
  }

  // Create the plot
  plot = new GPlot(this);
  plot.setPos(25, 25);
  plot.setDim(300, 300);
  // or all in one go
  // plot = new GPlot(this, 25, 25, 300, 300);

  // Set the plot limits (this will fix them)
  plot.setXLim(-1.2*scale, 1.2*scale);
  plot.setYLim(-1.2*scale, 1.2*scale);

  // Set the plot title and the axis labels
  plot.setTitleText("Clockwise movement");
  plot.getXAxis().setAxisLabelText("x axis");
  plot.getYAxis().setAxisLabelText("y axis");

  // Activate the panning effect
  plot.activatePanning();

  // Add the two set of points to the plot
  plot.setPoints(points1);
  plot.addLayer("surface", points2);

  // Change the second layer line color
  plot.getLayer("surface").setLineColor(color(100, 255, 100));
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
  plot.getMainLayer().drawPoints();
  plot.getLayer("surface").drawFilledContour(GPlot.HORIZONTAL, 0);
  plot.endDraw();

  // Add and remove new points every 10th of a second
  if (millis() - lastStepTime > 100) {
    if (clockwise) {
      // Add the point at the end of the array
      plot.addPoint(calculatePoint(step, stepsPerCycle, scale));
      step++;

      // Remove the first point
      plot.removePoint(0);
    }
    else {
      // Add the point at the beginning of the array
      plot.addPoint(0, calculatePoint(step, stepsPerCycle, scale));
      step--;

      // Remove the last point
      plot.removePoint(plot.getPointsRef().getNPoints() - 1);
    }

    lastStepTime = millis();
  }
}

void mouseClicked() {
  // Change the movement sense
  clockwise = !clockwise;

  if (clockwise) {
    step += plot.getPointsRef().getNPoints() + 1;
    plot.setTitleText("Clockwise movement");
  } 
  else {
    step -= plot.getPointsRef().getNPoints() + 1;
    plot.setTitleText("Anti-clockwise movement");
  }
}

GPoint calculatePoint(float i, float n, float rad) {
  float delta = 0.1*cos(TWO_PI*10*i/n);
  float ang = TWO_PI*i/n;
  return new GPoint(rad*(1 + delta)*sin(ang), rad*(1 + delta)*cos(ang));
}
