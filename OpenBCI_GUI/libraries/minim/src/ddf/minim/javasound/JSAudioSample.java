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

package ddf.minim.javasound;

import ddf.minim.AudioMetaData;
import ddf.minim.AudioSample;
import ddf.minim.spi.AudioOut;

final class JSAudioSample extends AudioSample
{
  private SampleSignal sample;
  private AudioMetaData meta;
  
  JSAudioSample(AudioMetaData mdata, SampleSignal ssig, AudioOut out)
  {
    super(out);
    sample = ssig;
    meta = mdata;
  }
  
  public void trigger()
  {
    sample.trigger();
  }
  
  public void stop()
  {
    sample.stop();
  }
  
  public float[] getChannel(int channelNumber)
  {
    return sample.getChannel(channelNumber);
  }

  public int length()
  {
    return meta.length();
  }
  
  public AudioMetaData getMetaData()
  {
	  return meta;
  }
}
