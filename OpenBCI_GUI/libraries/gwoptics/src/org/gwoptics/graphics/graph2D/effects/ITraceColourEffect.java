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

import org.gwoptics.graphics.GWColour;

/**
 * <p> This interface is consumed and implemented by the IGraphTrace object. An
 * ITraceColourEffect is called for each point/segment of a trace and is given
 * the x and y graph values and control positions in pixels. These can be used
 * in anyway to generate a colour to return to the rendering object. </p> <p>
 * The setXAxisValues and setAxisYValues methods are called to allow you to
 * store the range of the axes the trace is on. This allows normalisations of
 * values to change between max and mins of the axes. </p>
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 *
 */
public interface ITraceColourEffect {

  /**
   * The trace this effect relates to should call this function for each segment
   * of the trace. it should provide the x and y position and graph value of the
   * segment so this function can generate a colour to return.
   *
   * @param xPos
   * @param yPos
   * @param xVal
   * @param yVal
   * @return
   */
  GWColour getPixelColour(int xPos, int yPos, float xVal, float yVal);

  /**
   * Accepts values relating to the axes the trace is being plotted on.
   *
   * @param axisLength
   * @param minValue
   * @param maxValue
   */
  void setXAxisValues(int axisLength, float minValue, float maxValue);

  /**
   * Accepts values relating to the axes the trace is being plotted on.
   *
   * @param axisLength
   * @param minValue
   * @param maxValue
   */
  void setYAxisValues(int axisLength, float minValue, float maxValue);
}
