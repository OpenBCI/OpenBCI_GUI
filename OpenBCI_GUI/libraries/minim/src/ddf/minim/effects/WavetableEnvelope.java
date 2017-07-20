package ddf.minim.effects;

// import ddf.minim.AudioEffect;
// import ddf.minim.Wavetable;

// Not available for 2.0.2
class WavetableEnvelope // implements AudioEffect
{
//
//	private Wavetable	envform;
//	private long		duration			= 0;
//	private int			samplecounter	= 0;
//	private boolean	triggered		= false;
//
//	private int			lastsample		= 0;
//	private int			sampleRate;
//
//	public WavetableEnvelope(Wavetable envelopeform, int sampleRate)
//	{
//		envform = envelopeform;
//		this.sampleRate = sampleRate;
//	}
//
//	/**
//	 * Trigger the envelope to start processing. When the envelope has finished,
//	 * The value of the last sample in the wavetable will be applied to the
//	 * signal being processed.
//	 * 
//	 * @param duration
//	 *           how long the envelope should last in milliseconds
//	 */
//	public void trigger(long duration)
//	{
//		triggered = true;
//		this.duration = duration;
//		samplecounter = 0;
//		lastsample = 0;
//	}
//
//	public boolean isTriggered()
//	{
//		return triggered;
//	}
//
//	public void process(float[] signal)
//	{
//		process(signal, null);
//	}
//
//	public void process(float[] sigLeft, float[] sigRight)
//	{
//
//		for (int i = 0; i < sigLeft.length; i++)
//		{
//			if (triggered)
//			{
//				// total samples effected divided by the sample rate tells us how
//				// many seconds
//				// the effect samples correspond to. then we multiply by 1000 to get
//				// the value in ms.
//				double millisecondsElapsed = ((double)samplecounter / sampleRate) * 1000;
//				// dividing by the duration of the envolope gives us a value we can
//				// use to choose an
//				// index from the wavetable. if milliseconds elapsed is half of
//				// duration, for instance
//				// we will use a sample from the middle of the wavetable.
//				double mapToIndex = millisecondsElapsed / duration;
//				// calculate a sample
//				double sample = (double)(envform.size() - 1) * mapToIndex;
//				// don't use indices that are out of bounds.
//				if ((int)sample < envform.size() - 1)
//				{
//					int lowSamp = (int)Math.floor(sample);
//					int hiSamp = lowSamp + 1;
//					// get the decimal part, that's how far we are
//					// between the two wavetable samples
//					double percent = lowSamp - sample;
//					// do sample interpolation
//					float s1 = envform.get(lowSamp);
//					float s2 = envform.get(hiSamp);
//					float val = (float)((percent * s1) + ((1 - percent) * s2));
//
//					// apply the amplitude lookup.
//					sigLeft[i] *= val;
//					if ( sigRight != null )
//					{
//						sigRight[i] *= val;
//					}
//
//					samplecounter++;
//					lastsample = (int)sample;
//				}
//				else
//				{
//					triggered = false;
//				}
//			}
//			else
//			{
//				sigLeft[i] *= envform.get(lastsample);
//				if ( sigRight != null )
//				{
//					sigRight[i] *= envform.get(lastsample);
//				}
//			}
//		}
//
//	}
//
}
