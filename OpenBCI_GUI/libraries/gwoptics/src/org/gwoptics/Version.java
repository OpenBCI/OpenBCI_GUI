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

import java.io.IOException;
import java.io.InputStream;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

/**
 * Small class that reads the manifest file and gets the Implementation-Version
 * of the Jar file and returns as a string.
 *
 * @author Daniel Brown 17/6/09
 * @since 0.2.3
 *
 */
public final class Version {

  public String getVersion() {
    try {
      InputStream stream = this.getClass().getResourceAsStream("/META-INF/MANIFEST.MF");

      if (stream == null) {
        System.out.println("Couldn't find manifest.");
      }

      Manifest manifest = new Manifest(stream);
      Attributes attributes = manifest.getMainAttributes();
      return attributes.getValue("Implementation-Version");
    } catch (IOException e) {
      System.out.println("Couldn't read manifest.");
    }
    return null;
  }
}
