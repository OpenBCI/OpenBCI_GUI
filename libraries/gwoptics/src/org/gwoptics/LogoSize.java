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
package org.gwoptics;

/**
 * Used in conjunction with the Logo object, this defines the various sizes that
 * the gwOptics logo can come in. SizeXX with the XX part representing the
 * height in pixels of the logo.
 *
 * @author Daniel Brown
 */
public enum LogoSize {

  Size20 {

    @Override
    public int getSize() {
      return 20;
    }
  },
  Size25 {

    @Override
    public int getSize() {
      return 25;
    }
  },
  Size30 {

    @Override
    public int getSize() {
      return 30;
    }
  },
  Size35 {

    @Override
    public int getSize() {
      return 35;
    }
  },
  Size40 {

    @Override
    public int getSize() {
      return 40;
    }
  },
  Size50 {

    @Override
    public int getSize() {
      return 50;
    }
  },
  Size60 {

    @Override
    public int getSize() {
      return 60;
    }
  },
  Size80 {

    @Override
    public int getSize() {
      return 80;
    }
  };

  public int getSize() {
    return 35;
  }
}
