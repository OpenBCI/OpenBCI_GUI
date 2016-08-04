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
package org.gwoptics.graphics.graph2D;

import org.gwoptics.graphics.graph2D.backgrounds.IGraph2DBackground;

/**
 * This interface is used to pass to an IGraph2DTrace object. It provides some
 * minimal methods for a trace object to alter the graph. Originally created to
 * provide traces access to the background renderer to provide moving grids etc.
 *
 * @author Daniel Brown 7/8/09
 */
public interface IGraph2D {

  /**
   * Gets a reference to the current Background renderer
   */
  IGraph2DBackground getGraphBackground();

  Axis2D getXAxis();

  Axis2D getYAxis();
}
