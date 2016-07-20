package ddf.minim.ugens;

import ddf.minim.UGen;

/**
 * <p>
 * The Bypass UGen allows you to wrap another UGen and then insert that UGen into your
 * signal chain using Bypass in its place. You can then dynamically route the 
 * audio through the wrapped UGen or simply allow incoming audio to pass through unaffected. 
 * Using a Bypass UGen allows you to avoid concurrency issues caused by patching and unpatching 
 * during runtime from a Thread other than the audio one.
 * </p>
 * <p>
 * Your usage of Bypass might look something like this:
 * </p>
 * <pre>
 * Bypass&lt;GranulateSteady&gt; granulate = new Bypass( new GranulateSteady() );
 * filePlayer.patch( granulate ).patch( mainOut );
 * </pre>
 * <p>
 * If you needed to patch something else to one of the inputs of the GranulateSteady,
 * you'd use the <code>ugen</code> method of Bypass to retrieve the wrapped UGen
 * and operate on it:
 * </p>
 * <pre>
 * grainLenLine.patch( granulate.ugen().grainLen );
 * </pre>
 * <p>
 * Now, calling the <code>activate</code> method will <em>bypass</em> the granulate effect 
 * so that the Bypass object outputs the audio that is coming into it. Calling the 
 * <code>deactivate</code> method will route the audio through the wrapped effect. The 
 * <code>isActive</code> method indicates whether or not the wrapped effect is currently 
 * being bypassed.
 * </p>
 * 
 * @author Damien Di Fede
 *
 * @param <T> The type of UGen being wrapped, like GranulateSteady.
 * 
 * @related UGen
 * 
 * @example Synthesis/bypassExample
 */

public class Bypass<T extends UGen> extends UGen 
{
	private T mUGen;
	// do NOT allow people to patch directly to this!
	private UGenInput audio;
	
	private boolean mActive;
	
	/**
	 * Construct a Bypass UGen that wraps a UGen of type T.
	 * 
	 * @param ugen
	 * 			the UGen that this can bypass
	 */
	public Bypass( T ugen )
	{
		mUGen 	= ugen;
		audio 	= addAudio();
		mActive = false;
	}
	
	/**
	 * Retrieve the UGen that this Bypass is wrapping.
	 * 
	 * @return the wrapped UGen, cast to the class this Bypass was constructed with.
	 * 
	 * @example Synthesis/bypassExample
	 * 
	 * @related Bypass
	 */
	public T ugen() 
	{
		return mUGen;
	}
	
	@Override
	protected void sampleRateChanged()
	{
		mUGen.setSampleRate( sampleRate() );
	}
	
	@Override
	protected void addInput( UGen input )
	{
		audio.setIncomingUGen( input );
		input.patch( mUGen );
	}
	
	@Override
	protected void removeInput( UGen input )
	{
		if ( audio.getIncomingUGen() == input )
		{
			audio.setIncomingUGen(null);
			input.unpatch( mUGen );
		}
	}
	
	public void setChannelCount( int channelCount )
	{
	  // this will set our audio input properly
	  super.setChannelCount(channelCount);
	  
	  // but we also need to let our wrapped UGen know
	  mUGen.setChannelCount(channelCount);
	}
	
	/**
	 * Activate the bypass functionality. In other words, the wrapped UGen will NOT
	 * have an effect on the UGen patched to this Bypass.
	 * 
	 * @example Synthesis/bypassExample
	 * 
	 * @related Bypass
	 */
	public void activate()
	{
		mActive = true;
	}
	
	/**
	 * Deactivate the bypass functionality. In other words, the wrapped UGen WILL 
	 * have an effect on the UGen patched to this Bypass, as if it was in the 
	 * signal chain in place of this Bypass.
	 * 
	 * @example Synthesis/bypassExample
	 * 
	 * @related Bypass
	 */
	public void deactivate()
	{
		mActive = false;
	}
	
	/**
	 * Find out if this Bypass is active or not.
	 * 
	 * @return true if the bypass functionality is on.
	 * 
	 * @example Synthesis/bypassExample
	 * 
	 * @related Bypass
	 */
	public boolean isActive()
	{
		return mActive;
	}

	@Override
	protected void uGenerate(float[] channels) 
	{
		mUGen.tick(channels);
		
		// but stomp the result if we are active
		if ( mActive )
		{
			System.arraycopy(audio.getLastValues(), 0, channels, 0, channels.length);
		}
	}

}
