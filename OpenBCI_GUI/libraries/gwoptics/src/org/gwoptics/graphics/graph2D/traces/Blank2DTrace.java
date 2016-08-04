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

import org.gwoptics.graphics.graph2D.Axis2D;
import org.gwoptics.graphics.graph2D.IGraph2D;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;

public abstract class Blank2DTrace implements IGraph2DTrace {

  private IGraph2D _graphDrawable;
  protected PApplet _parent;
  protected PGraphics _backBuffer;
  protected PImage _traceImg;
  private boolean _redraw;
  private String _renderer = PApplet.P2D;
  protected PlotRenderer _prenderer;
  protected IGraph2D getGraph(){ return _graphDrawable; }
  
  public class PlotRenderer {
	public PGraphics canvas;
	private Axis2D _x, _y;
	private float _offx, _offy;
	
	public PlotRenderer(IGraph2D grph, PGraphics canvas){
		this.canvas = canvas;
		
		this._x = grph.getXAxis();
		this._y = grph.getYAxis();
	}
	
	/***
	 * Called Internally by Blank2DTrace to update the internal
	 * variables for computing offsets.
	 * @param offx
	 */
	protected void update(){
		_offx = _x.valueToPosition(0);
		_offy = _y.valueToPosition(0);
	}
	
	public float valToX(double value){
		return _x.valueToPosition(value) - _offx;
	}
	
	public float valToY(double value){
		return _y.valueToPosition(value) - _offy;
	}
  }
  
  /**
   * Sets the renderer for the PGraphics object that is used for drawing to.
   * 
   * @param renderer P2D or JAVA2D
   */
  public final void setRenderer(String renderer){
    if(!renderer.equals(PApplet.JAVA2D) & !renderer.equals(PApplet.P2D) & !renderer.equals(PApplet.OPENGL))
      throw new RuntimeException("Renderer must be JAVA2D, P2D or OPENGL");
    
    _renderer = renderer;
  }
  
  @Override
  public void generate() {
    _redraw = true;
  }

  @Override
  public void onAddTrace(Object[] traces) {
  }

  @Override
  public void onRemoveTrace() {
  }

  @Override
  public void setPosition(int x, int y) {
  }

  @Override
  public void setParent(PApplet parent) {
    if (parent == null) {
      throw new NullPointerException("Cannot assign a null PApplet object as a parent.");
    } else {
      _parent = parent;
    }
  }

  @Override
  public void setGraph(IGraph2D grp) {
    if (grp == null) {
      throw new NullPointerException("Cannot assign a null graph2D object to draw on.");
    } else if (_graphDrawable != null) {
      throw new RuntimeException("A Graph2D object has already been set for this trace"
              + ", other components may have already referenced the previous Graphs objects.");
    }

    if (_parent == null) {
      throw new NullPointerException("Parent PApplet object is null.");
    }

    _graphDrawable = grp;
    _backBuffer = _parent.createGraphics(grp.getXAxis().getLength(), grp.getYAxis().getLength(), _renderer);
        
    _prenderer = new PlotRenderer(grp, _backBuffer);
  }

  @Override
  public void draw() {
    if (_redraw) {
      _backBuffer.beginDraw();
      
      _prenderer.update();
      
      Axis2D ax = _graphDrawable.getXAxis();
      Axis2D ay = _graphDrawable.getYAxis();

      float xoff = ax.valueToPosition(0);
      float yoff = _backBuffer.height - ay.valueToPosition(0);
      
      _backBuffer.translate(xoff, yoff);
      _backBuffer.pushMatrix();

      _backBuffer.scale(1f,-1f);
      _backBuffer.background(0, 0, 0, 0);
      
      _backBuffer.strokeCap(PApplet.SQUARE);
      
      TraceDraw(_prenderer);

      _backBuffer.popMatrix();
      _backBuffer.endDraw();

      _traceImg = _backBuffer.get(0, 0, _backBuffer.width, _backBuffer.height);
      _redraw = false;
    }
    
    if(_traceImg!=null)
      _parent.image(_traceImg, 0, -_backBuffer.height);
  }

  public abstract void TraceDraw(PlotRenderer p);
}
