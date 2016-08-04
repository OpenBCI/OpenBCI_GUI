/**
 *  Basic2
 *  This is sketch that uses the Graph2D object from the library.
 *  It plots two functions, and shows how some more
 *  methods available to alter the graph
 **/


import org.gwoptics.graphics.*;
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.LabelPos;
import org.gwoptics.graphics.graph2D.traces.Line2DTrace;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.backgrounds.*;

Graph2D g;
GridBackground gb;


/**
 *  Equations that are to be plot must be encapsulated into a 
 *  class implementing the IGraph2DCallback interface.
 **/
public class eq1 implements ILine2DEquation{
  public double computePoint(double x,int pos) {
    return Math.sin(x);
  }		
}
public class eq2 implements ILine2DEquation{
  public double computePoint(double x,int pos) {
    return Math.cos(x);
  }		
}


void setup(){
  size(500,300);

  // Graph2D object, arguments are 
  // the parent object, xsize, ysize, cross axes at zero point
  g = new Graph2D(this, 400, 200, true); 

  // setting attributes for the X and Y-Axis
  g.setYAxisMin(-1);
  g.setYAxisMax(1);
  g.setXAxisMin(-1*PI);
  g.setXAxisMax(2*PI);
  g.setXAxisLabel("X-Axis");
  g.setYAxisLabel("Y-Axis");
  g.setXAxisLabelAccuracy(1);
  g.setYAxisLabelAccuracy(1);
  g.setXAxisTickSpacing(PI/2);
  g.setYAxisTickSpacing(0.25);

  // switching of the border, and changing the label positions
  g.setNoBorder(); 
  g.setXAxisLabelPos(LabelPos.END);
  g.setYAxisLabelPos(LabelPos.END);
  
  // switching on Grid, with differetn colours for X and Y lines
  gb = new  GridBackground(new GWColour(240));
  gb.setGridColour(200,100,200,180,180,180);
  g.setBackground(gb);

  g.position.y = 50;
  g.position.x = 60;

  Line2DTrace trace1 = new Line2DTrace(new eq1());
  Line2DTrace trace2 = new Line2DTrace(new eq2());

  trace1.setTraceColour(255,0,0);
  trace2.setTraceColour(0,0,255);

  g.addTrace(trace1);
  g.addTrace(trace2);
}

void draw(){
  background(255);
  g.draw();
}


