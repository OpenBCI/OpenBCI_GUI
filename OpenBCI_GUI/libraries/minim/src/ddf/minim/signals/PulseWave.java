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


/**
 * A pulse wave is a square wave whose peaks and valleys are different length.
 * The pulse width of a pulse wave is how wide the peaks.
 * 
 * @author Damien Di Fede
 * @see <a href="http://en.wikipedia.org/wiki/Pulse_wave">Pulse Wave</a>
 */
public class PulseWave extends Oscillator
{
  private float width;

  /**
   * Constructs a pulse wave with the given frequency, amplitude and sample
   * rate.
   * 
   * @param frequency
   *          the frequency of the pulse wave
   * @param amplitude
   *          the amplitude of the pulse wave
   * @param sampleRate
   *          the sample rate of the pulse wave
   */
  public PulseWave(float frequency, float amplitude, float sampleRate)
  {
    super(frequency, amplitude, sampleRate);
    // duty period is 1:width
    width = 2;
  }

  /**
   * Sets the pulse width of the pulse wave.
   * 
   * @param w
   *          the new pulse width, this will be constrained to [1, 30]
   */
  public void setPulseWidth(float w)
  {
    width = w < 1 ? 1 : ( w > 30 ? 30 : w );
  }

  /**
   * Returns the current pulse width.
   * 
   * @return the current pulse width
   */
  public float getPulseWidth()
  {
    return width;
  }

  protected float value(float step)
  {
    float v = 0;
    if (step < 1 / (width + 1))
      v = 1;
    else
      v = -1;
    return v;
  }

}
