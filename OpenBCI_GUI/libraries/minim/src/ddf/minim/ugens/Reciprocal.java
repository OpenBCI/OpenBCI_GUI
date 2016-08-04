package ddf.minim.ugens;

import ddf.minim.UGen;

/**
 * A UGen which simply returns the reciprocal value of it's input. 
 * Because this UGen is intended for use with control signals, 
 * rather than audio signals, it behaves as a mono UGen, regardless 
 * of whether or not it has been configured with more than one channel.
 * This means that the output of Reciprocal will always be the reciprocal
 * of the first (and usually only) channel of the denominator input copied 
 * to all output channels, similar to Constant.
 * 
 * @related UGen
 * 
 * @author nodog
 * 
 */

public class Reciprocal extends UGen
{
	/**
	 * denominator is the default audio input
	 */
	public UGenInput	denominator;

	/**
	 * Constructs a Reciprocal with a denominator of 1.
	 */
	public Reciprocal()
	{
		this( 1.0f );
	}

	/**
	 * Constructs a Reciprocal with the given denominator value.
	 * 
	 * @param fixedDenominator
	 *            the denominator value if the input is never connected
	 */
	public Reciprocal(float fixedDenominator)
	{
		super();
		// audio = new UGenInput(InputType.AUDIO);
		// for this UGen, denominator is the main input and can be audio
		denominator = new UGenInput( InputType.AUDIO );
		denominator.setLastValue( fixedDenominator );
	}

	/**
	 * Used to change the fixedDenominator value after instantiation
	 * 
	 * @param fixedDenominator
	 *            the denominator value if the input is never connected
	 */
	public void setReciprocal(float fixedDenominator)
	{
		denominator.setLastValue( fixedDenominator );
	}

	@Override
	protected void uGenerate(float[] channels)
	{
		for ( int i = 0; i < channels.length; i++ )
		{
			channels[i] = 1.0f / denominator.getLastValue();
		}
	}
}