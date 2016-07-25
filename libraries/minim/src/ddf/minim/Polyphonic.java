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
 * <code>Polyphonic</code> describes an object that can have multiple
 * <code>AudioSignal</code>s attached to it. It is implemented by
 * {@link AudioOutput}.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */

public interface Polyphonic
{
  /**
   * Enables all signals currently attached to this. If you want to enable only
   * a single signal, use {@link #enableSignal(int)}.
   * 
   */
  void sound();

  /**
   * Disables all signals currently attached to this. If you want to disable
   * only a single signal, use {@link #disableSignal(int)}.
   * 
   */
  void noSound();

  /**
   * Returns true if at least one signal in the chain is enabled.
   * 
   * @return true if at least one signal in the signal chain is enabled
   */
  boolean isSounding();

  /**
   * Returns true if <code>signal</code> is in the chain and is also enabled.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to check the status of
   * @return true if <code>signal</code> is in the chain and is enabled
   */
  boolean isEnabled(AudioSignal signal);

  /**
   * Adds an signal to the signals chain.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to add
   */
  void addSignal(AudioSignal signal);

  /**
   * Returns the <code>i<sup>th</sup></code> signal in the signal chain.
   * This method is not required to do bounds checking and may throw an
   * ArrayOutOfBoundsException if <code>i</code> is larger than
   * {@link #signalCount()}.
   * 
   * @param i
   *          which signal to return
   * 
   * @return the requested signal
   */
  AudioSignal getSignal(int i);
  
  boolean hasSignal(AudioSignal signal);

  /**
   * Returns the number of signals in the chain.
   * 
   * @return the number of signals in the chain
   */
  int signalCount();

  /**
   * Enables the <code>i</code><sup>th</sup> signal in the signal chain.
   * 
   * @param i
   *          the index of the signal to enable
   */
  void enableSignal(int i);

  /**
   * Enables <code>signal</code> if it is in the chain.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to enable
   */
  void enableSignal(AudioSignal signal);

  /**
   * disables the <code>i</code><sup>th</sup> signal in the signal chain.
   * 
   * @param i
   *          the index of the signal to disable
   */
  void disableSignal(int i);

  /**
   * Disables <code>signal</code> if it is in the chain.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to disable
   */
  void disableSignal(AudioSignal signal);

  /**
   * Removes <code>signal</code> from the signals chain.
   * 
   * @param signal
   *          the AudioSignal to remove
   */
  void removeSignal(AudioSignal signal);

  /**
   * Removes and returns the <code>i<sup>th</sup></code> signal in the
   * signal chain.
   * 
   * @param i
   *          which signal to remove
   * @return the removed <code>AudioSignal</code>
   */
  AudioSignal removeSignal(int i);

  /**
   * Removes all signals from the signal chain.
   * 
   */
  void clearSignals();
}
