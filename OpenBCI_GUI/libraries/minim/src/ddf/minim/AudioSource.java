package ddf.minim;

import javax.sound.sampled.AudioFormat;

import ddf.minim.spi.AudioOut;

/**
 * An <code>AudioSource</code> is a kind of wrapper around an
 * <code>AudioStream</code>. An <code>AudioSource</code> will add its
 * <code>AudioBuffer</code>s as listeners on the stream so that you can access
 * the stream's samples without having to implement <code>AudioListener</code>
 * yourself. It also provides the <code>Effectable</code> and
 * <code>Recordable</code> interface. Because an <code>AudioStream</code> must
 * be closed when you are finished with it, you must remember to call
 * {@link #close()} on any <code>AudioSource</code>s you obtain from Minim, such
 * as <code>AudioInput</code>s, <code>AudioOutput</code>s, and
 * <code>AudioPlayer</code>s.
 * 
 * @author Damien Di Fede
 * @invisible
 * 
 */
public class AudioSource extends Controller implements Effectable, Recordable
{
	// the instance of Minim that created us, if one did.
	Minim						parent;

	private AudioOut			stream;
	// the signal splitter used to manage listeners to the source
	// our stereobuffer will be the first in the list
	private SignalSplitter		splitter;
	// the StereoBuffer that will subscribe to synth
	private StereoBuffer		buffer;
	// the effects chain used for effecting
	private EffectsChain		effects;

	/**
	 * The AudioBuffer containing the left channel samples. If this is a mono
	 * sound, it contains the single channel of audio.
	 * 
	 * @example Basics/PlayAFile
	 * 
	 * @related AudioBuffer
	 */
	public final AudioBuffer	left;

	/**
	 * The AudioBuffer containing the right channel samples. If this is a mono
	 * sound, <code>right</code> contains the same samples as
	 * <code>left</code>.
	 * 
	 * @example Basics/PlayAFile
	 * 
	 * @related AudioBuffer
	 */
	public final AudioBuffer	right;

	/**
	 * The AudioBuffer containing the mix of the left and right channels. If this is
	 * a mono sound, <code>mix</code> contains the same
	 * samples as <code>left</code>.
	 * 
	 * @example Basics/PlayAFile
	 * 
	 * @related AudioBuffer
	 */
	public final AudioBuffer	mix;

	/**
	 * Constructs an <code>AudioSource</code> that will subscribe to the samples
	 * in <code>stream</code>. It is expected that the stream is using a
	 * <code>DataLine</code> for playback. If it is not, calls to
	 * <code>Controller</code>'s methods will result in a
	 * <code>NullPointerException</code>.
	 * 
	 * @param istream
	 *            the <code>AudioStream</code> to subscribe to and wrap
	 * 
	 * @invisible
	 */
	public AudioSource(AudioOut istream)
	{
		super( istream.getControls() );
		stream = istream;

		// we gots a buffer for users to poll
		buffer = new StereoBuffer( stream.getFormat().getChannels(),
				stream.bufferSize(), this );
		left = buffer.left;
		right = buffer.right;
		mix = buffer.mix;

		// we gots a signal splitter that we'll add any listeners the user wants
		splitter = new SignalSplitter( stream.getFormat(), stream.bufferSize() );
		// we stick our buffer in the signal splitter because we can only set
		// one
		// listener on the stream
		splitter.addListener( buffer );
		// and there it goes.
		stream.setAudioListener( splitter );

		// we got an effects chain that we'll add user effects to
		effects = new EffectsChain();
		// we set it as the effect on the stream
		stream.setAudioEffect( effects );

		stream.open();
	}

	/**
	 * Closes this source, making it unavailable.
	 * 
	 * @invisible
	 */
	public void close()
	{
		Minim.debug( "Closing " + this.toString() );
		
		stream.close();
		
		// if we have a parent, tell them to stop tracking us
		// so that we can get garbage collected
		if ( parent != null )
		{
			parent.removeSource( this );
		}
	}

	/** @deprecated */
	public void addEffect(AudioEffect effect)
	{
		effects.add( effect );
	}

	/** @deprecated */
	public void clearEffects()
	{
		effects.clear();
	}

	/** @deprecated */
	public void disableEffect(int i)
	{
		effects.disable( i );
	}

	/** @deprecated */
	public void disableEffect(AudioEffect effect)
	{
		effects.disable( effect );
	}

	/** @deprecated */
	public int effectCount()
	{
		return effects.size();
	}

	/** @deprecated */
	public void effects()
	{
		effects.enableAll();
	}

	/** @deprecated */
	public boolean hasEffect(AudioEffect e)
	{
		return effects.contains( e );
	}

	/** @deprecated */
	public void enableEffect(int i)
	{
		effects.enable( i );
	}

	/** @deprecated */
	public void enableEffect(AudioEffect effect)
	{
		effects.enable( effect );
	}

	/** @deprecated */
	public AudioEffect getEffect(int i)
	{
		return effects.get( i );
	}

	/** @deprecated */
	public boolean isEffected()
	{
		return effects.hasEnabled();
	}

	/** @deprecated */
	public boolean isEnabled(AudioEffect effect)
	{
		return effects.isEnabled( effect );
	}

	/** @deprecated */
	public void noEffects()
	{
		effects.disableAll();
	}

	/** @deprecated */
	public void removeEffect(AudioEffect effect)
	{
		effects.remove( effect );
	}

	/** @deprecated */
	public AudioEffect removeEffect(int i)
	{
		return effects.remove( i );
	}

	/**
	 * Add an AudioListener to this sound generating object,
	 * which will have its samples method called every time
	 * this object generates a new buffer of samples.
	 * 
	 * @shortdesc Add an AudioListener to this sound generating object.
	 * 
	 * @example Advanced/AddAndRemoveAudioListener
	 * 
	 * @param listener
	 * 		the AudioListener that will listen to this
	 * 
	 * @related AudioListener
	 */
	public void addListener( AudioListener listener )
	{
		splitter.addListener( listener );
	}

	/**
	 * The internal buffer size of this sound object.
	 * The left, right, and mix AudioBuffers of this object 
	 * will be this large, and sample buffers passed to
	 * AudioListeners added to this object will be this large.
	 * 
	 * @shortdesc The internal buffer size of this sound object.
	 * 
	 * @example Basics/PlayAFile
	 * 
	 * @return int: the internal buffer size of this sound object, in sample frames.
	 */
	public int bufferSize()
	{
		return stream.bufferSize();
	}

	/**
	 * Returns an AudioFormat object that describes the audio properties 
	 * of this sound generating object. This is often useful information 
	 * when doing sound analysis or some synthesis, but typically you
	 * will not need to know about the specific format. 
	 * 
	 * @shortdesc Returns AudioFormat object that describes the audio properties 
	 * of this sound generating object.
	 * 
	 * @example Advanced/GetAudioFormat
	 * 
	 * @return an AudioFormat describing this sound object.
	 */
	public AudioFormat getFormat()
	{
		return stream.getFormat();
	}

	/**
	 * Removes an AudioListener that was previously 
	 * added to this sound object.
	 * 
	 * @example Advanced/AddAndRemoveAudioListener
	 * 
	 * @param listener
	 * 		the AudioListener that should stop listening to this
	 * 
	 * @related AudioListener
	 */
	public void removeListener( AudioListener listener )
	{
		splitter.removeListener( listener );
	}

	/**
	 * The type is an int describing the number of channels
	 * this sound object has.
	 * 
	 * @return Minim.MONO if this is mono, Minim.STEREO if this is stereo
	 */
	public int type()
	{
		return stream.getFormat().getChannels();
	}

    /**
     * Returns the sample rate of this sound object.
     * 
     * @return the sample rate of this sound object.
     */
	public float sampleRate()
	{
		return stream.getFormat().getSampleRate();
	}
}
