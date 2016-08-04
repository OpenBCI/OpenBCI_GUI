package ddf.minim.ugens;

import java.util.Arrays;

import ddf.minim.Minim;
import ddf.minim.UGen;

/**
 * A UGen that starts at a value and changes linearly to another value over a specified time.
 * 
 * @example Synthesis/lineExample
 * 
 * @author nodog
 *
 */
public class Line extends UGen
{
	// jam3: define the inputs to Oscil
	// the initial amplitude
	private float begAmp;
	// the ending amplitude
	private float endAmp;
	// the current amplitude
	private float amp;
	// the time from begAmp to endAmp
	private float lineTime;
	// the current size of the step
	private float timeStepSize;
	// the current time
	private float lineNow;
	// the damp has been activated
	private boolean isActivated;
	
	/**
	 * Constructs a Line that starts at 1 and transitions to 0 over 1 second.
	 */
	public Line()
	{
		this(1.0f, 1.0f, 0.0f);
	}
	
	/**
	 * Constructs a Line that starts at 1 and transitions to 0 over dT seconds.
	 * 
	 * @param dT 
	 * 		float: how long it should take, in seconds, to transition from the beginning value to the end value.
	 */
	public Line(float dT)
	{
		this(dT, 1.0f, 0.0f);
	}
	
	/**
	 * Constructs a Line that starts at beginningAmplitude and transitions to 0 over dT seconds.
	 * 
	 * @param dT 
	 * 		float: how long it should take, in seconds, to transition from the beginning value to the end value.
	 * @param beginningAmplitude 
	 * 		float: the value to begin at
	 */
	public Line(float dT, float beginningAmplitude)
	{
		this(dT, beginningAmplitude, 0.0f);
	}
	
	/**
	 * Constructs a Line that starts at beginningAmplitude and transitions to endAmplitude over dT seconds.
	 * 
	 * @param dT 
	 * 			float: how long it should take, in seconds, to transition from the beginning value to the end value.
	 * @param beginningAmplitude
	 * 			float: the value to begin at
	 * @param endAmplitude 
	 * 			float: the value to end at
	 */
	public Line(float dT, float beginningAmplitude, float endAmplitude)
	{
		super();
		lineTime = dT;
		begAmp = beginningAmplitude;
		amp = begAmp;
		endAmp = endAmplitude;
		lineNow = 0f;
		isActivated = false;
		Minim.debug(" dampTime = " + lineTime + " begAmp = " + begAmp + " now = " + lineNow);
	}
	
	/**
	 * Start the Line's transition.
	 *
	 */
	public void activate()
	{
		lineNow = 0f;
		amp = begAmp;
		isActivated = true;
	}
	
	/**
	 * Start the Line's transition after setting all parameters for the Line.
	 * 
	 * @param duration
	 * 			float: how long it should take, in seconds, to transition from the beginning value to the end value.
	 * @param beginAmp
	 * 			float: the value to begin at
	 * @param endingAmp
	 * 			float: the value to end at
	 */
	public void activate( float duration, float beginAmp, float endingAmp )
	{
		begAmp = beginAmp;
		endAmp = endingAmp;
		lineTime = duration;
		activate();
	}
	
	/**
	 * Has the Line completed its transition.
	 * 
	 * @return
	 * 		true if the Line has completed
	 */
	public boolean isAtEnd()
	{
		return (lineNow >= lineTime);
	}
	
	/**
	 * Set the ending value of the Line's transition.
	 * This can be set while a Line is transitioning without causing 
	 * serious discontinuities in the Line's output.
	 * 
	 * @shortdesc Set the ending value of the Line's transition.
	 *
	 * @param newEndAmp
	 * 			float: the new value to end at
	 */
	public void setEndAmp( float newEndAmp )
	{
		endAmp = newEndAmp;
	}
	
	/**
	 * Set the length of this Line's transition.
	 * 
	 * @param newLineTime 
	 * 			float: the new transition time (in seconds)
	 */
	public void setLineTime( float newLineTime )
	{
		lineTime = newLineTime;
	}
	
	/**
	 * Change the timeStepSize when sampleRate changes.
	 */
	@Override
	protected void sampleRateChanged()
	{
		timeStepSize = 1/sampleRate();
	}
	
	@Override
	protected void uGenerate(float[] channels) 
	{
		//Minim.debug(" dampTime = " + dampTime + " begAmp = " + begAmp + " now = " + now);
		if (!isActivated)
		{
			Arrays.fill( channels, begAmp );
		} 
		else if (lineNow >= lineTime)
		{
			Arrays.fill( channels, endAmp );
		} 
		else 
		{
			amp += ( endAmp - amp )*timeStepSize/( lineTime - lineNow );
			//Minim.debug(" dampTime = " + dampTime + " begAmp = " + begAmp + " amp = " + amp + " dampNow = " + dampNow);
			Arrays.fill( channels, amp );
			lineNow += timeStepSize;
		}
	}
}