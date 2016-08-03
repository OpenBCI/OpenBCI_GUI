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

import java.util.ArrayList;
import java.util.Arrays;
import org.gwoptics.graphics.GWColour;

/**
 * <p> RGBColourmap is an object that allows various colourmaps to be generated
 * from RGB nodes. The class accepts user given values for nodes which are used
 * to build a lookup table for fast access of values. The lookup table ranges
 * from 0.0f to 1.0f where the steps in between are changeable via the
 * constructor. To lookup a colour value the user input of the location must
 * normalise their input and select a value between 0.0 and 1.0(Values greater
 * or less than these are capped). So for a range of 0.0 to 100.0 to get the
 * colour of a point whose value is 69, the location input should be 0.69f. </p>
 *
 * <p> This class implements the general IColourmap interface which allows it to
 * work with objects that use colourmaps. </p>
 *
 * @author Daniel Brown 12/6/09
 * @see IColourmap
 * @see ColourmapNode
 * @since 0.1.1
 */
public class RGBColourmap implements IColourmap {

  private GWColour[] _cColourmapLookup;
  private int[] _iColourmapLookup;
  private ArrayList<ColourmapNode> _nodes;
  private float _dLoc; //difference in location between each value on the colourmap, dependent on resolution
  private boolean _needsGenerating;
  private boolean _isCentreAtZero;

  public boolean isCentreAtZero() {
    return _isCentreAtZero;
  }

  public void setCentreAtZero(boolean value) {
    _isCentreAtZero = value;
  }

  /**
   * Standard constructor that sets a default resolution of 100 steps in the
   * lookup table.
   */
  public RGBColourmap() {
    _cColourmapLookup = new GWColour[100];
    _nodes = new ArrayList<ColourmapNode>();
    _dLoc = 1.0f / 63f;
    _iColourmapLookup = new int[64];
    _needsGenerating = true;
  }

  /**
   * Additional constructor that allows a custom resolution of lookup table.
   * Values of 50 and greater are recommended for most uses.
   *
   * @param resolution defines number of steps in colourmap lookup table.
   */
  public RGBColourmap(int resolution) {
    _cColourmapLookup = new GWColour[resolution];
    _nodes = new ArrayList<ColourmapNode>();
    _dLoc = 1.0f / (resolution - 1);
    _iColourmapLookup = new int[resolution];
    _needsGenerating = true;
  }

  public boolean isGenerated() {
    return !_needsGenerating;
  }

  /**
   * This function adds an RGBNode to the colour map, which is then used to
   * generate various gradients of colour.
	 *
   */
  public void addNode(ColourmapNode n) {
    ColourmapNode node = new ColourmapNode();

    if (n.location < 0.0f) {
      node.location = 0.0f;
    } else if (n.location > 1.0f) {
      node.location = 1.0f;
    } else {
      node.location = n.location;
    }

    if (n.colour.A < 0.0f) {
      node.colour.A = 0.0f;
    } else if (n.colour.A > 1.0f) {
      node.colour.A = 1.0f;
    } else {
      node.colour.A = n.colour.A;
    }

    if (n.colour.R < 0.0f) {
      node.colour.R = 0.0f;
    } else if (n.colour.R > 1.0f) {
      node.colour.R = 1.0f;
    } else {
      node.colour.R = n.colour.R;
    }

    if (n.colour.G < 0.0f) {
      node.colour.G = 0.0f;
    } else if (n.colour.G > 1.0f) {
      node.colour.G = 1.0f;
    } else {
      node.colour.G = n.colour.G;
    }

    if (n.colour.B < 0.0f) {
      node.colour.B = 0.0f;
    } else if (n.colour.B > 1.0f) {
      node.colour.B = 1.0f;
    } else {
      node.colour.B = n.colour.B;
    }

    _nodes.add(node);
    //colourmap nodes have changed so needs generating again
    _needsGenerating = true;
  }

  /**
   * Generates the lookup table values using supplied nodes.
   *
   * Once the required nodes have been added to the colourmap using addNode(),
   * this function iterates through them all to generate the colourmap lookup
   * table. This can later be accessed via the getColourAtLocation() and
   * getIntAtLocation() functions. This function populates both a integer lookup
   * table and a Colour lookup table. The integer being for faster access so no
   * need to convert each Colour object.
   *
   * @see GWColour
   * @see getColourAtLocation
   * @see getIntAtLocation
   * @see addNode()
   */
  public void generateColourmap() {
    ColourmapNode[] nodeArray = _nodes.toArray(new ColourmapNode[_nodes.size()]);

    if (nodeArray.length > 1) {
      //The nodes may not have been entered in the correct order
      //so order them w.r.t their location.
      Arrays.sort(nodeArray);
      ColourmapNode n1, n2;

      for (int i = 0; i < nodeArray.length - 1; i++) {
        n1 = nodeArray[i];
        n2 = nodeArray[i + 1];
        int i1, i2;

        //find the range of indexes the 2 nodes relate to on the colourmap
        i1 = Math.round(n1.location / _dLoc);
        i2 = Math.round(n2.location / _dLoc);

        if (i1 != i2) {
          //check if first node is at 0 or not
          if (i == 0) {
            if (n1.location > 0.0f) { //TODO if first node isn't at 0 then need to fill
              //all previous values with first node colour						
            }
          } else if (i == nodeArray.length - 1) {
            if (n1.location < 1.0f) {//TODO if last node isn't at 1.0 then need to fill
              //all following values with last node colour		 					
            }
          }
          float steps = i2 - i1;
          float dAlpha = (n2.colour.A - n1.colour.A) / steps;
          float dRed = (n2.colour.R - n1.colour.R) / steps;
          float dGreen = (n2.colour.G - n1.colour.G) / steps;
          float dBlue = (n2.colour.B - n1.colour.B) / steps;

          for (int j = 0; j < i2 - i1 + 1; j++) {
            _cColourmapLookup[j + i1] = new GWColour(n1.colour.A + j * dAlpha, n1.colour.R + j * dRed, n1.colour.G + j * dGreen, n1.colour.B + j * dBlue);
            _iColourmapLookup[j + i1] = GWColour.convertColourToInt(_cColourmapLookup[j + i1]);
          }
        }
      }
    } else if (nodeArray.length == 1) {
      ColourmapNode node = nodeArray[0];
      for (int i = 0; i < _cColourmapLookup.length; i++) {
        _cColourmapLookup[i] = new GWColour(node.colour.A, node.colour.R, node.colour.G, node.colour.B);
      }
    } else {
      for (int i = 0; i < _cColourmapLookup.length; i++) {
        _cColourmapLookup[i] = new GWColour(0, 0, 0);
      }
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

  public ColourmapNode getNode(int i) {
    if (_nodes.size() <= i) {
      throw new ArrayIndexOutOfBoundsException();
    }
    return _nodes.get(i);
  }

  public void setNode(int i, ColourmapNode node) {
    if (_nodes.size() <= i) {
      throw new ArrayIndexOutOfBoundsException();
    }
    _nodes.set(i, node);
  }

  public void removeNode(int i) {
    if (_nodes.size() <= i) {
      throw new ArrayIndexOutOfBoundsException();
    }
    _nodes.remove(i);
  }

  public int getNodeCount() {
    return _nodes.size();
  }
}
