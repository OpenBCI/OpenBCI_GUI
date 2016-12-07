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

import java.util.ArrayList;
import java.util.ListIterator;

import processing.core.PApplet;
import processing.core.PGraphics;

/**
 * Used by Chart, a chart data set is a container to store chart data.
 */
@SuppressWarnings( "serial" )
public class ChartDataSet extends ArrayList< ChartData > {

	protected CColor _myColor;
	protected float _myStrokeWeight = 1;
	protected int[] colors = new int[ 0 ];
	protected final String _myName;

	public ChartDataSet( String theName ) {
		_myName = theName;
		_myColor = new CColor( );
	}

	public CColor getColor( ) {
		return _myColor;
	}

	public ChartDataSet setColors( int ... theColors ) {
		colors = theColors;
		return this;
	}

	public int[] getColors( ) {
		return colors;
	}

	public int getColor( int theIndex ) {
		if ( colors.length == 0 ) {
			return getColor( ).getForeground( );
		}
		if ( colors.length == 2 ) {
			return PGraphics.lerpColor( colors[ 0 ] , colors[ 1 ] , theIndex / ( float ) size( ) , PApplet.RGB );
		}
		if ( theIndex >= 0 && theIndex < colors.length ) {
			return colors[ theIndex ];
		}
		return getColor( 0 );
	}

	public ChartDataSet setStrokeWeight( float theStrokeWeight ) {
		_myStrokeWeight = theStrokeWeight;
		return this;
	}

	public float getStrokeWeight( ) {
		return _myStrokeWeight;
	}

	public float[] getValues( ) {
		float[] v = new float[ size( ) ];
		int n = 0;
		ListIterator< ChartData > litr = listIterator( );
		while ( litr.hasNext( ) ) {
			v[ n++ ] = litr.next( ).getValue( );
		}
		return v;
	}

}
