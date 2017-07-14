package ddf.minim.ugens;

import java.util.Arrays;

import ddf.minim.Minim;
import ddf.minim.MultiChannelBuffer;
import ddf.minim.UGen;

/**
 * Sampler is the UGen version of AudioSample and is
 * the preferred method of triggering short audio files. 
 * You will also find Sampler much more flexible,
 * since it provides ways to trigger only part of a sample, and 
 * to trigger a sample at different playback rates. Also, unlike AudioSample,
 * a Sampler lets you specify how many voices (i.e. simultaneous 
 * playbacks of the sample) should have.
 * <p>
 * Sampler provides several inputs that allow you to control the properties
 * of a triggered sample. When you call the trigger method, the values of these 
 * inputs are "snapshotted" and used to configure the new voice that will play 
 * the sample. So, changing the values does not effect already playing voices,
 * except for <code>amplitude</code>, which controls the volume of the Sampler 
 * as a whole.
 * 
 * @example Advanced/DrumMachine
 * 
 * @related AudioSample
 * @related UGen
 * 
 * @author Damien Di Fede
 * 
 */

public class Sampler extends UGen
{
	/**
	 * The sample number in the source sample 
	 * the voice will start at when triggering this Sampler.
	 */
	public UGenInput begin;
	
	/**
	 * The sample number in the source sample 
	 * the voice will end at when triggering this Sampler.
	 */
	public UGenInput end;
	
	/**
	 * The attack time, in seconds, when triggering 
	 * this Sampler. Attack time is used to ramp up 
	 * the amplitude of the voice. By default it 
	 * is 0 seconds.
	 */
	public UGenInput attack;
	
	/**
	 * The amplitude of this Sampler. This acts as an
	 * overall volume control. So changing the amplitude
	 * will effect all currently active voices.
	 */
	public UGenInput amplitude;
	
	/**
	 * The playback rate used when triggering this Sampler.
	 */
	public UGenInput rate;
	
	/**
	 * Whether triggered voices should loop or not.
	 */
	public boolean looping;
	
	private MultiChannelBuffer sampleData;
	// what's the sample rate of our sample data
	private float			   sampleDataSampleRate;
	// what's the baseline playback rate.
	// this is set whenever sampleRateChanged is called
	// and is used to scale the value of the rate input
	// when starting a trigger. we need this so that,
	// for example, 22k sample data will playback at
	// the correct speed when played through a 44.1k
	// UGen chain.
	private float 			   basePlaybackRate;
	
	// Trigger class is defined at bottom of Sampler imp
	private Trigger[]		   triggers;
	private int				   nextTrigger;
	
	/**
	 * Create a new Sampler for triggering the provided file.
	 * 
	 * @param filename 
	 * 			String: the file to load
	 * @param maxVoices
	 * 			int: the maximum number of voices for this Sampler
	 * @param system 
	 * 			Minim: the instance of Minim to use for loading the file
	 *
	 */
	public Sampler( String filename, int maxVoices, Minim system )
	{
		triggers = new Trigger[maxVoices];
		for( int i = 0; i < maxVoices; ++i )
		{
			triggers[i] = new Trigger();
		}
		
		sampleData = new MultiChannelBuffer(1,1);
		sampleDataSampleRate = system.loadFileIntoBuffer( filename, sampleData );
		
		createInputs();
	}
	
	/**
	 * Create a Sampler that will use the audio in the provided MultiChannelBuffer
	 * for its sample. It will make a copy of the data, so modifying the provided
	 * buffer after the fact will not change the audio in this Sampler.
	 * The original sample rate of the audio data must be provided
	 * so that the default playback rate of the Sampler can be set properly.
	 * Additionally, you must specify how many voices the Sampler should use,
	 * which will determine how many times the sound can overlap with itself
	 * when triggered. 
	 * 
	 * @param sampleData
	 * 		 	MultiChannelBuffer: the sample data this Sampler will use to generate sound
	 * @param sampleRate
	 * 			float: the sample rate of the sampleData
	 * @param maxVoices
	 * 			int: the maximum number of voices for this Sampler
	 * 
	 * @related MultiChannelBuffer
	 */
	public Sampler( MultiChannelBuffer sampleData, float sampleRate, int maxVoices )
	{
		triggers = new Trigger[maxVoices];
		for( int i = 0; i < maxVoices; ++i )
		{
			triggers[i] = new Trigger();
		}
		
		this.sampleData      = new MultiChannelBuffer( sampleData.getChannelCount(), sampleData.getBufferSize() );
		this.sampleData.set(  sampleData );
		sampleDataSampleRate = sampleRate;
		
		createInputs();
	}
	
	private void createInputs()
	{
		begin 			= addControl(0);
		end   			= addControl(sampleData.getBufferSize()-1);
		attack 			= addControl();
		amplitude		= addControl(1);
		rate			= addControl(1);
	}
	
	/**
	 * Trigger this Sampler. If all of the Sampler's voices 
	 * are currently in use, it will use the least recently 
	 * triggered voice, which means whatever that voice is 
	 * currently playing will get cut off. For this reason,
	 * choose the number of voices you want carefully.
	 * 
	 * @shortdesc Trigger this Sampler.
	 */
	public void trigger()
	{
		triggers[nextTrigger].activate();
		nextTrigger = (nextTrigger+1)%triggers.length;
	}
	
	/**
	 * Stop all active voices. In other words,
	 * immediately silence this Sampler.
	 */
	public void stop()
	{
		for( Trigger t : triggers )
		{
			t.stop();
		}
	}
	
	/**
	 * Sets the sample data used by this Sampler by <em>copying</em> the 
	 * contents of the provided MultiChannelBuffer into the internal buffer.
	 * 
	 * @param newSampleData 
	 * 				MultiChannelBuffer: the new sample data for this Sampler
	 * @param sampleRate 
	 * 				float: the sample rate of the sample data
	 * 
	 * @related MultiChannelBuffer
	 */
	public void setSample( MultiChannelBuffer newSampleData, float sampleRate )
	{
		sampleData.set( newSampleData );
		sampleDataSampleRate = sampleRate;
		basePlaybackRate	 = sampleRate / sampleRate();
	}
	
	@Override
	protected void sampleRateChanged()
	{
		basePlaybackRate = sampleDataSampleRate / sampleRate();
	}
	
	@Override
	protected void uGenerate(float[] channels)
	{
		Arrays.fill( channels, 0 );
		for( Trigger t : triggers )
		{
			t.generate( channels );
		}
	}

	private class Trigger
	{
		// begin and end sample numbers
		float beginSample;
		float endSample;
		// playback rate
		float playbackRate;
		// what sample we are at in our trigger. expressed as a float to handle variable rate.
		float sample;
		// how many output samples we have generated, tracked for attack/release
		float outSampleCount;
		// attack time, in samples
		int   attackLength;
		// current amplitude mod for attack
		float attackAmp;
		// how much to increase the attack amp each sample frame
		float attackAmpStep;
		// release time, in samples
		int   release;
		// whether we are done playing our bit of the sample or not
		boolean  done;
		// whether we should start triggering in the next call to generate
		boolean  triggering;
		
		Trigger()
		{
			done = true;
		}
		
		// start this Trigger playing with the current settings of the Sampler
		void activate()
		{
			triggering = true;
		}
        
        // stop this trigger
        void stop()
        {
        	done = true;
        }
		
		// generate one sample frame of data
		void generate( float[] sampleFrame )
		{
			if ( triggering )
			{
				beginSample  = (int)Math.min( begin.getLastValue(), sampleData.getBufferSize()-2);
				endSample    = (int)Math.min( end.getLastValue(), sampleData.getBufferSize()-1 );
				playbackRate = rate.getLastValue();
				attackLength = (int)Math.max( sampleRate() * attack.getLastValue(), 1.f );
				attackAmp    = 0;
				attackAmpStep = 1.0f / attackLength;
				release		  = 0;
				sample		  = beginSample;
				outSampleCount = 0;
				done		  = false;
				triggering    = false;
			}
			
			if ( done ) return;
			
			final float outAmp = amplitude.getLastValue() * attackAmp;
			
			for( int c = 0; c < sampleFrame.length; ++c )
			{
				int sourceChannel = c < sampleData.getChannelCount() ? c : sampleData.getChannelCount() - 1;
				sampleFrame[c] += outAmp * sampleData.getSample( sourceChannel, sample );
			}
			
			sample += playbackRate*basePlaybackRate;
			
			if ( sample > endSample )
			{
				if ( looping ) 
				{
					sample -= endSample - beginSample;
				}
				else 
				{
					done = true;
				}
			}
			
			++outSampleCount;
			if ( outSampleCount <= attackLength )
			{
				attackAmp += attackAmpStep;
			}
		}
	}
}
