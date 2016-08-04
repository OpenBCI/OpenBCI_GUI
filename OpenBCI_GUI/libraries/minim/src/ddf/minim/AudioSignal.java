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
 * If you want to write an audio generating class to work with Minim, you must
 * implement the <code>AudioSignal</code> interface. Your only responsibility
 * is to fill either a single float buffer or two float buffers with values in
 * the range of [-1, 1]. The <code>AudioOutput</code> to which you add your
 * signal will handle the mixing of multiple signals. There may be values in the
 * arrays when you receive them, left over from the previous signal in a
 * <code>SignalChain</code>, but you can disregard them (or use them if
 * you're feeling crazy like that).
 * 
 * @author Damien Di Fede
 * @invisible
 */
@Deprecated
public interface AudioSignal
{
  /**
   * Fills <code>signal</code> with values in the range of [-1, 1].
   * <code>signal</code> represents a mono audio signal.
   * 
   * @param signal
   *          the float array to fill
   */
  void generate(float[] signal);

  /**
   * Fills <code>left</code> and <code>right</code> with values in the range
   * of [-1, 1]. <code>left</code> represents the left channel of a stereo
   * signal, <code>right</code> represents the right channel of that same
   * stereo signal.
   * 
   * @param left
   *          the left channel
   * @param right
   *          the right channel
   */
  void generate(float[] left, float[] right);
}
