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
import processing.core.PImage;

/**
 * a toggle can have two states, true and false, where true has the value 1 and false is 0.
 * 
 * @example controllers/ControlP5toggle
 * @nosuperclasses Controller Controller
 */
public class Toggle extends Controller< Toggle > {

	protected int cnt;
	protected boolean isOn = false;
	protected float internalValue = -1;
	public static int autoWidth = 39;
	public static int autoHeight = 19;
	protected float[] autoSpacing = new float[] { 10 , 20 };

	/**
	 * Convenience constructor to extend Toggle.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public Toggle( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	public Toggle( ControlP5 theControlP5 , Tab theParent , String theName , float theValue , float theX , float theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myValue = theValue;
		_myCaptionLabel.align( LEFT , BOTTOM_OUTSIDE ).setPadding( 0 , Label.paddingY );
	}

	/**
	 * 
	 * @param theApplet PApplet
	 */
	@ControlP5.Invisible public void draw( PGraphics theGraphics ) {
		theGraphics.pushMatrix( );
		theGraphics.translate( x( position ) , y( position ) );
		_myControllerView.display( theGraphics , this );
		theGraphics.popMatrix( );
	}

	protected void onEnter( ) {
		isActive = true;
	}

	protected void onLeave( ) {
		isActive = false;
	}

	/**
	 * {@inheritDoc}
	 */
	@ControlP5.Invisible public void mousePressed( ) {
		setState( !isOn );
		isActive = false;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Toggle setValue( float theValue ) {
		if ( theValue == 0 ) {
			setState( false );
		} else {
			setState( true );
		}
		return this;
	}

	/**
	 * @param theValue
	 */
	public Toggle setValue( boolean theValue ) {
		setValue( ( theValue == true ) ? 1 : 0 );
		return this;
	}

	public boolean getBooleanValue( ) {
		return getState( );
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Toggle update( ) {
		return setValue( _myValue );
	}

	/**
	 * sets the state of the toggle, this can be true or false.
	 * 
	 * @param theFlag boolean
	 */
	public Toggle setState( boolean theFlag ) {
		isOn = theFlag;
		_myValue = ( isOn == false ) ? 0 : 1;
		broadcast( FLOAT );
		return this;
	}

	public boolean getState( ) {
		return isOn;
	}

	protected void deactivate( ) {
		isOn = false;
		_myValue = ( isOn == false ) ? 0 : 1;
	}

	protected void activate( ) {
		isOn = true;
		_myValue = ( isOn == false ) ? 0 : 1;
	}

	/**
	 * switch the state of a toggle.
	 */
	public Toggle toggle( ) {
		if ( isOn ) {
			setState( false );
		} else {
			setState( true );
		}
		return this;
	}

	/**
	 * set the visual mode of a Toggle. use setMode(ControlP5.DEFAULT) or setMode(ControlP5.SWITCH)
	 * 
	 * @param theMode
	 */
	public Toggle setMode( int theMode ) {
		updateDisplayMode( theMode );
		return this;
	}

	public int getMode( ) {
		return _myDisplayMode;
	}

	/**
	 * by default a toggle returns 0 (for off) and 1 (for on). the internal value variable can be
	 * used to store an additional value for a toggle event.
	 * 
	 * @param theInternalValue
	 */
	@ControlP5.Invisible public void setInternalValue( float theInternalValue ) {
		internalValue = theInternalValue;
	}

	@ControlP5.Invisible public float internalValue( ) {
		return internalValue;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Toggle linebreak( ) {
		cp5.linebreak( this , true , autoWidth , autoHeight , autoSpacing );
		return this;
	}

	@Override public Toggle setImages( PImage ... theImages ) {
		setImage( theImages[ 0 ] , DEFAULT );
		setImage( theImages[ 1 ] , ACTIVE );
		updateDisplayMode( IMAGE );
		return this;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public Toggle updateDisplayMode( int theState ) {
		_myDisplayMode = theState;
		switch ( theState ) {
		case ( DEFAULT ):
			_myControllerView = new ToggleView( );
			break;
		case ( IMAGE ):
			_myControllerView = new ToggleImageView( );
			break;
		case ( SWITCH ):
			_myControllerView = new ToggleSwitchView( );
			break;
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	class ToggleView implements ControllerView< Toggle > {

		public void display( PGraphics theGraphics , Toggle theController ) {
			if ( isActive ) {
				theGraphics.fill( isOn ? color.getActive( ) : color.getForeground( ) );
			} else {
				theGraphics.fill( isOn ? color.getActive( ) : color.getBackground( ) );
			}

			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );

			if ( isLabelVisible ) {
				_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
			}

		}
	}

	class ToggleImageView implements ControllerView< Toggle > {

		public void display( PGraphics theGraphics , Toggle theController ) {

			if ( isOn ) {
				theGraphics.image( ( availableImages[ ACTIVE ] == true ) ? images[ ACTIVE ] : images[ DEFAULT ] , 0 , 0 );
			} else {
				theGraphics.image( images[ DEFAULT ] , 0 , 0 );
			}
		}
	}

	class ToggleSwitchView implements ControllerView< Toggle > {

		public void display( PGraphics theGraphics , Toggle theController ) {

			theGraphics.fill( color.getBackground( ) );
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			theGraphics.fill( color.getActive( ) );

			if ( isOn ) {
				theGraphics.rect( 0 , 0 , getWidth( ) / 2 , getHeight( ) );
			} else {
				theGraphics.rect( ( getWidth( ) % 2 == 0 ? 0 : 1 ) + getWidth( ) / 2 , 0 , getWidth( ) / 2 , getHeight( ) );
			}

			if ( isLabelVisible ) {
				_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
			}
		}
	}
}
