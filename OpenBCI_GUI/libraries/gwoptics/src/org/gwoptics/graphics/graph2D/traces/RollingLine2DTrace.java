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

import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.locks.ReentrantLock;

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.IGraph2D;

import processing.core.PApplet;

/**
 * <p> The rolling 2D trace object was created to act in a similar way to a
 * Seismometer works, where the previous values on the graph move to the left
 * and new values are added to the right. </p> <p> In similar fashion to other {@link Line2DTrace}
 * objects a callback function needs to be specified, {@link ILine2DEquation},
 * that returns the value of a function or the value of some monitored variable.
 * </p> <p>Only Rolling2DTrace's can be added to a graph control, you cannot mix
 * this with other {@link Line2DTrace} objects due to the way this object
 * updates the x-axis of the graph control it is added to.</p>
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 */
public class RollingLine2DTrace extends Line2DTrace {

  protected ReentrantLock _lock;
  protected boolean _doDraw;
  protected Timer _timer;
  protected long _refreshRate;
  protected float _xIncr;
  protected boolean _isMaster;
  protected RollingLine2DTrace[] _slaveTraces;
  protected double[] _eqDataX;
  protected boolean paused = false;

  /**
   * This exception is thrown when the graph is trying to update too fast. You
   * must pick values for msRefreshRate and xIncr in the {@link RollingLine2DTrace}
   * constructor so that the graph can update and render correctly. Using large
   * x-axis increments per update and short refresh times will cause the issue.
   * Experimenting with different values will be required.
   *
   * @author Daniel Brown 23/11/10
   */
  public class RollingTraceTooFastException extends RuntimeException {

    public RollingTraceTooFastException() {
      super("The RollingGraphTrace is moving too fast to"
              + " process and render correctly. You need to reduce the x-axis increment"
              + " per update or use a larger refresh rate in the RollingLine2DTrace constructor");
    }
  }

  protected class RollingTick extends TimerTask {

    @Override
    public void run() {
      if (_isMaster) {
        try {
          _lock.lock();

          _doDraw = true;

          //increment the x-axis bounds if we are the master trace.
          if (isMaster()) {
            _ax.setMaxValue(_ax.getMaxValue() + _xIncr);
            _ax.setMinValue(_ax.getMinValue() + _xIncr);
          }


          if (!paused) {
            _timer.schedule(new RollingTick(), _refreshRate);
          }
        } finally {
          _lock.unlock();
        }
      }
    }
  }

  /**
   * Calling this stops the internal updating thread running.
   */
  public void pause() {
    paused = true;
    _timer.cancel();
  }

  /**
   * Calling this resumes the internal updating thread.
   */
  public void unpause() {
    if (paused) {
      paused = false;
      _timer = new Timer();
      _timer.schedule(new RollingTick(), _refreshRate);
    }
  }

  public long getRefreshRate() {
    return _refreshRate;
  }

  protected boolean isMaster() {
    return _isMaster;
  }

  /**
   * <p>Creates a new {@link RollingLine2DTrace} to be added to a {@link Graph2D}
   * instance. A rolling graph is able to update itself automatically after a
   * user defined period in milliseconds indefinitely. All {@link RollingLine2DTrace}
   * traces that are added to a {@link Graph2D} instance should have the same
   * update rate or an exception will be thrown.</p>
   *
   * <p> Care needs to be taken when choosing values for the refresh and x axis
   * increment. Choosing very quick refresh rates using large x-axis increments
   * will cause the {@link RollingTraceTooFastException} to be thrown. </p>
   *
   * @param eq Equation that is to be used to generate the trace.
   * @param msRefreshRate Rate at which trace is updated in milliseconds
   * @param xIncr The amount the X-Axis value should increase every update
   */
  public RollingLine2DTrace(ILine2DEquation eq, long msRefreshRate, float xIncr) {
    super(eq);
    _refreshRate = msRefreshRate;
    _xIncr = xIncr;
    _timer = new Timer();
    _isMaster = true; //true unless otherwise found it isnt in preCheck
    _lock = new ReentrantLock();
    _slaveTraces = new RollingLine2DTrace[0];

  }

  @Override
  public void setParent(PApplet parent) {
    super.setParent(parent);
    parent.registerMethod("pre",this);
  }

  @Override
  public void setGraph(IGraph2D grph) {
    super.setGraph(grph);
    _eqDataX = new double[_ax.getLength()];

    for (int i = 0; i < _eqDataX.length; i++) {
      _eqDataX[i] = _ax.positionToValue(i);
      _eqDataY[i] = Float.NaN;

      if (i > 0) {
        if (_eqDataX[i] <= _eqDataX[i - 1]) {
          PApplet.println("length of the X-Axis and the range of values used is"
                  + " conflicting so that 2 pixels on the X-Axis have the"
                  + " same value. Please change the axis range or length of graph");
        }
      }
    }
  }

  /**
   * Here we override the onAddTrace method to see if any Rolling2DTraces have
   * been previously added. Then check to see if our refresh rate is the same as
   * the others
   */
  @Override
  public void onAddTrace(Object traces[]) {
    if (traces != null) {
      if (traces.length > 0) {
        for (Object t : traces) {
          if (t instanceof RollingLine2DTrace) {
            _isMaster = false;
            RollingLine2DTrace rt = (RollingLine2DTrace) t;

            if (rt.isMaster()) {
              rt._addTraceToMaster(this);
            }

            //check to see if our refresh rates match
            if (rt.getRefreshRate() != _refreshRate) {
              throw new Trace2DException("The refresh rate of this trace must be the same "
                      + "as the refresh rate of the Rolling2DTraces already "
                      + "present in the Graph2D object.");
            }

          } else {
            throw new Trace2DException("There are other types of traces that are not Rolling2DTraces, remove before using a Rolling2DTrace.");
          }
        }
      }
    }

    if (_isMaster) {
      _slaveTraces = new RollingLine2DTrace[0];
      _timer.schedule(new RollingTick(), _refreshRate);
    } else {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
    }
  }

  @Override
  public void onRemoveTrace() {
    if (_isMaster) {
      if (_slaveTraces != null) {
        if (_slaveTraces.length > 0) {
          _changeMasterTrace(this, _slaveTraces[0]);
        }
      }
    }
  }

  private static void _changeMasterTrace(RollingLine2DTrace prev, RollingLine2DTrace next) {
    if (prev.isMaster() && !next.isMaster()) {
      try {
        prev._lock.lock();
        next._lock.lock();

        prev._removeTraceFromMaster(next);

        prev._isMaster = false;
        next._isMaster = true;

        next._slaveTraces = prev._slaveTraces;
        next._timer = new Timer();
        next._timer.schedule(next.new RollingTick(), next._refreshRate);
      } finally {
        prev._lock.unlock();
        next._lock.unlock();
      }
    }
  }

  protected void _addTraceToMaster(RollingLine2DTrace rolling2DTrace) {
    if (_isMaster && rolling2DTrace != null) {
      synchronized (_slaveTraces) {
        RollingLine2DTrace tmp[] = new RollingLine2DTrace[_slaveTraces.length + 1];
        System.arraycopy(_slaveTraces, 0, tmp, 0, _slaveTraces.length);
        tmp[tmp.length - 1] = rolling2DTrace;

        _slaveTraces = new RollingLine2DTrace[tmp.length];
        System.arraycopy(tmp, 0, _slaveTraces, 0, tmp.length);
      }
    }
  }

  protected void _removeTraceFromMaster(RollingLine2DTrace t) {
    if (_isMaster && t != null) {
      synchronized (_slaveTraces) {
        RollingLine2DTrace[] tmp = new RollingLine2DTrace[_slaveTraces.length];
        int ix = 0;

        for (RollingLine2DTrace rt : _slaveTraces) {
          if (!t.equals(rt)) {
            tmp[ix] = rt;
            ix++;
          }
        }

        if (tmp[_slaveTraces.length - 1] == null) {
          _slaveTraces = new RollingLine2DTrace[tmp.length - 1];

          for (int i = 0; i < tmp.length - 1; i++) {
            _slaveTraces[i] = tmp[i];
          }
        }
      }
    }
  }

  @Override
  public void generate() {
    if (_ax == null || _ay == null) {
      throw new RuntimeException("One of the axis objects are null, set them using setAxes().");
    }

    int endPX = _eqDataY.length - 1;
    int endNewPos = _ax.valueToPosition(_eqDataX[endPX]);
    int startPos = endPX - endNewPos;

    if (startPos >= _eqDataX.length) {
      throw new RollingTraceTooFastException();
    }

    int lastPosChange = startPos - _ax.valueToPosition(_eqDataX[startPos]);

    for (int k = startPos; k <= endPX; k++) {
      //using the x value of this point determine its new pixel location
      //on the off set x axis 
      int kpos = _ax.valueToPosition(_eqDataX[k]);

      if (k - kpos != lastPosChange) {
        kpos = k - lastPosChange;
        _eqDataX[k] = _ax.positionToValue(kpos);
      }

      if (kpos >= 0 & kpos != k) {
        _eqDataX[kpos] = _eqDataX[k];
        _eqDataY[kpos] = _eqDataY[k];
        _eqDataY[k] = Float.NaN;
      }
    }

    if (endNewPos < endPX) {
      for (int l = endNewPos + 1; l <= endPX; l++) {
        float x = _ax.positionToValue(l);
        _eqDataX[l] = x;
        _eqDataY[l] = Float.NaN;
      }
    }

    _eqDataX[endPX] = _ax.getMaxValue();
    _eqDataY[endPX] = _cb.computePoint(_eqDataX[endPX], endPX);

    for (int i = 0; i < _pointData.length; i++) {
      if (Double.isNaN(_eqDataY[i])) {
        _pointData[i] = Float.NaN;
      } else {
        _pointData[i] = _ay.valueToPosition((float) _eqDataY[i]);
      }
    }
  }

  public void pre() {
    try {
      _lock.lock();

      if (_isMaster && _doDraw) {
        generate();

        for (RollingLine2DTrace t : this._slaveTraces) {
          if (t != null) {
            t.generate();
          }
        }

        _doDraw = false;
      }
    } finally {
      _lock.unlock();
    }
  }
}
