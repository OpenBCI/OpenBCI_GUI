package org.gwoptics.testing;

import org.gwoptics.graphics.graph2D.*;
import org.gwoptics.graphics.graph2D.traces.*;
import processing.core.PApplet;

/**
 *
 * @author Daniel
 */
public class Graph2DTest extends PApplet{
  
  Graph2D g;

  public static void main(final String[] args) {  
    PApplet.main( new String[]{Graph2DTest.class.getName()} );  
  }

  @Override public void setup(){
    size(500,270, P2D);

    // Creating the Graph2D object:
    // arguments are the parent object, xsize, ysize, cross axes at zero point
    g = new Graph2D(this, 400, 200, false); 

    // Defining the main properties of the X and Y-Axis
    g.setYAxisMin(-1);
    g.setYAxisMax(1);
    g.setXAxisMin(-2*PI);
    g.setXAxisMax(2*PI);
    g.setXAxisLabel("X-Axis");
    g.setYAxisLabel("Y-Axis");
    g.setXAxisTickSpacing(PI/2);
    g.setYAxisTickSpacing(0.25f);

    // Offset of the top left corner of the plotting area
    // to the sketch origin (should not be zero in order to
    // see the y-axis label
    g.position.x = 70;
    g.position.y = 20;

    // Here we create a new trace and set a colour for
    // it, along with passing the equation object to it.
    Line2DTrace trace = new Line2DTrace(new ILine2DEquation() {
      public double computePoint(double x, int position) {
        return Math.sin(x);
      }
    });
    
    trace.setTraceColour(255,0,0);
    // Adding the trace to the graph
    g.addTrace(trace);
  }

  @Override public void draw(){
    background(255);
    g.draw();
  }
}