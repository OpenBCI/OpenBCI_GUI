/**
 * This example was motivated by the following posts:
 * 
 * http://lisacharlotterost.github.io/2016/05/17/one-chart-tools/
 * http://lisacharlotterost.github.io/2016/05/17/one-chart-code/
 */

import grafica.*;

GPlot plot;

void setup() {
  // Define the window size
  size(750, 410);

  // Load the cvs dataset. 
  // The file has the following format: 
  // country,income,health,population
  // Central African Republic,599,53.8,4900274
  // ...
  Table table = loadTable("data.csv", "header");

  // Save the data in one GPointsArray and calculate the point sizes
  GPointsArray points = new GPointsArray();
  float[] pointSizes = new float[table.getRowCount()];
  
  for (int row = 0; row < table.getRowCount(); row++) {
    String country = table.getString(row, "country");
    float income = table.getFloat(row, "income");
    float health = table.getFloat(row, "health");
    int population = table.getInt(row, "population");
    points.add(income, health, country);
    
    // The point area should be proportional to the country population
    // population = pi * sq(diameter/2) 
    pointSizes[row] = 2 * sqrt(population/(200000 * PI));
  }

  // Create the plot
  plot = new GPlot(this);
  plot.setDim(650, 300);
  plot.setTitleText("Life expectancy connection to average income");
  plot.getXAxis().setAxisLabelText("Personal income ($/year)");
  plot.getYAxis().setAxisLabelText("Life expectancy (years)");
  plot.setLogScale("x");
  plot.setPoints(points);
  plot.setPointSizes(pointSizes);
  plot.activatePointLabels();
  plot.activatePanning();
  plot.activateZooming(1.1, CENTER, CENTER);
}

void draw() {
  // Clean the screen
  background(255);

  // Draw the plot  
  plot.beginDraw();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.drawGridLines(GPlot.BOTH);
  plot.drawPoints();
  plot.drawLabels();
  plot.endDraw();
}
