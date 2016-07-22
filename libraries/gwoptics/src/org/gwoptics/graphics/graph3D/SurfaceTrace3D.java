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
import org.gwoptics.graphics.colourmap.IColourmap;

import processing.core.PApplet;

/**
 * <p> This class encapsulates a surface trace on a graph. It handles processing
 * each point on the grid as well as colouring it it also handles relating graph
 * space to world space(see below). This object is designed to work with the
 * SurfaceGraph3D closely, or anything that uses Axis3D objects in a Cartesian
 * form. </p> <p> Firstly world space is the size of everything render in the
 * sketch, so if we specify something has a length 100 its a 100 units long and
 * at whatever position we set it at in units. Graph space on the other hand
 * relates to the fact we can have axis ranges, for example -10 to 10, which is
 * displayed along out axis which has a world length of 100. therefore 0 in
 * graph space relates to 50 units along the axis in world space. </p>
 *
 * @author Daniel Brown 16/6/09
 * @since 0.2.2
 * @see SquareGridMesh
 * @see IColourmap
 */
public class SurfaceTrace3D extends Renderable {

  public String name; //name of trace
  private SquareGridMesh _grid; //Mesh representing surface
  private IColourmap _heightMap; //is the colourmap used to colour surface
  private IGraph3DCallback _callback; //callback that contains an equation to generate the surface
  private boolean _updateGrid; //boolean that specifies whether to update grid points or not
  private float _dx; //Graph space difference between each point on x direction
  private float _dy; //Graph space difference between each point on z direction
  private Axis3D _ax, _az, _ay; //pointers to axis that the surface is traced against
  private float[] _highestValue = new float[3];
  private float[] _lowestValue = new float[3];
  private boolean _autoRangeZaxis = false;

  //Setters - These setters seem fairly obvious from their names what they do...
  public void setCallback(IGraph3DCallback cb) {
    _callback = cb;
    _updateGrid = true;
  }

  public void setIsSurfacedStroked(boolean b) {
    _grid.isStroked = b;
  }

  public void setSurfaceStroke(GWColour c) {
    _grid.strokeColour = c;
  }

  public void setIsSurfaceFilled(boolean b) {
    _grid.isFilled = b;
  }

  public void setSurfaceFill(GWColour c) {
    _grid.fillColour = c;
  }

  public void setAutoRangeZAxis(boolean value) {
    _autoRangeZaxis = value;
  }

  //Getters
  public float getZValue(int X, int Y) {
    return _grid.getZValue(X, Y);
  }

  public float[] getMaximumPoint() {
    return _highestValue;
  }

  public float[] getLowestPoint() {
    return _lowestValue;
  }

  /**
   * To generate a surface trace all 3 cartesian axis that the trace is mapped
   * onto need to be supplied, also the resolution of the grid in both X and Y
   * directions. A callback must be specified or a NullReferenceException will
   * be throw, the colourmap object on the other hand is nullable.
   *
   * @param parent PApplet that will render this object
   * @param x Reference to X Axis
   * @param y Reference to Y Axis
   * @param z Reference to Z Axis
   * @param Xresolution Number of squares in X direction
   * @param Yresolution Number of squares in Z direction
   * @param cb Callback object which defines the equation of the surface
   * @param n Name of the trace
   * @param map Colourmap used to colour surface. Can be null for for wireframe.
   */
  public SurfaceTrace3D(PApplet parent, Axis3D x, Axis3D y, Axis3D z, int Xresolution, int Yresolution, IGraph3DCallback cb, String n, IColourmap map) {
    super(parent);

    if (cb == null) {
      throw new NullPointerException("A callback object must be specified for a trace.");
    }

    int _gridXResolution;
    int _gridYResolution;

    if (Xresolution < 1) {
      _gridXResolution = 1;
    } else {
      _gridXResolution = Xresolution;
    }
    if (Yresolution < 1) {
      _gridYResolution = 1;
    } else {
      _gridYResolution = Yresolution;
    }

    _ax = x;
    _ay = y;
    _az = z;
    name = n;
    _callback = cb;
    _heightMap = map;
    _grid = new SquareGridMesh(_gridXResolution,
            _gridYResolution,
            x.getLength() / _gridXResolution,
            y.getLength() / _gridYResolution,
            parent);

    if (map != null) {
      _grid.isColoured = true;
      // added 200210 adf
      if (map.isGenerated() == false) {
        map.generateColourmap();
      }
    }
    calculateSpacing();
    _updateGrid = true;
  }

  /**
   * This function must be called when an axis changes its range as the graph to
   * world space constants will change.
   */
  public void calculateSpacing() {
    //take range of axis and divide by the number of squares in each direction
    //to get how much each square represents in graph space.
    _dx = (_ax.getMaxValue() - _ax.getMinValue()) / _grid.sizeX();
    _dy = (_ay.getMaxValue() - _ay.getMinValue()) / _grid.sizeY();
  }

  /**
   * This function calls the callback object set during the constructor, and
   * applies the equation is represents to each of the points, relating graph
   * space to world space for correctly position traces.
   */
  public void generateSurface() {
    if (_callback != null && _updateGrid == true) {
      float val = 0;	//holds the value return by callback equation
      float zMax = 0;
      float zMin = 0;
      float c = 0; //constant used in converting from graph to world space
      float d = 0; //constant used to normalise val to get a colour value.
      float[][] _vals = null;
      float range = 1;

      _highestValue = new float[3];
      _lowestValue = new float[3];

      if (_autoRangeZaxis) {
        _vals = new float[_grid.sizeX() + 1][_grid.sizeY() + 1];
      } else {
        zMax = _az.getMaxValue();
        zMin = _az.getMinValue();
        c = _az.getLength() / (zMax - zMin);
        d = 1 / (zMax - zMin);
      }

      for (int i = 0; i <= _grid.sizeX(); i++) {
        for (int j = 0; j <= _grid.sizeY(); j++) {
          //here we calculate the graph space value of each of the points on the grid and passing
          // them to the equation in the callback object.
          val = _callback.computePoint(_ax.getMinValue() + i * _dx, _ay.getMinValue() + j * _dy);

          if (val > _highestValue[2]) {
            _highestValue[0] = i * _dx;
            _highestValue[1] = j * _dx;
            _highestValue[2] = val;
          } else if (val < _lowestValue[2]) {
            _lowestValue[0] = i * _dx;
            _lowestValue[1] = j * _dx;
            _lowestValue[2] = val;
          }

          //Check if we are autoranging the z axis, in this case
          //we need to calc all values find the max and min then
          //rescale the z-axis. once this is done then plot data
          // Also need to confirm that the array has been created
          // 17-3-2010 pkl
          if (_autoRangeZaxis && _vals != null) {
            _vals[i][j] = val;
          } else {
            //clamp values to the max/min height of z axis
            if (val < zMin) {
              val = zMin;
            }
            if (val > zMax) {
              val = zMax;
            }

            //self explanatory this bit, normalise the val returned to get a colour for this point 
            if (_grid.isColoured == true) {
              _grid.setVertexColour(i, j, _heightMap.getColourAtLocation(Math.abs((val - zMin) * d)));
            }
            //convert from graph space to world
            _grid.setZValue(i, j, (val - zMin) * c);
          }
        }
      }
      // Also need to confirm that the array has been created
      // 17-3-2010 pkl
      if (_autoRangeZaxis && _vals != null) {
        //Calc all conversion variables
        zMax = _highestValue[2];
        zMin = _lowestValue[2];
        c = _az.getLength() / (zMax - zMin);

        //determine whether the middle point of the colour map represents 0, if so 
        //we need to make sure 0 value is the colour at 0.5 on the colourmap
        if (_heightMap.isCentreAtZero()) {
          range = Math.max(Math.abs(zMax), Math.abs(zMin));
          d = 1 / (range * 2);
        } else {
          range = Math.abs(zMax - zMin);
          d = 1 / (zMax - zMin);
        }

        _az.setMaxValue(_highestValue[2]);
        _az.setMinValue(_lowestValue[2]);

        for (int i = 0; i <= _grid.sizeX(); i++) {
          for (int j = 0; j <= _grid.sizeY(); j++) {
            //self explanatory this bit, normalise the val returned to get a colour for this point 
            if (_grid.isColoured == true) {
              // I don't understand the `1-' in the equation below
              // Daniel - the '1-' is because when _vals = range (so a maximum) the output is 0 which is minimum on colourmap
              // so the 1- just inverts this.
              _grid.setVertexColour(i, j, _heightMap.getColourAtLocation(1 - Math.abs(_vals[i][j] - range) * d));
            }
            //convert from graph space to world
            _grid.setZValue(i, j, (_vals[i][j] - zMin) * c);
          }
        }
      }
    }
  }

  /**
   * Draws the surface trace
   */
  public void draw() {
    _grid.draw();
  }
}
