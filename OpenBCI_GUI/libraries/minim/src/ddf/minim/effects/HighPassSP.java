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
 * HighPassSP is a single pole high pass filter. It is not super high quality, but it gets 
 * the job done.
 * 
 * @author Damien Di Fede
 *
 */
public class HighPassSP extends IIRFilter 
{
  /**
   * Constructs a high pass filter with a cutoff frequency of <code>freq</code> that will be 
   * used to filter audio recorded at <code>sampleRate</code>.
   * 
   * @param freq the cutoff frequency
   * @param sampleRate the sample rate of audio that will be filtered
   */
	public HighPassSP(float freq, float sampleRate) 
	{
	  super(freq, sampleRate);
	}

	protected void calcCoeff() 
	{
    float fracFreq = frequency()/sampleRate();
	  float x = (float)Math.exp(-2 * Math.PI * fracFreq);
	  a = new float[] { (1+x)/2, -(1+x)/2 };
	  b = new float[] { x };
	}
}
