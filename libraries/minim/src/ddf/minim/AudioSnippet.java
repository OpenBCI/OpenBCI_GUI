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

import ddf.minim.spi.AudioRecording;

/**
 * <code>AudioSnippet</code> is a simple wrapper around a JavaSound
 * <code>Clip</code> (It isn't called AudioClip because that's an interface
 * defined in the package java.applet). It provides almost the exact same
 * functionality, the main difference being that length, position, and cue are
 * expressed in milliseconds instead of microseconds. You can obtain an
 * <code>AudioSnippet</code> by using {@link Minim#loadSnippet(String)}. One
 * of the limitations of <code>AudioSnippet</code> is that you do not have
 * access to the audio samples as they are played. However, you are spared all
 * of the overhead associated with making samples available. An
 * <code>AudioSnippet</code> is a good choice if all you need to do is play a
 * short sound at some point. If your aim is to repeatedly trigger a sound, you
 * should use an {@link AudioSample} instead.
 * 
 * @author Damien Di Fede
 */

/** @deprecated */
public class AudioSnippet extends Controller implements Playable
{
	private AudioRecording	recording;

	public AudioSnippet(AudioRecording rec)
	{
		super(rec.getControls());
		rec.open();
		recording = rec;
	}

	public void play()
	{
		recording.play();
	}

	public void play(int millis)
	{
		cue(millis);
		play();
	}

	public void pause()
	{
		recording.pause();
	}

	public void rewind()
	{
		cue(0);
	}

	public void loop()
	{
		recording.loop(Minim.LOOP_CONTINUOUSLY);
	}

	public void loop(int n)
	{
		recording.loop(n);
	}

	public int loopCount()
	{
		return recording.getLoopCount();
	}

	public int length()
	{
		return recording.getMillisecondLength();
	}

	public int position()
	{
		return recording.getMillisecondPosition();
	}

	public void cue(int millis)
	{
		if (millis < 0)
			millis = 0;
		if (millis > length())
			millis = length();
		recording.setMillisecondPosition(millis);
	}

	public void skip(int millis)
	{
		int pos = position() + millis;
		if (pos < 0)
			pos = 0;
		else if (pos > length())
			pos = length();
		recording.setMillisecondPosition(pos);
	}

	public boolean isLooping()
	{
		return recording.getLoopCount() != 0;
	}

	public boolean isPlaying()
	{
		return recording.isPlaying();
	}

	/**
	 * Closes the snippet so that any resources it is using can be released. This
	 * should be called when you are finished using this snippet.
	 * 
	 */
	public void close()
	{
		recording.close();
	}

	public AudioMetaData getMetaData()
	{
		return recording.getMetaData();
	}

	public void setLoopPoints(int start, int stop)
	{
		recording.setLoopPoints(start, stop);
	}
}
