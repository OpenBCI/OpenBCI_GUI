/**
 * Scatter Plot Basic
 * Demonstrates how to plot a scatter plot using the gwoptics library. This randomly
 * creates 40 points
 **/
 
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.ScatterTrace;

Graph2D grph;

void setup(){
  size(600,600, P2D);

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
  
  // Here we create a new ScatterTrace and define the type of point to use 
  // Available points: ScatterTrace.Circle
  //                   ScatterTrace.Ring
  //                   ScatterTrace.Cross
  ScatterTrace t = new ScatterTrace(ScatterTrace.Circle);
      
  // Sets the size of the point
  t.setDefaultSize(30f);
  
  //Loop 40 times and add a random point
  for(int i=0;i<40;i++){      
    float x =-9f + (float)Math.random()*18f;
    float y = -9f + (float)Math.random()*18f;

    t.addPoint(x, y);
  }
  
  // Adding the trace to the graph
  grph.addTrace(t);
}

void draw(){
  background(255);
  grph.draw();
}
