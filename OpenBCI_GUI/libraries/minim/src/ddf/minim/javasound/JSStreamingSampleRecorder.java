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

import java.io.File;
import java.io.IOException;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;

import org.tritonus.share.sampled.AudioSystemShadow;
import org.tritonus.share.sampled.AudioUtils;
import org.tritonus.share.sampled.file.AudioOutputStream;

import ddf.minim.Minim;
import ddf.minim.spi.AudioRecordingStream;
import ddf.minim.spi.SampleRecorder;

/**
 * JSStreamingSampleRecorder using the Tritonus AudioOutputStream class to stream audio
 * directly to disk. The limitation of this approach is that the file format and
 * the file name must be known before recording begins because the file must be
 * created. The advantage is that you do not incur the overhead of an in-memory
 * buffer and saving will not cause your sketch to hang because all the audio is
 * already on disk and all that must be done is closing the file. Unlike
 * JSBufferedSampleRecorder, specifying the file format upon saving will do nothing and
 * you cannot easily save your recorded audio to multiple formats. There are
 * also fewer formats available to save in, limiting you to AIFF, AU, and WAV.
 * 
 * @author Damien Di Fede
 * 
 */
final class JSStreamingSampleRecorder implements SampleRecorder
{
  // output stream representing the file being written to
  private AudioOutputStream aos;
  // float sample buffer used for converting float samples to bytes
  private FloatSampleBuffer fsb;
  private String name;
  private AudioFileFormat.Type type;
  private AudioFormat format;
  private boolean recording;
  
  private JSMinim system;

  /**
   * 
   * @param fileName
   * @param fileType
   * @param fileFormat
   */
  JSStreamingSampleRecorder(JSMinim sys, 
                         String fileName, 
                         AudioFileFormat.Type fileType, 
                         AudioFormat fileFormat,
                         int bufferSize)
  {
    name = fileName;
    type = fileType;
    format = fileFormat;
    system = sys;
    try
    {
      aos = AudioSystemShadow.getAudioOutputStream( type, format,
                              AudioSystem.NOT_SPECIFIED, 
                              new File(name) );
    }
    catch (IOException e)
    {
      system.error("Error obtaining new output stream: " + e.getMessage());
    }
    catch (IllegalArgumentException badarg)
    {
      system.error("Error obtaining new output stream for " + fileName + " with type " 
          + type.toString() + " format " + format.toString() 
          + " and bufferSize " + bufferSize + ".\n" 
          + "The reason is " + badarg.getMessage());
    }
    fsb = new FloatSampleBuffer(format.getChannels(),
                                bufferSize,
                                format.getSampleRate());
    recording = false;
  }
  
  public String filePath()
  {
    return name;
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

  /**
   * Finishes the recording process by closing the file.
   */
  public AudioRecordingStream save()
  {
    try
    {
      aos.close();
    }
    catch (IOException e)
    {
      Minim.error("AudioRecorder.save: An error occurred when trying to save the file:\n"
                  + e.getMessage());
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
      System.arraycopy(samp, 0, fsb.getChannel(0), 0, samp.length);
      byte[] raw = fsb.convertToByteArray(format);
      try
      {
        aos.write(raw, 0, raw.length);
      }
      catch (IOException e)
      {
        Minim.error("AudioRecorder: An error occurred while trying to write to the file:\n" +
                    e.getMessage() );
      }
    }
  }

  public void samples(float[] sampL, float[] sampR)
  {
    if ( recording )
    {
      System.arraycopy(sampL, 0, fsb.getChannel(0), 0, sampL.length);
      System.arraycopy(sampR, 0, fsb.getChannel(1), 0, sampR.length);
      byte[] raw = fsb.convertToByteArray(format);
      try
      {
        aos.write(raw, 0, raw.length);
      }
      catch (IOException e)
      {
        Minim.error("AudioRecorder: An error occurred while trying to write to the file:\n" +
                    e.getMessage() );
      }
    }
  }
}
