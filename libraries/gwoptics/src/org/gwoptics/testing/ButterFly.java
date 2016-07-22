package org.gwoptics.testing;

import org.gwoptics.graphics.graph2D.*;
import org.gwoptics.graphics.graph2D.traces.*;
import processing.core.PApplet;

/**
 *
 * @author Daniel
 */
public class ButterFly extends PApplet{
  
  public static void main(final String[] args) {  
    PApplet.main( new String[]{ButterFly.class.getName()} );  
  }

  class ButterflyTrace extends Blank2DTrace{	
	  
		public float xparam(float t){
			return sin(t)*(exp(cos(t)) - 2*cos(4*t)-pow(sin(t/12),5));
		}
		
		public float yparam(float t){
			return cos(t)*(exp(cos(t)) - 2*cos(4*t)-pow(sin(t/12),5));
		}
		
		public void TraceDraw(Blank2DTrace.PlotRenderer pr) {		
			int res = 1000; // alters the resolution of the 
	                                // plot to get a smoother appearance
			float dAngle = 2f*PI/res;
	                float mod = frameCount/200f;  //this variable determines
	                                              //how fast with time the plot
	                                              //evolves
	                
			for(int i=0;i < mod*2*res; i++){
				pr.canvas.stroke(255,0,255,255);
				pr.canvas.line(pr.valToX(xparam(dAngle*i)),
	                                       pr.valToY(yparam(dAngle*i)),
	                                       pr.valToX(xparam(dAngle*(i+1))),
	                                       pr.valToY(yparam(dAngle*(i+1))));
			}
		}
	}

  
  ButterflyTrace bTrace;
  Graph2D g;

  public void setup(){
  	size(600, 500, OPENGL);
	frameRate(20);
          
  	bTrace  = new ButterflyTrace();
  	 
  	g = new Graph2D(this, 400,400, true);
  	g.setAxisColour(220, 220, 220);
  	g.setFontColour(100, 100, 100);
  	
  	g.position.y = 50;
  	g.position.x = 100;
  	
  	g.setYAxisTickSpacing(2f);
  	g.setXAxisTickSpacing(2f);

  	g.setYAxisMin(-5f);
  	g.setYAxisMax(5f);
  	g.setXAxisMin(-5f);
  	g.setXAxisMax(5f);
  	
  	g.addTrace(bTrace);
  }

  public void draw(){
	background(0);
	bTrace.generate();  //As the graph is always changing we
	//need to update each draw cycle
	g.draw();
  }
}