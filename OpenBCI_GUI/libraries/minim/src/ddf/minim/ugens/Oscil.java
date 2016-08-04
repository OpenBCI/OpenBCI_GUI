package ddf.minim.ugens;

import java.util.Arrays;

import ddf.minim.UGen;

/**
 * <p>
 * An Oscil is a UGen that generates audio by oscillating over a Waveform 
 * at a particular frequency. For instance, if you were to create this Oscil:
 * </p>
 * <pre>Oscil testTone = new Oscil( 440, 1, Waves.SINE );</pre>
 * <p>
 * When patched to an AudioOuput, it would generate a continuous sine wave tone 
 * at 440 Hz and would sound like a test tone. 
 * This frequency also happens to be the same as the pitch played 
 * by the lead oboist in a orchestra when they tune up at the beginning of a concert.
 * </p>
 * <p>
 * However, rather than give Oscil a fixed, or limited, set of sounds it 
 * can generate, instead it simply oscillates over a generic Waveform object. 
 * Waveform is simply an <em>interface</em> that declares a value method, which 
 * is used by Oscil to determine what value it should output at any given moment 
 * in time. Generally, you will use predefined Waveforms from the Waves class, 
 * or generated Waveforms using the WavetableGenerator class. However, there's 
 * no particular reason you couldn't define your own classes that implement 
 * the Waveform interface.
 * </p>
 * <p>
 * Another abstraction the Oscil UGen makes use of is the Frequency class. 
 * This class allows you to define a frequency in terms of pitch, midi note, 
 * or hertz. This is often quite useful when writing musical scores with code.
 * For instance, we could use the Frequency class when creating an Oscil that 
 * will sound the same as the example above:
 * </p>
 * <pre>Oscil testTone = new Oscil( Frequency.ofPitch("A4"), 1, Waves.SINE );</pre>
 * 
 * @example Basics/SynthesizeSound
 * 
 * @related UGen
 * @related Waveform
 * @related Waves
 * @related WavetableGenerator
 * @related Frequency
 * 
 * @author Damien Di Fede, Anderson Mills
 * 
 */
public class Oscil extends UGen
{
	/**
	 * Patch to this to control the amplitude of the oscillator with another
	 * UGen.
	 * 
	 * @example Synthesis/oscilEnvExample
	 * 
	 * @related Oscil
	 */
	public UGenInput	amplitude;

	/**
	 * Patch to this to control the frequency of the oscillator with another
	 * UGen.
	 * 
	 * @example Synthesis/frequencyModulation
	 * 
	 * @related Oscil
	 */
	public UGenInput	frequency;

	/**
	 * Patch to this to control the phase of the oscillator with another UGen.
	 * 
	 * @example Synthesis/oscilPhaseExample
	 * 
	 * @related Oscil
	 */
	public UGenInput	phase;

	/**
	 * Patch to this to control the DC offset of the Oscil with another UGen. 
	 * This is useful when using an Oscil as a modulator.
	 * 
	 * @example Synthesis/frequencyModulation
	 * 
	 * @related Oscil
	 */
	public UGenInput	offset;

	// the waveform we will oscillate over
	private Waveform	wave;

	// where we will sample our waveform, moves between [0,1]
	private float		step;
	// the step size we will use to advance our step
	private float		stepSize;
	// what was our frequency from the last time we updated our step size
	// stashed so that we don't do more math than necessary
	private float		prevFreq;
	// 1 / sampleRate, which is used to calculate stepSize
	private float		oneOverSampleRate;

	// constructors
	/**
	 * Constructs an Oscil UGen, given frequency in Hz, amplitude, and a waveform
	 * 
	 * @param frequencyInHertz
	 *            float: the frequency this Oscil should oscillate at
	 * @param amplitude
	 *            float: the amplitude of this Oscil.
	 * @param waveform
	 *            Waveform: the waveform this Oscil will oscillate over
	 *            
	 * @related Waveform
	 */
	public Oscil(float frequencyInHertz, float amplitude, Waveform waveform)
	{
		this( Frequency.ofHertz( frequencyInHertz ), amplitude, waveform );
	}

	/**
	 * Constructs an Oscil UGen given frequency in Hz and amplitude. This
	 * oscillator uses a sine wave.
	 * 
	 * @param frequencyInHertz
	 *            float: the frequency this Oscil should oscillate at
	 * @param amplitude
	 *            float: the amplitude of this Oscil.
	 */
	public Oscil(float frequencyInHertz, float amplitude)
	{
		this( Frequency.ofHertz( frequencyInHertz ), amplitude );
	}

	/**
	 * Constructs an Oscil UGen given a Frequency and amplitude. This oscillator
	 * uses a sine wave.
	 * 
	 * @param frequency
	 *            Frequency: the frequency this Oscil should oscillate at.
	 * @param amplitude
	 *            float: the amplitude of this Oscil.
	 */
	// shortcut for building a sine wave
	public Oscil(Frequency frequency, float amplitude)
	{
		this( frequency, amplitude, Waves.SINE );
	}

	/**
	 * Constructs an Oscil UGen given a Frequency, amplitude, and a waveform
	 * 
	 * @param frequency
	 *            Frequency: the frequency this Oscil should oscillate at.
	 * @param amplitude
	 *            float: the amplitude of this Oscil.
	 * @param waveform
	 *            Waveform: the waveform this Oscil will oscillate over
	 * 
	 * @related Frequency
	 * @related Waveform
	 */
	public Oscil(Frequency frequency, float amplitude, Waveform waveform)
	{
		super();

		this.amplitude = new UGenInput( InputType.CONTROL );
		this.amplitude.setLastValue( amplitude );

		this.frequency = new UGenInput( InputType.CONTROL );
		this.frequency.setLastValue( frequency.asHz() );

		phase = new UGenInput( InputType.CONTROL );
		phase.setLastValue( 0.f );

		offset = new UGenInput( InputType.CONTROL );
		offset.setLastValue( 0.f );

		wave = waveform;
		step = 0f;
		oneOverSampleRate = 1.f;
	}

	/**
	 * This routine will be called any time the sample rate changes.
	 */
	protected void sampleRateChanged()
	{
		oneOverSampleRate = 1 / sampleRate();
		// don't call updateStepSize because it checks for frequency change
		stepSize = frequency.getLastValue() * oneOverSampleRate;
		prevFreq = frequency.getLastValue();
	}

	// updates our step size based on the current frequency
	private void updateStepSize()
	{
		float currFreq = frequency.getLastValue();
		if ( prevFreq != currFreq )
		{
			stepSize = currFreq * oneOverSampleRate;
			prevFreq = currFreq;
		}
	}

	/**
	 * Sets the frequency of this Oscil. You might want to do this to change the
	 * frequency of this Oscil in response to a button press or something. For
	 * controlling frequency continuously over time you will usually want to use
	 * the frequency input.
	 * 
	 * @shortdesc Sets the frequency of this Oscil.
	 * 
	 * @param hz
	 *            the frequency, in Hertz, to set this Oscil to
	 *            
	 * @example Basics/SynthesizeSound
	 * 
	 * @related frequency
	 * @related Frequency
	 * @related Oscil
	 */
	public void setFrequency(float hz)
	{
		frequency.setLastValue( hz );
		updateStepSize();
	}

	/**
	 * Sets the frequency of this Oscil. You might want to do this to change the
	 * frequency of this Oscil in response to a button press or something. For
	 * controlling frequency continuously over time you will usually want to use
	 * the frequency input.
	 * 
	 * @shortdesc Sets the frequency of this Oscil.
	 * 
	 * @param newFreq
	 *            the Frequency to set this Oscil to
	 *            
	 * @example Basics/SynthesizeSound          
	 *            
	 * @related frequency
	 * @related Frequency
	 * @related Oscil
	 */
	public void setFrequency(Frequency newFreq)
	{
		frequency.setLastValue( newFreq.asHz() );
		updateStepSize();
	}

	/**
	 * Sets the amplitude of this Oscil. You might want to do this to change the
	 * amplitude of this Oscil in response to a button press or something. For
	 * controlling amplitude continuously over time you will usually want to use
	 * the amplitude input.
	 * 
	 * @shortdesc Sets the amplitude of this Oscil.
	 * 
	 * @param newAmp
	 *            amplitude to set this Oscil to
	 *            
	 * @example Basics/SynthesizeSound
	 * 
	 * @related amplitude
	 * @related Oscil
	 */
	public void setAmplitude(float newAmp)
	{
		amplitude.setLastValue( newAmp );
	}

	/**
	 * Set the amount that the phase will be offset by. Oscil steps its time
	 * from 0 to 1, which means that the phase is also normalized. However, it
	 * still makes sense to set the phase to greater than 1 or even to a
	 * negative number.
	 * 
	 * @shortdesc Set the amount that the phase will be offset by.
	 * 
	 * @param newPhase
	 * 			float: the phase offset value
	 * 
	 * @related phase
	 * @related Oscil
	 */
	public void setPhase(float newPhase)
	{
		phase.setLastValue( newPhase );
	}

	/**
	 * Changes the Waveform used by this Oscil.
	 * 
	 * @param theWaveform
	 *            the new Waveform to use
	 *            
	 * @example Basics/SynthesizeSound            
	 *            
	 * @related Waveform
	 * @related Oscil
	 */
	public void setWaveform(Waveform theWaveform)
	{
		wave = theWaveform;
	}
	
	/**
	 * Returns the Waveform currently being used by this Oscil.
	 * 
	 * @return a Waveform
	 * 
	 * @example Basics/SynthesizeSound
	 * 
	 * @related Waveform
	 * @related Oscil
	 */
	public Waveform getWaveform()
	{
		return wave;
	}

	/**
	 * Resets the time-step used by the Oscil to be equal to the current
	 * phase input value. You will typically use this when starting a new note with an
	 * Oscil that you have already used so that the waveform will begin sounding
	 * at the beginning of its period, which will typically be a zero-crossing.
	 * In other words, use this to prevent clicks when starting Oscils that have
	 * been used before.
	 * 
	 * @shortdesc Resets the time-step used by the Oscil to be equal to the current
	 * phase input value.
	 * 
	 * @example Synthesis/oscilPhaseExample
	 * 
	 * @related Oscil
	 */
	public void reset()
	{
		step = phase.getLastValue();
	}

	@Override
	protected void uGenerate(float[] channels)
	{
		// start with our base amplitude
		float outAmp = amplitude.getLastValue();

		// temporary step location with phase offset.
		float tmpStep = step + phase.getLastValue();
		// don't be less than zero
		if ( tmpStep < 0.f )
		{
			tmpStep -= (int)tmpStep - 1f;
		}
		// don't exceed 1.
		// we don't use Math.floor because that involves casting up
		// to a double and then back to a float.
		if ( tmpStep > 1.0f )
		{
			tmpStep -= (int)tmpStep;
		}

		// calculate the sample value
		float sample = outAmp * wave.value( tmpStep ) + offset.getLastValue();

		Arrays.fill( channels, sample );

		// update our step size.
		// this will check to make sure the frequency has changed.
		updateStepSize();

		// increase time
		// NOT THIS FROM BEFORE: step += stepSize + fPhase;
		step += stepSize;

		// don't be less than zero
		if ( step < 0.f )
		{
			step -= (int)step - 1f;
		}

		// don't exceed 1.
		// we don't use Math.floor because that involves casting up
		// to a double and then back to a float.
		if ( step > 1.0f )
		{
			step -= (int)step;
		}
	}
}
