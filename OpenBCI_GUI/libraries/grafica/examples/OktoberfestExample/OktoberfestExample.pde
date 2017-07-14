
import grafica.*;

String[] monthNames = new String[] {"January", "February", "March", "April", "May", "June", "July", 
                                     "August", "September", "October", "November", "December"};
int[] daysPerMonth = new int[] {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
int[] daysPerMonthLeapYear = new int[] {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

GPlot plot;

void setup() {
  size(800, 400);

  // Load the Oktoberfest vs. Bundestagswahl (German elections day) Google 
  // search history file (obtained from the Google trends page). 
  // The csv file has the following format: 
  // year,month,day,oktoberfest,bundestagswahl
  // 2004,0,1,5,1
  // ...
  Table table = loadTable("OktoberfestVSGermanElections.csv", "header");
  table.setColumnType("year", Table.INT);
  table.setColumnType("month", Table.INT);
  table.setColumnType("day", Table.INT);
  table.setColumnType("oktoberfest", Table.INT);
  table.setColumnType("bundestagswahl", Table.INT);

  // Save the data in two GPointsArrays
  GPointsArray pointsOktoberfest = new GPointsArray();
  GPointsArray pointsElections = new GPointsArray();

  for (int row = 0; row < table.getRowCount(); row++) {
    int year = table.getInt(row, "year");
    int month = table.getInt(row, "month");
    int day = table.getInt(row, "day");
    float date = getExactDate(year, month, day);
    int oktoberfestCount = table.getInt(row, "oktoberfest");
    int electionsCount = table.getInt(row, "bundestagswahl");

    pointsOktoberfest.add(date, oktoberfestCount, monthNames[month]);
    pointsElections.add(date, electionsCount, monthNames[month]);
  }

  // Create the plot
  plot = new GPlot(this);
  plot.setDim(700, 300);
  plot.setTitleText("Oktoberfest vs. Bundestagwahl Google search history");
  plot.getXAxis().setAxisLabelText("Year");
  plot.getYAxis().setAxisLabelText("Google normalized searches");
  plot.getXAxis().setNTicks(10);
  plot.setPoints(pointsOktoberfest);
  plot.setLineColor(color(100, 100, 100));
  plot.addLayer("German elections day", pointsElections);
  plot.getLayer("German elections day").setLineColor(color(255, 100, 255));
  plot.activatePointLabels();
}

void draw() {
  background(255);

  // Draw the plot  
  plot.beginDraw();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.drawGridLines(GPlot.VERTICAL);
  plot.drawFilledContours(GPlot.HORIZONTAL, 0);
  plot.drawLegend(new String[] {"Oktoberfest", "Bundestagswahl"}, new float[] {0.07, 0.22}, 
                  new float[] {0.92, 0.92});
  plot.drawLabels();
  plot.endDraw();
}  


// Not really the exact date, but it's ok for this example
float getExactDate(int year, int month, int day) {
  boolean leapYear = false;

  if (year % 400 == 0) {
    leapYear = true;
  }
  else if (year % 100 == 0) {
    leapYear = false;
  }
  else if (year % 4 == 0) {
    leapYear = true;
  }

  if (leapYear) {
    return year + (month + (day - 1f)/daysPerMonthLeapYear[month])/12f;
  }
  else {
    return year + (month + (day - 1f)/daysPerMonth[month])/12f;
  }
}
