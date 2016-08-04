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

import ddf.minim.AudioListener;

/**
 * <code>SampleRecorder</code> is an interface that describes the limited 
 * set of functionality required of an object that records samples. It is 
 * not required that the <code>SampleRecorder</code> records to disk, though 
 * the implementations in Minim do so.
 *  
 * @author Damien Di Fede
 *
 */

public interface SampleRecorder extends AudioListener
{
  /**
   * Returns the full path to the file this is saving to, if it exists.
   * If this is not saving to a file, an empty <code>String</code> will be 
   * returned.
   *   
   * @return the full path to the file or an empty String
   */
  String filePath();
  
  /**
   * Begins recording.
   *
   */
  void beginRecord();
  
  /**
   * Halts recording.
   *
   */
  void endRecord();
  
  /**
   * Returns the current record state.
   * 
   * @return true if this is recording
   */
  boolean isRecording();
  
  /**
   * Saves the recorded samples, probably to disk. 
   * Returns the recorded audio as an AudioRecordingStream.
   *
   */
  AudioRecordingStream save();
}
