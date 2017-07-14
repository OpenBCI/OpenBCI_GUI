package ddf.minim.ugens;

import java.util.Arrays;

import ddf.minim.AudioMetaData;
import ddf.minim.Minim;
import ddf.minim.MultiChannelBuffer;
import ddf.minim.Playable;
import ddf.minim.UGen;
import ddf.minim.spi.AudioRecordingStream;

/**
 * The FilePlayer UGen provides a way for you to play audio files in the same 
 * way that AudioPlayer does, allowing you to patch them into a UGen graph any way you choose.
 * The constructor for FilePlayer takes an AudioRecordingStream,
 * which you can get from a Minim object by calling the loadFileStream method.
 * 
 * @example Synthesis/filePlayerExample
 * 
 * @author Damien Di Fede
 * 
 * @related Minim
 * @related AudioPlayer
 * @related UGen
 *
 */

public class FilePlayer extends UGen implements Playable
{
	private AudioRecordingStream mFileStream;
	private boolean 			 isPaused;
	// buffer we use to read from the stream
	private MultiChannelBuffer   buffer;
	// where in the buffer we should read the next sample from
	private int 				 bufferOutIndex;
	
	/**
	 * Construct a FilePlayer that will read from iFileStream.
	 * 
	 * @param iFileStream 
	 * 			AudioRecordingStream: the stream this should read from
	 * 
	 * @example Synthesis/filePlayerExample
	 */
	public FilePlayer( AudioRecordingStream iFileStream )
	{
		mFileStream 	= iFileStream;
		buffer 			= new MultiChannelBuffer(1024, mFileStream.getFormat().getChannels());
		bufferOutIndex 	= 0;
		
		// we'll need to do this eventually, I think.
		// but for now we don't need this because it starts the iothread,
		// which is not what we want.
		// mFileStream.open();	
		// mFileStream.play();
	}
	
	/**
	 * Returns the underlying AudioRecordingStream.
	 * 
	 * @return AudioRecordingStream: the underlying stream
	 * 
	 * @related Minim
	 * @related AudioRecordingStream
	 * @related FilePlayer
	 */
	public AudioRecordingStream getStream()
	{
		return mFileStream;
	}
	
	/**
	   * Starts playback from the current position. 
	   * If this was previously set to loop, looping will be disabled.
	   * 
	   * @example Synthesis/filePlayerExample
	   * 
	   * @related FilePlayer
	   * 
	   */
	public void play()
	{
		mFileStream.play();
		isPaused = false;
	}

	/**
	   * Starts playback <code>millis</code> from the beginning. 
	   * If this was previously set to loop, looping will be disabled.
	   * 
	   * @param millis
	   * 		int: where to start playing the file, in milliseconds
	   * 
	   * @related FilePlayer
	   */
	public void play(int millis)
	{
		cue(millis);
		play();
	}

	/**
	   * Pauses playback.
	   * 
	   * @example Synthesis/filePlayerExample
	   * 
	   * @related FilePlayer
	   */
	public void pause()
	{
		mFileStream.pause();
		isPaused = true;
	}

	/**
	   * Rewinds to the beginning. This <i>does not</i> stop playback.
	   * 
	   * @related FilePlayer
	   */
	public void rewind()
	{
		cue(0);
	}

	/**
	   * Sets looping to continuous. If this is already playing, the position
	   * <i>will not</i> be reset to the beginning. If this is not playing,
	   * it will start playing.
	   * 
	   * @shortdesc Start looping playback of the file.
	   * 
	   * @example Synthesis/filePlayerExample
	   * 
	   * @related loopCount ( )
	   * @related setLoopPoints ( )
	   * @related isLooping ( )
	   * @related FilePlayer
	   */
	public void loop()
	{
		loop(Minim.LOOP_CONTINUOUSLY);
	}

	/**
	   * Sets this to loop <code>loopCount</code> times. 
	   * If this is already playing, 
	   * the position <i>will not</i> be reset to the beginning. 
	   * If this is not playing, it will start playing.
	   * 
	   * @shortdesc Sets this to loop <code>loopCount</code> times.
	   * 
	   * @param loopCount
	   *          int: the number of times to loop
	   *          
	   * @related loopCount ( )
	   * @related setLoopPoints ( )
	   * @related isLooping ( )
	   * @related FilePlayer
	   */
	public void loop(int loopCount)
	{
		if ( isPaused )
		{
			int pos = mFileStream.getMillisecondPosition();
			mFileStream.loop( loopCount );
			cue( pos );
		}
		else
		{
			mFileStream.loop(loopCount);
		}
		
		isPaused = false;
	}

	/**
	   * Returns the number of loops left to do. 
	   * 
	   * @return int: the number of loops left
	   * 
	   * @related loop ( )
	   * @related FilePlayer
	   */
	public int loopCount()
	{
		return mFileStream.getLoopCount();
	}

	/**
	   * Returns the length of the sound in milliseconds. If for any reason the 
	   * length could not be determined, this will return -1. However, an unknown 
	   * length should not impact playback.
	   * 
	   * @shortdesc Returns the length of the sound in milliseconds.
	   * 
	   * @return int: the length of the sound in milliseconds
	   * 
	   * @related FilePlayer
	   */
	public int length()
	{
		return mFileStream.getMillisecondLength();
	}

	/**
	   * Returns the current position of the "playhead" (ie how much of
	   * the sound has already been played)
	   * 
	   * @return int: the current position of the "playhead", in milliseconds
	   * 
	   * @related FilePlayer
	   */
	public int position()
	{
		return mFileStream.getMillisecondPosition();
	}

	/**
	   * Sets the position to <code>millis</code> milliseconds from
	   * the beginning. This will not change the play state. If an error
	   * occurs while trying to cue, the position will not change. 
	   * If you try to cue to a negative position or try to a position 
	   * that is greater than <code>length()</code>, the amount will be clamped 
	   * to zero or <code>length()</code>.
	   * 
	   * @shortdesc Sets the position to <code>millis</code> milliseconds from
	   * the beginning.
	   * 
	   * @param millis int: the position to place the "playhead", in milliseconds
	   * 
	   * @related FilePlayer
	   */
	public void cue(int millis)
	{
		if (millis < 0)
		{
			millis = 0;
		}
		else if (millis > length())
		{
			millis = length();
		}
		mFileStream.setMillisecondPosition(millis);
		// change the position in the stream invalidates our buffer, so we read a new buffer
		fillBuffer();
	}

	/**
	   * Skips <code>millis</code> from the current position. <code>millis</code> 
	   * can be negative, which will make this skip backwards. If the skip amount 
	   * would result in a negative position or a position that is greater than 
	   * <code>length()</code>, the new position will be clamped to zero or 
	   * <code>length()</code>.
	   * 
	   * @shortdesc Skips <code>millis</code> from the current position.
	   * 
	   * @param millis 
	   * 		 	int: how many milliseconds to skip, sign indicates direction
	   * 
	   * @related FilePlayer
	   */
	public void skip(int millis)
	{
		int pos = position() + millis;
		if (pos < 0)
		{
			pos = 0;
		}
		else if (pos > length())
		{
			pos = length();
		}
		//Minim.debug("AudioPlayer.skip: skipping " + millis + " milliseconds, new position is " + pos);
		cue( pos );
	}

	/**
	   * Returns true if this is currently playing and has more than one loop 
	   * left to play.
	   * 
	   * @return boolean: true if this is looping
	   * 
	   * @related loop ( )
	   * @related FilePlayer
	   */
	public boolean isLooping()
	{
		return mFileStream.getLoopCount() != 0;
	}

	/**
	   * Returns true if this currently playing.
	   * 
	   * @return boolean: the current play state
	   * 
	   * @example Synthesis/filePlayerExample
	   * 
	   * @related play ( )
	   * @related pause ( )
	   * @related FilePlayer
	   */
	public boolean isPlaying()
	{
		return mFileStream.isPlaying();
	}

	/**
	 * Returns the meta data for the recording being played by this player.
	 * 
	 * @return 
	 * 		AudioMetaData: the meta data for this player's recording
	 * 
	 * @related AudioMetaData
	 * @related FilePlayer
	 */
	public AudioMetaData getMetaData()
	{
		return mFileStream.getMetaData();
	}

	/**
	   * Sets the loop points used when looping.
	   * 
	   * @param start 
	   * 			int: the start of the loop in milliseconds
	   * @param stop 
	   * 			int: the end of the loop in milliseconds
	   * 
	   * @related loop ( )
	   * @related FilePlayer
	   */
	public void setLoopPoints(int start, int stop)
	{
		mFileStream.setLoopPoints(start, stop);
	}
	
	/**
	 * Calling close will close the AudioRecordingStream that this wraps, 
	 * which is proper cleanup for using the stream.
	 * 
	 * @related FilePlayer
	 */
	public void close()
	{
		mFileStream.close();
	}
	
	private void fillBuffer()
	{
		mFileStream.read(buffer);
		bufferOutIndex = 0;
	}
	
	@Override
	protected void uGenerate(float[] channels) 
	{
		if ( mFileStream.isPlaying() )
		{
			// special case: mono expands out to all channels.
			if ( buffer.getChannelCount() == 1 )
			{
				Arrays.fill( channels, buffer.getSample( 0, bufferOutIndex ) );
			}
			// we have more than one channel, don't try to fill larger channel requests
			if ( buffer.getChannelCount() <= channels.length )
			{
				for(int i = 0 ; i < channels.length; ++i)
				{
					channels[i] = buffer.getSample( i, bufferOutIndex );
				}
			}
			// special case: we are stereo, output is mono.
			else if ( channels.length == 1 && buffer.getChannelCount() == 2 )
			{
				channels[0] = (buffer.getSample( 0, bufferOutIndex ) + buffer.getSample( 1, bufferOutIndex ))/2.0f;
			}
			
			++bufferOutIndex;
			if ( bufferOutIndex == buffer.getBufferSize() )
			{
				fillBuffer();
			}
		}
		else
		{
			Arrays.fill( channels, 0 );
		}
	}

}
