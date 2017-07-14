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
 * An <code>Effectable</code> object is simply one that can have
 * <code>AudioEffect</code>s attached to it. As with an audio track in a
 * typical DAW, you can enable and disable the effects on an
 * <code>Effectable</code> without having to remove them from the object.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */
public interface Effectable
{
  /**
   * Enables all effects currently attached to this. If you want to enable only
   * a single effect, use {@link #enableEffect(int)}.
   * 
   */
  void effects();

  /**
   * Disables all effects currently attached to this. If you want to disable
   * only a single effect, use {@link #disableEffect(int)}.
   * 
   */
  void noEffects();

  /**
   * Returns true if at least one effect in the chain is enabled.
   * 
   * @return true if at least one effect in the effects chain is enabled
   */
  boolean isEffected();

  /**
   * Returns true if <code>effect</code> is in the chain and is also enabled.
   * 
   * @param effect
   *          the <code>AudioEffect</code> to check the status of
   * @return true if <code>effect</code> is in the chain and is enabled
   */
  boolean isEnabled(AudioEffect effect);

  /**
   * Adds an effect to the effects chain.
   * 
   * @param effect
   *          the AudioEffect to add
   */
  void addEffect(AudioEffect effect);

  /**
   * Returns the <code>i<sup>th</sup></code> effect in the effect chain.
   * This method is not required to do bounds checking and may throw an
   * ArrayOutOfBoundsException if <code>i</code> is larger than
   * {@link #effectCount()}.
   * 
   * @param i
   *          which effect to return
   * 
   * @return the requested effect
   */
  AudioEffect getEffect(int i);

  /**
   * Returns the number of effects in the chain.
   * 
   * @return the number of effects in the chain
   */
  int effectCount();
  
  /**
   * Returns true if <code>effect</code> is in the chain.
   * 
   * @param effect the effec to check for
   * @return true if <code>effect</code> is attached to this
   */
  boolean hasEffect(AudioEffect effect);

  /**
   * Enables the <code>i</code><sup>th</sup> effect in the effect chain.
   * 
   * @param i
   *          the index of the effect to enable
   */
  void enableEffect(int i);

  /**
   * Enables <code>effect</code> if it is in the chain.
   * 
   * @param effect
   *          the <code>AudioEffect</code> to enable
   */
  void enableEffect(AudioEffect effect);

  /**
   * disables the <code>i</code><sup>th</sup> effect in the effect chain.
   * 
   * @param i
   *          the index of the effect to disable
   */
  void disableEffect(int i);

  /**
   * Disables <code>effect</code> if it is in the chain.
   * 
   * @param effect
   *          the <code>AudioEffect</code> to disable
   */
  void disableEffect(AudioEffect effect);

  /**
   * Removes <code>effect</code> from the effects chain.
   * 
   * @param effect
   *          the AudioEffect to remove
   */
  void removeEffect(AudioEffect effect);

  /**
   * Removes and returns the <code>i<sup>th</sup></code> effect in the
   * effect chain.
   * 
   * @param i
   *          which effect to remove
   * @return the removed <code>AudioEffect</code>
   */
  AudioEffect removeEffect(int i);

  /**
   * Removes all effects from the effect chain.
   * 
   */
  void clearEffects();
}
