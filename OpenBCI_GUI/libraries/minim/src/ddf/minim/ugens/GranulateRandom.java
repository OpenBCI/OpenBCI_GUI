package ddf.minim.ugens;

import ddf.minim.UGen;


/**
 * GranulateRandom is randomly varying version of GranulateSteady.
 * Rather than have fixed values for grain length, space length, 
 * and fade length, it has min and max values for each so that each 
 * grain is different from the last.
 * 
 * @example Synthesis/granulateRandomExample
 * 
 * @related GranulateSteady
 * @related UGen
 * 
 * @author Anderson Mills
 *
 */
public class GranulateRandom extends UGen
{   
	/**
	 * The default input is "audio."
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput audio;
	
	/**
	 * Controls the minimum length of each grain.
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput grainLenMin;
	
	/**
	 * Controls the minimum space between each grain.
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput spaceLenMin;
	
	/**
	 * Controls the minimum length of the fade in and fade out.
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput fadeLenMin;
	
	/**
	 * Controls the maximum length of each grain.
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput grainLenMax;
	
	/**
	 * Controls the maximum space between each grain.
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput spaceLenMax;
	
	/**
	 * Controls the maximum length of the fade in and fade out.
	 * 
	 * @related GranulateRandom
	 */
	public UGenInput fadeLenMax;

	// variables to determine the current placement WRT a grain
	private boolean insideGrain;
	private float timeSinceGrainStart;
	private float timeSinceGrainStop;
	private float timeStep;
	
	// variables to keep track of the grain value ranges
	private float fadeLength = 0.0025f;
	private float grainLength = 0.010f;
	private float spaceLength = 0.020f;
	private float fadeLengthMin = 0.0025f;
	private float grainLengthMin = 0.010f;
	private float spaceLengthMin = 0.020f;
	private float fadeLengthMax = 0.0025f;
	private float grainLengthMax = 0.010f;
	private float spaceLengthMax = 0.020f;
	private float minAmp = 0.0f;
	private float maxAmp = 1.0f;	

	/**
	 * Constructor for GranulateRandom.
	 * grainLengthMin, minimum grain length of each grain, defaults to 10 msec. 
	 * spaceLengthMin, minimum space between each grain, defaults to 20 msec.
	 * fadeLengthMin, minimum length of the linear fade in and fade out of the i
	 * grain envelope, defaults to 2.5 msec.
	 * grainLengthMax, maximum grain length of each grain, defaults to 100 msec.  
	 * spaceLengthMax, maximum space between each grain, defaults to 200 msec.
	 * fadeLengthMax, maximum length of the linear fade in and fade out of the
	 * grain envelope, defaults to 25 msec.
	 * 
	 * minAmp, minimum amplitude of the envelope, defaults to 0.
	 * maxAmp, maximum amplitude of the envelope, defaults to 1.
	 */
	public GranulateRandom()
	{
		this( 0.010f, 0.020f, 0.0025f, 0.10f, 0.20f, 0.025f, 0.0f, 1.0f  );
	}
	/**
	 * Constructor for GranulateRandom.
 	 * minAmp, minimum amplitude of the envelope, defaults to 0.
	 * maxAmp, maximum amplitude of the envelope, defaults to 1.
	 * 
	 * @param grainLengthMin
	 * 			float: minimum grain length of each grain in seconds 
	 * @param spaceLengthMin
	 *			float: minimum space between each grain in seconds
	 * @param fadeLengthMin
	 * 			float: minimum length of the linear fade in and fade out of the grain envelope in seconds
	 * @param grainLengthMax
	 * 			float: maximum grain length of each grain in seconds 
	 * @param spaceLengthMax
	 *			float: maximum space between each grain in seconds
	 * @param fadeLengthMax
	 * 			float: maximum length of the linear fade in and fade out of the grain envelope in seconds
	 */
	public GranulateRandom(float grainLengthMin, float spaceLengthMin, float fadeLengthMin,
			float grainLengthMax, float spaceLengthMax, float fadeLengthMax )
	{
		this( grainLengthMin, spaceLengthMin, fadeLengthMin,
			grainLengthMax, spaceLengthMax, fadeLengthMax, 0.0f, 1.0f );
	}
	/**
	 * Constructor for GranulateRandom
	 * 
	 * @param grainLengthMin
	 * 			float: minimum grain length of each grain in seconds 
	 * @param spaceLengthMin
	 *			float: minimum space between each grain in seconds
	 * @param fadeLengthMin
	 * 			float: minimum length of the linear fade in and fade out of the grain envelope in seconds
	 * @param grainLengthMax
	 * 			float: maximum grain length of each grain in seconds 
	 * @param spaceLengthMax
	 *			float: maximum space between each grain in seconds
	 * @param fadeLengthMax
	 * 			float: maximum length of the linear fade in and fade out of the grain envelope in seconds
	 * @param minAmp
	 * 			float: minimum amplitude of the envelope
	 * @param maxAmp
	 * 			float: maximum amplitude of the envelope
	 */
	public GranulateRandom(float grainLengthMin, float spaceLengthMin, float fadeLengthMin,
			float grainLengthMax, float spaceLengthMax, float fadeLengthMax,
			float minAmp, float maxAmp)
	{
		super();
		// jam3: These can't be instantiated until the uGenInputs ArrayList
		//       in the super UGen has been constructed
		audio = new UGenInput(InputType.AUDIO);
		grainLenMin = new UGenInput( InputType.CONTROL );
		spaceLenMin = new UGenInput( InputType.CONTROL );
		fadeLenMin = new UGenInput( InputType.CONTROL );
		grainLenMax = new UGenInput( InputType.CONTROL );
		spaceLenMax = new UGenInput( InputType.CONTROL );
		fadeLenMax = new UGenInput( InputType.CONTROL );
		
		setAllParameters( grainLengthMin, spaceLengthMin, fadeLengthMin, 
		                  grainLengthMax, spaceLengthMax, fadeLengthMax,
		                  minAmp, maxAmp );
		
		insideGrain = false;
		timeSinceGrainStart = 0.0f;
		timeSinceGrainStop = 0.0f;
		timeStep = 0.0f;
	}
	
	/**
	 * Use this method to notify GranulateRandom that the sample rate has changed.
	 */
	protected void sampleRateChanged()
	{
		timeStep = 1.0f/sampleRate();
	}

	/**
	 * Immediately sets all public class members concerning time to new values.
	 *  
	 * @param grainLengthMin
	 * 			float: minimum grain length of each grain in seconds 
	 * @param spaceLengthMin
	 *			float: minimum space between each grain in seconds
	 * @param fadeLengthMin
	 * 			float: minimum length of the linear fade in and fade out of the grain envelope in seconds
	 * @param grainLengthMax
	 * 			float: maximum grain length of each grain in seconds 
	 * @param spaceLengthMax
	 *			float: maximum space between each grain in seconds
	 * @param fadeLengthMax
	 * 			float: maximum length of the linear fade in and fade out of the grain envelope in seconds
	 * 
	 * @related GranulateRandom
	 */
	public void setAllTimeParameters(float grainLengthMin, float spaceLengthMin, float fadeLengthMin,
			float grainLengthMax, float spaceLengthMax, float fadeLengthMax)
	{
	  setAllParameters(grainLengthMin, spaceLengthMin, fadeLengthMin, grainLengthMax, spaceLengthMax, fadeLengthMax, minAmp, maxAmp);
	}

	/**
	 * Immediately sets all public class members to new values. 
	 * 
	 * @param grainLengthMin
	 * 			float: minimum grain length of each grain in seconds 
	 * @param spaceLengthMin
	 *			float: minimum space between each grain in seconds
	 * @param fadeLengthMin
	 * 			float: minimum length of the linear fade in and fade out of the grain envelope in seconds
	 * @param grainLengthMax
	 * 			float: maximum grain length of each grain in seconds 
	 * @param spaceLengthMax
	 *			float: maximum space between each grain in seconds
	 * @param fadeLengthMax
	 * 			float: maximum length of the linear fade in and fade out of the grain envelope in seconds
	 * @param minAmp
	 * 			float: minimum amplitude of the envelope
	 * @param maxAmp
	 * 			float: maximum amplitude of the envelope
	 * 
	 * @related GranulateRandom
	 */
	public void setAllParameters(float grainLengthMin, float spaceLengthMin, float fadeLengthMin,
			float grainLengthMax, float spaceLengthMax, float fadeLengthMax,
			float minAmp, float maxAmp)
	{
	  grainLenMin.setLastValue(grainLengthMin);
	  grainLenMax.setLastValue(grainLengthMax);
	  fadeLenMin.setLastValue(fadeLengthMin);
	  fadeLenMax.setLastValue(fadeLengthMax);
	  spaceLenMin.setLastValue(spaceLengthMin);
	  spaceLenMax.setLastValue(spaceLengthMax);
	  
		this.grainLengthMin = grainLengthMin;
		this.spaceLengthMin = spaceLengthMin;
		this.fadeLengthMin = fadeLengthMin;
		this.grainLengthMax = grainLengthMax;
		this.spaceLengthMax = spaceLengthMax;
		this.fadeLengthMax = fadeLengthMax;
		
		this.minAmp = minAmp;
		this.maxAmp = maxAmp;	
	}
	
	// This makes sure that fadeLength isn't more than half the grainLength
	private void checkFadeLength()
	{
		fadeLength = Math.min( fadeLength, grainLength/2.0f );
	}
	
	// This is just a helper function to generate a random number between two others.
	// TODO place randomBetween somewhere more generic and useful.
	private float randomBetween( float min, float max )
	{
		return (max - min)*(float)Math.random()	+ min;
	}
	
	// Make the samples.  Must make the samples
	@Override
	protected void uGenerate( float[] channels ) 
	{
		if ( insideGrain )  // inside a grain
		{	
			// start with an amplitude at maxAmp
			float amp = maxAmp;
			if ( timeSinceGrainStart < fadeLength )  // inside the rise 
			{
				// linear fade in
				amp *= timeSinceGrainStart/fadeLength;
			}
			else if ( timeSinceGrainStart > ( grainLength - fadeLength ) )  // inside the decay
			{
				// linear fade out
				amp *= ( grainLength - timeSinceGrainStart )/fadeLength;
			}
			
			// generate the sample
			for(int i = 0; i < channels.length; i++)
			{
				channels[i] = amp*audio.getLastValues()[i];
			}
			
			// increment time
			timeSinceGrainStart += timeStep;
		
			if ( timeSinceGrainStart > grainLength )  // just after a grain 
			{
				// stop the grain
				timeSinceGrainStop = 0.0f;
				insideGrain = false;
				// set a new spaceLength
				spaceLengthMin = spaceLenMin.getLastValue();
				spaceLengthMax = spaceLenMax.getLastValue();
				spaceLength = randomBetween( spaceLengthMin, spaceLengthMax );
			}
		}
		else  // outside a grain
		{
			for(int i = 0; i < channels.length; i++)
			{
				channels[i] = minAmp;
			}
			
			// increment time
			timeSinceGrainStop += timeStep;

			if (timeSinceGrainStop > spaceLength)  // just inside a grain again
			{
				// start the grain
				timeSinceGrainStart = 0.0f;
				insideGrain = true;
				// set a new grain length
				grainLengthMin = grainLenMin.getLastValue();
			  grainLengthMax = grainLenMax.getLastValue();
				grainLength = randomBetween( grainLengthMin, grainLengthMax );

				// set a new fade length
				fadeLengthMin = fadeLenMin.getLastValue();
				fadeLengthMax = fadeLenMax.getLastValue();
				fadeLength = randomBetween( fadeLengthMin, fadeLengthMax );

				// make sure the fade length is correct
				checkFadeLength();
			}
		}
	} 
}