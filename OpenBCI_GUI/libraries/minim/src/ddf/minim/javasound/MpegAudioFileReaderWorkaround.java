/*
 * MpegAudioFileReaderWorkaround.
 *
 *-----------------------------------------------------------------------
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
 *----------------------------------------------------------------------
 */


package ddf.minim.javasound;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.UnsupportedAudioFileException;

import javazoom.spi.mpeg.sampled.file.IcyListener;
import javazoom.spi.mpeg.sampled.file.tag.IcyInputStream;

/** This class comes from the package javazoom.jlgui.basicplayer, 
 *  but I don't want to lug along jlgui just to be able to play mp3 
 *  files in the web browser. So I include it here, with slight modifications
 *  for error/debug reporting.
 * 
 */
final class MpegAudioFileReaderWorkaround extends MpegAudioFileReader
{
	MpegAudioFileReaderWorkaround(JSMinim sys)
  {
    super(sys);
  }

  /**
	 * Returns AudioInputStream from url and userAgent
	 */
	public AudioInputStream getAudioInputStream(URL url, String userAgent) 
         throws UnsupportedAudioFileException, IOException
	{
		system.debug("MpegAudioFileReaderWorkaround.getAudioInputStream(" + 
                url.toString() + ", " + userAgent + "): begin");
		long lFileLengthInBytes = AudioSystem.NOT_SPECIFIED;
		URLConnection conn = url.openConnection();
		// Tell shoucast server (if any) that SPI support shoutcast stream.
		boolean isShout = false;
		int toRead = 4;
		byte[] head = new byte[toRead];
		if (userAgent != null) conn.setRequestProperty("User-Agent", userAgent);
		conn.setRequestProperty("Accept", "*/*");
		conn.setRequestProperty("Icy-Metadata", "1");
		conn.setRequestProperty("Connection", "close");
		system.debug("Base input stream is: " + conn.getInputStream().toString());
		BufferedInputStream bInputStream = new BufferedInputStream(conn.getInputStream());
		bInputStream.mark(toRead);
		int read = bInputStream.read(head, 0, toRead);
		if ((read > 2) && (((head[0] == 'I') | (head[0] == 'i')) && ((head[1] == 'C') | (head[1] == 'c')) && ((head[2] == 'Y') | (head[2] == 'y'))))
		{
			isShout = true;
		}
		bInputStream.reset();
		InputStream inputStream = null;
		// Is it a shoutcast server ?
		if (isShout == true)
		{
			// Yes
			system.debug("URL is a shoutcast server.");
			IcyInputStream icyStream = new IcyInputStream(bInputStream);
			icyStream.addTagParseListener(IcyListener.getInstance());
			inputStream = icyStream;
		}
		else
		{
			// No, is it Icecast 2 ?
			String metaint = conn.getHeaderField("icy-metaint");
			if (metaint != null)
			{
				// Yes, it might be icecast 2 mp3 stream.
				system.debug("URL is probably an icecast 2 mp3 stream");
				IcyInputStream icyStream = new IcyInputStream(bInputStream, metaint);
				icyStream.addTagParseListener(IcyListener.getInstance());
				inputStream = icyStream;
			}
			else
			{
				system.debug("URL is not shoutcast or icecast 2.");
				inputStream = bInputStream;
			}
		}
		AudioInputStream audioInputStream = null;
		try
		{
			system.debug("Attempting to get audioInputStream.");
			audioInputStream = getAudioInputStream(inputStream, lFileLengthInBytes);
		}
		catch (UnsupportedAudioFileException e)
		{
			inputStream.close();
			throw e;
		}
		catch (IOException e)
		{
			inputStream.close();
			throw e;
		}
		system.debug("MpegAudioFileReaderWorkaround.getAudioInputStream(URL,String): end");
		return audioInputStream;
	}
}