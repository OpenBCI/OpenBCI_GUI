/*
 *  Copyright (c) 2007 - 2008 by Damien Di Fede <ddf@compartmental.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

package ddf.minim.spi;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.Control;

public interface AudioResource
{
  /**
   * Opens the resource to be used.
   * 
   */
  void open();

  /**
   * Closes the resource, releasing any memory.
   * 
   */
  void close();

  /**
   * Returns the Controls available for this AudioResource.
   * 
   * @return an array of Control objects, that can be used to manipulate the
   *         resource
   */
  Control[] getControls();
  
  /**
   * Returns the AudioFormat of this AudioResource.
   * 
   * @return the AudioFormat of this AudioResource
   */
  AudioFormat getFormat();
}
