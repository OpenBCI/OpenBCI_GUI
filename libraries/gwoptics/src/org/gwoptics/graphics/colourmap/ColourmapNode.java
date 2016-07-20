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
package org.gwoptics.graphics.colourmap;

import org.gwoptics.graphics.GWColour;

/**
 * <p> ColourmapNode is a class that encapsulates the colour and location of a
 * point, on a colourmap. These nodes are then used to generate a gradient of
 * colour between 2 locations. Implements the Comparable interface to allow
 * sorting of nodes into location order. </p>
 *
 * @author Daniel Brown 12/6/09
 * @since 0.1.1
 */
public final class ColourmapNode implements Comparable<ColourmapNode> {

  public GWColour colour;
  public float location;

  public ColourmapNode() {
    colour = new GWColour();
    location = 0.0f;
  }

  /**
   * Custom constructor that allows user specified RGB and location values.
   *
   * @param R Value between 0.0f and 1.0f relating to the red colour.
   * @param G Value between 0.0f and 1.0f relating to the green colour.
   * @param B Value between 0.0f and 1.0f relating to the blue colour.
   * @param l Value between 0.0f and 1.0f relating to the location of the colour
   * on the colourmap.
   */
  public ColourmapNode(float R, float G, float B, float l) {
    colour = new GWColour(1f, R, G, B);
    location = l;
  }

  public ColourmapNode(float Alpha, float R, float G, float B, float l) {
    colour = new GWColour(Alpha, R, G, B);
    location = l;
  }

  public int compareTo(ColourmapNode o) {
    if (location < o.location) {
      return -1;
    }
    if (location == o.location) {
      return 0;
    }
    if (location > o.location) {
      return 1;
    }
    return 0;
  }
}