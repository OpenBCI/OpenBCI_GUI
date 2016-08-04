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

public class GridBackground extends SolidColourBackground {

  protected GWColour _gridXColour, _gridYColour;
  protected boolean _showX = true, _showY = true;

  /**
   * Constructors *
   */
  public GridBackground() {
    super(new GWColour(255, 255, 255));
    _gridXColour = new GWColour(0, 0, 0);
    _gridYColour = new GWColour(0, 0, 0);
  }

  public GridBackground(GWColour background) {
    super(background);
    _gridXColour = new GWColour(0, 0, 0);
    _gridYColour = new GWColour(0, 0, 0);
  }

  public GridBackground(GWColour gridColour, GWColour background) {
    super(background);
    _gridXColour = gridColour;
    _gridYColour = gridColour;
  }

  public GridBackground(GWColour gridColour, GWColour background, boolean ShowXAxisLines, boolean ShowYAxisLines) {
    super(background);
    _showX = ShowXAxisLines;
    _showY = ShowYAxisLines;
    _gridXColour = gridColour;
    _gridYColour = gridColour;
  }

  /**
   * Sets the colour of the major grid lines *
   */
  public void setGridColour(int R, int G, int B) {
    _gridYColour = new GWColour(R, G, B);
    _gridXColour = new GWColour(R, G, B);
  }

  /**
   * Set colour of grid lines independently *x sets X-axis line and *y set
   * Y-axis line colours. *
   */
  public void setGridColour(int Rx, int Gx, int Bx, int Ry, int Gy, int By) {
    _gridYColour = new GWColour(Ry, Gy, By);
    _gridXColour = new GWColour(Rx, Gx, Bx);
  }

  /**
   * Removes major grid lines *
   */
  public void setNoGrid() {
    _gridXColour = null;
    _gridYColour = null;
  }

  /**
   * Sets which lines to to show *
   */
  public void setGridLines(boolean ShowXAxisLines, boolean ShowYAxisLines) {
    _showX = ShowXAxisLines;
    _showY = ShowYAxisLines;
  }

  public void draw() {
    super.draw();

    if (_parent != null && _gridYColour != null && _gridXColour != null) {

      _parent.stroke(_gridXColour.toInt());
      if (_ax.getMajorTickPositions() != null && _showX) {
        for (Integer i : _ax.getMajorTickPositions()) {
          _parent.line(i, 0, i, -_ay.getLength());
        }
      }

      _parent.stroke(_gridYColour.toInt());
      if (_ay.getMajorTickPositions() != null && _showY) {
        for (Integer i : _ay.getMajorTickPositions()) {
          _parent.line(0, -i, _ax.getLength(), -i);
        }
      }
    }
  }
}