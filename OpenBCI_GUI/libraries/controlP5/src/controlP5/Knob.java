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
 * A knob is a circular slider which can be used with a limited and unlimited range. Knobs come in 3
 * designs LINE, ARC and ELLIPSE and can be controller with both the mouse and the mouse wheel.
 * 
 * @example controllers/ControlP5knob
 */
public class Knob extends Controller< Knob > {

	protected float _myDiameter;
	protected float _myRadius;
	protected float myAngle;
	protected float startAngle;
	protected float angleRange;
	protected float resolution = 200.0f; // sensitivity.
	protected int _myTickMarksNum = 8;
	protected boolean isShowTickMarks;
	protected boolean isSnapToTickMarks;
	protected int myTickMarkLength = 2;
	protected float myTickMarkWeight = 1;
	protected boolean isShowAngleRange = true;
	protected float currentValue;
	protected float previousValue;
	protected float modifiedValue;
	protected boolean isConstrained;
	protected int _myDragDirection = HORIZONTAL;
	protected int viewStyle = LINE;
	public static int autoWidth = 39;
	public static int autoHeight = 39;
	protected float[] autoSpacing = new float[] { 10 , 20 };

	private float scrollSensitivity = 1.0f / resolution;

	/**
	 * Convenience constructor to extend Knob.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public Knob( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 100 , 0 , 0 , 0 , autoWidth );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	/**
	 * @exclude
	 */
	public Knob( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theMin , float theMax , float theDefaultValue , int theX , int theY , int theWidth ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theWidth );
		_myValue = theDefaultValue;
		setMin( theMin );
		setMax( theMax );
		_myDiameter = theWidth;
		_myRadius = _myDiameter / 2;
		_myUnit = ( _myMax - _myMin ) / ControlP5Constants.TWO_PI;
		startAngle = HALF_PI + PI * 0.25f;
		angleRange = PI + HALF_PI;
		myAngle = startAngle;
		isConstrained = true;
		getCaptionLabel( ).align( CENTER , BOTTOM_OUTSIDE );
		setViewStyle( ARC );
	}

	@Override public Knob setSize( int theWidth , int theHeight ) {
		return setRadius( theWidth / 2 );
	}

	public Knob setRadius( float theValue ) {
		_myRadius = theValue;
		_myDiameter = _myRadius * 2;
		setWidth( ( int ) _myDiameter );
		setHeight( ( int ) _myDiameter );
		return this;
	}

	public float getRadius( ) {
		return _myRadius;
	}

	/**
	 * The start angle is a value between 0 and TWO_PI. By default the start angle is set to HALF_PI
	 * + PI * 0.25f
	 */
	public Knob setStartAngle( float theAngle ) {
		startAngle = theAngle;
		setInternalValue( modifiedValue );
		return this;
	}

	/**
	 * get the start angle, 0 is at 3 o'clock.
	 */
	public float getStartAngle( ) {
		return startAngle;
	}

	/**
	 * set the range in between which the know operates. By default the range is PI + HALF_PI
	 */
	public Knob setAngleRange( float theRange ) {
		angleRange = theRange;
		setInternalValue( modifiedValue );
		return this;
	}

	public float getAngleRange( ) {
		return angleRange;
	}

	public float getAngle( ) {
		return myAngle;
	}

	public boolean isShowAngleRange( ) {
		return isShowAngleRange;
	}

	public Knob setShowAngleRange( boolean theValue ) {
		isShowAngleRange = theValue;
		return this;
	}

	/**
	 * Sets the drag direction, when controlling a knob, parameter is either Controller.HORIZONTAL
	 * or Controller.VERTICAL.
	 * 
	 * @param theValue
	 *            must be Controller.HORIZONTAL or Controller.VERTICAL
	 * @return Knob
	 */
	public Knob setDragDirection( int theValue ) {
		if ( theValue == HORIZONTAL ) {
			_myDragDirection = HORIZONTAL;
		} else {
			_myDragDirection = VERTICAL;
		}
		return this;
	}

	/**
	 * Gets the drag direction which is either Controller.HORIZONTAL or Controller.VERTICAL.
	 * 
	 * @return int returns Controller.HORIZONTAL or Controller.VERTICAL
	 */
	public int getDragDirection( ) {
		return _myDragDirection;
	}

	/**
	 * resolution is a sensitivity value when dragging a knob. the higher the value, the more
	 * sensitive the dragging.
	 */
	public Knob setResolution( float theValue ) {
		resolution = theValue;
		return this;
	}

	public float getResolution( ) {
		return resolution;
	}

	public Knob setNumberOfTickMarks( int theNumber ) {
		_myTickMarksNum = theNumber;
		showTickMarks( );
		return this;
	}

	public int getNumberOfTickMarks( ) {
		return _myTickMarksNum;
	}

	public Knob showTickMarks( ) {
		isShowTickMarks = true;
		return this;
	}

	public Knob hideTickMarks( ) {
		isShowTickMarks = false;
		return this;
	}

	public boolean isShowTickMarks( ) {
		return isShowTickMarks;
	}

	public Knob snapToTickMarks( boolean theFlag ) {
		isSnapToTickMarks = theFlag;
		update( );
		return this;
	}

	public Knob setTickMarkLength( int theLength ) {
		myTickMarkLength = theLength;
		return this;
	}

	public int getTickMarkLength( ) {
		return myTickMarkLength;
	}

	public Knob setTickMarkWeight( float theWeight ) {
		myTickMarkWeight = theWeight;
		return this;
	}

	public float getTickMarkWeight( ) {
		return myTickMarkWeight;
	}

	public Knob setConstrained( boolean theValue ) {
		isConstrained = theValue;
		if ( !isConstrained ) {
			setShowAngleRange( false );
		} else {
			setShowAngleRange( true );
		}
		return this;
	}

	public boolean isConstrained( ) {
		return isConstrained;
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public Knob updateInternalEvents( PApplet theApplet ) {
		if ( isMousePressed && !cp5.isAltDown( ) ) {
			if ( isActive ) {
				float c = ( _myDragDirection == HORIZONTAL ) ? _myControlWindow.mouseX - _myControlWindow.pmouseX : _myControlWindow.mouseY - _myControlWindow.pmouseY;
				currentValue += ( c ) / resolution;
				if ( isConstrained ) {
					currentValue = PApplet.constrain( currentValue , 0 , 1 );
				}
				setInternalValue( currentValue );
			}
		}
		return this;
	}

	protected void onEnter( ) {
		isActive = true;
	}

	protected void onLeave( ) {
		isActive = false;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public void mousePressed( ) {
		float x = x(_myParent.getAbsolutePosition( )) + x(position) + _myRadius;
		float y = y(_myParent.getAbsolutePosition( )) + y(position) + _myRadius;
		if ( PApplet.dist( x , y , _myControlWindow.mouseX , _myControlWindow.mouseY ) < _myRadius ) {
			isActive = true;
			if ( PApplet.dist( x , y , _myControlWindow.mouseX , _myControlWindow.mouseY ) > ( _myRadius * 0.6 ) ) {
				myAngle = ( PApplet.atan2( _myControlWindow.mouseY - y , _myControlWindow.mouseX - x ) - startAngle );
				if ( myAngle < 0 ) {
					myAngle = TWO_PI + myAngle;
				}
				if ( isConstrained ) {
					myAngle %= TWO_PI;
				}
				currentValue = PApplet.map( myAngle , 0 , angleRange , 0 , 1 );
				setInternalValue( currentValue );

			}
		}
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public void mouseReleasedOutside( ) {
		isActive = false;
	}

	@Override public Knob setMin( float theValue ) {
		_myMin = theValue;
		return this;
	}

	@Override public Knob setMax( float theValue ) {
		_myMax = theValue;
		return this;
	}

	public Knob setRange( float theMin , float theMax ) {
		setMin( theMin );
		setMax( theMax );
		update( );
		return this;
	}

	protected void setInternalValue( float theValue ) {
		modifiedValue = ( isSnapToTickMarks ) ? PApplet.round( ( theValue * _myTickMarksNum ) ) / ( ( float ) _myTickMarksNum ) : theValue;
		currentValue = theValue;
		myAngle = PApplet.map( isSnapToTickMarks == true ? modifiedValue : currentValue , 0 , 1 , startAngle , startAngle + angleRange );

		if ( isSnapToTickMarks ) {
			if ( previousValue != modifiedValue && isSnapToTickMarks ) {
				broadcast( FLOAT );
				_myValueLabel.set( adjustValue( getValue( ) ) );
				previousValue = modifiedValue;
				return;
			}
		}
		if ( previousValue != currentValue ) {
			broadcast( FLOAT );
			_myValueLabel.set( adjustValue( getValue( ) ) );
			previousValue = modifiedValue;
		}
	}

	@Override public Knob setValue( float theValue ) {
		theValue = PApplet.map( theValue , _myMin , _myMax , 0 , 1 );
		if ( isConstrained ) {
			theValue = PApplet.constrain( theValue , 0 , 1 );
		}
		_myValueLabel.set( adjustValue( getValue( ) ) );
		setInternalValue( theValue );
		return this;
	}

	@Override public float getValue( ) {
		_myValue = PApplet.map( _myTickMarksNum > 0 ? modifiedValue : currentValue , 0 , 1 , _myMin , _myMax );
		return _myValue;
	}

	/**
	 * Assigns a random value to the controller.
	 */
	public Knob shuffle( ) {
		float r = ( float ) Math.random( );
		setValue( PApplet.map( r , 0 , 1 , getMin( ) , getMax( ) ) );
		return this;
	}

	/**
	 * Sets the sensitivity for the scroll behavior when using the mouse wheel or the scroll
	 * function of a multi-touch track pad. The smaller the value (closer to 0) the higher the
	 * sensitivity.
	 * 
	 * @param theValue
	 * @return Knob
	 */
	public Knob setScrollSensitivity( float theValue ) {
		scrollSensitivity = theValue;
		return this;
	}

	/**
	 * Changes the value of the knob when hovering and using the mouse wheel or the scroll function
	 * of a multi-touch track pad.
	 */
	@ControlP5.Invisible public Knob scrolled( int theRotationValue ) {
		float f = getValue( );
		float steps = isSnapToTickMarks ? ( 1.0f / getNumberOfTickMarks( ) ) : scrollSensitivity;
		f += ( getMax( ) - getMin( ) ) * ( -theRotationValue * steps );
		setValue( f );
		return this;
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public Knob update( ) {
		setValue( _myValue );
		return this;
	}

	/**
	 * set the display style of a knob. takes parameters Knob.LINE, Knob.ELLIPSE or Knob.ARC.
	 * default style is Knob.LINE
	 * 
	 * @param theStyle
	 *            use Knob.LINE, Knob.ELLIPSE or Knob.ARC
	 * @return Knob
	 */
	public Knob setViewStyle( int theStyle ) {
		viewStyle = theStyle;
		return this;
	}

	public int getViewStyle( ) {
		return viewStyle;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public Knob updateDisplayMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new KnobView( );
			break;
		case ( SPRITE ):
		case ( IMAGE ):
			_myControllerView = new KnobView( );
			break;
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	class KnobView implements ControllerView< Knob > {

		public void display( PGraphics theGraphics , Knob theController ) {
			theGraphics.translate( ( int ) getRadius( ) , ( int ) getRadius( ) );

			theGraphics.pushMatrix( );
			theGraphics.ellipseMode( PApplet.CENTER );
			theGraphics.noStroke( );
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.ellipse( 0 , 0 , getRadius( ) * 2 , getRadius( ) * 2 );
			theGraphics.popMatrix( );
			int c = isActive( ) ? getColor( ).getActive( ) : getColor( ).getForeground( );
			theGraphics.pushMatrix( );
			if ( getViewStyle( ) == Controller.LINE ) {
				theGraphics.rotate( getAngle( ) );
				theGraphics.stroke( c );
				theGraphics.strokeWeight( getTickMarkWeight( ) );
				theGraphics.line( 0 , 0 , getRadius( ) , 0 );
			} else if ( getViewStyle( ) == Controller.ELLIPSE ) {
				theGraphics.rotate( getAngle( ) );
				theGraphics.fill( c );
				theGraphics.ellipse( getRadius( ) * 0.75f , 0 , getRadius( ) * 0.2f , getRadius( ) * 0.2f );
			} else if ( getViewStyle( ) == Controller.ARC ) {
				theGraphics.fill( c );
				theGraphics.arc( 0 , 0 , getRadius( ) * 1.8f , getRadius( ) * 1.8f , getStartAngle( ) , getAngle( ) + ( ( getStartAngle( ) == getAngle( ) ) ? 0.06f : 0f ) );
				theGraphics.fill( theGraphics.red( getColor( ).getBackground( ) ) , theGraphics.green( getColor( ).getBackground( ) ) , theGraphics.blue( getColor( ).getBackground( ) ) , 255 );
				theGraphics.ellipse( 0 , 0 , getRadius( ) * 1.2f , getRadius( ) * 1.2f );
			}
			theGraphics.popMatrix( );

			theGraphics.pushMatrix( );
			theGraphics.rotate( getStartAngle( ) );

			if ( isShowTickMarks( ) ) {
				float step = getAngleRange( ) / getNumberOfTickMarks( );
				theGraphics.stroke( getColor( ).getForeground( ) );
				theGraphics.strokeWeight( getTickMarkWeight( ) );
				for ( int i = 0 ; i <= getNumberOfTickMarks( ) ; i++ ) {
					theGraphics.line( getRadius( ) + 2 , 0 , getRadius( ) + getTickMarkLength( ) + 2 , 0 );
					theGraphics.rotate( step );
				}
			} else {
				if ( isShowAngleRange( ) ) {
					theGraphics.stroke( getColor( ).getForeground( ) );
					theGraphics.strokeWeight( getTickMarkWeight( ) );
					theGraphics.line( getRadius( ) + 2 , 0 , getRadius( ) + getTickMarkLength( ) + 2 , 0 );
					theGraphics.rotate( getAngleRange( ) );
					theGraphics.line( getRadius( ) + 2 , 0 , getRadius( ) + getTickMarkLength( ) + 2 , 0 );
				}
			}
			theGraphics.noStroke( );
			theGraphics.popMatrix( );

			theGraphics.pushMatrix( );
			theGraphics.translate( -getWidth( ) / 2 , -getHeight( ) / 2 );
			if ( isLabelVisible ) {
				_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
				_myValueLabel.align( ControlP5.CENTER , ControlP5.CENTER );
				_myValueLabel.draw( theGraphics , 0 , 0 , theController );
			}
			theGraphics.popMatrix( );

		}
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public Knob setOffsetAngle( float theValue ) {
		return setStartAngle( theValue );
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public float value( ) {
		return getValue( );
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public Knob setDisplayStyle( int theStyle ) {
		viewStyle = theStyle;
		return this;
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public int getDisplayStyle( ) {
		return viewStyle;
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated @ControlP5.Invisible public Knob setSensitivity( float theValue ) {
		scrollSensitivity = theValue;
		return this;
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public Knob showTickMarks( boolean theFlag ) {
		isShowTickMarks = theFlag;
		return this;
	}

}
/* settings for:
 * 
 * TODO tickmarks: distance from edge
 * 
 * TODO only start-end marks if isLimited and tickmarks are off.
 * 
 * TODO arc: add setter for distance to center + distance to edge currently percental.
 * 
 * TODO enable/disable drag and click control (for endless, click should be disabled).
 * 
 * TODO dragging: add another option to control the knob. currently only linear dragging is
 * implemented, add circular dragging (as before) as well */

/* (non-Javadoc)
 * 
 * @see controlP5.Controller#updateInternalEvents(processing.core.PApplet) */
