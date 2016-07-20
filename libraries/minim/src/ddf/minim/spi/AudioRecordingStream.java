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

package ddf.minim.spi;

import ddf.minim.AudioMetaData;


public interface AudioRecordingStream extends AudioStream
{
	/**
	 * Allows playback/reads of the source. 
	 * 
	 */
	void play();

	/**
	 * Disallows playback/reads of the source. If this is pause, all calls to read 
	 * will generate arrays full of zeros (silence).
	 * 
	 */
	void pause();

	boolean isPlaying();

	/**
	 * Starts looping playback from the loop start point. Playback will continue
	 * to the loop's end point, then loop back to the loop start point count
	 * times.
	 * 
	 * A count value of 0 indicates that the section indicated by the loop start 
	 * point and loop end point should play 1 time. The behavior is undefined
	 * when this method is invoked with any other value during a loop operation.
	 * 
	 * If playback is stopped during looping, the current loop status is cleared;
	 * the behavior of subsequent loop and start requests is not affected by an
	 * interrupted loop operation.
	 * 
	 * @param count
	 *           the number of times playback should loop back from the loop's
	 *           end position to the loop's start position, or
	 *           Minim.LOOP_CONTINUOUSLY to indicate that looping should continue
	 *           until interrupted
	 */
	void loop(int count);

	/**
	 * Sets the loops points in the source, in milliseconds
	 * 
	 * @param start
	 *           the position of the beginning of the loop
	 * @param stop
	 *           the position of the end of the loop
	 */
	void setLoopPoints(int start, int stop);

	/**
	 * How many loops are left to go. 0 means this isn't looping and -1 means
	 * that it is looping continuously.
	 * 
	 * @return how many loops left
	 */
	int getLoopCount();

	/**
	 * Gets the current millisecond position of the source.
	 * 
	 * @return the current position, in milliseconds in the source
	 */
	int getMillisecondPosition();

	/**
	 * Sets the current millisecond position of the source.
	 * 
	 * @param pos
	 *           the position to cue the stream to
	 */
	void setMillisecondPosition(int pos);

	/**
	 * Returns the length of the source in milliseconds. Infinite sources, such
	 * as internet radio streams, should return -1.
	 * 
	 * @return the length of the source, in milliseconds
	 */
	int getMillisecondLength();
	
	/**
	 * Returns how many sample frames are in this recording. Infinite sources,
	 * such as internet radio streams, should return -1.
	 * 
	 * @return the length of the source, in sample frames
	 */
	long getSampleFrameLength();

	/**
	 * Returns meta data about the recording, such as duration, name, ID3 tags
	 * perhaps.
	 * 
	 * @return the MetaData of the recording
	 */
	AudioMetaData getMetaData();

}
