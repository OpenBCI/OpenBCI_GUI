package ddf.minim.ugens;

import ddf.minim.UGen;


/**
 * A UGen which chops the incoming audio into steady grains
 * of sound.  The envelope of these sounds has a linear fade
 * in and fade out.
 * 
 * @example Synthesis/granulateSteadyExample
 * 
 * @related UGen
 * @related GranulateRandom
 * 
 * @author Anderson Mills
 *
 */
public class GranulateSteady extends UGen
{
	/**
	 * The default input is "audio."
	 * 
	 * @related GranulateSteady
	 */
	public UGenInput audio;
	
	/**
	 * Controls the length of each grain.
	 * 
	 * @related GranulateSteady
	 */
	public UGenInput grainLen;
	
	/**
	 * Controls the space between each grain.
	 * 
	 * @related GranulateSteady
	 */
	public UGenInput spaceLen;
	
	/**
	 * Controls the length of the fade in and fade out.
	 * 
	 * @related GranulateSteady
	 */
	public UGenInput fadeLen;

	// variables to determine the current placement WRT a grain
	private boolean insideGrain;
	private float timeSinceGrainStart;
	private float timeSinceGrainStop;
	private float timeStep;
	
	// variables to keep track of the grain values
	// these are only set when appropriate for the algorithm
	// the user-manipulated values are held by the inputs
	private float grainLength = 0.010f;
	private float spaceLength = 0.020f;
	private float fadeLength = 0.0025f;
	private float minAmp = 0.0f;
	private float maxAmp = 1.0f;	
	
	/**
	 * Constructor for GranulateSteady.
	 * grainLength, length of each grain, defaults to 10 msec.
	 * spaceLength, space between each grain, defaults to 20 msec.
	 * fadeLength, length of the linear fade in and fade out of the grain envelope, defaults to 2.5 msec.
	 * minAmp, minimum amplitude of the envelope, defaults to 0.
	 * maxAmp, maximum amplitude of the envelope, defaults to 1.
	 */
	public GranulateSteady()
	{
		this( 0.01f, 0.02f, 0.0025f, 0.0f, 1.0f );
	}
	/**
	 * Constructor for GranulateSteady.
	 * minAmp, minimum amplitude of the envelope, defaults to 0.
	 * maxAmp, maximum amplitude of the envelope, defaults to 1.
	 * 
	 * @param grainLength
	 * 			float: length of each grain in seconds
	 * @param spaceLength
	 * 			float: space between each grain in seconds
	 * @param fadeLength
	 * 			float: length of the linear fade in and fade out of the grain envelope in seconds
	 */
	public GranulateSteady( float grainLength, float spaceLength, float fadeLength )
	{
		this( grainLength, spaceLength, fadeLength, 0.0f, 1.0f );
	}
	/**
	 * Constructor for GranulateSteady.
	 * @param grainLength
	 * 			float: length of each grain in seconds
	 * @param spaceLength
	 * 			float: space between each grain in seconds
	 * @param fadeLength
	 * 			float: length of the linear fade in and fade out of the grain envelope in seconds
	 * @param minAmp
	 * 			float: minimum amplitude of the envelope
	 * @param maxAmp
	 * 			float: maximum amplitude of the envelope
	 */
	public GranulateSteady( float grainLength, float spaceLength, float fadeLength, float minAmp, float maxAmp )
	{
		super();
		// jam3: These can't be instantiated until the uGenInputs ArrayList
		//       in the super UGen has been constructed
		audio = new UGenInput(InputType.AUDIO);
		grainLen = new UGenInput( InputType.CONTROL );
		spaceLen = new UGenInput( InputType.CONTROL );
		fadeLen = new UGenInput( InputType.CONTROL );
		//amplitude = new UGenInput(InputType.CONTROL);
		setAllParameters( grainLength, spaceLength, fadeLength, minAmp, maxAmp );
		insideGrain = true;
		timeSinceGrainStart = 0.0f;
		timeSinceGrainStop = 0.0f;
		timeStep = 0.0f;
	}
	
	/**
	 * Use this method to notify GranulateSteady that the sample rate has changed.
	 */
	protected void sampleRateChanged()
	{
		timeStep = 1.0f/sampleRate();
	}
	
	/**
	 * Immediately sets all public class members concerning time to new values. 
	 * @param grainLength
	 * 			float: grain length of each grain in seconds 
	 * @param spaceLength
	 *			float: space between each grain in seconds
	 * @param fadeLength
	 * 			float: length of the linear fade in and fade out of the grain envelope in seconds
	 * 
	 * @related GranulateSteady
	 */
	public void setAllTimeParameters( float grainLength, float spaceLength, float fadeLength )
	{
		setAllParameters( grainLength, spaceLength, fadeLength, minAmp, maxAmp );
	}

	/**
	 * Immediately sets all public class members to new values. 
	 * 
	 * @param grainLength
	 * 			float: grain length of each grain in seconds
	 * @param spaceLength
	 *			float: space between each grain in seconds
	 * @param fadeLength
	 * 			float: length of the linear fade in and fade out of the grain envelope in seconds
	 * @param minAmp
	 * 			float: minimum amplitude of the envelope
	 * @param maxAmp
	 * 			float: maximum amplitude of the envelope
	 * 
	 * @related GranulateSteady
	 */
	public void setAllParameters( float grainLength, float spaceLength, float fadeLength,
			float minAmp, float maxAmp)
	{
	  grainLen.setLastValue(grainLength);
	  spaceLen.setLastValue(spaceLength);
	  fadeLen.setLastValue(fadeLength);
		this.grainLength = grainLength;
		this.spaceLength = spaceLength;
		this.fadeLength = fadeLength;
		this.minAmp = minAmp;
		this.maxAmp = maxAmp;	
	}
	
	/**
	 * Sets the state of this granulate to the very start of a grain. 
	 * Useful for syncing the granulate timing with other audio.
	 * 
	 * @related GranulateSteady
	 */
	public void reset()
	{
		// start the grain
		timeSinceGrainStart = 0.0f;
		insideGrain = true;
		// only set the grain values at the beginning of a grain
		grainLength = grainLen.getLastValue();
		checkFadeLength();
		fadeLength = fadeLen.getLastValue();
		checkFadeLength();
	}
	
	// This makes sure that fadeLength isn't more than half the grainLength
	private void checkFadeLength()
	{
		fadeLength = Math.min( fadeLength, grainLength/2.0f );
	}
	
	// Make those samples!
	@Override
	protected void uGenerate( float[] channels ) 
	{
		if ( insideGrain )  // inside a grain
		{	
			// start with an amplitude at maxAmp
			float amp = maxAmp;
			if ( timeSinceGrainStart < fadeLength )  // inside the rise of the envelope
			{
				// linear fade in
				amp *= timeSinceGrainStart/fadeLength;  
			}
			else if ( timeSinceGrainStart > ( grainLength - fadeLength ) )  // inside the decay of the envelope
			{
				// linear fade out
				amp *= ( grainLength - timeSinceGrainStart )/fadeLength;
			}
			
			// generate the sample
			for( int i = 0; i < channels.length; i++ )
			{
				channels[i] = amp*audio.getLastValues()[i];
			}
			
			// increment time
			timeSinceGrainStart += timeStep;
			
			if ( timeSinceGrainStart > grainLength )  // just after the grain 
			{
				// stop the grain
				timeSinceGrainStop = 0.0f;
				insideGrain = false;
				// only set space volues at the beginning of a space
				spaceLength = spaceLen.getLastValue();
			}
		}
		else  // outside of a grain
		{
			// generate the samples
			for( int i = 0; i < channels.length; i++ )
			{
				channels[i] = minAmp;
			}
			
			// increment time
			timeSinceGrainStop += timeStep;

			if ( timeSinceGrainStop > spaceLength )  // just inside a grain again
			{
				reset();
			}
		}
	} 
}