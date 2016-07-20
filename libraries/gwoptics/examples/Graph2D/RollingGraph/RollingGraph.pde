/**
 * RollingGraph
 * This sketch makes ise of the RollingLine2DTrace object to
 * draw a dynamically updated plot.
 */

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.traces.RollingLine2DTrace;

class eq implements ILine2DEquation{
	public double computePoint(double x,int pos) {
		return mouseX;
	}		
}

class eq2 implements ILine2DEquation{
	public double computePoint(double x,int pos) {
		return mouseY;
	}		
}

class eq3 implements ILine2DEquation{
	public double computePoint(double x,int pos) {
		if(mousePressed)
			return 400;
		else
			return 0;
	}		
}

RollingLine2DTrace r,r2,r3;
Graph2D g;
	
void setup(){
	size(600,300);
	
	r  = new RollingLine2DTrace(new eq() ,100,0.1f);
	r.setTraceColour(0, 255, 0);
	
	r2 = new RollingLine2DTrace(new eq2(),100,0.1f);
	r2.setTraceColour(255, 0, 0);
	
	r3 = new RollingLine2DTrace(new eq3(),100,0.1f);
	r3.setTraceColour(0, 0, 255);
	 
	g = new Graph2D(this, 400, 200, false);
	g.setYAxisMax(600);
	g.addTrace(r);
	g.addTrace(r2);
	g.addTrace(r3);
	g.position.y = 50;
	g.position.x = 100;
	g.setYAxisTickSpacing(100);
	g.setXAxisMax(5f);
}

void draw(){
	background(200);
	g.draw();
}

