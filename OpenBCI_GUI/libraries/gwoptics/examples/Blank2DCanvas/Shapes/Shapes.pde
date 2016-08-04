/*
  Shapes
  
  Here we demonstate that Blank2DCanvas is not limited to purely line traces
  and that drawing shapes of specific sizes matches the axes values. Here
  we show how to create a simple histogram fed data by an ArrayList of floats.  
 */

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace;

  class Histogram extends Blank2DTrace{
    private ArrayList _data;
  
    public void bindData(ArrayList data) {_data = data;}
  
    public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
      
      if(_data != null){            
        for (int i = 0;i < _data.size(); i++) {            
          pr.canvas.fill(50 + i*25);
                          
          float val = (Float)_data.get(i);
          pr.canvas.rect(pr.valToX(i+0.5f),
                         pr.valToY(0), 
                         pr.valToX(1f),
                         pr.valToY(val));              
        }
      }
    }
  }
  
  Histogram hTrace;
  Graph2D g;
    
  void setup(){
    size(600,500, P2D);
        
    hTrace  = new Histogram();
    
    g = new Graph2D(this, 400,400, true);
    g.setAxisColour(220, 220, 220);
    g.setFontColour(255, 255, 255);
        
    g.position.y = 50;
    g.position.x = 100;
        
    g.setYAxisTickSpacing(1f);
    g.setXAxisTickSpacing(1f);
    g.setXAxisMinorTicks(1);
    
    g.setYAxisMin(-5f);
    g.setYAxisMax(5f);
        
    g.setXAxisMin(0.1f);
    g.setXAxisMax(5.9f);
    g.setXAxisLabelAccuracy(0);
    
    g.addTrace(hTrace);
    
    ArrayList data = new ArrayList();
    data.add(3f);
    data.add(6f);
    data.add(-3f);
    data.add(4f);
    data.add(2f);
        
    hTrace.bindData(data);
        
  }
    
  void draw(){
    background(0);
    g.draw();
  }

