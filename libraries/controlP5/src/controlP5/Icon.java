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
import processing.core.PFont;
import processing.core.PGraphics;

public class Icon extends Controller< Icon > {

	protected boolean isPressed;
	protected boolean isOn = false;
	public static int autoWidth = 69;
	public static int autoHeight = 19;
	protected int activateBy = RELEASE;
	protected boolean isSwitch = false;
	protected int roundedCorners = 0;
	protected boolean isFill = true;
	protected boolean isStroke = false;
	protected float scl = 1;
	protected int[] fontIcons = new int[] { -1 , -1 , -1 , -1 };
	protected boolean isHideBackground = true;
	protected float strokeWeight = 1;
	protected float scalePressed = 1.0f;
	protected float scaleReleased = 1.0f;

	public Icon( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected Icon( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theDefaultValue , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myValue = theDefaultValue;
		_myCaptionLabel.align( CENTER , CENTER );
	}

	@Override protected void onEnter( ) {
		isActive = true;
	}

	@Override protected void onLeave( ) {
		isActive = false;
		setIsInside( false );
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public void mousePressed( ) {
		isActive = getIsInside( );
		isPressed = true;
		if ( activateBy == PRESSED ) {
			activate( );
		}
		scl = scalePressed;
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public void mouseReleased( ) {
		isPressed = false;
		if ( activateBy == RELEASE ) {
			activate( );
		}
		isActive = false;
		scl = scaleReleased;
	}

	/**
	 * A Icon can be activated by a mouse PRESSED or mouse
	 * RELEASE. Default value is RELEASE.
	 */
	public Icon activateBy( int theValue ) {
		if ( theValue == PRESS ) {
			activateBy = PRESS;
		} else {
			activateBy = RELEASE;
		}
		return this;
	}

	protected void activate( ) {
		if ( isActive ) {
			isActive = false;
			isOn = !isOn;
			setValue( _myValue );
		}
	}

	@Override @ControlP5.Invisible public void mouseReleasedOutside( ) {
		mouseReleased( );
	}

	@Override public Icon setValue( float theValue ) {
		_myValue = theValue;
		broadcast( FLOAT );
		return this;
	}

	@Override public Icon update( ) {
		return setValue( _myValue );
	}

	/**
	 * Turns an icon into a switch.
	 */
	public Icon setSwitch( boolean theFlag ) {
		isSwitch = theFlag;
		if ( isSwitch ) {
			_myBroadcastType = BOOLEAN;
		} else {
			_myBroadcastType = FLOAT;
		}
		return this;
	}

	/**
	 * If the Icon acts as a switch, setOn will turn on
	 * the switch. Use
	 * {@link controlP5.Icon#setSwitch(boolean) setSwitch}
	 * to turn a Icon into a Switch.
	 */
	public Icon setOn( ) {
		if ( isSwitch ) {
			isOn = false;
			isActive = true;
			activate( );
		}
		return this;
	}

	/**
	 * If the Icon acts as a switch, setOff will turn off
	 * the switch. Use
	 * {@link controlP5.Icon#setSwitch(boolean) setSwitch}
	 * to turn a Icon into a Switch.
	 */
	public Icon setOff( ) {
		if ( isSwitch ) {
			isOn = true;
			isActive = true;
			activate( );
		}
		return this;
	}

	public boolean isOn( ) {
		return isOn;
	}

	public boolean isSwitch( ) {
		return isSwitch;
	}

	public boolean isPressed( ) {
		return isPressed;
	}

	/**
	 * Returns true or false and indicates the switch state
	 * of the Icon. {@link setSwitch(boolean) setSwitch}
	 * should have been set before.
	 */
	public boolean getBooleanValue( ) {
		return isOn;
	}

	public Icon setRoundedCorners( int theRadius ) {
		roundedCorners = theRadius;
		return this;
	}

	public Icon setFontIconSize( int theSize ) {
		_myCaptionLabel.setSize( theSize );
		return this;
	}

	public Icon setFont( PFont thePFont ) {
		_myCaptionLabel.setFont( thePFont );
		return this;
	}

	public Icon setFont( PFont thePFont , int theSize ) {
		_myCaptionLabel.setFont( thePFont );
		setFontIconSize( theSize );
		return this;
	}

	public Icon setFontIndex( int theIndex ) {
		_myCaptionLabel.set( "" + ( char ) theIndex );
		return this;
	}

	public Icon setStroke( boolean theBoolean ) {
		isStroke = theBoolean;
		return this;
	}

	public Icon setStrokeWeight( float theStrokeWeight ) {
		strokeWeight = theStrokeWeight;
		return this;
	}

	public Icon setFill( boolean theBoolean ) {
		isFill = theBoolean;
		return this;
	}

	public Icon setFontIcons( int theStateOff , int theStateOn ) {
		setFontIcon( theStateOn , ACTIVE );
		setFontIcon( theStateOff , DEFAULT );
		return this;
	}

	public Icon setFontIconOn( int theStateOn ) {
		setFontIcon( theStateOn , ACTIVE );
		return this;
	}

	public Icon setFontIconOff( int theStateOff ) {
		setFontIcon( theStateOff , DEFAULT );
		return this;
	}

	public Icon setFontIcons( int ... theIds ) {
		if ( theIds.length < 3 || theIds.length > 4 ) {
			return this;
		}
		setFontIcon( theIds[ 0 ] , DEFAULT );
		setFontIcon( theIds[ 1 ] , OVER );
		setFontIcon( theIds[ 2 ] , ACTIVE );
		setFontIcon( theIds.length == 3 ? theIds[ 2 ] : theIds[ 3 ] , HIGHLIGHT );
		return this;
	}

	public Icon setFontIcon( int theId ) {
		return setFontIcon( theId , DEFAULT );
	}

	public int getFontIcon( int theState ) {
		if ( theState >= 0 && theState < 4 ) {
			return fontIcons[ theState ];
		} else {
			return fontIcons[ DEFAULT ];
		}
	}

	/**
	 * @param theImage
	 * @param theState use Controller.DEFAULT (background) Controller.OVER (foreground) Controller.ACTIVE (active)
	 */
	public Icon setFontIcon( int theId , int theState ) {
		fontIcons[ theState ] = theId;
		updateDisplayMode( DEFAULT );
		return this;
	}

	public Icon hideBackground( ) {
		isHideBackground = true;
		return this;
	}

	public Icon showBackground( ) {
		isHideBackground = false;
		return this;
	}

	public Icon setScale( float theScalePressed , float theScaleReleased ) {
		scalePressed = theScalePressed;
		scaleReleased = theScaleReleased;
		return this;
	}

	@Override @ControlP5.Invisible public Icon updateDisplayMode( int theMode ) {
		return updateViewMode( theMode );
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public Icon updateViewMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new IconView( );
			break;
		case ( IMAGE ):
			_myControllerView = new IconImageView( );
			break;
		case ( CUSTOM ):
		default:
			break;

		}
		return this;
	}

	private class IconView implements ControllerView< Icon > {

		public void display( PGraphics theGraphics , Icon theController ) {

			if ( !isHideBackground ) {
				if ( isStroke ) {
					theGraphics.stroke( color.getBackground( ) );
					theGraphics.strokeWeight( strokeWeight );
				} else {
					theGraphics.noStroke( );
				}

				if ( isFill ) {
					theGraphics.fill( color.getBackground( ) );
				} else {
					theGraphics.noFill( );
				}
			}

			float w_half = getWidth( ) / 2;
			float h_half = getHeight( ) / 2;
			theGraphics.translate( w_half , h_half );
			theGraphics.scale( scl );

			if ( !isHideBackground ) {
				if ( roundedCorners == 0 ) {
					theGraphics.rect( -w_half , -h_half , getWidth( ) , getHeight( ) );
				} else if ( roundedCorners == -1 ) {
					theGraphics.ellipseMode(PApplet.CORNER);
					theGraphics.ellipse( -w_half , -h_half , getWidth( ) , getHeight( ) );
				} else {
					theGraphics.rect( -w_half , -h_half , getWidth( ) , getHeight( ) , roundedCorners , roundedCorners , roundedCorners , roundedCorners );
				}
			}

			if ( isSwitch ) {
				if ( !isOn ) {
					setFontIndex( getFontIcon( ACTIVE ) );
				} else {
					setFontIndex( getFontIcon( DEFAULT ) );
				}
			} else {
				setFontIndex( getFontIcon( DEFAULT ) );
			}
			_myCaptionLabel.setColor( isOn && isSwitch || isPressed && !isSwitch ? color.getActive( ) : color.getForeground( ) );
			_myCaptionLabel.draw( theGraphics , -( int ) w_half , -( int ) ( h_half * 1.05f ) , theController );

		}
	}

	private class IconImageView implements ControllerView< Icon > {

		public void display( PGraphics theGraphics , Icon theController ) {

			float w_half = getWidth( ) / 2;
			float h_half = getHeight( ) / 2;
			theGraphics.translate( w_half , h_half );
			theGraphics.scale( scl );

			if ( isOn && isSwitch ) {
				theGraphics.image( ( availableImages[ HIGHLIGHT ] == true ) ? images[ HIGHLIGHT ] : images[ DEFAULT ] , -w_half , -h_half );
				return;
			}
			if ( getIsInside( ) ) {
				if ( isPressed ) {
					theGraphics.image( ( availableImages[ ACTIVE ] == true ) ? images[ ACTIVE ] : images[ DEFAULT ] , -w_half , -h_half );
				} else {
					theGraphics.image( ( availableImages[ OVER ] == true ) ? images[ OVER ] : images[ DEFAULT ] , -w_half , -h_half );
				}
			} else {
				theGraphics.image( images[ DEFAULT ] , -w_half , -h_half );
			}
		}
	}

	@Override public String getInfo( ) {
		return "type:\tIcon\n" + super.getInfo( );
	}

	@Override public String toString( ) {
		return super.toString( ) + " [ " + getValue( ) + " ] " + "Icon" + " (" + this.getClass( ).getSuperclass( ) + ")";
	}
}
