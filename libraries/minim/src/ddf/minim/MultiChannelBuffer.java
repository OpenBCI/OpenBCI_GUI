package ddf.minim;

/**
 * MultiChannelBuffer represents a chunk of multichannel (or mono) audio data.
 * It is primarily used internally when passing buffers of audio around, but 
 * you will need to create one to use things like the loadFileIntoBuffer method of Minim
 * and the setSample method of Sampler. When thinking about a buffer of audio
 * we usually consider how many <em>sample frames</em> long that buffer is. This 
 * is not the same as the actual number of values stored in the buffer. Mono, or 
 * single channel audio, contains one sample per sample frame, but stereo is
 * two, quadraphonic is four, and so forth. The buffer size of a MultiChannelBuffer
 * is how many sample frames it stores, so when retrieving and setting values
 * it is required to indicate which channel should be operated upon. 
 * 
 * @example Advanced/loadFileIntoBuffer
 * 
 * @related Minim
 * 
 * @author Damien Di Fede
 *
 */

public class MultiChannelBuffer 
{
	// TODO: consider just wrapping a FloatSampleBuffer
	private float[][]	channels;
	private int 		bufferSize;
	
	/**
	 * Construct a MultiChannelBuffer, providing a size and number of channels.
	 * 
	 * @param bufferSize
	 * 			int: The length of the buffer in sample frames.
	 * @param numChannels
	 * 			int: The number of channels the buffer should contain.
	 */
	public MultiChannelBuffer(int bufferSize, int numChannels)
	{
		channels = new float[numChannels][bufferSize];
		this.bufferSize = bufferSize;
	}
	
	/**
	 * Copy the data in the provided MultiChannelBuffer to this MultiChannelBuffer.
	 * Doing so will change both the buffer size and channel count of this
	 * MultiChannelBuffer to be the same as the copied buffer.
	 * 
	 * @shortdesc Copy the data in the provided MultiChannelBuffer to this MultiChannelBuffer.
	 * 
	 * @param otherBuffer
	 * 			the MultiChannelBuffer to copy
	 */
	public void set( MultiChannelBuffer otherBuffer )
	{
		bufferSize = otherBuffer.bufferSize;
		channels   = otherBuffer.channels.clone();
	}
	
	/**
	 * Returns the length of this buffer in samples.
	 * 
	 * @return the length of this buffer in samples
	 */
	public int getBufferSize()
	{
		return bufferSize;
	}
	
	/**
	 * Returns the number of channels in this buffer.
	 * 
	 * @return the number of channels in this buffer
	 */
	public int getChannelCount()
	{
		return channels.length;
	}
	
	/**
	 * Returns the value of a sample in the given channel,
	 * at the given offset from the beginning of the buffer.
	 * When sampleIndex is a float, this returns an interpolated
	 * sample value. For instance, getSample( 0, 30.5f ) will 
	 * return an interpolated sample value in channel 0 that is 
	 * between the value at 30 and the value at 31. 
	 * 
	 * @shortdesc Returns the value of a sample in the given channel,
	 * at the given offset from the beginning of the buffer.
	 * 
	 * @param channelNumber
	 * 			int: the channel to get the sample value from
	 * @param sampleIndex
	 * 			int: the offset from the beginning of the buffer, in samples.
	 * @return
	 * 			float: the value of the sample
	 */
	public float getSample( int channelNumber, int sampleIndex )
	{
		return channels[channelNumber][sampleIndex];
	}
	
	/**
	 * Returns the interpolated value of a sample in the given channel,
	 * at the given offset from the beginning of the buffer, 
	 * For instance, getSample( 0, 30.5f ) will 
	 * return an interpolated sample value in channel 0 that is 
	 * between the value at 30 and the value at 31. 
	 * 
	 * @param channelNumber
	 * 			int: the channel to get the sample value from
	 * @param sampleIndex
	 * 			float: the offset from the beginning of the buffer, in samples.
	 * @return
	 * 			float: the value of the sample
	 */
	public float getSample( int channelNumber, float sampleIndex )
	{
		  int lowSamp = (int)sampleIndex;
		  int hiSamp = lowSamp + 1;
		  if ( hiSamp == bufferSize )
		  {
			  return channels[channelNumber][lowSamp];
		  }
		  float lerp = sampleIndex - lowSamp;
		  return channels[channelNumber][lowSamp] + lerp*(channels[channelNumber][hiSamp] - channels[channelNumber][lowSamp]);
	}
	
	/**
	 * Sets the value of a sample in the given channel at the given
	 * offset from the beginning of the buffer.
	 * 
	 * @param channelNumber
	 * 			int: the channel of the buffer
	 * @param sampleIndex
	 * 			int: the sample offset from the beginning of the buffer
	 * @param value
	 * 			float: the sample value to set
	 */
	public void setSample( int channelNumber, int sampleIndex, float value )
	{
		channels[channelNumber][sampleIndex] = value;
	}
	
	/**
	 * Returns the requested channel as a float array.
	 * You should not necessarily assume that the 
	 * modifying the returned array will modify 
	 * the values in this buffer.
	 * 
	 * @shortdesc Returns the requested channel as a float array.
	 * 
	 * @param channelNumber
	 * 			int: the channel to return
	 * @return
	 * 			float[]: the channel represented as a float array
	 */
	public float[] getChannel(int channelNumber)
	{
		return channels[channelNumber];
	}
	
	/**
	 * Sets all of the values in a particular channel using 
	 * the values of the provided float array. The array
	 * should be at least as long as the current buffer size
	 * of this buffer and this will only copy as many samples
	 * as fit into its current buffer size.
	 * 
	 * @shortdesc Sets all of the values in a particular channel using 
	 * the values of the provided float array.
	 * 
	 * @param channelNumber
	 * 			int: the channel to set
	 * @param samples
	 * 			float[]: the array of values to copy into the channel
	 */
	public void setChannel(int channelNumber, float[] samples)
	{
		System.arraycopy( samples, 0, channels[channelNumber], 0, bufferSize );
	}
	
	/**
	 * Set the number of channels this buffer contains.
	 * Doing this will retain any existing channels 
	 * under the new channel count.
	 * 
	 * @shortdesc Set the number of channels this buffer contains.
	 * 
	 * @param numChannels
	 * 			int: the number of channels this buffer should contain
	 */
	public void setChannelCount(int numChannels)
	{
		if ( channels.length != numChannels )
		{
			float[][] newChannels = new float[numChannels][bufferSize];
			for( int c = 0; c < channels.length && c < numChannels; ++c )
			{
				newChannels[c] = channels[c];
			}
			channels = newChannels;
		}
	}
	
	/**
	 * Set the length of this buffer in sample frames.
	 * Doing this will retain all of the sample data 
	 * that can fit into the new buffer size.
	 * 
	 * @shortdesc Set the length of this buffer in sample frames.
	 * 
	 * @param bufferSize
	 * 			int: the new length of this buffer in sample frames
	 */
	public void setBufferSize(int bufferSize)
	{
		if ( this.bufferSize != bufferSize )
		{
			this.bufferSize = bufferSize;
			for( int i = 0; i < channels.length; ++i )
			{
				float[] newChannel = new float[bufferSize];
				// copy existing data into the new channel array
				System.arraycopy( channels[i], 0, newChannel, 0, (bufferSize < channels[i].length ? bufferSize : channels[i].length) ); 
				channels[i] = newChannel;
			}
		}
	}
}
