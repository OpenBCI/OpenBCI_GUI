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

/**
 * <p> This interface should be implemented by objects that are to be
 * represented by a trace on a Graph2D object. The computePoint method is called
 * for each point along the X-Axis and the object implementing the interface is
 * expected to return a double value to plot as the Y-value. </p>
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 *
 */
public interface ILine2DEquation {

  /**
   * This method is called for each pixel along the width of a Graph2D object.
   * The x parameter gives the value of the point to be plotted along the
   * horizontal axis. The position parameter states the number of pixels along
   * the axis this value relates to, going from left to right.
   *
   * @param X value
   * @param position pixel
   * @return Y value to be plotted
   */
  double computePoint(double x, int position);
}
