package ddf.minim.ugens;

import ddf.minim.UGen;

/**
 * A UGen which provides <a href="http://en.wikipedia.org/wiki/Waveshaper">waveshaping distortion</a>. 
 * The incoming "audio" signal is used as an index to a Waveform containing a
 * "mapping" function and the output of the waveshaper is the value in the
 * Waveform given by the index. The incoming wave is expected to have values
 * between -1 and 1 although exceeding this range can be used expressively. The
 * input signal is then normalized so that -1 to 1 becomes 0 and 1 to provide
 * the index value. The output waveshape is then multiplied by an output
 * amplitude.
 * 
 * A library of shapes is defined, that the user can call. The shapes are
 * Wavetables, which can be used in a creative way (using waveforms from the
 * Waves library for example).
 * 
 * @example Synthesis/waveShaperExample
 * 
 * @related Waves
 * @related Wavetable
 * @related UGen
 * 
 * @author Nicolas Brix, Anderson Mills
 */
public class WaveShaper extends UGen
{
	/**
	 * The default input is "audio."
	 * 
	 * @related WaveShaper
	 */
	public UGenInput	audio;
	
	/**
	 * The output amplitude
	 * 
	 * @related WaveShaper
	 */
	public UGenInput	outAmplitude;
	
	/**
	 * The mapping amplitude of the input signal
	 * 
	 * @related WaveShaper
	 */
	public UGenInput	mapAmplitude;

	// flag to wrap the map around the ends instead of hitting the edge
	private boolean		wrapMap;
	// the current waveshape for mapping
	private Waveform	mapShape;

	/**
	 * Constructor for WaveShaper. 
	 * 
	 * mapWrap, a boolean flag to wrap the map
	 * around the ends instead of hitting the edge, defaults to false.
	 * 
	 * @shortdesc Constructor for WaveShaper.
	 * 
	 * @param outAmp
	 *            float: the output amplitude multiplier of the shaped wave
	 * @param mapAmp
	 *            float: amplitude over which to map the incoming signal
	 * @param mapShape
	 *            Waveform: waveshape over which to map the incoming signal
	 *            
	 * @related WaveShaper
	 */
	public WaveShaper(float outAmp, float mapAmp, Waveform mapShape)
	{
		this( outAmp, mapAmp, mapShape, false );
	}

	/**
	 * Constructor for WaveShaper.
	 * 
	 * @param outAmp
	 *            float: the output amplitude multiplier of the shaped wave
	 * @param mapAmp
	 *            float: amplitude over which to map the incoming signal
	 * @param mapShape
	 *            Waveform: waveshape over which to map the incoming signal
	 * @param wrapMap
	 *            boolean: flag to wrap the map instead of hit the edge and stick
	 *            
	 * @related WaveShaper
	 */
	public WaveShaper(float outAmp, float mapAmp, Waveform mapShape, boolean wrapMap)
	{
		super();
		audio = new UGenInput( InputType.AUDIO );

		mapAmplitude = new UGenInput( InputType.CONTROL );
		mapAmplitude.setLastValue( mapAmp );

		outAmplitude = new UGenInput( InputType.CONTROL );
		outAmplitude.setLastValue( outAmp );

		this.mapShape = mapShape;
		this.wrapMap = wrapMap;
	}

	// the input signal is supposed to be less than 1 in amplitude
	// as Wavetable is basically an array of floats accessed via a 0 to 1.0
	// index,
	// some shifting+scaling has to be done
	// the shape is supposed to be -1 at [0] and +1 at [length].
	@Override
	protected void uGenerate(float[] channels)
	{
		// run over the length of the channel array
		for ( int i = 0; i < channels.length; i++ )
		{
			// bring in the audio as index, scale by the map amplitude, and
			// normalize
			float tmpIndex = ( mapAmplitude.getLastValue() * audio
					.getLastValues()[i] ) / 2.0f + 0.5f;

			// handle the cases where it goes out of bouds
			if ( wrapMap ) // wrap oround
			{
				// what's left after dividing by 1?
				tmpIndex %= 1.0f;
				// I don't like that remaider gives the same sign as the first
				// argument
				if ( tmpIndex < 0.0f )
				{
					tmpIndex += 1.0f;
				}
			}
			else if ( tmpIndex > 1.0f ) // otherwise cap at 1
			{
				tmpIndex = 1.0f;
			}
			else if ( tmpIndex < 0.0f ) // and cap on the bottom at 0
			{
				tmpIndex = 0.0f;
			}

			// now that tmpIndex is good, look up the wavetable value and
			// multiply by outAmp
			channels[i] = outAmplitude.getLastValue() * mapShape.value( tmpIndex );
		}
	}
}
