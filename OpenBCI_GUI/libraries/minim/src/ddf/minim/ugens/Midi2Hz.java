package ddf.minim.ugens;

import java.util.Arrays;

import ddf.minim.UGen;

/**
 * Midi2Hz is a UGen that will convert a MIDI note number to a frequency in
 * Hertz. This is useful if you want to drive the frequency input of an Oscil
 * with something that generates MIDI notes.
 * 
 * @example Synthesis/midiFreqKeyboardExample
 * 
 * @author Anderson Mills
 * 
 */

public class Midi2Hz extends UGen 
{
	/**
	 * Patch something to this input that generates MIDI note numbers 
	 * (values in the range [0,127])
	 * 
	 * @related Midi2Hz
	 * @related UGen.UGenInput
	 */
	public UGenInput midiNoteIn;

	/**
	 * Construct a Midi2Hz that generates a fixed value from MIDI note 0.
	 * 
	 */
	public Midi2Hz() 
	{
		this(0.0f);
	}

	/**
	 * Construct a Midi2Hz that generates a fixed value from fixedMidiNoteIn.
	 * 
	 * @param fixedMidiNoteIn
	 *            float: the MIDI note to convert to Hz (values in the range [0,127])
	 */
	public Midi2Hz(float fixedMidiNoteIn) 
	{
		super();
		// jam3: These can't be instantiated until the uGenInputs ArrayList
		// in the super UGen has been constructed
		// audio = new UGenInput(InputType.AUDIO);
		midiNoteIn = new UGenInput(InputType.CONTROL);
		midiNoteIn.setLastValue(fixedMidiNoteIn);
	}

	/**
	 * Set the fixed value this will use if midiNoteIn is not patched.
	 * 
	 * @param fixedMidiNoteIn
	 * 			float: the MIDI note to convert to Hz (values in the range [0,127])
	 * 
	 * @related midiNoteIn
	 * @related Midi2Hz
	 */
	public void setMidiNoteIn(float fixedMidiNoteIn) 
	{
		midiNoteIn.setLastValue(fixedMidiNoteIn);
	}

	@Override
	protected void uGenerate(float[] channels) 
	{
		Arrays.fill( channels, Frequency.ofMidiNote(midiNoteIn.getLastValue()).asHz() );
	}
}