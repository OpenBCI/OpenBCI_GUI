/*
 *  Copyright (c) 2007 - 2008 by Damien Di Fede <ddf@compartmental.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

package ddf.minim;

import ddf.minim.spi.AudioOut;
import ddf.minim.ugens.DefaultInstrument;
import ddf.minim.ugens.Frequency;
import ddf.minim.ugens.Instrument;
import ddf.minim.ugens.Summer;

/**
 * <p>
 * An AudioOutput is a connection to the output of a computer's sound card. 
 * Typically the computer speakers are connected to this. 
 * You can use an AudioOutput to do real-time sound synthesis by patching 
 * UGens to an output object. You can get an AudioOutput object from Minim 
 * using one of five methods:
 * </p>
 * <pre>
 * AudioOutput getLineOut()
 * 
 * // specifiy either Minim.MONO or Minim.STEREO for type
 * AudioOutput getLineOut(int type)
 * 
 * // bufferSize is the size of the left, right,
 * // and mix buffers of the output you get back
 * AudioOutput getLineOut(int type, int bufferSize)
 * 
 * // sampleRate is a request for an output of a certain sample rate
 * AudioOutput getLineOut(int type, int bufferSize, float sampleRate)
 * 
 * // bitDepth is a request for an output with a certain bit depth
 * AudioInput getLineOut(int type, int bufferSize, float sampleRate, int bitDepth)
 * </pre>
 * <p>
 * In the event that an output doesn't exist with the requested parameters, 
 * Minim will spit out an error and return null. 
 * In general, you will want to use one of the first two methods listed above.
 * </p>
 * <p>
 * In addition to directly patching UGens to the output, you can also schedule 
 * "notes" to be played by the output at some time in the future. This can 
 * be very powerful when writing algorithmic music and sound. See the playNote
 * method for more information.
 * </p>
 * 
 * @author Damien Di Fede
 * @related Minim
 * @related UGen
 * @related playNote ( )
 * 
 * @example Basics/SynthesizeSound
 * @example Basics/SequenceSound
 */
public class AudioOutput extends AudioSource implements Polyphonic
{
	// the synth attach our signals to
	private AudioOut	synth;
	// the signals added by the user
	private SignalChain	signals;
	// the note manager for this output
	private NoteManager	noteManager;
	// the Bus for UGens used by this output
	Summer bus;

	private class SampleGenerator implements AudioSignal
	{
		public void generate(float[] signal)
		{
			if ( signals.size() > 0 )
			{
				signals.generate( signal );
			}

			float[] tick = new float[1];
			for ( int i = 0; i < signal.length; ++i )
			{
				noteManager.tick();
				bus.tick( tick );
				signal[i] += tick[0];
			}
		}

		public void generate(float[] left, float[] right)
		{
			if ( signals.size() > 0 )
			{
				signals.generate( left, right );
			}

			float[] tick = new float[2];
			for ( int i = 0; i < left.length; ++i )
			{
				noteManager.tick();
				bus.tick( tick );
				left[i] += tick[0];
				right[i] += tick[1];
			}
		}
	}

	/**
	 * Constructs an <code>AudioOutput</code> that will use <code>out</code> 
	 * to generate sound.
	 * 
	 * @param out
	 *            the <code>AudioOut</code> that does most of our work
	 *            
	 * @invisible
	 */
	public AudioOutput(AudioOut out)
	{
		super( out );
		synth = out;
		signals = new SignalChain();
		noteManager = new NoteManager( getFormat().getSampleRate() );
		bus = new Summer();
		// configure it
		bus.setSampleRate( getFormat().getSampleRate() );
		bus.setChannelCount( getFormat().getChannels() );

		synth.setAudioSignal( new SampleGenerator() );
	}

	/** @deprecated */
	public void addSignal(AudioSignal signal)
	{
		signals.add( signal );
	}

	/** @deprecated */
	public AudioSignal getSignal(int i)
	{
		// get i+1 because the bus is signal 0.
		return signals.get( i );
	}

	/** @deprecated */
	public void removeSignal(AudioSignal signal)
	{
		signals.remove( signal );
	}

	/** @deprecated */
	public AudioSignal removeSignal(int i)
	{
		// remove i+1 because the bus is 1
		return signals.remove( i );
	}

	/** @deprecated */
	public void clearSignals()
	{
		signals.clear();
	}

	/** @deprecated */
	public void disableSignal(int i)
	{
		// disable i+1 because the bus is 0
		signals.disable( i );
	}

	/** @deprecated */
	public void disableSignal(AudioSignal signal)
	{
		signals.disable( signal );
	}

	/** @deprecated */
	public void enableSignal(int i)
	{
		signals.enable( i );
	}

	/** @deprecated */
	public void enableSignal(AudioSignal signal)
	{
		signals.enable( signal );
	}

	/** @deprecated */
	public boolean isEnabled(AudioSignal signal)
	{
		return signals.isEnabled( signal );
	}

	/** @deprecated */
	public boolean isSounding()
	{
		for ( int i = 1; i < signals.size(); i++ )
		{
			if ( signals.isEnabled( signals.get( i ) ) )
			{
				return true;
			}
		}
		return false;
	}

	/** @deprecated */
	public void noSound()
	{
		for ( int i = 1; i < signals.size(); i++ )
		{
			signals.disable( i );
		}
	}

	/** @deprecated */
	public int signalCount()
	{
		return signals.size();
	}

	/** @deprecated */
	public void sound()
	{
		for ( int i = 1; i < signals.size(); i++ )
		{
			signals.enable( i );
		}
	}

	/** @deprecated */
	public boolean hasSignal(AudioSignal signal)
	{
		return signals.contains( signal );
	}

	/**
	 * playNote is a method of scheduling a "note" to be played at 
	 * some time in the future (or immediately), where a "note" is 
	 * an instance of a class that implements the Instrument interface.
	 * The Instrument interface requires you to implement a noteOn method 
	 * that accepts a float duration value and is called when that 
	 * Instrument should begin making sound, and a noteOff method 
	 * that is called when that Instrument should stop making sound.
	 * <p>
	 * Versions of playNote that do not have an Instrument argument
	 * will create an instance of a default Instrument that plays a
	 * sine tone based on the parameters passed in.
	 * <p>
	 * To facilitate writing algorithmic music, the start time and 
	 * duration of a note is expressed in <em>beats</em> and not in seconds. 
	 * By default, the tempo of an AudioOutput will be 60 BPM (beats per minute), 
	 * which means that beats are equivalent to seconds. If you want to think 
	 * in seconds when writing your note playing code, then simply don't change 
	 * the tempo of the output.
	 * <p>
	 * Another thing to keep in mind is that the AudioOutput processes its 
	 * note queue in its own Thread, so if you are going to queue up a lot of 
	 * notes at once you will want to use the pauseNotes method before queuing
	 * them. If you don't, the timing will be slightly off because the "now" that
	 * the start time of each note is an offset from will change from note to note.
	 * Once all of your notes have been added, you call resumeNotes to allow 
	 * the AudioOutput to process notes again.
	 * 
	 * @related Instrument
	 * @related setTempo ( )
	 * @related setNoteOffset ( )
	 * @related setDurationFactor ( )
	 * @related pauseNotes ( )
	 * @related resumeNotes ( )
	 * 
	 * @example Basics/SequenceSound
	 *  
	 * @shortdesc Schedule a "note" to played by the output. 
	 * 
	 * @param startTime
	 * 			float: when the note should begin playing, in beats
	 * @param duration
	 * 			float: how long the note should be, in beats
	 * @param instrument
	 * 			the Instrument that will play the note
	 */
	public void playNote(float startTime, float duration, Instrument instrument)
	{
		noteManager.addEvent( startTime, duration, instrument );
	}

	/**
	 * Schedule a "note" to played by the output that uses the default Instrument.
	 * 
	 * @see #playNote(float, float, Instrument)
	 * 
	 * @param startTime
	 * 		float: when the note should begin playing, in beats
	 * @param duration
	 * 		float: how long the note should be, in beats
	 * @param hz
	 * 		float: the frequency, in Hertz, of the note to be played
	 */
	public void playNote(float startTime, float duration, float hz)
	{
		noteManager.addEvent( startTime, duration, new DefaultInstrument( hz, this ) );
	}

	/**
	 * Schedule a "note" to played by the output that uses the default Instrument.
	 * 
	 * @see #playNote(float, float, Instrument)
	 * 
	 * @param startTime
	 * 		float: when the note should begin playing, in beats
	 * @param duration
	 * 		float: how long the note should be, in beats
	 * @param pitchName
	 * 		String: the pitch name of the note to be played (e.g. "A4" or "Bb3")
	 */
	public void playNote(float startTime, float duration, String pitchName)
	{
		noteManager.addEvent( startTime, duration, new DefaultInstrument( Frequency.ofPitch( pitchName ).asHz(), this ) );
	}

	/**
	 * Schedule a "note" to played by the output that uses the default Instrument and has a duration of 1 beat.
	 * 
	 * @see #playNote(float, float, Instrument)
	 * 
	 * @param startTime
	 * 		float: when the note should begin playing, in beats
	 * @param hz
	 * 		float: the frequency, in Hertz, of the note to be played
	 */
	public void playNote(float startTime, float hz)
	{
		noteManager.addEvent( startTime, 1.0f, new DefaultInstrument( hz, this ) );
	}

	/**
	 * Schedule a "note" to played by the output that uses the default Instrument and has a duration of 1 beat.
	 * 
	 * @see #playNote(float, float, Instrument)
	 * 
	 * @param startTime
	 * 		float: when the note should begin playing, in beats
	 * @param pitchName
	 * 		String: the pitch name of the note to be played (e.g. "A4" or "Bb3")
	 */
	public void playNote(float startTime, String pitchName)
	{
		noteManager.addEvent( startTime, 1.0f, new DefaultInstrument( Frequency.ofPitch( pitchName ).asHz(), this ) );
	}

	/**
	 * Schedule a "note" to played by the output that uses the default Instrument, has a duration of 1 beat,
	 * and is played immediately.
	 * 
	 * @see #playNote(float, float, Instrument)
	 * 
	 * @param hz
	 * 		float: the frequency, in Hertz, of the note to be played
	 */
	public void playNote(float hz)
	{
		noteManager.addEvent( 0.0f, 1.0f, new DefaultInstrument( hz, this ) );
	}
	
	/**
	 * Schedule a "note" to played by the output that uses the default Instrument,
	 * has a duration of 1 beat, and is played immediately.
	 * 
	 * @see #playNote(float, float, Instrument)
	 * 
	 * @param pitchName
	 * 		String: the pitch name of the note to be played (e.g. "A4" or "Bb3")
	 */	
	public void playNote(String pitchName)
	{
		noteManager.addEvent( 0.0f, 1.0f, new DefaultInstrument( Frequency.ofPitch( pitchName ).asHz(), this ) );
	}

	/**
	 * Schedule a "note" to played by the output that uses the default Instrument,
	 * has a duration of 1 beat, is played immediately, and has a pitch of "A4".
	 * This is good to use if you just want to generate some test tones.
	 * 
	 * @see #playNote(float, float, Instrument)
	 */
	public void playNote()
	{
		noteManager.addEvent( 0.0f, 1.0f, new DefaultInstrument( Frequency.ofPitch( "" ).asHz(), this ) );
	}

	/**
	 * The tempo of an AudioOutput controls how it will interpret the start time and duration 
	 * arguments of playNote methods. By default the tempo of an AudioOutput is 60 BPM (beats per minute),
	 * which means that one beat lasts one second. Setting the tempo to 120 BPM means that one beat lasts 
	 * half of a second. When the tempo is changed, it will only effect playNote calls made 
	 * <em>after</em> the change. 
	 * 
	 * @shortdesc Set the tempo of the AudioOutput to change the meaning of start times and durations for notes.
	 * 
	 * @example Basics/SequenceSound
	 * 
	 * @param tempo
	 * 		float: the new tempo for the AudioOutput, in BPM (beats per minute)
	 * 
	 * @related getTempo ( )
	 */
	public void setTempo(float tempo)
	{
		noteManager.setTempo( tempo );
	}
	
	/**
	 * Return the current tempo of the AudioOuput. 
	 * Tempo is expressed in BPM (beats per minute).
	 * 
	 * @return float: the current tempo
	 * 
	 * @example Basics/SequenceSound
	 * 
	 * @related setTempo ( )
	 */
	public float getTempo()
	{
		return noteManager.getTempo();
	}

	/**
	 * When writing out musical scores in code, it is often nice to think about 
	 * music in sections, where all of the playNote calls have start times relative to
	 * the beginning of the section. The setNoteOffset method facilitates this by
	 * letting you set a time from which all start times passed to playNote calls 
	 * will add on to. So, if you set the note offset to 16, that means all playNote 
	 * start times will be relative to the 16th beat from "now".
	 * <p>
	 * By default, note offset is 0.
	 * 
	 * @shortdesc Sets the amount of time added to all start times passed to playNote calls.
	 * 
	 * @param noteOffset
	 * 			float: the amount of time added to all start times passed to playNote calls.
	 * 
	 * @example Basics/SequenceSound
	 * 
	 * @related getNoteOffset ( )
	 */
	public void setNoteOffset(float noteOffset)
	{
		noteManager.setNoteOffset( noteOffset );
	}
	
	/**
	 * Return the current value of the note offset for this output.
	 * 
	 * @return float: the current note offset
	 * 
	 * @example Basics/SequenceSound
	 * 
	 * @related setNoteOffset ( )
	 */
	public float getNoteOffset()
	{
		return noteManager.getNoteOffset();
	}

	/**
	 * The duration factor of an AudioOutput defines how durations passed to playNote calls 
	 * are scaled before being queued. If your duration factor is 0.5 and you queue a note 
	 * with a duration of 2, the actual duration will become 1. This might be useful if 
	 * you want to queue a string of notes first with long durations and then very short durations.
	 * <p>
	 * By default the duration factor is 1.
	 * 
	 * @shortdesc Sets a factor that will scale durations passed to subsequent playNote calls.
	 * 
	 * @param durationFactor
	 * 			float: the duration factor
	 * 
	 * @related getDurationFactor ( )
	 */
	public void setDurationFactor(float durationFactor)
	{
		noteManager.setDurationFactor( durationFactor );
	}
	
	/**
	 * Return the current value of the duration factor for this output.
	 * 
	 * @return float: the current duration factor
	 * 
	 * @related setDurationFactor ( )
	 */
	public float getDurationFactor()
	{
		return noteManager.getDurationFactor();
	}

	/**
	 * An AudioOutput processes its note queue in its own Thread, 
	 * so if you are going to queue up a lot of notes at once 
	 * you will want to use the <code>pauseNotes</code> method before queuing
	 * them. If you don't, the timing will be slightly off because the "now" that
	 * the start time of each note is an offset from will change from note to note.
	 * Once all of your notes have been added, you call <code>resumeNotes</code> to allow 
	 * the AudioOutput to process notes again.
	 * 
	 * @shortdesc pause note processing
	 * 
	 * @example Basics/SequenceSound
	 * 
	 * @related resumeNotes ( )
	 */
	public void pauseNotes()
	{
		noteManager.pause();
	}

	/**
	 * Resume note processing.
	 * 
	 * @example Basics/SequenceSound
	 * 
	 * @see 	#pauseNotes()
	 * @related pauseNotes ( )
	 */
	public void resumeNotes()
	{
		noteManager.resume();
	}

}
