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

import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.graph2D.Axis2D;
import org.gwoptics.graphics.graph2D.IGraph2D;
import org.gwoptics.graphics.graph2D.backgrounds.IGraph2DBackground;
import org.gwoptics.graphics.graph2D.effects.ITraceColourEffect;

import processing.core.PApplet;
import processing.core.PVector;

/**
 * <p> The Line2DTrace is the default implementation of the IGraphTrace
 * interface. It can be used for a variety of plotting tasks and for 9/10 times
 * will be useful for whatever is needed. </p>
 *
 * <p> The Line2DTrace object requires that an IGraph2DCallback object is
 * provided for it to plot a trace. To plot the trace, the generate() method is
 * first called. This populates an internal array that stores the points of the
 * trace. If the callback object changes, the trace will not change until the
 * generate() method is called again. If you have a trace that changes
 * regularly, ie a non-static standing wave, then call the generate method in
 * each draw() call. <b>Note:</b> Make sure the callback object is optimised as
 * much as possible for non static graphs, complicated graphs that are
 * regenerated each draw call will grind the system to a halt, contemplate using
 * the TrigLookup object for faster sinusoidal functions. </p>
 *
 * <p> This trace object also accepts trace effects defined by the
 * ITraceColourEffect interface. Use this to visually enhance a graph trace.
 * </p>
 *
 * <p> <b>Custom 2D Traces</b><br> If the need arises to create a custom trace
 * object for the graph2D control two options are open. Implement the
 * IGraphTrace interface from scratch or inherit the Line2DTrace object, the
 * later being the simplest. To do that though understanding of the class is
 * necessary and its members. </p> <p> Most of the public members are properties
 * such as setAxis and setTraceColour, these simple apply a value to the
 * relevant member and most likely will not need overriding. The most likely
 * candidates for overriding are the generate and draw methods. Generate simply
 * goes about deducing the graph value for each pixel on the x-axis and then
 * passing this to the ILineEquation object to produce a y value. This is
 * converted into a point that is represented on the Y-axis and then stored in
 * the _pointData and _eqData arrays. The generate function therefore only needs
 * to be called on if the trace is changing values or shape. </p> <p> The draw
 * method is the one who goes about plotting the values using the _pointData
 * array. No heavy calculations should be going on in the draw method, to give
 * the best framerates. Draw loops through each _pointData value and limits it
 * to the max and min values of the y-axis and then draws the points using
 * connected lines. At this point any trace colour effect is also applied to the
 * trace. One important note is that if you want to display no point at a place
 * on your trace, simply put Float.NaN into the _pointData array. The draw
 * method then ignores this point. </p> <p> The recommended approach to
 * producing a new trace is to override the generate method and populate the
 * relevant arrays as needed. Then let the draw method do its job, this is
 * recommended if what you are looking for in the end is a line. If for example
 * an area graph, bar-graph, histogram or scatter plot is required then the draw
 * method would be need to be altered to produce the correct effect. For future
 * use if no source is present the generate and draw method code is included
 * below, all the other methods can be left not overridden. </p>
 * <pre>
 * <code>
 * protected Axis2D _ax, _ay; //Reference to the 2 axis objects of the graph2D control
 * protected PApplet _parent; //Parent PApplet
 * protected ILineEquation _cb; //The ILineEquation used to implemnt the data to plot
 * protected double[] _eqData; //This array stores for each pixel along the X-Axis a Y value in graph space
 * protected float[] _pointData; //This array stores the Y pixel value of each pixel along the X-Axis.
 * protected boolean _yAutoRange; //determines whether to auto range the y axis
 * protected PVector _pos; //position of the trace on the graph
 * protected Colour _traceColour; // solid colour of the trace if no effect applied
 * protected ITraceColourEffect _effect; //Colour effect applied to the trace
 *
 * public void generate() {
 * if(_ax == null || _ay == null)
 * throw new RuntimeException("One of the axis objects are null, set them using setAxes().");
 *
 * if(_cb != null){
 * float dRes = (_ax.getMaxValue() - _ax.getMinValue()) / (_ax.getLength() - 1);
 * double highestValue = 0;
 * double lowestValue = 0;
 *
 * for (int i = 0; i < _eqData.length; i++) {
 * double val = _cb.computePoint(_ax.getMinValue() + i * dRes);
 *
 * _eqData[i] = val;
 *
 * if(_yAutoRange){
 * if(val > highestValue)
 * highestValue = val;
 * else if(val < lowestValue)
 * val = lowestValue;
 *
 * }else
 * _pointData[i] = _ay.valueToPosition((float) val);
 * }
 *
 * if(_yAutoRange){
 * _ay.setMinValue((float) lowestValue);
 * _ay.setMaxValue((float) highestValue);
 *
 * for (int i = 0; i < _eqData.length; i++) {
 * _pointData[i] = _ay.valueToPosition((float)_eqData[i]);
 * }
 * }
 * }
 * }
 *
 * public void draw() {
 * if(_parent == null)
 * throw new NullPointerException("Set parent object before plotting.");
 *
 * float y1,y2;
 * boolean b1,b2;
 * float dRes = (_ax.getMaxValue() - _ax.getMinValue()) / (_ax.getLength() - 1);
 * Colour cTrace;
 *
 * _parent.pushMatrix();
 * _parent.pushStyle();
 * _parent.translate(_pos.x, _pos.y);
 *
 * for (int i = 1; i < _pointData.length; i++) {
 * b1 = true;
 * b2 = true;
 * y1 = _pointData[i-1];
 * y2 = _pointData[i];
 *
 * if(!(Float.isNaN(y1) || Float.isNaN(y2))){
 *
 * if(y1 > _ay.getLength()){
 * y1 = _ay.getLength();
 * }else if(y1 < 0){
 * y1 = 0;
 * }else
 * b1 = false;
 *
 * if(y2 > _ay.getLength()){
 * y2 = _ay.getLength();
 * }else if(y2 < 0){
 * y2 = 0;
 * }else
 * b2 = false;
 *
 * if(!(b1 && b2)){
 * if(_effect != null)
 * cTrace = _effect.getPixelColour(i-1, (int) y1,_ax.getMinValue() + i * dRes,(float)_eqData[i-1]);
 * else
 * cTrace = _traceColour;
 *
 * _parent.stroke(cTrace.R * 255,cTrace.G * 255,cTrace.B * 255,cTrace.A * 255);
 * //_parent.stroke(cTrace.toInt());
 * _parent.strokeWeight(1);
 * _parent.line(i-1, -y1, i, -y2);
 * }
 * }
 * }
 *
 * _parent.popStyle();
 * _parent.popMatrix();
 * }
 * </code>
 * </pre>
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 */
public class Line2DTrace implements IGraph2DTrace {

  protected Axis2D _ax, _ay;
  protected IGraph2DBackground _back;
  protected PApplet _parent;
  protected ILine2DEquation _cb;
  protected double[] _eqDataY;
  protected float[] _pointData;
  protected boolean _yAutoRange;
  protected PVector _pos;
  protected GWColour _traceColour;
  protected ITraceColourEffect _effect;
  protected int _lineWidth;

  /**
   * Default constructor accepting a callback object implementing the
   * ILineEquation interface. The object should then accept an x value and
   * return a y.
   */
  public Line2DTrace(ILine2DEquation eq) {
    _cb = eq;
    _pos = new PVector(0, 0);
    _traceColour = new GWColour(0, 0, 0);
  }

  public void setGraph(IGraph2D grp) {
    _ax = grp.getXAxis();
    _ay = grp.getYAxis();

    _setupTraceEffect();

    _back = grp.getGraphBackground();

    _pointData = new float[_ax.getLength()];
    _eqDataY = new double[_ax.getLength()];
  }

  /**
   * Sets the parent PApplet object
   */
  public void setParent(PApplet parent) {
    if (parent == null) {
      throw new NullPointerException("Parent object can not be null");
    }

    _parent = parent;
  }

  /**
   * Sets the position of the trace
   */
  public void setPosition(int x, int y) {
    _pos.x = x;
    _pos.y = y;
  }

  /**
   * Sets the callback object implementing the ILineEquation interface. The
   * object should then accept an x value and return a y.
   */
  public void setEquationCallback(ILine2DEquation equation) {
    _cb = equation;
  }

  /**
   * Uses the ILineEquation object provided to fill the internal arrays. The
   * arrays are then used to plot the data in the draw method.
   */
  public void generate() {
    if (_ax == null || _ay == null) {
      throw new RuntimeException("One of the axis objects are null, set them using setAxes().");
    }

    if (_cb != null) {
      double highestValue = 0;
      double lowestValue = 0;

      for (int i = 0; i < _eqDataY.length; i++) {
        double xval = _ax.positionToValue(i);
        double val = _cb.computePoint(xval, i);

        _eqDataY[i] = val;

        if (_yAutoRange) {
          if (val > highestValue) {
            highestValue = val;
          } else if (val < lowestValue) {
            val = lowestValue;
          }
        } else {
          _pointData[i] = _ay.valueToPosition((float) val);
        }
      }

      if (_yAutoRange) {
        _ay.setMinValue((float) lowestValue);
        _ay.setMaxValue((float) highestValue);

        for (int i = 0; i < _eqDataY.length; i++) {
          _pointData[i] = _ay.valueToPosition((float) _eqDataY[i]);
        }
      }
    }
  }

  /**
   * Uses the data that generate produced beforehand to plot the final trace
   * line. Also applies any colour of effect to the trace.
   */
  public void draw() {
    if (_parent == null) {
      throw new NullPointerException("Set parent object before plotting.");
    }

    float dRes = (_ax.getMaxValue() - _ax.getMinValue()) / (_ax.getLength() - 1);
    GWColour cTrace;

    _parent.pushMatrix();
    _parent.pushStyle();
    _parent.translate(_pos.x, _pos.y);
    _parent.strokeWeight(_lineWidth);

    if (_pointData.length > 0) {
      int prevX = 0;
      float prevY = 0;
      int startPos = 0;

      //find a starting point as the previous point is drawn first
      //then the current point, and a line between them
      for (int j = 0; j < _pointData.length; j++) {
        if (!Float.isNaN(_pointData[j])) {
          prevX = j;
          prevY = _pointData[j];
          startPos = j + 1;
          break;
        }
      }

      if (startPos != 0) {
        float ypos = 0;
        prevY = _pointData[startPos - 1];

        for (int i = startPos; i < _pointData.length; i++) {
          ypos = _pointData[i];

          if (!(Float.isNaN(ypos) || Float.isNaN(prevY))) {
            boolean outofbounds = false;

            if (ypos < 0 || ypos > _ay.getLength()) {
              outofbounds = true;
            }

            if (prevY < 0 || prevY > _ay.getLength()) {
              outofbounds = true;
            }

            if (!outofbounds) {
              if (_effect != null) {
                cTrace = _effect.getPixelColour(i - 1, (int) ypos,
                        _ax.getMinValue() + i * dRes,
                        (float) _eqDataY[i - 1]);
                _parent.stroke(cTrace.R * 255,
                        cTrace.G * 255,
                        cTrace.B * 255,
                        cTrace.A * 255);
              } else {
                _parent.stroke(_traceColour.R * 255, _traceColour.G * 255, _traceColour.B * 255, _traceColour.A * 255);
              }
            } else {
              _parent.stroke(0, 0);
            }

            _parent.line(prevX, -prevY, i, -ypos);

            prevX = i;
            prevY = ypos;
          }
        }
      }
    }

    _parent.popStyle();
    _parent.popMatrix();
  }

  public void onAddTrace(Object[] traces) {
  }//No checks are required so add away

  public void onRemoveTrace() {
  }//No checks are required so add away

  public void setTraceColour(int R, int G, int B) {
    _traceColour = new GWColour(R, G, B);
  }

  public void setLineWidth(int width) {
    _lineWidth = width;
  }

  public void removeEffect() {
    _effect = null;
  }

  public void setTraceEffect(ITraceColourEffect effect) {
    _effect = effect;

    _setupTraceEffect();
  }

  private void _setupTraceEffect() {
    if (_ax != null && _ay != null && _effect != null) {
      _effect.setXAxisValues(_ax.getLength(), _ax.getMinValue(), _ax.getMaxValue());
      _effect.setYAxisValues(_ay.getLength(), _ay.getMinValue(), _ay.getMaxValue());
    }
  }
}
