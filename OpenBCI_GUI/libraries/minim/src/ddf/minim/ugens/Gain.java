package ddf.minim.ugens;

import ddf.minim.UGen;

/**
 * Gain is another way of expressing an increase or decrease in the volume of something.
 * It is represented in decibels (dB), which is a logorithmic scale. A gain of 0 dB means 
 * that you are not changing the volume of the incoming signal at all, positive gain boosts 
 * the signal and negative gain decreases it. You can effectively silence 
 * the incoming signal by setting the gain to something like -60.
 * 
 * @example Synthesis/gainExample
 * 
 * @author Damien Di Fede
 *
 */

public class Gain extends UGen
{
	/**
	 * The audio input is where incoming signals should be patched, however you do not need 
	 * to patch directly to this input because patching to the Gain itself will accomplish
	 * the same thing.
	 * 
	 * @related Gain
	 */
	public UGenInput audio;
	
	/**
	 * The gain input controls the value of this Gain. It will be interpreted as being in dB. 
	 * 0 dB means that the incoming signal will not be changed, positive dB increases the 
	 * amplitude of the signal, and negative dB decreases it. You can effectively silence 
	 * the incoming signal by setting the gain to something like -60.
	 * 
	 * @related Gain
	 */
	public UGenInput gain;
	
	private float mValue;
	
	/**
	 * Construct a Gain UGen with a value of 0 dB, which means 
	 * it will not change the volume of something patched to it.
	 */
	public Gain() 
	{
		this(0.f);
	}

	/**
	 * Construct a Gain with the specific dBvalue. 0 dB is no change 
	 * to incoming audio, positive values make it louder and negative values 
	 * make it softer.
	 * 
	 * @param dBvalue 
	 * 			float: the amount of gain to apply to the incoming signal
	 */
	public Gain( float dBvalue ) 
	{
		// linear = pow ( 10.0, (0.05 * dBvalue) );
		 mValue = (float)Math.pow(10.0, (0.05 * dBvalue));
		 
		 audio = new UGenInput(InputType.AUDIO);
		 gain = new UGenInput(InputType.CONTROL);
	}
	
	/**
	 * Set the value of this Gain to a given dB value.
	 * 
	 * @param dBvalue
	 * 			float: the new value for this Gain, in decibels.
	 * 
	 * @example Synthesis/gainExample
	 * 
	 * @related Gain
	 */
	public void setValue( float dBvalue )
	{
		mValue = (float)Math.pow(10.0, (0.05 * dBvalue));
	}

	@Override
	protected void uGenerate(float[] channels) 
	{
		// TODO: not fond of the fact that we cast up to doubles for this math function.
		if ( gain.isPatched() )
		{
			mValue = (float)Math.pow(10.0, (0.05 * gain.getLastValue()));
		}	
		
		for(int i = 0; i < channels.length; ++i)
		{
			channels[i] = mValue * audio.getLastValues()[i];
		}
	}
}
