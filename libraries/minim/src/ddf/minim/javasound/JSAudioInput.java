/*
 *  Copyright (c) 2007 by Damien Di Fede <ddf@compartmental.net>
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

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.Control;
import javax.sound.sampled.TargetDataLine;

import ddf.minim.AudioEffect;
import ddf.minim.AudioListener;
import ddf.minim.Minim;
import ddf.minim.MultiChannelBuffer;
import ddf.minim.spi.AudioStream;

// This is our AudioInput!
final class JSAudioInput extends Thread
                        implements AudioStream
{
  private AudioListener listener;
  private AudioEffect effect;
  
  // line reading variables 
  private TargetDataLine line;
  private FloatSampleBuffer buffer;
  private int bufferSize;
  private boolean finished;
  private boolean mono;
  private byte[] rawBytes;
  
  JSAudioInput(TargetDataLine tdl, int bufferSize)
  {
    line = tdl;
    this.bufferSize = bufferSize;
    buffer = new FloatSampleBuffer(tdl.getFormat().getChannels(), 
        bufferSize,
        tdl.getFormat().getSampleRate());
    finished = false;
    mono = ( buffer.getChannelCount() == 1 );
    int byteBufferSize = buffer.getByteArrayBufferSize(line.getFormat());
    Minim.debug("byteBufferSize is " + byteBufferSize);
    rawBytes = new byte[byteBufferSize];
  }
  
  public void run()
  {
    line.start();
    while ( !finished )
    {
      // read from the line
      line.read(rawBytes, 0, rawBytes.length);
      // convert to float samples
      buffer.setSamplesFromBytes(rawBytes, 0, line.getFormat(), 
                                 0, buffer.getSampleCount());
      // apply effects, if any, and broadcast the result
      // to all listeners
      if ( mono )
      {
        float[] samp = buffer.getChannel(0);
        effect.process(samp);
        listener.samples(samp);
      }
      else
      {
        float[] sampL = buffer.getChannel(0);
        float[] sampR = buffer.getChannel(1);
        effect.process(sampL, sampR);
        listener.samples(sampL, sampR);
      }
      try
      {
        Thread.sleep(10);
      }
      catch (InterruptedException e)
      {
      }
    }
    // we are done, clean up the line
    line.flush();
    line.stop();
    line.close();
    line = null;
  }
  
  public void open()
  {
    // start();
	line.start();
  }
  
  public void close()
  {
    finished = true;
    // we are done, clean up the line
    line.flush();
    line.stop();
    line.close();
  }
 
  public int bufferSize()
  {
   return bufferSize;
  }

  public AudioFormat getFormat()
  {
    return line.getFormat();
  } 
  
  public void setAudioEffect(AudioEffect effect)
  {
    this.effect = effect;    
  }

  public void setAudioListener(AudioListener listener)
  {
    this.listener = listener;    
  }

  public Control[] getControls()
  {
    return line.getControls();
  }

	public float[] read() 
	{
		// TODO: this is sort of terrible, but will do for now. would be much better
		// to dig the conversion stuff out of FloatSampleBuffer and do this more directly
		int numSamples = 1;
		// allocate enough bytes for one sample frame
		byte[] bytes = new byte[ line.getFormat().getFrameSize() ];
		line.read(bytes, 0, bytes.length);
		buffer.setSamplesFromBytes(bytes, 0, line.getFormat(), 0, numSamples);
		// allocate enough floats for the number of channels
		float[] samples = new float[ buffer.getChannelCount() ];

		for(int i = 0; i < samples.length; i++)
		{
			samples[i] = buffer.getChannel(i)[0];
		}		
		return samples;
	}

	public int read(MultiChannelBuffer buffer) 
	{
		// create our converter object
		int numChannels = line.getFormat().getChannels();
		int numSamples = buffer.getBufferSize();
		float sampleRate = line.getFormat().getSampleRate();
		FloatSampleBuffer convert = new FloatSampleBuffer( numChannels, numSamples, sampleRate );
		// allocate enough bytes for the size of this buffer
		byte[] bytes = new byte[ convert.getByteArrayBufferSize(line.getFormat()) ];
		// read the bytes
		line.read(bytes, 0, bytes.length);
		// convert the bytes
		convert.setSamplesFromBytes(bytes, 0, line.getFormat(), 0, numSamples);
		// copy the converted floats into the MultiChannelBuffer
		// make sure it has the correct number of channels first
		buffer.setChannelCount(numChannels);
		for(int i = 0; i < convert.getChannelCount(); i++)
		{
			buffer.setChannel(i, convert.getChannel(i));
		}
		
		return numSamples;
	}
}
