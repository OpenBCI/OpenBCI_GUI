
import grafica.*;
import java.util.Random;

public GPlot plot1, plot2, plot3, plot4;
public GPointsArray polygonPoints;
public float[] gaussianStack;
public float[] uniformStack;
public int gaussianCounter;
public int uniformCounter;
public PImage mug;
public PShape star;
public Random r;

public void setup() {
  size(850, 650);

  // Prepare the points for the first plot  
  GPointsArray points1a = new GPointsArray(500);
  GPointsArray points1b = new GPointsArray(500);
  GPointsArray points1c = new GPointsArray(500);

  for (int i = 0; i < 500; i++) {
    points1a.add(i, noise(0.1*i) + 1, "point " + i);
    points1b.add(i, noise(500 + 0.1*i) + 0.5, "point " + i);
    points1c.add(i, noise(1000 + 0.1*i), "point " + i);
  }

  // Create a polygon to display inside the plot  
  polygonPoints = new GPointsArray(5);
  polygonPoints.add(2, 0.15);
  polygonPoints.add(6, 0.12);
  polygonPoints.add(15, 0.3);
  polygonPoints.add(8, 0.6);
  polygonPoints.add(1.5, 0.5);

  // Setup for the first plot
  plot1 = new GPlot(this);
  plot1.setPos(0, 0);
  plot1.setXLim(1, 100);
  plot1.setYLim(0.1, 3);
  plot1.getTitle().setText("Multiple layers plot");
  plot1.getXAxis().getAxisLabel().setText("Time");
  plot1.getYAxis().getAxisLabel().setText("noise (0.1 time)");
  plot1.setLogScale("xy");
  plot1.setPoints(points1a);
  plot1.setLineColor(color(200, 200, 255));
  plot1.addLayer("layer 1", points1b);
  plot1.getLayer("layer 1").setLineColor(color(150, 150, 255));
  plot1.addLayer("layer 2", points1c);
  plot1.getLayer("layer 2").setLineColor(color(100, 100, 255));


  // Leave empty the points for the second plot. We will fill them in draw()

  // Setup for the second plot 
  plot2 = new GPlot(this);
  plot2.setPos(460, 0);
  plot2.setDim(250, 250);
  plot2.getTitle().setText("Mouse position");
  plot2.getXAxis().getAxisLabel().setText("mouseX");
  plot2.getYAxis().getAxisLabel().setText("-mouseY");


  // Prepare the points for the third plot
  gaussianStack = new float[10];
  gaussianCounter = 0;
  r = new Random();

  for (int i = 0; i < 20; i++) {
    int index = int(gaussianStack.length/2 + (float) r.nextGaussian());

    if (index >= 0 && index < gaussianStack.length) {
      gaussianStack[index]++;
      gaussianCounter++;
    }
  }

  GPointsArray points3 = new GPointsArray(gaussianStack.length);

  for (int i = 0; i < gaussianStack.length; i++) {
    points3.add(i + 1 - gaussianStack.length/2.0, gaussianStack[i]/gaussianCounter, "H" + i);
  }

  // Setup for the third plot 
  plot3 = new GPlot(this);
  plot3.setPos(0, 300);
  plot3.setDim(250, 250);
  plot3.setYLim(-0.02, 0.45);
  plot3.setXLim(5, -5);
  plot3.getTitle().setText("Gaussian distribution (" + str(gaussianCounter) + " points)");
  plot3.getTitle().setTextAlignment(LEFT);
  plot3.getTitle().setRelativePos(0);
  plot3.getYAxis().getAxisLabel().setText("Relative probability");
  plot3.getYAxis().getAxisLabel().setTextAlignment(RIGHT);
  plot3.getYAxis().getAxisLabel().setRelativePos(1);
  plot3.setPoints(points3);
  plot3.startHistograms(GPlot.VERTICAL);
  plot3.getHistogram().setDrawLabels(true);
  plot3.getHistogram().setRotateLabels(true);
  plot3.getHistogram().setBgColors(new color[] {
    color(0, 0, 255, 50), color(0, 0, 255, 100), 
    color(0, 0, 255, 150), color(0, 0, 255, 200)
  }
  );

  // Prepare the points for the fourth plot  
  uniformStack = new float[30];
  uniformCounter = 0;

  for (int i = 0; i < 20; i++) {
    int index = int(uniformStack.length/2 + random(uniformStack.length));

    if (index >= 0 && index < uniformStack.length) {
      uniformStack[index]++;
      uniformCounter++;
    }
  }

  GPointsArray points4 = new GPointsArray(uniformStack.length);

  for (int i = 0; i < uniformStack.length; i++) {
    points4.add(i + 1 - uniformStack.length/2.0, uniformStack[i]/uniformCounter, "point " + i);
  }

  // Setup for the fourth plot 
  plot4 = new GPlot(this);
  plot4.setPos(370, 350);
  plot4.setYLim(-0.005, 0.1);
  plot4.getTitle().setText("Uniform distribution (" + str(uniformCounter) + " points)");
  plot4.getTitle().setTextAlignment(LEFT);
  plot4.getTitle().setRelativePos(0.1);
  plot4.getXAxis().getAxisLabel().setText("x variable");
  plot4.getYAxis().getAxisLabel().setText("Relative probability");
  plot4.setPoints(points4);
  plot4.startHistograms(GPlot.VERTICAL);

  // Setup the mouse actions
  plot1.activatePanning();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePointLabels();
  plot2.activateZooming(1.5);
  plot3.activateCentering(LEFT, GPlot.CTRLMOD);
  plot4.activateZooming();

  // Load some images and shapes to use later in the plots
  mug = loadImage("beermug.png");
  mug.resize(int(0.7*mug.width), int(0.7*mug.height));
  star = loadShape("star.svg");
  star.disableStyle();
}


public void draw() {
  background(255);

  // Draw the first plot
  plot1.beginDraw();
  plot1.drawBackground();
  plot1.drawBox();
  plot1.drawXAxis();
  plot1.drawYAxis();
  plot1.drawTopAxis();
  plot1.drawRightAxis();
  plot1.drawTitle();
  plot1.drawFilledContours(GPlot.HORIZONTAL, 0.05);
  plot1.drawPoint(new GPoint(65, 1.5), mug);
  plot1.drawPolygon(polygonPoints, color(255, 200));
  plot1.drawLabels();
  plot1.endDraw();


  // Add a new point to the second plot if the mouse moves significantly
  GPoint lastPoint = plot2.getPointsRef().getLastPoint();

  if (lastPoint == null) {
    plot2.addPoint(mouseX, -mouseY, "(" + str(mouseX) + " , " + str(mouseY) + ")");
  } 
  else if (!lastPoint.isValid() || sq(lastPoint.getX() - mouseX) + sq(lastPoint.getY() + mouseY) > 2500) {
    plot2.addPoint(mouseX, -mouseY, "(" + str(mouseX) + " , " + str(-mouseY) + ")");
  }

  // Reset the points if the user pressed the space bar
  if (keyPressed && key == ' ') {
    plot2.setPoints(new GPointsArray());
  }

  // Draw the second plot  
  plot2.beginDraw();
  plot2.drawBackground();
  plot2.drawBox();
  plot2.drawXAxis();
  plot2.drawYAxis();
  plot2.drawTitle();
  plot2.drawGridLines(GPlot.BOTH);
  plot2.drawLines();
  plot2.drawPoints(star);
  plot2.endDraw();


  // Add one more point to the gaussian stack
  int index = int(gaussianStack.length/2 + (float) r.nextGaussian());

  if (index >= 0 && index < gaussianStack.length) {
    gaussianStack[index]++;
    gaussianCounter++;

    GPointsArray points3 = new GPointsArray(gaussianStack.length);

    for (int i = 0; i < gaussianStack.length; i++) {
      points3.add(i + 0.5 - gaussianStack.length/2.0, gaussianStack[i]/gaussianCounter, "H" + i);
    }

    plot3.setPoints(points3);
    plot3.getTitle().setText("Gaussian distribution (" + str(gaussianCounter) + " points)");
  }

  // Draw the third plot  
  plot3.beginDraw();
  plot3.drawBackground();
  plot3.drawBox();
  plot3.drawYAxis();
  plot3.drawTitle();
  plot3.drawHistograms();
  plot3.endDraw();


  // Actions over the fourth plot (scrolling)
  if (plot4.isOverBox(mouseX, mouseY)) {
    // Get the cursor relative position inside the inner plot area
    float[] relativePos = plot4.getRelativePlotPosAt(mouseX, mouseY);

    // Move the x axis 
    if (relativePos[0] < 0.2) {
      plot4.moveHorizontalAxesLim(2);
    }
    else if (relativePos[0] > 0.8) {
      plot4.moveHorizontalAxesLim(-2);
    }

    // Move the y axis 
    if (relativePos[1] < 0.2) {
      plot4.moveVerticalAxesLim(2);
    } 
    else if (relativePos[1] > 0.8) {
      plot4.moveVerticalAxesLim(-2);
    }

    // Change the inner area bg color
    plot4.setBoxBgColor(color(200, 100));
  }
  else {
    plot4.setBoxBgColor(color(200, 50));
  }

  // Add one more point to the uniform stack
  index = int(random(uniformStack.length));

  if (index >= 0 && index < uniformStack.length) {
    uniformStack[index]++;
    uniformCounter++;

    GPointsArray points4 = new GPointsArray(uniformStack.length);

    for (int i = 0; i < uniformStack.length; i++) {
      points4.add(i + 0.5 - uniformStack.length/2.0, uniformStack[i]/uniformCounter, "point " + i);
    }

    plot4.setPoints(points4);
    plot4.getTitle().setText("Uniform distribution (" + str(uniformCounter) + " points)");
  }

  // Draw the forth plot  
  plot4.beginDraw();
  plot4.drawBackground();
  plot4.drawBox();
  plot4.drawXAxis();
  plot4.drawYAxis();
  plot4.drawTitle();
  plot4.drawHistograms();
  plot4.endDraw();
}
