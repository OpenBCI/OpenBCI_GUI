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

import ddf.minim.spi.AudioRecordingStream;
import ddf.minim.spi.SampleRecorder;


/**
 * An <code>AudioRecorder</code> can be used to record audio that is being
 * played by a <code>Recordable</code> object such as an <code>AudioOutput</code>, 
 * <code>AudioInput</code>, or <code>AudioPlayer</code>. An <code>AudioRecorder</code>
 * need not necessarily record to disk, but the recorders you receive from
 * Minim's createRecorder method will do so.
 * 
 * @example Advanced/RecordAndPlayback
 * 
 * @author Damien Di Fede
 * 
 */

public class AudioRecorder
{
  private Recordable source;
  private SampleRecorder recorder;

  /** @invisible 
   * 
   * Constructs an <code>AudioRecorder</code> that will use
   * <code>recorder</code> to record <code>recordSource</code>.
   * You might use this if you want to implement your own SampleRecorder
   * that can encode to file types not available in Minim.
   * 
   * @param recordSource
   *          the <code>Recordable</code> object to record
   * @param recorder
   *          the <code>SampleRecorder</code> to use to record it
   */
  public AudioRecorder(Recordable recordSource, SampleRecorder recorder)
  {
    source = recordSource;
    this.recorder = recorder;
    source.addListener(recorder);
  }

  /**
   * Begins recording audio from the current record source. If recording was
   * previously halted, and the save method was not called, samples will be
   * appended to the end of the material recorded so far.
   * 
   * @shortdesc Begins recording audio from the current record source.
   * 
   * @example Advanced/RecordAndPlayback
   * 
   * @related AudioRecorder
   */
  public void beginRecord()
  {
    recorder.beginRecord();
  }

  /**
   * Halts the recording of audio from the current record source.
   * 
   * @example Advanced/RecordAndPlayback
   * 
   * @related AudioRecorder
   */
  public void endRecord()
  {
    recorder.endRecord();
  }

  /**
   * Returns the current record state.
   * 
   * @return true if this is currently recording
   * 
   * @example Advanced/RecordAndPlayback
   * 
   * @related AudioRecorder
   */
  public boolean isRecording()
  {
    return recorder.isRecording();
  }

  /**
   * Requests that the recorder saves. This will only
   * work if you have called the endRecord method. If this was created with a
   * buffered recorder, then calling the beginRecord method after saving will
   * not overwrite the file on the disk, unless this method is subsequently
   * called. However, if this was created with an unbuffered recorder, it is
   * likely that a call to the beginRecord method will create the file again,
   * overwriting the file that had previously been saved. An
   * <code>AudioRecordingStream</code> will be returned if the
   * <code>SampleRecorder</code> used to record the audio saved to a file
   * (this will always be the case if you use <code>createRecorder</code> or
   * the first constructor for <code>AudioRecorder</code>).
   * 
   * @shortdesc Requests that the recorder saves.
   * 
   * @return the audio that was recorded as an <code>AudioRecordingStream</code>
   * 
   * @example Advanced/RecordAndPlayback
   * 
   * @related AudioRecorder
   */
  // TODO: this should return whatever our "file handle" interface winds up being.
  public AudioRecordingStream save()
  {
    return recorder.save();
  }

  /**
   * Sets the record source for this recorder. The record source can be set at
   * any time, but if you are in the middle of recording it is a good idea to mute the old
   * record source, then add the new record source, also muted, and then unmute
   * the new record source. Otherwise, you'll probably wind up with a pop in the
   * recording.
   * 
   * @shortdesc Sets the record source for this recorder.
   * 
   * @param recordSource
   *          an AudioSample, AudioPlayer, AudioInput, or AudioOutput
   *          
   * @related AudioRecorder
   */
  public void setRecordSource(Recordable recordSource)
  {
    source.removeListener(recorder);
    source = recordSource;
    source.addListener(recorder);
  }

  /** @invisible 
   * Sets the <code>SampleRecorder</code> for this recorder. Similar caveats
   * apply as with {@link #setRecordSource(Recordable)}. This calls
   * <code>endRecord</code> and <code>save</code> on the current
   * <code>SampleRecorder</code> before setting the new one.
   * 
   * @param recorder
   *          the new <code>SampleRecorder</code> to use
   */
  public void setSampleRecorder(SampleRecorder recorder)
  {
    this.recorder.endRecord();
    this.recorder.save();
    source.removeListener(this.recorder);
    source.addListener(recorder);
    this.recorder = recorder;
  }
}
