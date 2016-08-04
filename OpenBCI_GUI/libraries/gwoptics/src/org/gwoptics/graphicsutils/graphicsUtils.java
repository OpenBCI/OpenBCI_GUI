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
package org.gwoptics.graphicsutils;

import processing.core.PMatrix3D;
import processing.core.PVector;

/**
 * Contains an assortment of functions that can help with some trickier
 * graphical problems.
 *
 * @author Daniel Brown
 */
public class graphicsUtils {

  /**
   * This function takes a 3D point and determines which pixels on the screen it
   * maps too. This has various uses such as overlays of 3D displays, or
   * altering pixels using the pixel array around certain areas depending on
   * object 3D position.
   *
   * @param view Camera view matrix
   * @param proj Camera projection matrix
   * @param vec 3D point to map to screen coordinates
   * @param width width of viewport
   * @param height height of viewport
   * @return PVector with 2D screen coordinates in the X and Y component of the
   * vector
   */
  public static float[] convertWorldToScreen(PMatrix3D view, PMatrix3D proj, PVector vec, float width, float height) {
    float[] v = new float[4];
    float[] v1 = new float[4];
    float[] v2 = new float[4];

    v[0] = vec.x;
    v[1] = vec.y;
    v[2] = vec.z;
    v[3] = 1.0f;

    view.mult(v, v1);
    proj.mult(v1, v2);

    v2[0] /= v2[3];
    v2[1] /= v2[3];
    v2[2] /= v2[3];

    float[] rtn = new float[2];
    rtn[0] = (float) (v2[0] + (1 + v2[0]) * width * 0.5);
    rtn[1] = (float) (v2[1] + (1 + v2[1]) * height * 0.5);

    return rtn;
  }
}
