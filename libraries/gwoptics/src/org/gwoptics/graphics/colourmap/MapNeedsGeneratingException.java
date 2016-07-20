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
package org.gwoptics.graphics.colourmap;

/**
 * This exception is thrown by a colourmap when the user attempts to read a
 * value from the map without generating it beforehand.
 *
 * @author Daniel 17/6/09
 * @since 0.2.2
 */
@SuppressWarnings("serial")
public class MapNeedsGeneratingException extends RuntimeException {

  public MapNeedsGeneratingException() {
    super("Colourmap needs to be generated before values are read from it.");
  }
}
