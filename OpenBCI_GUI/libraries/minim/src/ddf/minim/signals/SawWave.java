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
 * A saw wave is characterized by rising edge followed by a sharp drop off.
 * 
 * @author Damien Di Fede
 * @see <a href="http://en.wikipedia.org/wiki/Saw_wave">Saw Wave</a>
 *
 */
public class SawWave extends Oscillator 
{  
  
  /**
   * Constructs a saw wave with the given frequency, amplitude and sample
   * rate.
   * 
   * @param frequency
   *          the frequency of the pulse wave
   * @param amplitude
   *          the amplitude of the pulse wave
   * @param sampleRate
   *          the sample rate of the pulse wave
   */
	public SawWave(float frequency, float amplitude, float sampleRate) 
	{
	  super(frequency, amplitude, sampleRate);
	}
	
	protected float value(float step) 
	{
	  return 2 * ( step - (float)Math.round(step));
	}
}
