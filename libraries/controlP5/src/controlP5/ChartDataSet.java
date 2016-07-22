package controlP5;

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
