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

import javax.sound.sampled.AudioFormat;

/** @invisible
 * 
 * A <code>Recordable</code> object is one that can provide a program with 
 * floating point samples of the audio passing through it. It does this using 
 * <code>AudioListener</code>s. You add listeners to the <code>Recordable</code> and 
 * then the <code>Recordable</code> will call the appropriate <code>samples</code> 
 * method of all its listeners when it has a new buffer of samples. It is also 
 * possible to query a <code>Recordable</code> object for its buffer size, type 
 * (mono or stereo), and audio format. 
 * 
 * @author Damien Di Fede
 *
 */
public interface Recordable
{
  /**
   * Adds a listener who will be notified each time this receives 
   * or creates a new buffer of samples. If the listener has already 
   * been added, it will not be added again.
   * 
   * @example Advanced/AddAndRemoveAudioListener
   * 
   * @param listener the listener to add
   */
  void addListener(AudioListener listener);
  
  /**
   * Removes the listener from the list of listeners.
   * 
   * @example Advanced/AddAndRemoveAudioListener
   * 
   * @param listener the listener to remove
   */
  void removeListener(AudioListener listener);
    
  /**
   * Returns the format of this recordable audio.
   * 
   * @return the format of the audio
   */
  AudioFormat getFormat();
  
  /**
   * Returns either Minim.MONO or Minim.STEREO
   * 
   * @return Minim.MONO if this is mono, Minim.STEREO if this is stereo
   */
  int type();
  
  /**
   * Returns the buffer size being used by this.
   * 
   * @return the buffer size
   */
  int bufferSize();
  
  /**
   * Returns the sample rate of the audio.
   * 
   * @return the sample rate of the audio
   */
  float sampleRate();
}
