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

package ddf.minim.signals;

import ddf.minim.AudioSignal;

/**
 * White noise is a signal that contains all frequencies in equal amounts.
 * 
 * @author Damien Di Fede
 * @see <a href="http://en.wikipedia.org/wiki/White_noise">White Noise</a>
 */
public class WhiteNoise implements AudioSignal
{
  protected float amp;
  protected float pan;
  protected float leftScale, rightScale;

  /**
   * Constructs a white noise generator with an amplitude of 1.
   *
   */
  public WhiteNoise()
  {
    amp = 1;
    pan = 0;
    leftScale = rightScale = 1;
  }

  /**
   * Constructs a white noise generator with the given amplitude. <code>amp</code> 
   * should be between 0 and 1.
   * 
   * @param amp the amplitude
   */
  public WhiteNoise(float amp)
  {
    setAmp(amp);
    pan = 0;
    leftScale = rightScale = 1;
  }

  /**
   * Sets the amplitude to <code>a</code>. This value will be constrained to [0, 1].
   * @param a the new amplitude
   */
  public void setAmp(float a)
  {
    amp = constrain(a, 0, 1);
  }

  /**
   * Sets the pan to <cod>p</code>. This value will be constrained to [-1, 1].
   * 
   * @param p the new pan
   */
  public void setPan(float p)
  {
    pan = constrain(p, -1, 1);
    calcLRScale();
  }

  public void generate(float[] signal)
  {
    for (int i = 0; i < signal.length; i++)
    {
      signal[i] = amp * (2 * (float) Math.random() - 1);
    }
  }

  public void generate(float[] left, float[] right)
  {
    for (int i = 0; i < left.length; i++)
    {
      left[i] = leftScale * amp * (2 * (float) Math.random() - 1);
      right[i] = rightScale * amp * (2 * (float) Math.random() - 1);
    }
  }

  private void calcLRScale()
  {
    if (pan <= 0)
    {
      // map -1, 0 to 0, 1
      rightScale = pan + 1;
      leftScale = 1;
    }
    if (pan >= 0)
    {
      // map 0, 1 to 1, 0;
      leftScale = 1 - pan;
      rightScale = 1;
    }
    if (pan == 0)
    {
      leftScale = rightScale = 1;
    }
  }
  
  float constrain( float val, float min, float max )
  {
	  return val < min ? min : ( val > max ? max : val );
  }
}
