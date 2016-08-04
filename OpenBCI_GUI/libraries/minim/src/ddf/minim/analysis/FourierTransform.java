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

import ddf.minim.AudioBuffer;
import ddf.minim.Minim;

/**
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
 * As an example, if you construct a FourierTransform with a
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
 * A typical usage of a FourierTransform is to analyze a signal so that the
 * frequency spectrum may be represented in some way, typically with vertical
 * lines. You could do this in Processing with the following code, where
 * <code>audio</code> is an AudioSource and <code>fft</code> is an FFT (one
 * of the derived classes of FourierTransform).
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
 * FourierTransform also has functions that allow you to request the creation of
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
 * FourierTransform also supports taking the inverse transform of a spectrum.
 * This means that a frequency spectrum will be transformed into a time domain
 * signal and placed in a provided sample buffer. The length of the time domain
 * signal will be <code>timeSize()</code> long. The <code>set</code> and
 * <code>scale</code> functions allow you the ability to shape the spectrum
 * already stored in the object before taking the inverse transform. You might
 * use these to filter frequencies in a spectrum or modify it in some other way.
 * 
 * @author Damien Di Fede
 * @see <a href="http://www.dspguide.com/ch8.htm">The Discrete Fourier Transform</a>
 * 
 * @invisible
 */
public abstract class FourierTransform
{
  /** A constant indicating no window should be used on sample buffers. 
   *  Also referred as a Rectangular window.
   *  
   *  @example Analysis/FFT/Windows
   *  
   *  @related <a href="http://en.wikipedia.org/wiki/Window_function#Rectangular_window">Rectangular window</a>
   *  @related WindowFunction
   */
  public static final WindowFunction NONE = new RectangularWindow();
  
  /** A constant indicating a Hamming window should be used on sample buffers.
   * 
   * @example Analysis/FFT/Windows
   * 
   * @related <a href="http://en.wikipedia.org/wiki/Window_function#Hamming_window">Hamming window</a>
   * @related WindowFunction
   */
  public static final WindowFunction HAMMING = new HammingWindow();
  
  /** A constant indicating a Hann window should be used on sample buffers.
   * 
   *  @example Analysis/FFT/Windows
   *  
   *  @related <a href="http://en.wikipedia.org/wiki/Window_function#Hann_window">Hann window</a>
   *  @related WindowFunction
   */
  public static final WindowFunction HANN = new HannWindow();
  
  /** A constant indicating a Cosine window should be used on sample buffers.
   *  
   *  @example Analysis/FFT/Windows
   *  
   *  @related <a href="http://en.wikipedia.org/wiki/Window_function#Cosine_window">Cosine window</a>
   *  @related WindowFunction
   */
  public static final WindowFunction COSINE = new CosineWindow();
  
  /** A constant indicating a Triangular window should be used on sample buffers.
   *  
   *  @example Analysis/FFT/Windows
   *  
   *  @related <a href="http://en.wikipedia.org/wiki/Window_function#Triangular_window">Triangular window</a>
   *  @related WindowFunction
   */
  public static final WindowFunction TRIANGULAR = new TriangularWindow();
  
  /** A constant indicating a Bartlett window should be used on sample buffers.
   * 
   * @example Analysis/FFT/Windows
   * 
   * @related <a href="http://en.wikipedia.org/wiki/Window_function#Bartlett_window_.28zero_valued_end-points.29">Bartlett window</a>
   * @related WindowFunction
   */
  public static final WindowFunction BARTLETT = new BartlettWindow();
  
  /** A constant indicating a Bartlett-Hann window should be used on sample buffers.
   * 
   * @example Analysis/FFT/Windows
   * 
   * @related <a href="http://en.wikipedia.org/wiki/Window_function#Bartlett.E2.80.93Hann_window">Bartlett-Hann window</a>
   * @related WindowFunction
   */
  public static final WindowFunction BARTLETTHANN = new BartlettHannWindow();
  
  /** A constant indicating a Lanczos window should be used on sample buffers.
   * 
   * @example Analysis/FFT/Windows
   * 
   * @related <a href="http://en.wikipedia.org/wiki/Window_function#Lanczos_window">Lanczos window</a>
   * @related WindowFunction
   */
  public static final WindowFunction LANCZOS = new LanczosWindow();
  
  /** A constant indicating a Blackman window with a default value should be used on sample buffers.
   * 
   * @example Analysis/FFT/Windows 
   * 
   * @related <a href="http://en.wikipedia.org/wiki/Window_function#Blackman_windows">Blackman window</a>
   * @related WindowFunction
   */
  public static final WindowFunction BLACKMAN = new BlackmanWindow();
  
  /** A constant indicating a Gauss with a default value should be used on sample buffers.
   * 
   * @example Analysis/FFT/Windows
   * 
   * @related <a href="http://en.wikipedia.org/wiki/Window_function#Gauss_windows">Gauss window</a>
   * @related WindowFunction
   */
  public static final WindowFunction GAUSS = new GaussWindow();

  protected static final int LINAVG = 1;
  protected static final int LOGAVG = 2;
  protected static final int NOAVG = 3;

  protected static final float TWO_PI = (float) (2 * Math.PI);
  protected int timeSize;
  protected int sampleRate;
  protected float bandWidth;
  protected WindowFunction currentWindow;
  protected float[] real;
  protected float[] imag;
  protected float[] spectrum;
  protected float[] averages;
  protected int whichAverage;
  protected int octaves;
  protected int avgPerOctave;

  /**
   * Construct a FourierTransform that will analyze sample buffers that are
   * <code>ts</code> samples long and contain samples with a <code>sr</code>
   * sample rate.
   * 
   * @param ts
   *          the length of the buffers that will be analyzed
   * @param sr
   *          the sample rate of the samples that will be analyzed
   */
  FourierTransform(int ts, float sr)
  {
    timeSize = ts;
    sampleRate = (int)sr;
    bandWidth = (2f / timeSize) * ((float)sampleRate / 2f);
    noAverages();
    allocateArrays();
    currentWindow = new RectangularWindow(); // a Rectangular window is analogous to using no window. 
  }

  // allocating real, imag, and spectrum are the responsibility of derived
  // classes
  // because the size of the arrays will depend on the implementation being used
  // this enforces that responsibility
  protected abstract void allocateArrays();

  protected void setComplex(float[] r, float[] i)
  {
    if (real.length != r.length && imag.length != i.length)
    {
      Minim
          .error("FourierTransform.setComplex: the two arrays must be the same length as their member counterparts.");
    }
    else
    {
      System.arraycopy(r, 0, real, 0, r.length);
      System.arraycopy(i, 0, imag, 0, i.length);
    }
  }

  // fill the spectrum array with the amps of the data in real and imag
  // used so that this class can handle creating the average array
  // and also do spectrum shaping if necessary
  protected void fillSpectrum()
  {
    for (int i = 0; i < spectrum.length; i++)
    {
      spectrum[i] = (float) Math.sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }

    if (whichAverage == LINAVG)
    {
      int avgWidth = (int) spectrum.length / averages.length;
      for (int i = 0; i < averages.length; i++)
      {
        float avg = 0;
        int j;
        for (j = 0; j < avgWidth; j++)
        {
          int offset = j + i * avgWidth;
          if (offset < spectrum.length)
          {
            avg += spectrum[offset];
          }
          else
          {
            break;
          }
        }
        avg /= j + 1;
        averages[i] = avg;
      }
    }
    else if (whichAverage == LOGAVG)
    {
      for (int i = 0; i < octaves; i++)
      {
        float lowFreq, hiFreq, freqStep;
        if (i == 0)
        {
          lowFreq = 0;
        }
        else
        {
          lowFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - i);
        }
        hiFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - i - 1);
        freqStep = (hiFreq - lowFreq) / avgPerOctave;
        float f = lowFreq;
        for (int j = 0; j < avgPerOctave; j++)
        {
          int offset = j + i * avgPerOctave;
          averages[offset] = calcAvg(f, f + freqStep);
          f += freqStep;
        }
      }
    }
  }

  /**
   * Sets the object to not compute averages.
   * 
   * @related FFT
   */
  public void noAverages()
  {
    averages = new float[0];
    whichAverage = NOAVG;
  }

  /**
   * Sets the number of averages used when computing the spectrum and spaces the
   * averages in a linear manner. In other words, each average band will be
   * <code>specSize() / numAvg</code> bands wide.
   * 
   * @param numAvg
   *          int: how many averages to compute
   *          
   * @example Analysis/SoundSpectrum
   * 
   * @related FFT
   */
  public void linAverages(int numAvg)
  {
    if (numAvg > spectrum.length / 2)
    {
      Minim.error("The number of averages for this transform can be at most "
          + spectrum.length / 2 + ".");
      return;
    }
    else
    {
      averages = new float[numAvg];
    }
    whichAverage = LINAVG;
  }

  /**
   * Sets the number of averages used when computing the spectrum based on the
   * minimum bandwidth for an octave and the number of bands per octave. For
   * example, with audio that has a sample rate of 44100 Hz,
   * <code>logAverages(11, 1)</code> will result in 12 averages, each
   * corresponding to an octave, the first spanning 0 to 11 Hz. To ensure that
   * each octave band is a full octave, the number of octaves is computed by
   * dividing the Nyquist frequency by two, and then the result of that by two,
   * and so on. This means that the actual bandwidth of the lowest octave may
   * not be exactly the value specified.
   * 
   * @param minBandwidth
   *          int: the minimum bandwidth used for an octave, in Hertz.
   * @param bandsPerOctave
   *          int: how many bands to split each octave into
   *
   * @example Analysis/SoundSpectrum
   * 
   * @related FFT
   */
  public void logAverages(int minBandwidth, int bandsPerOctave)
  {
    float nyq = (float) sampleRate / 2f;
    octaves = 1;
    while ((nyq /= 2) > minBandwidth)
    {
      octaves++;
    }
    Minim.debug("Number of octaves = " + octaves);
    avgPerOctave = bandsPerOctave;
    averages = new float[octaves * bandsPerOctave];
    whichAverage = LOGAVG;
  }

  /**
   * Sets the window to use on the samples before taking the forward transform.
   * If an invalid window is asked for, an error will be reported and the
   * current window will not be changed.
   * 
   * @param windowFunction 
   * 			the new WindowFunction to use, typically one of the statically defined 
   * 			windows like HAMMING or BLACKMAN
   * 
   * @related FFT
   * @related WindowFunction
   * 
   * @example Analysis/FFT/Windows
   */
  public void window(WindowFunction windowFunction)
  {
	this.currentWindow = windowFunction;
  }

  protected void doWindow(float[] samples)
  {
    currentWindow.apply(samples);
  }

  /**
   * Returns the length of the time domain signal expected by this transform.
   * 
   * @return int: the length of the time domain signal expected by this transform
   * 
   * @related FFT
   */
  public int timeSize()
  {
    return timeSize;
  }

  /**
   * Returns the size of the spectrum created by this transform. In other words,
   * the number of frequency bands produced by this transform. This is typically
   * equal to <code>timeSize()/2 + 1</code>, see above for an explanation.
   * 
   * @return int: the size of the spectrum
   * 
   * @example Basics/AnalyzeSound
   * 
   * @related FFT
   */
  public int specSize()
  {
    return spectrum.length;
  }

  /**
   * Returns the amplitude of the requested frequency band.
   * 
   * @param i
   *          int: the index of a frequency band
   *          
   * @return float: the amplitude of the requested frequency band
   * 
   * @example Basics/AnalyzeSound
   * 
   * @related FFT
   */
  public float getBand(int i)
  {
    if (i < 0) i = 0;
    if (i > spectrum.length - 1) i = spectrum.length - 1;
    return spectrum[i];
  }

  /**
   * Returns the width of each frequency band in the spectrum (in Hz). It should
   * be noted that the bandwidth of the first and last frequency bands is half
   * as large as the value returned by this function.
   * 
   * @return float: the width of each frequency band in Hz.
   * 
   * @related FFT
   */
  public float getBandWidth()
  {
    return bandWidth;
  }
  
  /**
   * Returns the bandwidth of the requested average band. Using this information 
   * and the return value of getAverageCenterFrequency you can determine the 
   * lower and upper frequency of any average band.
   * 
   * @param averageIndex
   * 			int: the index of the average you want the bandwidth of
   * 
   * @return float: the bandwidth of the request average band, in Hertz.
   * 
   * @example Analysis/SoundSpectrum
   * 
   * @see #getAverageCenterFrequency(int)
   * 
   * @related getAverageCenterFrequency ( )
   * @related FFT
   *
   */
  public float getAverageBandWidth( int averageIndex )
  {
    if ( whichAverage == LINAVG )
    {
      // an average represents a certain number of bands in the spectrum
      int avgWidth = (int) spectrum.length / averages.length;
      return avgWidth * getBandWidth();
            
    }
    else if ( whichAverage == LOGAVG )
    {
      // which "octave" is this index in?
      int octave = averageIndex / avgPerOctave;
      float lowFreq, hiFreq, freqStep;
      // figure out the low frequency for this octave
      if (octave == 0)
      {
        lowFreq = 0;
      }
      else
      {
        lowFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - octave);
      }
      // and the high frequency for this octave
      hiFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - octave - 1);
      // each average band within the octave will be this big
      freqStep = (hiFreq - lowFreq) / avgPerOctave;
      
      return freqStep;
    }
	    
	  return 0;
  }

  /**
   * Sets the amplitude of the <code>i<sup>th</sup></code> frequency band to
   * <code>a</code>. You can use this to shape the spectrum before using
   * <code>inverse()</code>.
   * 
   * @param i
   *          int: the frequency band to modify
   * @param a
   *          float: the new amplitude
   *          
   * @example Analysis/FFT/SetBand
   * 
   * @related FFT
   */
  public abstract void setBand(int i, float a);

  /**
   * Scales the amplitude of the <code>i<sup>th</sup></code> frequency band
   * by <code>s</code>. You can use this to shape the spectrum before using
   * <code>inverse()</code>.
   * 
   * @param i
   *          int: the frequency band to modify
   * @param s
   *          float: the scaling factor
   *          
   * @example Analysis/FFT/ScaleBand
   * 
   * @related FFT
   */
  public abstract void scaleBand(int i, float s);

  /**
   * Returns the index of the frequency band that contains the requested
   * frequency.
   * 
   * @param freq
   *          float: the frequency you want the index for (in Hz)
   *          
   * @return int: the index of the frequency band that contains freq
   * 
   * @related FFT
   * 
   * @example Analysis/SoundSpectrum
   */
  public int freqToIndex(float freq)
  {
    // special case: freq is lower than the bandwidth of spectrum[0]
    if (freq < getBandWidth() / 2) return 0;
    // special case: freq is within the bandwidth of spectrum[spectrum.length - 1]
    if (freq > sampleRate / 2 - getBandWidth() / 2) return spectrum.length - 1;
    // all other cases
    float fraction = freq / (float) sampleRate;
    int i = Math.round(timeSize * fraction);
    return i;
  }
  
  /**
   * Returns the middle frequency of the i<sup>th</sup> band.
   * 
   * @param i
   *        int: the index of the band you want to middle frequency of
   * 
   * @return float: the middle frequency, in Hertz, of the requested band of the spectrum
   * 
   * @related FFT
   */
  public float indexToFreq(int i)
  {
    float bw = getBandWidth();
    // special case: the width of the first bin is half that of the others.
    //               so the center frequency is a quarter of the way.
    if ( i == 0 ) return bw * 0.25f;
    // special case: the width of the last bin is half that of the others.
    if ( i == spectrum.length - 1 ) 
    {
      float lastBinBeginFreq = (sampleRate / 2) - (bw / 2);
      float binHalfWidth = bw * 0.25f;
      return lastBinBeginFreq + binHalfWidth;
    }
    // the center frequency of the ith band is simply i*bw
    // because the first band is half the width of all others.
    // treating it as if it wasn't offsets us to the middle 
    // of the band.
    return i*bw;
  }
  
  /**
   * Returns the center frequency of the i<sup>th</sup> average band.
   * 
   * @param i
   *     int: which average band you want the center frequency of.
   *     
   * @return float: the center frequency of the i<sup>th</sup> average band.
   * 
   * @related FFT
   * 
   * @example Analysis/SoundSpectrum
   */
  public float getAverageCenterFrequency(int i)
  {
    if ( whichAverage == LINAVG )
    {
      // an average represents a certain number of bands in the spectrum
      int avgWidth = (int) spectrum.length / averages.length;
      // the "center" bin of the average, this is fudgy.
      int centerBinIndex = i*avgWidth + avgWidth/2;
      return indexToFreq(centerBinIndex);
            
    }
    else if ( whichAverage == LOGAVG )
    {
      // which "octave" is this index in?
      int octave = i / avgPerOctave;
      // which band within that octave is this?
      int offset = i % avgPerOctave;
      float lowFreq, hiFreq, freqStep;
      // figure out the low frequency for this octave
      if (octave == 0)
      {
        lowFreq = 0;
      }
      else
      {
        lowFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - octave);
      }
      // and the high frequency for this octave
      hiFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - octave - 1);
      // each average band within the octave will be this big
      freqStep = (hiFreq - lowFreq) / avgPerOctave;
      // figure out the low frequency of the band we care about
      float f = lowFreq + offset*freqStep;
      // the center of the band will be the low plus half the width
      return f + freqStep/2;
    }
    
    return 0;
  }
   

  /**
   * Gets the amplitude of the requested frequency in the spectrum.
   * 
   * @param freq
   *          float: the frequency in Hz
   *          
   * @return float: the amplitude of the frequency in the spectrum
   * 
   * @related FFT
   */
  public float getFreq(float freq)
  {
    return getBand(freqToIndex(freq));
  }

  /**
   * Sets the amplitude of the requested frequency in the spectrum to
   * <code>a</code>.
   * 
   * @param freq
   *          float: the frequency in Hz
   * @param a
   *          float: the new amplitude
   *          
   * @example Analysis/FFT/SetFreq
   * 
   * @related FFT
   */
  public void setFreq(float freq, float a)
  {
    setBand(freqToIndex(freq), a);
  }

  /**
   * Scales the amplitude of the requested frequency by <code>a</code>.
   * 
   * @param freq
   *          float: the frequency in Hz
   * @param s
   *          float: the scaling factor
   *          
   * @example Analysis/FFT/ScaleFreq
   * 
   * @related FFT
   */
  public void scaleFreq(float freq, float s)
  {
    scaleBand(freqToIndex(freq), s);
  }

  /**
   * Returns the number of averages currently being calculated.
   * 
   * @return int: the length of the averages array
   * 
   * @related FFT
   */
  public int avgSize()
  {
    return averages.length;
  }

  /**
   * Gets the value of the <code>i<sup>th</sup></code> average.
   * 
   * @param i
   *          int: the average you want the value of
   * @return float: the value of the requested average band
   * 
   * @related FFT
   */
  public float getAvg(int i)
  {
    float ret;
    if (averages.length > 0)
      ret = averages[i];
    else
      ret = 0;
    return ret;
  }

  /**
   * Calculate the average amplitude of the frequency band bounded by
   * <code>lowFreq</code> and <code>hiFreq</code>, inclusive.
   * 
   * @param lowFreq
   *          float: the lower bound of the band, in Hertz
   * @param hiFreq
   *          float: the upper bound of the band, in Hertz
   *          
   * @return float: the average of all spectrum values within the bounds
   * 
   * @related FFT
   */
  public float calcAvg(float lowFreq, float hiFreq)
  {
    int lowBound = freqToIndex(lowFreq);
    int hiBound = freqToIndex(hiFreq);
    float avg = 0;
    for (int i = lowBound; i <= hiBound; i++)
    {
      avg += spectrum[i];
    }
    avg /= (hiBound - lowBound + 1);
    return avg;
  }
  
  /**
   * Get the Real part of the Complex representation of the spectrum.
   * 
   * @return float[]: an array containing the values for the Real part of the spectrum.
   * 
   * @related FFT
   */
  public float[] getSpectrumReal()
  {
	  return real;
  }
  
  /**
   * Get the Imaginary part of the Complex representation of the spectrum.
   * 
   * @return float[]: an array containing the values for the Imaginary part of the spectrum.
   * 
   * @related FFT
   */
  public float[] getSpectrumImaginary()
  {
	  return imag;
  }
  

  /**
   * Performs a forward transform on <code>buffer</code>.
   * 
   * @param buffer
   *          float[]: the buffer to analyze, must be the same length as timeSize()
   *    
   * @example Basics/AnalyzeSound
   * 
   * @related FFT
   */
  public abstract void forward(float[] buffer);
  
  /**
   * Performs a forward transform on values in <code>buffer</code>.
   * 
   * @param buffer
   *          float[]: the buffer to analyze, must be the same length as timeSize()
   * @param startAt
   *          int: the index to start at in the buffer. there must be at least timeSize() samples
   *          between the starting index and the end of the buffer. If there aren't, an
   *          error will be issued and the operation will not be performed.
   *          
   */
  public void forward(float[] buffer, int startAt)
  {
    if ( buffer.length - startAt < timeSize )
    {
      Minim.error( "FourierTransform.forward: not enough samples in the buffer between " + 
                   startAt + " and " + buffer.length + " to perform a transform."
                 );
      return;
    }
    
    // copy the section of samples we want to analyze
    float[] section = new float[timeSize];
    System.arraycopy(buffer, startAt, section, 0, section.length);
    forward(section);
  }

  /**
   * Performs a forward transform on <code>buffer</code>.
   * 
   * @param buffer
   *          AudioBuffer: the buffer to analyze
   *         
   */
  public void forward(AudioBuffer buffer)
  {
    forward(buffer.toArray());
  }

  /**
   * Performs a forward transform on <code>buffer</code>.
   * 
   * @param buffer
   *          AudioBuffer: the buffer to analyze
   * @param startAt
   *          int: the index to start at in the buffer. there must be at least timeSize() samples
   *          between the starting index and the end of the buffer. If there aren't, an
   *          error will be issued and the operation will not be performed.
   *         
   */
  public void forward(AudioBuffer buffer, int startAt)
  {
    forward(buffer.toArray(), startAt);
  }
  
  /**
   * Performs an inverse transform of the frequency spectrum and places the
   * result in <code>buffer</code>.
   * 
   * @param buffer
   *          float[]: the buffer to place the result of the inverse transform in
   *          
   *          
   * @related FFT
   */
  public abstract void inverse(float[] buffer);

  /**
   * Performs an inverse transform of the frequency spectrum and places the
   * result in <code>buffer</code>.
   * 
   * @param buffer
   *          AudioBuffer: the buffer to place the result of the inverse transform in
   *          
   */
  public void inverse(AudioBuffer buffer)
  {
    inverse(buffer.toArray());
  }

  /**
   * Performs an inverse transform of the frequency spectrum represented by
   * freqReal and freqImag and places the result in buffer.
   * 
   * @param freqReal
   *          float[]: the real part of the frequency spectrum
   * @param freqImag
   *          float[]: the imaginary part the frequency spectrum
   * @param buffer
   *          float[]: the buffer to place the inverse transform in
   */
  public void inverse(float[] freqReal, float[] freqImag, float[] buffer)
  {
    setComplex(freqReal, freqImag);
    inverse(buffer);
  }
}
