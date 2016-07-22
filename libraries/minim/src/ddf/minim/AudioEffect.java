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
 * An <code>AudioEffect</code> is anything that can process one or two float
 * arrays. Typically it is going to be some kind of time-based process because
 * the float arrays passed to it will be consecutive chunks of audio data. The
 * effect is expected to modify these arrays in such a way that the values
 * remain in the range [-1, 1]. All of the effects included with Minim implement
 * this interface and all you need to do to write your own effects is to create
 * a class that implements this interface and then add an instance of it to an
 * anything that is <code>Effectable</code>, such as an <code>AudioOutput</code>.
 * <p>
 * This interface is Deprecated and will likely be removed from a future version 
 * of Minim. We now recommend implementing your effects by extending <code>UGen</code>.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */

@Deprecated
public interface AudioEffect
{ 
  /**
   * Processes <code>signal</code> in some way.
   * 
   * @param signal
   *          an array of audio samples, representing a mono sound stream.
   */
  void process(float[] signal);

  /**
   * Processes <code>sigLeft</code> and <code>sigRight</code> in some way.
   * 
   * @param sigLeft
   *          an array of audio samples, representing the left channel of a
   *          stereo sound stream
   * @param sigRight
   *          an array of audio samples, representing the right channel of a
   *          stereo sound stream
   */
  void process(float[] sigLeft, float[] sigRight);
}
