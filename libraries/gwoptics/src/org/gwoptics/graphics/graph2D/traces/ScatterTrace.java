/**
 * Copyright notice
 *
 * This file is part of the Processing library `gwoptics'
 * http://www.gwoptics.org/processing/gwoptics_p5lib/
 *
 * Copyright (C) 2009 onwards Daniel Brown and Andreas Freise
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 2.1 as published
 * by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package org.gwoptics.graphics.graph2D.traces;

import java.util.ArrayList;
import java.util.HashMap;
import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.graph2D.Axis2D;
import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;

/**
 *
 * @author Daniel
 */
public class ScatterTrace extends Blank2DTrace {

  private ArrayList<LabelData> _labels;
  private ArrayList<Point2D> _data;
  private ArrayList<HashMap<String, Object>> _info;
  private GWColour defaultColour = new GWColour(255, 0, 0), defaultLabelColour = new GWColour(0, 0, 0);
  private float defaultSize = 0.05f;
  private IScatterPoint _pt;
  private PFont _labelfont;
  private LABELPOSITION _lblPos = LABELPOSITION.RIGHT;

  public enum LABELPOSITION {
    ABOVE, LEFT, RIGHT, BELOW, CENTER
  }

  private class LabelData {

    public String value="";
    public GWColour c = defaultLabelColour;
    public float offscale=1f;
  }

  private class Point2D {

    public float x, y;

    public Point2D(float x, float y) {
      this.x = x;
      this.y = y;
    }
  }
  public final static IScatterPoint Cross = new IScatterPoint() {

    @Override
    public void drawPoint(float x, float y, PlotRenderer pr, HashMap<String, Object> info) {
      float psize = 0.5f * ((Number) info.get("size")).floatValue();
      GWColour c = (GWColour) info.get("colour");

      pr.canvas.pushStyle();
      pr.canvas.stroke(c.toInt());
      pr.canvas.strokeCap(PApplet.SQUARE);
      
      float X = pr.valToX(x);
      float Y = pr.valToY(y);
      
      pr.canvas.line(X - psize, Y, X + psize, Y);
      pr.canvas.line(X, Y - psize, X, Y + psize);
      pr.canvas.popStyle();
    }
  };
  
  public final static IScatterPoint Circle = new IScatterPoint() {
    @Override
    public void drawPoint(float x, float y, PlotRenderer pr, HashMap<String, Object> info) {
      float psize = 0.5f * ((Number) info.get("size")).floatValue();
      GWColour c = (GWColour) info.get("colour");

      x = pr.valToX(x);
      y = pr.valToY(y);
      
      pr.canvas.fill(c.toInt());
      pr.canvas.noStroke();
      pr.canvas.ellipse(x, y, psize, psize);
    }
  };
  
  public final static IScatterPoint Ring = new IScatterPoint() {
    @Override
    public void drawPoint(float x, float y, PlotRenderer pr, HashMap<String, Object> info) {
      float psize = 0.5f * ((Number) info.get("size")).floatValue();
      GWColour c = (GWColour) info.get("colour");
      float stroke = 1f;

      if (info.containsKey("stroke")) {
        stroke = (Float) info.get("stroke");
      }

      x = pr.valToX(x);
      y = pr.valToY(y);

      pr.canvas.pushStyle();
      pr.canvas.stroke(c.toInt());
      pr.canvas.strokeWeight(stroke);
      pr.canvas.noFill();
      pr.canvas.ellipse(x, y, psize, psize);
      pr.canvas.popStyle();
    }
  };

  public interface IScatterPoint {
    public void drawPoint(float x, float y, PlotRenderer pr, HashMap<String, Object> info);
  }

  public ScatterTrace(IScatterPoint pt) {
    super();

    _pt = pt;
    _labels = new ArrayList<LabelData>();
    _info = new ArrayList<HashMap<String, Object>>();
    _data = new ArrayList<Point2D>();
  }

  @Override
  public void onAddTrace(Object[] traces) {
    if (_labelfont == null) {
      _labelfont = _parent.createFont("Arial", 12, true);
    }
  }
  
  public void setLablePosition(LABELPOSITION p) {
    _lblPos = p;
  }

  public void setLabelFont(PFont font) {
    if (font == null) {
      throw new NullPointerException("Font object cannot be null");
    }

    _labelfont = font;
  }

  public void setDefaultLabelColor(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Color object cannot be null");
    }

    defaultLabelColour = c;
  }

  public void setDefaultColor(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Color object cannot be null");
    }

    defaultColour = c;
  }

  public void setDefaultSize(float s) {
    defaultSize = Math.abs(s);
  }

  private void _addPoint(float x, float y, float size, GWColour c) {
    _data.add(new Point2D(x, y));
    HashMap<String, Object> hm = new HashMap<String, Object>(2);
    
    if(!hm.containsKey("color"))
      hm.put("colour", c);
    
    if(!hm.containsKey("size"))
      hm.put("size", (Float) size);
    
    _info.add(hm);
  }

  public void addPoint(float x, float y, float size, GWColour c, Object... args) {
    _addPoint(x, y, size, c);
    _processesVarArgs(args);
  }

  public void addPoint(float x, float y, Object... args) {
    _addPoint(x, y, defaultSize, defaultColour);
    _processesVarArgs(args);
  }

  public void addPoint(float x, float y, float size, String label, GWColour c, Object... args) {
    if (args.length % 2 != 0) {
      throw new RuntimeException("There was not an even number of Key/Value pairs");
    }

    _addPoint(x, y, size, c);

    _processesVarArgs(args);
  }

  protected void _processesVarArgs(Object[] args) {
    HashMap<String, Object> hm = _info.get(_info.size() - 1);

    for (int i = 0; i < args.length; i += 2) {

      if (!(args[i] instanceof String)) {
        throw new RuntimeException("Was expecting vararg number " + i + " to be a string for a key value");
      }
      String key = (String) args[i];
      if (key.compareToIgnoreCase("label") == 0) {
        if (!(args[i + 1] instanceof String)) {
          throw new RuntimeException("Was expecting label value to be a string");
        }

        if (_labels.size() < _info.size()) {
          _labels.add(new LabelData());
        }

        _labels.get(_info.size() - 1).value = (String) args[i + 1];

      } else if (key.compareToIgnoreCase("labelcolour") == 0 || key.compareToIgnoreCase("labelcolor") == 0) {
        if (!(args[i + 1] instanceof GWColour)) {
          throw new RuntimeException("Was expecting labelcolor value to be a GWColor object");
        }

        if (_labels.size() < _info.size()) {
          _labels.add(new LabelData());
        }

        _labels.get(_info.size() - 1).c = (GWColour) args[i + 1];
      } else if (key.compareToIgnoreCase("labeloffsetscale") == 0) {
        
        if (_labels.size() < _info.size()) {
          _labels.add(new LabelData());
        }

        _labels.get(_info.size() - 1).offscale = ((Number)args[i + 1]).floatValue();
      }
      

      hm.put((String) args[i], args[i + 1]);
    }
  }

  private void drawPoint(int ix, PlotRenderer pr) {
    Point2D p = _data.get(ix);

    pr.canvas.pushMatrix();
    pr.canvas.pushStyle();
    
    _pt.drawPoint(p.x, p.y, pr, _info.get(ix));
    
    pr.canvas.popMatrix();
    pr.canvas.popStyle();
    
    if (!_labels.isEmpty()) {
      // The BlankCanvas trace works by creating a scaled canvas on which
      // we draw, if we try and draw text to it though this will also be
      // scaled and looks ugly. For a hack we can undo this scaling then
      // draw the text, easy...
      pr.canvas.pushMatrix();
      pr.canvas.pushStyle();

      // -1 for the y is needed here as the coordinate system in Blank canvas is
      // flipped to be like a normal graph, rather than screen coordinates
      pr.canvas.scale(1f, -1f);
      pr.canvas.textFont(_labelfont);
      pr.canvas.fill(0);

      float px = 0, py = 0;

      String lbl = _labels.get(ix).value;
      GWColour c = _labels.get(ix).c;
      float offsc = _labels.get(ix).offscale;
      
      switch (_lblPos) {
        case CENTER:
          px = -pr.canvas.textWidth(lbl) / 2;
          py = -_labelfont.getSize() * (_labelfont.ascent()) / 2;
          break;
        case BELOW:
          px = -pr.canvas.textWidth(lbl) / 2;
          py = -defaultSize * offsc / 2 - _labelfont.getSize() * (_labelfont.ascent());
          break;
        case ABOVE:
          px = -pr.canvas.textWidth(lbl) / 2;
          py = defaultSize  * offsc / 2 + _labelfont.getSize() * (_labelfont.descent());
          break;
        case LEFT:
          py = -_labelfont.getSize() * (_labelfont.ascent()) / 2;
          px = -(pr.canvas.textWidth(lbl) + defaultSize  * offsc / 2);
          break;
        case RIGHT:
          py = -_labelfont.getSize() * (_labelfont.ascent()) / 2;
          px = defaultSize * offsc / 2;
          break;
      }

      pr.canvas.fill(c.toInt());
      pr.canvas.text(lbl, pr.valToX(p.x) + px, -(pr.valToY(p.y) + py));

      pr.canvas.popMatrix();
      pr.canvas.popStyle();
    }
  }

  @Override
  public void TraceDraw(PlotRenderer p) {
    p.canvas.pushStyle();
    p.canvas.pushMatrix();
    
    if (_data != null) {
      for (int i = 0; i < _data.size(); i++) {
        drawPoint(i, p);
      }
    }

    p.canvas.popMatrix();
    p.canvas.popStyle();
  }
}
