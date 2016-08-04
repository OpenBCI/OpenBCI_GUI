/*
 *  Copyright (c) 2007 - 2008 by Damien Di Fede <ddf@compartmental.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

package ddf.minim.analysis;

import ddf.minim.Minim;

/**
 * FFT stands for Fast Fourier Transform. It is an efficient way to calculate the Complex 
 * Discrete Fourier Transform. There is not much to say about this class other than the fact 
 * that when you want to analyze the spectrum of an audio buffer you will almost always use 
 * this class. One restriction of this class is that the audio buffers you want to analyze 
 * must have a length that is a power of two. If you try to construct an FFT with a 
 * <code>timeSize</code> that is not a power of two, an IllegalArgumentException will be 
 * thrown.
 * <p>
 * A Fourier Transform is an algorithm that transforms a signal in the time
 * domain, such as a sample buffer, into a signal in the frequency domain, often
 * called the spectrum. The spectrum does not represent individual frequencies,
 * but actually represents frequency bands centered on particular frequencies.
 * The center frequency of each band is usually expressed as a fraction of the
 * sampling rate of the time domain signal and is equal to the index of the
 * frequency band divided by the total number of bands. The total number of
 * frequency bands is usually equal to the length of the time domain signal, but
 * access is only provided to frequency bands with indices less than half the
 * length, because they correspond to frequencies below the <a
 * href="http://en.wikipedia.org/wiki/Nyquist_frequency">Nyquist frequency</a>.
 * In other words, given a signal of length <code>N</code>, there will be
 * <code>N/2</code> frequency bands in the spectrum.
 * <p>
 * As an example, if you construct an FFT with a
 * <code>timeSize</code> of 1024 and and a <code>sampleRate</code> of 44100
 * Hz, then the spectrum will contain values for frequencies below 22010 Hz,
 * which is the Nyquist frequency (half the sample rate). If you ask for the
 * value of band number 5, this will correspond to a frequency band centered on
 * <code>5/1024 * 44100 = 0.0048828125 * 44100 = 215 Hz</code>. The width of
 * that frequency band is equal to <code>2/1024</code>, expressed as a
 * fraction of the total bandwidth of the spectrum. The total bandwith of the
 * spectrum is equal to the Nyquist frequency, which in this case is 22050, so
 * the bandwidth is equal to about 50 Hz. It is not necessary for you to
 * remember all of these relationships, though it is good to be aware of them.
 * The function <code>getFreq()</code> allows you to query the spectrum with a
 * frequency in Hz and the function <code>getBandWidth()</code> will return
 * the bandwidth in Hz of each frequency band in the spectrum.
 * <p>
 * <b>Usage</b>
 * <p>
 * A typical usage of the FFT is to analyze a signal so that the
 * frequency spectrum may be represented in some way, typically with vertical
 * lines. You could do this in Processing with the following code, where
 * <code>audio</code> is an AudioSource and <code>fft</code> is an FFT.
 * 
 * <pre>
 * fft.forward(audio.left);
 * for (int i = 0; i &lt; fft.specSize(); i++)
 * {
 *   // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
 *   line(i, height, i, height - fft.getBand(i) * 4);
 * }
 * </pre>
 * 
 * <b>Windowing</b>
 * <p>
 * Windowing is the process of shaping the audio samples before transforming them
 * to the frequency domain. The Fourier Transform assumes the sample buffer is is a 
 * repetitive signal, if a sample buffer is not truly periodic within the measured
 * interval sharp discontinuities may arise that can introduce spectral leakage.
 * Spectral leakage is the speading of signal energy across multiple FFT bins. This
 * "spreading" can drown out narrow band signals and hinder detection.
 * </p>
 * <p>
 * A <a href="http://en.wikipedia.org/wiki/Window_function">windowing function</a>
 * attempts to reduce spectral leakage by attenuating the measured sample buffer
 * at its end points to eliminate discontinuities. If you call the <code>window()</code> 
 * function with an appropriate WindowFunction, such as <code>HammingWindow()</code>,
 * the sample buffers passed to the object for analysis will be shaped by the current
 * window before being transformed. The result of using a window is to reduce
 * the leakage in the spectrum somewhat.
 * <p>
 * <b>Averages</b>
 * <p>
 * FFT also has functions that allow you to request the creation of
 * an average spectrum. An average spectrum is simply a spectrum with fewer
 * bands than the full spectrum where each average band is the average of the
 * amplitudes of some number of contiguous frequency bands in the full spectrum.
 * <p>
 * <code>linAverages()</code> allows you to specify the number of averages
 * that you want and will group frequency bands into groups of equal number. So
 * if you have a spectrum with 512 frequency bands and you ask for 64 averages,
 * each average will span 8 bands of the full spectrum.
 * <p>
 * <code>logAverages()</code> will group frequency bands by octave and allows
 * you to specify the size of the smallest octave to use (in Hz) and also how
 * many bands to split each octave into. So you might ask for the smallest
 * octave to be 60 Hz and to split each octave into two bands. The result is
 * that the bandwidth of each average is different. One frequency is an octave
 * above another when it's frequency is twice that of the lower frequency. So,
 * 120 Hz is an octave above 60 Hz, 240 Hz is an octave above 120 Hz, and so on.
 * When octaves are split, they are split based on Hz, so if you split the
 * octave 60-120 Hz in half, you will get 60-90Hz and 90-120Hz. You can see how
 * these bandwidths increase as your octave sizes grow. For instance, the last
 * octave will always span <code>sampleRate/4 - sampleRate/2</code>, which in
 * the case of audio sampled at 44100 Hz is 11025-22010 Hz. These
 * logarithmically spaced averages are usually much more useful than the full
 * spectrum or the linearly spaced averages because they map more directly to
 * how humans perceive sound.
 * <p>
 * <code>calcAvg()</code> allows you to specify the frequency band you want an
 * average calculated for. You might ask for 60-500Hz and this function will
 * group together the bands from the full spectrum that fall into that range and
 * average their amplitudes for you.
 * <p>
 * If you don't want any averages calculated, then you can call
 * <code>noAverages()</code>. This will not impact your ability to use
 * <code>calcAvg()</code>, it will merely prevent the object from calculating
 * an average array every time you use <code>forward()</code>.
 * <p>
 * <b>Inverse Transform</b>
 * <p>
 * FFT also supports taking the inverse transform of a spectrum.
 * This means that a frequency spectrum will be transformed into a time domain
 * signal and placed in a provided sample buffer. The length of the time domain
 * signal will be <code>timeSize()</code> long. The <code>set</code> and
 * <code>scale</code> functions allow you the ability to shape the spectrum
 * already stored in the object before taking the inverse transform. You might
 * use these to filter frequencies in a spectrum or modify it in some other way.
 * 
 * @example Basics/AnalyzeSound
 * 
 * @see FourierTransform
 * @see <a href="http://www.dspguide.com/ch12.htm">The Fast Fourier Transform</a>
 * 
 * @author Damien Di Fede
 * 
 */
public class FFT extends FourierTransform
{
  /**
   * Constructs an FFT that will accept sample buffers that are
   * <code>timeSize</code> long and have been recorded with a sample rate of
   * <code>sampleRate</code>. <code>timeSize</code> <em>must</em> be a
   * power of two. This will throw an exception if it is not.
   * 
   * @param timeSize
   *          int: the length of the sample buffers you will be analyzing
   * @param sampleRate
   *          float: the sample rate of the audio you will be analyzing
   */
  public FFT(int timeSize, float sampleRate)
  {
    super(timeSize, sampleRate);
    if ((timeSize & (timeSize - 1)) != 0)
    {
      throw new IllegalArgumentException("FFT: timeSize must be a power of two.");
    }
    buildReverseTable();
    buildTrigTables();
  }

  protected void allocateArrays()
  {
    spectrum = new float[timeSize / 2 + 1];
    real = new float[timeSize];
    imag = new float[timeSize];
  }

  public void scaleBand(int i, float s)
  {
    if (s < 0)
    {
      Minim.error("Can't scale a frequency band by a negative value.");
      return;
    }
    
    real[i] *= s;
    imag[i] *= s;
    spectrum[i] *= s;
    
    if (i != 0 && i != timeSize / 2)
    {
      real[timeSize - i] = real[i];
      imag[timeSize - i] = -imag[i];
    }
  }

  public void setBand(int i, float a)
  {
    if (a < 0)
    {
      Minim.error("Can't set a frequency band to a negative value.");
      return;
    }
    if (real[i] == 0 && imag[i] == 0)
    {
      real[i] = a;
      spectrum[i] = a;
    }
    else
    {
      real[i] /= spectrum[i];
      imag[i] /= spectrum[i];
      spectrum[i] = a;
      real[i] *= spectrum[i];
      imag[i] *= spectrum[i];
    }
    if (i != 0 && i != timeSize / 2)
    {
      real[timeSize - i] = real[i];
      imag[timeSize - i] = -imag[i];
    }
  }

  // performs an in-place fft on the data in the real and imag arrays
  // bit reversing is not necessary as the data will already be bit reversed
  private void fft()
  {
    for (int halfSize = 1; halfSize < real.length; halfSize *= 2)
    {
      // float k = -(float)Math.PI/halfSize;
      // phase shift step
      // float phaseShiftStepR = (float)Math.cos(k);
      // float phaseShiftStepI = (float)Math.sin(k);
      // using lookup table
      float phaseShiftStepR = cos(halfSize);
      float phaseShiftStepI = sin(halfSize);
      // current phase shift
      float currentPhaseShiftR = 1.0f;
      float currentPhaseShiftI = 0.0f;
      for (int fftStep = 0; fftStep < halfSize; fftStep++)
      {
        for (int i = fftStep; i < real.length; i += 2 * halfSize)
        {
          int off = i + halfSize;
          float tr = (currentPhaseShiftR * real[off]) - (currentPhaseShiftI * imag[off]);
          float ti = (currentPhaseShiftR * imag[off]) + (currentPhaseShiftI * real[off]);
          real[off] = real[i] - tr;
          imag[off] = imag[i] - ti;
          real[i] += tr;
          imag[i] += ti;
        }
        float tmpR = currentPhaseShiftR;
        currentPhaseShiftR = (tmpR * phaseShiftStepR) - (currentPhaseShiftI * phaseShiftStepI);
        currentPhaseShiftI = (tmpR * phaseShiftStepI) + (currentPhaseShiftI * phaseShiftStepR);
      }
    }
  }

  public void forward(float[] buffer)
  {
    if (buffer.length != timeSize)
    {
      Minim
          .error("FFT.forward: The length of the passed sample buffer must be equal to timeSize().");
      return;
    }
    doWindow(buffer);
    // copy samples to real/imag in bit-reversed order
    bitReverseSamples(buffer, 0);
    // perform the fft
    fft();
    // fill the spectrum buffer with amplitudes
    fillSpectrum();
  }
  
  @Override
  public void forward(float[] buffer, int startAt)
  {
	  if ( buffer.length - startAt < timeSize )
	  {
		  Minim.error( "FourierTransform.forward: not enough samples in the buffer between " + 
		               startAt + " and " + buffer.length + " to perform a transform."
		             );
		  return;  
	  }
	  
	  currentWindow.apply( buffer, startAt, timeSize );
	  bitReverseSamples(buffer, startAt);
	  fft();
	  fillSpectrum();
  }

  /**
   * Performs a forward transform on the passed buffers.
   * 
   * @param buffReal the real part of the time domain signal to transform
   * @param buffImag the imaginary part of the time domain signal to transform
   */
  public void forward(float[] buffReal, float[] buffImag)
  {
    if (buffReal.length != timeSize || buffImag.length != timeSize)
    {
      Minim
          .error("FFT.forward: The length of the passed buffers must be equal to timeSize().");
      return;
    }
    setComplex(buffReal, buffImag);
    bitReverseComplex();
    fft();
    fillSpectrum();
  }

  public void inverse(float[] buffer)
  {
    if (buffer.length > real.length)
    {
      Minim
          .error("FFT.inverse: the passed array's length must equal FFT.timeSize().");
      return;
    }
    // conjugate
    for (int i = 0; i < timeSize; i++)
    {
      imag[i] *= -1;
    }
    bitReverseComplex();
    fft();
    // copy the result in real into buffer, scaling as we do
    for (int i = 0; i < buffer.length; i++)
    {
      buffer[i] = real[i] / real.length;
    }
  }

  private int[] reverse;

  private void buildReverseTable()
  {
    int N = timeSize;
    reverse = new int[N];

    // set up the bit reversing table
    reverse[0] = 0;
    for (int limit = 1, bit = N / 2; limit < N; limit <<= 1, bit >>= 1)
      for (int i = 0; i < limit; i++)
        reverse[i + limit] = reverse[i] + bit;
  }

  // copies the values in the samples array into the real array
  // in bit reversed order. the imag array is filled with zeros.
  private void bitReverseSamples(float[] samples, int startAt)
  {
    for (int i = 0; i < timeSize; ++i)
    {
      real[i] = samples[ startAt + reverse[i] ];
      imag[i] = 0.0f;
    }
  }

  // bit reverse real[] and imag[]
  private void bitReverseComplex()
  {
    float[] revReal = new float[real.length];
    float[] revImag = new float[imag.length];
    for (int i = 0; i < real.length; i++)
    {
      revReal[i] = real[reverse[i]];
      revImag[i] = imag[reverse[i]];
    }
    real = revReal;
    imag = revImag;
  }

  // lookup tables

  private float[] sinlookup;
  private float[] coslookup;

  private float sin(int i)
  {
    return sinlookup[i];
  }

  private float cos(int i)
  {
    return coslookup[i];
  }

  private void buildTrigTables()
  {
    int N = timeSize;
    sinlookup = new float[N];
    coslookup = new float[N];
    for (int i = 0; i < N; i++)
    {
      sinlookup[i] = (float) Math.sin(-(float) Math.PI / i);
      coslookup[i] = (float) Math.cos(-(float) Math.PI / i);
    }
  }
}
