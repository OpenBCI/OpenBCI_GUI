/**
 * Basic Sprial
 * The Blank2DTrace onject can be used to draw more generally in
 * a Graph2D envirmonment, i.e. not using functions. This example
 * shows how to draw a parametric sprial.
 */

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace;

class spiralTrace extends Blank2DTrace{
	
	public float xparam(float t){
		return t*0.1f*cos(t);
	}
	
	public float yparam(float t){
		return t*0.1f*sin(t);
	}
	
	public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
		pr.canvas.background(0);
		
		int res = 40;
		float dAngle = 2f*PI/res;
		
		for(int i=0;i<10*res;i++){
			pr.canvas.stroke(0,0,255,255);
			pr.canvas.line(pr.valToX(xparam(dAngle*i)),
				       pr.valToY(yparam(dAngle*i)),
				       pr.valToX(xparam(dAngle*(i+1))),
			               pr.valToY(yparam(dAngle*(i+1))));
		}
	}
}

spiralTrace r;
Graph2D g;

void setup(){
	size(600,500, P2D);
	
	r  = new spiralTrace();
	 
	g = new Graph2D(this, 400,400, true);
	g.setAxisColour(220, 220, 220);
	g.setFontColour(100, 100, 100);
	
	g.position.y = 50;
	g.position.x = 100;
	g.setYAxisTickSpacing(2f);
	g.setXAxisTickSpacing(2f);

	g.setYAxisMin(-10f);
	g.setYAxisMax(10f);
	g.setXAxisMin(-10f);
	g.setXAxisMax(10f);
	
	g.addTrace(r);
}

void draw(){
	background(0);
	g.draw();
}