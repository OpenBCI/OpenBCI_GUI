/**
 *  This sketch sets out to show how it is possible to use trace
 *  effects to colour different traces.
 **/

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.Line2DTrace;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.effects.ITraceColourEffect;
import org.gwoptics.graphics.colourmap.ColourmapNode;
import org.gwoptics.graphics.colourmap.RGBColourmap;
import org.gwoptics.graphics.graph2D.effects.XAxisColourmapEffect;
import org.gwoptics.graphics.graph2D.effects.YAxisColourmapEffect;

Graph2D g;

/**
 *  Equations that are to be plot must be encapsulated into a 
 * class implementing the ILine2DEquation interface.
 **/
public class eqSin implements ILine2DEquation{
	public double computePoint(double x,int pos) {
		return Math.sin(x);
	}		
}

public class eqCos implements ILine2DEquation{
	public double computePoint(double x,int pos) {
		return Math.cos(x);
	}		
}

void setup(){
	size(500,300);

	//The following shows all the methods that alter the 
	//layout of the graph.

	// Arguments are: 
	// parent object, xsize, ysize, cross axes at zero point
	g = new Graph2D(this, 400, 200, false);
	g.setYAxisMin(-1.1);
	g.setYAxisMax(1.1);
	g.setXAxisMin(-2*PI);
	g.setXAxisMax(2*PI);

	g.setXAxisTickSpacing(PI/2);
	g.setYAxisTickSpacing(0.25);

	g.position.y = 50;
	g.position.x = 60;

	// There are 2 effects included in the library, if you 
	// require something else see the custom effect sketch.
	// The 2 included apply colourmaps in either the x and y
	// directions.

	// define 2 colourmaps, one with 3 nodes going
	// from red to green to blue 
	RGBColourmap m1 = new RGBColourmap();
	m1.addNode(new ColourmapNode(1,0,0,0f));
	m1.addNode(new ColourmapNode(0,1,0,0.5f));
	m1.addNode(new ColourmapNode(0,0,1,1f));
	m1.generateColourmap();

	// A map that slowly fades in and out using the alpha channel
	RGBColourmap m2 = new RGBColourmap();
	m2.addNode(new ColourmapNode(1,1,0,0,0f));
	m2.addNode(new ColourmapNode(0,0,1,0,0.5f));
	m2.addNode(new ColourmapNode(1,0,0,1,1f));
	m2.generateColourmap();

	// Here we create a new trace and set a colour for
	// it, along with passing the equation object to it.
	Line2DTrace trace1 = new Line2DTrace(new eqSin());
	trace1.setTraceColour(255,0,0);
	trace1.setTraceEffect(new XAxisColourmapEffect(m1));

	Line2DTrace trace2 = new Line2DTrace(new eqCos());
	trace2.setTraceEffect(new YAxisColourmapEffect(m2));
	trace2.setTraceColour(0,255,0);

	//add the trace to the graph
	g.addTrace(trace1);	
	g.addTrace(trace2);
}

void draw(){
        background(200);
	g.draw();
}
