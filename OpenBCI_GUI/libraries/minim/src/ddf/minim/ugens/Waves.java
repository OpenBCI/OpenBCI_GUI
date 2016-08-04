package ddf.minim.ugens;

/**
 * Waves provides some already constructed Wavetables for common waveforms, as
 * well as methods for constructing some basic waveforms with non-standard
 * parameters. For instance, you can use the QUARTERPULSE member if you want a
 * typical "thin" square wave sound, but you might want a square wave with a 60%
 * duty cycle instead, which you can create by passing 0.6f to the square
 * method. Methods exist for generating basic waves with multiple harmonics,
 * basic waves with different duty cycles, and noise.
 * 
 * @example Synthesis/waveformExample
 * 
 * @related Wavetable
 * @related WavetableGenerator
 * @related Oscil
 * 
 * @author Nicolas Brix, Anderson Mills
 */
public class Waves
{
	// private constructor so it doesn't show up in documentation
	// and so that people can't make instances of this class, which is all
	// static methods
	private Waves()
	{
	}

	/**
	 * standard size for a Wavetable from Waves
	 */
	private static int				tableSize		= 8192;
	private static int				tSby2			= tableSize / 2;
	private static int				tSby4			= tableSize / 4;

	// Perfect waveforms
	/**
	 * A pure sine wave.
	 * 
	 * @example Basics/SynthesizeSound
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public final static Wavetable	SINE			= WavetableGenerator.gen10(
															tableSize,
															new float[] { 1 } );
	/**
	 * A perfect sawtooth wave.
	 * 
	 * @example Basics/SynthesizeSound
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public final static Wavetable	SAW				= WavetableGenerator.gen7(
															tableSize,
															new float[] { 0,-1, 1, 0 }, 
															new int[] { tSby2, 0, tableSize - tSby2	} );
	
	/**
	 * A perfect phasor wave going from 0 to 1.
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public final static Wavetable	PHASOR			= WavetableGenerator.gen7( tableSize,
																	new float[] { 0, 1 },
																	new int[] { tableSize } );
	/**
	 * A perfect square wave with a 50% duty cycle.
	 * 
	 * @example Basics/SynthesizeSound
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public final static Wavetable	SQUARE			= WavetableGenerator.gen7(
															tableSize,
															new float[] { -1, -1, 1, 1 }, 
															new int[] { tSby2, 0, tableSize - tSby2	} );

	/**
	 * A perfect triangle wave.
	 * 
	 * @example Basics/SynthesizeSound
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public final static Wavetable	TRIANGLE		= WavetableGenerator.gen7(
															tableSize,
															new float[] { 0, 1, -1, 0 }, 
															new int[] { tSby4, tSby2, tableSize - tSby2 - tSby4	} );

	/**
	 * A perfect square wave with a 25% duty cycle.
	 * 
	 * @example Basics/SynthesizeSound
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public final static Wavetable	QUARTERPULSE	= WavetableGenerator.gen7(
															tableSize,
															new float[] { -1, -1, 1, 1 }, 
															new int[] { tSby4, 0, tableSize - tSby4	} );

	/**
	 * Builds an approximation of a perfect sawtooth wave by summing together
	 * harmonically related sine waves.
	 * 
	 * @param numberOfHarmonics
	 *            int: the number of harmonics to use in the approximation. 1 harmonic 
	 *            will simply generate a sine wave. The greater the number of 
	 *            harmonics used, the closer to a pure saw wave the approximation will be.
	 * 
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable sawh(int numberOfHarmonics)
	{
		float[] content = new float[numberOfHarmonics];
		for ( int i = 0; i < numberOfHarmonics; i++ )
		{
			content[i] = (float)( ( -2 ) / ( ( i + 1 ) * Math.PI ) * Math.pow( -1, i + 1 ) );
		}
		return WavetableGenerator.gen10( tableSize, content );
	}

	/**
	 * Constructs a perfect sawtooth wave with the specified duty cycle.
	 * 
	 * @param dutyCycle
	 * 			float: a sawtooth wave with a duty cycle of 0.5 will be 
	 * 			a perfect sawtooth wave that smoothly changes from 1 to -1 
	 * 			with a zero-crossing in the middle. By changing the duty 
	 * 			cycle, you change how much of the sawtooth is below zero. 
	 * 			So, a duty cycle of 0.2 would result in 20 percent of the 
	 *  		sawtooth below zero and the rest above. Duty cycle will 
	 *  		be clamped to [0,1].
	 *  
	 * @return Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable saw(float dutyCycle)
	{
		dutyCycle = Math.max( 0, Math.min( dutyCycle, 1 ) );
		int a 	  = (int)( tableSize * dutyCycle );
		return WavetableGenerator.gen7( tableSize, new float[] { 0, -1, 1, 0 }, new int[] { a, 0, tableSize - a } );
	}

	/**
	 * Builds an approximation of a perfect square wave by summing together
	 * harmonically related sine waves.
	 * 
	 * @param numberOfHarmonics
	 *            int: the number of harmonics to use in the approximation. 1 harmonic 
	 *            will simply generate a sine wave. The greater the number of 
	 *            harmonics used, the closer to a pure saw wave the approximation will be.
	 *            
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable squareh(int numberOfHarmonics)
	{
		float[] content = new float[numberOfHarmonics + 1];
		for ( int i = 0; i < numberOfHarmonics; i += 2 )
		{
			content[i] = (float)1 / ( i + 1 );
			content[i + 1] = 0;
		}
		return WavetableGenerator.gen10( tableSize, content );
	}

	/**
	 * Constructs a perfect square wave with the specified duty cycle.
	 * 
	 * @param dutyCycle
	 * 			float: a square wave with a duty cycle of 0.5 will be 
	 * 			a perfect square wave that is 1 half the time and -1 the other half. 
	 * 			By changing the duty cycle, you change how much of the square 
	 * 			is below zero. So, a duty cycle of 0.2 would result in 20 percent of the 
	 *  		square below zero and the rest above. Duty cycle will 
	 *  		be clamped to [0,1].
	 *  
	 * @return Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable square(float dutyCycle)
	{// same as pulse
		return pulse( dutyCycle );
	}

	/**
	 * Constructs a perfect square wave with the specified duty cycle.
	 * 
	 * @param dutyCycle
	 * 			float: a square wave with a duty cycle of 0.5 will be 
	 * 			a perfect square wave that is 1 half the time and -1 the other half. 
	 * 			By changing the duty cycle, you change how much of the square 
	 * 			is below zero. So, a duty cycle of 0.2 would result in 20 percent of the 
	 *  		square below zero and the rest above. Duty cycle will 
	 *  		be clamped to [0,1].
	 *  
	 * @return Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable pulse(float dutyCycle)
	{
		dutyCycle = Math.max( 0, Math.min( dutyCycle, 1 ) );
		return WavetableGenerator.gen7( tableSize, 
				new float[] { -1, -1, 1, 1 }, 
				new int[] { (int)( dutyCycle * tableSize ), 0, tableSize - (int)( dutyCycle * tableSize ) } );
	}

	/**
	 * Builds an approximation of a perfect triangle wave by summing together
	 * harmonically related sine waves.
	 * 
	 * @param numberOfHarmonics
	 *            int: the number of harmonics to use in the approximation. 1 harmonic 
	 *            will simply generate a sine wave. The greater the number of 
	 *            harmonics used, the closer to a pure saw wave the approximation will be.
	 *            
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable triangleh(int numberOfHarmonics)
	{
		float[] content = new float[numberOfHarmonics + 1];
		for ( int i = 0; i < numberOfHarmonics; i += 2 )
		{
			content[i] = (float)( Math.pow( -1, i / 2 ) * 8 / Math.PI / Math.PI / Math.pow( i + 1, 2 ) );
			content[i + 1] = 0;
		}
		return WavetableGenerator.gen10( tableSize, content );
	}

	/**
	 * Constructs a perfect triangle wave with the specified duty cycle.
	 * 
	 * @param dutyCycle
	 * 			float: a triangle wave with a duty cycle of 0.5 will be 
	 * 			a perfect triangle wave that is 1 half the time and -1 the other half. 
	 * 			By changing the duty cycle, you change how much of the triangle 
	 * 			is below zero. So, a duty cycle of 0.2 would result in 20 percent of the 
	 *  		triangle below zero and the rest above. Duty cycle will 
	 *  		be clamped to [0,1].
	 *  
	 * @return Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable triangle(float dutyCycle)
	{
		dutyCycle = Math.max( 0, Math.min( dutyCycle, 1 ) );
		int a = (int)( tableSize * dutyCycle * 0.5 );
		return WavetableGenerator.gen7( tableSize,
				new float[] { 0, -1, 0, 1, 0 }, new int[] { a, a, tSby2 - a, tableSize - tSby2 - a } );
	}

	// TODO a dutycycled sine wavetable : i think a new warp() method in
	// Wavetable would be the best

	/**
	 * Constructs a waveform by summing together the first numberOfHarmonics 
	 * in the harmonic series with randomly chosen amplitudes. This often 
	 * sounds like an organ.
	 * 
	 * @param numberOfHarmonics
	 * 			int: the number of harmonics to use when generating the wave
	 * 
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable randomNHarms(int numberOfHarmonics)
	{
		float[] harmAmps = new float[numberOfHarmonics];
		for ( int i = 0; i < numberOfHarmonics; i++ )
		{
			harmAmps[i] = (float)Math.random() * 2 - 1;
		}
		Wavetable builtWave = WavetableGenerator.gen10( tableSize, harmAmps );
		builtWave.normalize();
		return builtWave;
	}

	/**
	 * Constructs a waveform by summing together the first odd numberOfHarmonics 
	 * in the harmonic series (1, 3, 5, etc) with randomly chosen amplitudes. 
	 * This often sounds like an organ with a band pass filter on it.
	 * 
	 * @param numberOfHarmonics
	 * 			int: the number of odd harmonics to use when generating the wave
	 * 
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable randomNOddHarms(int numberOfHarmonics)
	{
		float[] harmAmps = new float[numberOfHarmonics * 2];
		for ( int i = 0; i < numberOfHarmonics; i += 1 )
		{
			harmAmps[i * 2] = (float)Math.random() * 2 - 1;
			harmAmps[i * 2 + 1] = 0.0f;
		}
		Wavetable builtWave = WavetableGenerator.gen10( tableSize, harmAmps );
		builtWave.normalize();
		return builtWave;
	}

	/**
	 * Constructs a Wavetable of randomly generated noise.
	 * 
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Wavetable
	 * @related Waveform
	 */
	public static Wavetable randomNoise()
	{
		float[] builtArray = new float[tableSize];
		for ( int i = 0; i < builtArray.length; i++ )
		{
			builtArray[i] = (float)Math.random() * 2 - 1;
		}
		Wavetable builtWave = new Wavetable( builtArray );
		builtWave.normalize();
		return builtWave;
	}

	/**
	 * Generates a Wavetable by adding any number of Waveforms, each scaled by an amplitude.
	 * 
	 * Calling this method might look like:
	 * <code>
	 * Wavetable wave = Wavetable.add( new float[] { 0.8f, 0.2f }, Waves.SINE, Waves.SAW );
	 * </code>
	 * or:
	 * <code>
	 * Wavetable wave = Wavetable.add( new float[] { 0.2f, 0.3f, 0.5f }, Waves.SINE, Waves.SQUARE, Waves.sawh( 6 ) );
	 * </code>
	 * 
	 * In other words, the number of elements in the amplitude array
	 * must match the number of Waveform arguments provided.
	 * 
	 * @shortdesc Generates a Wavetable by adding any number of Waveforms, each scaled by an amplitude.
	 * 
	 * @param amps
	 * 			float[]: an array of amplitudes used to scale the matching Waveform argument 
	 * 					 when adding it into the final Wavetable.
	 * @param waves
	 * 			Waveform vararg: The Waveforms to be added together. The number of Waveforms
	 * 			passed in as arguments much match the length of the amps array.
	 * 
	 * @example Synthesis/waveformExample
	 * 
	 * @return a Wavetable
	 * 
	 * @related Waves
	 * @related Waveform
	 * @related Wavetable
	 */
	public static Wavetable add(float[] amps, Waveform... waves)
	{
		if ( amps.length != waves.length )
		{
			System.out.println( "add() : amplitude array size must match the number of waveforms!" );
			return null;
		}
		
		float[] accumulate = new float[tableSize];
		for ( int i = 0; i < waves.length; i++ )
		{
			for ( int j = 0; j < tableSize; j++ )
			{
				float lu = (float)j / tableSize;
				accumulate[j] += waves[i].value( lu ) * amps[i];
			}
		}
		return new Wavetable( accumulate );
	}
}
