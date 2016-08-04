package ddf.minim.ugens;

import ddf.minim.UGen;


/**
 * A UGen that can generate White, Pink, or Red/Brown noise.
 * 
 * @example Synthesis/noiseExample
 * 
 * @author Anderson Mills, Damien Di Fede
 *
 * @related UGen
 * @related Noise.Tint
 */
public class Noise extends UGen 
{
	/**
	 * An enumeration used to specify the tint of a Noise UGen.
	 * 
	 * @example Synthesis/noiseTintExample
	 * 
	 * @nosuperclasses
	 * 
	 * @related Noise
	 */
	public enum Tint { WHITE, PINK, RED, BROWN };
	
	/**
	 * Patch to this to control the amplitude of the noise with another UGen.
	 * 
	 * @related Noise
	 */
	public UGenInput amplitude;
	
	/**
	 * Patch to this to offset the value of the noise by a fixed value.
	 * 
	 *  @related Noise
	 */
	public UGenInput offset;

	// the type of noise
	private Tint	tint;
	// the last output value
	private float	lastOutput;
	// cutoff frequency for brown/red noise
	private float brownCutoffFreq = 100.0f;
	// alpha filter coefficient for brown/red noise
	private float brownAlpha;
	// amplitude correction for brown noise;
	private float brownAmpCorr = 6.2f;

	/**
	 * Constructor for white noise. 
	 * By default, the amplitude will be 1 and the tint will be WHITE.
	 */
	public Noise()
	{
		this( 1.0f, 0.f, Tint.WHITE );
	}
	/**
	 * Constructor for white noise of the specified amplitude.
	 * 
	 * @param amplitude
	 * 			float: the amplitude of the noise 
	 */
	public Noise( float amplitude )
	{
		this( amplitude, 0.f, Tint.WHITE ) ;
	}
	/**
	 * Constructor for noise of the specified tint with an amplitude of 1.0.
	 * 
	 * @param noiseType
	 * 		Noise.Tint: specifies the tint of the noise 
	 * 		(Noise.Tint.WHITE, Noise.Tint.PINK, Noise.Tint.RED, Noise.Tint.BROWN)
	 */
	public Noise( Tint noiseType )
	{
		this( 1.0f, 0.f, noiseType ) ;
	}
	/**
	 * Constructor for noise of a specific tint with a specified amplitude.
	 * 
	 * @param amplitude
	 * 			float: the amplitude of the noise
	 * @param noiseType
	 * 		Noise.Tint: specifies the tint of the noise 
	 * 		(Noise.Tint.WHITE, Noise.Tint.PINK, Noise.Tint.RED, Noise.Tint.BROWN)
	 */
	public Noise(float amplitude, Tint noiseType)
	{
		this(amplitude, 0.f, noiseType);
	}
	/**
	 * Constructor for noise of a specific tint with a specified amplitude and offset.
	 * @param amplitude
	 * 			float: the amplitude of the noise 
	 * @param offset
	 * 			float: the value that should be added to the noise to offset the "center"
	 * @param noiseType
	 * 		Noise.Tint: specifies the tint of the noise 
	 * 		(Noise.Tint.WHITE, Noise.Tint.PINK, Noise.Tint.RED, Noise.Tint.BROWN)
	 */
	public Noise(float amplitude, float offset, Tint noiseType)
	{
		this.amplitude = addControl(amplitude);
		this.offset = addControl(offset);
		lastOutput = 0f;
		tint = noiseType;
		if ( tint == Tint.PINK )
		{
			initPink();
		}
	}
	
	/**
	 * Set the Noise.Tint to use.
	 * 
	 * @param noiseType
	 * 		Noise.Tint: specifies the tint of the noise 
	 * 		(Noise.Tint.WHITE, Noise.Tint.PINK, Noise.Tint.RED, Noise.Tint.BROWN)
	 * 			
	 * @related Noise
	 * @related Noise.Tint
	 */
	public void setTint( Tint noiseType )
	{
	    if ( tint != noiseType )
	    {
	        if ( noiseType == Tint.PINK )
	        {
	            initPink();
	        }
	        tint = noiseType;
	    }
	}
	
	/**
	 * Returns the current Noise.Tint in use
	 * 
	 * @return Noise.Tint: the current tint of the noise 
	 * 		   (Noise.Tint.WHITE, Noise.Tint.PINK, Noise.Tint.RED, Noise.Tint.BROWN)
	 * 
	 * @related Noise
	 * @related Noise.Tint
	 */
	public final Tint getTint()
	{
	    return tint;
	}
	
	@Override
	protected void sampleRateChanged()
	{
		float dt = 1.0f/sampleRate();
		float RC = 1.0f/( 2.0f*(float)Math.PI*brownCutoffFreq );
		brownAlpha = dt/( RC + dt );
	}
	
	@Override
	protected void uGenerate(float[] channels) 
	{
		// start with our base amplitude
		float outAmp = amplitude.getLastValue();
		
		float n;
		switch (tint) 
		{
		// BROWN is a 1/f^2 spectrum (20db/decade, 6db/octave).
		// There is some disagreement as to whether
		// brown and red are the same, but here they are.
		case BROWN :
		case RED :
			// I admit that I'm using the filter coefficients and 
			// amplitude correction from audacity, a great audio editor.  
			n = outAmp*(2.0f*(float)Math.random() - 1.0f);
			n = brownAlpha*n + ( 1 - brownAlpha )*lastOutput;
			lastOutput = n;
			n *= brownAmpCorr;
			break;
		// PINK noise has a 10db/decade (3db/octave) slope
		case PINK :
			n = outAmp*pink();
			break;
		case WHITE :
		default :
			n = outAmp*(2.0f*(float)Math.random() - 1.0f);
			break;
		}
		n += offset.getLastValue();
		for(int i = 0; i < channels.length; i++)
		{
			channels[i] = n;
		}
	}
	
	// The code below (including comments) is taken directly from ddf's old PinkNoise.java code
	// This is the Voss algorithm for creating pink noise
	private int maxKey, key, range;
	private float whiteValues[];
	private float maxSumEver;

	private void initPink()
	{
	    maxKey = 0x1f;
	    range = 128;
	    maxSumEver = 90;
	    key = 0;
	    whiteValues = new float[6];
	    for (int i = 0; i < 6; i++)
	      whiteValues[i] = ((float) Math.random() * Long.MAX_VALUE) % (range / 6);
	}

	// return a pink noise value
	private float pink()
	{
	  int last_key = key;
	  float sum;

	  key++;
	  if (key > maxKey) key = 0;
	  // Exclusive-Or previous value with current value. This gives
	  // a list of bits that have changed.
	  int diff = last_key ^ key;
	  sum = 0;
	  for (int i = 0; i < 6; i++)
	  {
	    // If bit changed get new random number for corresponding
	    // white_value
	    if ((diff & (1 << i)) != 0)
	    {
	      whiteValues[i] = ((float) Math.random() * Long.MAX_VALUE) % (range / 6);
	    }
	    sum += whiteValues[i];
	  }
	  if (sum > maxSumEver) maxSumEver = sum;
	  sum = 2f * (sum / maxSumEver) - 1f;
	  return sum;
	}
	
}