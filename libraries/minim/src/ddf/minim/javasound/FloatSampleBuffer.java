/*
 * FloatSampleBuffer.java
 *
 *	This file is part of Tritonus: http://www.tritonus.org/
 */

/*
 *  Copyright (c) 2000-2006 by Florian Bomers <http://www.bomers.de>
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

/*
 |<---            this code is formatted to fit into 80 columns             --->|
 */

package ddf.minim.javasound;

import javax.sound.sampled.AudioFormat;

/**
 * A class for small buffers of samples in linear, 32-bit floating point format.
 * <p>
 * It is supposed to be a replacement of the byte[] stream architecture of
 * JavaSound, especially for chains of AudioInputStreams. Ideally, all involved
 * AudioInputStreams handle reading into a FloatSampleBuffer.
 * <p>
 * Specifications:
 * <ol>
 * <li>Channels are separated, i.e. for stereo there are 2 float arrays with
 * the samples for the left and right channel
 * <li>All data is handled in samples, where one sample means one float value
 * in each channel
 * <li>All samples are normalized to the interval [-1.0...1.0]
 * </ol>
 * <p>
 * When a cascade of AudioInputStreams use FloatSampleBuffer for processing,
 * they may implement the interface FloatSampleInput. This signals that this
 * stream may provide float buffers for reading. The data is <i>not</i>
 * converted back to bytes, but stays in a single buffer that is passed from
 * stream to stream. For that serves the read(FloatSampleBuffer) method, which
 * is then used as replacement for the byte-based read functions of
 * AudioInputStream.<br>
 * However, backwards compatibility must always be retained, so even when an
 * AudioInputStream implements FloatSampleInput, it must work the same way when
 * any of the byte-based read methods is called.<br>
 * As an example, consider the following set-up:<br>
 * <ul>
 * <li>auAIS is an AudioInputStream (AIS) that reads from an AU file in 8bit
 * pcm at 8000Hz. It does not implement FloatSampleInput.
 * <li>pcmAIS1 is an AIS that reads from auAIS and converts the data to PCM
 * 16bit. This stream implements FloatSampleInput, i.e. it can generate float
 * audio data from the ulaw samples.
 * <li>pcmAIS2 reads from pcmAIS1 and adds a reverb. It operates entirely on
 * floating point samples.
 * <li>The method that reads from pcmAIS2 (i.e. AudioSystem.write) does not
 * handle floating point samples.
 * </ul>
 * So, what happens when a block of samples is read from pcmAIS2 ?
 * <ol>
 * <li>the read(byte[]) method of pcmAIS2 is called
 * <li>pcmAIS2 always operates on floating point samples, so it uses an own
 * instance of FloatSampleBuffer and initializes it with the number of samples
 * requested in the read(byte[]) method.
 * <li>It queries pcmAIS1 for the FloatSampleInput interface. As it implements
 * it, pcmAIS2 calls the read(FloatSampleBuffer) method of pcmAIS1.
 * <li>pcmAIS1 notes that its underlying stream does not support floats, so it
 * instantiates a byte buffer which can hold the number of samples of the
 * FloatSampleBuffer passed to it. It calls the read(byte[]) method of auAIS.
 * <li>auAIS fills the buffer with the bytes.
 * <li>pcmAIS1 calls the <code>initFromByteArray</code> method of the float
 * buffer to initialize it with the 8 bit data.
 * <li>Then pcmAIS1 processes the data: as the float buffer is normalized, it
 * does nothing with the buffer - and returns control to pcmAIS2. The
 * SampleSizeInBits field of the AudioFormat of pcmAIS1 defines that it should
 * be 16 bits.
 * <li>pcmAIS2 receives the filled buffer from pcmAIS1 and does its processing
 * on the buffer - it adds the reverb.
 * <li>As pcmAIS2's read(byte[]) method had been called, pcmAIS2 calls the
 * <code>convertToByteArray</code> method of the float buffer to fill the byte
 * buffer with the resulting samples.
 * </ol>
 * <p>
 * To summarize, here are some advantages when using a FloatSampleBuffer for
 * streaming:
 * <ul>
 * <li>no conversions from/to bytes need to be done during processing
 * <li>the sample size in bits is irrelevant - normalized range
 * <li>higher quality for processing
 * <li>separated channels (easy process/remove/add channels)
 * <li>potentially less copying of audio data, as processing the float samples
 * is generally done in-place. The same instance of a FloatSampleBuffer may be
 * used from the original data source to the final data sink.
 * </ul>
 * <p>
 * Simple benchmarks showed that the processing requirements for the conversion
 * to and from float is about the same as when converting it to shorts or ints
 * without dithering, and significantly higher with dithering. An own
 * implementation of a random number generator may improve this.
 * <p>
 * &quot;Lazy&quot; deletion of samples and channels:<br>
 * <ul>
 * <li>When the sample count is reduced, the arrays are not resized, but only
 * the member variable <code>sampleCount</code> is reduced. A subsequent
 * increase of the sample count (which will occur frequently), will check that
 * and eventually reuse the existing array.
 * <li>When a channel is deleted, it is not removed from memory but only
 * hidden. Subsequent insertions of a channel will check whether a hidden
 * channel can be reused.
 * </ul>
 * The lazy mechanism can save many array instantiation (and copy-) operations
 * for the sake of performance. All relevant methods exist in a second version
 * which allows explicitely to disable lazy deletion.
 * <p>
 * Use the <code>reset</code> functions to clear the memory and remove hidden
 * samples and channels.
 * <p>
 * Note that the lazy mechanism implies that the arrays returned from
 * <code>getChannel(int)</code> may have a greater size than getSampleCount().
 * Consequently, be sure to never rely on the length field of the sample arrays.
 * <p>
 * As an example, consider a chain of converters that all act on the same
 * instance of FloatSampleBuffer. Some converters may decrease the sample count
 * (e.g. sample rate converter) and delete channels (e.g. PCM2PCM converter).
 * So, processing of one block will decrease both. For the next block, all
 * starts from the beginning. With the lazy mechanism, all float arrays are only
 * created once for processing all blocks.<br>
 * Having lazy disabled would require for each chunk that is processed
 * <ol>
 * <li>new instantiation of all channel arrays at the converter chain beginning
 * as they have been either deleted or decreased in size during processing of
 * the previous chunk, and
 * <li>re-instantiation of all channel arrays for the reduction of the sample
 * count.
 * </ol>
 * <p>
 * Dithering:<br>
 * By default, this class uses dithering for reduction of sample width (e.g.
 * original data was 16bit, target data is 8bit). As dithering may be needed in
 * other cases (especially when the float samples are processed using DSP
 * algorithms), or it is preferred to switch it off, dithering can be
 * explicitely switched on or off with the method setDitherMode(int).<br>
 * For a discussion about dithering, see <a
 * href="http://www.iqsoft.com/IQSMagazine/BobsSoapbox/Dithering.htm"> here</a>
 * and <a href="http://www.iqsoft.com/IQSMagazine/BobsSoapbox/Dithering2.htm">
 * here</a>.
 * 
 * @author Florian Bomers
 */

public class FloatSampleBuffer {

	/** Whether the functions without lazy parameter are lazy or not. */
	private static final boolean LAZY_DEFAULT = true;

	// one float array for each channel
	private Object[] channels = new Object[2];
	private int sampleCount = 0;
	private int channelCount = 0;
	private float sampleRate = 0;
	private int originalFormatType = 0;

	/**
	 * Constant for setDitherMode: dithering will be enabled if sample size is
	 * decreased
	 */
	public static final int DITHER_MODE_AUTOMATIC = 0;
	/** Constant for setDitherMode: dithering will be done */
	public static final int DITHER_MODE_ON = 1;
	/** Constant for setDitherMode: dithering will not be done */
	public static final int DITHER_MODE_OFF = 2;

	private float ditherBits = FloatSampleTools.DEFAULT_DITHER_BITS;

	// e.g. the sample rate converter may want to force dithering
	private int ditherMode = DITHER_MODE_AUTOMATIC;

	// ////////////////////////////// initialization //////////////////////

	/**
	 * Create an instance with initially no channels.
	 */
	public FloatSampleBuffer() {
		this(0, 0, 1);
	}

	/**
	 * Create an empty FloatSampleBuffer with the specified number of channels,
	 * samples, and the specified sample rate.
	 */
	public FloatSampleBuffer(int channelCount, int sampleCount, float sampleRate) {
		init(channelCount, sampleCount, sampleRate, LAZY_DEFAULT);
	}

	/**
	 * Creates a new instance of FloatSampleBuffer and initializes it with audio
	 * data given in the interleaved byte array <code>buffer</code>.
	 */
	public FloatSampleBuffer(byte[] buffer, int offset, int byteCount,
			AudioFormat format) {
		this(format.getChannels(), byteCount
				/ (format.getSampleSizeInBits() / 8 * format.getChannels()),
				format.getSampleRate());
		initFromByteArray(buffer, offset, byteCount, format);
	}

	/**
	 * Initialize this sample buffer to have the specified channels, sample
	 * count, and sample rate. If LAZY_DEFAULT is true, as much as possible will
	 * existing arrays be reused. Otherwise, any hidden channels are freed.
	 * 
	 * @param newChannelCount
	 * @param newSampleCount
	 * @param newSampleRate
	 * @throws IllegalArgumentException if newChannelCount or newSampleCount are
	 *             negative, or newSampleRate is not positive.
	 */
	public void init(int newChannelCount, int newSampleCount,
			float newSampleRate) {
		init(newChannelCount, newSampleCount, newSampleRate, LAZY_DEFAULT);
	}

	/**
	 * Initialize this sample buffer to have the specified channels, sample
	 * count, and sample rate. If lazy is true, as much as possible will
	 * existing arrays be reused. Otherwise, any hidden channels are freed.
	 * 
	 * @param newChannelCount
	 * @param newSampleCount
	 * @param newSampleRate
	 * @param lazy
	 * @throws IllegalArgumentException if newChannelCount or newSampleCount are
	 *             negative, or newSampleRate is not positive.
	 */
	public void init(int newChannelCount, int newSampleCount,
			float newSampleRate, boolean lazy) {
		if (newChannelCount < 0 || newSampleCount < 0 || newSampleRate <= 0.0f) {
			throw new IllegalArgumentException(
					"invalid parameters in initialization of FloatSampleBuffer.");
		}
		setSampleRate(newSampleRate);
		if (this.sampleCount != newSampleCount
				|| this.channelCount != newChannelCount) {
			createChannels(newChannelCount, newSampleCount, lazy);
		}
	}

	/**
	 * Verify that the specified AudioFormat can be converted to and from. If
	 * the format is not supported, an IllegalArgumentException is thrown.
	 * 
	 * @throws IllegalArgumentException if the format is not supported
	 */
	public static void checkFormatSupported(AudioFormat format) {
		FloatSampleTools.getFormatType(format);
	}

	/**
	 * Grow the channels array to allow at least channelCount elements. If
	 * !lazy, then channels will be resized to be exactly channelCount elements.
	 * The new elements will be null.
	 * 
	 * @param newChannelCount
	 * @param lazy
	 */
	private final void grow(int newChannelCount, boolean lazy) {
		if (channels.length < newChannelCount || !lazy) {
			Object[] newChannels = new Object[newChannelCount];
			System.arraycopy(channels, 0, newChannels, 0,
					(channelCount < newChannelCount) ? channelCount
							: newChannelCount);
			this.channels = newChannels;
		}
	}

	private final void createChannels(int newChannelCount, int newSampleCount,
			boolean lazy) {
		// shortcut
		if (lazy && newChannelCount <= channelCount
				&& newSampleCount <= this.sampleCount) {
			setSampleCountImpl(newSampleCount);
			setChannelCountImpl(newChannelCount);
			return;
		}
		setSampleCountImpl(newSampleCount);
		// grow the array, if necessary. Intentionally lazy here!
		grow(newChannelCount, true);
		// lazy delete of all channels. Intentionally lazy !
		setChannelCountImpl(0);
		for (int ch = 0; ch < newChannelCount; ch++) {
			insertChannel(ch, false, lazy);
		}
		// if not lazy, remove hidden channels
		grow(newChannelCount, lazy);
	}

	/**
	 * Resets this buffer with the audio data specified in the arguments. This
	 * FloatSampleBuffer's sample count will be set to
	 * <code>byteCount / format.getFrameSize()</code>. If LAZY_DEFAULT is
	 * true, it will use lazy deletion.
	 * 
	 * @throws IllegalArgumentException
	 */
	public void initFromByteArray(byte[] buffer, int offset, int byteCount,
			AudioFormat format) {
		initFromByteArray(buffer, offset, byteCount, format, LAZY_DEFAULT);
	}

	/**
	 * Resets this buffer with the audio data specified in the arguments. This
	 * FloatSampleBuffer's sample count will be set to
	 * <code>byteCount / format.getFrameSize()</code>.
	 * 
	 * @param lazy if true, then existing channels will be tried to be re-used
	 *            to minimize garbage collection.
	 * @throws IllegalArgumentException
	 */
	public void initFromByteArray(byte[] buffer, int offset, int byteCount,
			AudioFormat format, boolean lazy) {
		if (offset + byteCount > buffer.length) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer.initFromByteArray: buffer too small.");
		}

		int thisSampleCount = byteCount / format.getFrameSize();
		init(format.getChannels(), thisSampleCount, format.getSampleRate(),
				lazy);

		// save format for automatic dithering mode
		originalFormatType = FloatSampleTools.getFormatType(format);

		FloatSampleTools.byte2float(buffer, offset, channels, 0, sampleCount,
				format);
	}

	/**
	 * Resets this sample buffer with the data in <code>source</code>.
	 */
	public void initFromFloatSampleBuffer(FloatSampleBuffer source) {
		init(source.getChannelCount(), source.getSampleCount(),
				source.getSampleRate());
		for (int ch = 0; ch < getChannelCount(); ch++) {
			System.arraycopy(source.getChannel(ch), 0, getChannel(ch), 0,
					sampleCount);
		}
	}
	
	/**
	 * Write the contents of the byte array to this buffer, overwriting existing
	 * data. If the byte array has fewer channels than this float buffer, only
	 * the first channels are written. Vice versa, if the byte buffer has more
	 * channels than this float buffer, only the first channels of the byte
	 * buffer are written to this buffer.
	 * <p>
	 * The format and the number of samples of this float buffer are not
	 * changed, so if the byte array has more samples than fit into this float
	 * buffer, it is not expanded.
	 * 
	 * @param buffer the byte buffer to write to this float buffer
	 * @param srcByteOffset the offset in bytes in buffer where to start reading
	 * @param format the audio format of the bytes in buffer
	 * @param dstSampleOffset the offset in samples where to start writing the
	 *            converted float data into this float buffer
	 * @param aSampleCount the number of samples to write
	 * @return the number of samples actually written
	 */
	public int writeByteBuffer(byte[] buffer, int srcByteOffset,
			AudioFormat format, int dstSampleOffset, int aSampleCount) {
		if (dstSampleOffset + aSampleCount > getSampleCount()) {
			aSampleCount = getSampleCount() - dstSampleOffset;
		}
		int lChannels = format.getChannels();
		if (lChannels > getChannelCount()) {
			lChannels = getChannelCount();
		}
		if (lChannels > format.getChannels()) {
			lChannels = format.getChannels();
		}
		for (int channel = 0; channel < lChannels; channel++) {
			float[] data = getChannel(channel);

			FloatSampleTools.byte2floatGeneric(buffer, srcByteOffset,
					format.getFrameSize(), data, dstSampleOffset, aSampleCount,
					format);
			srcByteOffset += format.getFrameSize() / format.getChannels();
		}
		return aSampleCount;
	}

	/**
	 * Deletes all channels, frees memory... This also removes hidden channels
	 * by lazy remove.
	 */
	public void reset() {
		init(0, 0, 1, false);
	}

	/**
	 * Destroys any existing data and creates new channels. It also destroys
	 * lazy removed channels and samples. Channels will not be silenced, though.
	 */
	public void reset(int newChannels, int newSampleCount, float newSampleRate) {
		init(newChannels, newSampleCount, newSampleRate, false);
	}

	// //////////////////////// conversion back to bytes ///////////////////

	/**
	 * @return the required size of the buffer for calling
	 *         convertToByteArray(..) is called
	 */
	public int getByteArrayBufferSize(AudioFormat format) {
		return getByteArrayBufferSize(format, getSampleCount());
	}

	/**
	 * @param lenInSamples how many samples to be considered
	 * @return the required size of the buffer for the given number of samples
	 *         for calling convertToByteArray(..)
	 */
	public int getByteArrayBufferSize(AudioFormat format, int lenInSamples) {
		// make sure this format is supported
		checkFormatSupported(format);
		return format.getFrameSize() * lenInSamples;
	}

	/**
	 * Writes this sample buffer's audio data to <code>buffer</code> as an
	 * interleaved byte array. <code>buffer</code> must be large enough to
	 * hold all data.
	 * 
	 * @throws IllegalArgumentException when buffer is too small or
	 *             <code>format</code> doesn't match
	 * @return number of bytes written to <code>buffer</code>
	 */
	public int convertToByteArray(byte[] buffer, int offset, AudioFormat format) {
		return convertToByteArray(0, getSampleCount(), buffer, offset, format);
	}

	// cache for performance
	private AudioFormat lastConvertToByteArrayFormat = null;
	private int lastConvertToByteArrayFormatCode = 0;

	/**
	 * Writes this sample buffer's audio data to <code>buffer</code> as an
	 * interleaved byte array. <code>buffer</code> must be large enough to
	 * hold all data.
	 * 
	 * @param readOffset the sample offset from where samples are read from this
	 *            FloatSampleBuffer
	 * @param lenInSamples how many samples are converted
	 * @param buffer the byte buffer written to
	 * @param writeOffset the byte offset in buffer
	 * @throws IllegalArgumentException when buffer is too small or
	 *             <code>format</code> doesn't match
	 * @return number of bytes written to <code>buffer</code>
	 */
	public int convertToByteArray(int readOffset, int lenInSamples,
			byte[] buffer, int writeOffset, AudioFormat format) {
		int byteCount = format.getFrameSize() * lenInSamples;
		if (writeOffset + byteCount > buffer.length) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer.convertToByteArray: buffer too small.");
		}
		if (format != lastConvertToByteArrayFormat) {
			if (format.getSampleRate() != getSampleRate()) {
				throw new IllegalArgumentException(
						"FloatSampleBuffer.convertToByteArray: different samplerates.");
			}
			if (format.getChannels() != getChannelCount()) {
				throw new IllegalArgumentException(
						"FloatSampleBuffer.convertToByteArray: different channel count.");
			}
			lastConvertToByteArrayFormat = format;
			lastConvertToByteArrayFormatCode = FloatSampleTools.getFormatType(format);
		}
		FloatSampleTools.float2byte(channels, readOffset, buffer, writeOffset,
				lenInSamples, lastConvertToByteArrayFormatCode,
				format.getChannels(), format.getFrameSize(),
				getConvertDitherBits(lastConvertToByteArrayFormatCode));

		return byteCount;
	}

	/**
	 * Creates a new byte[] buffer, fills it with the audio data, and returns
	 * it.
	 * 
	 * @throws IllegalArgumentException when sample rate or channels do not
	 *             match
	 * @see #convertToByteArray(byte[], int, AudioFormat)
	 */
	public byte[] convertToByteArray(AudioFormat format) {
		// throws exception when sampleRate doesn't match
		// creates a new byte[] buffer and returns it
		byte[] res = new byte[getByteArrayBufferSize(format)];
		convertToByteArray(res, 0, format);
		return res;
	}

	// ////////////////////////////// actions /////////////////////////////////

	/**
	 * Resizes this buffer.
	 * <p>
	 * If <code>keepOldSamples</code> is true, as much as possible samples are
	 * retained. If the buffer is enlarged, silence is added at the end. If
	 * <code>keepOldSamples</code> is false, existing samples may get
	 * discarded, the buffer may then contain random samples.
	 */
	public void changeSampleCount(int newSampleCount, boolean keepOldSamples) {
		int oldSampleCount = getSampleCount();

		// shortcut: if we just make this buffer smaller, just set new
		// sampleCount
		if (oldSampleCount >= newSampleCount) {
			setSampleCountImpl(newSampleCount);
			return;
		}
		// shortcut for one or 2 channels
		if (channelCount == 1 || channelCount == 2) {
			float[] ch = getChannel(0);
			if (ch.length < newSampleCount) {
				float[] newCh = new float[newSampleCount];
				if (keepOldSamples && oldSampleCount > 0) {
					// copy old samples
					System.arraycopy(ch, 0, newCh, 0, oldSampleCount);
				}
				channels[0] = newCh;
			} else if (keepOldSamples) {
				// silence out excess samples (according to the specification)
				for (int i = oldSampleCount; i < newSampleCount; i++) {
					ch[i] = 0.0f;
				}
			}
			if (channelCount == 2) {
				ch = getChannel(1);
				if (ch.length < newSampleCount) {
					float[] newCh = new float[newSampleCount];
					if (keepOldSamples && oldSampleCount > 0) {
						// copy old samples
						System.arraycopy(ch, 0, newCh, 0, oldSampleCount);
					}
					channels[1] = newCh;
				} else if (keepOldSamples) {
					// silence out excess samples (according to the
					// specification)
					for (int i = oldSampleCount; i < newSampleCount; i++) {
						ch[i] = 0.0f;
					}
				}
			}
			setSampleCountImpl(newSampleCount);
			return;
		}

		Object[] oldChannels = null;
		if (keepOldSamples) {
			oldChannels = getAllChannels();
		}
		init(getChannelCount(), newSampleCount, getSampleRate());
		if (keepOldSamples) {
			// copy old channels and eventually silence out new samples
			int copyCount = newSampleCount < oldSampleCount ? newSampleCount
					: oldSampleCount;
			for (int ch = 0; ch < this.channelCount; ch++) {
				float[] oldSamples = (float[]) oldChannels[ch];
				float[] newSamples = (float[]) channels[ch];
				if (oldSamples != newSamples) {
					// if this sample array was not object of lazy delete
					System.arraycopy(oldSamples, 0, newSamples, 0, copyCount);
				}
				if (oldSampleCount < newSampleCount) {
					// silence out new samples
					for (int i = oldSampleCount; i < newSampleCount; i++) {
						newSamples[i] = 0.0f;
					}
				}
			}
		}
	}

	/**
	 * Silence the entire audio buffer.
	 */
	public void makeSilence() {
		makeSilence(0, getSampleCount());
	}

	/**
	 * Silence the entire buffer in the specified range on all channels.
	 */
	public void makeSilence(int offset, int count) {
		if (offset < 0 || (count + offset) > getSampleCount() || count < 0) {
			throw new IllegalArgumentException(
					"offset and/or sampleCount out of bounds");
		}
		// silence all channels
		int localChannelCount = getChannelCount();
		for (int ch = 0; ch < localChannelCount; ch++) {
			makeSilence(getChannel(ch), offset, count);
		}
	}

	/**
	 * Silence the specified channel
	 */
	public void makeSilence(int channel) {
		makeSilence(channel, 0, getSampleCount());
	}

	/**
	 * Silence the specified channel in the specified range
	 */
	public void makeSilence(int channel, int offset, int count) {
		if (offset < 0 || (count + offset) > getSampleCount() || count < 0) {
			throw new IllegalArgumentException(
					"offset and/or sampleCount out of bounds");
		}
		makeSilence(getChannel(channel), offset, count);
	}

	private void makeSilence(float[] samples, int offset, int count) {
		count += offset;
		for (int i = offset; i < count; i++) {
			samples[i] = 0.0f;
		}
	}
	
	/**
	 * Fade the volume level of this buffer from the given start volume to the end volume.
	 * E.g. to implement a fade in, use startVol=0 and endVol=1.
	 * 
	 * @param startVol the start volume as a linear factor [0..1]
	 * @param endVol the end volume as a linear factor [0..1]
	 */
	public void linearFade(float startVol, float endVol) {
		linearFade(startVol, endVol, 0, getSampleCount());
	}

	/**
	 * Fade the volume level of this buffer from the given start volume to the end volume.
	 * The fade will start at the offset, and will have reached endVol after count samples.
	 * E.g. to implement a fade in, use startVol=0 and endVol=1.
	 * 
	 * @param startVol the start volume as a linear factor [0..1]
	 * @param endVol the end volume as a linear factor [0..1]
	 * @param offset the offset in this buffer where to start the fade (in samples)
	 * @param count the number of samples to fade
	 */
	public void linearFade(float startVol, float endVol, int offset, int count) {
		for (int channel = 0; channel < getChannelCount(); channel++) {
			linearFade(channel, startVol, endVol, offset, count);
		}
	}

	/**
	 * Fade the volume level of the specified channel from the given start volume to 
	 * the end volume.
	 * The fade will start at the offset, and will have reached endVol after count 
	 * samples.
	 * E.g. to implement a fade in, use startVol=0 and endVol=1.
	 *
	 * @param channel the channel to do the fade 
	 * @param startVol the start volume as a linear factor [0..1]
	 * @param endVol the end volume as a linear factor [0..1]
	 * @param offset the offset in this buffer where to start the fade (in samples)
	 * @param count the number of samples to fade
	 */
	public void linearFade(int channel, float startVol, float endVol, int offset, int count) {
		if (count <= 0) return;
		float end = count+offset;
		float inc = (endVol - startVol) / count;
		float[] samples = getChannel(channel);
		float curr = startVol;
		for (int i = offset; i < end; i++) {
			samples[i] *= curr;
			curr += inc;
		}
	}

	/** 
	 * Add a channel to this buffer, e.g. adding a channel to a mono buffer will make it a stereo buffer.
	 * 
	 * @param silent if true, the channel is explicitly silenced. Otherwise the new channel may contain random data.
	 */
	public void addChannel(boolean silent) {
		// creates new, silent channel
		insertChannel(getChannelCount(), silent);
	}

	/**
	 * Insert a (silent) channel at position <code>index</code>. If
	 * LAZY_DEFAULT is true, this is done lazily.
	 */
	public void insertChannel(int index, boolean silent) {
		insertChannel(index, silent, LAZY_DEFAULT);
	}

	/**
	 * Inserts a channel at position <code>index</code>.
	 * <p>
	 * If <code>silent</code> is true, the new channel will be silent.
	 * Otherwise it will contain random data.
	 * <p>
	 * If <code>lazy</code> is true, hidden channels which have at least
	 * getSampleCount() elements will be examined for reusage as inserted
	 * channel.<br>
	 * If <code>lazy</code> is false, still hidden channels are reused, but it
	 * is assured that the inserted channel has exactly getSampleCount()
	 * elements, thus not wasting memory.
	 */
	public void insertChannel(int index, boolean silent, boolean lazy) {
		// first grow the array of channels, if necessary. Intentionally lazy
		grow(this.channelCount + 1, true);
		int physSize = channels.length;
		int virtSize = this.channelCount;
		float[] newChannel = null;
		if (physSize > virtSize) {
			// there are hidden channels. Try to use one.
			for (int ch = virtSize; ch < physSize; ch++) {
				float[] thisChannel = (float[]) channels[ch];
				if (thisChannel != null
						&& ((lazy && thisChannel.length >= getSampleCount()) || (!lazy && thisChannel.length == getSampleCount()))) {
					// we found a matching channel. Use it !
					newChannel = thisChannel;
					channels[ch] = null;
					break;
				}
			}
		}
		if (newChannel == null) {
			newChannel = new float[getSampleCount()];
		}
		// move channels after index
		for (int i = index; i < virtSize; i++) {
			channels[i + 1] = channels[i];
		}
		channels[index] = newChannel;
		setChannelCountImpl(this.channelCount + 1);
		if (silent) {
			makeSilence(index);
		}
		// if not lazy, remove old channels
		grow(this.channelCount, lazy);
	}

	/** performs a lazy remove of the channel */
	public void removeChannel(int channel) {
		removeChannel(channel, LAZY_DEFAULT);
	}

	/**
	 * Removes a channel. If lazy is true, the channel is not physically
	 * removed, but only hidden. These hidden channels are reused by subsequent
	 * calls to addChannel or insertChannel.
	 */
	public void removeChannel(int channel, boolean lazy) {
		float[] toBeDeleted = (float[]) channels[channel];
		// move all channels after it
		for (int i = channel; i < this.channelCount - 1; i++) {
			channels[i] = channels[i + 1];
		}
		if (!lazy) {
			grow(this.channelCount - 1, true);
		} else {
			// if not already, insert this channel at the end
			channels[this.channelCount - 1] = toBeDeleted;
		}
		setChannelCountImpl(channelCount - 1);
	}

	/**
	 * Copy sourceChannel's audio data to targetChannel, identified by their
	 * indices in the channel list. Both source and target channel have to
	 * exist. targetChannel will be overwritten
	 */
	public void copyChannel(int sourceChannel, int targetChannel) {
		float[] source = getChannel(sourceChannel);
		float[] target = getChannel(targetChannel);
		System.arraycopy(source, 0, target, 0, getSampleCount());
	}

	/**
	 * Copy sampleCount samples from sourceChannel at position srcOffset to
	 * targetChannel at position targetOffset. sourceChannel and targetChannel
	 * are indices in the channel list. Both source and target channel have to
	 * exist. targetChannel will be overwritten
	 */
	public void copyChannel(int sourceChannel, int sourceOffset,
			int targetChannel, int targetOffset, int aSampleCount) {
		float[] source = getChannel(sourceChannel);
		float[] target = getChannel(targetChannel);
		System.arraycopy(source, sourceOffset, target, targetOffset,
				aSampleCount);
	}

	/**
	 * Copies data inside all channel. When the 2 regions overlap, the behavior
	 * is not specified.
	 */
	public void copy(int sourceIndex, int destIndex, int length) {
		int count = getChannelCount();
		for (int i = 0; i < count; i++) {
			copy(i, sourceIndex, destIndex, length);
		}
	}

	/**
	 * Copies data inside a channel. When the 2 regions overlap, the behavior is
	 * not specified.
	 */
	public void copy(int channel, int sourceIndex, int destIndex, int length) {
		float[] data = getChannel(channel);
		int bufferCount = getSampleCount();
		if (sourceIndex + length > bufferCount
				|| destIndex + length > bufferCount || sourceIndex < 0
				|| destIndex < 0 || length < 0) {
			throw new IndexOutOfBoundsException("parameters exceed buffer size");
		}
		System.arraycopy(data, sourceIndex, data, destIndex, length);
	}

	/**
	 * Mix up of 1 channel to n channels.<br>
	 * It copies the first channel to all newly created channels.
	 * 
	 * @param targetChannelCount the number of channels that this sample buffer
	 *            will have after expanding. NOT the number of channels to add !
	 * @exception IllegalArgumentException if this buffer does not have one
	 *                channel before calling this method.
	 */
	public void expandChannel(int targetChannelCount) {
		// even more sanity...
		if (getChannelCount() != 1) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer: can only expand channels for mono signals.");
		}
		for (int ch = 1; ch < targetChannelCount; ch++) {
			addChannel(false);
			copyChannel(0, ch);
		}
	}

	/**
	 * Mix down of n channels to one channel.<br>
	 * It uses a simple mixdown: all other channels are added to first channel.<br>
	 * The volume is NOT lowered ! Be aware, this might cause clipping when
	 * converting back to integer samples.
	 */
	public void mixDownChannels() {
		float[] firstChannel = getChannel(0);
		int localSampleCount = getSampleCount();
		for (int ch = getChannelCount() - 1; ch > 0; ch--) {
			float[] thisChannel = getChannel(ch);
			for (int i = 0; i < localSampleCount; i++) {
				firstChannel[i] += thisChannel[i];
			}
			removeChannel(ch);
		}
	}

	/**
	 * Mixes <code>source</code> to this buffer by adding all samples. At
	 * most, <code>source</code>'s number of samples, number of channels are
	 * mixed. None of the sample count, channel count or sample rate of either
	 * buffer are changed. In particular, the caller needs to assure that the
	 * sample rate of the buffers match.
	 * 
	 * @param source the buffer to be mixed to this buffer
	 */
	public void mix(FloatSampleBuffer source) {
		int count = getSampleCount();
		if (count > source.getSampleCount()) {
			count = source.getSampleCount();
		}
		int localChannelCount = getChannelCount();
		if (localChannelCount > source.getChannelCount()) {
			localChannelCount = source.getChannelCount();
		}
		for (int ch = 0; ch < localChannelCount; ch++) {
			float[] thisChannel = getChannel(ch);
			float[] otherChannel = source.getChannel(ch);
			for (int i = 0; i < count; i++) {
				thisChannel[i] += otherChannel[i];
			}
		}
	}

	/**
	 * Mixes <code>source</code> samples to this buffer by adding the sample values. 
	 * None of the sample count, channel count or sample rate of either
	 * buffer are changed. In particular, the caller needs to assure that the
	 * sample rate of the buffers match.
	 * <p>
	 * This method is not error tolerant, in particular, runtime exceptions
	 * will be thrown if the channel counts do not match, or if the
	 * offsets and count exceed the buffer's capacity.
	 * 
	 * @param source the source buffer from where to take samples and mix to this one
	 * @param sourceOffset offset in source where to start reading samples
	 * @param thisOffset offset in this buffer from where to start mixing samples
	 * @param count number of samples to mix
	 */
	public void mix(FloatSampleBuffer source, int sourceOffset, int thisOffset, int count) {
		int localChannelCount = getChannelCount();
		for (int ch = 0; ch < localChannelCount; ch++) {
			float[] thisChannel = getChannel(ch);
			float[] otherChannel = source.getChannel(ch);
			for (int i = 0; i < count; i++) {
				thisChannel[i+thisOffset] += otherChannel[i+sourceOffset];
			}
		}
	}

	/**
	 * Copies the contents of this buffer to the destination buffer at the
	 * destOffset. At most, <code>dest</code>'s number of samples, number of
	 * channels are copied. None of the sample count, channel count or sample
	 * rate of either buffer are changed. In particular, the caller needs to
	 * assure that the sample rate of the buffers match.
	 * 
	 * @param dest the buffer to write to
	 * @param destOffset the position in <code>dest</code> where to start
	 *            writing the samples of this buffer
	 * @param count the number of samples to be copied
	 * @return the number of samples copied
	 */
	public int copyTo(FloatSampleBuffer dest, int destOffset, int count) {
		return copyTo(0, dest, destOffset, count);
	}

	/**
	 * Copies the specified part of this buffer to the destination buffer. 
	 * At most, <code>dest</code>'s number of samples, number of
	 * channels are copied. None of the sample count, channel count or sample
	 * rate of either buffer are changed. In particular, the caller needs to
	 * assure that the sample rate of the buffers match.
	 * 
	 * @param srcOffset the start position in this buffer, where to start reading samples 
	 * @param dest the buffer to write to
	 * @param destOffset the position in <code>dest</code> where to start
	 *            writing the samples
	 * @param count the number of samples to be copied
	 * @return the number of samples copied
	 */
	public int copyTo(int srcOffset, FloatSampleBuffer dest, int destOffset, int count) {
		if (srcOffset + count > getSampleCount()) {
			count = getSampleCount() - srcOffset;
		}
		if (count + destOffset > dest.getSampleCount()) {
			count = dest.getSampleCount() - destOffset;
		}
		int localChannelCount = getChannelCount();
		if (localChannelCount > dest.getChannelCount()) {
			localChannelCount = dest.getChannelCount();
		}
		for (int ch = 0; ch < localChannelCount; ch++) {
			System.arraycopy(getChannel(ch), srcOffset, dest.getChannel(ch),
					destOffset, count);
		}
		return count;
	}

	/**
	 * Initializes audio data from the provided byte array. The float samples
	 * are written at <code>destOffset</code>. This FloatSampleBuffer must be
	 * big enough to accomodate the samples.
	 * <p>
	 * <code>srcBuffer</code> is read from index <code>srcOffset</code> to
	 * <code>(srcOffset + (lengthInSamples * format.getFrameSize()))</code.
	 *
	 * @param input the input buffer in interleaved audio data
	 * @param inByteOffset the offset in <code>input</code>
	 * @param format input buffer's audio format
	 * @param floatOffset the offset where to write the float samples
	 * @param frameCount number of samples to write to this sample buffer
	 */
	public void setSamplesFromBytes(byte[] input, int inByteOffset,
			AudioFormat format, int floatOffset, int frameCount) {
		if (floatOffset < 0 || frameCount < 0 || inByteOffset < 0) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer.setSamplesFromBytes: negative inByteOffset, floatOffset, or frameCount");
		}
		if (inByteOffset + (frameCount * format.getFrameSize()) > input.length) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer.setSamplesFromBytes: input buffer too small.");
		}
		if (floatOffset + frameCount > getSampleCount()) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer.setSamplesFromBytes: frameCount too large");
		}
		FloatSampleTools.byte2float(input, inByteOffset, channels, floatOffset,
				frameCount, format, false);
	}

	// ////////////////////////////// properties /////////////////////////////

	public int getChannelCount() {
		return channelCount;
	}

	public int getSampleCount() {
		return sampleCount;
	}

	public float getSampleRate() {
		return sampleRate;
	}

	/**
	 * internal setter for channel count, just change the variable. From
	 * outside, use addChannel, insertChannel, removeChannel
	 */
	protected void setChannelCountImpl(int newChannelCount) {
		if (channelCount != newChannelCount) {
			channelCount = newChannelCount;
			// remove cache
			this.lastConvertToByteArrayFormat = null;
		}
	}

	/**
	 * internal setter for sample count, just change the variable. From outside,
	 * use changeSampleCount
	 */
	protected void setSampleCountImpl(int newSampleCount) {
		if (sampleCount != newSampleCount) {
			sampleCount = newSampleCount;
		}
	}

	/**
	 * Alias for changeSampleCount
	 * 
	 * @param newSampleCount the new number of samples for this buffer
	 * @param keepOldSamples if true, the new buffer will keep the current
	 *            samples in the arrays
	 * @see #changeSampleCount(int, boolean)
	 */
	public void setSampleCount(int newSampleCount, boolean keepOldSamples) {
		changeSampleCount(newSampleCount, keepOldSamples);
	}

	/**
	 * Sets the sample rate of this buffer. NOTE: no conversion is done. The
	 * samples are only re-interpreted.
	 */
	public void setSampleRate(float sampleRate) {
		if (sampleRate <= 0) {
			throw new IllegalArgumentException(
					"Invalid samplerate for FloatSampleBuffer.");
		}
		if (this.sampleRate != sampleRate) {
			this.sampleRate = sampleRate;
			// remove cache
			lastConvertToByteArrayFormat = null;
		}
	}

	/**
	 * Get the actual audio data of one channel.<br>
	 * Modifying this array will modify the audio samples of this
	 * FloatSampleBuffer. <br>
	 * NOTE: the returned array may be larger than sampleCount. So in any case,
	 * sampleCount is to be respected.
	 * @throws IllegalArgumentException if channel is out of bounds
	 */
	public float[] getChannel(int channel) {
		if (channel >= this.channelCount) {
			throw new IllegalArgumentException(
					"FloatSampleBuffer: invalid channel number.");
		}
		return (float[]) channels[channel];
	}

	/**
	 * Low-level method to directly set the array for the given channel.
	 * Normally, you do not need this method, as you can conveniently
	 * resize the array with <code>changeSampleCount()</code>. This method
	 * may be useful for advanced optimization techniques.
	 * @param channel the channel to replace
	 * @param data the audio sample array
	 * @return the audio data array that was replaced
	 * @throws IllegalArgumentException if channel is out of bounds or data is null
	 * @see #changeSampleCount(int, boolean)
	 */
	public float[] setRawChannel(int channel, float[] data) {
		if (data == null) {
			throw new IllegalArgumentException(
					"cannot set a channel to a null array");
		}
		float[] ret = getChannel(channel);
		channels[channel] = data;
		return ret;
	}

	/**
	 * Get an array of all channels.
	 * @return all channels as array
	 */
	public Object[] getAllChannels() {
		Object[] res = new Object[getChannelCount()];
		for (int ch = 0; ch < getChannelCount(); ch++) {
			res[ch] = getChannel(ch);
		}
		return res;
	}

	/**
	 * Set the number of bits for dithering. Typically, a value between 0.2 and
	 * 0.9 gives best results.
	 * <p>
	 * Note: this value is only used, when dithering is actually performed.
	 */
	public void setDitherBits(float ditherBits) {
		if (ditherBits <= 0) {
			throw new IllegalArgumentException(
					"DitherBits must be greater than 0");
		}
		this.ditherBits = ditherBits;
	}

	public float getDitherBits() {
		return ditherBits;
	}

	/**
	 * Sets the mode for dithering. This can be one of:
	 * <ul>
	 * <li>DITHER_MODE_AUTOMATIC: it is decided automatically, whether
	 * dithering is necessary - in general when sample size is decreased.
	 * <li>DITHER_MODE_ON: dithering will be forced
	 * <li>DITHER_MODE_OFF: dithering will not be done.
	 * </ul>
	 */
	public void setDitherMode(int mode) {
		if (mode != DITHER_MODE_AUTOMATIC && mode != DITHER_MODE_ON
				&& mode != DITHER_MODE_OFF) {
			throw new IllegalArgumentException("Illegal DitherMode");
		}
		this.ditherMode = mode;
	}

	public int getDitherMode() {
		return ditherMode;
	}

	/**
	 * @return the ditherBits parameter for the float2byte functions
	 */
	protected float getConvertDitherBits(int newFormatType) {
		// let's see whether dithering is necessary
		boolean doDither = false;
		switch (ditherMode) {
		case DITHER_MODE_AUTOMATIC:
			doDither = (originalFormatType & FloatSampleTools.F_SAMPLE_WIDTH_MASK) > (newFormatType & FloatSampleTools.F_SAMPLE_WIDTH_MASK);
			break;
		case DITHER_MODE_ON:
			doDither = true;
			break;
		case DITHER_MODE_OFF:
			doDither = false;
			break;
		}
		return doDither ? ditherBits : 0.0f;
	}
}
