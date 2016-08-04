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

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.nio.FloatBuffer;
import java.util.ArrayList;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;

import org.tritonus.share.sampled.AudioUtils;

import ddf.minim.Minim;
import ddf.minim.spi.AudioRecordingStream;
import ddf.minim.spi.SampleRecorder;

/**
 * JSBufferedSampleRecorder is an implementation of the AudioFileOut protocol that records to an 
 * in-memory buffer and then writes the data to disk when <code>save()</code> is called. 
 * Because of this it is possible to specify the file format to use for saving <i>after</i> 
 * the audio has already been recorded. It is also possible to save the recorded audio to 
 * multiple formats by calling <code>save(type)</code> for each file format you want to 
 * save to. Because the saving is performed in the same thread of execution as your 
 * Processing sketch, you can expect your sketch to hang while the audio is written to 
 * disk. How long it hangs will be proportional to the length of the audio buffer.
 * 
 * @author Damien Di Fede
 *
 */
final class JSBufferedSampleRecorder implements SampleRecorder
{
  private ArrayList<FloatBuffer> buffers;
  private FloatBuffer left;
  private FloatBuffer right;
  private boolean recording;
  private String name;
  private AudioFileFormat.Type type;
  private AudioFormat format;
  
  private JSMinim system;

  /**
   * Constructs a JSBufferedSampleRecorder that expects audio in the given AudioFormat and 
   * which will save to a file with given name.
   * 
   * @param format the AudioFormat you want to record in
   * @param name the name of the file to save to (not including the extension)
   */
  JSBufferedSampleRecorder(JSMinim sys,
                           String fileName, 
                           AudioFileFormat.Type fileType, 
                           AudioFormat fileFormat,
                           int bufferSize)
  {
    name = fileName;
    type = fileType;
    format = fileFormat;
    buffers = new ArrayList<FloatBuffer>(20);
    left = FloatBuffer.allocate(bufferSize*10);
    if ( format.getChannels() == Minim.STEREO )
    {
      right = FloatBuffer.allocate(bufferSize*10);
    }
    else
    {
      right = null;
    }
    system = sys;
  }
  
  public String filePath()
  {
    return name;
  }

  /**
   * Saves the audio in the internal buffer to a file using the current settings for 
   * file type and file name.
   */
  public AudioRecordingStream save()
  {
    if ( isRecording() )
    {
      system.error("You must stop recording before you can write to a file.");
    }
    else
    {
      int channels = format.getChannels();
      int length = left.capacity();
      int totalSamples = ( buffers.size() / channels ) * length;
      FloatSampleBuffer fsb = new FloatSampleBuffer(channels,
                                                    totalSamples,
                                                    format.getSampleRate());
      if ( channels == 1 )
      {
        for (int i = 0; i < buffers.size(); i++)
        {
          int offset = i*length;
          FloatBuffer fb = (FloatBuffer)buffers.get(i);
          fb.rewind();
          // copy all the floats in fb to the first channel
          // of fsb, starting at the index offset, and copy
          // the whole FloatBuffer over.
          fb.get(fsb.getChannel(0), offset, length);
        }
      }
      else
      {
        for (int i = 0; i < buffers.size(); i+=2)
        {
          int offset = (i/2)*length;
          FloatBuffer fbL = (FloatBuffer)buffers.get(i);
          FloatBuffer fbR = (FloatBuffer)buffers.get(i+1);
          fbL.rewind();
          fbL.get(fsb.getChannel(0), offset, length);
          fbR.rewind();
          fbR.get(fsb.getChannel(1), offset, length);
        }
      }
      int sampleFrames = fsb.getByteArrayBufferSize(format) / format.getFrameSize();
      ByteArrayInputStream bais = new ByteArrayInputStream(fsb.convertToByteArray(format));
      AudioInputStream ais = new AudioInputStream(bais, format, sampleFrames);
      if (AudioSystem.isFileTypeSupported(type, ais))
      {
        File out = new File( name );
        try
        {
          AudioSystem.write(ais, type, out);
        }
        catch (IOException e)
        {
          system.error("AudioRecorder.save: Error attempting to save buffer to "
              + name + "\n" + e.getMessage());
        }
        if (out.length() == 0)
        {
          system.error("AudioRecorder.save: Error attempting to save buffer to "
              + name + ", the output file is empty.");
        }
      }
      else
      {
        system.error("AudioRecorder.save: Can't write " + type.toString()
            + " using format " + format.toString() + ".");
      }
    }
    
    String filePath = filePath();
    AudioInputStream ais = system.getAudioInputStream(filePath);
    SourceDataLine sdl = system.getSourceDataLine(ais.getFormat(), 1024);
    // this is fine because the recording will always be 
    // in a raw format (WAV, AU, etc).
    long length = AudioUtils.frames2Millis(ais.getFrameLength(), format);
    BasicMetaData meta = new BasicMetaData(filePath, length, ais.getFrameLength());
    JSPCMAudioRecordingStream recording = new JSPCMAudioRecordingStream(system, meta, ais, sdl, 1024);
    return recording;
  }

  public void samples(float[] samp)
  {
    if ( recording )
    {
      left.put(samp);
      if ( !left.hasRemaining() )
      {
        buffers.add(left);
        left = FloatBuffer.allocate(left.capacity());
      }
    }
  }

  public void samples(float[] sampL, float[] sampR)
  {
    if ( recording )
    {
      left.put(sampL);
      right.put(sampR);
      if ( !left.hasRemaining() )
      {
        buffers.add(left);
        buffers.add(right);
        left = FloatBuffer.allocate(left.capacity());
        right = FloatBuffer.allocate(right.capacity());
      }
    }
  }

  public void beginRecord()
  {
    recording = true;
  }

  public void endRecord()
  {
    recording = false;    
  }

  public boolean isRecording()
  {
    return recording;
  }
}
