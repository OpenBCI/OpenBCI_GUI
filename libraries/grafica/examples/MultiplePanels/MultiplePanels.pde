
import grafica.*;

void setup() {
  size(500, 500);
  background(255);

  float[] firstPlotPos = new float[] {0, 0};
  float[] panelDim = new float[] {200, 200};
  float[] margins = new float[] {60, 70, 40, 30};

  // Create four plots to represent the 4 panels
  GPlot plot1 = new GPlot(this);
  plot1.setPos(firstPlotPos);
  plot1.setMar(0, margins[1], margins[2], 0);
  plot1.setDim(panelDim);
  plot1.setAxesOffset(0);
  plot1.setTicksLength(-4);
  plot1.getXAxis().setDrawTickLabels(false);

  GPlot plot2 = new GPlot(this);
  plot2.setPos(firstPlotPos[0] + margins[1] + panelDim[0], firstPlotPos[1]);
  plot2.setMar(0, 0, margins[2], margins[3]);
  plot2.setDim(panelDim);
  plot2.setAxesOffset(0);
  plot2.setTicksLength(-4);
  plot2.getXAxis().setDrawTickLabels(false);
  plot2.getYAxis().setDrawTickLabels(false);

  GPlot plot3 = new GPlot(this);
  plot3.setPos(firstPlotPos[0], firstPlotPos[1] + margins[2] + panelDim[1]);
  plot3.setMar(margins[0], margins[1], 0, 0);
  plot3.setDim(panelDim);
  plot3.setAxesOffset(0);
  plot3.setTicksLength(-4);

  GPlot plot4 = new GPlot(this);
  plot4.setPos(firstPlotPos[0] + margins[1] + panelDim[0], firstPlotPos[1] + margins[2] + panelDim[1]);
  plot4.setMar(margins[0], 0, 0, margins[3]);
  plot4.setDim(panelDim);
  plot4.setAxesOffset(0);
  plot4.setTicksLength(-4);
  plot4.getYAxis().setDrawTickLabels(false);

  // Prepare the points for the four plots
  int nPoints = 21;
  GPointsArray points1 = new GPointsArray(nPoints);
  GPointsArray points2 = new GPointsArray(nPoints);
  GPointsArray points3 = new GPointsArray(nPoints);
  GPointsArray points4 = new GPointsArray(nPoints);

  for (int i = 0; i < nPoints; i++) {
    points1.add(sin(TWO_PI*i/(nPoints-1)), cos(TWO_PI*i/(nPoints-1)));
    points2.add(i, cos(TWO_PI*i/(nPoints-1)));
    points3.add(sin(TWO_PI*i/(nPoints-1)), i);
    points4.add(i, i);
  }  

  // Set the points, the title and the axis labels
  plot1.setPoints(points1);
  plot1.setTitleText("Plot with multiple panels");
  plot1.getTitle().setRelativePos(1);
  plot1.getTitle().setTextAlignment(CENTER);
  plot1.getYAxis().setAxisLabelText("cos(i)");

  plot2.setPoints(points2);

  plot3.setPoints(points3);
  plot3.getXAxis().setAxisLabelText("sin(i)");
  plot3.getYAxis().setAxisLabelText("i");
  plot3.setInvertedYScale(true);

  plot4.setPoints(points4);
  plot4.getXAxis().setAxisLabelText("i");
  plot4.setInvertedYScale(true);

  // Draw the plots
  plot1.beginDraw();
  plot1.drawBox();
  plot1.drawXAxis();
  plot1.drawYAxis();
  plot1.drawTopAxis();
  plot1.drawRightAxis();
  plot1.drawTitle();
  plot1.drawPoints();
  plot1.drawLines();
  plot1.endDraw();

  plot2.beginDraw();
  plot2.drawBox();
  plot2.drawXAxis();
  plot2.drawYAxis();
  plot2.drawTopAxis();
  plot2.drawRightAxis();
  plot2.drawPoints();
  plot2.drawLines();
  plot2.endDraw();

  plot3.beginDraw();
  plot3.drawBox();
  plot3.drawXAxis();
  plot3.drawYAxis();
  plot3.drawTopAxis();
  plot3.drawRightAxis();
  plot3.drawPoints();
  plot3.drawLines();
  plot3.endDraw();

  plot4.beginDraw();
  plot4.drawBox();
  plot4.drawXAxis();
  plot4.drawYAxis();
  plot4.drawTopAxis();
  plot4.drawRightAxis();
  plot4.drawPoints();
  plot4.drawLines();
  plot4.endDraw();
}
