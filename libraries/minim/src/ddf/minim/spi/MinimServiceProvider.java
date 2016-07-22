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

package ddf.minim.spi;

import javax.sound.sampled.AudioFormat;

import ddf.minim.AudioSample;
import ddf.minim.Recordable;

/**
 * <code>MinimServiceProvider</code> is the interface that an audio implementation must 
 * provide to <code>Minim</code>, to guarantee that it can provide all of the functionality 
 * that Minim promises. All of the interfaces in this package define functionality in the 
 * most minimal way possible, to make it easy for people write their own implementations, since 
 * much of what Minim provides can be done so without regard for the details of audio intput and 
 * output. If you write your own implementation of this interface, or if you are using one that 
 * someone else has written, all you must do is pass an instantiation of it to the Minim 
 * constructor. That Minim object will then delegate most of the work to the implementation. 
 * 
 * @author ddf
 *
 */

public interface MinimServiceProvider
{
  /**
   * Called inside the Minim constructor. Implementations should load any libraries and 
   * resources they need at this time.
   */
  void start();
  
  /**
   * Called when <code>stop()</code> is called by the Minim object that owns this. 
   * Implementations should release all resources and stop all Threads at this time.
   *
   */
  void stop();
  
  /**
   * Tells the implementation it should produce debug output, if that's something it does.
   *
   */
  void debugOn();
  
  /**
   * Tells the implementation it should not produce debug output.
   *
   */
  void debugOff();
  
  /**
   * Should return an {@link AudioRecording} that can play the file requested. The filename could 
   * be a URL, an absolute path, or just a filename that the user expects the system to find in 
   * their sketch somewhere.
   * 
   * @param filename the name of the file to load into the AudioRecording
   * @return an AudioRecording that can play the file
   */
  /** @deprecated */
  AudioRecording getAudioRecording(String filename);
  
  /**
   * Should return an {@link AudioRecordingStream} that will stream the file requested. The filename 
   * could be a URL, an absolute path, or just a filename that the user expects the system to find 
   * in their sketch somewhere.
   * 
   * @param filename the name of the file to load into the AudioRecordingStream
 * @param bufferSize the bufferSize to use in memory (implementations are free to ignore this, if they must)
 * @param inMemory TODO figure out if this inMemory thing really makes sense.
   * @return an AudioRecording stream that will stream the file
   */
  AudioRecordingStream getAudioRecordingStream(String filename, int bufferSize, boolean inMemory);
  
  /**
   * Should return an {@link  AudioStream} with the requested parameters. What Minim is 
   * expecting this stream to be reading from is the active audio input of the computer, 
   * such as the microphone or line-in.
   * 
   * @param type Minim.STEREO or Minim.MONO
   * @param bufferSize how big the in-memory buffer should be
   * @param sampleRate what the sample rate of the stream should be
   * @param bitDepth what the bit depth of the stream should be
   * @return an AudioStream that is reading from the active audio input of the computer
   */
  AudioStream getAudioInput(int type, int bufferSize, float sampleRate, int bitDepth);
  
  /**
   * Should return an {@link AudioOut} that can be used to generate audio that will 
   * be heard through the computer's speakers.
   * 
   * @param type Minim.STEREO or Minim.MONO
   * @param bufferSize how big the in-memory buffer should be
   * @param sampleRate what the sample rate of the generated audio should be
   * @param bitDepth what the bit depth of the generated audio should be
   * @return an AudioSynthesizer that will output to the computer's speakers
   */
  AudioOut getAudioOutput(int type, int bufferSize, float sampleRate, int bitDepth);
  
  /**
   * Should return an {@link AudioSample} that will load the requested file into memory.
   * 
   * @param filename the name of the file to load, this might be a URL, an absolute path, or a 
   * file that the user expects the implementation to find in their sketch somewhere.
   * @param bufferSize how big the output buffer used for playing the sample should be
   * @return an AudioSample that contains the file
   */
  AudioSample getAudioSample(String filename, int bufferSize);
  
  /**
   * Should return an {@link AudioSample} that will store the provided samples.
   * 
   * @param samples 
   *          the array of audio samples
   * @param bufferSize
   *          how large the output buffer should be
   * @return
   *          an AudioSample that contains the samples
   */
  AudioSample getAudioSample(float[] samples, AudioFormat format, int bufferSize);
  
  /**
   * Should return an {@link AudioSample} that will store the provided samples.
   * 
   * @param left
   *          the left channel of the stereo sample
   * @param right
   *          the right channel of a stereo sample
   * @param bufferSize
   *          how large the output buffer should be
   * @return
   *          an AudioSample that contains the samples
   */
  AudioSample getAudioSample(float[] left, float[] right, AudioFormat format, int bufferSize);
  
  /**
   * Should return a {@link SampleRecorder} that can record the <code>source</code> in a 
   * buffered (in-memory) or non-buffered (streamed) manner, to the file specified by <code>saveTo</code> 
   * @param source the audio source that should be recorded
   * @param saveTo the file to save the recorded audio to
   * @param buffered whether or not to buffer all recorded audio in memory or stream directly to the file
   * @return an appropriate SampleRecorder
   */
  SampleRecorder getSampleRecorder(Recordable source, String saveTo, boolean buffered);
}
