package ddf.minim.ugens;

/**
 * An interface to represent a Waveform that can be sampled by using a value 
 * between 0 and 1. 
 * 
 * @author Damien Di Fede
 * 
 * @related Oscil
 * @related Wavetable
 *
 */

public interface Waveform 
{
	/**
	 * <p>
	 * Sample the Waveform at the location specified. 
	 * As an example, if the Waveform represents a sine wave,
	 * then we would expect the following:
	 * </p>
	 * <pre>
	 * waveform.value( 0.25f ) == sin( PI/2 )
	 * waveform.value( 0.5f ) == sin( PI )
	 * waveform.value( 0.75f ) == sin( 3*PI/2 )
	 * </pre> 
	 * 
	 * @shortdesc Sample the Waveform at the location specified.
	 * 
	 * @param at
	 * 			float: a value in the range [0,1]
	 * @return float: the value of the Waveform at the sampled location
	 * 
	 * @related Waveform
	 */
	float value(float at);
}
