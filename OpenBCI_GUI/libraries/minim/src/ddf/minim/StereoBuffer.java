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

package ddf.minim;

class StereoBuffer implements AudioListener
{
  public MAudioBuffer left;
  public MAudioBuffer right;
  public MAudioBuffer mix;
  
  private Controller parent;
  
  StereoBuffer(int type, int bufferSize, Controller c)
  {
    left = new MAudioBuffer(bufferSize);
    if ( type == Minim.MONO )
    {
      right = left;
      mix = left;
    }
    else
    {
      right = new MAudioBuffer(bufferSize);
      mix = new MAudioBuffer(bufferSize);
    }
    parent = c;
  }
  
  public void samples(float[] samp)
  {
    // Minim.debug("Got samples!");
    left.set(samp);
    parent.update();
  }

  public void samples(float[] sampL, float[] sampR)
  {
    left.set(sampL);
    right.set(sampR);
    mix.mix(sampL, sampR);
    parent.update();
  }
}
