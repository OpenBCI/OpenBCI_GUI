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

import processing.core.PApplet;
import processing.core.PGraphics;

/**
 * A Multilist is a multi-menu-tree controller. see the example for more information and how to use.
 * 
 * @example controllers/ControlP5multiList
 * 
 * TODO is currently broken, is this due to replacing PVector with float[]?
 * 
 */
public class MultiList extends Controller< MultiList > implements MultiListInterface , ControlListener {

	/* TODO reflection does not work properly. TODO add an option to remove MultiListButtons */

	protected Tab _myTab;
	protected boolean isVisible = true;
	private int cnt;
	protected boolean isOccupied;
	protected boolean isUpdateLocation = false;
	protected MultiListInterface mostRecent;
	protected int[] _myRect = new int[ 4 ];
	protected int _myDirection = ControlP5Constants.RIGHT;
	public int closeDelay = 30;
	protected int _myDefaultButtonHeight = 10;
	protected boolean isUpperCase = true;

	/**
	 * Convenience constructor to extend MultiList.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public MultiList( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 99 , 19 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	public MultiList( ControlP5 theControlP5 , Tab theParent , String theName , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , 0 );
		_myDefaultButtonHeight = theHeight;
		setup( );
	}

	public MultiList toUpperCase( boolean theValue ) {
		isUpperCase = theValue;
		for ( Controller c : getSubelements( ) ) {
			c.getCaptionLabel( ).toUpperCase( isUpperCase );
		}
		return this;
	}

	@ControlP5.Invisible public void setup( ) {
		mostRecent = this;
		isVisible = true;
		updateRect( x( position ) , y( position ) , getWidth( ) , _myDefaultButtonHeight );
	}

	protected void updateRect( float theX , float theY , float theW , float theH ) {
		_myRect = new int[] { ( int ) theX , ( int ) theY , ( int ) theW , ( int ) theH };
	}

	public int getDirection( ) {
		return _myDirection;
	}

	/**
	 * TODO does not work.
	 * 
	 * @param theDirection
	 */
	void setDirection( int theDirection ) {
		_myDirection = ( theDirection == LEFT ) ? LEFT : RIGHT;
		for ( int i = 0 ; i < getSubelements( ).size( ) ; i++ ) {
			( ( MultiListButton ) getSubelements( ).get( i ) ).setDirection( _myDirection );
		}
	}

	/**
	 * @param theX
	 *            float
	 * @param theY
	 *            float
	 */
	@ControlP5.Invisible public void updateLocation( float theX , float theY ) {
		set( position , theX , theY );
		updateRect( x( position ) , y( position ) , getWidth( ) , _myDefaultButtonHeight );
		for ( int i = 0 ; i < getSubelements( ).size( ) ; i++ ) {
			( ( MultiListInterface ) getSubelements( ).get( i ) ).updateLocation( theX , theY );
		}

	}

	/**
	 * removes the multilist.
	 */
	public void remove( ) {
		super.remove( );
		for ( int i = 0 ; i < getSubelements( ).size( ) ; i++ ) {
			getSubelements( ).get( i ).removeListener( this );
			getSubelements( ).get( i ).remove( );
		}
	}

	/**
	 * adds multilist buttons to the multilist.
	 * 
	 * @param theName
	 *            String
	 * @param theValue
	 *            int
	 * @return MultiListButton
	 */
	public MultiListButton add( String theName , int theValue ) {
		int x = ( int ) x( position );
		int yy = 0;
		for ( Controller< ? > c : getSubelements( ) ) {
			yy += c.getHeight( ) + 1;
		}
		int y = ( int ) y( position ) + yy;// (_myDefaultButtonHeight + 1) * _myChildren.size();
		MultiListButton b = new MultiListButton( cp5 , theName , theValue , x , y , getWidth( ) , _myDefaultButtonHeight , this , this );
		b.toUpperCase( isUpperCase );
		b.isMoveable = false;
		cp5.register( null , "" , b );
		b.addListener( this );
		getSubelements( ).add( b );
		b.show( );
		updateRect( x( position ) , y( position ) , getWidth( ) , ( _myDefaultButtonHeight + 1 ) * getSubelements( ).size( ) );
		return b;
	}

	/**
	 * @param theEvent
	 */
	@Override @ControlP5.Invisible public void controlEvent( ControlEvent theEvent ) {
		if ( theEvent.getController( ) instanceof MultiListButton ) {
			_myValue = theEvent.getController( ).getValue( );
			ControlEvent myEvent = new ControlEvent( this );
			cp5.getControlBroadcaster( ).broadcast( myEvent , ControlP5Constants.FLOAT );
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public void draw( PGraphics theGraphics ) {
		super.draw( theGraphics );
		// TODO update( theGraphics );
	}

	/**
	 * 
	 * @param theApplet
	 * @return boolean
	 */
	@ControlP5.Invisible public boolean update( PApplet theApplet ) {
		if ( !isOccupied ) {
			cnt++;
			if ( cnt == closeDelay ) {
				close( );
			}
		}

		if ( isUpdateLocation ) {
			updateLocation( ( _myControlWindow.mouseX - _myControlWindow.pmouseX ) , ( _myControlWindow.mouseY - _myControlWindow.pmouseY ) );
			isUpdateLocation = theApplet.mousePressed;
		}

		if ( isOccupied ) {
			if ( theApplet.keyPressed && theApplet.mousePressed ) {
				if ( theApplet.keyCode == PApplet.ALT ) {
					isUpdateLocation = true;
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * 
	 * @param theFlag
	 *            boolean
	 */
	@ControlP5.Invisible public void occupied( boolean theFlag ) {
		isOccupied = theFlag;
		cnt = 0;
	}

	/**
	 * @return boolean
	 */
	@ControlP5.Invisible public boolean observe( ) {
		return CP.inside( _myRect , _myControlWindow.mouseX , _myControlWindow.mouseY );
	}

	/**
	 * @param theInterface
	 *            MultiListInterface
	 */
	public void close( MultiListInterface theInterface ) {
		for ( int i = 0 ; i < getSubelements( ).size( ) ; i++ ) {
			if ( theInterface != ( MultiListInterface ) getSubelements( ).get( i ) ) {
				( ( MultiListInterface ) getSubelements( ).get( i ) ).close( );
			}
		}

	}

	/**
	 * {@inheritDoc}
	 */
	@Override public void close( ) {
		for ( int i = 0 ; i < getSubelements( ).size( ) ; i++ ) {
			( ( MultiListInterface ) getSubelements( ).get( i ) ).close( );
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public void open( ) {
		for ( int i = 0 ; i < getSubelements( ).size( ) ; i++ ) {
			( ( MultiListInterface ) getSubelements( ).get( i ) ).open( );
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public MultiList setValue( float theValue ) {
		return this;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public MultiList update( ) {
		return setValue( _myValue );
	}

}
