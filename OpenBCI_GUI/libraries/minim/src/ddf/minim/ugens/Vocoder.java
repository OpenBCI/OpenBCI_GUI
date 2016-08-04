package ddf.minim.ugens;

import ddf.minim.UGen;
import ddf.minim.analysis.FFT;

/**
 * Vocoder is a UGen that performs very basic <a href="http://en.wikipedia.org/wiki/Vocoder">vocoding</a>.
 * It works by analyzing the audio input and the modulator input with FFTs and then multiplying 
 * the audio input's spectrum by the modulator's spectrum. 
 * 
 * @example Synthesis/vocoderExample
 * 
 * @author Damien Di Fede
 *
 */
public class Vocoder extends UGen
{
	/**
	 * The audio you want processed by the Vocoder.
	 * If you are going for the classic robot vocals sound,
	 * you would patch the synth to this input, typically
	 * something with a lot of high frequency content, like Waves.SAW.
	 * 
	 * @shortdesc The audio you want processed by the Vocoder.
	 * 
	 * @related Vocoder
	 */
	public UGenInput	audio;

	/**
	 * The signal that will be used to transform the audio input.
	 * If you are going for the classic robot vocals sound,
	 * you would patch the vocals to this input.
	 * 
	 * @shortdesc The signal that will be used to transform the audio input.
	 * 
	 * @related Vocoder
	 */
	public UGenInput	modulator;

	// the window size we use for analysis
	private int			m_windowSize;

	// how many samples should pass between the
	// beginning of each window
	private int			m_windowSpacing;
	// the sample data from audio
	private float[]		m_audioSamples;
	// the sample data from carrier
	private float[]		m_modulatorSamples;
	// our output
	private float[]		m_outputSamples;
	// where we are in our sampling arrays
	private int			m_index;
	// where we are in our output array
	private int			m_outputIndex;

	// sample counter for triggering the next window
	private int			m_triggerCount;
	// the float array we use for constructing our analysis window
	private float[]		m_analysisSamples;
	private float		m_outputScale;

	// used to analyze the audio input
	private FFT			m_audioFFT;
	// used to analyze the modulator input
	private FFT			m_modulatorFFT;

	/**
	 * Constructs a Vocoder.
	 * 
	 * @param windowSize
	 * 			int: the number of sample frames to use for 
	 * 				 each FFT analysis. Smaller window sizes 
	 * 				 will have better performance, but lower
	 * 				 sound quality. the window size must also 
	 * 				 be a power of two, which is a requirement 
	 * 				 for using an FFT.
	 * 
	 * @param windowCount
	 * 			int: the number of overlapping windows to use. 
	 * 				 this must be at least 1 with larger values
	 * 				 causing the analysis windows to overlap 
	 * 				 with each other to a greater degree.
	 * 				 For instance, with a windowSize of 1024 and 
	 * 				 a windowCount of 2, a 1024 sample frame FFT 
	 * 				 will be calculated every 512 sample frames. 
	 * 				 With 3 windows, every 341 samples, and so forth.
	 * 				 More windows generally equates to better quality.
	 * 
	 *  @related Vocoder
	 */
	public Vocoder(int windowSize, int windowCount)
	{
		audio = new UGenInput( InputType.AUDIO );
		modulator = new UGenInput( InputType.AUDIO );

		float overlapPercent = 1.f;
		m_outputScale = 1.f;
		if ( windowCount > 1 )
		{
			overlapPercent = 1.f / (float)windowCount;
			m_outputScale = overlapPercent / 8.f;
		}
		m_windowSize = windowSize;
		m_windowSpacing = (int)( windowSize * overlapPercent );
		int bufferSize = m_windowSize * 2 - m_windowSpacing;
		m_audioSamples = new float[bufferSize];
		m_modulatorSamples = new float[bufferSize];
		m_outputSamples = new float[bufferSize];
		m_analysisSamples = new float[windowSize];
		m_index = 0;
		m_triggerCount = m_windowSize;
		// need to defer creation of the FFT objects until we know our sample
		// rate.
	}

	protected void sampleRateChanged()
	{
		m_audioFFT = new FFT( m_windowSize, sampleRate() );
		m_audioFFT.window( FFT.HAMMING );
		m_modulatorFFT = new FFT( m_windowSize, sampleRate() );
		m_modulatorFFT.window( FFT.HAMMING );
	}

	private void analyze(FFT fft, float[] src)
	{
		// copy the previous windowSize samples into our analysis window
		for ( int i = m_index - m_windowSize, j = 0; i < m_index; ++i, ++j )
		{
			m_analysisSamples[j] = ( i < 0 ) ? src[src.length + i] : src[i];
		}
		fft.forward( m_analysisSamples );
	}

	protected void uGenerate(float[] out)
	{
		m_audioSamples[m_index] = audio.getLastValue();
		m_modulatorSamples[m_index] = modulator.getLastValue();
		++m_index;
		--m_triggerCount;
		if ( m_index == m_audioSamples.length )
		{
			m_index = 0;
		}

		// we reached the end of our window. analyze and synthesize!
		if ( m_triggerCount == 0 )
		{
			analyze( m_audioFFT, m_audioSamples );
			analyze( m_modulatorFFT, m_modulatorSamples );

			for ( int i = 0; i < m_audioFFT.specSize(); ++i )
			{
				m_audioFFT.scaleBand( i, m_modulatorFFT.getBand( i ) );
			}

			// synthesize
			m_audioFFT.inverse( m_analysisSamples );

			// window
			FFT.HAMMING.apply( m_analysisSamples );

			// accumulate
			for ( int a = 0; a < m_windowSize; ++a )
			{
				int outIndex = m_outputIndex + a;
				if ( outIndex >= m_outputSamples.length )
				{
					outIndex -= m_outputSamples.length;
				}
				m_outputSamples[outIndex] += m_analysisSamples[a] * m_outputScale;
			}

			m_triggerCount = m_windowSpacing;
		}

		for ( int i = 0; i < out.length; ++i )
		{
			out[i] = m_outputSamples[m_outputIndex];
		}
		// eat it.
		m_outputSamples[m_outputIndex] = 0.f;
		// next!
		++m_outputIndex;
		if ( m_outputIndex == m_outputSamples.length )
		{
			m_outputIndex = 0;
		}
	}
}
