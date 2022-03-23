package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser
 * General Public License as published by the Free Software
 * Foundation; either version 2.1 of the License, or (at
 * your option) any later version. This library is
 * distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 59 Temple Place,
 * Suite 330, Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 03/23/2022
 * @version 2.3.2
 * 
 */

import processing.core.PGraphics;
import processing.core.PImage;

/**
 * <p>
 * A button triggers an event after it has been release.
 * Events can be linked to functions and fields inside your
 * program/sketch. for a full documentation of this
 * controller see the {@link Controller} class.
 * 
 * @example controllers/ControlP5button
 */

public class Button extends Controller< Button > {

	protected boolean isPressed;
	protected boolean isOn = false;
	public static int autoWidth = 69;
	public static int autoHeight = 19;
	protected int activateBy = RELEASE;
	protected boolean isSwitch = false;
	protected int cornerRoundness = 0;
	protected Integer buttonStrokeColor;
	protected boolean isCircularButton;
	protected boolean forceDrawBackground;

	/**
	 * Convenience constructor to extend Button.
	 * 
	 * @example use/ControlP5extendController
	 */
	public Button( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected Button( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theDefaultValue , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myValue = theDefaultValue;
		_myCaptionLabel.align( CENTER , CENTER );
	}

	/**
	 * @exclude
	 */
	public Button( ) {
		super( null , null , null , 0 , 0 , 1 , 1 );
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
	}

	/**
	 * A button can be activated by a mouse PRESSED or mouse
	 * RELEASE. Default value is RELEASE.
	 * 
	 * @param theValue use ControlP5.PRESSED or
	 *            ControlP5.RELEASE as parameter
	 * @return Button
	 */
	public Button activateBy( int theValue ) {
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

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public void mouseReleasedOutside( ) {
		mouseReleased( );
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Button setValue( float theValue ) {
		_myValue = theValue;
		broadcast( FLOAT );
		return this;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Button update( ) {
		return setValue( _myValue );
	}

	/**
	 * Turns a button into a switch, or use a Toggle
	 * instead.
	 * 
	 */
	public Button setSwitch( boolean theFlag ) {
		isSwitch = theFlag;
		if ( isSwitch ) {
			_myBroadcastType = BOOLEAN;
		} else {
			_myBroadcastType = FLOAT;
		}
		return this;
	}

	/**
	 * If the button acts as a switch, setOn will turn on
	 * the switch. Use
	 * {@link controlP5.Button#setSwitch(boolean) setSwitch}
	 * to turn a Button into a Switch.
	 * 
	 * @return Button
	 */
	public Button setOn( ) {
		if ( isSwitch ) {
			isOn = false;
			isActive = true;
			activate( );
		}
		return this;
	}

	/**
	 * If the button acts as a switch, setOff will turn off
	 * the switch. Use
	 * {@link controlP5.Button#setSwitch(boolean) setSwitch}
	 * to turn a Button into a Switch.
	 * 
	 * @return Button
	 */
	public Button setOff( ) {
		if ( isSwitch ) {
			isOn = true;
			isActive = true;
			activate( );
		}
		return this;
	}

	/**
	 * @return boolean
	 */
	public boolean isOn( ) {
		return isOn;
	}

	public boolean isSwitch( ) {
		return isSwitch;
	}

	/**
	 * @return boolean
	 */
	public boolean isPressed( ) {
		return isPressed;
	}

	/**
	 * Set the corner roundess of this button. Default value is 0 and right-angle corners.
	 * @param _cornerRoundness
	 * @return Button
	 */
    public Button setCornerRoundness(int _cornerRoundness){
		cornerRoundness = _cornerRoundness;
		return this;
	}

	/**
	 * Set the border color of this button. Default value is null.
	 * When null, noStroke() is used during draw loop
	 * @param theColor
	 * @return Button
	 */
    public Button setBorderColor(Integer theColor){
		buttonStrokeColor = theColor;
		return this;
	}

	/**
	 * Draw a circular button instead of a rectangular one.
	 * Default value is false.
	 * 
	 * @param theFlag
	 * @return Button
	 */
    public Button setCircularButton(boolean theFlag){
		isCircularButton = theFlag;
		return this;
	}

	/**
	 * Force draw the button background when using images
	 * Default value is false.
	 * 
	 * @param theFlag
	 * @return Button
	 */
    public Button setForceDrawBackground(boolean theFlag){
		forceDrawBackground = theFlag;
		return this;
	}
	
	/**
	 * Returns true or false and indicates the switch state
	 * of the button. {@link setSwitch(boolean) setSwitch}
	 * should have been set before.
	 * 
	 * @see controlP5.Button#setSwitch(boolean)
	 * @return boolean
	 */
	public boolean getBooleanValue( ) {
		return isOn;
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public Button updateDisplayMode( int theMode ) {
		return updateViewMode( theMode );
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public Button updateViewMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new ButtonView( );
			break;
		case ( IMAGE ):
			_myControllerView = new ButtonImageView( );
			break;
		case ( CUSTOM ):
		default:
			break;

		}
		return this;
	}

	private class ButtonView implements ControllerView< Button > {

		public void display( PGraphics theGraphics , Button theController ) {
			theGraphics.pushStyle();
			if (buttonStrokeColor != null) {
				theGraphics.stroke( buttonStrokeColor );
			} else {
				theGraphics.noStroke( );
			}
			
			if ( isOn && isSwitch ) {
				theGraphics.fill( color.getActive( ) );
			} else {
				if ( getIsInside( ) ) {
					if ( isPressed ) {
						theGraphics.fill( color.getActive( ) );
					} else {
						theGraphics.fill( color.getForeground( ) );
					}
				} else {
					theGraphics.fill( color.getBackground( ) );
				}
			}

			if (isCircularButton) {
				theGraphics.ellipseMode( theGraphics.CORNER );
				theGraphics.ellipse( 0 , 0 , getWidth( ) , getHeight( ));
			} else {
				theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) , cornerRoundness);
			}

			if ( isLabelVisible ) {
				_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
			}
			theGraphics.popStyle();
		}
	}

	private class ButtonImageView implements ControllerView< Button > {

		public void display( PGraphics theGraphics , Button theController ) {
			
			PImage img;
			int imgX = 0;
			int imgY = 0;
			int imgW = 0;
			int imgH = 0;
			
			theGraphics.pushStyle();

			if (buttonStrokeColor != null) {
				theGraphics.stroke( buttonStrokeColor );
			} else {
				theGraphics.noStroke( );
			}
			
			if (forceDrawBackground) {
				theGraphics.imageMode(theGraphics.CENTER);
				imgX = 0 + (getWidth() / 2);
				imgY = 0 + (getHeight() / 2);
				imgW = getWidth() - 8;
				imgH = getHeight() - 8;
			}

			if ( isOn && isSwitch ) {
				img = availableImages[ HIGHLIGHT ] == true ? images[ HIGHLIGHT ] : images[ DEFAULT ];
				if (forceDrawBackground) {
					theGraphics.image( img, imgX, imgY, imgW, imgH );
				} else {
					theGraphics.image( img, 0, 0);
				}
				return;
			}

			if ( getIsInside( ) ) {
				if ( isPressed ) {
					theGraphics.fill( color.getActive( ) );
					img = availableImages[ ACTIVE ] == true ? images[ ACTIVE ] : images[ DEFAULT ];
				} else {
					theGraphics.fill( color.getForeground( ) );
					img = availableImages[ OVER ] == true ? images[ OVER ] : images[ DEFAULT ];
				}
			} else {
				theGraphics.fill( color.getBackground( ) );
				img = images[ DEFAULT ];
			}

			if (forceDrawBackground) {
				theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) , cornerRoundness);
				theGraphics.image( img, imgX, imgY, imgW, imgH);
			} else {
				theGraphics.image( img, imgX, imgY);
			}
			
			theGraphics.popStyle();
		}
	}

	/**
	 * @exclude
	 */
	@Override public String getInfo( ) {
		return "type:\tButton\n" + super.getInfo( );
	}

	/**
	 * @exclude
	 */
	@Override public String toString( ) {
		return super.toString( ) + " [ " + getValue( ) + " ] " + "Button" + " (" + this.getClass( ).getSuperclass( ) + ")";
	}

}