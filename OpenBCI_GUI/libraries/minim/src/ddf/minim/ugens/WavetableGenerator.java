package ddf.minim.ugens;


/**
 * WavetableGenerator is a helper class for generating Wavetables.
 * The method names come from <a href="http://www.cara.gsu.edu/courses/Csound_Users_Seminar/csound/3.46/CsGens.html">CSound</a>. 
 * Generally speaking, it will often be easier to use the static methods in the Waves class, but the methods 
 * in this class provide more flexibility.
 * 
 * @related Wavetable
 * @related Waves
 *  
 * @author Mark Godfrey &lt;mark.godfrey@gatech.edu&gt;
 */

public class WavetableGenerator
{
	// private constructor so it doesn't show up in documentation
	// and so that instances of this class cannot be created.
	private WavetableGenerator() {}

  /** 
   * Generate a piecewise linear waveform given an array of sample values and the distances 
   * between them. The <code>dist</code> array should contain one value less than the <code>val</code>
   * array. The values in the <code>dist</code> array should also add up to <code>size</code>. For instance, a 
   * call like this:
   * <p>
   * <code>Wavetable table = WavetableGenerator.gen7( 4096, new float[] { 1.0, -1.0, 1.0 }, new int[] { 2048, 2048 } );</code>
   * <p>
   * Would generate a Wavetable that was 4096 samples long and the values of those samples would start at 1.0, 
   * linearly decrease to -1.0 over 2048 samples, and then increase to 1.0 over the next 2048 samples.
   * <p>
   * If you wanted to generate a triangle wavetable with 4096 samples, you'd do this:
   * <p>
   * <code>Wavetable table = WavetableGenerator.gen7( 4069, new float[] { 0.0, 1.0, 0.0, -1.0, 0.0 }, new int[] { 1024, 1024, 1024, 1024 } );</code>
   * 
   * @shortdesc Generate a piecewise linear waveform given an array of sample values and the distances 
   * between them.
   * 
   * @param size 
   * 			int: the size of the Wavetable that you want generate
   * @param val 
   * 			float[]: the sample values used as control points for generating the waveform
   * @param dist 
   * 			int[]: the sample distances between control points in val
   * 
   * @return a Wavetable
   * 
   * @related Wavetable
   */
	public static Wavetable gen7(int size, float[] val, int[] dist)
	{
		//System.out.println("gen7: " + size + ", " + val + ", " + dist);
		float[] waveform = new float[size];

		// check lengths of arrays
		if (val.length - 1 != dist.length)
		{
			System.out.println("Input arrays of invalid sizes!");
			return null;
		}

		// check if size is sum of dists
		int sum = 0;
		for (int i = 0; i < dist.length; i++)
		{
			sum += dist[i];
		}
		if (size != sum)
		{
			System.out.println("Distances do not sum to size!");
			return null;
		}

		// waveform[0] = val[0];
		int i = 0;
		for (int j = 1; j < val.length && i < waveform.length; j++)
		{
			waveform[i] = val[j - 1];
			float m = (val[j] - val[j - 1]) / (float)(dist[j - 1]);
			for (int k = i + 1; k < i + dist[j - 1]; k++)
			{
				waveform[k] = m * (k - i) + val[j - 1];
			}
			i += dist[j - 1];
		}
		waveform[waveform.length - 1] = val[val.length - 1];

		// for(int n = 0; n < waveform.length; n++)
		// System.out.println(waveform[n]);

		return new Wavetable(waveform);
	}

	/**
	 * 
	 * Generates a Wavetable from a list of partials with matching amplitudes and phases. Partial, here, refers 
	 * to a particular sine wave in the harmonic series (see: <a href="http://en.wikipedia.org/wiki/Harmonic_series_%28music%29#Harmonic_vs._partial">Harmonic vs. partial</a>). 
	 * If you want to generate a single sine wave, suitable for playing a single tone of a particular frequency 
	 * in an Oscil, you could use this code:
	 * <p>
	 * <code>Wavetable sine = WavetableGenerator.gen9(4096, new float[] { 1 }, new float[] { 1 }, new float[] { 0 });</code>
	 * <p>
	 * But what this method lets you do, is create a Wavetable that contains several different partials, each with 
	 * a particular amplitude or phase shift. For instance, you could create a Wavetable that plays two pitches an octave 
	 * apart like this:
	 * <p>
	 * <code>Wavetable octave = WavetableGenerator.gen9(4096, new float[] { 1, 2 }, new float[] { 1, 1 }, new float[] { 0, 0 });</code>
	 * <p>
	 * If this is something you want a particular instrument you write to do, then creating a Wavetable that already 
	 * contains the octave and using that in an Oscil will be less computationally expensive than creating two Oscils 
	 * and setting their frequencies an octave apart.
	 * 
	 * @shortdesc Generates a Wavetable from a list of partials with matching amplitudes and phases.
	 * 
	 * @param size 
	 * 			int: how many samples the Wavetable should contain 
	 * @param partial 
	 * 			float[]: a list of partials to generate
	 * @param amp 
	 * 			float[]: the amplitude of each partial
	 * @param phase 
	 * 			float[]: the phase of each partial
	 * 
	 * @return a Wavetable
	 * 
	 * @related Wavetable
	 * 
	 */
	// generates waveform from lists of partials
	// phases are between 0 and 1
	public static Wavetable gen9(int size, float[] partial, float[] amp, float[] phase)
	{

		if (partial.length != amp.length 
		 || partial.length != phase.length
		 || amp.length != phase.length)
		{
			System.err.println("Input arrays of different size!");
			return null;
		}

		float[] waveform = new float[size];

		float index = 0;
		for (int i = 0; i < size; i++)
		{
			index = (float)i / (size - 1);
			for (int j = 0; j < partial.length; j++)
			{
				waveform[i] += amp[j]
						* Math.sin(2 * Math.PI * partial[j] * index + phase[j]);
			}
		}

		return new Wavetable(waveform);
	}

	/**
	 * 
	 * Generate a Wavetable given a list of amplitudes for successive partials (harmonics). These two method 
	 * calls are equivalent:
	 * <p>
	 * <code>Wavetable table = WavetableGenerator.gen9(4096, new float[] { 1, 2, 3 }, new float[] { 1, 0.5, 0.2 }, new float[] { 0, 0, 0 });</code>
	 * <p>
	 * <code>Wavetable table = WavetableGenerator.gen10(4096, new float[] { 1, 0.5, 0.2 });</code>
	 * 
	 * @shortdesc Generate a Wavetable given a list of amplitudes for successive partials (harmonics).
	 * 
	 * @param size 
	 * 			int: the number of samples the Wavetable should contain
	 * @param amp 
	 * 			float[]: the amplitude of each successive partial, beginning with partial 1.
	 * 
	 * @return a Wavetable
	 * 
	 * @see #gen9
	 * @related gen9 ( )
	 * @related Wavetable
	 */
	public static Wavetable gen10(int size, float[] amp)
	{

		float[] waveform = new float[size];

		float index = 0;
		for (int i = 0; i < size; i++)
		{
			index = (float)i / (size - 1);
			for (int j = 0; j < amp.length; j++)
			{
				waveform[i] += amp[j] * Math.sin(2 * Math.PI * (j + 1) * index);
			}
		}

		return new Wavetable(waveform);
	}

}
