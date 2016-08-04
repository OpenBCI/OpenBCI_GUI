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
package org.gwoptics.graphics.graph2D.effects;

import org.gwoptics.graphics.colourmap.IColourmap;

/**
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 *
 */
public abstract class AxisColourmapEffect implements ITraceColourEffect {

  protected IColourmap _map;
  protected float yMin, yMax, xMin, xMax;
  protected boolean xContainsZero, yContainsZero;
  protected boolean _xaxisDataSet, _yaxisDataSet;

  public AxisColourmapEffect(IColourmap map) {
    if (map == null) {
      throw new NullPointerException("Colourmap argument is null");
    }

    if (!map.isGenerated()) {
      map.generateColourmap();
    }

    _map = map;
    _xaxisDataSet = false;
    _yaxisDataSet = false;
  }

  public void setXAxisValues(int axisLength, float minValue, float maxValue) {
    xMin = minValue;
    xMax = maxValue;
    _xaxisDataSet = true;

    if (xMin < 0 && xMax > 0) {
      xContainsZero = true;
    } else {
      xContainsZero = false;
    }

  }

  public void setYAxisValues(int axisLength, float minValue, float maxValue) {
    yMin = minValue;
    yMax = maxValue;
    _yaxisDataSet = true;

    if (yMin < 0 && yMax > 0) {
      yContainsZero = true;
    } else {
      yContainsZero = false;
    }
  }
}
