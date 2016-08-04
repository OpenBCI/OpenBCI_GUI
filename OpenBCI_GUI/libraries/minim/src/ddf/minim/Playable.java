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

/**
 * <code>Playable</code> defines functionality that you would expect from a tapedeck 
 * or CD player. Implementing classes are usually playing an audio file.
 *  
 * @author Damien Di Fede
 * @invisible
 *
 */
public interface Playable
{
  /**
   * Starts playback from the current position. 
   * If this was previously set to loop, looping will be disabled.
   * 
   */
  void play();
  
  /**
   * Starts playback <code>millis</code> from the beginning. 
   * If this was previously set to loop, looping will be disabled.
   * 
   * @param millis the position to start playing from
   */
  void play(int millis);
  
  /**
   * Returns true if this currently playing.
   * 
   * @return true if this is currently playing
   */
  boolean isPlaying();
  
  /**
   * Sets looping to continuous. If this is already playing, the position
   * <i>will not</i> be reset to the beginning. If this is not playing,
   * it will start playing.
   * 
   */
  void loop();
  
  /**
   * Sets this to loop <code>num</code> times. If this is already playing, 
   * the position <i>will not</i> be reset to the beginning. 
   * If this is not playing, it will start playing.
   * 
   * @param num
   *          the number of times to loop
   */
  void loop(int num);
  
  /**
   * Returns true if this is currently playing and has more than one loop 
   * left to play.
   * 
   * @return true if this is looping
   */
  boolean isLooping();
  
  /**
   * Returns the number of loops left to do. 
   * 
   * @return the number of loops left
   */
  int loopCount();
  
  /**
   * Sets the loop points used when looping.
   * 
   * @param start the start of the loop in milliseconds
   * @param stop the end of the loop in milliseconds
   */
  void setLoopPoints(int start, int stop);
    
  /**
   * Pauses playback.
   * 
   */
  void pause();
  
  /**
   * Sets the position to <code>millis</code> milliseconds from
   * the beginning. This will not change the playstate. If an error
   * occurs while trying to cue, the position will not change. 
   * If you try to cue to a negative position or try to a position 
   * that is greater than <code>length()</code>, the amount will be clamped 
   * to zero or <code>length()</code>.
   * 
   * @param millis the position to place the "playhead"
   */
  void cue(int millis);
  
  /**
   * Skips <code>millis</code> from the current position. <code>millis</code> 
   * can be negative, which will make this skip backwards. If the skip amount 
   * would result in a negative position or a position that is greater than 
   * <code>length()</code>, the new position will be clamped to zero or 
   * <code>length()</code>.
   * 
   * @param millis how many milliseconds to skip, sign indicates direction
   */
  void skip(int millis);
  
  /**
   * Rewinds to the beginning. This <i>does not</i> stop playback.
   * 
   */
  void rewind();
  
  /**
   * Returns the current position of the "playhead" (ie how much of
   * the sound has already been played)
   * 
   * @return the current position of the "playhead"
   */
  int position();
  
  /**
   * Returns the length of the sound in milliseconds. If for any reason the 
   * length could not be determined, this will return -1. However, an unknown 
   * length should not impact playback.
   * 
   * @return the length of the sound in milliseconds
   */
  int length();
  
  /**
   * Returns and <code>AudioMetaData</code> object that describes this audio. 
   * 
   * @see AudioMetaData
   * 
   * @return the <code>AudioMetaData</code> for this
   */
  AudioMetaData getMetaData();
}
