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
package org.gwoptics.graphics.graph3D;

import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.Renderable;

import processing.core.PApplet;
import processing.core.PConstants;

/**
 * <p> SquareGridMesh is a square shaped grid with variable resolution along
 * both sides. Each point can have its height set allowing surfaces to be
 * generated. This object is originally designed to work with the SurfaceGraph3D
 * control, but is Usable without this for other purposes. </p>
 *
 * <p> Each point is coloured according to a supplied IColourmap, solid fill
 * colour or by wireframe. The colour and point positions are both stored in 2
 * arrays. Default values are a resolution along both sides of 10 squares each
 * 10 units in length. </p>
 *
 * <p> <b>Important Note:</b> It must be noted that although due to notation the
 * Z axis points upwards, in world space the Y axis points up. Therefore Z <-> Y
 * when it comes to plotting data. </p>
 *
 * @author Daniel Brown 8/6/09
 * @since 0.1.1
 * @see Renderable
 * @see IColourmap
 */
public class SquareGridMesh extends Renderable {

  private int _X_size = 11; //number of points along x axis
  private int _Y_size = 11; //number of points along z axis
  private float _dx = 10; //x distance between points
  private float _dy = 10; //z distance between points
  protected float[][][] _vertexs;
  protected int[][][] _colour;
  /**
   * Specifies whether to use a colourmap to colour each vertex
   */
  public boolean isColoured;
  /**
   * If no colourmap is provided this is the stroke colour for the grid. Only
   * applies if isColoured is false.
   */
  public GWColour strokeColour;
  /**
   * States whether to fill the grid using fillColour. Only applies if
   * isColoured is false.
   */
  public boolean isFilled;
  /**
   * If no colourmap is provided this is the fill colour for the grid. Only
   * applies if isColoured is false.
   */
  public GWColour fillColour;
  /**
   * States whether to stroke the grid using strokeColour. Only applies if
   * isColoured is false.
   */
  public boolean isStroked;

  public float getWidth() {
    return _dx * (_X_size - 1);
  }

  public float getLength() {
    return _dy * (_Y_size - 1);
  }

  /**
   * Allows user to specify dimensions of the grid needed. By default the grid
   * is rendered in wireframe mode with stroke colour as white.
   *
   * @param X number of squares along the x axis
   * @param Y number of squares along the y axis
   * @param dx size of square in x direction
   * @param dy size of square in y direction
   * @param parent PApplet that the grid is rendered in
   */
  public SquareGridMesh(int X, int Y, float dx, float dz, PApplet parent) {
    super(parent);

    if (X <= 0 || Y <= 0) {
      throw new IllegalArgumentException("Grid size dimensions should be greater than 0.");
    }

    //Add one to resolution so it determines the number of squares not points
    _X_size = X + 1;
    _Y_size = Y + 1;
    _dx = dx;
    _dy = dz;
    isColoured = false;
    isFilled = false;
    isStroked = true;
    strokeColour = new GWColour(1, 1, 1);
    fillColour = new GWColour(0.5f, 0.5f, 0.5f);

    _vertexs = new float[_X_size][_Y_size][3];
    _colour = new int[_X_size][_Y_size][3];

    //as the x and z components never change on the grid just the y we set
    //all the values now and then the y later
    for (int i = 0; i < _vertexs.length; i++) {
      for (int j = 0; j < _vertexs[0].length; j++) {
        _vertexs[i][j][0] = i * _dx;
        _vertexs[i][j][2] = j * _dy;
      }
    }
  }

  /**
   * This function sets the Z value of a given point at X and Y. X and Y both
   * refer to the index of the point.
   *
   * @param X
   * @param Y
   * @param Z
   */
  public void setZValue(int X, int Y, float Z) {
    if (X < 0 || Y < 0 || X > _X_size - 1 || Y > _Y_size - 1) {
      throw new ArrayIndexOutOfBoundsException();
    }
    _vertexs[X][Y][1] = Z;//remember plot Z as Y
  }

  /**
   * Sets the colour of a given point at indexes X and Y.
   *
   * @param X
   * @param Y
   * @param c
   */
  public void setVertexColour(int X, int Y, GWColour c) {
    if (X < 0 || Y < 0 || X > _X_size - 1 || Y > _Y_size - 1) {
      throw new ArrayIndexOutOfBoundsException();
    }
    _colour[X][Y][0] = (int) (c.R * 255);
    _colour[X][Y][1] = (int) (c.G * 255);
    _colour[X][Y][2] = (int) (c.B * 255);
  }

  /**
   * Returns height of point at index X and Y.
   */
  public float getZValue(int X, int Y) {
    return _vertexs[X][Y][1];
  }

  public void draw() {
    _parent.pushMatrix();

    if (isColoured) {
      _ColouredDraw();
    } else {
      _noColourDraw();
    }

    _parent.popMatrix();
  }

  /**
   * This function is used when no colourmap is given
   */
  private void _noColourDraw() {
    //moved these 2 check outside the loop
    if (isFilled) {
      _parent.fill(fillColour.toInt());
    } else {
      _parent.noFill();
    }

    if (isStroked) {
      _parent.stroke(strokeColour.toInt());
    } else {
      _parent.noStroke();
    }

    for (int i = 0; i < _vertexs.length - 1; i++) {
      _parent.beginShape(PConstants.TRIANGLE_STRIP);

      for (int j = 0; j < _vertexs[0].length; j++) {
        //as in setZValue() earlier we saved the 'Z' as Y component we simply plot
        // the points as normal now
        _parent.vertex(_vertexs[i][j][0], _vertexs[i][j][1], _vertexs[i][j][2]);
        _parent.vertex(_vertexs[i + 1][j][0], _vertexs[i + 1][j][1], _vertexs[i + 1][j][2]);
      }

      _parent.endShape();
    }
  }

  /**
   * This function is used when colours have been applied to each vertex
   */
  private void _ColouredDraw() {
    int k;
    _parent.noStroke();

    for (int i = 0; i < _vertexs.length - 1; i++) {
      _parent.beginShape(PConstants.TRIANGLE_STRIP);

      for (int j = 0; j < _vertexs[0].length; j++) {
        k = i + 1;
        //as in setZValue() earlier we saved the 'Z' as Y component we simply plot
        // the points as normal now
        _parent.fill(_colour[i][j][0], _colour[i][j][1], _colour[i][j][2]);
        _parent.vertex(_vertexs[i][j][0], _vertexs[i][j][1], _vertexs[i][j][2]);
        _parent.fill(_colour[k][j][0], _colour[k][j][1], _colour[k][j][2]);
        _parent.vertex(_vertexs[i + 1][j][0], _vertexs[i + 1][j][1], _vertexs[i + 1][j][2]);
      }

      _parent.endShape();
    }
  }

  /**
   * Returns number of squares along X side.
   */
  public int sizeX() {
    return _X_size - 1;
  }//1 is subtracted as we added one in the constructor
  //for the total number of points rather than squares.

  /**
   * Returns number of squares along Z side.
   */
  public int sizeY() {
    return _Y_size - 1;
  }
}
