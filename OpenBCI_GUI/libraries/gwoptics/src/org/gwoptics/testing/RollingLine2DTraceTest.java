package org.gwoptics.testing;
/*
ScatterPlot

Example showing how to use blank2DCanvas to quickly create a simple scatter plot.
*/
import java.util.ArrayList;

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.traces.RollingLine2DTrace;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

import org.gwoptics.graphics.*;
import org.gwoptics.graphics.camera.*;
import org.gwoptics.graphics.graph3D.*;
import org.gwoptics.ValueType;
import org.gwoptics.graphics.colourmap.presets.*;
import org.gwoptics.testing.RollingLine2DTraceTest.Point2D;


public class RollingLine2DTraceTest extends PApplet{
        public static void main(final String[] args) {  
            PApplet.main( new String[]{RollingLine2DTraceTest.class.getName()} ); 
        }
        float t = 0f;
        float xmin = -5f;
        float xmax = 1f;
        float xinc = 1;

        class Point2D{
          public float X,Y;
          public Point2D(float x, float y){ X=x; Y=y;}
        }

        class ScatterTrace extends Blank2DTrace{
          private ArrayList<Point2D> _data;
          private float pSize = 10f;
          
          public ScatterTrace(){
            _data = new ArrayList<Point2D>();
          }
          
          public void addPoint(float x, float y){ _data.add(new Point2D(x,y)); } 
        
          private void drawPoint(Point2D p, Blank2DTrace.PlotRenderer pr){
        	
            float x = pr.valToX(p.X);
            float y = pr.valToY(p.Y);
            
            pr.canvas.strokeWeight(2f);
            pr.canvas.pushStyle();
            pr.canvas.stroke(255,0,0);
            pr.canvas.line(x - pSize, y, x + pSize, y);
            pr.canvas.line(x, y - pSize, x, y + pSize);      
            pr.canvas.popStyle();
          }
          
          public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
            if(_data != null){            
              for (int i = 0; i < _data.size(); i++) {
                drawPoint((Point2D)_data.get(i), pr);            
              }
            }
          }
        }
        
        ScatterTrace sTrace;
        Graph2D g;
          
        public void setup(){
          size(600,500, OPENGL);
              
          sTrace  = new ScatterTrace();
          
          g = new Graph2D(this, 400,400, true);
          g.setAxisColour(220, 220, 220);
          g.setFontColour(255, 255, 255);
              
          g.position.y = 50;
          g.position.x = 100;
              
          g.setYAxisTickSpacing(1f);
          g.setXAxisTickSpacing(1f);
          
          g.setXAxisMinorTicks(1);
          g.setYAxisMinorTicks(1);
          
          g.setYAxisMin(0f);
          g.setYAxisMax(10f);
              
          g.setXAxisLabelAccuracy(0);
          
          g.addTrace(sTrace);

          g.setXAxisMin(0);
          g.setXAxisMax(10);
        }
        
        public void draw(){
          background(0);
          
          t += 1.0f/(float)frameRate;
          
          sTrace.addPoint(t, 5f + 3f*sin(t));
          sTrace.generate(); // regenerate the trace for plotting
          
          g.draw();
        }
}