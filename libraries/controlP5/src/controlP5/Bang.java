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

import processing.core.PGraphics;

/**
 * <p>
 * The Bang controller triggers an event when pressed. A bang can only be assigned to a function in
 * your program but not to a field like other controllers. Bang extends superclass Controller, for a
 * full documentation see the {@link Controller} reference.
 * 
 * @example controllers/ControlP5bang
 */
@ControlP5.Layout public class Bang extends Controller< Bang > {

	protected int cnt;

	protected int triggerId = PRESSED;

	/**
	 * Convenience constructor to extend Bang.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public Bang( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 20 , 20 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected Bang( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theX , float theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myCaptionLabel.setPadding( 0 , Label.paddingY ).align( LEFT , BOTTOM_OUTSIDE );
		_myValue = 1;
	}

	@Override protected void onEnter( ) {
		cnt = 0;
		isActive = true;
	}

	@Override protected void onLeave( ) {
		isActive = false;
	}

	@Override protected void mousePressed( ) {
		if ( triggerId == PRESSED ) {
			cnt = -3;
			isActive = true;
			update( );
		}
	}

	@Override protected void mouseReleased( ) {
		if ( triggerId == RELEASE ) {
			cnt = -3;
			isActive = true;
			update( );
		}
	}

	@Override protected void mouseReleasedOutside( ) {
		onLeave( );
	}

	/**
	 * By default a bang is triggered when the mouse is pressed. use setTriggerEvent(Bang.PRESSED)
	 * or setTriggerEvent(Bang.RELEASE) to define the action for triggering a bang. currently only
	 * Bang.PRESSED and Bang.RELEASE are supported.
	 * 
	 * @param theEventID
	 * @return Bang
	 */
	@ControlP5.Layout public Bang setTriggerEvent( int theEventID ) {
		triggerId = theEventID;
		return this;
	}

	@ControlP5.Layout public int getTriggerEvent( ) {
		return triggerId;
	}

	/**
	 * Sets the value of the bang controller. since bang can be true or false, false=0 and true=1
	 * 
	 * @param theValue float
	 * @return Bang
	 */
	@Override public Bang setValue( float theValue ) {
		_myValue = theValue;
		broadcast( FLOAT );
		return this;
	}

	/**
	 * @exclude
	 */
	@Override public Bang update( ) {
		return setValue( _myValue );
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public Bang updateDisplayMode( int theMode ) {
		updateViewMode( theMode );
		return this;
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public Bang updateViewMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new BangView( );
			break;
		case ( IMAGE ):
			_myControllerView = new BangImageView( );
			break;
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	private class BangView implements ControllerView< Bang > {

		public void display( PGraphics theGraphics , Bang theController ) {
			if ( isActive ) {
				theGraphics.fill( color.getActive( ) );
			} else {
				theGraphics.fill( color.getForeground( ) );
			}

			if ( cnt < 0 ) {
				theGraphics.fill( color.getForeground( ) );
				cnt++;
			}
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			if ( isLabelVisible ) {
				_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
			}
		}
	}

	private class BangImageView implements ControllerView< Bang > {

		public void display( PGraphics theGraphics , Bang theController ) {
			if ( isActive ) {
				theGraphics.image( ( availableImages[ ACTIVE ] == true ) ? images[ ACTIVE ] : images[ DEFAULT ] , 0 , 0 );
			} else {
				theGraphics.image( ( availableImages[ OVER ] == true ) ? images[ OVER ] : images[ DEFAULT ] , 0 , 0 );
			}
			if ( cnt < 0 ) {
				theGraphics.image( ( availableImages[ OVER ] == true ) ? images[ OVER ] : images[ DEFAULT ] , 0 , 0 );
				cnt++;
			}
		}
	}

	/**
	 * {@inheritDoc}
	 * 
	 * @exclude
	 */
	@Override public String getInfo( ) {
		return "type:\tBang\n" + super.getInfo( );
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override public String toString( ) {
		return super.toString( ) + " [ " + getValue( ) + " ] " + "Bang" + " (" + this.getClass( ).getSuperclass( ) + ")";
	}

}
