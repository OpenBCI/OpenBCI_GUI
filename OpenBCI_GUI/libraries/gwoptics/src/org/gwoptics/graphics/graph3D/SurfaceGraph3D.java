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

import java.util.ArrayList;

import org.gwoptics.ArgumentException;
import org.gwoptics.ValueType;
import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.Renderable;
import org.gwoptics.graphics.colourmap.IColourmap;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;

/**
 * <p> This class incorporates the Axis3D and SurfaceTrace3D objects to
 * construct a 3D Cartesian surface graph. It is possible to draw several
 * surface traces, but care must be taken not to incorporate to many points if
 * the graph is to be rendered with a moving camera, otherwise slower system
 * will struggle to render the graph. </p> <p> Once the graph is created, it is
 * possible to add traces using the addSurfaceTrace() function. You must specify
 * a callback for the trace which defines the equation it represents. The
 * callback must implement the IGraph3DCallback interface, which allows it to
 * work with the SurfaceTrace3D class by providing a function to compute the
 * values of each point on the surface. It is also possible to specify a
 * colourmap to colour the trace. Several presets can be found in
 * org.gwoptics.graphics.colourmap.presets, or unique ones can be created using
 * the RGBColourmap object. Once the trace is added it must be plotted everytime
 * it is changed using plotSurfaceTrace() otherwise changes will not be seen.
 * </p> <p> The graphs position denotes the point where all 3 axes meet, the x,y
 * and z axes then all extend in the positive direction by the length values
 * supplied. If in the constructor setAxisCrossAtZero is true, position denotes
 * the location of the minimum point of the z-axis. Axis x and y will then alter
 * themselves automatically to get as close to zero on the z-axis as possible.
 * Due to screen space defining the y axis as 'down' the screen from the top
 * corner, it is recommended that PApplet.scale(1,-1,1) is applied before
 * drawing the graph or a suitable rotation. Or use the Camera3D class which
 * defines the upwards direction to be -y automatically. </p> <p> <b>Important
 * Note:</b> Due to notation the x and y directions should relate to the grid
 * plane the the height in the z direction. Though due to the way screen space
 * works y is the up direction. This must be taken into account throughout this
 * class. </p>
 *
 * <p> <b>History</b><br/> Version 0.3.6 Added functionality to auto-range
 * Z-Axis for a given surface. Can now alter colour of tick and fonts of axis
 * <br/> <br/> Version 0.3.0 Altered to ensure labels were correctly aligned and
 * that the graph was right-handed. <br/> <br/> Version 0.2.4 sees a breaking
 * change of notation relating z as the up direction, see important note above
 * for more implications of this change. Also changed class to final, so it cant
 * be extended. <br/> <br/> Version 0.2.2 sees the introduction of traces,
 * before only one surface was plotted. This is not backwards compatiable. </p>
 *
 * <pre>
 * <code>
 * 	//Example Code for simple sin graph.
 * 	g3d = new SurfaceGraph3D(this, 500, 100,500);
 * 	g3d.setXAxisMin(-2);
 * 	g3d.setXAxisMax(2);
 * 	g3d.setYAxisMin(-2);
 * 	g3d.setYAxisMax(2);
 * 	g3d.setZAxisMin(-1);
 * 	g3d.setZAxisMax(1);
 *
 * 	//Plot sin graph using preset hot colourmap
 * 	g3d.addSurfaceTrace(new IGraph3DCallback(){
 * 		public float computePoint(float X, float Y) {
 * 			return Math.sin(X) * Math.sin(Y);
 * 		}}, 100, 100, new HotColourmap(true));
 *
 * 	//Once trace is added it must be plotted.
 * 	g3d.plotSurfaceTrace(0);
 * </code>
 * </pre>
 *
 * @author Daniel Brown 8/6/09
 * @since 0.1.1
 * @see Axis3D
 * @see SurfaceTrace3D
 * @see RGBColourmap
 * @see org.gwoptics.graphics.colourmap.presets
 * @see IGraph3DCallback
 */
public final class SurfaceGraph3D extends Renderable {

  private Axis3D _ax, _az, _ay;
  private ArrayList<SurfaceTrace3D> _traces; // list of traces
  // world space lengths of axes
  private float _xLength;
  private float _zLength;
  private float _yLength;
  //private boolean _drawXAxis;
  //private boolean _drawYAxis;
  //private boolean _drawZAxis;
  private int _autoRangeSurfaceIX;
  private boolean _setAxisCrossAtZero;

  public float getZAxisMax() {
    return _az.getMaxValue();
  }

  // Setters
  public void setXAxisMin(float l) {
    _ax.setMinValue(l);
    _alterSurfaceSpacing();
    _alignAxesToZeroPoint();
  }

  public void setYAxisMin(float l) {
    _ay.setMinValue(l);
    _alterSurfaceSpacing();
    _alignAxesToZeroPoint();
  }

  public void setZAxisMin(float l) {
    _az.setMinValue(l);
    _alignAxesToZeroPoint();
  }

  public void setXAxisMax(float l) {
    _ax.setMaxValue(l);
    _alignAxesToZeroPoint();
  }

  public void setYAxisMax(float l) {
    _ay.setMaxValue(l);
    _alterSurfaceSpacing();
    _alignAxesToZeroPoint();
  }

  public void setZAxisMax(float l) {
    _az.setMaxValue(l);
    _alterSurfaceSpacing();
    _alignAxesToZeroPoint();
  }

  public void setXAxisLabel(String s) {
    _ax.setAxisLabel(s);
  }

  public void setYAxisLabel(String s) {
    _ay.setAxisLabel(s);
  }

  public void setZAxisLabel(String s) {
    _az.setAxisLabel(s);
  }

  public void setXAxisLabelAccuracy(int l) {
    _ax.setTickLabelAccuracy(l);
  }

  public void setYAxisLabelAccuracy(int l) {
    _ay.setTickLabelAccuracy(l);
  }

  public void setZAxisLabelAccuracy(int l) {
    _az.setTickLabelAccuracy(l);
  }

  public void setXAxisLabelType(ValueType l) {
    _ax.setTickLabelType(l);
  }

  public void setYAxisLabelType(ValueType l) {
    _ay.setTickLabelType(l);
  }

  public void setZAxisLabelType(ValueType l) {
    _az.setTickLabelType(l);
  }

  public void setXAxisMajorTicks(int n) {
    _ax.setMajorTicks(n);
  }

  public void setXAxisMinorTicks(int n) {
    _ax.setMinorTicks(n);
  }

  public void setYAxisMajorTicks(int n) {
    _ay.setMajorTicks(n);
  }

  public void setYAxisMinorTicks(int n) {
    _ay.setMinorTicks(n);
  }

  public void setZAxisMajorTicks(int n) {
    _az.setMajorTicks(n);
  }

  public void setZAxisMinorTicks(int n) {
    _az.setMinorTicks(n);
  }

  /*
   * public void setDrawXAxis(boolean val){_drawXAxis = val;} public void
   * setDrawYAxis(boolean val){_drawYAxis = val;} public void
   * setDrawZAxis(boolean val){_drawZAxis = val;}
   */
  public void setBillboarding(boolean value) {
    _ax.setTickLabelBillboarding(value);
    _ay.setTickLabelBillboarding(value);
    _az.setTickLabelBillboarding(value);
  }

  public void setDrawLines(boolean value) {
    _ax.setDrawLine(value);
    _ay.setDrawLine(value);
    _az.setDrawLine(value);
  }

  public void setDrawTickLabels(boolean value) {
    _ax.setDrawTickLabels(value);
    _ay.setDrawTickLabels(value);
    _az.setDrawTickLabels(value);
  }

  public void setDrawTicks(boolean value) {
    _ax.setDrawTicks(value);
    _ay.setDrawTicks(value);
    _az.setDrawTicks(value);
  }

  public void setDrawAxisLabel(boolean value) {
    _ax.setDrawAxisLabel(value);
    _ay.setDrawAxisLabel(value);
    _az.setDrawAxisLabel(value);
  }

  public void setAxisColour(int R, int G, int B) {
    setAxisColour(new GWColour(R, G, B));
  }

  public void setAxisColour(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Colour argument cannot be null");
    }

    _ax.setAxisColour(c);
    _ay.setAxisColour(c);
    _az.setAxisColour(c);
  }

  public void setFontColour(int R, int G, int B) {
    setFontColour(new GWColour(R, G, B));
  }

  public void setFontColour(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Colour argument cannot be null");
    }

    _ax.setFontColour(c);
    _ay.setFontColour(c);
    _az.setFontColour(c);
  }

  /**
   * Use this to set a surface to automatically set the min and max values of
   * the Z-axis to match the computed values, resulting in no clipping of
   * surface points.
   *
   * Set index to -1 if no auto-ranging is required.
   *
   * @param surfaceIndex The index of the surface to autorange the z axis
   */
  public void setAutoRanging(int surfaceIndex) {
    if (surfaceIndex > _traces.size() - 1) {
      throw new ArgumentException(
              "This surface trace index does not exist in the traces available");
    }

    SurfaceTrace3D t = null;

    // Disable old surface
    if (_autoRangeSurfaceIX > -1) {
      t = _traces.get(_autoRangeSurfaceIX);
      if (t != null) {
        t.setAutoRangeZAxis(false);
      }
    }

    if (surfaceIndex < -1) {
      surfaceIndex = -1;
    }

    _autoRangeSurfaceIX = surfaceIndex;

    if (surfaceIndex > -1) {
      t = _traces.get(surfaceIndex);

      if (t != null) {
        t.setAutoRangeZAxis(true);
      }
    }
  }

  /**
   * All that needs to be specified to generate a graph is its dimensions. This
   * sets a default state for all the axes, like which direction the labels are
   * drawn in and label sizes etc. Some of these properties are changeable using
   * the various axis setter functions.
   *
   * @param p PApplet that will render this object
   * @param xLength Length of the X-Axis
   * @param yLength Length of the Y-Axis
   * @param zLength Length of the Z-Axis
   */
  public SurfaceGraph3D(PApplet p, float xLength, float yLength, float zLength) {
    this(p, xLength, yLength, zLength, false);
  }

  /**
   * All that needs to be specified to generate a graph is its dimensions. This
   * sets a default state for all the axes, like which direction the labels are
   * drawn in and label sizes etc. Some of these properties are changeable using
   * the various axis setter functions.
   *
   * @param p PApplet that will render this object
   * @param xLength Length of the X-Axis
   * @param yLength Length of the Y-Axis
   * @param zLength Length of the Z-Axis
   * @param setAxisCrossAtZero boolean stating whether to make axes cross at
   * zero
   */
  public SurfaceGraph3D(PApplet p, float xLength, float yLength,
          float zLength, boolean setAxisCrossAtZero) {
    super(p);

    _az = new Axis3D(_parent);
    _ax = new Axis3D(_parent);
    _ay = new Axis3D(_parent);

    //_drawXAxis = _drawYAxis = _drawZAxis = true;

    if (xLength < 1) {
      _xLength = 1;
      _ax.setDraw(false);
    } else {
      _xLength = xLength;
    }
    if (zLength < 1) {
      _zLength = 1;
      _az.setDraw(false);
    } else {
      _zLength = zLength;
    }
    if (yLength < 1) {
      _yLength = 1;
      _ay.setDraw(false);
    } else {
      _yLength = yLength;
    }

    _traces = new ArrayList<SurfaceTrace3D>();
    _autoRangeSurfaceIX = -1;

    _az.setAxesDirection(new PVector(0, 1, 0)); // z axis plotted in y
    // direction
    _az.setAxisLabel("Z-Axis");
    _az.position = new PVector(0, 0, 0);
    _az.setLength(_zLength);
    _az.setLabelDirection(new PVector(-1, 0, -1));
    _az.setTickLabelXRotation(PConstants.PI);
    _az.setTickLabelYRotation(-PConstants.PI + PConstants.PI / 4);
    _az.setLabelZRotation(PConstants.PI / 2);
    _az.setLabelXRotation(PConstants.PI - PConstants.PI / 6);
    _az.setTickLabelBillboarding(false);

    // These settings are mostly trial and error to get the
    // best looking results
    _ax.setAxesDirection(new PVector(1, 0, 0));
    _ax.setAxisLabel("X-Axis");
    // _ax.setLabelYRotation(PConstants.PI);
    _ax.setLabelXRotation(-PConstants.PI / 2);
    _ax.setLabelOffset(10);
    _ax.setLength(_xLength);
    _ax.setTickLabelYRotation(PConstants.PI / 2);
    _ax.setTickLabelZRotation(PConstants.PI / 2);
    _ax.setLabelDirection(new PVector(0, 0, -1));
    _ax.position = new PVector(0, 0, 0);
    _ax.setTickLabelBillboarding(false);

    _ay.setAxesDirection(new PVector(0, 0, 1)); // y axis plotted in z
    // direction
    _ay.setAxisLabel("Y-Axis");
    _ay.setLength(_yLength);
    _ay.setLabelOffset(10);
    _ay.setLabelXRotation(PConstants.PI);
    _ay.setLabelYRotation(PConstants.PI / 2);
    _ay.setLabelZRotation(PConstants.PI / 2);
    _ay.setTickLabelYRotation(PConstants.PI / 2);
    _ay.setTickLabelZRotation(PConstants.PI / 2);
    _ay.setTickLabelXRotation(-PConstants.PI / 2);
    _ay.setLabelDirection(new PVector(-1, 0, 0));
    _ay.position = new PVector(0, 0, 0);
    _ay.setTickLabelBillboarding(false);

    _setAxisCrossAtZero = setAxisCrossAtZero;
  }

  private void _alignAxesToZeroPoint() {
    if (_setAxisCrossAtZero
            && (_az.getMinValue() <= 0 && _az.getMaxValue() >= 0)) {
      float pos;

      pos = Math.abs(_az.getLength()
              * Math.abs(_az.getMinValue()
              / (_az.getMaxValue() - _az.getMinValue())));

      _ax.position = new PVector(0, pos, 0);
      _ay.position = new PVector(0, pos, 0);
    } else {
      _ax.position = new PVector(0, 0, 0);
      _ay.position = new PVector(0, 0, 0);
    }
  }

  private void _alterSurfaceSpacing() {
    synchronized (_traces) {
      for (SurfaceTrace3D s : _traces) {
        s.calculateSpacing();
      }
    }
  }

  // Trace functions
  public int getTraceCount() {
    synchronized (_traces) {
      return _traces.size();
    }
  }

  /**
   * Adds a surface trace to the graph.
   *
   * @param cb IGraph3DCallback that represents the equation of the trace
   * @param XRes Number of squares along x side of grid, the higher the more
   * detailed the graph
   * @param YRes Number of squares along z side of grid, the higher the more
   * detailed the graph
   * @param map Null for wireframe rendering. Otherwise specifies how to colour
   * the surface.
   */
  public void addSurfaceTrace(IGraph3DCallback cb, int XRes, int YRes,
          IColourmap map) {
    synchronized (_traces) {
      _traces.add(new SurfaceTrace3D(_parent, _ax, _ay, _az, XRes, YRes,
              cb, String.valueOf(_traces.size() + 1), map));
    }
  }

  /**
   * Removes trace from the graph.
   *
   * @param index Index of trace to remove
   */
  public void removeSurfaceTrace(int index) {
    synchronized (_traces) {
      if (_traces.size() <= index) {
        throw new ArrayIndexOutOfBoundsException();
      }
      _traces.remove(index);
    }
  }

  /**
   * This function starts the surface calling the callback object to generate
   * the surface
   *
   * @param index index of trace the generate
   */
  public void plotSurfaceTrace(int index) {
    synchronized (_traces) {
      if (_traces.size() <= index) {
        throw new ArrayIndexOutOfBoundsException();
      }
      _traces.get(index).generateSurface();
    }
  }

  /**
   * sets the colour of the wireframe of a trace if no colourmap is specified
   *
   * @param index index of trace
   * @param c colour of wireframe
   */
  public void setTraceStroke(int index, GWColour c) {
    if (_traces.size() <= index) {
      throw new ArrayIndexOutOfBoundsException();
    }

    SurfaceTrace3D t = _traces.get(index);

    if (c == null) {
      t.setIsSurfacedStroked(false);
    } else {
      t.setIsSurfacedStroked(true);
      t.setSurfaceStroke(c);
    }
  }

  /**
   * Fills the trace with a solid colour if no colourmap is specified
   *
   * @param index index of trace
   * @param c colour to fill surface
   */
  public void setTraceFill(int index, GWColour c) {
    if (_traces.size() <= index) {
      throw new ArrayIndexOutOfBoundsException();
    }

    SurfaceTrace3D t = _traces.get(index);

    if (c == null) {
      t.setIsSurfaceFilled(false);
    } else {
      t.setIsSurfaceFilled(true);
      t.setSurfaceFill(c);
    }
  }

  // End Trace functions
  /**
   * Draws each segment of the graph, all the traces and axes.
   */
  public synchronized void draw() {
    synchronized (_traces) {
      _parent.pushMatrix();
      _parent.translate(position.x, position.y, position.z);
      // _parent.translate(-400,-400,0);
      // Although it looks better if it is slightly offset in wireframe
      // mode
      // it appears that you gain an extra fps(on my computer) if they
      // arent
      // applied.
      // _parent.translate((float)0.3,0,(float)0.3);

      for (SurfaceTrace3D s : _traces) {
        s.draw();
      }

      _alignAxesToZeroPoint();

      // _parent.translate((float)-0.3,0,(float)-0.3);
      _ax.draw();
      _ay.draw();
      _az.draw();
      _parent.popMatrix();
    }
  }
}
