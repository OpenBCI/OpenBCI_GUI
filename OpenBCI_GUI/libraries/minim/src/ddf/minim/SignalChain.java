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
 * An <code>SignalChain</code> is a list of {@link AudioSignal AudioSignals}
 * that gives you the ability to enable (unmute) and disable (mute) signals.
 * When you add a signal, it is added to the end of the chain and is enabled.
 * When you remove a signal, signals further down the chain are moved up a slot.
 * <code>SignalChain</code> is itself an <code>AudioSignal</code>, so you
 * can easily create groups of signals that can be enabled/disabled together by
 * putting them in an <code>SignalChain</code> and then adding that chain to a
 * <code>Polyphonic</code> object as a single signal. When the signal chain is
 * asked to generate a signal, it asks each of its signals to generate audio and
 * then mixes all of the signals together. <code>SignalChain</code> is fully
 * <code>synchronized</code> so that signals cannot be added and removed from
 * the chain during signal generation.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */
@Deprecated
public class SignalChain implements AudioSignal
{
  // the signals in the order they were added
  private Vector<AudioSignal> signals;
  // signals we should remove after our next generate
  // this is done so that a signal won't ever be actually 
  // removed in the middle of a generate, which can cause clicks
  private Vector<AudioSignal> signalsToRemove;
  // all currently enabled signals
  private HashSet<AudioSignal> enabled;
  // buffers used to generate audio for each signal
  private float[] tmpL;
  private float[] tmpR;

  /**
   * Constructs an empty <code>SignalChain</code>.
   * 
   */
  public SignalChain()
  {
    signals = new Vector<AudioSignal>();
    signalsToRemove = new Vector<AudioSignal>();
    enabled = new HashSet<AudioSignal>();
  }

  /**
   * Adds <code>signal</code> to the end of the chain.
   * 
   * @param signal
   *          the <code>AudioEffect</code> to add
   */
  public synchronized void add(AudioSignal signal)
  {
    signals.add(signal);
    enabled.add(signal);
  }

  /**
   * Removes <code>signal</code> from the chain.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to remove
   */
  public synchronized void remove(AudioSignal signal)
  {
	//Minim.debug("Marking " + signal.toString() + " for removal.");
	signalsToRemove.add(signal);
  }

  /**
   * Removes and returns the <code>i</code><sup>th</sup> signal from the
   * chain.
   * 
   * @param i
   *          the index of the <code>AudioSignal</code> to remove
   * @return the <code>AudioSignal</code> that was removed
   */
  public synchronized AudioSignal remove(int i)
  {
    AudioSignal s = signals.remove(i);
    enabled.remove(s);
    return s;
  }

  /**
   * Gets the <code>i<sup>th</sup></code> signal in the chain.
   * 
   * @param i
   *          the index of the <code>AudioSignal</code> to get
   *         
   * @return the <code>i<sup>th</sup></code> signal in the chain.
   */
  public synchronized AudioSignal get(int i)
  {
    return signals.get(i);
  }
  
  /**
   * Returns true if <code>s</code> is in the chain.
   * 
   * @param s the <code>AudioSignal</code> to check for
   * @return true if <code>s</code> is in the chain
   */
  public synchronized boolean contains(AudioSignal s)
  {
    return signals.contains(s);
  }

  /**
   * Enables the <code>i</code><sup>th</sup> effect in the chain.
   * 
   * @param i
   *          the index of the effect to enable
   */
  public synchronized void enable(int i)
  {
    enabled.add(get(i));
  }

  /**
   * Enables <code>signal</code> if it is in the chain.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to enable
   */
  public synchronized void enable(AudioSignal signal)
  {
    if (signals.contains(signal))
    {
      enabled.add(signal);
    }
  }

  /**
   * Enables all signals in the chain.
   * 
   */
  public synchronized void enableAll()
  {
    enabled.addAll(signals);
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
   * @param signal
   *          the <code>AudioSignal</code> to return the status of
   * @return true if <code>signal</code> is enabled and in the chain
   */
  public synchronized boolean isEnabled(AudioSignal signal)
  {
    return enabled.contains(signal);
  }

  /**
   * Disables the <code>i</code><sup>th</sup> effect in the chain.
   * 
   * @param i
   *          the index of the effect to disable
   */
  public synchronized void disable(int i)
  {
    enabled.remove(get(i));
  }

  /**
   * Disables <code>signal</code> if it is in the chain.
   * 
   * @param signal
   *          the <code>AudioSignal</code> to disable
   */
  public synchronized void disable(AudioSignal signal)
  {
    enabled.remove(signal);
  }

  /**
   * Disables all signals in the chain.
   * 
   */
  public synchronized void disableAll()
  {
    enabled.clear();
  }

  /**
   * Returns the number of signals in the chain.
   * 
   * @return the number of signals in the chain
   */
  public synchronized int size()
  {
    return signals.size();
  }

  /**
   * Removes all signals from the effect chain.
   * 
   */
  public synchronized void clear()
  {
    signals.clear();
    enabled.clear();
  }

  /**
   * Asks all the enabled signals in the chain to generate a new buffer of
   * samples, adds the buffers together and puts the result in
   * <code>signal</code>.
   * 
   */
  public synchronized void generate(float[] signal)
  {
    if ( tmpL == null )
    {
    	tmpL = new float[signal.length];
    }
    for (int i = 0; i < signals.size(); i++)
    {
      AudioSignal s = signals.get(i);
      if ( enabled.contains(s) )
      {
        for(int it = 0; it < tmpL.length; it++) 
        { 
        	tmpL[it] = 0; 
        }
        s.generate(tmpL);
        for (int is = 0; is < signal.length; is++)
        {
          signal[is] += tmpL[is];
        }
      }
    }
    // now remove signals we have marked for removal
    signals.removeAll(signalsToRemove);
    signalsToRemove.removeAllElements();    
  }

  /**
   * Asks all the enabled signals in the chain to generate a left and right
   * buffer of samples, adds the signals together and puts the result in
   * <code>left</code> and <code>right</code>.
   */
  public synchronized void generate(float[] left, float[] right)
  {
	  if ( tmpL == null )
	  {
		  tmpL = new float[left.length];
	  }
	  if ( tmpR == null )
	  {
		  tmpR = new float[right.length];
	  }
    for (int i = 0; i < signals.size(); i++)
    {
      AudioSignal s = signals.get(i);
      if ( enabled.contains(s) )
      {
        s.generate(tmpL, tmpR);
        for (int j = 0; j < left.length; j++)
        {
          left[j] += tmpL[j];
          right[j] += tmpR[j];
        }
      }
    }
    // now remove signals we have marked for removal
    signals.removeAll(signalsToRemove);
    signalsToRemove.removeAllElements(); 
  }
}
