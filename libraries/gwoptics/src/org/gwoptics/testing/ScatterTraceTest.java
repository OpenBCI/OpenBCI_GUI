/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.gwoptics.testing;

import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.traces.Line2DTrace;
import org.gwoptics.graphics.graph2D.traces.ScatterTrace;
import processing.core.PApplet;

/**
 *
 * @author Daniel
 */
public class ScatterTraceTest extends PApplet {
    
  Graph2D grph;

  public static void main(final String[] args) {  
    PApplet.main( new String[]{ScatterTraceTest.class.getName()} );  
  }

  @Override public void setup(){
    size(600,600,OPENGL);

    // Creating the Graph2D object:
    // arguments are the parent object, xsize, ysize, cross axes at zero point
    grph = new Graph2D(this, 450, 450, false); 

    // Defining the main properties of the X and Y-Axis
    grph.setYAxisMin(-6);
    grph.setYAxisMax(6);
    grph.setXAxisMin(-6);
    grph.setXAxisMax(6);
    grph.setXAxisLabel("X-Axis");
    grph.setYAxisLabel("Y-Axis");
    grph.setXAxisTickSpacing(2.5f);
    grph.setYAxisTickSpacing(2.5f);

    // Offset of the top left corner of the plotting area
    // to the sketch origin (should not be zero in order to
    // see the y-axis label
    grph.position.x = 80;
    grph.position.y = 60;

    // Here we create a new trace and set a colour for
    // it, along with passing the equation object to it.
    t = new ScatterTrace(ScatterTrace.Ring);
        
    t.setDefaultSize(30f);
    t.setLablePosition(ScatterTrace.LABELPOSITION.RIGHT);
    t.setLabelFont(createFont("Arial", 18, true));
    
    for(int i=-5;i<5;i++){
      t.addPoint(i, i, "label", String.format("[%.1f, %.1f]", (float)i, (float)i), "labelcolour", new GWColour(255,255,255));
    }
    
    // Adding the trace to the graph
    grph.addTrace(t);

    t.generate();
    frameRate(900);
  }
  
  ScatterTrace t;

  @Override public void draw(){
    background(120);
    grph.draw();
    println(frameRate);
  }
}
