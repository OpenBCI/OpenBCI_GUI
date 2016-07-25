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
 * The BeatDetect class allows you to analyze an audio stream for beats (rhythmic onsets). 
 * <a href="http://www.gamedev.net/reference/programming/features/beatdetection">Beat
 * Detection Algorithms</a> by Frederic Patin describes beats in the following
 * way: <blockquote> The human listening system determines the rhythm of music
 * by detecting a pseudo periodical succession of beats. The signal which is
 * intercepted by the ear contains a certain energy, this energy is converted
 * into an electrical signal which the brain interprets. Obviously, The more
 * energy the sound transports, the louder the sound will seem. But a sound will
 * be heard as a <em>beat</em> only if his energy is largely superior to the
 * sound's energy history, that is to say if the brain detects a
 * <em>brutal variation in sound energy</em>. Therefore if the ear intercepts
 * a monotonous sound with sometimes big energy peaks it will detect beats,
 * however, if you play a continuous loud sound you will not perceive any beats.
 * Thus, the beats are big variations of sound energy. </blockquote> In fact,
 * the two algorithms in this class are based on two algorithms described in
 * that paper.
 * <p>
 * To use this class, inside of <code>draw()</code> you must first call
 * <code>detect()</code>, passing the <code>AudioBuffer</code> you want to
 * analyze. You may then use the <code>isXXX</code> functions to find out what
 * beats have occurred in that frame. For example, you might use
 * <code>isKick()</code> to cause a circle to pulse.
 * <p>
 * BeatDetect has two modes: sound energy tracking and frequency energy
 * tracking. In sound energy mode, the level of the buffer, as returned by
 * <code>level()</code>, is used as the instant energy in each frame. Beats,
 * then, are spikes in this value, relative to the previous one second of sound.
 * In frequency energy mode, the same process is used but instead of tracking
 * the level of the buffer, an FFT is used to obtain a spectrum, which is then
 * divided into average bands using <code>logAverages()</code>, and each of
 * these bands is tracked individually. The result is that it is possible to
 * track sounds that occur in different parts of the frequency spectrum
 * independently (like the kick drum and snare drum).
 * <p>
 * In sound energy mode you use <code>isOnset()</code> to query the algorithm
 * and in frequency energy mode you use <code>isOnset(int i)</code>,
 * <code>isKick()</code>, <code>isSnare()</code>, and
 * <code>isRange()</code> to query particular frequnecy bands or ranges of
 * frequency bands. It should be noted that <code>isKick()</code>,
 * <code>isSnare()</code>, and <code>isHat()</code> merely call
 * <code>isRange()</code> with values determined by testing the algorithm
 * against music with a heavy beat and they may not be appropriate for all kinds
 * of music. If you find they are performing poorly with your music, you should
 * use <code>isRange()</code> directly to locate the bands that provide the
 * most meaningful information for you.
 * 
 * @author Damien Di Fede
 * 
 * @example Analysis/SoundEnergyBeatDetection
 */

public class BeatDetect
{
	/** Constant used to request frequency energy tracking mode.
	 * 
	 *  @example Analysis/FrequencyEnergyBeatDetection
	 */
	public static final int	FREQ_ENERGY		= 0;

	/** Constant used to request sound energy tracking mode.
	 * 
	 *  @example Analysis/SoundEnergyBeatDetection
	 */
	public static final int	SOUND_ENERGY	= 1;

	private int					algorithm;
	private int					sampleRate;
	private int					timeSize;
	private int					valCnt;
	private float[]			valGraph;
	private int					sensitivity;
	// for circular buffer support
	private int					insertAt;
	// vars for sEnergy
	private boolean			isOnset;
	private float[]			eBuffer;
	private float[]			dBuffer;
	private long				timer;
	// vars for fEnergy
	private boolean[]			fIsOnset;
	private FFT					spect;
	private float[][]			feBuffer;
	private float[][]			fdBuffer;
	private long[]				fTimer;
	private float[]			varGraph;
	private int					varCnt;

	/**
	 * Create a BeatDetect object that is in SOUND_ENERGY mode.
	 * <code>timeSize</code> and <code>sampleRate</code> will be set to 1024
	 * and 44100, respectively, so that it is possible to switch into FREQ_ENERGY
	 * mode with meaningful values.
	 * 
	 */
	public BeatDetect()
	{
		sampleRate = 44100;
		timeSize = 1024;
		initSEResources();
		initGraphs();
		algorithm = SOUND_ENERGY;
		sensitivity = 10;
	}

	/**
	 * Create a BeatDetect object that is in FREQ_ENERGY mode and expects a
	 * sample buffer with the requested attributes.
	 * 
	 * @param timeSize
	 *           int: the size of the buffer
	 * @param sampleRate
	 *           float: the sample rate of the samples in the buffer
	 *           
	 * @related BeatDetect
	 */
	public BeatDetect(int timeSize, float sampleRate)
	{
		this.sampleRate = (int) sampleRate;
		this.timeSize = timeSize;
		initFEResources();
		initGraphs();
		algorithm = FREQ_ENERGY;
		sensitivity = 10;
	}

	/**
	 * Set the object to use the requested algorithm. If an invalid value is
	 * passed, the function will report and error and default to
	 * BeatDetect.SOUND_ENERGY
	 * 
	 * @param algo
	 *           int: either BeatDetect.SOUND_ENERGY or BeatDetect.FREQ_ENERGY
	 *           
	 * @related BeatDetect
	 */
	public void detectMode(int algo)
	{
		if (algo < 0 || algo > 1)
		{
			Minim.error("Unrecognized detect mode, defaulting to SOUND_ENERGY.");
			algo = SOUND_ENERGY;
		}
		if (algo == SOUND_ENERGY)
		{
			if (algorithm == FREQ_ENERGY)
			{
				releaseFEResources();
				initSEResources();
				initGraphs();
				algorithm = algo;
			}
		}
		else
		{
			if (algorithm == SOUND_ENERGY)
			{
				releaseSEResources();
				initFEResources();
				initGraphs();
				algorithm = FREQ_ENERGY;
			}
		}
	}

	private void initGraphs()
	{
		valCnt = varCnt = 0;
		valGraph = new float[512];
		varGraph = new float[512];
	}

	private void initSEResources()
	{
		isOnset = false;
		eBuffer = new float[sampleRate / timeSize];
		dBuffer = new float[sampleRate / timeSize];
		timer = System.currentTimeMillis();
		insertAt = 0;
	}

	private void initFEResources()
	{
		spect = new FFT(timeSize, sampleRate);
		spect.logAverages(60, 3);
		int numAvg = spect.avgSize();
		fIsOnset = new boolean[numAvg];
		feBuffer = new float[numAvg][sampleRate / timeSize];
		fdBuffer = new float[numAvg][sampleRate / timeSize];
		fTimer = new long[numAvg];
		long start = System.currentTimeMillis();
		for (int i = 0; i < fTimer.length; i++)
		{
			fTimer[i] = start;
		}
		insertAt = 0;
	}

	private void releaseSEResources()
	{
		isOnset = false;
		eBuffer = null;
		dBuffer = null;
		timer = 0;
	}

	private void releaseFEResources()
	{
		spect = null;
		fIsOnset = null;
		feBuffer = null;
		fdBuffer = null;
		fTimer = null;
	}

	/**
	 * Analyze the samples in <code>buffer</code>. 
	 * This is a cumulative process, so you must call this function every frame.
	 * 
	 * @param buffer
	 *           AudioBuffer: the buffer to analyze.
	 *           
	 * @example Analysis/SoundEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public void detect(AudioBuffer buffer)
	{
		detect( buffer.toArray() );
	}
	

	/**
	 * Analyze the samples in <code>buffer</code>. This is a cumulative
	 * process, so you must call this function every frame.
	 * 
	 * @param buffer
	 *           float[]: the buffer to analyze
	 *           
	 * @related BeatDetect
	 */
	public void detect(float[] buffer)
	{
		switch (algorithm)
		{
		case SOUND_ENERGY:
			sEnergy(buffer);
			break;
		case FREQ_ENERGY:
			fEnergy(buffer);
			break;
		}
	}
	
	/**
	 * In frequency energy mode this returns the number of frequency bands 
	 * currently being used. In sound energy mode this always returns 0.
	 * 
	 * @return int: the length of the FFT's averages array
	 * 
	 * @related BeatDetect
	 */
	public int detectSize()
	{
		if ( algorithm == FREQ_ENERGY )
		{
			return spect.avgSize();
		}

		return 0;
	}
	
	@Deprecated
	public int dectectSize()
	{
		return detectSize();
	}
	
	/**
	 * Returns the center frequency of the i<sup>th</sup> frequency band.
	 * In sound energy mode this always returns 0.
	 * 
	 * @param i
	 *     int: which detect band you want the center frequency of.
	 *     
	 *  @return float: the center frequency of the i<sup>th</sup> frequency band
	 *  
	 *  @related BeatDetect
	 */
	public float getDetectCenterFrequency(int i)
	{
	  if ( algorithm == FREQ_ENERGY )
	  {
	    return spect.getAverageCenterFrequency(i);
	  }

	  return 0;
	}

	/**
	 * Sets the sensitivity of the algorithm. After a beat has been detected, the
	 * algorithm will wait for <code>millis</code> milliseconds before allowing
	 * another beat to be reported. You can use this to dampen the algorithm if
	 * it is giving too many false-positives. The default value is 10, which is
	 * essentially no damping. If you try to set the sensitivity to a negative
	 * value, an error will be reported and it will be set to 10 instead.
	 * 
	 * @param millis
	 *           int: the sensitivity in milliseconds
	 *           
	 * @example Analysis/FrequencyEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public void setSensitivity(int millis)
	{
		if (millis < 0)
		{
			Minim.error("BeatDetect: sensitivity cannot be less than zero. Defaulting to 10.");
			sensitivity = 10;
		}
		else
		{
			sensitivity = millis;
		}
	}
	
	/**
	 * In sound energy mode this returns true when a beat has been detected. In
	 * frequency energy mode this always returns false.
	 * 
	 * @return boolean: true if a beat has been detected.
	 * 
	 * @example Analysis/SoundEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public boolean isOnset()
	{
		return isOnset;
	}

	/**
	 * In frequency energy mode this returns true when a beat has been detect in
	 * the <code>i<sup>th</sup></code> frequency band. In sound energy mode
	 * this always returns false.
	 * 
	 * @param i
	 *           int: the frequency band to query
	 * @return boolean: true if a beat has been detected in the requested band
	 * 
	 * @example Analysis/SoundEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public boolean isOnset(int i)
	{
		if (algorithm == SOUND_ENERGY)
		{
			return false;
		}
		return fIsOnset[i];
	}

	/**
	 * In frequency energy mode this returns true if a beat corresponding to the
	 * frequency range of a kick drum has been detected. This has been tuned to
	 * work well with dance / techno music and may not perform well with other
	 * styles of music. In sound energy mode this always returns false.
	 * 
	 * @return boolean: true if a kick drum beat has been detected
	 * 
	 * @example Analysis/FrequencyEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public boolean isKick()
	{
		if (algorithm == SOUND_ENERGY)
		{
			return false;
		}
		int upper = 6 >= spect.avgSize() ? spect.avgSize() : 6;
		return isRange(1, upper, 2);
	}

	/**
	 * In frequency energy mode this returns true if a beat corresponding to the
	 * frequency range of a snare drum has been detected. This has been tuned to
	 * work well with dance / techno music and may not perform well with other
	 * styles of music. In sound energy mode this always returns false.
	 * 
	 * @return boolean: true if a snare drum beat has been detected
	 * 
	 * @example Analysis/FrequencyEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public boolean isSnare()
	{
		if (algorithm == SOUND_ENERGY)
		{
			return false;
		}
		int lower = 8 >= spect.avgSize() ? spect.avgSize() : 8;
		int upper = spect.avgSize() - 1;
		int thresh = (upper - lower) / 3 + 1;
		return isRange(lower, upper, thresh);
	}

	/**
	 * In frequency energy mode this returns true if a beat corresponding to the
	 * frequency range of a hi hat has been detected. This has been tuned to work
	 * well with dance / techno music and may not perform well with other styles
	 * of music. In sound energy mode this always returns false.
	 * 
	 * @return boolean: true if a hi hat beat has been detected
	 * 
	 * @example Analysis/FrequencyEnergyBeatDetection
	 * 
	 * @related BeatDetect
	 */
	public boolean isHat()
	{
		if (algorithm == SOUND_ENERGY)
		{
			return false;
		}
		int lower = spect.avgSize() - 7 < 0 ? 0 : spect.avgSize() - 7;
		int upper = spect.avgSize() - 1;
		return isRange(lower, upper, 1);
	}

	/**
	 * In frequency energy mode this returns true if at least
	 * <code>threshold</code> bands of the bands included in the range
	 * <code>[low, high]</code> have registered a beat. In sound energy mode
	 * this always returns false.
	 * 
	 * @param low
	 *           int: the index of the lower band
	 * @param high
	 *           int: the index of the higher band
	 * @param threshold
	 *           int: the smallest number of bands in the range
	 *           <code>[low, high]</code> that need to have registered a beat
	 *           for this to return true
	 * @return boolean: true if at least <code>threshold</code> bands of the bands
	 *         included in the range <code>[low, high]</code> have registered a
	 *         beat
	 *         
	 * @related BeatDetect
	 */
	public boolean isRange(int low, int high, int threshold)
	{
		if (algorithm == SOUND_ENERGY)
		{
			return false;
		}
		int num = 0;
		for (int i = low; i < high + 1; i++)
		{
			if (isOnset(i))
			{
				num++;
			}
		}
		return num >= threshold;
	}

	/**
	 * Draws some debugging visuals in the passed PApplet. The visuals drawn when
	 * in frequency energy mode are a good way to determine what values to use
	 * with <code>inRange()</code> if the provided drum detecting functions
	 * aren't what you need or aren't working well.
	 * 
	 * @param p
	 *           the PApplet to draw in
	 */
//	public void drawGraph(PApplet p)
//	{
//		if (algorithm == SOUND_ENERGY)
//		{
//			// draw valGraph
//			for (int i = 0; i < valCnt; i++)
//			{
//				p.stroke(255);
//				p.line(i, (p.height / 2) - valGraph[i], i, (p.height / 2)
//						+ valGraph[i]);
//			}
//			// draw varGraph
//			for (int i = 0; i < varCnt - 1; i++)
//			{
//				p.stroke(255);
//				p.line(i, p.height - varGraph[i], i + 1, p.height - varGraph[i + 1]);
//			}
//		}
//		else
//		{
//			p.strokeWeight(5);
//			for (int i = 0; i < fTimer.length; i++)
//			{
//				int c = (i % 3 == 0) ? p.color(255, 0, 0) : p.color(255);
//				p.stroke(c);
//				long clock = System.currentTimeMillis();
//				if (clock - fTimer[i] < sensitivity)
//				{
//					float h = PApplet.map(clock - fTimer[i], 0, sensitivity, 100, 0);
//					p.line((i * 10), p.height - h, (i * 10), p.height);
//				}
//			}
//		}
//	}

	private void sEnergy(float[] samples)
	{
		// compute the energy level
		float level = 0;
		for (int i = 0; i < samples.length; i++)
		{
			level += (samples[i] * samples[i]);
		}
		level /= samples.length;
		level = (float) Math.sqrt(level);
		float instant = level * 100;
		// compute the average local energy
		float E = average(eBuffer);
		// compute the variance of the energies in eBuffer
		float V = variance(eBuffer, E);
		// compute C using a linear digression of C with V
		float C = (-0.0025714f * V) + 1.5142857f;
		// filter negaive values
		float diff = (float)Math.max(instant - C * E, 0);
		pushVal(diff);
		// find the average of only the positive values in dBuffer
		float dAvg = specAverage(dBuffer);
		// filter negative values
		float diff2 = (float)Math.max(diff - dAvg, 0);
		pushVar(diff2);
		// report false if it's been less than 'sensitivity'
		// milliseconds since the last true value
		if (System.currentTimeMillis() - timer < sensitivity)
		{
			isOnset = false;
		}
		// if we've made it this far then we're allowed to set a new
		// value, so set it true if it deserves to be, restart the timer
		else if (diff2 > 0 && instant > 2)
		{
			isOnset = true;
			timer = System.currentTimeMillis();
		}
		// OMG it wasn't true!
		else
		{
			isOnset = false;
		}
		eBuffer[insertAt] = instant;
		dBuffer[insertAt] = diff;
		insertAt++;
		if (insertAt == eBuffer.length)
			insertAt = 0;
	}

	private void fEnergy(float[] in)
	{
		spect.forward(in);
		float instant, E, V, C, diff, dAvg, diff2;
		for (int i = 0; i < feBuffer.length; i++)
		{
			instant = spect.getAvg(i);
			E = average(feBuffer[i]);
			V = variance(feBuffer[i], E);
			C = (-0.0025714f * V) + 1.5142857f;
			diff = (float)Math.max(instant - C * E, 0);
			dAvg = specAverage(fdBuffer[i]);
			diff2 = (float)Math.max(diff - dAvg, 0);
			if (System.currentTimeMillis() - fTimer[i] < sensitivity)
			{
				fIsOnset[i] = false;
			}
			else if (diff2 > 0)
			{
				fIsOnset[i] = true;
				fTimer[i] = System.currentTimeMillis();
			}
			else
			{
				fIsOnset[i] = false;
			}
			feBuffer[i][insertAt] = instant;
			fdBuffer[i][insertAt] = diff;
		}
		insertAt++;
		if (insertAt == feBuffer[0].length)
		{
			insertAt = 0;
		}
	}

	private void pushVal(float v)
	{
		// println(valCnt);
		if (valCnt == valGraph.length)
		{
			valCnt = 0;
			valGraph = new float[valGraph.length];
		}
		valGraph[valCnt] = v;
		valCnt++;
	}

	private void pushVar(float v)
	{
		// println(valCnt);
		if (varCnt == varGraph.length)
		{
			varCnt = 0;
			varGraph = new float[varGraph.length];
		}
		varGraph[varCnt] = v;
		varCnt++;
	}

	private float average(float[] arr)
	{
		float avg = 0;
		for (int i = 0; i < arr.length; i++)
		{
			avg += arr[i];
		}
		avg /= arr.length;
		return avg;
	}

	private float specAverage(float[] arr)
	{
		float avg = 0;
		float num = 0;
		for (int i = 0; i < arr.length; i++)
		{
			if (arr[i] > 0)
			{
				avg += arr[i];
				num++;
			}
		}
		if (num > 0)
		{
			avg /= num;
		}
		return avg;
	}

	private float variance(float[] arr, float val)
	{
		float V = 0;
		for (int i = 0; i < arr.length; i++)
		{
			V += (float)Math.pow(arr[i] - val, 2);
		}
		V /= arr.length;
		return V;
	}
}
