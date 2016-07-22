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
package org.gwoptics.graphics.graph2D;

import java.util.ArrayList;
import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.Renderable;
import org.gwoptics.graphics.graph2D.Axis2D.Alignment;
import org.gwoptics.graphics.graph2D.backgrounds.IGraph2DBackground;
import org.gwoptics.graphics.graph2D.traces.IGraph2DTrace;
import processing.core.*;

/**
 * <p> Graph2D is a collection of Axis2D objects and IGraphTrace's. It is the
 * basis of a 2D graph and can have multiple traces added to it, with access to
 * various methods to alter the look and feel of the graph axes and layout. </p>
 * <p> The traces that this graph excepts must conform to the IGraphTrace
 * interface and must fully implement it correctly. The graph also allows full
 * control over the X and Y axes through controls that begin with setXAxis and
 * setYaxis. Also available is the option to display a border and major grid
 * lines. </p>
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 */
public class Graph2D extends Renderable implements PConstants, IGraph2D {

  protected Axis2D _ax, _ay;
  protected float _xLength, _yLength;
  protected GWColour _border;
  protected ArrayList<IGraph2DTrace> _traces;
  protected boolean _crossAxesAtZero;
  protected IGraph2DBackground _back;

  public void setXAxisTickSpacing(float s) {
    _ax.setTickSpacing(s);
  }

  public void setYAxisTickSpacing(float s) {
    _ay.setTickSpacing(s);
  }

  /**
   * Sets the minimum value to be shown on the X-Axis *
   */
  public void setXAxisMin(float val) {
    _ax.setMinValue(val);
  }

  /**
   * Sets the maximum value to be shown on the X-Axis *
   */
  public void setXAxisMax(float val) {
    _ax.setMaxValue(val);
  }

  /**
   * Sets the minimum value to be shown on the Y-Axis *
   */
  public void setYAxisMin(float val) {
    _ay.setMinValue(val);
  }

  /**
   * Sets the maximum value to be shown on the Y-Axis *
   */
  public void setYAxisMax(float val) {
    _ay.setMaxValue(val);
  }

  /**
   * Sets the label that describes the data shown on the X-Axis *
   */
  public void setXAxisLabel(String s) {
    _ax.setAxisLabel(s);
  }

  /**
   * Sets the label that describes the data shown on the Y-Axis *
   */
  public void setYAxisLabel(String s) {
    _ay.setAxisLabel(s);
  }

  /**
   * Sets the label position for the X-Axis *
   */
  public void setXAxisLabelPos(LabelPos lblpos) {
    _ax.setAxisLabelPos(lblpos);
  }

  /**
   * Sets the label position for the Y-Axis *
   */
  public void setYAxisLabelPos(LabelPos lblpos) {
    _ay.setAxisLabelPos(lblpos);
  }

  /**
   * Sets the decimal places to show on the X-Axis tick labels*
   */
  public void setXAxisLabelAccuracy(int l) {
    _ax.setTickLabelAccuracy(l);
  }

  /**
   * Sets the decimal places to show on the Y-Axis tick labels*
   */
  public void setYAxisLabelAccuracy(int l) {
    _ay.setTickLabelAccuracy(l);
  }

  /**
   * Sets number of minor ticks to show on the X-Axis*
   */
  public void setXAxisMinorTicks(int n) {
    _ax.setMinorTicks(n);
  }
  
  /** Sets the font of the X axis label */
  public void setXAxisLabelFont(String font, int size, boolean smooth){
    _ax.setLabelFont(font, size, smooth);
  }
  
  /** Sets the font of the X axis ticks */
  public void setXAxisTickFont(String font, int size, boolean smooth){
    _ax.setTickFont(font, size, smooth);
  }

  /** Sets the font of the Y axis label */
  public void setYAxisLabelFont(String font, int size, boolean smooth){
    _ay.setLabelFont(font, size, smooth);
  }
  
  /** Sets the font of the Y axis ticks */
  public void setYAxisTickFont(String font, int size, boolean smooth){
    _ay.setTickFont(font, size, smooth);
  }
  
  /**
   * Sets number of minor ticks to show on the Y-Axis*
   */
  public void setYAxisMinorTicks(int n) {
    _ay.setMinorTicks(n);
  }

  /**
   * Sets the colour of the X and Y axes, through RGB values*
   */
  public void setAxisColour(int R, int G, int B) {
    setAxisColour(new GWColour(R, G, B));
  }

  /**
   * Sets the colour of the X and Y axes, through a Colour object*
   */
  public void setAxisColour(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Colour argument cannot be null");
    }

    _ax.setAxisColour(c);
    _ay.setAxisColour(c);
  }

  /**
   * Sets the colour of the X and Y axes fonts, through RGB values*
   */
  public void setFontColour(int R, int G, int B) {
    setFontColour(new GWColour(R, G, B));
  }

  /**
   * Sets the colour of the X and Y fonts, through a Colour object*
   */
  public void setFontColour(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Colour argument cannot be null");
    }

    _ax.setFontColour(c);
    _ay.setFontColour(c);
  }

  /**
   *    */
  public IGraph2DBackground getGraphBackground() {
    return _back;
  }

  /**
   *    */
  public Axis2D getXAxis() {
    return _ax;
  }

  /**
   *    */
  public Axis2D getYAxis() {
    return _ay;
  }

  /**
   * Removes border *
   */
  public void setNoBorder() {
    _border = null;
  }

  /**
   * Sets the colour of the border surrounding the graph object*
   */
  public void setNoBackground() {
    _back = null;
  }

  /**
   * Sets the colour of the border surrounding the graph object*
   */
  public void setBorderColour(int R, int G, int B) {
    _border = new GWColour(R, G, B);
  }

  /**
   * Sets an IGraph2DBackground to use to fill the graph background
   */
  public void setBackground(IGraph2DBackground bk) {
    _back = bk;
    _back.setParent(_parent);
    _back.setAxes(_ax, _ay);
    _back.setDimensions(_ax.getLength(), _ay.getLength());
  }

  /**
   * Graph constructor that requires you to define the dimensions of the graph,
   * whether the axes should cross at the 0 and the parent PApplet object which
   * is rendering the graph.
   *
   * @param parent
   * @param xLength
   * @param yLength
   * @param crossAxesAtZero
   */
  public Graph2D(PApplet parent, int xLength, int yLength, boolean crossAxesAtZero) {
    super(parent);

    _crossAxesAtZero = crossAxesAtZero;

    _xLength = xLength;
    _yLength = yLength;

    _border = new GWColour(0, 0, 0);

    _ax = new Axis2D(parent, xLength);
    _ax.setTickLabelAlignment(Alignment.CENTER);
    _ax.setAxesDirection(new PVector(1, 0));
    _ax.setLabelDirection(new PVector(0, 1));
    _ax.setAxisLabel("X-Axis");

    _ay = new Axis2D(parent, yLength);
    _ay.setTickLabelAlignment(Alignment.RIGHT);
    _ay.setAxesDirection(new PVector(0, -1));
    _ay.setLabelDirection(new PVector(-1, 0));
    _ay.setLabelRotation(-PI / 2);
    _ay.setOffsetLabelByTickLength(true);
    _ay.setAxisLabel("Y-Axis");

    if (_crossAxesAtZero) {
      _alignAxesToZero();
    }

    _traces = new ArrayList<IGraph2DTrace>();
  }

  /**
   * Internal function called to realign axes
   */
  protected void _alignAxesToZero() {
    float xPos, yPos;

    xPos = PApplet.constrain(_ax.valueToPosition(0), 0, _ax.getLength());
    yPos = PApplet.constrain(_ay.valueToPosition(0), 0, _ay.getLength());

    _ax.position.y = -yPos;
    _ay.position.x = xPos;
  }

  /**
   * Method to add an object that has implements the IGraphTrace interface.
   * Throws exception if trace is null. Returns an integer which represents the
   * index of the array the trace is stored in.
   *
   * @param trace IGraphTrace
   * @return int Index that the trace is stored in the control
   */
  public int addTrace(IGraph2DTrace trace) {
    if (trace == null) {
      throw new NullPointerException("Trace object can not be null.");
    }

    int ix = -1;

    synchronized (_traces) {
      //reorder of the methods here to make sure that all
      //methods down the line have access to the parent PApplet
      trace.setParent(_parent);
      trace.setGraph(this);
      trace.onAddTrace(_traces.toArray());
      trace.generate();
      _traces.add(trace);
      ix = _traces.size() - 1;
    }

    return ix;
  }

  /**
   * Removes a trace from the graph depending on its index. Index of trace
   * increase from 0 by 1 for each trace added.
   *
   * @param trace
   */
  public void removeTrace(IGraph2DTrace trace) {
    synchronized (_traces) {
      trace.onRemoveTrace();
      _traces.remove(trace);
    }
  }

  /**
   * Calls the traces generate method to refresh data. Trace is identified by
   * its index.
   *
   * @param index
   */
  public void generateTrace(int index) {
    IGraph2DTrace t = _traces.get(index);
    t.generate();
  }

  /**
   * Draw method that calls various internal methods to generate each part of
   * the graph. Normally called from draw loop
   */
  @Override
  public void draw() {
    if (_crossAxesAtZero) {
      _alignAxesToZero();
    }

    _parent.pushMatrix();
    _parent.pushStyle();
    //Added height of the graph to the y position so that the control
    //is drawn with the top left corner being at the controls position 
    _parent.translate(position.x, position.y + _yLength);

    //From the bottom up draw background
    if (_back != null) {
      _back.draw();
    }

    if (_border != null) {
      _parent.stroke(_border.toInt());
      _parent.noFill();
      _parent.rect(0, 0, _xLength, -_yLength);
    }

    //put a lock on the traces object so other threads
    //cannot change values while we are drawing
    synchronized (_traces) {
      //need this to separate lines and background when drawing in 3D
      //if(!(_parent.g instanceof PGraphics2D || _parent.g instanceof PGraphicsJava2D))
      //	_parent.translate(0, 0,1f);

      for (IGraph2DTrace t : _traces) {
        t.draw();
      }
    }

    //if(!(_parent.g instanceof PGraphics2D || _parent.g instanceof PGraphicsJava2D))
    //	_parent.translate(0, 0,1f);

    _ax.draw();
    _ay.draw();

    _parent.popStyle();
    _parent.popMatrix();
    _parent.flush();
  }
}
