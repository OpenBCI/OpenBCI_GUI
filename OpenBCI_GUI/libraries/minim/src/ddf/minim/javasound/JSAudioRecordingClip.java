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

package ddf.minim.javasound;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.Clip;
import javax.sound.sampled.Control;
import javax.sound.sampled.LineEvent;
import javax.sound.sampled.LineListener;

import ddf.minim.AudioMetaData;
import ddf.minim.MultiChannelBuffer;
import ddf.minim.spi.AudioRecording;

/** @deprecated */
class JSAudioRecordingClip implements AudioRecording
{
	private Clip			c;
	private int				loopCount;
	private AudioMetaData	meta;
	private boolean			playing;

	JSAudioRecordingClip(Clip clip, AudioMetaData mdata)
	{
		c = clip;
		// because Clip doesn't give access to the loop count
		// we just loop it ourselves by triggering off of a STOP event
		c.addLineListener( new LineListener()
		{
			public void update(LineEvent event)
			{
				if ( event.getType().equals( LineEvent.Type.STOP ) )
				{
					if ( playing && loopCount != 0 )
					{
						c.setMicrosecondPosition( 0 );
						c.start();
						if ( loopCount > 0 )
						{
							loopCount--;
						}
					}
					else
					{
						playing = false;
					}
				}
			}
		} );
		playing = false;
		loopCount = 0;
		meta = mdata;
	}

	public int getLoopCount()
	{
		return loopCount;
	}

	public int getMillisecondLength()
	{
		return (int)c.getMicrosecondLength() / 1000;
	}

	public int getMillisecondPosition()
	{
		return (int)c.getMicrosecondPosition() / 1000;
	}

	public AudioMetaData getMetaData()
	{
		return meta;
	}

	public boolean isPlaying()
	{
		return playing;
	}

	public void loop(int count)
	{
		play();
		loopCount = count;
	}

	public void setLoopPoints(int start, int end)
	{
		c.setLoopPoints( start, end );
	}

	public void setMillisecondPosition(int pos)
	{
		c.setMicrosecondPosition( pos * 1000 );
	}

	public void play()
	{
		if ( c.getMicrosecondPosition() != c.getMicrosecondLength() )
		{
			c.start();
			playing = true;
		}
	}

	public void pause()
	{
		c.stop();
		playing = false;
	}

	public void close()
	{
		c.close();
	}

	public Control[] getControls()
	{
		return c.getControls();
	}

	public AudioFormat getFormat()
	{
		return c.getFormat();
	}

	public void open()
	{
		// don't need to do anything here
	}

	public int bufferSize()
	{
		return 0;
	}

	public float[] read()
	{
		return null;
	}

	public int read(MultiChannelBuffer buffer)
	{
		return 0;
	}
}
