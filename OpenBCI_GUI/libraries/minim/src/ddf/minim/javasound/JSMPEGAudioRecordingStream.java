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

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.SourceDataLine;

import ddf.minim.AudioMetaData;

class JSMPEGAudioRecordingStream extends JSBaseAudioRecordingStream
{
	JSMPEGAudioRecordingStream(JSMinim sys, AudioMetaData metaData,
			AudioInputStream encStream, AudioInputStream decStream,
			SourceDataLine sdl, int bufferSize)
	{
		super( sys, metaData, decStream, sdl, bufferSize, metaData.length() );
	}

	synchronized protected void rewind()
	{
		super.rewind();
		ais = system.getAudioInputStream( format, ais );
	}
}
