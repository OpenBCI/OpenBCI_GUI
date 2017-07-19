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

import java.util.HashMap;
import java.util.Map;

import processing.core.PApplet;
import processing.core.PGraphics;

/**
 * A tooltip can be registered for individual controllers
 * and is activated on rollover.
 * 
 * @example controllers/ControlP5tooltip
 * 
 */
public class Tooltip {

	private ControllerView< ? > _myView;
	private float[] position = new float[3];
	private float[] currentPosition = new float[3];
	private float[] previousPosition = new float[3];
	private float[] offset = new float[3];
	private Controller< ? > _myController;
	private long startTime = 0;
	private long _myDelayInMillis = 500;
	private int _myMode = ControlP5.INACTIVE;
	private int _myHeight = 20;
	private int _myBackgroundColor = 0xffffffb4;
	private int _myMaxAlpha = 255;
	private int _myAlpha = 0;
	private Map< Controller< ? > , String > map;
	private Label _myLabel;
	private boolean enabled = true;
	private int _myBorder;
	private ControlP5 cp5;
	private int _myAlignH = ControlP5.RIGHT;
	private int _myColor = 0x00000000;

	Tooltip( ControlP5 theControlP5 ) {
		cp5 = theControlP5;
		position[0] = -1000;
		position[1] = -1000;
		currentPosition = new float[3];
		previousPosition = new float[3];
		offset = new float[] { 0 , 24 , 0 };
		map = new HashMap< Controller< ? > , String >( );
		_myLabel = new Label( cp5 , "tooltip" );
		_myLabel.setColor( _myColor );
		_myLabel.setPadding( 0 , 0 );
		setView( new TooltipView( ) );
		setBorder( 4 );
	}

	/**
	 * sets the border of the tooltip, the default border is
	 * 4px.
	 * 
	 * @param theValue
	 * @return Tooltip
	 */
	public Tooltip setBorder( int theValue ) {
		_myBorder = theValue;
		_myLabel.getStyle( ).setMargin( _myBorder , _myBorder , _myBorder , _myBorder );
		return this;
	}

	/**
	 * returns the value of the border
	 * 
	 * @return
	 */
	public int getBorder( ) {
		return _myBorder;
	}

	/**
	 * sets the transparency of the default background,
	 * default value is 200
	 * 
	 * @param theValue
	 * @return Tooltip
	 */
	public Tooltip setAlpha( int theValue ) {
		_myMaxAlpha = theValue;
		return this;
	}

	private void updateText( String theText ) {
		int n = 1;
		for ( char c : theText.toCharArray( ) ) {
			if ( c == '\n' ) {
				n++;
			}
		}
		if ( _myLabel.getHeight( ) != _myLabel.getLineHeight( ) * n ) {
			_myLabel.setHeight( _myLabel.getLineHeight( ) * n );
		}
		_myLabel.set( theText );
	}

	/**
	 * TODO see below
	 * @param theWindow
	 */
	void draw( ControlWindow theWindow ) {
		// TODO re-implement Tooltip
	}

	private boolean moved( ) {
		return PApplet.abs( PApplet.dist( previousPosition[0] , previousPosition[1] , currentPosition[0] , currentPosition[1] ) ) > 1;
	}

	/**
	 * A tooltip is activated when entered by the mouse,
	 * after a given delay time the Tooltip starts to fade
	 * in. Use setDelay(long) to adjust the default delay
	 * time of 1000 millis.
	 * 
	 * @param theMillis
	 * @return Tooltip
	 */
	public Tooltip setDelay( long theMillis ) {
		_myDelayInMillis = theMillis;
		return this;
	}

	/**
	 * a Tooltip is activated when the mouse enters a
	 * controller.
	 * 
	 * @param theController
	 */
	protected void activate( Controller< ? > theController ) {
		if ( map.containsKey( theController ) ) {
			startTime = System.nanoTime( );
			_myController = theController;
			currentPosition[0] = theController.getControlWindow( ).mouseX;
			currentPosition[1] = theController.getControlWindow( ).mouseY;
			updateText( map.get( _myController ) );
			_myMode = ControlP5.WAIT;
		}
	}

	protected void deactivate( ) {
		deactivate( 1 );
	}

	protected void deactivate( int theNum ) {
		if ( theNum == 0 ) {
			if ( _myMode >= ControlP5.IDLE ) {
				if ( _myMode < ControlP5.FADEOUT )
					startTime = System.nanoTime( );
				_myMode = ControlP5.FADEOUT;
			}
		} else {
			_myMode = ( _myMode >= ControlP5.IDLE ) ? ControlP5.FADEOUT : ControlP5.DONE;
		}
	}

	/**
	 * A custom view can be set for a Tooltip. The default
	 * view class can be found at the bottom of the Tooltip
	 * source.
	 * 
	 * @see controlP5.ControllerView
	 * @param theDisplay
	 * @return Tooltip
	 */
	public Tooltip setView( ControllerView< ? > theDisplay ) {
		_myView = theDisplay;
		return this;
	}

	/**
	 * registers a controller with the Tooltip, when
	 * activating the tooltip for a particular controller,
	 * the registered text (second parameter) will be
	 * displayed.
	 * 
	 * @param theController
	 * @param theText
	 * @return Tooltip
	 */
	public Tooltip register( Controller< ? > theController , String theText ) {
		map.put( theController , theText );
		theController.registerProperty( "setTooltipEnabled" , "isTooltipEnabled" );
		return this;
	}

	public Tooltip register( String theControllerName , String theText ) {
		Controller< ? > c = cp5.getController( theControllerName );
		if ( c == null ) {
			return this;
		}
		map.put( c , theText );
		c.registerProperty( "setTooltipEnabled" , "isTooltipEnabled" );
		return this;
	}

	/**
	 * removes a controller from the tooltip
	 * 
	 * @param theController
	 * @return Tooltip
	 */
	public Tooltip unregister( Controller< ? > theController ) {
		map.remove( theController );
		theController.removeProperty( "setTooltipEnabled" , "isTooltipEnabled" );
		return this;
	}

	public Tooltip unregister( String theControllerName ) {
		Controller< ? > c = cp5.getController( theControllerName );
		if ( c == null ) {
			return this;
		}
		return unregister( c );
	}

	/**
	 * with the default display, the width of the tooltip is
	 * set automatically, therefore setWidth() does not have
	 * any effect without changing the default display to a
	 * custom ControllerView.
	 * 
	 * @see controlP5.ControllerView
	 * @see controlP5.Tooltip#setDisplay(ControllerView)
	 * @return Tooltip
	 */
	public Tooltip setWidth( int theWidth ) {
		// TODO
		// _myWidth = theWidth;
		return this;
	}

	public int getWidth( ) {
		return _myLabel.getWidth( );
	}

	/**
	 * @see controlP5.Tooltip#setWidth(int)
	 * @param theHeight
	 * @return Tooltip
	 */
	public Tooltip setHeight( int theHeight ) {
		ControlP5.logger( ).warning( "Tooltip.setHeight is disabled with this version" );
		_myHeight = theHeight;
		return this;
	}

	/**
	 * adds an offset to the position of the controller
	 * relative to the mouse cursor's position. default
	 * offset is (10,20)
	 * 
	 * @param theX
	 * @param theY
	 * @return Tooltip
	 */
	public Tooltip setPositionOffset( float theX , float theY ) {
		offset[0] = theX;
		offset[1] = theY;
		return this;
	}

	/**
	 * disables the Tooltip on a global level, when
	 * disabled, tooltip will not respond to any registered
	 * controller. to disable a tooltip for aparticular
	 * controller, used unregister(Controller)
	 * 
	 * @see controlP5.Tooltip#unregister(Controller)
	 * @return Tooltip
	 */
	public Tooltip disable( ) {
		enabled = false;
		return this;
	}

	/**
	 * in case the tooltip is disabled, use enable() to turn
	 * the tooltip back on.
	 * 
	 * @return Tooltip
	 */
	public Tooltip enable( ) {
		enabled = true;
		return this;
	}

	/**
	 * check if the tooltip is enabled or disabled
	 * 
	 * @return boolean
	 */
	public boolean isEnabled( ) {
		return enabled;
	}

	/**
	 * sets the Label to a custom label and replaces the
	 * default label.
	 * 
	 * @param theLabel
	 * @return Tooltip
	 */
	public Tooltip setLabel( Label theLabel ) {
		_myLabel = theLabel;
		return this;
	}

	/**
	 * returns the current Label
	 * 
	 * @return Label
	 */
	public Label getLabel( ) {
		return _myLabel;
	}

	/**
	 * sets the background color of the tooltip, the default
	 * color is a dark grey
	 * 
	 * @param theColor
	 * @return Tooltip
	 */
	public Tooltip setColorBackground( int theColor ) {
		_myBackgroundColor = theColor;
		return this;
	}

	/**
	 * sets the text color of the tooltip's label, the
	 * default color is a white
	 * 
	 * @param theColor
	 * @return Tooltip
	 */
	public Tooltip setColorLabel( int theColor ) {
		_myColor = theColor;
		_myLabel.setColor( theColor );
		return this;
	}

	class TooltipView implements ControllerView< Controller< ? >> {

		public void display( PGraphics theGraphics , Controller< ? > theController ) {
			_myHeight = _myLabel.getHeight( );
			theGraphics.fill( _myBackgroundColor , _myAlpha );
			theGraphics.rect( 0 , 0 , getWidth( ) + _myBorder * 2 , _myHeight + _myBorder * 2 );
			theGraphics.pushMatrix( );
			if ( _myAlignH == ControlP5.RIGHT ) {
				theGraphics.translate( 6 , 0 );
			} else {
				theGraphics.translate( getWidth( ) - 6 , 0 );
			}
			theGraphics.triangle( 0 , 0 , 4 , -4 , 8 , 0 );
			theGraphics.popMatrix( );
			int a = ( int ) ( PApplet.map( _myAlpha , 0 , _myMaxAlpha , 0 , 255 ) );
			_myLabel.setColor( a << 24 | ( _myColor >> 16 ) << 16 | ( _myColor >> 8 ) << 8 | ( _myColor >> 0 ) << 0 );
			_myLabel.draw( theGraphics , 0 , 0 , theController );
		}
	}
}
