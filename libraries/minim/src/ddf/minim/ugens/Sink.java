package ddf.minim.ugens;


/**
 * A Sink is similar to a Summer, but instead of summing all of the UGens patched to it,
 * it simply ticks them and only generates silence. This is useful if you have a UGen that 
 * needs to be ticked but that shouldn't be generating audio, such as an EnvelopeFollower.
 * 
 * @example Synthesis/envelopeFollowerExample
 * 
 * @related Summer
 * 
 * @author Damien Di Fede
 *
 */
// ddf: I'm extending Summer because dealing with our own array of UGens is tricky.
//      Extending Summer means we can keep that code in one place.
public class Sink extends Summer
{
	public Sink() 
	{
		super();
	}

	// we do nothing here because a Sink should always output silence.
	// since Summer always fills the output with silence before ticking
	// its list, we don't even need to do that work.
	@Override
	protected void processSampleFrame( float[] in, float[] out )
	{
	  return;
	}
}
