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
 * Click and drag the mouse inside a numberbox and move up and down to change the value of a
 * numberbox. By default the value changes when dragging the mouse up and down. use
 * setDirection(Controller.HORIZONTAL) to change the mouse control to left and right.
 * 
 * Why do I get -1000000 as initial value when creating a numberbox without a default value? the
 * value of a numberbox defaults back to its minValue, which is -1000000. either use a default value
 * or link a variable to the numberbox - this is done by giving a float or int variable the same
 * name as the numberbox.
 * 
 * Use setMultiplier(float) to change the sensitivity of values increasing/decreasing, by default
 * the multiplier is 1.
 * 
 * 
 * @example controllers/ControlP5numberbox
 * @nosuperclasses Controller Controller
 */
public class Numberbox extends Controller< Numberbox > {

	protected int cnt;
	protected boolean isActive;
	public static int LEFT = 0;
	public static int UP = 1;
	public static int RIGHT = 2;
	public static int DOWN = 3;
	protected int _myNumberCount = VERTICAL;
	protected float _myMultiplier = 1;
	public static int autoWidth = 69;
	public static int autoHeight = 19;
	protected float[] autoSpacing = new float[] { 10 , 20 };
	protected float scrollSensitivity = 0.1f;

	/**
	 * Convenience constructor to extend Numberbox.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public Numberbox( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	/**
	 * 
	 * @param theControlP5 ControlP5
	 * @param theParent Tab
	 * @param theName String
	 * @param theDefaultValue float
	 * @param theX int
	 * @param theY int
	 * @param theWidth int
	 * @param theHeight int
	 */
	public Numberbox( ControlP5 theControlP5 , Tab theParent , String theName , float theDefaultValue , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myMin = -Float.MAX_VALUE;
		_myMax = Float.MAX_VALUE;
		_myValue = theDefaultValue;
		_myValueLabel = new Label( cp5 , "" + _myValue , theWidth , 12 , color.getValueLabel( ) );
		if ( Float.isNaN( _myValue ) ) {
			_myValue = 0;
		}
	}

	/* (non-Javadoc)
	 * 
	 * @see ControllerInterfalce.updateInternalEvents */
	@ControlP5.Invisible
	public Numberbox updateInternalEvents( PApplet theApplet ) {
		if ( isActive ) {
			if ( !cp5.isAltDown( ) ) {
				if ( _myNumberCount == VERTICAL ) {
					setValue( _myValue + ( _myControlWindow.mouseY - _myControlWindow.pmouseY ) * _myMultiplier );
				} else {
					setValue( _myValue + ( _myControlWindow.mouseX - _myControlWindow.pmouseX ) * _myMultiplier );
				}
			}
		}
		return this;
	}

	/* (non-Javadoc)
	 * 
	 * @see controlP5.Controller#mousePressed() */
	@Override
	@ControlP5.Invisible
	public void mousePressed( ) {
		isActive = true;
	}

	/* (non-Javadoc)
	 * 
	 * @see controlP5.Controller#mouseReleased() */
	@Override
	@ControlP5.Invisible
	public void mouseReleased( ) {
		isActive = false;
	}

	/* (non-Javadoc)
	 * 
	 * @see controlP5.Controller#mouseReleasedOutside() */
	@Override
	@ControlP5.Invisible
	public void mouseReleasedOutside( ) {
		mouseReleased( );
	}

	/**
	 * 
	 * @param theMultiplier
	 * @return Numberbox
	 */
	public Numberbox setMultiplier( float theMultiplier ) {
		_myMultiplier = theMultiplier;
		return this;
	}

	/**
	 * 
	 * @return float
	 */
	public float getMultiplier( ) {
		return _myMultiplier;
	}

	/**
	 * set the value of the numberbox.
	 * 
	 * @param theValue float
	 * @return Numberbox
	 */
	@Override
	public Numberbox setValue( float theValue ) {
		_myValue = theValue;
		_myValue = Math.max( _myMin , Math.min( _myMax , _myValue ) );
		broadcast( FLOAT );
		_myValueLabel.set( adjustValue( _myValue ) );
		return this;
	}

	/**
	 * assigns a random value to the controller.
	 * 
	 * @return Numberbox
	 */
	public Numberbox shuffle( ) {
		float r = ( float ) Math.random( );
		if ( getMax( ) != Float.MAX_VALUE && getMin( ) != -Float.MAX_VALUE ) {
			setValue( PApplet.map( r , 0 , 1 , getMin( ) , getMax( ) ) );
		}
		return this;
	}

	public Numberbox setRange( float theMin , float theMax ) {
		setMin( theMin );
		setMax( theMax );
		setValue( getValue( ) );
		return this;
	}

	/**
	 * sets the sensitivity for the scroll behavior when using the mouse wheel or the scroll
	 * function of a multi-touch track pad. The smaller the value (closer to 0) the higher the
	 * sensitivity.
	 * 
	 * @param theValue
	 * @return Numberbox
	 */
	public Numberbox setScrollSensitivity( float theValue ) {
		scrollSensitivity = theValue;
		return this;
	}

	/**
	 * changes the value of the numberbox when hovering and using the mouse wheel or the scroll
	 * function of a multi-touch track pad.
	 * 
	 * @param theRotationValue
	 * @return Numberbox
	 */
	@ControlP5.Invisible
	public Numberbox scrolled( int theRotationValue ) {
		float f = getValue( );
		f += ( _myMultiplier == 1 ) ? ( theRotationValue * scrollSensitivity ) : theRotationValue * _myMultiplier;
		setValue( f );
		return this;
	}

	/**
	 * set the direction for changing the numberbox value when dragging the mouse. by default this
	 * is up/down (VERTICAL), use setDirection(Controller.HORIZONTAL) to change to left/right or
	 * back with setDirection(Controller.VERTICAL).
	 * 
	 * @param theValue
	 */
	public Numberbox setDirection( int theValue ) {
		if ( theValue == HORIZONTAL || theValue == VERTICAL ) {
			_myNumberCount = theValue;
		} else {
			_myNumberCount = VERTICAL;
		}
		return this;
	}

	/* (non-Javadoc)
	 * 
	 * @see controlP5.Controller#update() */
	@Override
	public Numberbox update( ) {
		return setValue( _myValue );
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public Numberbox linebreak( ) {
		cp5.linebreak( this , true , autoWidth , autoHeight , autoSpacing );
		return this;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	@ControlP5.Invisible
	public Numberbox updateDisplayMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new NumberboxView( );
		case ( SPRITE ):
		case ( IMAGE ):
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	class NumberboxView implements ControllerView< Numberbox > {

		NumberboxView( ) {
			_myValueLabel.align( LEFT , CENTER ).setPadding( 0 , Label.paddingY );
			_myCaptionLabel.align( LEFT , BOTTOM_OUTSIDE ).setPadding( 0 , Label.paddingY );
		}

		public void display( PGraphics theGraphics , Numberbox theController ) {
			theGraphics.fill( color.getBackground( ) );
			theGraphics.rect( 0 , 0 , getWidth() , getHeight() );
			theGraphics.fill( ( isActive ) ? color.getActive( ) : color.getForeground( ) );
			int h = getHeight() / 2;
			theGraphics.triangle( 0 , h - 6 , 6 , h , 0 , h + 6 );
			_myValueLabel.draw( theGraphics , 10 , 0 , theController );
			_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
		}
	}

	/**
	 * @see controlP5.Numberbox#setScrollSensitivity(float)
	 * 
	 * @param theValue
	 * @return
	 */
	@Deprecated
	public Numberbox setSensitivity( float theValue ) {
		return setScrollSensitivity( theValue );
	}
}
