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
package ddf.minim.effects;

/**
 * A notch filter removes a narrow band of frequencies from an audio signal. It
 * is the opposite of a band pass filter, which allows only a narrow band of
 * frequencies to pass through the filter.
 * 
 * @author Damien Di Fede
 * 
 */
public class NotchFilter extends IIRFilter
{
  private float bw;

  /**
   * Constructs a notch filter with the requested center frequency, bandwidth and 
   * sample rate.
   * 
   * @param freq the center frequency of the band to remove (in Hz)
   * @param bandWidth the width of the band to remove (in Hz)
   * @param sampleRate the sample rate of audio that will be filtered by this filter
   */
  public NotchFilter(float freq, float bandWidth, float sampleRate)
  {
    super(freq, sampleRate);
    setBandWidth(bandWidth);
  }

  /**
   * Sets the band width of the filter.
   * 
   * @param b the band width (in Hz)
   */
  public void setBandWidth(float b)
  {
    bw = b / sampleRate();
  }

  /**
   * Returns the band width of this filter.
   * 
   * @return the band width (in Hz)
   */
  public float getBandWidth()
  {
    return bw * sampleRate();
  }

  protected void calcCoeff()
  {
    float fracFreq = frequency()/sampleRate();
    float R = 1 - 3 * bw;
    float T = 2 * (float) Math.cos(2 * Math.PI * fracFreq);
    float K = (1 - R * T + R * R) / (2 - T);
    a = new float[] { K, -K * T, K };
    b = new float[] { R * T, -R * R };
  }

}
