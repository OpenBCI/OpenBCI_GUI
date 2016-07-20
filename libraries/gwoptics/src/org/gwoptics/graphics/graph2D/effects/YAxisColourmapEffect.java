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
import org.gwoptics.graphics.colourmap.IColourmap;

/**
 *
 * @author Daniel Brown 13/7/09
 * @since 0.4.0
 *
 */
public class YAxisColourmapEffect extends AxisColourmapEffect {

  public YAxisColourmapEffect(IColourmap map) {
    super(map);
  }

  public GWColour getPixelColour(int pos, int pos2, float xVal, float yVal) {
    if (!_xaxisDataSet || !_yaxisDataSet) {
      throw new RuntimeException("Axis data has not been set. Set using setXAxisValues and setYAxisValues before using.");
    }

    if (_map.isCentreAtZero()) {
      //if map is centred about 0 then we need to make sure we 
      //are colouring the right segments in the right colour			
      if (yContainsZero) {
        float range = Math.max(Math.abs(yMax), Math.abs(yMin));

        return _map.getColourAtLocation(1 - Math.abs(yVal - range) / (range * 2));
      } else {
        //we have a situation where we are either completly +ive or -ive
        //range so we need to decide which part of the map to use
        float range = yMax - yMin;

        if (Math.signum(range) == 1) {//in the 0.5 -> 1.0 range
          //position section
          return _map.getColourAtLocation(0.5f + (float) ((yVal - yMin) * 0.5 / range));
        } else if (Math.signum(range) == -1) { //in the 0.0 -> 0.5 range
          return _map.getColourAtLocation((float) ((yVal - yMin) * 0.5 / range));
        }
      }

    } else {
      return _map.getColourAtLocation(Math.abs((yVal - yMin) / (yMax - yMin)));
    }

    return new GWColour(0, 0, 0);
  }
}
