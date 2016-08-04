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

import java.util.Vector;

import javax.sound.sampled.AudioFormat;

/**
 * A <code>SignalSplitter</code> acts exactly like a headphone splitter. 
 * When you pass it audio with the <code>samples</code> method, it echoes that 
 * audio out to all of its listeners, giving each their own copy of the audio. 
 * In other words, changes that the listeners make to the float arrays 
 * they receive from a <code>SignalSplitter</code> will not be reflected in 
 * the arrays you pass to <code>samples</code>. <code>SignalSplitter</code> is 
 * fully <code>synchronized</code> so that listeners cannot be added and 
 * removed while it is in the midst transmitting.
 *  
 * @author Damien Di Fede
 * @invisible
 *
 */

public class SignalSplitter implements Recordable, AudioListener
{
  private Vector<AudioListener> listeners;
  private AudioFormat f;
  private int bs;
  
  /**
   * Construct a <code>SignalSplitter</code> that will receive 
   * audio in the given format and in buffers the size of 
   * <code>bufferSize</code>. Strictly speaking, a <code>SignalSplitter</code>
   * doesn't care about either of these things because it does nothing with 
   * the samples it receives other than pass them on. But both things are 
   * required to fulfill the <code>Recordable</code> contract.
   * 
   * @param format the <code>AudioFormat</code> of samples that this will receive
   * @param bufferSize the size of the float arrays this will receive
   */
  public SignalSplitter(AudioFormat format, int bufferSize)
  {
    f = format;
    bs = bufferSize;
    listeners = new Vector<AudioListener>(5);
  }
  
  public int bufferSize()
  {
    return bs;
  }

  public AudioFormat getFormat()
  {
    return f;
  }
  
  public int type()
  {
    return f.getChannels();
  }
  
  public synchronized void addListener(AudioListener listener)
  {
    if ( !listeners.contains(listener) )
    {
      listeners.add(listener);
    }
  }

  public synchronized void removeListener(AudioListener listener)
  {
    listeners.remove(listener);
  }

  public synchronized void samples(float[] samp)
  {
    for (int i = 0; i < listeners.size(); i++)
    {
      AudioListener al = listeners.get(i);
      float[] copy = new float[samp.length];
      System.arraycopy(samp, 0, copy, 0, copy.length);
      al.samples(copy);
    }
  }

  public synchronized void samples(float[] sampL, float[] sampR)
  {
    for (int i = 0; i < listeners.size(); i++)
    {
      AudioListener al = listeners.get(i);
      float[] copyL = new float[sampL.length];
      float[] copyR = new float[sampR.length];
      System.arraycopy(sampL, 0, copyL, 0, copyL.length);
      System.arraycopy(sampR, 0, copyR, 0, copyR.length);
      al.samples(copyL, copyR);
    }
  }

  public float sampleRate()
  {
    return f.getSampleRate();
  }
}
