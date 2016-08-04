package ddf.minim.ugens;

import ddf.minim.AudioOutput;
import ddf.minim.Minim;
import ddf.minim.UGen;

/**
 * A UGen that generates a simple envelope that changes from a starting value to a
 * middle value during an "attack" phase and then changes to an ending value 
 * during a "damp" or "decay" phase. By default, if you only specify a damp time,
 * it will change from 1 to 0 over that period of time. Specifying only attack and 
 * damp time, it will ramp up from 0 to 1 over the attack time and then 1 to 0 over 
 * the damp time. All times are specified in seconds.
 * 
 * @example Synthesis/dampExample
 * 
 * @author Anderson Mills
 *
 * @related UGen
 */
public class Damp extends UGen
{
	/**
	 *  The default input is "audio." You don't need to patch directly to this input,
	 *  patching to the UGen itself will accomplish the same thing.
	 *  
	 *  @related Damp
	 *  @related UGen.UGenInput
	 */
	public UGenInput audio;

	// the maximum amplitude of the damp
	private float maxAmp;
	// the current amplitude
	private float amp;
	// the time from maxAmp to afterAmplitude
	private float dampTime;
	// the time from beforeAmplitude to maxAmp
	private float attackTime;
	// amplitude before the damp hits
	private float beforeAmplitude;
	// amplitude after the release of the damp
	private float afterAmplitude;
	// the current size of the step
	private float timeStepSize;
	// the current time
	private float now;
	// the damp has been activated
	private boolean isActivated;
	// unpatch the note after it's finished
	private boolean unpatchAfterDamp;
	// it might need to unpatch from an output
	private AudioOutput output;
	// or it might need to unpatch from another ugen
	private UGen		ugenOutput;
	
	/**
	 * Constructor for Damp envelope.
	 * attackTime, rise time of the damp envelope, defaults to 0.
	 * dampTime, decay time of the damp envelope, defaults to 1.
	 * maxAmp, maximum amlitude of the damp envelope, defaults to 1.
	 * befAmp, amplitude before the damp envelope,
	 * and aftAmp, amplitude after the damp envelope,
	 * default to 0.
	 */
	public Damp()
	{
		this( 0.0f, 1.0f, 1.0f, 0.0f, 0.0f );
	}
	
	/**
	 * Constructor for Damp envelope.
	 * attackTime, rise time of the damp envelope, defaults to 0.
	 * maxAmp, maximum amlitude of the damp envelope, defaults to 1.
	 * befAmp, amplitude before the damp envelope,
	 * and aftAmp, amplitude after the damp envelope,
	 * default to 0.
	 * @param dampTime
	 * 			float: decay time of the damp envelope, in seconds
	 */
	 public Damp( float dampTime )
	{
		this( 0.0f, dampTime, 1.0f, 0.0f, 0.0f );
	}
	 
	/**
	 * Constructor for Damp envelope.
	 * maxAmp, maximum amlitude of the damp envelope, defaults to 1.
	 * befAmp, amplitude before the damp envelope,
	 * and aftAmp, amplitude after the damp envelope,
	 * default to 0.
	 * @param attackTime 
	 * 			float: rise time of the damp envelope, in seconds
	 * @param dampTime
	 * 			float: decay time of the damp envelope, in seconds
	 */	
	public Damp( float attackTime, float dampTime )
	{
		this( attackTime, dampTime, 1.0f, 0.0f, 0.0f );
	}
	
	/**
	 * Constructor for Damp envelope.
	 * befAmp, amplitude before the damp envelope,
	 * and aftAmp, amplitude after the damp envelope,
	 * default to 0.
	 * @param attackTime 
	 * 			float: rise time of the damp envelope, in seconds
	 * @param dampTime
	 * 			float: decay time of the damp envelope, in seconds
	 * @param maxAmp
	 * 			float: maximum amplitude of the damp envelope
	 */
	public Damp( float attackTime, float dampTime, float maxAmp )
	{
		this( attackTime, dampTime, maxAmp, 0.0f, 0.0f );
	}
	
	/**
	 * Constructor for Damp envelope.
	 * @param attackTime 
	 * 			float: rise time of the damp envelope, in seconds
	 * @param dampTime
	 * 			float: decay time of the damp envelope, in seconds
	 * @param maxAmp
	 * 			float: maximum amplitude of the damp envelope
	 * @param befAmp
	 * 			float: amplitude before the damp envelope
	 * @param aftAmp
	 * 			float: amplitude after the damp envelope
	 */
	public Damp( float attackTime, float dampTime, float maxAmp, float befAmp, float aftAmp )
	{
		super();
		audio = new UGenInput(InputType.AUDIO);
		this.attackTime = attackTime;
		this.dampTime = dampTime;
		this.maxAmp = maxAmp;
		beforeAmplitude = befAmp;
		afterAmplitude = aftAmp;
		isActivated = false;
		amp = beforeAmplitude;
		Minim.debug(" attackTime = " + attackTime + " dampTime = " + dampTime 
				+ " maxAmp = " + this.maxAmp + " now = " + now );
	}
	
	/**
	 * Specifies that the damp envelope should begin.
	 * 
	 * @example Synthesis/dampExample
	 * 
	 * @related Damp
	 */
	public void activate()
	{
		now = 0f;
		isActivated = true;
		if( timeStepSize > attackTime )
		{
			amp = maxAmp;
		}  else
		{
			amp = 0f;
		}
	}
	
	/**
	 * Permits the setting of the attackTime parameter.
	 * 
	 * @param attackTime
	 * 			float: rise time of the damp envelope, in seconds
	 * 
	 * @related Damp
	 */
	public void setAttackTime( float attackTime )
	{
		this.attackTime = attackTime;
	}
	
	/**
	 * Permits the setting of the attackTime parameter.
	 * 
	 * @param dampTime
	 * 			float: decay time of the damp envelope, in seconds
	 * 
	 * @related Damp
	 */
	public void setDampTime( float dampTime )
	{
		this.dampTime = dampTime;
	}
	
	/**
	 * Set the attack time and damp time parameters based on a duration.  
	 * If the current attack time is positive, and less than the total duration, 
	 * then the damp time is the total duration after the attack time, otherwise, 
	 * the attack time and damp time are both set to half the duration.
	 * 
	 * @shortdesc Set the attack time and damp time parameters based on a duration.
	 * 
	 * @param duration
	 * 			float: duration of the entire damp envelope, in seconds
	 * 
	 * @related Damp
	 * 
	 * @example Synthesis/dampExample
	 */
	public void setDampTimeFromDuration( float duration )
	{
		float tmpDampTime = duration - attackTime;
		if ( tmpDampTime > 0.0f )
		{
			dampTime = tmpDampTime;
		} else
		{
			attackTime = duration/2.0f;
			dampTime = duration/2.0f;
		}
	}
	
	@Override
	protected void sampleRateChanged()
	{
		timeStepSize = 1/sampleRate();
	}	

	/**
	 * Tell this Damp that it should unpatch itself from the output after the release time.
	 * 
	 * @param output
	 * 			AudioOutput: the output this should unpatch from
	 * 
	 * @example Synthesis/dampExample
	 * 
	 * @related Damp
	 */
	public void unpatchAfterDamp( AudioOutput output )
	{
		unpatchAfterDamp = true;
		this.output = output;
	}
	
	/**
	 * The UGen this Damp should unpatch itself from after the release time.
	 * 
	 * @param output
	 * 			the UGen that this Damp should unpatch to after the Damp completes
	 * 
	 * @related Damp
	 */
	public void unpatchAfterDamp( UGen output )
	{
		unpatchAfterDamp = true;
		ugenOutput = output;
	}
	
	@Override
	protected void uGenerate( float[] channels ) 
	{
		// before the damp
		if ( !isActivated ) 
		{
			for( int i = 0; i < channels.length; i++ )
			{
				channels[ i ] = beforeAmplitude*audio.getLastValues()[ i ];
			}
		}
		// after the damp
		else if ( now >= ( dampTime + attackTime ) )
		{
			for( int i = 0; i < channels.length; i++ )
			{
				channels[ i ] = afterAmplitude*audio.getLastValues()[ i ];
			}
			if ( unpatchAfterDamp )
			{
				if ( output != null )
				{
					unpatch( output );
					output = null;
				}
				else if ( ugenOutput != null )
				{
					unpatch( ugenOutput );
					ugenOutput = null;
				}
				unpatchAfterDamp = false;
			 	Minim.debug(" unpatching Damp ");
			}
		}
		// after the attack, during the decay
		else if ( now >= attackTime )  // in the damp time
		{
			amp += ( afterAmplitude - amp )*timeStepSize/( dampTime + attackTime - now );
			for( int i = 0; i < channels.length; i++ )
			{
				channels[i] = amp*audio.getLastValues()[ i ];
			}
			now += timeStepSize;
		} else // in the attack time
		{
			amp += ( maxAmp - amp )*timeStepSize/( attackTime - now );
			for( int i = 0; i < channels.length; i++ )
			{
				channels[i] = amp*audio.getLastValues()[ i ];
			}
			now += timeStepSize;
		}
	}
}
