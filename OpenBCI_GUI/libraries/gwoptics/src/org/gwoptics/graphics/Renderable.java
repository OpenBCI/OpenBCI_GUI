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
package org.gwoptics.graphics;

import processing.core.PApplet;
import processing.core.PVector;

/**
 * An abstract class that can be inherited to provide some common functionality
 * that all rendered objects have. Such as a reference to its parent object its
 * position, and a draw function that renders the object.
 *
 * @author Daniel Brown
 */
public abstract class Renderable implements IRenderable {

  protected PApplet _parent;
  public PVector position;

  public Renderable(PApplet parent) {
    if (parent == null) {
      throw new NullPointerException();
    }
    position = new PVector(0, 0, 0);
    _parent = parent;
  }

  public void setParent(PApplet parent) {
    if (_parent != null) {
      throw new RuntimeException("Parent object has already been set.");
    }
  }

  abstract public void draw();
}
