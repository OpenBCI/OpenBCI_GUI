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

import org.gwoptics.graphics.GWColour;

/**
 * EquationColourmap implements the IColourmap interface to generate a colourmap
 * from an equation, rather than nodes as in the alternative RGBColourmap. The
 * equation that generates the map returns a Colour object as specified in
 * IColourmapEquation.
 *
 * <p>Before any values are read from the map, the map must have been generated
 * using generateColourmap() or a {@link MapNeedsGeneratingException} will be
 * thrown.</p>
 *
 * @author Daniel Brown 18/6/09
 * @since 0.2.4
 * @see GWColour
 * @see IColourmapEquation
 * @see IColourmap
 * @see RGBColourmap
 * @see MapNeedsGeneratingException
 */
public class EquationColourmap implements IColourmap {

  private GWColour[] _cColourmapLookup;
  private int[] _iColourmapLookup;
  private boolean _needsGenerating;
  private IColourmapEquation _eq;
  private float _dLoc;
  private boolean _isCentreAtZero;

  public boolean isCentreAtZero() {
    return _isCentreAtZero;
  }

  public void setCentreAtZero(boolean value) {
    _isCentreAtZero = value;
  }

  /**
   * Requires an equation object to be passed to it, which is not nullable
   *
   * @param eq Equation that generates the colourmap, is not nullable.
   */
  public EquationColourmap(IColourmapEquation eq) {
    if (eq == null) {
      throw new NullPointerException("Object requires a non null IColourmapEquation.");
    }

    _cColourmapLookup = new GWColour[64];
    _iColourmapLookup = new int[64];
    _dLoc = 1.0f / (63);
  }

  /**
   * Additional constructor that allows a custom resolution of lookup table.
   * Values of 50 and greater are recommended for most uses.
   *
   * @param resolution defines number of steps in colourmap lookup table.
   * @param eq Equation that generates the colourmap, is not nullable.
   */
  public EquationColourmap(int resolution, IColourmapEquation eq) {
    if (eq == null) {
      throw new NullPointerException("Object requires a non null IColourmapEquation.");
    }
    if (resolution < 1) {
      resolution = 1;
    }

    _eq = eq;
    _cColourmapLookup = new GWColour[resolution];
    _iColourmapLookup = new int[resolution];
    _dLoc = 1.0f / (resolution - 1);
  }

  public boolean isGenerated() {
    return !_needsGenerating;
  }

  /**
   * Use the supplied equation to generate colour values for each index in the
   * colourmap. Must be called before map is used.
   */
  public void generateColourmap() {
    for (int i = 0; i < _cColourmapLookup.length; i++) {
      GWColour val = _eq.colourmapEquation(_dLoc * i);
      _cColourmapLookup[i] = val;
      _iColourmapLookup[i] = val.toInt();
    }
    _needsGenerating = false;
  }

  /**
   * Returns a Colour object that relates to a normalised location on the
   * colourmap
   *
   * @param l Normalised location input (between 0.0f and 1.0f)
   * @return Colour at location.
   */
  public GWColour getColourAtLocation(float l) {
    if (_needsGenerating) {
      throw new MapNeedsGeneratingException();
    }

    float loc;

    if (l < 0.0f) {
      loc = 0.0f;
    } else if (l > 1.0f) {
      loc = 1.0f;
    } else {
      loc = l;
    }

    return _cColourmapLookup[Math.round(loc / _dLoc)];
  }

  /**
   * Returns an integer that relates to a normalised location on the colourmap.
   * Integer is in a 4 byte format of ARGB.
   *
   * @param l Normalised location input (between 0.0f and 1.0f)
   * @return Integer value of colour at location.
   */
  public int getIntAtLocation(float l) {
    if (_needsGenerating) {
      throw new MapNeedsGeneratingException();
    }

    float loc;

    if (l < 0.0f) {
      loc = 0.0f;
    } else if (l > 1.0f) {
      loc = 1.0f;
    } else {
      loc = l;
    }

    return _iColourmapLookup[Math.round(loc / _dLoc)];
  }
}
