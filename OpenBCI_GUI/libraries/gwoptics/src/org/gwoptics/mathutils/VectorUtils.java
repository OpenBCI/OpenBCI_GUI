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
package org.gwoptics.mathutils;

import processing.core.PVector;

public class VectorUtils {

  /**
   * Rotates a given vector about an arbitrary axis. All rotations are about the
   * origin point to translations may be necessary after this step.
   *
   * <p>Equation used in this code is from the book Mathematics for 3D game
   * programming by Eric Lengyel, 2nd Edition, page 78, ISBN 1-58450-277-0.</p>
   *
   * @param P
   * @param A
   * @param theta
   * @return
   */
  public static PVector rotateArbitaryAxis(PVector P, PVector A, float theta) {
    A.normalize();

    //All these are just constants that are repeated in the 
    //final matrix, check out the book for more details
    float c = (float) TrigLookup.cos(theta);
    float s = (float) TrigLookup.sin(theta);
    float c1 = 1 - c;
    float kxy = c1 * A.x * A.y;
    float kyz = c1 * A.y * A.z;
    float kxz = c1 * A.x * A.z;
    float sz = s * A.z;
    float sx = s * A.x;
    float sy = s * A.y;

    float m00 = (float) (c + c1 * Math.pow(A.x, 2));
    float m01 = kxy - sz;
    float m02 = kxz + sy;

    float m10 = kxy + sz;
    float m11 = (float) (c + c1 * Math.pow(A.y, 2));
    float m12 = kyz - sx;

    float m20 = kxz - sy;
    float m21 = kyz + sx;
    float m22 = (float) (c + c1 * Math.pow(A.z, 2));

    double[][] mRy = {{m00, m01, m02}, {m10, m11, m12},
      {m20, m21, m22}};

    return new PVector((float) (P.x * mRy[0][0] + P.y * mRy[0][1] + P.z
            * mRy[0][2]), (float) (P.x * mRy[1][0] + P.y * mRy[1][1] + P.z
            * mRy[1][2]), (float) (P.x * mRy[2][0] + P.y * mRy[2][1] + P.z
            * mRy[2][2]));
  }
}
