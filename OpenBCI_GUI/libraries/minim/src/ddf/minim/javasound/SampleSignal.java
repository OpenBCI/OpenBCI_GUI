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

package ddf.minim.javasound;

import ddf.minim.AudioSample;
import ddf.minim.AudioSignal;
import ddf.minim.Minim;

class SampleSignal implements AudioSignal
{
	private FloatSampleBuffer	buffer;
	private int[]				marks;
	private int					markAt;

	public SampleSignal(FloatSampleBuffer samps)
	{
		buffer = samps;
		marks = new int[20];
		for ( int i = 0; i < marks.length; i++ )
		{
			marks[i] = -1;
		}
		markAt = 0;
	}

	public void generate(float[] signal)
	{
		// build our signal from all the marks
		for ( int i = 0; i < marks.length; i++ )
		{
			int begin = marks[i];
			if ( begin == -1 )
			{
				continue;
			}

			// JSMinim.debug("Sample trigger in process at marks[" + i + "] = "
			// + marks[i]);
			int j, k;
			for ( j = begin, k = 0; j < buffer.getSampleCount()
					&& k < signal.length; j++, k++ )
			{
				signal[k] += buffer.getChannel( 0 )[j];
			}
			if ( j < buffer.getSampleCount() )
			{
				marks[i] = j;
			}
			else
			{
				// Minim.debug("Sample trigger ended.");
				marks[i] = -1;
			}
		}

	}

	public void generate(float[] left, float[] right)
	{
		// build our signal from all the marks
		for ( int i = 0; i < marks.length; i++ )
		{
			int begin = marks[i];
			if ( begin == -1 )
			{
				continue;
			}

			// Minim.debug("Sample trigger in process at marks[" + i + "] = " +
			// marks[i]);
			int j, k;
			for ( j = begin, k = 0; j < buffer.getSampleCount()
					&& k < left.length; j++, k++ )
			{
				left[k] += buffer.getChannel( 0 )[j];
				right[k] += buffer.getChannel( 1 )[j];
			}
			if ( j < buffer.getSampleCount() )
			{
				marks[i] = j;
			}
			else
			{
				// Minim.debug("Sample trigger ended.");
				marks[i] = -1;
			}
		}

	}

	public void trigger()
	{
		marks[markAt] = 0;
		markAt++;
		if ( markAt == marks.length )
		{
			markAt = 0;
		}

	}

	public void stop()
	{
		for ( int i = 0; i < marks.length; ++i )
		{
			marks[i] = -1;
		}
	}

	public float[] getChannel(int channelNumber)
	{
		if ( channelNumber == AudioSample.LEFT )
		{
			return buffer.getChannel( 0 );
		}
		else if ( channelNumber == AudioSample.RIGHT )
		{
			return buffer.getChannel( 1 );
		}
		Minim.error( "getChannel: Illegal channel number " + channelNumber );
		return null;
	}
}
