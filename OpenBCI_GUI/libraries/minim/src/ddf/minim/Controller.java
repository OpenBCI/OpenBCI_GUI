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

import javax.sound.sampled.BooleanControl;
import javax.sound.sampled.Control;
import javax.sound.sampled.FloatControl;

/**
 * <code>Controller</code> is the base class of all Minim classes that deal
 * with audio I/O. It provides control over the underlying <code>DataLine</code>,
 * which is a low-level JavaSound class that talks directly to the audio
 * hardware of the computer. This means that you can make changes to the audio
 * without having to manipulate the samples directly. The downside to this is
 * that when outputting sound to the system (such as with an
 * <code>AudioOutput</code>), these changes will not be present in the
 * samples made available to your program.
 * <p>
 * The {@link #volume()}, {@link #gain()}, {@link #pan()}, and
 * {@link #balance()} methods return objects of type <code>FloatControl</code>,
 * which is a class defined by the JavaSound API. A <code>FloatControl</code>
 * represents a control of a line that holds a <code>float</code> value. This
 * value has an associated maximum and minimum value (such as between -1 and 1
 * for pan), and also a unit type (such as dB for gain). You should refer to the
 * <a
 * href="http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/sampled/FloatControl.html">FloatControl
 * Javadoc</a> for the full description of the methods available.
 * <p>
 * Not all controls are available on all objects. Before calling the methods
 * mentioned above, you should call
 * {@link #hasControl(javax.sound.sampled.Control.Type)} with the control type
 * you want to use. Alternatively, you can use the <code>get</code> and
 * <code>set</code> methods, which will simply do nothing if the control you
 * are trying to manipulate is not available.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */
public class Controller
{
  /** @invisible
   * The volume control type.
   */
  @Deprecated
  public static FloatControl.Type VOLUME = FloatControl.Type.VOLUME;

  /** @invisible
   * The gain control type.
   */
  @Deprecated
  public static FloatControl.Type GAIN = FloatControl.Type.MASTER_GAIN;

  /** @invisible
   * The balance control type.
   */
  @Deprecated
  public static FloatControl.Type BALANCE = FloatControl.Type.BALANCE;

  /** @invisible
   * The pan control type.
   */
  @Deprecated
  public static FloatControl.Type PAN = FloatControl.Type.PAN;

  /** @invisible
   * The sample rate control type.
   */
  @Deprecated
  public static FloatControl.Type SAMPLE_RATE = FloatControl.Type.SAMPLE_RATE;

  /** @invisible
   * The mute control type.
   */
  @Deprecated
  public static BooleanControl.Type MUTE = BooleanControl.Type.MUTE;
  
  private Control[] controls;
  // the starting value for shifting
  private ValueShifter vshifter, gshifter, bshifter, pshifter;
  private boolean vshift, gshift, bshift, pshift;

  /**
   * Constructs a <code>Controller</code> for the given <code>Line</code>.
   * 
   * @param cntrls
   *          an array of Controls that this Controller will manipulate
   *          
   * @invisible
   */
  public Controller(Control[] cntrls)
  {
    controls = cntrls;
    vshift = gshift = bshift = pshift = false;
  }
  
  // for line reading/writing classes to alert the controller 
  // that a new buffer has been read/written
  void update()
  {
    if ( vshift )
    {
      setVolume( vshifter.value() );
      if ( vshifter.done() ) vshift = false;
    }

    if ( gshift )
    {
      setGain( gshifter.value() );
      if ( gshifter.done() ) gshift = false;
    }
    
    if ( bshift )
    {
      setBalance( bshifter.value() );
      if ( bshifter.done() ) bshift = false;
    }
    
    if ( pshift )
    {
      setPan( pshifter.value() );
      if ( pshifter.done() ) pshift = false;
    }
  }
  
  // a small class to interpolate a value over time
  class ValueShifter
  {
    private float tstart, tend, vstart, vend;
    
    public ValueShifter(float vs, float ve, int t)
    {
      tstart = (int)System.currentTimeMillis();
      tend = tstart + t;
      vstart = vs;
      vend = ve;
    }
    
    public float value()
    {
      int millis = (int)System.currentTimeMillis();
      float norm = (float)(millis-tstart) / (tend-tstart);
      float range = (float)(vend-vstart);
      return vstart + range*norm;
    }
    
    public boolean done()
    {
      return (int)System.currentTimeMillis() > tend;
    }
  }

  /** @invisible
   * 
   * Prints the available controls and their ranges to the console. Not all
   * Controllers have all of the controls available on them so this is a way to find
   * out what is available.
   * 
   */
  public void printControls()
  {
    if (controls.length > 0)
    {
      System.out.println("Available controls are:");
      for (int i = 0; i < controls.length; i++)
      {
        Control.Type type = controls[i].getType();
        System.out.print("  " + type.toString());
        if (type == VOLUME || type == GAIN || type == BALANCE || type == PAN)
        {
          FloatControl fc = (FloatControl) controls[i];
          String shiftSupported = "does";
          if (fc.getUpdatePeriod() == -1)
          {
            shiftSupported = "doesn't";
          }
          System.out.println(", which has a range of " + fc.getMaximum() + " to "
              + fc.getMinimum() + " and " + shiftSupported
              + " support shifting.");
        }
        else
        {
          System.out.println("");
        }
      }
    }
    else
    {
      System.out.println("There are no controls available.");
    }
  }

  /** @invisible
   * 
   * Returns whether or not the particular control type is supported by this Controller
   * 
   * @param type 
   * 		the Control.Type to query for
   * 
   * @see #VOLUME
   * @see #GAIN
   * @see #BALANCE
   * @see #PAN
   * @see #SAMPLE_RATE
   * @see #MUTE
   * 
   * @return true if the control is available
   */
  @Deprecated
  public boolean hasControl(Control.Type type)
  {
    for(int i = 0; i < controls.length; i++)
    {
      if ( controls[i].getType().equals(type) )
      {
        return true;
      }
    }
    return false;
  }

  /** @invisible
   * 
   * Returns an array of all the available <code>Control</code>s for the
   * <code>DataLine</code> being controlled. You can use this if you want to
   * access the controls directly, rather than using the convenience methods
   * provided by this class.
   * 
   * @return an array of all available controls
   */
  @Deprecated
  public Control[] getControls()
  {
    return controls;
  }
  
  @Deprecated
  public Control getControl(Control.Type type)
  {
    for(int i = 0; i < controls.length; i++)
    {
      if ( controls[i].getType().equals(type) )
      {
        return controls[i];
      }
    }
    return null;
  }

  /** @invisible
   * Gets the volume control for the <code>Line</code>, if it exists. You
   * should check for the availability of a volume control by using
   * {@link #hasControl(javax.sound.sampled.Control.Type)} before calling this
   * method.
   * 
   * @return the volume control
   */
  @Deprecated
  public FloatControl volume()
  {
    return (FloatControl)getControl(VOLUME);
  }

  /** @invisible
   * Gets the gain control for the <code>Line</code>, if it exists. You
   * should check for the availability of a gain control by using
   * {@link #hasControl(javax.sound.sampled.Control.Type)} before calling this
   * method.
   * 
   * @return the gain control
   */
  @Deprecated
  public FloatControl gain()
  {
    return (FloatControl) getControl(GAIN);
  }

  /** @invisible
   * Gets the balance control for the <code>Line</code>, if it exists. You
   * should check for the availability of a balance control by using
   * {@link #hasControl(javax.sound.sampled.Control.Type)} before calling this
   * method.
   * 
   * @return the balance control
   */
  @Deprecated
  public FloatControl balance()
  {
    return (FloatControl) getControl(BALANCE);
  }

  /** @invisible
   * Gets the pan control for the <code>Line</code>, if it exists. You should
   * check for the availability of a pan control by using
   * {@link #hasControl(javax.sound.sampled.Control.Type)} before calling this
   * method.
   * 
   * @return the pan control
   */
  @Deprecated
  public FloatControl pan()
  {
    return (FloatControl) getControl(PAN);
  }

  /**
   * Mutes the sound.
   * 
   * @related unmute ( )
   * @related isMuted ( )
   */
  public void mute()
  {
    setValue(MUTE, true);
  }

  /**
   * Unmutes the sound.
   * 
   * @related mute ( )
   * @related isMuted ( )
   */
  public void unmute()
  {
    setValue(MUTE, false);
  }

  /**
   * Returns true if the sound is muted.
   * 
   * @return the current mute state
   * 
   * @related mute ( )
   * @related unmute ( )
   */
  public boolean isMuted()
  {
    return getValue(MUTE);
  }

  private boolean getValue(BooleanControl.Type type)
  {
    boolean v = false;
    if (hasControl(type))
    {
      BooleanControl c = (BooleanControl) getControl(type);
      v = c.getValue();
    }
    else
    {
      Minim.error(type.toString() + " is not supported.");
    }
    return v;
  }

  private void setValue(BooleanControl.Type type, boolean v)
  {
    if (hasControl(type))
    {
      BooleanControl c = (BooleanControl) getControl(type);
      c.setValue(v);
    }
    else
    {
      Minim.error(type.toString() + " is not supported.");
    }
  }

  private float getValue(FloatControl.Type type)
  {
    float v = 0;
    if (hasControl(type))
    {
      FloatControl c = (FloatControl) getControl(type);
      v = c.getValue();
    }
    else
    {
      Minim.error(type.toString() + " is not supported.");
    }
    return v;
  }

  private void setValue(FloatControl.Type type, float v)
  {
    if (hasControl(type))
    {
      FloatControl c = (FloatControl) getControl(type);
      if (v > c.getMaximum())
        v = c.getMaximum();
      else if (v < c.getMinimum()) v = c.getMinimum();
      c.setValue(v);
    }
    else
    {
      Minim.error(type.toString() + " is not supported.");
    }
  }

  /**
   * Returns the current volume. If a volume control is not available, this
   * returns 0. Note that the volume is not the same thing as the
   * <code>level()</code> of an AudioBuffer!
   * 
   * @shortdesc Returns the current volume.
   * 
   * @return the current volume or zero if a volume control is unavailable
   * 
   * @related setVolume ( )
   * @related shiftVolume ( )
   */
  public float getVolume()
  {
    return getValue(VOLUME);
  }

  /**
   * Sets the volume. If a volume control is not available,
   * this does nothing.
   * 
   * @shortdesc Sets the volume.
   * 
   * @param value
   *          float: the new value for the volume, usually in the range [0,1].
   *          
   * @related getVolume ( )
   * @related shiftVolume ( )
   */
  public void setVolume(float value)
  {
    setValue(VOLUME, value);
  }

  /**
   * Transitions the volume from one value to another.
   * 
   * @param from
   *          float: the starting volume
   * @param to
   *          float: the ending volume
   * @param millis
   *          int: the length of the transition in milliseconds
   *          
   * @related getVolume ( )
   * @related setVolume ( )
   */
  public void shiftVolume(float from, float to, int millis)
  {
    if ( hasControl(VOLUME) )
    {
      setVolume(from);
      vshifter = new ValueShifter(from, to, millis);
      vshift = true;
    }
  }

  /**
   * Returns the current gain. If a gain control is not available, this returns
   * 0. Note that the gain is not the same thing as the <code>level()</code>
   * of an AudioBuffer! Gain describes the current volume of the sound in 
   * decibels, which is a logarithmic, rather than linear, scale. A gain 
   * of 0dB means the sound is not being amplified or attenuated. Negative
   * gain values will reduce the volume of the sound, and positive values 
   * will increase it. 
   * <p>
   * See: <a href="http://wikipedia.org/wiki/Decibel">http://wikipedia.org/wiki/Decibel</a>
   * 
   * @shortdesc Returns the current gain.
   * 
   * @return float: the current gain or zero if a gain control is unavailable.
   * the gain is expressed in decibels.
   * 
   * @related setGain ( )
   * @related shiftGain ( ) 
   */
  public float getGain()
  {
    return getValue(GAIN);
  }

  /**
   * Sets the gain. If a gain control is not available,
   * this does nothing.
   * 
   * @shortdesc Sets the gain.
   * 
   * @param value
   *          float: the new value for the gain, expressed in decibels.
   *          
   * @related getGain ( )
   * @related shiftGain ( )
   */
  public void setGain(float value)
  {
    setValue(GAIN, value);
  }

  /**
   * Transitions the gain from one value to another.
   * 
   * @param from
   *          float: the starting gain
   * @param to
   *          float: the ending gain
   * @param millis
   *          int: the length of the transition in milliseconds
   *          
   * @related getGain ( )
   * @related setGain ( )
   */
  public void shiftGain(float from, float to, int millis)
  {
    if ( hasControl(GAIN) )
    {
      setGain(from);
      gshifter = new ValueShifter(from, to, millis);
      gshift = true;
    }
  }

  /**
   * Returns the current balance. This will be in the range [-1, 1].
   * Usually balance will only be available for stereo audio sources, 
   * because it describes how much attenuation should be applied to 
   * the left and right channels.
   * If a balance control is not available, this will do nothing.
   * 
   * @shortdesc Returns the current balance.
   * 
   * @return float: the current balance or zero if a balance control is unavailable
   * 
   * @related setBalance ( )
   * @related shiftBalance ( )
   */
  public float getBalance()
  {
    return getValue(BALANCE);
  }

  /**
   * Sets the balance. 
   * The value should be in the range [-1, 1]. 
   * If a balance control is not available, this will do nothing.
   * 
   * @shortdesc Sets the balance.
   * 
   * @param value
   *          float: the new value for the balance
   *          
   * @related getBalance ( )
   * @related shiftBalance ( )
   */
  public void setBalance(float value)
  {
    setValue(BALANCE, value);
  }

  /**
   * Transitions the balance from one value to another.
   * 
   * @param from
   *          float: the starting balance
   * @param to
   *          float: the ending balance
   * @param millis
   *          int: the length of the transition in milliseconds
   *          
   * @related getBalance ( )
   * @related setBalance ( )
   */
  public void shiftBalance(float from, float to, int millis)
  {
    if ( hasControl(BALANCE) )
    {
      setBalance(from);
      bshifter = new ValueShifter(from, to, millis);
      bshift = true;
    }
  }

  /**
   * Returns the current pan.
   * Usually pan will be only be available on mono audio sources because 
   * it describes a mono signal's position in a stereo field.
   * This will be in the range [-1, 1], where -1 will place the sound 
   * only in the left speaker and 1 will place the sound only in the right speaker.
   * 
   * @shortdesc Returns the current pan.
   * 
   * @return float: the current pan or zero if a pan control is unavailable
   * 
   * @related setPan ( )
   * @related shiftPan ( )
   */
  public float getPan()
  {
    return getValue(PAN);
  }

  /**
   * Sets the pan. 
   * The provided value should be in the range [-1, 1].
   * If a pan control is not present, this does nothing.
   * 
   * @shortdesc Sets the pan. 
   * 
   * @param value
   *          float: the new value for the pan
   *          
   * @related getPan ( )  
   * @related shiftPan ( )    
   */
  public void setPan(float value)
  {
    setValue(PAN, value);
  }

  /**
   * Transitions the pan from one value to another.
   * 
   * @param from
   *          float: the starting pan
   * @param to
   *          float: the ending pan
   * @param millis
   *          int: the length of the transition in milliseconds
   *         
   * @related getPan ( )
   * @related setPan ( )
   */
  public void shiftPan(float from, float to, int millis)
  {
    if ( hasControl(PAN) )
    {
      setPan(from);
      pshifter = new ValueShifter(from, to, millis);
      pshift = true;
    }
  }
}
