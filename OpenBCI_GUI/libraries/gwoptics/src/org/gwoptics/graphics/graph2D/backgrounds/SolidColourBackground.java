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
package org.gwoptics.graphics.graph2D.backgrounds;

import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.graph2D.Axis2D;

import processing.core.PApplet;

public class SolidColourBackground implements IGraph2DBackground {

  protected Axis2D _ax, _ay;
  protected int _width, _height;
  protected PApplet _parent;
  protected GWColour _background;

  /**
   * Sets the background colour of the graph *
   */
  public void setBackgroundColour(int R, int G, int B) {
    _background = new GWColour(R, G, B);
  }

  /**
   * Removes any background *
   */
  public void setNoBackground() {
    _background = null;
  }

  public SolidColourBackground(GWColour bk) {
    _background = bk;
  }

  public void setAxes(Axis2D x, Axis2D y) {
    _ax = x;
    _ay = y;
  }

  public void setDimensions(int width, int height) {
    _width = width;
    _height = height;
  }

  public void setParent(PApplet parent) {
    if (_parent != null) {
      throw new RuntimeException("Parent object has already been set");
    }

    _parent = parent;
  }

  public void draw() {
    if (_background != null && _parent != null) {
      _parent.pushStyle();
      _parent.pushMatrix();
      _parent.translate(0, -_height);
      _parent.fill(_background.toInt());
      _parent.noStroke();
      _parent.rect(0, 0, _width, _height);
      _parent.popStyle();
      _parent.popMatrix();
    }
  }
}
