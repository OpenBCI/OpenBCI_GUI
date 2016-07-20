package ddf.minim.ugens;

import ddf.minim.UGen;

/**
 * A UGen for panning a mono signal in a stereo field.
 * Because of the generally accepted meaning of pan,
 * this UGen strictly enforces the channel count of its 
 * input and output. Anything patched to the audio input 
 * of Pan will be configured to generate mono audio, and when 
 * Pan is patched to any other UGen, it will throw an 
 * exception if that UGen tries to set Pan's channel count 
 * to anything other than 2.
 * 
 * @example Synthesis/panExample
 * 
 * @related UGen
 * @related Balance
 * 
 * @author nb, ddf
 */

public class Pan extends UGen
{
	/**
	 * UGens patched to this input should generate values between -1 and +1.
	 * 
	 * @example Synthesis/panExample
	 * 
	 * @related Pan
	 * @related setPan ( )
	 */
	public UGenInput		pan;

	private UGen			audio;
	private float[]			tickBuffer = new float[1];

	static private float	PIOVER2	= (float)Math.PI / 2.f;

	/**
	 * Construct a Pan UGen with a specific starting pan value.
	 * 
	 * @param panValue
	 *            float: a value of 0 means to pan dead center, 
	 *            -1 hard left, and 1 hard right.
	 */
	public Pan(float panValue)
	{
		super();
		pan = addControl( panValue );
	}

	/**
	 * Set the pan value of this Pan. Values passed to this method should be
	 * between -1 and +1. This is equivalent to calling the setLastValue method 
	 * on the pan input directly.
	 * 
	 * @param panValue
	 * 			the new value for the pan input
	 * 
	 * @related Pan
	 * @related pan
	 */
	public void setPan(float panValue)
	{
		pan.setLastValue( panValue );
	}

	@Override
	protected void addInput(UGen in)
	{
		// System.out.println("Adding " + in.toString() + " to Pan.");
		audio = in;
		// we only deal in MONO!
		audio.setChannelCount( 1 );
	}

	@Override
	protected void removeInput(UGen input)
	{
		if ( audio == input )
		{
			audio = null;
		}
	}

	@Override
	protected void sampleRateChanged()
	{
		if ( audio != null )
		{
			audio.setSampleRate( sampleRate() );
		}
	}

	/**
	 * Pan overrides setChannelCount to ensure that it can 
	 * never be set to output more or fewer than 2 channels.
	 */
	@Override
	public void setChannelCount(int numberOfChannels)
	{
		if ( numberOfChannels == 2 )
		{
			super.setChannelCount( numberOfChannels );
		}
		else
		{
			throw new IllegalArgumentException( "Pan MUST be ticked with STEREO output! It doesn't make sense in any other context!" );
		}
	}

	/**
	 * NOTE: Currently only supports stereo audio!
	 */
	@Override
	protected void uGenerate(float[] channels)
	{
		if ( channels.length != 2 )
		{
			throw new IllegalArgumentException( "Pan MUST be ticked with STEREO output! It doesn't make sense in any other context!" );
		}

		float panValue = pan.getLastValue();

		// tick our audio as MONO because that's what a Pan is for!
		if ( audio != null )
		{
			audio.tick( tickBuffer );
		}

		// formula swiped from the MIDI specification:
		// http://www.midi.org/techspecs/rp36.php
		// Left Channel Gain [dB] = 20*log (cos (Pi/2* max(0,CC#10 - 1)/126)
		// Right Channel Gain [dB] = 20*log (sin (Pi /2* max(0,CC#10 - 1)/126)

		// dBvalue = 20.0 * log10 ( linear );
		// dB = 20 * log (linear)

		// conversely...
		// linear = pow ( 10.0, (0.05 * dBvalue) );
		// linear = 10^(dB/20)

		float normBalance = ( panValue + 1.f ) * 0.5f;

		// note that I am calculating amplitude directly, by using the linear
		// value
		// that the MIDI specification suggests inputing into the dB formula.
		float leftAmp = (float)Math.cos( PIOVER2 * normBalance );
		float rightAmp = (float)Math.sin( PIOVER2 * normBalance );

		channels[0] = tickBuffer[0] * leftAmp;
		channels[1] = tickBuffer[0] * rightAmp;
	}
}
