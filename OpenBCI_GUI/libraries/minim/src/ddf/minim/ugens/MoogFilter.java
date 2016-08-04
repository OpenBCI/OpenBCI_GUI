package ddf.minim.ugens;

import java.util.Arrays;

import ddf.minim.UGen;

//Moog 24 dB/oct resonant lowpass VCF
//References: CSound source code, Stilson/Smith CCRMA paper.
//Modified by paul.kellett@maxim.abel.co.uk July 2000
//Java implementation by Damien Di Fede September 2010

/**
 * MoogFilter is a digital model of a Moog 24 dB/octave resonant VCF.
 * It can be set to low pass, high pass, or band pass using the 
 * MoogFilter.Type enumeration. More generally, a filter is used to 
 * remove certain ranges of the audio spectrum from a sound. 
 * A low pass filter will allow frequencies below the cutoff frequency
 * to be heard, a high pass filter allows frequencies above the cutoff 
 * frequency to be heard, a band pass filter will allow frequencies 
 * to either side of the center frequency to be heard. With MoogFilter, 
 * the cutoff frequency and the center frequency are set using the 
 * <code>frequency</code> input. Because this is a <i>resonant</i> 
 * filter, it means that frequencies close to the cutoff of center frequency
 * will become slighly emphasized, depending on the value of the 
 * <code>resonance</code> input. The resonance of the filter has a 
 * range from 0 to 1, where as the resonance approaches 1 the filter will 
 * begin to "ring" at the cutoff frequency.
 * 
 * @example Synthesis/moogFilterExample
 * 
 * @related UGen
 * 
 * @author Damien Di Fede
 *
 */
public class MoogFilter extends UGen
{
	/**
	 * The MoogFilter.Type enumeration is used to set 
	 * the filter mode of a MoogFilter. HP is high pass,
	 * LP is low pass, and BP is band pass. 
	 * 
	 * @example Synthesis/moogFilterExample
	 * 
	 * @related type
	 * @related MoogFilter
	 * 
	 * @nosuperclasses
	 */
	public enum Type
	{
		/**
		 * The value representing high pass.
		 * 
		 * @related type
		 */
		HP,
		
		/**
		 * The value representing low pass.
		 * 
		 * @related type
		 */
		LP,
		
		/**
		 * The value representing band pass.
		 * 
		 * @related type
		 */
		BP
	}
	
	/**
	 * The main audio input where the the UGen 
	 * you want to filter should be patched.
	 * 
	 * @related MoogFilter
	 * @related UGen.UGenInput
	 */
	public UGenInput	audio;
	
	/**
	 * The cutoff (or center) frequency of the filter, 
	 * expressed in Hz.
	 * 
	 * @example Synthesis/moogFilterExample
	 * 
	 * @related MoogFilter
	 * @related UGen.UGenInput
	 */
	public UGenInput	frequency;
	
	/**
	 * The resonance of the filter, expressed as a normalized value [0,1].
	 * 
	 * @example Synthesis/moogFilterExample
	 * 
	 * @related MoogFilter
	 * @related UGen.UGenInput
	 */
	public UGenInput	resonance;
	
	/**
	 * The current type of this filter: low pass, high pass, or band pass.
	 * 
	 * @example Synthesis/moogFilterExample
	 * 
	 * @related MoogFilter.Type
	 */
	public Type 		type;

	private float		coeff[][];	// filter buffers (beware denormals!)
	
	/**
	 * Creates a low pass filter.
	 * 
	 * @param frequencyInHz 
	 * 		float: the cutoff frequency for the filter
	 * @param normalizedResonance 
	 * 		float: the resonance of the filter [0,1]
	 */
	public MoogFilter( float frequencyInHz, float normalizedResonance )
	{
		this( frequencyInHz, normalizedResonance, Type.LP );
	}

	/**
	 * Creates a filter of the type specified.
	 * 
	 * @param frequencyInHz 
	 * 		float: the cutoff frequency for the filter
	 * @param normalizedResonance 
	 * 		float: the resonance of the filter [0,1]
	 * @param filterType
	 * 		the type of the filter: MoogFilter.Type.HP (high pass), 
	 * 		MoogFitler.Type.LP (low pass), or MoogFilter.Type.BP (band pass)
	 */
	public MoogFilter(float frequencyInHz, float normalizedResonance, Type filterType )
	{
		super();
		
		audio = new UGenInput( InputType.AUDIO );
		frequency = new UGenInput( InputType.CONTROL );
		resonance = new UGenInput( InputType.CONTROL );
		type      = filterType;

		frequency.setLastValue( frequencyInHz );
		resonance.setLastValue( constrain( normalizedResonance, 0.f, 1.f ) );
		
		coeff = new float[channelCount()][5];
	}

	protected void channelCountChanged()
	{
		if ( coeff == null || coeff.length != channelCount() )
		{
			coeff = new float[channelCount()][5];
		}
	}

	protected void uGenerate(float[] out)
	{
		// Set coefficients given frequency & resonance [0.0...1.0]
		float t1, t2; // temporary buffers
		float normFreq = frequency.getLastValue() / ( sampleRate() * 0.5f );
		float rez = constrain( resonance.getLastValue(), 0.f, 1.f );

		float q = 1.0f - normFreq;
		float p = normFreq + 0.8f * normFreq * q;
		float f = p + p - 1.0f;
		q = rez * ( 1.0f + 0.5f * q * ( 1.0f - q + 5.6f * q * q ) );

		float[] input = audio.getLastValues();

		for ( int i = 0; i < channelCount(); ++i )
		{
			// Filter (in [-1.0...+1.0])
			float[] b = coeff[i];
			float in = constrain( input[i], -1, 1 ); // hard clip

			in -= q * b[4]; // feedback

			t1 = b[1];
			b[1] = ( in + b[0] ) * p - b[1] * f;

			t2 = b[2];
			b[2] = ( b[1] + t1 ) * p - b[2] * f;

			t1 = b[3];
			b[3] = ( b[2] + t2 ) * p - b[3] * f;

			b[4] = ( b[3] + t1 ) * p - b[4] * f;
			b[4] = b[4] - b[4] * b[4] * b[4] * 0.166667f; // clipping
			
			// inelegantly squash denormals
	        if ( Float.isNaN( b[4] ) )
	        {
	        	Arrays.fill( b, 0 );
	        }

			b[0] = in;

			switch( type )
			{
			case HP:
				out[i] = in - b[4];
				break;
				
			case LP:
				out[i] = b[4];
				break;
				
			case BP:
				out[i] = 3.0f * (b[3] - b[4]);
			}
		}
	}
	
	private float constrain( float value, float min, float max )
	{
		if ( value < min ) return min;
		if ( value > max ) return max;
		return value;
	}
}
