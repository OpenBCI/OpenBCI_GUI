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
package org.gwoptics.graphics.colourmap.presets;

import org.gwoptics.graphics.colourmap.ColourmapNode;
import org.gwoptics.graphics.colourmap.RGBColourmap;

/**
 * CoolColourmap extends RGBColourmap and is a gradient of cyan at 0.0 to
 * magneta at 1.0. This map must be generated using generateColourmap() before
 * use.
 *
 * @author Daniel Brown 17/6/09
 * @since 0.2.2
 * @see generateColourmap()
 */
public final class CoolColourmap extends RGBColourmap {

  /**
   * If you require the colourmap to be generated now rather than later by
   * calling generateColourmap() manually set generateMapNow to true. This is
   * useful in the instance that you simply pass a map to a new trace.
   * <pre>
   * {@code} SurfaceGraph3D.addSurfaceTrace(new IGraph3DCallback(){ public float
   * computePoint(float X, float Z) { return -(X*X + Z*Z); }}, 100, 100, new
   * CoolColourmap(true));
   * </pre>
   *
   * @param generateMapNow Boolean value stating whether to generate map now or
   * not.
   */
  public CoolColourmap(boolean generateMapNow) {
    super();
    _addNodes();
    if (generateMapNow) {
      this.generateColourmap();
    }
  }

  private void _addNodes() {
    this.addNode(new ColourmapNode(0.0f, 1.0f, 1.0f, 0.0f));
    this.addNode(new ColourmapNode(1.0f, 0.0f, 1.0f, 1.0f));
  }
}
