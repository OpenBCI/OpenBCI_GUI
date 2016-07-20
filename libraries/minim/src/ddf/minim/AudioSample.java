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

/**
 * An <code>AudioSample</code> keeps the entire file in an internal buffer and
 * all you can do is <code>trigger()</code> the sound. However, you can trigger
 * the sound even if it is still playing back. It is not advised that you use
 * this class for long sounds (like entire songs, for example) because the
 * entire file is kept in memory.
 * <p>
 * To create an AudioSample you must use either the loadSample or createSample 
 * methods of the Minim class.
 * <p>
 * AudioSample also provides most of the same methods as AudioPlayer for
 * controlling volume, panning, and so forth.
 * <p>
 * We now recommend using <code>Sampler</code> class from the ugens package because it is more
 * full-featured than <code>AudioSample</code>.
 * 
 * @example Basics/TriggerASample
 * 
 * @related Minim
 * 
 * @author Damien Di Fede
 * 
 */

// TODO: some kind of event for when a sample finishes playing?

public abstract class AudioSample extends AudioSource
{
	/**
	 * int used to request the left channel of audio from the getChannel method.
	 * 
	 * @related getChannel ( )
	 * @related AudioSample
	 */
	static public final int	LEFT	= 1;
	
	/**
	 * int used to request the right channel of audio from the getChannel method.
	 * 
	 * @related getChannel ( )
	 * @related AudioSample
	 */
	static public final int	RIGHT	= 2;

	protected AudioSample(AudioOut output)
	{
		super( output );
	}

	/**
	 * Get the AudioMetaData for this sample. This will mostly be useful if you
	 * have created an AudioSample from an mp3 file and want to get at some of
	 * the most common ID3 tags.
	 * 
	 * @shortdesc Get the AudioMetaData for this sample.
	 * 
	 * @example Basics/GetMetaData
	 * 
	 * @return the AudioMetaData for the sample.
	 * 
	 * @related AudioMetaData
	 * @related AudioSample
	 */
	public abstract AudioMetaData getMetaData();

	/**
	 * Gets the samples for the requested channel number as a float array. 
	 * Use either AudioSample.LEFT or AudioSample.RIGHT.
	 * 
	 * @example Advanced/AudioSampleGetChannel
	 * 
	 * @param channelNumber
	 *            int: the channel you want the samples for
	 *            
	 * @return float[]: the samples in the specified channel
	 * 
	 * @related AudioSample
	 */
	public abstract float[] getChannel(int channelNumber);

	/**
	 * Gets the length in milliseconds of this AudioSample.
	 * 
	 * @return int: the length in milliseconds
	 * 
	 * @related AudioSample
	 */
	public abstract int length();

	/**
	 * Triggers the sound to play once. Can be called again before the sound
	 * finishes playing.
	 * 
	 * @example Basics/TriggerASample
	 * 
	 * @related AudioSample
	 */
	public abstract void trigger();

	/**
	 * Stops all sound being produced by this AudioSample.
	 * 
	 * @related AudioSample
	 */
	public abstract void stop();
}
