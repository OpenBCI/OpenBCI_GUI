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

import java.util.HashSet;
import java.util.Vector;

/**
 * An <code>EffectsChain</code> is a list of {@link AudioEffect AudioEffects} that 
 * gives you the ability to enable and disable effects, as you would in a typical 
 * DAW. When you add an effect, it is added to the end of the chain and is enabled.
 * When you remove an effect, effects further down the chain are moved up a slot. 
 * <code>EffectsChain</code> is itself an <code>AudioEffect</code>, so you can 
 * easily create groups of effects that can be enabled/disabled together by 
 * putting them in an <code>EffectsChain</code> and then adding that chain to 
 * an <code>Effectable</code> as a single effect. <code>EffectsChain</code> is 
 * fully <code>synchronized</code> so that it is not possible to add and remove 
 * effects while processing is taking place.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */
@Deprecated
public class EffectsChain implements AudioEffect
{
  // the effects in the order they were added
  private Vector<AudioEffect> effects;
  // all currently enabled effects
  private HashSet<AudioEffect> enabled;
  
  /**
   * Constructs an empty <code>EffectsChain</code>.
   *
   */
  public EffectsChain()
  {
    effects = new Vector<AudioEffect>();
    enabled = new HashSet<AudioEffect>();
  }
  
  /**
   * Adds <code>e</code> to the end of the chain.
   * 
   * @param e the <code>AudioEffect</code> to add
   */
  public synchronized void add(AudioEffect e)
  {
    effects.add(e);
    enabled.add(e);
  }

  /**
   * Removes <code>e</code> from the chain.
   * 
   * @param e the <code>AudioEffect</code> to remove
   */
  public synchronized void remove(AudioEffect e)
  {
    effects.remove(e);
    enabled.remove(e);
  }
  
  /**
   * Removes and returns the <code>i</code><sup>th</sup> effect from the chain.
   * 
   * @param i the index of the <code>AudioEffect</code> to remove
   * @return the <code>AudioEffect</code> that was removed
   */
  public synchronized AudioEffect remove(int i)
  {
    AudioEffect e = effects.remove(i);
    enabled.remove(e);
    return e;
  }
  
  /**
   * Gets the <code>i<sup>th</sup></code> effect in the chain.
   * 
   * @param i the index of the <code>AudioEffect</code> to get
   * 
   * @return the <code>i<sup>th</sup></code> effect in the chain.
   */
  public synchronized AudioEffect get(int i)
  {
    return effects.get(i);
  }
  
  /**
   * Returns true if <code>e</code> is in this chain
   * 
   * @param e the <code>AudioEffect</code> to check for
   * @return true if <code>e</code> is in this chain
   */
  public synchronized boolean contains(AudioEffect e)
  {
    return effects.contains(e);
  }
  
  /**
   * Enables the <code>i</code><sup>th</sup> effect in the chain.
   * 
   * @param i the index of the effect to enable
   */
  public synchronized void enable(int i)
  {
    enabled.add(get(i));
  }
  
  /**
   * Enables <code>e</code> if it is in the chain.
   * 
   * @param e the <code>AudioEffect</code> to enable
   */
  public synchronized void enable(AudioEffect e)
  {
    if ( effects.contains(e) )
    {
      enabled.add(e);
    }
  }
  
  /**
   * Enables all effects in the chain.
   *
   */
  public synchronized void enableAll()
  {
    enabled.addAll(effects);
  }
  
  /**
   * Returns true if at least one effect in the chain is enabled.
   * 
   * @return true if at least one effect in the chain is enabled
   */
  public synchronized boolean hasEnabled()
  {
    return enabled.size() > 0;
  }
  
  /**
   * Returns true if <code>e</code> is in the chain and is enabled.
   * 
   * @param e the <code>AudioEffect</code> to return the status of
   * @return true if <code>e</code> is enabled and in the chain
   */
  public synchronized boolean isEnabled(AudioEffect e)
  {
    return enabled.contains(e);
  }
  
  /**
   * Disables the <code>i</code><sup>th</sup> effect in the chain.
   * 
   * @param i the index of the effect to disable
   */
  public synchronized void disable(int i)
  {
    enabled.remove(get(i));
  }
  
  /**
   * Disables <code>e</code> if it is in the chain.
   * 
   * @param e the <code>AudioEffect</code> to disable
   */
  public synchronized void disable(AudioEffect e)
  {
    enabled.remove(e);
  }
  
  /**
   * Disables all effects in the chain.
   *
   */
  public synchronized void disableAll()
  {
    enabled.clear();
  }  
  
  /**
   * Returns the number of effects in the chain.
   * 
   * @return the number of effects in the chain
   */
  public synchronized int size()
  {
    return effects.size();
  }
  
  /**
   * Removes all effects from the effect chain.
   *
   */
  public synchronized void clear()
  {
    effects.clear();
    enabled.clear();
  }
  
  /**
   * Sends <code>samp</code> to each effect in the chain, in order. 
   * 
   * @param samp the samples to process
   */
  public synchronized void process(float[] samp)
  {
    for (int i = 0; i < effects.size(); i++)
    {
      AudioEffect e = effects.get(i);
      if ( enabled.contains(e) )
      {
        e.process(samp);
      }
    }  
  }
  
  /**
   * Sends <code>sampL</code> and <code>sampR</code> to each effect 
   * in the chain, in order. The two float arrays should correspond to 
   * the left and right channels of a stereo signal.
   * 
   * @param sampL the left channel of the signal to process
   * @param sampR the right channel of the signal to process
   */
  public synchronized void process(float[] sampL, float[] sampR)
  {
    for (int i = 0; i < effects.size(); i++)
    {
      AudioEffect e = effects.get(i);
      if ( enabled.contains(e) )
      {
        e.process(sampL, sampR);
      }
    } 
  }
}
