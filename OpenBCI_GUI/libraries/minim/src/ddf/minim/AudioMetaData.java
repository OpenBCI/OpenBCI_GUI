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

package ddf.minim;

/**
 * <code>AudioMetaData</code> provides information commonly found in ID3 tags. 
 * However, other audio formats, such as Ogg, can contain
 * similar information. So rather than refer to this information
 * as ID3Tags or similar, we simply call it metadata. This base 
 * class returns the empty string or -1 from all methods and
 * derived classes are expected to simply override the methods
 * that they have information for. This is a little less brittle
 * than using an interface because later on new properties can 
 * be added without breaking existing code.
 * 
 * @example Basics/GetMetaData
 */
public abstract class AudioMetaData
{	
	/**
	 * The length of the recording in milliseconds.
	 * 
	 * @return int: the length in milliseconds
	 * 
	 * @related AudioMetaData
	 */
	public int length()
	{
		return -1;
	}
	
	/**
	 * 
	 * How many sample frames are in this recording.
	 * 
	 * @return int: the number of sample frames
	 * 
	 * @related AudioMetaData
	 */
	public int sampleFrameCount()
	{
		return -1;
	}
	
	/**
	 * The name of the file / URL of the recording.
	 * 
	 * @return String: the file name
	 * 
	 * @related AudioMetaData
	 */
	public String fileName()
	{
		return ""; 
	}
	
	/**
	 * The title of the recording.
	 * 
	 * @return String: the title tag
	 * 
	 * @related AudioMetaData
	 */
	public String title()
	{
		return "";
	}
	
	/**
	 * The author of the recording.
	 * 
	 * @return String: the author tag
	 * 
	 * @related AudioMetaData
	 */
	public String author()
	{
		return "";
	}
	
	/**
	 * The album the recording came from.
	 * 
	 * @return String: the album tab
	 * 
	 * @related AudioMetaData
	 */
	public String album()
	{
		return "";
	}
	
	/**
	 * The date the recording was made.
	 * 
	 * @return String: the date tag
	 * 
	 * @related AudioMetaData
	 */
	public String date()
	{
		return "";
	}
	
	/**
	 * The comment field in the file.
	 * 
	 * @return String: the comment tag
	 * 
	 * @related AudioMetaData
	 */
	public String comment()
	{
		return "";
	}
	
	/**
	 * The track number of the recording.
	 * This will sometimes be in the form 3/10,
	 * giving you both the track number and total
	 * tracks on the album this track came from.
	 * 
	 * @return String: the track tag
	 * 
	 * @related AudioMetaData
	 */
	public String track()
	{
		return "";
	}
	
	/**
	 * The genre of the recording.
	 * 
	 * @return String: the genre tag
	 * 
	 * @related AudioMetaData
	 */
	public String genre()
	{
		return "";
	}
	
	/**
	 * The copyright of the recording.
	 * 
	 * @return String: the copyright tag
	 * 
	 * @related AudioMetaData
	 */
	public String copyright()
	{
		return "";
	}
	
	/**
	 * The disc number of the recording.
	 * 
	 * @return String: the disc tag
	 * 
	 * @related AudioMetaData
	 */
	public String disc()
	{
		return "";
	}
	
	/**
	 * The composer of the recording.
	 * 
	 * @return String: the composer tag
	 * 
	 * @related AudioMetaData
	 */
	public String composer()
	{
		return "";
	}
	
	/**
	 * The lyrics for the recording, if any.
	 * 
	 * @return String: the lyrics tag
	 * 
	 * @related AudioMetaData
	 */
	public String lyrics()
	{
		return "";
	}
    
	/**
	 * The orchestra that performed the recording.
	 * 
	 * @return String: the orchestra tag
	 * 
	 * @related AudioMetaData
	 */
	public String orchestra()
	{
		return "";
	}
	
	/** 
	 * The publisher of the recording.
	 * 
	 * @return String: the publisher tag
	 * 
	 * @related AudioMetaData
	 */
	public String publisher()
	{
		return "";
	}
	
	/**
	 * The software the recording was encoded with.
	 * 
	 * @return String: the encoded tag
	 * 
	 * @related AudioMetaData
	 */
	public String encoded()
	{
		return "";
	}
}
