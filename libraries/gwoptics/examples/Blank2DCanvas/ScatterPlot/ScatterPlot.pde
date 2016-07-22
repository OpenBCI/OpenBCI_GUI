/*
  ScatterPlot
  
  Example showing how to use blank2DCanvas to quickly create a simple scatter plot.
*/

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace;

  class Point2D{
    public float X,Y;
    public Point2D(float x, float y){X=x;Y=y;}
  }

  class ScatterTrace extends Blank2DTrace{
    private ArrayList _data;
    private float pSize = 4f;
    
    public ScatterTrace(){
      _data = new ArrayList();
    }
    
    public void addPoint(float x, float y){_data.add(new Point2D(x,y));}
  
    private void drawPoint(Point2D p, Blank2DTrace.PlotRenderer pr){
      // p.X and p.Y are values of the point in Graph space, here 
      // we convert them into the screen space, i.e. pixels.
      float x = pr.valToX(p.X);
      float y = pr.valToX(p.Y);
      
      pr.canvas.pushStyle();
      pr.canvas.stroke(255,0,0);
      pr.canvas.line(x-pSize, y, x+pSize, y);
      pr.canvas.line(x, y-pSize, x, y+pSize);      
      pr.canvas.popStyle();
    }
    
    public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
      if(_data != null){            
        for (int i = 0;i < _data.size(); i++) {
          drawPoint((Point2D)_data.get(i),pr);            
        }
      }
    }
  }
  
  ScatterTrace sTrace;
  Graph2D g;
    
  void setup(){
    size(600,500, P2D);
    
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
        
    g.setXAxisMin(0f);
    g.setXAxisMax(10f);
    g.setXAxisLabelAccuracy(0);
    
    g.addTrace(sTrace);
        
    for(int i=0;i<100;i++){
      sTrace.addPoint(random(0,10),random(0,10));
    }
  }
    
  void draw(){
    background(0);
    g.draw();
  }
