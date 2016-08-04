/**
 * Scatter Plot Advanced
 * You can plot some interesting stuff if you are willing to get your hands
 * dirty in some code! This example shows how we can plot clever points which
 * take in more than just x and y values and render something more interesting.
 **/

import org.gwoptics.graphics.GWColour; 
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.ScatterTrace;

ScatterTrace t;

Graph2D grph;

void setup(){
  size(600,600,P2D);

  // Creating the Graph2D object:
  // arguments are the parent object, xsize, ysize, cross axes at zero point
  grph = new Graph2D(this, 450, 450, false); 

  // Defining the main properties of the X and Y-Axis
  grph.setYAxisMin(-10);
  grph.setYAxisMax(10);
  grph.setXAxisMin(-10);
  grph.setXAxisMax(10);
  grph.setXAxisLabel("X-Axis");
  grph.setYAxisLabel("Y-Axis");
  grph.setXAxisTickSpacing(2.5f);
  grph.setYAxisTickSpacing(2.5f);
  
  // Offset of the top left corner of the plotting area
  // to the sketch origin (should not be zero in order to
  // see the y-axis label
  grph.position.x = 80;
  grph.position.y = 60;
  
  ScatterTrace.IScatterPoint CleverPoint = new ScatterTrace.IScatterPoint() {
    // The HashMap also contains extra information that we want to pass to the point
    public void drawPoint(float x, float y, ScatterTrace.PlotRenderer pr, HashMap<String, Object> info) {
      float psize = ((Number) info.get("size")).floatValue();
      // here we get the data we gave to the point in the addpoint command below
      // you can pass anything you want to the point for it to use, here is just
      // colours and data
      GWColour ac = (GWColour) info.get("AColour");
      GWColour bc = (GWColour) info.get("BColour");
      float A = ((Number) info.get("A")).floatValue();
      float B = ((Number) info.get("B")).floatValue();
      
      pr.canvas.strokeWeight(2f);
      
      // Need to convert graph space x and y into screen space, i.e. pixels
      x = pr.valToX(x);
      y = pr.valToY(y);
      
      pr.canvas.stroke(0);
      pr.canvas.fill(ac.toInt());
      pr.canvas.ellipse(x, y, A*psize, A*psize);
     
      pr.canvas.noStroke();
      pr.canvas.fill(bc.toInt());
      pr.canvas.ellipse(x, y, B*psize, B*psize);
    }
  };

  // Now we add square in here
  t = new ScatterTrace(CleverPoint);
  
  // Sets the size of the point
  t.setDefaultSize(5f);
  
  float x = -7f + (float)Math.random()*14f;
  float y = -7f + (float)Math.random()*14f;
  
  t.setLablePosition(ScatterTrace.LABELPOSITION.BELOW);
  t.setLabelFont(createFont("Arial", 18, true));
  float psize =  random(20,50);
  
  // here we pass lots of extra data to our point, notice that we first give a 
  // string values for the name and then whatever it is we want to pass, this is 
  // known as a Key Value pair

  // an important value that we give the point is the LabelOffsetScale, this scales
  // the normal label position calculation by some amount, so if you change the
  // size of the point you draw to something other than the default size, you need
  // to scale it.
  t.addPoint(x, y, "Label", "UK",
                   "LabelOffsetScale", psize*1.05f,
                   "A", psize,
                   "B", random(0.1,0.9*psize),
                   "AColour", new GWColour(255,0,0), 
                   "BColour", new GWColour(0,255,0));

  x =-9f + (float)Math.random()*18f;
  y = -9f + (float)Math.random()*18f;
  psize =  random(20,50);
  
  t.addPoint(x, y, "Label", "USA",
                   "LabelOffsetScale", psize*1.05f,
                   "A", psize,
                   "B", random(0.1,0.9*psize),
                   "AColour", new GWColour(255,0,0),
                   "BColour", new GWColour(0,255,0));
  
  // Adding the trace to the graph
  grph.addTrace(t);
}

void draw(){
  background(255);
  grph.draw();
}