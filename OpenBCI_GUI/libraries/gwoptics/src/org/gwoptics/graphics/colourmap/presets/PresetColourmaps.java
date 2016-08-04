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

import org.gwoptics.ArgumentException;
import org.gwoptics.graphics.colourmap.IColourmap;

/**
 * This class defines only one static member to retrieve various presets.
 *
 * @author Daniel Brown 18/6/09
 * @since 0.2.4
 */
public final class PresetColourmaps {

  /**
   * This function excepts a type of IColourmap to return, this is done via the
   * Presets enumerator. See Presets for list of possible inputs.
   *
   * @param type
   * @see Presets
   */
  public static IColourmap getColourmap(Presets type) {
    switch (type) {
      case COOL:
        return new CoolColourmap(true);
      case FLIP:
        return new FlipColourmap(true);
      case GRAY:
        return new GrayScaleColourmap(true);
      case HOT:
        return new HotColourmap(true);
      case WARM:
        return new WarmColourmap(true);

      default:
        throw new ArgumentException("type of preset can not be resolved.");
    }
  }
}
