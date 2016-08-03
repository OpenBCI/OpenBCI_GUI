package ddf.minim;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.Control;

import ddf.minim.spi.AudioOut;
import ddf.minim.spi.AudioStream;

// ddf (9/5/15): very very basic audio out implementation
//             : that is used when creating an AudioInput
//             : in the event that getLineOut does not return 
//             : a usable audio out. 
class BasicAudioOut extends Thread 
implements AudioOut
{
	private AudioFormat 		format;
	private MultiChannelBuffer  buffer;
	private AudioListener		listener;
	private AudioStream			stream;
	private boolean 			running;
	
	public BasicAudioOut(AudioFormat format, int bufferSize)
	{
		this.format = format;
		buffer = new MultiChannelBuffer(bufferSize, format.getChannels());
	}

	public void run()
	{
		running = true;
		while (running)
		{	
			// this should block until we get a full buffer
			int samplesRead = stream.read(buffer);
			
			// but with JavaSound, at least, it might return without 
			// a full buffer if the TargetDataLine the stream is reading from
			// is closed during a read, so in that case we simply
			// fill the rest of the buffer with silence
			if ( samplesRead != buffer.getBufferSize() )
			{
				for(int i = samplesRead; i < buffer.getBufferSize(); ++i)
				{
					for(int c = 0; c < buffer.getChannelCount(); ++c)
					{
						buffer.setSample( c, i, 0 );
						buffer.setSample( c, i, 0 );
					}
				}
			}
			
			if (buffer.getChannelCount()==1)
			{
				listener.samples(buffer.getChannel(0));
			}
			else
			{
				listener.samples(buffer.getChannel(0), buffer.getChannel(1));
			}
			
			try
			{
				Thread.sleep(1);
			}
			catch (InterruptedException e)
			{
			}
		}
	}
	
	public void open()
	{
		start();
	}

	public void close()
	{
		running = false;
	}

	public Control[] getControls()
	{
		return new Control[0];
	}

	public AudioFormat getFormat()
	{
		return format;
	}

	public int bufferSize()
	{
		return buffer.getBufferSize();
	}

	
	public void setAudioSignal(AudioSignal signal)
	{
		//Minim.error( "BasicAudioOut does not support setting an AudioSignal." );
	}

	public void setAudioStream(AudioStream stream)
	{
		this.stream = stream;
	}

	public void setAudioEffect(AudioEffect effect)
	{
		//Minim.error( "BasicAudiOut does not support setting an AudioEffect." );
	}

	public void setAudioListener(AudioListener listen)
	{
		this.listener = listen;
	}

}
