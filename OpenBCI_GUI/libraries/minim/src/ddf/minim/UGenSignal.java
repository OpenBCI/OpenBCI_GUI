package ddf.minim;


/** @invisible */
@Deprecated
public class UGenSignal implements AudioSignal
{
	private UGen generator;
	
	UGenSignal(UGen ugen)
	{
		generator = ugen;
	}
	
	/**
	 * Sets the UGen that this UGenSignal wraps.
	 * 
	 * @param ugen the UGen that is used to generate audio
	 */
	public void setUGen(UGen ugen)
	{
		generator = ugen;
	}
	
	/**
	 * Returns the UGen that is being wrapped by this UGenSignal.
	 * 
	 * @return the wrapped UGen
	 */
	public UGen getUGen()
	{
		return generator;
	}

	/**
	 * Generates a buffer of samples by ticking the wrapped UGen mono.length times.
	 */
	public void generate(float[] mono)
	{
		float[] sample = new float[1];
		for(int i = 0; i < mono.length; i++)
		{
			sample[0] = 0;
			generator.tick(sample);
			mono[i] = sample[0];
		}
	}
	
	/**
	 * Generates a buffer of samples by ticking the wrapped UGen left.length times.
	 */
	public void generate(float[] left, float[] right)
	{
		float[] sample = new float[2];
		for(int i = 0; i < left.length; i++)
		{
			sample[0] = 0;
			sample[1] = 0;
			generator.tick(sample);
			left[i] = sample[0];
			right[i] = sample[1];
		}
	}	
}
