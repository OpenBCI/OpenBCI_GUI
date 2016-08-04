package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 04/14/2016
 * @version 2.2.6
 * 
 */

import java.lang.reflect.Constructor;
import java.util.Arrays;

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PImage;

public class BitFont extends PFont {

	static public final String standard58base64 = "AakACQBgACAEAgQGBggGAgMDBAYDBAIGBQMFBQUFBQUFBQICBAUEBQgFBQUFBQUFBQIFBQQGBQUFBQUFBAUGCAUGBQMFAwYGAwQEBAQEBAQEAgQEAgYEBAQEAwQEBAQGBAQEBAIEBQKgUgghIaUAAIiRMeiZZwwAAANgjjnvmRRKESVzzDGXoqQUvYURQCCAQCCSCAAAAAgAAABEqECleCVFkRAAiLSUWEgoJQAAiSOllEJIKVRiSymllCRFSSlCEVIAQQBBQAARAAAAEAAAACQpgeALJASiIwAQSQipE1BKRS+QSEohhRBSqES1UkopSIqSkkIiFAGwEZOwSaplZGx2VVXVSQIAgeIgSETy4RCSCEnoEONAgJCkd0I6p73QiKilk46RpCQZQoQIAFBVVVOVVFVVVUKqqiqKCACCDyKpiIoAICQJ9FAiCUE8ElUphRRCSqESUUohJSRJSUpECBEAoCrqoiqZqqqqiFRVUiIJAADKI5UQASEgSAoJpSRSCgECUlJKKYSUSiWilEJKSRKRlIgQJABAVVVEVVJVVVUhqaqqQhIACBQixEIBQFBg9AwyRhhDBEIIpGPOCyZl0kXJBJOMGMImEW9owAcbMQmrpKpKxjJiopQdFQAAAAAAAABAAAAAAAAAAIAAAOAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAQIAAAEAQAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgAAAgCAAAAAgAA";
	static public final String standard56base64 = "AeYACQBgACAEAgQGBggHAgMDBgYDBQIFBgMGBgYGBgYGBgIDBAYEBggGBgYGBgYGBgIGBgUIBgYGBgYGBgYGCAYGBgMFAwYHAwUFBQUFAwUFAgMFAggFBQUFBAQEBQUIBQUFBAMEBQKgUgghRwoBAIAcOQ7yOZ/jAADAAXAe5/k+JwqKQlDkPM7jfFGUFEXfwghAQAAICIQUAgAAAAABAAAAQAkVqBSvJFJUEQCQaFHEBBEURQAAiDiiKIqCIIqCkjAWRVEURUQUJUURFCEFIBAAAgEBhAAAAABAAAAAAEikBIIvkFAQOQQAJBIEKU8ARVGiLyCRKAqiIAiioCJUTVEURQERRUmKgkQoAsAd40zcSambY447u5SSUnoSAYBAcRBMRNWHh4iEMAn0II4HBBAk6XuC6HmyL2gISVX0RI9DREoSQRAhAgBIKaW0lFIpKaWUIiSlpJRQhAAg+CCSFBFBACAiEdAHRUgEgfiIqIqiIAqCKAoqQlAWBVEBEZGSpBBCiAAAUgrpJaU0SkoppRBJKckkIxEAAJRHKkIEEACESEKERBERRUEAAVKiKIqCIIqKkhAURUGUREREJEVEECQAgJRSCkkplZJSSilIUkpKKUgEAAKFCHGhAIBAwdHnII5DOA4iIAiB6HGeL3CinOgFRU7gRA7hEDYR8QUJ+MEd40xcSqmkZI6LEWdsknsSAQAAAAAAAAAgAAAAAAAAAACAAACAAwAAAAAAAAAAAAAAQAAAAAAAAAADAwAAAAAABBAAAICAAAAAAIAAJQAAAAAAAAAABAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAACAAAgIAAAAAAYAAA=";
	static public final String grixelbase64 = "AnoADABgACAFAgQICAoIAgQEBgYDBQIKCQMICAgICAcICAIDBQYFBwkICAgIBwcICAYHCAcJCAgICAgICAgICggICAQKBAQHBAcHBwcHBQcHAgUHBAoHBwcHBgcGBwcKBwcHBQIFCAJAJeIjkENBAAAAQHzk4wPz5/Pz8QEAAB4ePj8+Pz6fX9AHCgoECvL58fnx+QsKiigo6C8CIAEIIAAAARwgEAoEAAAAAAAABAAAAAAAICIAAZVIUiERBQEAAIAIWlAQSkAQKCgIICCEhAQFBQUFAgFBBCgoMGwoKCgoKAghKCiioCCgEIAKQIAAAAQIgAAgEAAAAAAAABAAAAAAAICIsAUEfwlCRBCkEAAAIUhAQCQBAaCgIEAAAcoUFBQQFAgEBBGgoECpoqCgoKAAhKCgiEREQIIAAgAAAgAQIAACgEAAAAAAAABAAAAAAAAAIrIBEIgkgBBBEEEAAIIgAQGJ/ARAgoKS+AioVFBQQFAgEBBEgEICmZKCgoKCAhCCgiKioIAIBAgA4Pl4fJ7n+YRC8c7H8/F5ni8UiigU+okIAEAg4gOBA0HfhwcEguTDEwL0g/DxAwFAoFJ/PwFBv1/eHwH6CASKCgoKCvJBCAqKCAEBISAgAAAoFAqFQigUikREoVAoFISEUCgiSQgSQgAAgQgSAlEEEQQACAhSANAfUBAhCAiIj2BKBQUFBAUCQUEEKCQQKCzoJ+gHCCEoKCIKBIIAgQAAvlAg9AuhUOgREYVCoVBgEEKhiBghhIgAAAB/SITEEKQQABAgSAFAIEBBhCAgQABByBMUFBAUCAQFEaGgQKCgoICgECCEIJGIRBAEAggCAIRCgVAghEKhSEQUCoVCAUYIhSJihAgiAgAAiCQJFUMQAAgggCAFBIEEBRGCghACAkBAUFBQUCAQFESEggKBgoICkoKCEIIoIgpCCAhACAAQCoVCoRAKhUIRUSgUCgUhISSJSBISiAgAQCDiE4gTQQAgUAB89OcD4uND8PFJAAAEfkE/Pj++gF/Q5wn6BQryCfAJ8kHwQXAnCOEvACIAgM/j8XiCLxQKWUQhz8cXeDgPw52Q7yciAAAAAAIAANgAQAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAgAPg4AcAAAAAACAACAAAAAABEAAAAAAAACAAawAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB4ABgAAAAABEAAAAAAAAB4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
	protected int characters;
	protected int[] charWidth = new int[ 255 ];
	protected int charHeight;
	protected int[][] chars;
	protected int lineHeight = 10;
	protected int kerning = 0;
	protected int wh;
	protected PImage texture;
	public static int defaultChar = 32;

	public BitFont( byte[] theBytes ) {
		super( );

		texture = decodeBitFont( theBytes );
		make( );

		size = lineHeight;
		glyphs = new Glyph[ 256 ];
		ascii = new int[ 128 ];
		Arrays.fill( ascii , -1 );
		lazy = false;
		ascent = 4;
		descent = 4;
		glyphCount = 128;
		for ( int i = 0 ; i < 128 ; i++ ) {

			// unfortunately the PFont.Glyph constructor in
			// the android source code is for whatever
			// reason protected and not public like in the
			// java application source, therefore the
			// bitfont will only be used in the java
			// application mode until changes to the
			// processing core code have been made. see
			// issue
			// http://code.google.com/p/processing/issues/detail?id=1293

			try {
				Constructor< PFont.Glyph >[] constructors = ( Constructor< PFont.Glyph >[] ) PFont.Glyph.class.getDeclaredConstructors( );
				Constructor< PFont.Glyph > constructor = ( Constructor< PFont.Glyph > ) PFont.Glyph.class.getDeclaredConstructors( )[ 0 ];
				constructor.setAccessible( true );
				for ( Constructor< PFont.Glyph > c : constructors ) {
					c.setAccessible( true );
					if ( c.getParameterTypes( ).length == 1 ) {
						glyphs[ i ] = c.newInstance( this );
						break;
					}
				}
			} catch ( Exception e ) {
				System.out.println( e );
			}

			// as soon as the constructor is public, the
			// line below will replace the hack above
			// glyphs[i] = new Glyph();

			glyphs[ i ].value = i;

			if ( glyphs[ i ].value < 128 ) {
				ascii[ glyphs[ i ].value ] = i;
			}

			glyphs[ i ].index = i;
			int id = i - 32;
			if ( id >= 0 ) {
				glyphs[ i ].image = new PImage( charWidth[ id ] , 9 , ALPHA );
				for ( int n = 0 ; n < chars[ id ].length ; n++ ) {
					glyphs[ i ].image.pixels[ n ] = ( chars[ id ][ n ] == 1 ) ? 0xffffffff : 0x00000000;
				}
				glyphs[ i ].height = 9;
				glyphs[ i ].width = charWidth[ id ];
				glyphs[ i ].index = i;
				glyphs[ i ].value = i;
				glyphs[ i ].setWidth = charWidth[ id ];
				glyphs[ i ].topExtent = 4;
				glyphs[ i ].leftExtent = 0;
			} else {
				glyphs[ i ].image = new PImage( 1 , 1 );
			}
		}
	}

	public Glyph getGlyph( char c ) {
		int n = ( int ) c;
		/* if c is out of the BitFont-glyph bounds, return
		 * the defaultChar glyph (the space char by
		 * default). */
		n = ( n >= 128 ) ? defaultChar : n;
		return glyphs[ n ];
	}

	PImage decodeBitFont( byte[] bytes ) {

		PImage tex;

		// read width
		int w = CP.byteArrayToInt( new byte[] { bytes[ 0 ] , bytes[ 1 ] } );

		// read height
		int h = CP.byteArrayToInt( new byte[] { bytes[ 2 ] , bytes[ 3 ] } );

		// read size of chars
		int s = CP.byteArrayToInt( new byte[] { bytes[ 4 ] , bytes[ 5 ] } );

		// read first ascii char
		int c = CP.byteArrayToInt( new byte[] { bytes[ 6 ] , bytes[ 7 ] } );

		tex = new PImage( w , h , PApplet.ALPHA );

		// read bytes and write pixels into image
		int off = 8 + s;
		for ( int i = off ; i < bytes.length ; i++ ) {
			for ( int j = 0 ; j < 8 ; j++ ) {
				tex.pixels[ ( i - off ) * 8 + j ] = CP.getBit( bytes[ i ] , j ) == 1 ? 0xff000000 : 0xffffffff;
			}
		}

		int cnt = 0 , n = 0 , i = 0;

		// add character seperators on top of the texture
		for ( i = 0 ; i < s ; i++ ) {
			while ( ++cnt != bytes[ i + 8 ] ) {
			}
			n += cnt;
			tex.pixels[ n ] = 0xffff0000;
			cnt = 0;
		}

		return tex;
	}

	int getHeight( ) {
		return texture.height;
	}

	BitFont make( ) {

		charHeight = texture.height;

		lineHeight = charHeight;

		int currWidth = 0;

		for ( int i = 0 ; i < texture.width ; i++ ) {
			currWidth++;
			if ( texture.pixels[ i ] == 0xffff0000 ) {
				charWidth[ characters++ ] = currWidth;
				currWidth = 0;
			}
		}

		chars = new int[ characters ][];

		int indent = 0;

		for ( int i = 0 ; i < characters ; i++ ) {
			chars[ i ] = new int[ charWidth[ i ] * charHeight ];
			for ( int u = 0 ; u < charWidth[ i ] * charHeight ; u++ ) {
				chars[ i ][ u ] = texture.pixels[ indent + ( u / charWidth[ i ] ) * texture.width + ( u % charWidth[ i ] ) ] == 0xff000000 ? 1 : 0;
			}
			indent += charWidth[ i ];
		}
		return this;
	}
}
