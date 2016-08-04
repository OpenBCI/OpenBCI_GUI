package ddf.minim.ugens;

import ddf.minim.UGen;


/**
 * Just outputs a constant value.
 * 
 * @example Synthesis/constantExample
 * 
 * @author Anderson Mills
 * 
 * @related UGen
 *
 */
public class Constant extends UGen
{
	private float value;
	
	/**
	 * Empty constructor for Constant.
	 * Sets value to 1.0.
	 */
	public Constant()
	{
		this( 1.0f );
	}
	
	/**
	 * Constructor for Constant.
	 * Sets value to val.
	 * @param val
	 * 			float: the constant value this will output
	 */
	public Constant( float val )
	{
		super();
		value = val;
	}
	
	/**
	 * Sets the value of the Constant during execution.
	 * 
	 * @param val
	 * 			float: the constant value this will output
	 * 
	 * @example Synthesis/constantExample
	 * 
	 * @related Constant
	 */
	public void setConstant( float val )
	{
		value = val;
	}

	@Override
	protected void uGenerate( float[] channels ) 
	{
		for(int i = 0; i < channels.length; i++)
		{
			channels[ i ] = value;
		}
	} 
}