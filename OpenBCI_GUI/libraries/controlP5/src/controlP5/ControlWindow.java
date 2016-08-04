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
 * @modified 04/14/2016
 * @version 2.2.6
 *
 */

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import controlP5.ControlP5Base.KeyCode;

// TODO ! add mouse-button mask for left, center, right; also see Controller #mouse-button ^1

/**
 * @example controllers/ControlP5window
 */
public final class ControlWindow {

	protected ControlP5 cp5;
	protected Controller< ? > isControllerActive;
	public int background = 0x00000000;
	protected CColor color = new CColor( );
	private String _myName = "main";
	protected PApplet _myApplet;
	protected ControllerList _myTabs;
	protected boolean isVisible = true;
	protected boolean isInit = false;
	protected boolean isRemove = false;
	protected CDrawable _myDrawable;
	protected boolean isAutoDraw;
	protected boolean isUpdate;
	protected List< Canvas > _myCanvas;
	protected boolean isDrawBackground = true;
	protected boolean isUndecorated = false;
	protected float[] autoPosition = new float[]{ 10 , 30 , 0 };
	protected float tempAutoPositionHeight = 0;
	protected boolean rendererNotification = false;
	protected float[] positionOfTabs = new float[]{ 0 , 0 , 0 };
	private int _myFrameCount = 0;
	private boolean isMouse = true;
	private Pointer _myPointer;
	private int mouseWheelMoved = 0;
	private List< ControllerInterface< ? >> mouseoverlist;
	private boolean isMouseOver;
	protected int mouseX;
	protected int mouseY;
	protected int pmouseX;
	protected int pmouseY;
	protected boolean mousePressed;
	protected long mousePressedTime;
	protected long pmousePressedTime;
	protected boolean mouselock;
	protected char key;
	protected int keyCode;
	private final int numKeys = 1024;
	private boolean[] keys = new boolean[ numKeys ];
	private int numOfActiveKeys = 0;
	private boolean focused = true;

	/**
	 * @exclude
	 */
	public ControlWindow( final ControlP5 theControlP5 , final PApplet theApplet ) {
		mouseoverlist = new ArrayList< ControllerInterface< ? >>( );
		cp5 = theControlP5;
		_myApplet = theApplet;
		isAutoDraw = true;
		init( );
	}

	protected void init( ) {

		_myPointer = new Pointer( );
		_myCanvas = new ArrayList< Canvas >( );
		_myTabs = new ControllerList( );
		_myTabs.add( new Tab( cp5 , this , "global" ) );
		_myTabs.add( new Tab( cp5 , this , "default" ) );
		activateTab( ( Tab ) _myTabs.get( 1 ) );

		/* register a post event that will be called by
		 * processing after the draw method has been
		 * finished. */

		// processing pre 2.0 will not draw automatically if
		// in P3D mode. in earlier versions of
		// controlP5 this had been checked here and the user
		// had been informed to draw controlP5
		// manually by adding cp5.draw() to the sketch's
		// draw function. with processing 2.0 and this
		// version of controlP5 this notification does no
		// longer exist.

		if ( isInit == false ) {
			_myApplet.registerMethod( "pre" , this );
			_myApplet.registerMethod( "draw" , this );
			if ( !cp5.isAndroid ) {
				_myApplet.registerMethod( "keyEvent" , this );
				_myApplet.registerMethod( "mouseEvent" , this );
			}
		}

		mousePressedTime = System.currentTimeMillis( );
		pmousePressedTime = System.currentTimeMillis( );

		isInit = true;
	}

	public Tab getCurrentTab( ) {
		for ( int i = 1 ; i < _myTabs.size( ) ; i++ ) {
			if ( ( ( Tab ) _myTabs.get( i ) ).isActive( ) ) {
				return ( Tab ) _myTabs.get( i );
			}
		}
		return null;
	}

	public ControlWindow activateTab( String theTab ) {

		for ( int i = 1 ; i < _myTabs.size( ) ; i++ ) {
			if ( ( ( Tab ) _myTabs.get( i ) ).getName( ).equals( theTab ) ) {
				if ( ! ( ( Tab ) _myTabs.get( i ) ).isActive ) {
					resetMouseOver( );
				}
				activateTab( ( Tab ) _myTabs.get( i ) );
			}
		}
		return this;
	}

	public ControlWindow removeTab( Tab theTab ) {
		_myTabs.remove( theTab );
		return this;
	}

	public Tab add( Tab theTab ) {
		_myTabs.add( theTab );
		return theTab;
	}

	public Tab addTab( String theTab ) {
		return getTab( theTab );
	}

	protected ControlWindow activateTab( Tab theTab ) {
		for ( int i = 1 ; i < _myTabs.size( ) ; i++ ) {
			if ( _myTabs.get( i ) == theTab ) {
				if ( ! ( ( Tab ) _myTabs.get( i ) ).isActive ) {
					resetMouseOver( );
				}
				( ( Tab ) _myTabs.get( i ) ).setActive( true );
			} else {
				( ( Tab ) _myTabs.get( i ) ).setActive( false );
			}
		}
		return this;
	}

	public ControllerList getTabs( ) {
		return _myTabs;
	}

	public Tab getTab( String theTabName ) {
		return cp5.getTab( this , theTabName );
	}

	/**
	 * Sets the position of the tab bar which is set to 0,0
	 * by default. to move the tabs to y-position 100, use
	 * cp5.getWindow().setPositionOfTabs(0,100);
	 *
	 */

	public ControlWindow setPositionOfTabs( int theX , int theY ) {
		positionOfTabs[0] = theX;
		positionOfTabs[1] = theY;
		return this;
	}


	public float[] getPositionOfTabs( ) {
		return positionOfTabs;
	}

	void setAllignmentOfTabs( int theValue , int theWidth ) {
		// TODO
	}

	void setAllignmentOfTabs( int theValue , int theWidth , int theHeight ) {
		// TODO
	}

	void setAllignmentOfTabs( int theValue ) {
		// TODO
	}

	public void remove( ) {
		for ( int i = _myTabs.size( ) - 1 ; i >= 0 ; i-- ) {
			( ( Tab ) _myTabs.get( i ) ).remove( );
		}
		_myTabs.clear( );
		_myTabs.clearDrawable( );
	}

	/**
	 * clear the control window, delete all controllers from
	 * a control window.
	 */
	public ControlWindow clear( ) {
		remove( );
		return this;
	}

	protected void updateFont( ControlFont theControlFont ) {
		for ( int i = 0 ; i < _myTabs.size( ) ; i++ ) {
			( ( Tab ) _myTabs.get( i ) ).updateFont( theControlFont );
		}
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public void updateEvents( ) {
		handleMouseOver( );
		handleMouseWheelMoved( );
		if ( _myTabs.size( ) <= 0 ) {
			return;
		}
		( ( ControllerInterface< ? > ) _myTabs.get( 0 ) ).updateEvents( );
		for ( int i = 1 ; i < _myTabs.size( ) ; i++ ) {
			( ( Tab ) _myTabs.get( i ) ).continuousUpdateEvents( );
			if ( ( ( Tab ) _myTabs.get( i ) ).isActive( ) && ( ( Tab ) _myTabs.get( i ) ).isVisible( ) ) {
				( ( ControllerInterface< ? > ) _myTabs.get( i ) ).updateEvents( );
			}
		}
	}

	/**
	 * returns true if the mouse is inside a controller. !!!
	 * doesnt work for groups yet.
	 */
	public boolean isMouseOver( ) {
		// TODO doesnt work for all groups yet, only ListBox
		// and DropdownList.
		if ( _myFrameCount + 1 < _myApplet.frameCount ) {
			resetMouseOver( );
		}
		return isVisible ? isMouseOver : false;
	}

	public boolean isMouseOver( ControllerInterface< ? > theController ) {
		return mouseoverlist.contains( theController );
	}

	public void resetMouseOver( ) {
		isMouseOver = false;
		for ( int i = mouseoverlist.size( ) - 1 ; i >= 0 ; i-- ) {
			mouseoverlist.get( i ).setMouseOver( false );
		}
		mouseoverlist.clear( );
	}

	public ControllerInterface< ? > getFirstFromMouseOverList( ) {
		if ( getMouseOverList( ).isEmpty( ) ) {
			return null;
		} else {
			return getMouseOverList( ).get( 0 );
		}
	}

	/**
	 * A list of controllers that are registered with a
	 * mouseover.
	 */
	public List< ControllerInterface< ? >> getMouseOverList( ) {
		return mouseoverlist;
	}

	private ControlWindow handleMouseOver( ) {
		for ( int i = mouseoverlist.size( ) - 1 ; i >= 0 ; i-- ) {
			if ( !mouseoverlist.get( i ).isMouseOver( ) || !isVisible ) {
				mouseoverlist.remove( i );
			}
		}
		isMouseOver = mouseoverlist.size( ) > 0;
		return this;
	}

	public ControlWindow removeMouseOverFor( ControllerInterface< ? > theController ) {
		mouseoverlist.remove( theController );
		return this;
	}

	protected ControlWindow setMouseOverController( ControllerInterface< ? > theController ) {
		if ( !mouseoverlist.contains( theController ) && isVisible && theController.isVisible( ) ) {
			mouseoverlist.add( theController );
		}
		isMouseOver = true;
		return this;
	}

	/**
	 * updates all controllers inside the control window if
	 * update is enabled.
	 *
	 * @exclude
	 */
	public void update( ) {
		( ( ControllerInterface< ? > ) _myTabs.get( 0 ) ).update( );
		for ( int i = 1 ; i < _myTabs.size( ) ; i++ ) {
			( ( Tab ) _myTabs.get( i ) ).update( );
		}
	}

	/**
	 * enable or disable the update function of a control
	 * window.
	 */
	public void setUpdate( boolean theFlag ) {
		isUpdate = theFlag;
		for ( int i = 0 ; i < _myTabs.size( ) ; i++ ) {
			( ( ControllerInterface< ? > ) _myTabs.get( i ) ).setUpdate( theFlag );
		}
	}

	/**
	 * check the update status of a control window.
	 */
	public boolean isUpdate( ) {
		return isUpdate;
	}

	public ControlWindow addCanvas( Canvas theCanvas ) {
		_myCanvas.add( theCanvas );
		theCanvas.setControlWindow( this );
		theCanvas.setup( _myApplet.g );
		return this;
	}

	public ControlWindow removeCanvas( Canvas theCanvas ) {
		_myCanvas.remove( theCanvas );
		return this;
	}

	private boolean isReset = false;

	public ControlWindow pre( ) {

		if ( _myFrameCount + 1 < _myApplet.frameCount ) {
			if ( isReset ) {
				resetMouseOver( );
				isReset = false;
			}
		} else {
			isReset = true;
		}

		if ( papplet( ).focused != focused ) {
			clearKeys( );
			mousePressed = false;
			focused = papplet( ).focused;
		}

		return this;
	}

	boolean pmouseReleased; // Android

	boolean pmousePressed; // Android

	/**
	 * when in Android mode, call mouseEvent(int, int,
	 * boolean).
	 */
	public void mouseEvent( int theX , int theY , boolean pressed ) {

		mouseX = theX - cp5.pgx - cp5.ox;
		mouseY = theY - cp5.pgy - cp5.oy;

		if ( pressed && !pmousePressed ) {
			updateEvents( );
			mousePressedEvent( );
			pmousePressedTime = mousePressedTime;
			mousePressedTime = System.currentTimeMillis( );
			pmousePressed = true;
			pmouseReleased = false;
		} else if ( !pressed && !pmouseReleased ) {
			updateEvents( );
			mouseReleasedEvent( );
			for ( ControllerInterface c : mouseoverlist ) {
				if ( c instanceof Controller ) {
					final Controller c1 = ( ( Controller ) c );
					c1.onLeave( );
					c1.onRelease( );
					cp5.getControlBroadcaster( ).invokeAction( new CallbackEvent( c1 , ControlP5.ACTION_LEAVE ) );
					c1.callListener( ControlP5.ACTION_LEAVE );
					cp5.getControlBroadcaster( ).invokeAction( new CallbackEvent( c1 , ControlP5.ACTION_RELEASE ) );
					c1.callListener( ControlP5.ACTION_RELEASE );
				} else if ( c instanceof ControllerGroup ) {
					( ( ControllerGroup ) c ).mouseReleased( );
				}
			}
			resetMouseOver( );
			pmousePressed = false;
			pmouseReleased = true;

		}
	}

	/**
	 * @exclude
	 */
	public void mouseEvent( MouseEvent theMouseEvent ) {
		if ( isMouse ) {
			mouseX = theMouseEvent.getX( ) - cp5.pgx - cp5.ox;
			mouseY = theMouseEvent.getY( ) - cp5.pgy - cp5.oy;
			if ( theMouseEvent.getAction( ) == MouseEvent.PRESS ) {
				mousePressedEvent( );
			}
			if ( theMouseEvent.getAction( ) == MouseEvent.RELEASE ) {
				mouseReleasedEvent( );
			}
			if ( theMouseEvent.getAction( ) == MouseEvent.WHEEL ) {

				setMouseWheelRotation( theMouseEvent.getCount( ) );

			}
		}
	}

	public void keyEvent( KeyEvent theKeyEvent ) {

		if ( theKeyEvent.getAction( ) == KeyEvent.PRESS ) {
			keys[ theKeyEvent.getKeyCode( ) ] = true;
			numOfActiveKeys++;
			cp5.modifiers = theKeyEvent.getModifiers( );
			key = theKeyEvent.getKey( );
			keyCode = theKeyEvent.getKeyCode( );
		}

		if ( theKeyEvent.getAction( ) == KeyEvent.RELEASE ) {
			keys[ theKeyEvent.getKeyCode( ) ] = false;
			numOfActiveKeys--;
			cp5.modifiers = theKeyEvent.getModifiers( );
		}

		if ( theKeyEvent.getAction( ) == KeyEvent.PRESS && cp5.isShortcuts( ) ) {
			int n = 0;
			for ( boolean b : keys ) {
				n += b ? 1 : 0;
			}
			char[] c = new char[ n ];
			n = 0;
			for ( int i = 0 ; i < keys.length ; i++ ) {
				if ( keys[ i ] ) {
					c[ n++ ] = ( ( char ) i );
				}
			}
			KeyCode code = new KeyCode( c );

			if ( cp5.keymap.containsKey( code ) ) {
				for ( ControlKey ck : cp5.keymap.get( code ) ) {
					ck.keyEvent( );
				}
			}
		}

		handleKeyEvent( theKeyEvent );
	}

	public void clearKeys( ) {
		keys = new boolean[ numKeys ];
		numOfActiveKeys = 0;
	}

	// TODO
	public void draw( PGraphics pg , int theX , int theY ) {

	}

	/**
	 * @exclude draw content.
	 */
	public void draw( ) {
		_myFrameCount = _myApplet.frameCount;
		draw( cp5.pg );
	}

	public void draw( PGraphics pg ) {
		pg.pushMatrix( );
		pg.translate( cp5.ox , cp5.oy );
		if ( cp5.blockDraw == false ) {
			if ( cp5.isAndroid ) {
				mouseEvent( cp5.papplet.mouseX , cp5.papplet.mouseY , cp5.papplet.mousePressed );
			} else {
				updateEvents( );
			}
			if ( isVisible ) {
				if ( cp5.isGraphics ) {
					pg.beginDraw( );
					if ( ( ( background >> 24 ) & 0xff ) != 0 ) {
						pg.background( background );
					}
				}

				// TODO save stroke, noStroke, fill, noFill, strokeWeight parameters and restore after drawing controlP5 elements.

				int myRectMode = pg.rectMode;
				int myEllipseMode = pg.ellipseMode;
				int myImageMode = pg.imageMode;
				pg.pushStyle( );
				pg.rectMode( PConstants.CORNER );
				pg.ellipseMode( PConstants.CORNER );
				pg.imageMode( PConstants.CORNER );
				pg.noStroke( );

				if ( _myDrawable != null ) {
					_myDrawable.draw( pg );
				}

				for ( int i = 0 ; i < _myCanvas.size( ) ; i++ ) {
					if ( ( _myCanvas.get( i ) ).mode( ) == Canvas.PRE ) {
						( _myCanvas.get( i ) ).update( _myApplet );
						( _myCanvas.get( i ) ).draw( pg );
					}
				}

				pg.noStroke( );
				pg.noFill( );
				int myOffsetX = ( int ) getPositionOfTabs( )[0];
				int myOffsetY = ( int ) getPositionOfTabs( )[1];
				int myHeight = 0;

				if ( _myTabs.size( ) > 0 ) {
					for ( int i = 1 ; i < _myTabs.size( ) ; i++ ) {
						if ( ( ( Tab ) _myTabs.get( i ) ).isVisible( ) ) {
							if ( myHeight < ( ( Tab ) _myTabs.get( i ) ).height( ) ) {
								myHeight = ( ( Tab ) _myTabs.get( i ) ).height( );
							}

							// conflicts with Android, getWidth not found TODO

							// if (myOffsetX >
							// (papplet().getWidth()) -
							// ((Tab)
							// _myTabs.get(i)).width()) {
							// myOffsetY += myHeight + 1;
							// myOffsetX = (int)
							// getPositionOfTabs().x;
							// myHeight = 0;
							// }

							( ( Tab ) _myTabs.get( i ) ).setOffset( myOffsetX , myOffsetY );

							if ( ( ( Tab ) _myTabs.get( i ) ).isActive( ) ) {
								( ( Tab ) _myTabs.get( i ) ).draw( pg );
							}

							if ( ( ( Tab ) _myTabs.get( i ) ).updateLabel( ) ) {
								( ( Tab ) _myTabs.get( i ) ).drawLabel( pg );
							}
							myOffsetX += ( ( Tab ) _myTabs.get( i ) ).width( );
						}
					}
					( ( ControllerInterface< ? > ) _myTabs.get( 0 ) ).draw( pg );
				}
				for ( int i = 0 ; i < _myCanvas.size( ) ; i++ ) {
					if ( ( _myCanvas.get( i ) ).mode( ) == Canvas.POST ) {
						( _myCanvas.get( i ) ).draw( pg );
					}
				}

				pmouseX = mouseX;
				pmouseY = mouseY;

				/* draw Tooltip here. */

				cp5.getTooltip( ).draw( this );
				pg.rectMode( myRectMode );
				pg.ellipseMode( myEllipseMode );
				pg.imageMode( myImageMode );
				pg.popStyle( );

				if ( cp5.isGraphics ) {
					pg.endDraw( );
					cp5.papplet.image( pg , cp5.pgx , cp5.pgy );
				}
			}
		}
		pg.popMatrix( );
	}

	/**
	 * Adds a custom context to a ControlWindow. Use a
	 * custom class which implements the CDrawable interface
	 *
	 * @see controlP5.CDrawable
	 * @param theDrawable CDrawable
	 */
	public ControlWindow setContext( CDrawable theDrawable ) {
		_myDrawable = theDrawable;
		return this;
	}

	/**
	 * returns the name of the control window.
	 */
	public String name( ) {
		return _myName;
	}

	private void mousePressedEvent( ) {
		if ( isVisible ) {
			mousePressed = true;
			pmousePressedTime = mousePressedTime;
			mousePressedTime = System.currentTimeMillis( );
			for ( int i = 0 ; i < _myTabs.size( ) ; i++ ) {
				if ( ( ( ControllerInterface< ? > ) _myTabs.get( i ) ).setMousePressed( true ) ) {
					mouselock = true;
					return;
				}
			}
		}
	}

	private void mouseReleasedEvent( ) {
		if ( isVisible ) {
			mousePressed = false;
			mouselock = false;
			for ( int i = 0 ; i < _myTabs.size( ) ; i++ ) {
				( ( ControllerInterface< ? > ) _myTabs.get( i ) ).setMousePressed( false );
			}
		}
	}

	void setMouseWheelRotation( int theRotation ) {
		if ( isMouseOver( ) ) {
			mouseWheelMoved = theRotation;
		}
	}

	@SuppressWarnings( "unchecked" ) private void handleMouseWheelMoved( ) {
		if ( mouseWheelMoved != 0 ) {
			List< ControllerInterface< ? >> mouselist = new CopyOnWriteArrayList< ControllerInterface< ? >>( mouseoverlist );
			for ( ControllerInterface< ? > c : mouselist ) {
				if ( c.isVisible( ) ) {
					if ( c instanceof Controller ) {
						( ( Controller ) c ).onScroll( mouseWheelMoved );
						cp5.getControlBroadcaster( ).invokeAction( new CallbackEvent( ( Controller ) c , ControlP5.ACTION_WHEEL ) );
						( ( Controller ) c ).callListener( ControlP5.ACTION_WHEEL );
					}
					if ( c instanceof ControllerGroup ) {
						( ( ControllerGroup ) c ).onScroll( mouseWheelMoved );
					}
					if ( c instanceof Slider ) {
						( ( Slider ) c ).scrolled( mouseWheelMoved );
					} else if ( c instanceof Knob ) {
						( ( Knob ) c ).scrolled( mouseWheelMoved );
					} else if ( c instanceof Numberbox ) {
						( ( Numberbox ) c ).scrolled( mouseWheelMoved );
					} else if ( c instanceof Textarea ) {
						( ( Textarea ) c ).scrolled( mouseWheelMoved );
					} else if ( c instanceof ColorWheel ) {
						( ( ColorWheel ) c ).scrolled( mouseWheelMoved );
					}
					break;
				}
			}
		}
		mouseWheelMoved = 0;
	}

	public boolean isMousePressed( ) {
		return mousePressed;
	}

	/**
	 * @exclude
	 * @param theKeyEvent KeyEvent
	 */
	public void handleKeyEvent( KeyEvent theKeyEvent ) {
		for ( int i = 0 ; i < _myTabs.size( ) ; i++ ) {
			( ( ControllerInterface< ? > ) _myTabs.get( i ) ).keyEvent( theKeyEvent );
		}
	}

	/**
	 * set the color for the controller while active.
	 */
	public ControlWindow setColorActive( int theColor ) {
		color.setActive( theColor );
		for ( int i = 0 ; i < getTabs( ).size( ) ; i++ ) {
			( ( Tab ) getTabs( ).get( i ) ).setColorActive( theColor );
		}
		return this;
	}

	/**
	 * set the foreground color of the controller.
	 */
	public ControlWindow setColorForeground( int theColor ) {
		color.setForeground( theColor );
		for ( int i = 0 ; i < getTabs( ).size( ) ; i++ ) {
			( ( Tab ) getTabs( ).get( i ) ).setColorForeground( theColor );
		}
		return this;
	}

	/**
	 * set the background color of the controller.
	 */
	public ControlWindow setColorBackground( int theColor ) {
		color.setBackground( theColor );
		for ( int i = 0 ; i < getTabs( ).size( ) ; i++ ) {
			( ( Tab ) getTabs( ).get( i ) ).setColorBackground( theColor );
		}
		return this;
	}

	/**
	 * set the color of the text label of the controller.
	 */
	public ControlWindow setColorLabel( int theColor ) {
		color.setCaptionLabel( theColor );
		for ( int i = 0 ; i < getTabs( ).size( ) ; i++ ) {
			( ( Tab ) getTabs( ).get( i ) ).setColorLabel( theColor );
		}
		return this;
	}

	/**
	 * set the color of the values.
	 */
	public ControlWindow setColorValue( int theColor ) {
		color.setValueLabel( theColor );
		for ( int i = 0 ; i < getTabs( ).size( ) ; i++ ) {
			( ( Tab ) getTabs( ).get( i ) ).setColorValue( theColor );
		}
		return this;
	}

	/**
	 * set the background color of the control window.
	 */
	public ControlWindow setBackground( int theValue ) {
		background = theValue;
		return this;
	}

	/**
	 * get the papplet instance of the ControlWindow.
	 */
	public PApplet papplet( ) {
		return _myApplet;
	}

	/**
	 * sets the frame rate of the control window.
	 *
	 * @param theFrameRate
	 * @return ControlWindow
	 */
	public ControlWindow frameRate( int theFrameRate ) {
		_myApplet.frameRate( theFrameRate );
		return this;
	}

	public ControlWindow show( ) {
		isVisible = true;
		return this;
	}

	/**
	 * by default the background of a controlWindow is
	 * filled with a background color every frame. to enable
	 * or disable the background from drawing, use
	 * setDrawBackgorund(true/false).
	 *
	 * @param theFlag
	 * @return ControlWindow
	 */
	public ControlWindow setDrawBackground( boolean theFlag ) {
		isDrawBackground = theFlag;
		return this;
	}

	public boolean isDrawBackground( ) {
		return isDrawBackground;
	}

	public boolean isVisible( ) {
		return isVisible;
	}

	protected boolean isControllerActive( Controller< ? > theController ) {
		if ( isControllerActive == null ) {
			return false;
		}
		return isControllerActive.equals( theController );
	}

	protected ControlWindow setControllerActive( Controller< ? > theController ) {
		isControllerActive = theController;
		return this;
	}

	public ControlWindow toggleUndecorated( ) {
		setUndecorated( !isUndecorated( ) );
		return this;
	}

	public ControlWindow setUndecorated( boolean theFlag ) {
		if ( theFlag != isUndecorated( ) ) {
			isUndecorated = theFlag;
			_myApplet.frame.removeNotify( );
			_myApplet.frame.setUndecorated( isUndecorated );
			_myApplet.setSize( _myApplet.width , _myApplet.height );
			_myApplet.setBounds( 0 , 0 , _myApplet.width , _myApplet.height );
			_myApplet.frame.setSize( _myApplet.width , _myApplet.height );
			_myApplet.frame.addNotify( );
		}
		return this;
	}

	public boolean isUndecorated( ) {
		return isUndecorated;
	}

	public ControlWindow setPosition( int theX , int theY ) {
		return setLocation( theX , theY );
	}

	public ControlWindow setLocation( int theX , int theY ) {
		_myApplet.frame.setLocation( theX , theY );
		return this;
	}

	public Pointer getPointer( ) {
		return _myPointer;
	}

	public ControlWindow disablePointer( ) {
		_myPointer.disable( );
		return this;
	}

	public ControlWindow enablePointer( ) {
		_myPointer.enable( );
		return this;
	}

	/**
	 * A pointer by default is linked to the mouse and
	 * stores the x and y position as well as the pressed
	 * and released state. The pointer can be accessed by
	 * its getter method {@link ControlWindow#getPointer()}.
	 * Then use
	 * {@link controlP5.ControlWindow#set(int, int)} to
	 * alter its position or invoke {
	 * {@link controlP5.ControlWindow#pressed()} or
	 * {@link controlP5.ControlWindow#released()} to change
	 * its state. To disable the mouse and enable the
	 * Pointer use {@link controlP5.ControlWindow#enable()}
	 * and {@link controlP5.ControlWindow#disable()} to
	 * default back to the mouse as input parameter.
	 */
	// TODO offset against pgx and pgy
	public class Pointer {

		public Pointer setX( int theX ) {
			mouseX = theX;
			return this;
		}

		public Pointer setY( int theY ) {
			mouseY = theY;
			return this;
		}

		public int getY( ) {
			return mouseY;
		}

		public int getX( ) {
			return mouseX;
		}

		public int getPreviousX( ) {
			return pmouseX;
		}

		public int getPreviousY( ) {
			return pmouseY;
		}

		public Pointer set( int theX , int theY ) {
			setX( theX );
			setY( theY );
			return this;
		}

		// TODO mousePressed/mouseReleased are handled wrongly, released is called when moved, for now do not use, instead use set(x,y), pressed(), released()
		public Pointer set( int theX , int theY , boolean pressed ) {
			setX( theX );
			setY( theY );
			if ( pressed ) {
				if ( !mousePressed ) {
					pressed( );
				}
			} else {
				if ( mousePressed ) {
					released( );
				}
			}
			return this;
		}

		public Pointer pressed( ) {
			mousePressedEvent( );
			return this;
		}

		public Pointer released( ) {
			mouseReleasedEvent( );
			return this;
		}

		public void enable( ) {
			isMouse = false;
		}

		public void disable( ) {
			isMouse = true;
		}

		public boolean isEnabled( ) {
			return !isMouse;
		}
	}

	/**
	 * hide the controllers and tabs of the ControlWindow.
	 */
	public ControlWindow hide( ) {
		isVisible = false;
		isMouseOver = false;
		return this;
	}

}
