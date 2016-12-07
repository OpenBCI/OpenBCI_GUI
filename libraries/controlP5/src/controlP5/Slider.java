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

import processing.core.PApplet;
import processing.core.PGraphics;

/**
 * A slider is either used horizontally or vertically. when adding a slider to controlP5, the width
 * is compared against the height. if the width is bigger, you get a horizontal slider, is the
 * height bigger, you get a vertical slider. a slider can have a fixed slider handle (one end of the
 * slider is fixed to the left or bottom side of the controller), or a flexible slider handle (a
 * handle you can drag).
 * 
 * 
 * @example controllers/ControlP5slider
 */
public class Slider extends Controller< Slider > {

	public final static int FIX = 1;
	public final static int FLEXIBLE = 0;
	protected int _mySliderMode = FIX;
	protected float _myValuePosition;
	protected int _myHandleSize = 0;
	protected int _myDefaultHandleSize = 10;
	protected int triggerId = PRESSED;
	protected ArrayList< TickMark > _myTickMarks = new ArrayList< TickMark >( );
	protected boolean isShowTickMarks;
	protected boolean isSnapToTickMarks;
	protected static int autoWidth = 99;
	protected static int autoHeight = 9;
	protected float scrollSensitivity = 0.1f;
	protected int _myColorTickMark = 0xffffffff;
	private SliderView _myView;
	protected float _myMinReal = 0;
	protected float _myMaxReal = 1;
	protected float _myInternalValue = 0;

	/**
	 * Convenience constructor to extend Slider.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public Slider( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 100 , 0 , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	public Slider( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theMin , float theMax , float theDefaultValue , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );

		_myMin = 0;
		_myMax = 1;

		// with _myMinReal and _myMaxReal the range of values can now range
		// from big to small (e.g. 255 to 0) as well as from small to big (e.g. 0 to 255)
		_myMinReal = theMin;
		_myMaxReal = theMax;

		_myValue = PApplet.map( theDefaultValue , _myMinReal , _myMaxReal , 0 , 1 );

		_myCaptionLabel = new Label( cp5 , theName ).setColor( color.getCaptionLabel( ) );
		_myValueLabel = new Label( cp5 , "" + getValue( ) ).setColor( color.getValueLabel( ) );
		setSliderMode( FIX );

	}

	@ControlP5.Invisible @Override public void init( ) {
		// need to override init here since _myValue will only be a
		// normalized value here but _myDefaultValue needs to be absolute.
		// by normalizing _myValue the range of values can be from 'big-to-small'
		// as well as from 'small-to-big'
		// in order not to break anything, init() will be overwritten here.

		_myDefaultValue = getValue( );
		cp5.getControlBroadcaster( ).plug( cp5.papplet , this , _myName );
		initControllerValue( );
		isInit = cp5.isAutoInitialization;
		setValue( _myDefaultValue );
		isInit = true;
		updateDisplayMode( DEFAULT );

	}

	/**
	 * use the slider mode to set the mode of the slider bar, which can be Slider.FLEXIBLE or
	 * Slider.FIX
	 * 
	 * @param theMode
	 *            int
	 */
	public Slider setSliderMode( int theMode ) {
		_myView = ( getWidth( ) > getHeight( ) ) ? new SliderViewH( ) : new SliderViewV( );
		_myControllerView = ( getWidth( ) > getHeight( ) ) ? new SliderViewH( ) : new SliderViewV( );
		_mySliderMode = theMode;
		if ( _mySliderMode == FLEXIBLE ) {
			_myHandleSize = ( _myDefaultHandleSize >= getHeight( ) / 2 ) ? _myDefaultHandleSize / 2 : _myDefaultHandleSize;
		} else {
			_myHandleSize = 0;
		}
		_myView.updateUnit( );
		setValue( PApplet.map( _myValue , 0 , 1 , _myMinReal , _myMaxReal ) );
		return this;
	}

	public int getSliderMode( ) {
		return _mySliderMode;
	}

	/**
	 * sets the size of the Slider handle, by default it is set to either the width or height of the
	 * slider.
	 * 
	 * @param theSize
	 */
	public Slider setHandleSize( int theSize ) {
		_myDefaultHandleSize = theSize;
		setSliderMode( _mySliderMode );
		return this;
	}

	public int getHandleSize( ) {
		return _myHandleSize;
	}

	/**
	 * @see ControllerInterface.updateInternalEvents
	 * 
	 */
	@ControlP5.Invisible public Slider updateInternalEvents( PApplet theApplet ) {
		if ( isVisible ) {
			if ( isMousePressed && !cp5.isAltDown( ) ) {
				_myView.updateInternalEvents( theApplet );
			}
		}
		return this;
	}

	/**
	 * the trigger event is set to Slider.PRESSED by default but can be changed to Slider.RELEASE so
	 * that events are triggered when the slider is released.
	 * 
	 * @param theEventID
	 */
	public Slider setTriggerEvent( int theEventID ) {
		triggerId = theEventID;
		return this;
	}

	/**
	 * returns the current trigger event which is either Slider.PRESSED or Slider.RELEASE
	 * 
	 * @return int
	 */
	public int getTriggerEvent( ) {
		return triggerId;
	}

	@Override protected void mouseReleasedOutside( ) {
		mouseReleased( );
	}

	@Override protected void mouseReleased( ) {
		if ( triggerId == RELEASE ) {
			_myView.update( );
			broadcast( FLOAT );
		}
	}

	protected Slider snapValue( float theValue ) {
		if ( isSnapToTickMarks ) {
			_myValuePosition = ( ( _myValue - _myMin ) / _myUnit );
			_myView.setSnapValue( );
		}
		return this;
	}

	public float getValuePosition( ) {
		return _myValuePosition;
	}

	/**
	 * set the value of the slider.
	 * 
	 * @param theValue
	 *            float
	 */
	@Override public Slider setValue( float theValue ) {
		if ( isMousePressed && theValue == getValue( ) ) {
			return this;
		}
		_myInternalValue = theValue;
		_myValue = PApplet.map( theValue , _myMinReal , _myMaxReal , 0 , 1 );
		snapValue( _myValue );
		_myValue = ( _myValue <= _myMin ) ? _myMin : _myValue;
		_myValue = ( _myValue >= _myMax ) ? _myMax : _myValue;
		_myValuePosition = ( ( _myValue - _myMin ) / _myUnit );
		_myValueLabel.set( adjustValue( getValue( ) ) );
		if ( triggerId == PRESSED ) {
			broadcast( FLOAT );
		}
		return this;
	}

	@Override public float getValue( ) {
		return PApplet.map( _myValue , 0 , 1 , _myMinReal , _myMaxReal );
	}

	/**
	 * assigns a random value to the slider.
	 */
	public Slider shuffle( ) {
		float r = ( float ) Math.random( );
		setValue( PApplet.map( r , 0 , 1 , _myMinReal , _myMaxReal ) );
		return this;
	}

	/**
	 * sets the sensitivity for the scroll behavior when using the mouse wheel or the scroll
	 * function of a multi-touch track pad. The smaller the value (closer to 0) the higher the
	 * sensitivity. by default this value is set to 0.1
	 * 
	 * @param theValue
	 * @return Slider
	 */
	public Slider setScrollSensitivity( float theValue ) {
		scrollSensitivity = theValue;
		return this;
	}

	/**
	 * changes the value of the slider when hovering and using the mouse wheel or the scroll
	 * function of a multi-touch track pad.
	 * 
	 * @param theRotationValue
	 * @return Slider
	 */
	@ControlP5.Invisible public Slider scrolled( int theRotationValue ) {
		if ( isVisible ) {
			float f = _myValue;
			float steps = isSnapToTickMarks ? ( 1.0f / getNumberOfTickMarks( ) ) : scrollSensitivity * 0.1f;
			f += ( _myMax - _myMin ) * ( -theRotationValue * steps );
			setValue( PApplet.map( f , 0 , 1 , _myMinReal , _myMaxReal ) );
			if ( triggerId == RELEASE ) {
				broadcast( FLOAT );
			}
		}
		return this;
	}

	@Override public Slider update( ) {
		return setValue( PApplet.map( _myValue , 0 , 1 , _myMinReal , _myMaxReal ) );
	}

	/**
	 * sets the minimum value of the slider.
	 * 
	 * @param theValue
	 *            float
	 */
	@Override public Slider setMin( float theValue ) {
		float f = getValue( );
		_myMinReal = theValue;
		_myValue = PApplet.map( f , _myMinReal , _myMaxReal , 0 , 1 );
		setSliderMode( _mySliderMode );
		return this;
	}

	/**
	 * set the maximum value of the slider.
	 * 
	 * @param theValue
	 *            float
	 */
	@Override public Slider setMax( float theValue ) {
		float f = getValue( );
		_myMaxReal = theValue;
		_myValue = PApplet.map( f , _myMinReal , _myMaxReal , 0 , 1 );
		setSliderMode( _mySliderMode );
		return this;
	}

	@Override public float getMin( ) {
		return _myMinReal;
	}

	@Override public float getMax( ) {
		return _myMaxReal;
	}

	public Slider setRange( float theMin , float theMax ) {
		float f = _myInternalValue;
		_myMinReal = theMin;
		_myMaxReal = theMax;
		_myValue = PApplet.map( f , _myMinReal , _myMaxReal , 0 , 1 );
		setSliderMode( _mySliderMode );
		return this;
	}

	/**
	 * set the width of the slider.
	 * 
	 * @param theValue
	 *            int
	 */
	@Override public Slider setWidth( int theValue ) {
		super.setWidth( theValue );
		setSliderMode( _mySliderMode );
		return this;
	}

	/**
	 * set the height of the slider.
	 * 
	 * @param theValue
	 *            int
	 */
	@Override public Slider setHeight( int theValue ) {
		super.setHeight( theValue );
		setSliderMode( _mySliderMode );
		return this;
	}

	@Override public Slider setSize( int theWidth , int theHeight ) {
		super.setWidth( theWidth );
		setHeight( theHeight );
		_myView = ( getWidth( ) > getHeight( ) ) ? new SliderViewH( ) : new SliderViewV( );
		return this;
	}

	/* TODO new implementations follow: http://www.ibm.com/developerworks/java/library/j-dynui/ take
	 * interface builder as reference */
	protected Slider setTickMarks( ) {
		return this;
	}

	/**
	 * sets the number of tickmarks for a slider, by default tick marks are turned off.
	 * 
	 * @param theNumber
	 */
	public Slider setNumberOfTickMarks( int theNumber ) {
		_myTickMarks.clear( );
		if ( theNumber > 0 ) {
			for ( int i = 0 ; i < theNumber ; i++ ) {
				_myTickMarks.add( new TickMark( this ) );
			}
			showTickMarks( true );
			snapToTickMarks( true );
			setHandleSize( 20 );
		} else {
			showTickMarks( false );
			snapToTickMarks( false );
			setHandleSize( _myDefaultHandleSize );
		}
		setValue( PApplet.map( _myValue , 0 , 1 , _myMinReal , _myMaxReal ) );
		return this;
	}

	/**
	 * returns the amount of tickmarks available for a slider
	 * 
	 * @return int
	 */
	public int getNumberOfTickMarks( ) {
		return _myTickMarks.size( );
	}

	/**
	 * shows or hides tickmarks for a slider
	 * 
	 * @param theFlag
	 * @return Slider
	 */
	public Slider showTickMarks( boolean theFlag ) {
		isShowTickMarks = theFlag;
		return this;
	}

	/**
	 * enables or disables snap to tick marks.
	 * 
	 * @param theFlag
	 * @return Slider
	 */
	public Slider snapToTickMarks( boolean theFlag ) {
		isSnapToTickMarks = theFlag;
		return this;
	}

	/**
	 * returns an instance of a tickmark by index.
	 * 
	 * @see TickMark
	 * @param theIndex
	 * @return
	 */
	public TickMark getTickMark( int theIndex ) {
		if ( theIndex >= 0 && theIndex < _myTickMarks.size( ) ) {
			return _myTickMarks.get( theIndex );
		} else {
			return null;
		}
	}

	/**
	 * returns an ArrayList of available tick marks for a slider.
	 * 
	 * @return ArrayList<TickMark>
	 */
	public ArrayList< TickMark > getTickMarks( ) {
		return _myTickMarks;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public Slider linebreak( ) {
		cp5.linebreak( this , true , autoWidth , autoHeight , autoSpacing );
		return this;
	}

	/**
	 * sets the color of tick marks if enabled. by default the color is set to white.
	 * 
	 * @param theColor
	 * @return Slider
	 */
	public Slider setColorTickMark( int theColor ) {
		_myColorTickMark = theColor;
		return this;
	}

	public int getDirection( ) {
		return ( _myView instanceof SliderViewH ) ? HORIZONTAL : VERTICAL;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public Slider updateDisplayMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = ( getWidth( ) > getHeight( ) ) ? new SliderViewH( ) : new SliderViewV( );
			break;
		case ( IMAGE ):
			// TODO
			break;
		case ( SPRITE ):
			// TODO
			break;
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	private abstract class SliderView implements ControllerView< Slider > {

		abstract void updateInternalEvents( PApplet theApplet );

		abstract void update( );

		abstract void updateUnit( );

		abstract void setSnapValue( );

	}

	private class SliderViewV extends SliderView {

		SliderViewV( ) {
			_myCaptionLabel.align( LEFT , BOTTOM_OUTSIDE ).setPadding( 0 , Label.paddingY );
			_myValueLabel.set( "" + adjustValue( getValue( ) ) ).align( RIGHT_OUTSIDE , TOP );
		}

		void setSnapValue( ) {
			float n = PApplet.round( PApplet.map( _myValuePosition , 0 , getHeight( ) , 0 , _myTickMarks.size( ) - 1 ) );
			_myValue = PApplet.map( n , 0 , _myTickMarks.size( ) - 1 , _myMin , _myMax );
		}

		void updateUnit( ) {
			_myUnit = ( _myMax - _myMin ) / ( getHeight( ) - _myHandleSize );
		}

		void update( ) {
			float f = _myMin + ( - ( _myControlWindow.mouseY - ( y( _myParent.getAbsolutePosition( ) ) + y( position ) ) - getHeight( ) ) ) * _myUnit;
			setValue( PApplet.map( f , 0 , 1 , _myMinReal , _myMaxReal ) );
		}

		void updateInternalEvents( PApplet theApplet ) {
			float f = _myMin + ( - ( _myControlWindow.mouseY - ( y( _myParent.getAbsolutePosition( ) ) + y( position ) ) - getHeight( ) ) ) * _myUnit;
			setValue( PApplet.map( f , 0 , 1 , _myMinReal , _myMaxReal ) );
		}

		public void display( PGraphics theGraphics , Slider theController ) {
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.noStroke( );
			if ( ( getColor( ).getBackground( ) >> 24 & 0xff ) > 0 ) {
				theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			}
			theGraphics.fill( getIsInside( ) ? getColor( ).getActive( ) : getColor( ).getForeground( ) );
			if ( getSliderMode( ) == FIX ) {
				theGraphics.rect( 0 , getHeight( ) , getWidth( ) , -getValuePosition( ) );
			} else {
				if ( isShowTickMarks ) {
					theGraphics.triangle( getWidth( ) , getHeight( ) - getValuePosition( ) , getWidth( ) , getHeight( ) - getValuePosition( ) - getHandleSize( ) , 0 , getHeight( ) - getValuePosition( ) - getHandleSize( ) / 2 );
				} else {
					theGraphics.rect( 0 , getHeight( ) - getValuePosition( ) - getHandleSize( ) , getWidth( ) , getHandleSize( ) );
				}
			}

			if ( isLabelVisible ) {
				getCaptionLabel( ).draw( theGraphics , 0 , 0 , theController );
				theGraphics.pushMatrix( );
				theGraphics.translate( 0 , ( int ) PApplet.map( _myValue , _myMax , _myMin , 0 , getHeight( ) - _myValueLabel.getHeight( ) ) );
				getValueLabel( ).draw( theGraphics , 0 , 0 , theController );
				theGraphics.popMatrix( );
			}

			if ( isShowTickMarks ) {
				theGraphics.pushMatrix( );
				theGraphics.pushStyle( );
				theGraphics.translate( -4 , ( getSliderMode( ) == FIX ) ? 0 : getHandleSize( ) / 2 );
				theGraphics.fill( _myColorTickMark );
				float x = ( getHeight( ) - ( ( getSliderMode( ) == FIX ) ? 0 : getHandleSize( ) ) ) / ( getTickMarks( ).size( ) - 1 );
				for ( TickMark tm : getTickMarks( ) ) {
					tm.draw( theGraphics , getDirection( ) );
					theGraphics.translate( 0 , x );
				}
				theGraphics.popStyle( );
				theGraphics.popMatrix( );
			}
		}
	}

	private class SliderViewH extends SliderView {

		SliderViewH( ) {
			_myCaptionLabel.align( RIGHT_OUTSIDE , CENTER );
			_myValueLabel.set( "" + adjustValue( getValue( ) ) ).align( LEFT , CENTER );
		}

		void setSnapValue( ) {
			float n = PApplet.round( PApplet.map( _myValuePosition , 0 , getWidth( ) , 0 , _myTickMarks.size( ) - 1 ) );
			_myValue = PApplet.map( n , 0 , _myTickMarks.size( ) - 1 , _myMin , _myMax );
		}

		void updateUnit( ) {
			_myUnit = ( _myMax - _myMin ) / ( getWidth( ) - _myHandleSize );
		}

		void update( ) {
			float f = _myMin + ( _myControlWindow.mouseX - ( x( _myParent.getAbsolutePosition( ) ) + x( position ) ) ) * _myUnit;
			setValue( PApplet.map( f , 0 , 1 , _myMinReal , _myMaxReal ) );
		}

		void updateInternalEvents( PApplet theApplet ) {
			float f = _myMin + ( _myControlWindow.mouseX - ( x( _myParent.getAbsolutePosition( ) ) + x( position ) ) ) * _myUnit;
			setValue( PApplet.map( f , 0 , 1 , _myMinReal , _myMaxReal ) );
		}

		public void display( PGraphics theGraphics , Slider theController ) {
			theGraphics.fill( getColor( ).getBackground( ) );
			theGraphics.noStroke( );
			if ( ( getColor( ).getBackground( ) >> 24 & 0xff ) > 0 ) {
				theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			}
			theGraphics.fill( getIsInside( ) ? getColor( ).getActive( ) : getColor( ).getForeground( ) );
			if ( getSliderMode( ) == FIX ) {
				theGraphics.rect( 0 , 0 , getValuePosition( ) , getHeight( ) );
			} else {
				if ( isShowTickMarks ) {
					theGraphics.triangle( getValuePosition( ) , 0 , getValuePosition( ) + getHandleSize( ) , 0 , getValuePosition( ) + _myHandleSize / 2 , getHeight( ) );
				} else {
					theGraphics.rect( getValuePosition( ) , 0 , getHandleSize( ) , getHeight( ) );
				}

			}
			theGraphics.fill( 255 );

			if ( isLabelVisible ) {
				getValueLabel( ).draw( theGraphics , 0 , 0 , theController );
				getCaptionLabel( ).draw( theGraphics , 0 , 0 , theController );
			}

			if ( isShowTickMarks ) {
				theGraphics.pushMatrix( );
				//				theGraphics.pushStyle( );
				theGraphics.translate( ( getSliderMode( ) == FIX ) ? 0 : getHandleSize( ) / 2 , getHeight( ) );
				theGraphics.fill( _myColorTickMark );
				theGraphics.noStroke( );
				float x = ( getWidth( ) - ( ( getSliderMode( ) == FIX ) ? 0 : getHandleSize( ) ) ) / ( getTickMarks( ).size( ) - 1 );
				for ( TickMark tm : getTickMarks( ) ) {
					tm.draw( theGraphics , getDirection( ) );
					theGraphics.translate( x , 0 );
				}
				//				theGraphics.popStyle( );
				theGraphics.popMatrix( );
			}
		}
	}

	@Deprecated public void setSliderBarSize( int theSize ) {
		_myDefaultHandleSize = theSize;
		setSliderMode( _mySliderMode );
	}

	/**
	 * @see controlP5.Slider#setScrollSensitivity(float)
	 * 
	 * @param theValue
	 * @return Slider
	 */
	@Deprecated public Slider setSensitivity( float theValue ) {
		return setScrollSensitivity( theValue );
	}

}
