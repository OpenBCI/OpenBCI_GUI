package ddf.minim.ugens;

/**
 * The Instrument interface is expected by AudioOutput.playNote. You can create
 * your own instruments by implementing this interface in one of your classes.
 * Typically, you will create a class that constructs a UGen chain: an Oscil
 * patched to a filter patched to an ADSR. When noteOn is called you will patch
 * the end of your chain to the AudioOutput you are using and when noteOff is
 * called you will unpatch.
 * 
 * @example Basics/CreateAnInstrument
 * 
 * @author Damien Di Fede
 * 
 */
public interface Instrument
{
	/**
	 * Start playing a note. 
	 * This is called by AudioOutput when this Instrument's
	 * note should begin, based on the values passed to playNote.
	 * Typically you will patch your UGen chain to your AudioOutput here.
	 * 
	 * @shortdesc Start playing a note.
	 * 
	 * @param duration
	 *            float: how long the note will last 
	 *            (i.e. noteOff will be called after this many seconds)
	 * 
	 * @example Basics/CreateAnInstrument
	 * 
	 * @related Instrument
	 * @related noteOff ( )
	 */
	void noteOn(float duration);

	/**
	 * Stop playing a note. 
	 * This is called by AudioOuput when this Instrument's 
	 * note should end, based on the values passed to playNote.
	 * Typically you will unpatch your UGen chain from your AudioOutput here.
	 * 
	 * @shortdesc Stop playing a note.
	 * 
	 * @example Basics/CreateAnInstrument
	 * 
	 * @related Instrument
	 * @related noteOn ( )
	 */
	void noteOff();
}
