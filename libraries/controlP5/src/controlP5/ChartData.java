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

/**
 * Used by Chart, single chart data is stored here including value, (label) text, and color.
 */
public class ChartData {

	protected float _myValue;

	protected String _myText;

	protected int _myColor;

	public ChartData( float theValue ) {
		this( theValue , "" );
	}

	public ChartData( float theValue , String theText ) {
		_myValue = theValue;
		_myText = theText;
	}

	public void setValue( float theValue ) {
		_myValue = theValue;
	}

	public void setText( String theText ) {
		_myText = theText;
	}

	public float getValue( ) {
		return _myValue;
	}

	public String getText( ) {
		return _myText;
	}

	public void setColor( int theColor ) {
		_myColor = theColor;
	}

	public int getColor( ) {
		return _myColor;
	}

}
