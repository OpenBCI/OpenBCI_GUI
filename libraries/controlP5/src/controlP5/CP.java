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

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Array;
import java.net.URLEncoder;
import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.List;

public class CP {

	/**
	 * borrowed from http://www.javapractices.com/Topic96.cjp
	 * 
	 * 
	 * @param aURLFragment String
	 * @return String
	 */
	static public String forURL( String aURLFragment ) {
		String result = null;
		try {
			result = URLEncoder.encode( aURLFragment , "UTF-8" );
		} catch ( UnsupportedEncodingException ex ) {
			throw new RuntimeException( "UTF-8 not supported" , ex );
		}
		return result;
	}

	/**
	 * borrowed from http://www.javapractices.com/Topic96.cjp
	 * 
	 * @param aTagFragment String
	 * @return String
	 */
	static public String forHTMLTag( String aTagFragment ) {
		final StringBuffer result = new StringBuffer( );

		final StringCharacterIterator iterator = new StringCharacterIterator( aTagFragment );
		char character = iterator.current( );
		while ( character != CharacterIterator.DONE ) {
			if ( character == '<' ) {
				result.append( "&lt;" );
			} else if ( character == '>' ) {
				result.append( "&gt;" );
			} else if ( character == '\"' ) {
				result.append( "&quot;" );
			} else if ( character == '\'' ) {
				result.append( "&#039;" );
			} else if ( character == '\\' ) {
				result.append( "&#092;" );
			} else if ( character == '&' ) {
				result.append( "&amp;" );
			} else {
				// the char is not a special one
				// add it to the result as is
				result.append( character );
			}
			character = iterator.next( );
		}
		return result.toString( );
	}

	/**
	 * http://processing.org/discourse/yabb_beta/YaBB.cgi?board=Programs;action=
	 * display;num=1159828167;start=0#0
	 * 
	 * @param string String
	 * @return String
	 */
	String URLEncode( String string ) {
		String output = new String( );
		try {
			byte[] input = string.getBytes( "UTF-8" );
			for ( int i = 0 ; i < input.length ; i++ ) {
				if ( input[ i ] < 0 ) {
					// output += ('%' + hex(input[i])); // see hex method in
					// processing
				} else if ( input[ i ] == 32 ) {
					output += '+';
				} else {
					output += ( char ) ( input[ i ] );
				}
			}
		} catch ( UnsupportedEncodingException e ) {
			e.printStackTrace( );
		}

		return output;
	}

	static public String replace( String theSourceString , String theSearchForString , String theReplaceString ) {
		if ( theSourceString.length( ) < 1 ) {
			return "";
		}
		int p = 0;

		while ( p < theSourceString.length( ) && ( p = theSourceString.indexOf( theSearchForString , p ) ) >= 0 ) {
			theSourceString = theSourceString.substring( 0 , p ) + theReplaceString + theSourceString.substring( p + theSearchForString.length( ) , theSourceString.length( ) );
			p += theReplaceString.length( );
		}
		return theSourceString;
	}

	/**
	 * convert a hex number into an int
	 * 
	 * @param theHex
	 * @return
	 */
	static public int parseHex( String theHex ) {
		int myLen = theHex.length( );
		int a , r , b , g;
		switch ( myLen ) {
		case ( 8 ):
			break;
		case ( 6 ):
			theHex = "ff" + theHex;
			break;
		default:
			theHex = "ff000000";
			break;
		}
		a = ( new Integer( Integer.parseInt( theHex.substring( 0 , 2 ) , 16 ) ) ).intValue( );
		r = ( new Integer( Integer.parseInt( theHex.substring( 2 , 4 ) , 16 ) ) ).intValue( );
		g = ( new Integer( Integer.parseInt( theHex.substring( 4 , 6 ) , 16 ) ) ).intValue( );
		b = ( new Integer( Integer.parseInt( theHex.substring( 6 , 8 ) , 16 ) ) ).intValue( );
		return ( a << 24 | r << 16 | g << 8 | b );
	}

	static public String intToString( int theInt ) {
		int a = ( ( theInt >> 24 ) & 0xff );
		int r = ( ( theInt >> 16 ) & 0xff );
		int g = ( ( theInt >> 8 ) & 0xff );
		int b = ( ( theInt >> 0 ) & 0xff );
		String sa = ( ( Integer.toHexString( a ) ).length( ) == 1 ) ? "0" + Integer.toHexString( a ) : Integer.toHexString( a );
		String sr = ( ( Integer.toHexString( r ) ).length( ) == 1 ) ? "0" + Integer.toHexString( r ) : Integer.toHexString( r );
		String sg = ( ( Integer.toHexString( g ) ).length( ) == 1 ) ? "0" + Integer.toHexString( g ) : Integer.toHexString( g );
		String sb = ( ( Integer.toHexString( b ) ).length( ) == 1 ) ? "0" + Integer.toHexString( b ) : Integer.toHexString( b );
		return sa + sr + sg + sb;
	}

	/**
	 * @deprecated
	 */
	@Deprecated protected boolean save( ControlP5 theControlP5 , String theFilePath ) {
		ControlP5.logger( ).info( "Saving ControlP5 settings in XML format has been removed, have a look at controlP5's properties instead." );
		return false;
	}

	/**
	 * * Convenience method for producing a simple textual representation of an array.
	 * 
	 * <P>
	 * The format of the returned <code>String</code> is the same as
	 * <code>AbstractCollection.toString</code>:
	 * <ul>
	 * <li>non-empty array: [blah, blah]
	 * <li>empty array: []
	 * <li>null array: null
	 * </ul>
	 * 
	 * 
	 * <code>aArray</code> is a possibly-null array whose elements are primitives or objects; arrays
	 * of arrays are also valid, in which case <code>aArray</code> is rendered in a nested,
	 * recursive fashion.
	 * 
	 * @author Jerome Lacoste
	 * @author www.javapractices.com
	 */
	static public String arrayToString( Object aArray ) {
		if ( aArray == null ) {
			return fNULL;
		}

		checkObjectIsArray( aArray );

		StringBuilder result = new StringBuilder( fSTART_CHAR );
		int length = Array.getLength( aArray );
		for ( int idx = 0 ; idx < length ; ++idx ) {
			Object item = Array.get( aArray , idx );
			if ( isNonNullArray( item ) ) {
				// recursive call!
				result.append( arrayToString( item ) );
			} else {
				result.append( item );
			}
			if ( !isLastItem( idx , length ) ) {
				result.append( fSEPARATOR );
			}
		}
		result.append( fEND_CHAR );
		return result.toString( );
	}

	// PRIVATE //
	private static final String fSTART_CHAR = "[";

	private static final String fEND_CHAR = "]";

	private static final String fSEPARATOR = ", ";

	private static final String fNULL = "null";

	private static void checkObjectIsArray( Object aArray ) {
		if ( !aArray.getClass( ).isArray( ) ) {
			throw new IllegalArgumentException( "Object is not an array." );
		}
	}

	private static boolean isNonNullArray( Object aItem ) {
		return aItem != null && aItem.getClass( ).isArray( );
	}

	private static boolean isLastItem( int aIdx , int aLength ) {
		return ( aIdx == aLength - 1 );
	}

	protected static String formatGetClass( Class< ? > c ) {
		if ( c == null )
			return null;
		final String pattern = "class ";
		return c.toString( ).startsWith( pattern ) ? c.toString( ).substring( pattern.length( ) ) : c.toString( );
	}

	
	static public boolean inside( int[] theRect , float theX , float theY ) {
		if ( theRect.length == 4 ) {
			return ( theX > theRect[ 0 ] && theX < theRect[ 2 ] && theY > theRect[ 1 ] && theY < theRect[ 3 ] );
		} else {
			return false;
		}
	}

	/* Base64 static methods to encode and decode
	 * bytes into a String and back
	 * 
	 * from
	 * http://examples.oreilly.com/javacrypt/files/oreilly/jonathan/util/
	 * http://oreilly.com/catalog/javacrypt/chapter/ch06.html */

	static public String encodeBase64( byte[] raw ) {
		StringBuffer encoded = new StringBuffer( );
		for ( int i = 0 ; i < raw.length ; i += 3 ) {
			encoded.append( encodeBlock( raw , i ) );
		}
		return encoded.toString( );
	}

	protected static char[] encodeBlock( byte[] raw , int offset ) {
		int block = 0;
		int slack = raw.length - offset - 1;
		int end = ( slack >= 2 ) ? 2 : slack;
		for ( int i = 0 ; i <= end ; i++ ) {
			byte b = raw[ offset + i ];
			int neuter = ( b < 0 ) ? b + 256 : b;
			block += neuter << ( 8 * ( 2 - i ) );
		}
		char[] base64 = new char[ 4 ];
		for ( int i = 0 ; i < 4 ; i++ ) {
			int sixbit = ( block >>> ( 6 * ( 3 - i ) ) ) & 0x3f;
			base64[ i ] = getBase64Char( sixbit );
		}
		if ( slack < 1 )
			base64[ 2 ] = '=';
		if ( slack < 2 )
			base64[ 3 ] = '=';
		return base64;
	}

	static char getBase64Char( int sixBit ) {
		if ( sixBit >= 0 && sixBit <= 25 )
			return ( char ) ( 'A' + sixBit );
		if ( sixBit >= 26 && sixBit <= 51 )
			return ( char ) ( 'a' + ( sixBit - 26 ) );
		if ( sixBit >= 52 && sixBit <= 61 )
			return ( char ) ( '0' + ( sixBit - 52 ) );
		if ( sixBit == 62 )
			return '+';
		if ( sixBit == 63 )
			return '/';
		return '?';
	}

	static public byte[] decodeBase64( String base64 ) {
		int pad = 0;
		for ( int i = base64.length( ) - 1 ; base64.charAt( i ) == '=' ; i-- )
			pad++;
		int length = base64.length( ) * 6 / 8 - pad;
		byte[] raw = new byte[ length ];
		int rawIndex = 0;
		for ( int i = 0 ; i < base64.length( ) ; i += 4 ) {
			int block = ( getBase64Value( base64.charAt( i ) ) << 18 ) + ( getBase64Value( base64.charAt( i + 1 ) ) << 12 ) + ( getBase64Value( base64.charAt( i + 2 ) ) << 6 ) + ( getBase64Value( base64.charAt( i + 3 ) ) );
			for ( int j = 0 ; j < 3 && rawIndex + j < raw.length ; j++ )
				raw[ rawIndex + j ] = ( byte ) ( ( block >> ( 8 * ( 2 - j ) ) ) & 0xff );
			rawIndex += 3;
		}
		return raw;
	}

	static int getBase64Value( char c ) {
		if ( c >= 'A' && c <= 'Z' )
			return c - 'A';
		if ( c >= 'a' && c <= 'z' )
			return c - 'a' + 26;
		if ( c >= '0' && c <= '9' )
			return c - '0' + 52;
		if ( c == '+' )
			return 62;
		if ( c == '/' )
			return 63;
		if ( c == '=' )
			return 0;
		return -1;
	}

	static public int getBit( int theByte , int theIndex ) {
		int bitmask = 1 << theIndex;
		return ( ( theByte & bitmask ) > 0 ) ? 1 : 0;
	}

	static public byte setHigh( byte theByte , int theIndex ) {
		return ( byte ) ( theByte | ( 1 << theIndex ) );
	}

	static public byte setLow( byte theByte , int theIndex ) {
		return ( byte ) ( theByte & ~ ( 1 << theIndex ) );
	}

	static public byte[] intToByteArray( int a ) {
		byte[] ret = new byte[ 2 ];
		ret[ 1 ] = ( byte ) ( a & 0xFF );
		ret[ 0 ] = ( byte ) ( ( a >> 8 ) & 0xFF );
		//ret[0] = (byte) ((a >> 16) & 0xFF);   
		//ret[0] = (byte) ((a >> 24) & 0xFF);
		return ret;
	}

	static public int byteArrayToInt( byte[] b ) {
		int value = 0;
		for ( int i = 0 ; i < 2 ; i++ ) {
			int shift = ( 2 - 1 - i ) * 8;
			value += ( b[ i ] & 0x00FF ) << shift;
		}
		return value;
	}

	static String join( List< String > list , String delimiter ) {
		StringBuilder b = new StringBuilder( );
		for ( String item : list ) {
			b.append( item ).append( delimiter );
		}
		return b.toString( );
	}

}
