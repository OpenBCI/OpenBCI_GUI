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

import ddf.minim.spi.AudioOut;
import ddf.minim.spi.AudioStream;

/**
 * An AudioInput is a connection to the current record source of the computer. 
 * How the record source for a computer is set will depend on the soundcard and OS, 
 * but typically a user can open a control panel and set the source from there. 
 * Unfortunately, there is no way to set the record source from Java. 
 * This is particularly problematic on the Mac because the input will always wind 
 * up being connected to the Mic-In, even if the user has set the input differently 
 * using their audio control panel. 
 * <p>
 * You can obtain an AudioInput from Minim by using one of the getLineIn methods:
 * <pre>
 * // get the default STEREO input
 * AudioInput getLineIn()
 * 
 * // specifiy either Minim.MONO or Minim.STEREO for type
 * AudioInput getLineIn(int type)
 * 
 * // bufferSize is the size of the left, right,
 * // and mix buffers of the input you get back
 * AudioInput getLineIn(int type, int bufferSize)
 * 
 * // sampleRate is a request for an input of a certain sample rate
 * AudioInput getLineIn(int type, int bufferSize, float sampleRate)
 * 
 * // bitDepth is a request for an input with a certain bit depth
 * AudioInput getLineIn(int type, int bufferSize, float sampleRate, int bitDepth)
 * </pre>
 * In the event that an input doesn't exist with the requested parameters, 
 * Minim will spit out an error and return null. In general, 
 * you will want to use the first two methods listed above.
 * 
 * @example Basics/MonitorInput
 * 
 * @related Minim
 * 
 * @author Damien Di Fede
 *
 */
public class AudioInput extends AudioSource
{  
  boolean 		m_isMonitoring; 
  AudioStream	m_stream;
  
  /** @invisible
   * 
   * Constructs an <code>AudioInput</code> that uses <code>out</code> to read 
   * samples from <code>stream</code>. The samples from <code>stream</code> 
   * can be accessed by through the interface provided by <code>AudioSource</code>.
   * 
   * @param stream the <code>AudioStream</code> that provides the samples
   * @param out the <code>AudioOut</code> that will read from <code>stream</code>
   */
  public AudioInput(AudioStream stream, AudioOut out)
  {
    super( out );
    out.setAudioStream(stream);
    stream.open();
    
    disableMonitoring();
    
    m_stream = stream;
  }
  
  public void close()
  {
	  super.close();
	  m_stream.close();
  }
  
  /**
   * Returns whether or not this AudioInput is monitoring.
   * In other words, whether you will hear in your speakers
   * the audio coming into the input.
   * 
   * @return boolean: true if monitoring is on
   * 
   * @example Basics/MonitorInput
   * 
   * @related enableMonitoring ( )
   * @related disableMonitoring ( )
   * @related AudioInput
   */
  public boolean isMonitoring()
  {
	  return m_isMonitoring;
  }
  
  /**
   * When monitoring is enabled, you will be able to hear 
   * the audio that is coming through the input. 
   * 
   * @example Basics/MonitorInput
   * 
   * @related disableMonitoring ( )
   * @related isMonitoring ( )
   * @related AudioInput
   */
  public void enableMonitoring()
  {
    // make sure we don't make sound
    if ( hasControl(VOLUME) )
    {
    	setVolume( 1 );
        m_isMonitoring = true;
    }
    else if ( hasControl(GAIN) )
    {
    	setGain( 0 );
        m_isMonitoring = true;
    }
    else
    {
    	Minim.error( "Monitoring is not available on this AudioInput." );
    }
  }
  
  /**
   * 
   * When monitoring is disabled, you will not hear 
   * the audio that is coming through the input, 
   * but you will still be able to access the samples
   * in the left, right, and mix buffers. This is 
   * default state of an AudioInput and is what 
   * you will want if your input is microphone 
   * and your output is speakers. Otherwise: feedback.
   * 
   * @shortdesc When monitoring is disabled, you will not hear 
   * the audio that is coming through the input.
   * 
   * @example Basics/MonitorInput
   * 
   * @related enableMonitoring ( )
   * @related isMonitoring ( )
   * @related AudioInput
   * 
   */
  public void disableMonitoring()
  {
    // make sure we don't make sound
    if ( hasControl(VOLUME) )
    {
    	setVolume( 0 );
    }
    else if ( hasControl(GAIN) )
    {
    	setGain( -64 );
    }
    
    m_isMonitoring = false;
  }
}
