package controlP5;

import java.util.HashMap;
import java.util.Map;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

/**
 * A tooltip can be registered for individual controllers
 * and is activated on rollover.
 * 
 * @example controllers/ControlP5tooltip
 * 
 */
public class Tooltip {

	private ControllerView< ? > _myView;
	private PVector position = new PVector( );
	private PVector currentPosition = new PVector( );
	private PVector previousPosition = new PVector( );
	private PVector offset = new PVector( );
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
		position = new PVector( -1000 , -1000 );
		currentPosition = new PVector( );
		previousPosition = new PVector( );
		offset = new PVector( 0 , 24 , 0 );
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
		/*
		if ( enabled ) {

			if ( _myMode >= ControlP5.WAIT ) {

				previousPosition.set( currentPosition );
				currentPosition.set( theWindow.mouseX , theWindow.mouseY , 0 );

				if ( _myController != null ) {
					if ( _myController.getControlWindow( ).equals( theWindow ) ) {
						switch ( _myMode ) {
						case ( ControlP5.WAIT ):
							if ( moved( ) ) {
								startTime = System.nanoTime( );
							}

							if ( System.nanoTime( ) > startTime + ( _myDelayInMillis * 1000000 ) ) {

								position.set( currentPosition );
								_myAlignH = ControlP5.RIGHT;
								if ( position.x > ( _myController.getControlWindow( ).papplet( ).width - ( getWidth( ) + 20 ) ) ) {
									position.sub( new PVector( getWidth( ) , 0 , 0 ) );
									_myAlignH = ControlP5.LEFT;
								}
								_myMode = ControlP5.FADEIN;
								startTime = System.nanoTime( );
								_myAlpha = 0;
							}
							break;
						case ( ControlP5.FADEIN ):
							float t1 = System.nanoTime( ) - startTime;
							_myAlpha = ( int ) PApplet.map( t1 , 0 , 200 * 1000000 , 0 , _myMaxAlpha );
							if ( _myAlpha >= 250 ) {
								_myMode = ControlP5.IDLE;
								_myAlpha = 255;
							}
							break;
						case ( ControlP5.IDLE ):
							break;
						case ( ControlP5.FADEOUT ):
							float t2 = System.nanoTime( ) - startTime;
							_myAlpha = ( int ) PApplet.map( t2 , 0 , 200 * 1000000 , _myMaxAlpha , 0 );
							if ( _myAlpha <= 0 ) {
								_myMode = ControlP5.DONE;
							}
							break;
						case ( ControlP5.DONE ):
							_myController = null;
							_myMode = ControlP5.INACTIVE;
							position.set( -1000 , -1000 , 0 );
						}

						_myAlpha = PApplet.max( 0 , PApplet.min( _myAlpha , _myMaxAlpha ) );

						if ( _myMode >= ControlP5.WAIT ) {
							_myAlpha = ( _myMode == ControlP5.WAIT ) ? 0 : _myAlpha;
							theWindow.papplet( ).pushMatrix( );
							theWindow.papplet( ).translate( position.x , position.y );
							theWindow.papplet( ).translate( offset.x , offset.y );
							// TODO should request the current PGraphics element, not only the PApplet context. What if we render into a PGraphics buffer?
							_myView.display( theWindow.papplet( ).g , null );
							theWindow.papplet( ).popMatrix( );
						}
						if ( _myMode < ControlP5.FADEOUT ) {
							if ( moved( ) ) {
								deactivate( 0 );
							}
						}
					}
				}
			}
		}
		*/
	}

	private boolean moved( ) {
		return PApplet.abs( PApplet.dist( previousPosition.x , previousPosition.y , currentPosition.x , currentPosition.y ) ) > 1;
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
			currentPosition.set( theController.getControlWindow( ).mouseX , theController.getControlWindow( ).mouseY , 0 );
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
		offset.x = theX;
		offset.y = theY;
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
