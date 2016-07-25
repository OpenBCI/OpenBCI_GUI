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

import org.gwoptics.ValueType;
import org.gwoptics.graphics.GWColour;
import org.gwoptics.graphics.Renderable;
import org.gwoptics.graphics.camera.Camera3D;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PFont;
import processing.core.PVector;

/**
 * Axis3D class produces 3D axes with many variable properties to suite any
 * need. The axis can be be directed in any direction ,though it is more common
 * to use <1,0,0>, <0,1,0> or <0,0,1>, using setAxesDirection(). The axis has
 * full tick functionality using both major and minor ticks, with labels for
 * values along the axis shown for each major tick. As the axis is 3D you must
 * specify which plane the labels and ticks must be drawn using
 * setLabelDirection(). Unless strange looking axes are required it is
 * recommended to use a label direction which is orthogonal to the axis
 * direction. As Axis3D extends Renderable it has a position member which can be
 * used to position where the axis is. Both the axis label and tick labels can
 * be rotated using the given functions to generate the required layout of the
 * axis.
 *
 * History Version 0.3.8 Added billboarding to the tick labels, must be used
 * with Camera3D class though.
 *
 * @author Daniel Brown 8/6/09
 * @since 0.1.1
 */
public class Axis3D extends Renderable implements PConstants {

  private PVector _unitVec;
  private float _length = 100;
  private float _minShow = 0;
  private float _maxShow = 1;
  private int _axisLineWidth = 2;
  private int _axisTickLineWidth = 1;
  private static PFont _font;
  private String _label;
  private PVector _labelDirection;
  private int _majorTicks = 5;
  private int _minorTicks = 2;
  private int _majorTickSize = 10;
  private int _minorTickSize = 5;
  private int _axisTickLblSize = 8;
  private int _axisLblSize = 20;
  private PVector _axisTickLblRotation = new PVector(0, 0, 0);
  private PVector _axisLblRotation = new PVector(0, 0, 0);
  private float _axisLblOffset = 20;
  private GWColour _axisColour;
  private GWColour _fontColour;
  private boolean _drawLine;
  private boolean _drawTicks;
  private boolean _drawTickLabels;
  private boolean _drawName;
  private boolean _textBillboard;
  private ValueType _tickLblType;
  private int _accuracy;

  // private PVector[] _lblPos;
  // private String[] _lbl;
  // PMatrix3D view;
  // PMatrix3D proj;
  // Setter properties
  public void setAxisColour(int R, int G, int B) {
    setAxisColour(new GWColour(R, G, B));
  }

  public void setAxisColour(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Colour argument cannot be null");
    }
    _axisColour = c;
  }

  public void setFontColour(int R, int G, int B) {
    setFontColour(new GWColour(R, G, B));
  }

  public void setFontColour(GWColour c) {
    if (c == null) {
      throw new NullPointerException("Colour argument cannot be null");
    }
    _fontColour = c;
  }

  public void setTickLabelBillboarding(boolean value) {
    if (value) {
      if (Camera3D.getLookat() == null) {
        throw new RuntimeException(
                "To use text billboards you must use the Camera3"
                + "object in your scene.");
      } else {
        _textBillboard = value;
      }
    } else {
      _textBillboard = false;
    }
  }

  public void setDraw(boolean value) {
    _drawLine = value;
    _drawTicks = value;
    _drawTickLabels = value;
    _drawName = value;
  }

  public void setDrawLine(boolean value) {
    _drawLine = value;
  }

  public void setDrawTicks(boolean value) {
    _drawTicks = value;
  }

  public void setDrawTickLabels(boolean value) {
    _drawTickLabels = value;
  }

  public void setDrawAxisLabel(boolean value) {
    _drawName = value;
  }

  public void setAxisLabel(String lbl) {
    _label = lbl;
  }

  public void setLabelOffset(float val) {
    _axisLblOffset = val;
  }

  public void setTickLabelXRotation(float val) {
    _axisTickLblRotation.x = val;
  }

  public void setTickLabelYRotation(float val) {
    _axisTickLblRotation.y = val;
  }

  public void setTickLabelZRotation(float val) {
    _axisTickLblRotation.z = val;
  }

  public void setLabelXRotation(float val) {
    _axisLblRotation.x = val;
  }

  public void setLabelYRotation(float val) {
    _axisLblRotation.y = val;
  }

  public void setLabelZRotation(float val) {
    _axisLblRotation.z = val;
  }

  public void setLabelDirection(PVector vlbl) {
    vlbl.normalize();
    _labelDirection = vlbl;
  }

  public void setAxesDirection(PVector uv) {
    uv.normalize();
    _unitVec = uv;
  }

  public void setMajorTicks(int t) {
    _majorTicks = t;
  }

  public void setMinorTicks(int t) {
    _minorTicks = t;
  }

  public void setTickLabelType(ValueType v) {
    _tickLblType = v;
  }

  public void setTickLabelAccuracy(int v) {
    _accuracy = v;
  }

  /**
   * Sets the length of the major ticks, using a negative length extends ticks
   * into the graph rather than to the labels
   *
   * @param val length of the major ticks
   */
  public void setMajorTickLength(int val) {
    _majorTickSize = val;
  }

  /**
   * Sets the length of the minor ticks, using a negative length extends ticks
   * into the graph rather than to the labels
   *
   * @param val length of the major ticks
   */
  public void setMinorTickLength(int val) {
    _minorTickSize = val;
  }

  public void setMaxValue(float val) {
    _maxShow = val;
  }

  public void setMinValue(float val) {
    _minShow = val;
  }

  public void setLength(float l) {
    _length = l;
  }

  // Getters
  /**
   * returns the maximum value of the axis range
   */
  public float getMaxValue() {
    return _maxShow;
  }

  /**
   * returns the minimum value of the axis range
   */
  public float getMinValue() {
    return _minShow;
  }

  /**
   * returns the length of the axis in world space.
   */
  public float getLength() {
    return _length;
  }

  public Axis3D(PApplet parent) {
    super(parent);
    _axisColour = new GWColour(0, 0, 0);
    _fontColour = new GWColour(0, 0, 0);
    _drawLine = true;
    _drawTicks = true;
    _drawTickLabels = true;
    _drawName = true;
    _tickLblType = ValueType.EXPONENT;
    _accuracy = 1;
    _unitVec = new PVector(1, 0, 0);

    if (_font == null) {// Font is a static member so only load if noone has
      // before
      // adf 150310 changed to createFont because loadFont would not work with
      // getFont().getSize() below
      _font = parent.createFont("Verdana", 72);
      //_font = parent.loadFont("Verdana72.vlw");
      // _font = parent.loadFont("CourierNew36.vlw");
    }
  }

  /**
   * This function starts rendering the axis to the properties that have been
   * specified.
   */
  public void draw() {
    _parent.pushStyle();
    _parent.pushMatrix();

    _parent.translate(position.x, position.y, position.z);
    // Align all the text by centre point
    _parent.textAlign(PConstants.CENTER);
    // Draw Axis line
    PVector length = PVector.mult(_unitVec, _length);
    if (_drawLine) {
      _parent.stroke(_axisColour.toInt());
      _parent.fill(_fontColour.toInt());
      _parent.strokeWeight(_axisLineWidth);
      _parent.line(0, 0, 0, length.x, length.y, length.z);
    }
    float longestLabel = 0; // difference in value for tick positions
    PVector pos = null;
    PVector eye = null;
    PVector XZVector = null;
    float angleCamZAxis = 0;
    float angleCamXZPlane = 0;

    if (_drawTicks || _drawTickLabels) {
      // Start to add ticks on axis by initialising a bunch of variables
      // find distance between ticks on axis
      PVector dvTick = PVector.div(length, _majorTicks); // distance
      // between major
      // ticks
      PVector dvTickMinor = PVector.div(dvTick, _minorTicks + 1); // distance
      // between
      // minor
      // ticks
      PVector tickPos = new PVector(0, 0, 0);
      PVector tickEnd = new PVector(0, 0, 0);
      PVector tickPosMinor = new PVector(0, 0, 0);
      PVector tickEndMinor = new PVector(0, 0, 0);
      PVector tickLblPos;
      String tickLbl = null;
      float dValue = (float) ((_maxShow - _minShow) / (_majorTicks)); // difference
      // in
      // label
      // text
      // between
      // major
      // ticks

      _parent.strokeWeight(_axisTickLineWidth);
      _parent.textFont(_font, _axisTickLblSize * 2);

      // calc eye vector only once as it wont change
      if (_textBillboard) {
        eye = Camera3D.getEyeVector().get();
        eye.normalize();
        // calculate billboarding angle only once for all ticks
        pos = Camera3D.getPosition().get();
        pos.sub(Camera3D.getLookat());
        pos.sub(position);
        XZVector = new PVector(pos.x, 0, pos.z);
        XZVector.normalize();
        angleCamZAxis = (float) Math.atan2(pos.x, pos.z);
        angleCamXZPlane = (float) Math.acos(XZVector.dot(eye));
      }

      for (int i = 0; i <= _majorTicks; i++) {

        // Write tick label
        switch (_tickLblType) {
          case DECIMAL:
            tickLbl = String.format("% ." + _accuracy + "f",
                    (float) (_minShow + i * dValue));
            break;
          case EXPONENT:
            tickLbl = String.format("% ." + _accuracy + "E",
                    (float) (_minShow + i * dValue));
            break;
          case INTEGER:
            tickLbl = String.format("% d", Math.round(_minShow + i
                    * dValue));
            break;
        }
        // determine if this is the longest label for main axis label
        // placement later
        if (tickLbl.length() > longestLabel) {
          longestLabel = _parent.textWidth(tickLbl);
        }

        // to define where the major tick label is, we take the current
        // tick position
        // and move in the label direction depending on width of the
        // text and the major
        // tick size
        tickLblPos = PVector.add(tickPos, PVector.mult(_labelDirection,
                1 + _parent.textWidth(tickLbl) / 2
                + Math.abs(_majorTickSize)));
        // as the text is not vertically centred about the render point
        // we offset slightly
        // depending on the size of the font so label is approx centred
        // to tick
        tickLblPos.add(PVector.mult(_unitVec,
                (float) ((float) _axisTickLblSize * 1.2)));

        // also determine point where the tick should end, based on
        // label direction and length
        tickEnd = PVector.add(tickPos, PVector.mult(_labelDirection,
                _majorTickSize));

        // next draw the tick label
        if (_drawTickLabels) {
          _parent.pushMatrix();
          _parent.translate(tickLblPos.x, tickLblPos.y, tickLblPos.z);

          if (_textBillboard) {

            _parent.rotateZ(PI);
            _parent.rotateY(-angleCamZAxis);

            if (Math.signum(pos.y) == 1) {
              _parent.rotateX(PI - angleCamXZPlane);
            } else {
              _parent.rotateX(PI + angleCamXZPlane);
            }

          } else {
            _parent.rotateZ(_axisTickLblRotation.z);
            _parent.rotateX(_axisTickLblRotation.x);
            _parent.rotateY(_axisTickLblRotation.y);
          }

          _parent.text(tickLbl, 0, (0.25f * _font.getSize()), 0);
          _parent.popMatrix();
        }

        if (_drawTicks) {
          // draw the tick line
          _parent.line(tickPos.x, tickPos.y, tickPos.z, tickEnd.x, tickEnd.y, tickEnd.z);

          // Draw minor ticks
          if (i != 0) {// dont draw minor tick if first iteration as
            // the minor ticks get drawn in the -ive
            // axis
            // direction from the major tick in question, was that
            // or miss the last one out if drawn
            // in +ve axis direction.
            tickPosMinor = tickPos.get();

            for (int j = 0; j < _minorTicks; j++) {
              // same as with major ticks, get start and end
              // points
              tickPosMinor = PVector.sub(tickPosMinor,
                      dvTickMinor);
              tickEndMinor = PVector.add(tickPosMinor, PVector.mult(_labelDirection, _minorTickSize));

              _parent.line(tickPosMinor.x, tickPosMinor.y,
                      tickPosMinor.z, tickEndMinor.x, tickEndMinor.y,
                      tickEndMinor.z);
            }
          }
        }

        // position of tick along the axis
        tickPos.add(dvTick);
      }
    }

    _parent.popMatrix();
    if (_drawName) {
      // Add Label
      _parent.textFont(_font, _axisLblSize);
      // label position will be half way along the axis
      PVector lblPos = PVector.add(position, PVector.div(length, 2));
      // next need to offset in the label direction
      lblPos.add(PVector.mult(_labelDirection, longestLabel
              + _axisLblSize + _axisLblOffset));

      // Draw the label
      _parent.pushMatrix();
      // move into a local space about the label centre so we can easily
      // rotate it
      _parent.translate(lblPos.x, lblPos.y, lblPos.z);

      _parent.rotateZ(_axisLblRotation.z);
      _parent.rotateX(_axisLblRotation.x);
      _parent.rotateY(_axisLblRotation.y);

      _parent.text(String.valueOf(_label), 0, 0.25f * _font.getSize(), 0);
      _parent.popMatrix();
    }


    _parent.popStyle();
  }
}
