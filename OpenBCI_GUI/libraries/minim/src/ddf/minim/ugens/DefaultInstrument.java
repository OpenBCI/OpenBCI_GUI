package ddf.minim.ugens;
import ddf.minim.AudioOutput;
//import ddf.minim.effects.IIRFilter;
import ddf.minim.effects.LowPassSP;

/**
 * You can use this default instrument to make sound if you don't want to write 
 * your own instrument. It's a good way to start playing around with the playNote
 * method of AudioOutput. The default instrument makes a fuzzy triangle wave sound.
 * 
 * @example Synthesis/defaultInstrumentExample
 * 
 * @related Instrument
 * @related AudioOutput
 * 
 * @author Anderson Mills
 *
 */

public class DefaultInstrument implements Instrument
{
	private Oscil toneOsc;
	private Noise noiseGen;
	private Damp noiseEnv, toneEnv;
	//Gain toneEnv;
	//Damp toneEnv;
	private AudioOutput output;
	private Summer summer;
	private LowPassSP lpFilter;
		 
	/**
	 * Construct a default instrument that will play a note at the given frequency on the given output.
	 * 
	 * @param frequency 
	 * 			float: the frequency of the note
	 * @param output 
	 * 			AudioOutput: the output to play the note on when noteOn is called
	 */
	public DefaultInstrument( float frequency, AudioOutput output )
	{
		this.output = output;
		    
		float amplitude = 0.3f; 
		noiseGen = new Noise( 0.4f*amplitude, Noise.Tint.WHITE );
		noiseEnv = new Damp( 0.05f );
		lpFilter = new LowPassSP( 2.0f*frequency, output.sampleRate() );
		toneOsc = new Oscil( frequency, 0.9f*amplitude, Waves.TRIANGLE );
		//toneEnv = new Damp( 1.0f );
		toneEnv = new Damp( 2.0f/frequency, 1.0f );
		//toneEnv = new Gain( 0f );
		summer = new Summer();
		
		toneOsc.patch( toneEnv ).patch( summer );
		noiseGen.patch( noiseEnv ).patch( lpFilter).patch( summer );
		//.patch( output );
	}

	/**
	 * Turn on the default instrument.
	 * Typically, you will not call this directly.
	 * It will be called at the appropriate time by 
	 * the AudioOuput you schedule a note with.
	 * 
	 * @shortdesc Turn on the default instrument.
	 * 
	 * @param dur
	 * 			float: The duration of the note, in seconds.
	 * 
	 * @related DefaultInstrument
	 */
	public void noteOn( float dur )
	{
		summer.patch( output );
		toneEnv.setDampTimeFromDuration( dur );
		toneEnv.activate();
		noiseEnv.activate();
		//toneEnv.setValue( 1.0f );
		//summer.patch( output );
	}
		  
	/**
	 * Turn off the default instrument.
	 * 
	 * Typically, you will not call this directly.
	 * It will be called at the appropriate time by 
	 * the AudioOuput you schedule a note with.
	 * 
	 * @shortdesc Turn off the default instrument.
	 * 
	 * @related DefaultInstrument
	 */
	public void noteOff()
	{
		//toneEnv.setValue( 0.0f );
		summer.unpatch( output );
	}
}
