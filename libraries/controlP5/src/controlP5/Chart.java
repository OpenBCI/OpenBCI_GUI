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

import java.util.Iterator;
import java.util.LinkedHashMap;

import processing.core.PApplet;
import processing.core.PGraphics;

/**
 * Use charts to display float array data as line chart, yet experimental, but see the
 * ControlP5chart example for more details.
 * 
 * @example controllers/ControlP5chart
 */
public class Chart extends Controller< Chart > {

	public final static int LINE = 0;
	public final static int BAR = 1;
	public final static int BAR_CENTERED = 2;
	public final static int HISTOGRAM = 3;
	public final static int PIE = 4;
	public final static int AREA = 5;

	protected final LinkedHashMap< String , ChartDataSet > _myDataSet;
	protected float resolution = 1;
	protected float strokeWeight = 1;
	protected float _myMin = 0;
	protected float _myMax = 1;

	/**
	 * Convenience constructor to extend Chart.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public Chart( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 200 , 100 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected Chart( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theX , float theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		setRange( 0 , theHeight );
		_myDataSet = new LinkedHashMap< String , ChartDataSet >( );
		getCaptionLabel( ).align( LEFT, BOTTOM_OUTSIDE ).paddingX = 0;
		
	}

	public Chart setRange( float theMin , float theMax ) {
		_myMin = theMin;
		_myMax = theMax;
		return this;
	}

	public Chart setColors( String theSetIndex , int ... theColors ) {
		getDataSet( ).get( theSetIndex ).setColors( theColors );
		return this;
	}

	public Chart addData( ChartData theItem ) {
		return addData( getFirstDataSetIndex( ) , theItem );
	}

	private String getFirstDataSetIndex( ) {
		return getDataSet( ).keySet( ).iterator( ).next( );
	}

	private String getLastDataSetIndex( ) {
		Iterator< String > it = getDataSet( ).keySet( ).iterator( );
		String last = null;
		while ( it.hasNext( ) ) {
			last = it.next( );
		}
		return last;
	}

	public Chart addData( String theSetIndex , ChartData theItem ) {
		getDataSet( theSetIndex ).add( theItem );
		return this;
	}

	public Chart addData( float theValue ) {
		ChartData cdi = new ChartData( theValue );
		getDataSet( getFirstDataSetIndex( ) ).add( cdi );
		return this;
	}

	public Chart addData( String theSetIndex , float theValue ) {
		ChartData cdi = new ChartData( theValue );
		getDataSet( theSetIndex ).add( cdi );
		return this;
	}

	public Chart addData( ChartDataSet theChartData , float theValue ) {
		ChartData cdi = new ChartData( theValue );
		theChartData.add( cdi );
		return this;
	}

	// array operations see syntax
	// http://www.w3schools.com/jsref/jsref_obj_array.asp

	/**
	 * adds a new float at the beginning of the data set.
	 */
	public Chart unshift( float theValue ) {
		return unshift( getFirstDataSetIndex( ) , theValue );
	}

	public Chart unshift( String theSetIndex , float theValue ) {
		if ( getDataSet( theSetIndex ).size( ) > ( getWidth() / resolution ) ) {
			removeLast( theSetIndex );
		}
		return addFirst( theSetIndex , theValue );
	}

	public Chart push( float theValue ) {
		return push( getFirstDataSetIndex( ) , theValue );
	}

	public Chart push( String theSetIndex , float theValue ) {
		if ( getDataSet( theSetIndex ).size( ) > ( getWidth() / resolution ) ) {
			removeFirst( theSetIndex );
		}
		return addLast( theSetIndex , theValue );
	}

	public Chart addFirst( float theValue ) {
		return addFirst( getFirstDataSetIndex( ) , theValue );
	}

	public Chart addFirst( String theSetIndex , float theValue ) {
		ChartData cdi = new ChartData( theValue );
		getDataSet( theSetIndex ).add( 0 , cdi );
		return this;
	}

	public Chart addLast( float theValue ) {
		return addLast( getFirstDataSetIndex( ) , theValue );
	}

	public Chart addLast( String theSetIndex , float theValue ) {
		ChartData cdi = new ChartData( theValue );
		getDataSet( theSetIndex ).add( cdi );
		return this;
	}

	public Chart removeLast( ) {
		return removeLast( getFirstDataSetIndex( ) );
	}

	public Chart removeLast( String theSetIndex ) {
		return removeData( theSetIndex , getDataSet( theSetIndex ).size( ) - 1 );
	}

	public Chart removeFirst( ) {
		return removeFirst( getFirstDataSetIndex( ) );
	}

	public Chart removeFirst( String theSetIndex ) {
		return removeData( theSetIndex , 0 );
	}

	public Chart removeData( ChartData theItem ) {
		removeData( getFirstDataSetIndex( ) , theItem );
		return this;
	}

	public Chart removeData( String theSetIndex , ChartData theItem ) {
		getDataSet( theSetIndex ).remove( theItem );
		return this;
	}

	public Chart removeData( int theItemIndex ) {
		removeData( getFirstDataSetIndex( ) , theItemIndex );
		return this;
	}

	public Chart removeData( String theSetIndex , int theItemIndex ) {
		if ( getDataSet( theSetIndex ).size( ) < 1 ) {
			return this;
		}
		getDataSet( theSetIndex ).remove( theItemIndex );
		return this;
	}

	public Chart setData( int theItemIndex , ChartData theItem ) {
		getDataSet( getFirstDataSetIndex( ) ).set( theItemIndex , theItem );
		return this;
	}

	public Chart setData( String theSetItem , int theItemIndex , ChartData theItem ) {
		getDataSet( theSetItem ).set( theItemIndex , theItem );
		return this;
	}

	public Chart addDataSet( String theName ) {
		getDataSet( ).put( theName , new ChartDataSet( theName ) );
		return this;
	}

	public Chart setDataSet( ChartDataSet theItems ) {
		setDataSet( getFirstDataSetIndex( ) , theItems );
		return this;
	}

	public Chart setDataSet( String theSetIndex , ChartDataSet theChartData ) {
		getDataSet( ).put( theSetIndex , theChartData );
		return this;
	}

	public Chart removeDataSet( String theIndex ) {
		getDataSet( ).remove( theIndex );
		return this;
	}

	public Chart setData( float ... theValues ) {
		setData( getFirstDataSetIndex( ) , theValues );
		return this;
	}

	public Chart setData( String theSetIndex , float ... theValues ) {
		if ( getDataSet( ).get( theSetIndex ).size( ) != theValues.length ) {
			getDataSet( ).get( theSetIndex ).clear( );
			for ( int i = 0 ; i < theValues.length ; i++ ) {
				getDataSet( ).get( theSetIndex ).add( new ChartData( 0 ) );
			}
		}
		int n = 0;
		resolution = ( float ) getWidth() / ( getDataSet( ).get( theSetIndex ).size( ) - 1 );
		for ( float f : theValues ) {
			getDataSet( ).get( theSetIndex ).get( n++ ).setValue( f );
		}
		return this;
	}

	public Chart updateData( float ... theValues ) {
		return setData( theValues );
	}

	public Chart updateData( String theSetIndex , float ... theValues ) {
		return setData( theSetIndex , theValues );
	}

	public LinkedHashMap< String , ChartDataSet > getDataSet( ) {
		return _myDataSet;
	}

	public ChartDataSet getDataSet( String theIndex ) {
		return getDataSet( ).get( theIndex );
	}

	public float[] getValuesFrom( String theIndex ) {
		return getDataSet( theIndex ).getValues( );
	}

	public ChartData getData( String theIndex , int theItemIndex ) {
		return getDataSet( theIndex ).get( theItemIndex );
	}

	public int size( ) {
		return getDataSet( ).size( );
	}

	@Override
	public void onEnter( ) {
	}

	@Override
	public void onLeave( ) {
	}

	@Override
	public Chart setValue( float theValue ) {
		// TODO Auto-generated method stub
		return this;
	}

	public Chart setStrokeWeight( float theWeight ) {
		strokeWeight = theWeight;
		for ( ChartDataSet c : getDataSet( ).values( ) ) {
			c.setStrokeWeight( theWeight );
		}
		return this;
	}

	public float getStrokeWeight( ) {
		return strokeWeight;
	}

	/**
	 * ?
	 * 
	 * @param theValue
	 * @return
	 */
	public Chart setResolution( int theValue ) {
		resolution = theValue;
		return this;
	}

	public int getResolution( ) {
		return ( int ) resolution;
	}

	/**
	 * @exclude
	 */
	@Override
	@ControlP5.Invisible
	public Chart updateDisplayMode( int theMode ) {
		return updateViewMode( theMode );
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible
	public Chart updateViewMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new ChartViewPie( );
			break;
		case ( IMAGE ):
			// _myDisplay = new ChartImageDisplay();
			break;
		case ( SPRITE ):
			// _myDisplay = new ChartSpriteDisplay();
			break;
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	public class ChartViewBar implements ControllerView< Chart > {

		public void display( PGraphics theGraphics , Chart theController ) {
			theGraphics.pushStyle( );
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			theGraphics.noStroke( );

			Iterator< String > it = getDataSet( ).keySet( ).iterator( );
			String index = null;
			float o = 0;
			while ( it.hasNext( ) ) {
				index = it.next( );
				float s = getDataSet( index ).size( );
				for ( int i = 0 ; i < s ; i++ ) {
					theGraphics.fill( getDataSet( index ).getColor( i ) );
					float ww = ( ( getWidth() / s ) );
					float hh = PApplet.map( getDataSet( index ).get( i ).getValue( ) , _myMin , _myMax , 0 , getHeight( ) );
					theGraphics.rect( o + i * ww , getHeight( ) , ( ww / getDataSet( ).size( ) ) , -PApplet.min( getHeight( ) , PApplet.max( 0 , hh ) ) );
				}
				o += ( ( getWidth() / s ) ) / getDataSet( ).size( );
			}
			theGraphics.popStyle( );
		}
	}

	public class ChartViewBarCentered implements ControllerView< Chart > {

		public void display( PGraphics theGraphics , Chart theController ) {
			theGraphics.pushStyle( );
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			theGraphics.noStroke( );

			Iterator< String > it = getDataSet( ).keySet( ).iterator( );
			String index = null;
			float o = 0;
			int n = 4;
			int off = ( getDataSet( ).size( ) - 1 ) * n;
			while ( it.hasNext( ) ) {
				index = it.next( );
				int s = getDataSet( index ).size( );
				float step = ( float ) getWidth() / ( float ) ( s );
				float ww = step - ( getWidth() % step );
				ww -= 1;
				ww = PApplet.max( 1 , ww );

				for ( int i = 0 ; i < s ; i++ ) {
					theGraphics.fill( getDataSet( index ).getColor( i ) );
					ww = ( ( getWidth() / s ) * 0.5f );
					float hh = PApplet.map( getDataSet( index ).get( i ).getValue( ) , _myMin , _myMax , 0 , getHeight( ) );
					theGraphics.rect( -off / 2 + o + i * ( ( getWidth() / s ) ) + ww / 2 , getHeight( ) , ww , -PApplet.min( getHeight( ) , PApplet.max( 0 , hh ) ) );
				}
				o += n;
			}
			theGraphics.popStyle( );
		}
	}

	public class ChartViewLine implements ControllerView< Chart > {

		public void display( PGraphics theGraphics , Chart theController ) {

			theGraphics.pushStyle( );
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			theGraphics.noFill( );
			Iterator< String > it = getDataSet( ).keySet( ).iterator( );
			String index = null;
			while ( it.hasNext( ) ) {
				index = it.next( );
				theGraphics.stroke( getDataSet( index ).getColor( 0 ) );
				theGraphics.strokeWeight( getDataSet( index ).getStrokeWeight( ) );

				theGraphics.beginShape( );
				float res = ( ( float ) getWidth( ) ) / ( getDataSet( index ).size( ) - 1 );
				for ( int i = 0 ; i < getDataSet( index ).size( ) ; i++ ) {
					float hh = PApplet.map( getDataSet( index ).get( i ).getValue( ) , _myMin , _myMax , getHeight( ) , 0 );
					theGraphics.vertex( i * res , PApplet.min( getHeight( ) , PApplet.max( 0 , hh ) ) );
				}
				theGraphics.endShape( );
			}
			theGraphics.noStroke( );
			theGraphics.popStyle( );
			getCaptionLabel( ).draw( theGraphics , 0 , 0 , theController );
		}
	}

	public class ChartViewArea implements ControllerView< Chart > {

		public void display( PGraphics theGraphics , Chart theController ) {

			theGraphics.pushStyle( );
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			theGraphics.noStroke( );

			Iterator< String > it = getDataSet( ).keySet( ).iterator( );
			String index = null;
			while ( it.hasNext( ) ) {
				index = it.next( );
				float res = ( ( float ) getWidth( ) ) / ( getDataSet( index ).size( ) - 1 );

				theGraphics.fill( getDataSet( index ).getColor( 0 ) );
				theGraphics.beginShape( );
				theGraphics.vertex( 0 , getHeight( ) );

				for ( int i = 0 ; i < getDataSet( index ).size( ) ; i++ ) {
					float hh = PApplet.map( getDataSet( index ).get( i ).getValue( ) , _myMin , _myMax , getHeight( ) , 0 );
					theGraphics.vertex( i * res , PApplet.min( getHeight( ) , PApplet.max( 0 , hh ) ) );
				}
				theGraphics.vertex( getWidth( ) , getHeight( ) );
				theGraphics.endShape( PApplet.CLOSE );
			}
			theGraphics.noStroke( );
			theGraphics.popStyle( );
		}
	}

	public class ChartViewPie implements ControllerView< Chart > {

		public void display( PGraphics theGraphics , Chart theController ) {
			theGraphics.pushStyle( );
			theGraphics.pushMatrix( );

			Iterator< String > it = getDataSet( ).keySet( ).iterator( );
			String index = null;
			while ( it.hasNext( ) ) {
				index = it.next( );
				float total = 0;
				for ( int i = 0 ; i < getDataSet( index ).size( ) ; i++ ) {
					total += getDataSet( index ).get( i ).getValue( );
				}

				float segment = TWO_PI / total;
				float angle = -HALF_PI;

				theGraphics.noStroke( );
				for ( int i = 0 ; i < getDataSet( index ).size( ) ; i++ ) {
					theGraphics.fill( getDataSet( index ).getColor( i ) );
					float nextAngle = angle + getDataSet( index ).get( i ).getValue( ) * segment;

					// a tiny offset to even out render artifacts when in smooth() mode.
					float a = PApplet.max( 0 , PApplet.map( getWidth( ) , 0 , 200 , 0.05f , 0.01f ) );

					theGraphics.arc( 0 , 0 , getWidth( ) , getHeight( ) , angle - a , nextAngle );
					angle = nextAngle;
				}
				theGraphics.translate( 0 , ( getHeight( ) + 10 ) );
			}
			theGraphics.popMatrix( );
			theGraphics.popStyle( );
		}
	}

	public Chart setView( int theType ) {
		switch ( theType ) {
		case ( PIE ):
			setView( new ChartViewPie( ) );
			break;
		case ( LINE ):
			setView( new ChartViewLine( ) );
			break;
		case ( BAR ):
			setView( new ChartViewBar( ) );
			break;
		case ( BAR_CENTERED ):
			setView( new ChartViewBarCentered( ) );
			break;
		case ( AREA ):
			setView( new ChartViewArea( ) );
			break;
		default:
			System.out.println( "Sorry, this ChartView does not exist" );
			break;
		}
		return this;
	}

	@Override
	public String getInfo( ) {
		return "type:\tChart\n" + super.toString( );
	}

	@Override
	public String toString( ) {
		return super.toString( ) + " [ " + getValue( ) + " ]" + " Chart " + "(" + this.getClass( ).getSuperclass( ) + ")";
	}

}

/* NOTES what is the difference in meaning between chart and graph
 * http://answers.yahoo.com/question/index?qid=20090101193325AA3mgMl
 * 
 * more charts to implement: from https://vimeo.com/groups/oaod/videos/60013194 (44:40) scatter
 * plot, star plot, histogram, dendrogram, box plot, physical map, tree, 2d 3d isosurfaces table,
 * half matrix, graph, hierarchical pie, line graph, numeric matrix, heat map, permutation matrix
 * bar graph, radial graph, */
