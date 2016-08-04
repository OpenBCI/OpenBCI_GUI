package ddf.minim.ugens;

import ddf.minim.UGen;


/**
 * Abs is a UGen that outputs the absolute value of its input.
 * 
 * @author Damien Di Fede
 * @related UGen
 *
 */
public class Abs extends UGen 
{
	/**
	 * The input that we will take the absolute value of.
	 * 
	 * @related Abs
	 */
	public UGenInput audio;
	
	public Abs()
	{
		audio = new UGenInput(InputType.AUDIO);
	}

	@Override
	protected void uGenerate(float[] channels) 
	{
		for(int i = 0; i < channels.length; ++i)
		{
			channels[i] = Math.abs( audio.getLastValues()[i] );
		}
	}

}
