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

import ddf.minim.AudioEffect;
import ddf.minim.UGen;

/**
 * An Infinite Impulse Response, or IIR, filter is a filter that uses a set of
 * coefficients and previous filtered values to filter a stream of audio. It is
 * an efficient way to do digital filtering. IIRFilter is a general IIRFilter
 * that simply applies the filter designated by the filter coefficients so that
 * sub-classes only have to dictate what the values of those coefficients are by
 * defining the <code>calcCoeff()</code> function. When filling the
 * coefficient arrays, be aware that <code>b[0]</code> corresponds to
 * <code>b<sub>1</sub></code>.
 * 
 * @author Damien Di Fede
 * 
 */
public abstract class IIRFilter extends UGen implements AudioEffect
{
	public final UGenInput audio;
	public final UGenInput cutoff;
	
  /** The a coefficients. */
  protected float[] a;
  /** The b coefficients. */
  protected float[] b;

  /** The input values to the left of the output value currently being calculated. */
  private float[][] in;
  /** The previous output values. */
  private float[][] out;
  
  private float prevCutoff;

  /**
   * Constructs an IIRFilter with the given cutoff frequency that will be used
   * to filter audio recorded at <code>sampleRate</code>.
   * 
   * @param freq
   *          the cutoff frequency
   * @param sampleRate
   *          the sample rate of audio to be filtered
   */
  public IIRFilter(float freq, float sampleRate)
  {
  	super();
  	setSampleRate(sampleRate);
  	
  	audio = new UGenInput(InputType.AUDIO);
  	cutoff = new UGenInput(InputType.CONTROL);
  	
  	// set our center frequency
  	cutoff.setLastValue(freq);
  	
  	// force use to calculate coefficients the first time we generate
  	prevCutoff = -1.f;
  }

  /**
   * Initializes the in and out arrays based on the number of coefficients being
   * used.
   * 
   */
  private final void initArrays(int numChannels)
  {
    int memSize = (a.length >= b.length) ? a.length : b.length;
    in = new float[numChannels][memSize];
    out = new float[numChannels][memSize];
  }
  
  public final synchronized void uGenerate(float[] channels)
  {
    // make sure our coefficients are up-to-date
    if ( cutoff.getLastValue() != prevCutoff )
    {
      calcCoeff();
      prevCutoff = cutoff.getLastValue();
    }
    
	  // make sure we have enough filter buffers 
	  if ( in == null || in.length < channels.length || (in[0].length < a.length && in[0].length < b.length) )
	  {
		  initArrays(channels.length);
	  }
	  
	  // apply the filter to the sample value in each channel
	  for(int i = 0; i < channels.length; i++)
	  {
		  System.arraycopy(in[i], 0, in[i], 1, in[i].length - 1);
		  in[i][0] = audio.getLastValues()[i];

		  float y = 0;
		  for(int ci = 0; ci < a.length; ci++)
		  {
			  y += a[ci] * in[i][ci];
		  }
		  for(int ci = 0; ci < b.length; ci++)
		  {
			  y += b[ci] * out[i][ci];
		  }
		  System.arraycopy(out[i], 0, out[i], 1, out[i].length - 1);
		  out[i][0] = y;
		  channels[i] = y;
	  }
  }

  public final synchronized void process(float[] signal)
  {
    setChannelCount( 1 );
    float[] tmp = new float[1];
    for (int i = 0; i < signal.length; i++)
    {
    	audio.setLastValue( signal[i] );
    	uGenerate(tmp);
    	signal[i] = tmp[0];
    }
  }

  public final synchronized void process(float[] sigLeft, float[] sigRight)
  {
    setChannelCount( 2 );
    float[] tmp = new float[2];
    for (int i = 0; i < sigLeft.length; i++)
    {
  		audio.getLastValues()[0] = sigLeft[i];
  		audio.getLastValues()[1] = sigRight[i];
  		uGenerate(tmp);
  		sigLeft[i] = tmp[0];
  		sigRight[i] = tmp[1];
    }
  }

  /**
   * Sets the cutoff/center frequency of the filter. 
   * Doing this causes the coefficients to be recalculated.
   * 
   * @param f
   *          the new cutoff/center frequency (in Hz).
   */
  public final synchronized void setFreq(float f)
  {
  	// no need to recalc if the cutoff isn't actually changing
    if ( validFreq(f) && f != cutoff.getLastValue() )
    {
      prevCutoff = f;
      cutoff.setLastValue(f);
      calcCoeff();
    }
  }
  
  /**
   * Returns true if the frequency is valid for this filter. Subclasses can 
   * override this method if they want to limit center frequencies to certain 
   * ranges to avoid becoming unstable. The default implementation simply 
   * makes sure that <code>f</code> is positive.
   * 
   * @param f the frequency (in Hz) to validate
   * @return true if <code>f</code> is a valid frequency for this filter
   */
  public boolean validFreq(float f)
  {
    return f > 0;
  }

  /**
   * Returns the cutoff frequency (in Hz).
   * 
   * @return the current cutoff frequency (in Hz).
   */
  public final float frequency()
  {
    return cutoff.getLastValue();
  }

  /**
   * Calculates the coefficients of the filter using the current cutoff
   * frequency. To make your own IIRFilters, you must extend IIRFilter and
   * implement this function. The frequency is expressed as a fraction of the
   * sample rate. When filling the coefficient arrays, be aware that
   * <code>b[0]</code> corresponds to the coefficient <code>b<sub>1</sub></code>.
   * 
   */
  protected abstract void calcCoeff();

  /**
   * Prints the current values of the coefficients to the console.
   * 
   */
  public final void printCoeff()
  {
    System.out.println("Filter coefficients: ");
    if ( a != null )
    {
    	for (int i = 0; i < a.length; i++)
    	{
    		System.out.print("  A" + i + ": " + a[i]);
    	}
    }
    System.out.println();
    if ( b != null )
    {
    	for (int i = 0; i < b.length; i++)
    	{
    		System.out.print("  B" + (i + 1) + ": " + b[i]);
    	}
    	System.out.println();
    }
  }
}
