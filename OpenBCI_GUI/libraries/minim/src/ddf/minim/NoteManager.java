package ddf.minim;

import java.util.ArrayList;
import java.util.HashMap;

import ddf.minim.ugens.Instrument;

/**
 * 
 * @author ddf
 * @invisible
 */

public class NoteManager
{
	// we use this do our timing, basically
	private float sampleRate;
	private float tempo;
	private float noteOffset;
	private float durationFactor;
	private int   now;
	// our events are stored in a map.
	// the keys in this map are the "now" that the events should
	// occur at and the values are a list of events that occur
	// at that time.
	private HashMap<Integer, ArrayList<NoteEvent>> events;
	// are we paused?
	// pausing is important because if we're going to queue up 
	// a large number of notes, we want to make sure their timestamps
	// are accurate. this won't be possible if the note manager
	// is sending events because of ticks from the audio output.
	private boolean paused;
	
	private interface NoteEvent
	{
		void send();
	}
	
	private class NoteOnEvent implements NoteEvent
	{
		private Instrument instrument;
		private float duration;
		
		public NoteOnEvent(Instrument i, float dur)
		{
			instrument = i;
			duration = dur;
		}
		
		public void send()
		{
			instrument.noteOn(duration);
		}
	}
	
	private class NoteOffEvent implements NoteEvent
	{
		private Instrument instrument;
		
		public NoteOffEvent(Instrument i)
		{
			instrument = i;
		}
		
		public void send()
		{
			instrument.noteOff();
		}
	}
	
	public NoteManager( float sampleRate )
	{
		this.sampleRate = sampleRate;
		events = new HashMap<Integer, ArrayList<NoteEvent>>();
		tempo = 60f;
		noteOffset = 0.0f;
		durationFactor = 1.0f;
		now = 0;
		paused = false;
	}
	
	// events are always specified as happening some period of time from now.
	// but we store them as taking place at a specific time, rather than a relative time.
	public synchronized void addEvent(float startTime, float duration, Instrument instrument)
	{
		int on = now + (int)(sampleRate * ( startTime + noteOffset ) * 60f/tempo);
		Integer onAt = new Integer( on );
		
		float actualDuration = duration * durationFactor * 60f/tempo;
		
		if ( events.containsKey(onAt) )
		{
			ArrayList<NoteEvent> eventsAtOn = events.get(onAt);
			eventsAtOn.add( new NoteOnEvent(instrument, actualDuration) );
		}
		else
		{
			ArrayList<NoteEvent> eventsAtOn = new ArrayList<NoteEvent>();
			eventsAtOn.add( new NoteOnEvent(instrument, actualDuration) );
			events.put(onAt, eventsAtOn);
		}
		
		Integer offAt = new Integer( on + (int)(sampleRate * actualDuration) );
		
		if ( events.containsKey(offAt) )
		{
			ArrayList<NoteEvent> eventsAtOff = events.get(offAt);
			eventsAtOff.add( new NoteOffEvent(instrument) );
		}
		else
		{
			ArrayList<NoteEvent> eventsAtOff = new ArrayList<NoteEvent>();
			eventsAtOff.add( new NoteOffEvent(instrument) );
			events.put(offAt, eventsAtOff);
		}
		
	}
	
	public void setTempo(float tempo)
	{
		this.tempo = tempo;
	}
	
	public float getTempo()
	{
		return tempo;
	}
	
	public void setNoteOffset(float noteOffset)
	{
		this.noteOffset = noteOffset;
	}
	
	public float getNoteOffset()
	{
		return noteOffset;
	}
	
	public void setDurationFactor(float durationFactor)
	{
		this.durationFactor = durationFactor;
	}
	
	public float getDurationFactor()
	{
		return durationFactor;
	}
	
	public void pause()
	{
		paused = true;
	}
	
	public void resume()
	{
		paused = false;
	}
	
	synchronized public void tick()
	{
		if ( paused == false )
		{
			// find the events we should trigger now.
			Integer Now = new Integer(now);
			
			if ( events.containsKey(Now) )
			{
				ArrayList<NoteEvent> eventsToSend = events.get(Now);
				// ddf: change this to a for loop from an iterator so that
				// 		this list can be safely concurrently modified.
				for( int i = 0; i < eventsToSend.size(); ++i )
				{
					eventsToSend.get(i).send();
				}
				// remove this list because we've sent all the events
				events.remove(Now);
			}
			
			// increment our now
			++now;
		}
	}
}
