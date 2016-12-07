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

import java.io.File;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Logger;

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import controlP5.ControlWindow.Pointer;

/**
 * <p>
 * controlP5 is a processing and java library for creating
 * simple control GUIs. The ControlP5 class, the core of
 * controlP5.
 * </p>
 * <p>
 * All addController-Methods are located inside the
 * ControlP5Base class.
 * </p>
 * 
 * @see controlP5.ControlP5Base
 * @example use/ControlP5basics
 */
public class ControlP5 extends ControlP5Base {

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public ControlWindow controlWindow;

	/**
	 * @exclude
	 */
	@ControlP5.Invisible static CColor color = new CColor( THEME_CP52014 );

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public PApplet papplet;

	/**
	 * @exclude
	 */
	@ControlP5.Invisible PGraphics pg;
	int pgx = 0 , pgy = 0 , pgw = 0 , pgh = 0;
	int ox = 0;
	int oy = 0;

	boolean isGraphics = false;

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public static final String VERSION = "2.2.6";// "2.2.6";

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public static boolean isApplet = false;

	static int renderer = J2D;

	/**
	 * use this static variable to turn DEBUG on or off.
	 */
	public static boolean DEBUG;

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public static final Logger logger = Logger.getLogger( ControlP5.class.getName( ) );

	private Map< String , ControllerInterface< ? >> _myControllerMap;
	protected ControlBroadcaster _myControlBroadcaster;
	protected ControlWindow window;
	protected boolean isMoveable = false;

	/* TODO does not work anymore, deprecate? */
	protected boolean isAutoInitialization = false;
	protected boolean isGlobalControllersAlwaysVisible = true;
	protected boolean isTabEventsActive;
	protected boolean isUpdate;
	protected boolean isControlFont;
	protected ControlFont controlFont;
	static public final PFont BitFontStandard56 = new BitFont( CP.decodeBase64( BitFont.standard56base64 ) );
	static public final PFont BitFontStandard58 = new BitFont( CP.decodeBase64( BitFont.standard58base64 ) );
	protected ControlFont defaultFont = new ControlFont( BitFontStandard58 );
	protected ControlFont defaultFontForText = new ControlFont( BitFontStandard56 );

	/**
	 * from version 0.7.2 onwards shortcuts are disabled by
	 * default. shortcuts can be enabled using
	 * controlP5.enableShortcuts();
	 * 
	 * @see #enableShortcuts()
	 */
	protected boolean isShortcuts = false;

	@Deprecated public boolean blockDraw;
	protected Tooltip _myTooltip;
	protected boolean isAnnotation;
	boolean isAndroid = false;

	/**
	 * Create a new instance of controlP5.
	 * 
	 * @param theParent PApplet
	 */
	public ControlP5( final PApplet theParent ) {
		papplet = theParent;
		init( );
	}

	public ControlP5( final PApplet theParent , PFont thePFont ) {
		papplet = theParent;
		init( );
		setFont( thePFont );
	}

	public ControlP5( final PApplet theParent , ControlFont theControlFont ) {
		papplet = theParent;
		init( );
		setFont( theControlFont );
	}

	protected void init( ) {
		renderer = ( papplet.g.getClass( ).getCanonicalName( ).indexOf( "Java2D" ) > -1 ) ? J2D : P3D;
		Class< ? > check = papplet.getClass( );
		while ( check != null ) {
			check = check.getSuperclass( );
			if ( check != null ) {
				if ( check.toString( ).toLowerCase( ).indexOf( "android.app." ) > -1 ) {
					isAndroid = true;
					break;
				}
			}
		}

		isTabEventsActive = false;

		_myControlBroadcaster = new ControlBroadcaster( this );

		// } else {
		// defaultFont = new
		// ControlFont(papplet.createFont("", 10));
		//
		// defaultFontForText = new
		// ControlFont(papplet.createFont("", 10));
		// }

		controlFont = defaultFont;
		controlWindow = new ControlWindow( this , papplet );
		papplet.registerMethod( "pre" , this );
		papplet.registerMethod( "dispose" , this );
		setGraphics( papplet , 0 , 0 );
		_myControllerMap = new TreeMap< String , ControllerInterface< ? >>( );
		setFont( controlFont );
		_myTooltip = new Tooltip( this );
		super.init( this );

		if ( welcome++ < 1 ) {
			welcome( );
		}

		mapKeyFor( new ControlKey( ) {

			public void keyEvent( ) {
				saveProperties( );
			}
		} , PApplet.ALT , PApplet.SHIFT , 's' );

		mapKeyFor( new ControlKey( ) {

			public void keyEvent( ) {
				loadProperties( );
			}
		} , PApplet.ALT , PApplet.SHIFT , 'l' );

		mapKeyFor( new ControlKey( ) {

			public void keyEvent( ) {
				if ( controlWindow.isVisible ) {
					hide( );
				} else {
					show( );
				}
			}
		} , PApplet.ALT , PApplet.SHIFT , 'h' );

		disableShortcuts( );

		setFont( controlFont );

	}

	static int welcome = 0;

	private void welcome( ) {
		System.out.println( "ControlP5 " + VERSION + " " + "infos, comments, questions at http://www.sojamo.de/libraries/controlP5" );
	}

	public ControlP5 setGraphics( PApplet theApplet , int theX , int theY ) {
		setGraphics( theApplet.g , theX , theY );
		isGraphics = false;
		return this;
	}

	public ControlP5 setGraphics( PGraphics theGraphics , int theX , int theY ) {
		pg = theGraphics;
		pgx = theX;
		pgy = theY;
		pgw = pg.width;
		pgh = pg.height;
		isGraphics = true;
		return this;
	}

	public ControlP5 setPosition( int theX , int theY ) {
		ox = theX;
		oy = theY;
		return this;
	}

	/**
	 * By default event originating from tabs are disabled,
	 * use setTabEventsActive(true) to receive controlEvents
	 * when tabs are clicked.
	 * 
	 * @param theFlag
	 */
	public void setTabEventsActive( boolean theFlag ) {
		isTabEventsActive = theFlag;
	}

	/**
	 * autoInitialization can be very handy when it comes to
	 * initializing values, e.g. you load a set of
	 * controllers, then the values that are attached to the
	 * controllers will be reset to its saved state. to turn
	 * of auto intialization, call
	 * setAutoInitialization(false) right after initializing
	 * controlP5 and before creating any controller.
	 * 
	 * @param theFlag boolean
	 */
	public void setAutoInitialization( boolean theFlag ) {
		isAutoInitialization = theFlag;
	}

	/**
	 * by default controlP5 draws any controller on top of
	 * any drawing done in the draw() function (this doesnt
	 * apply to P3D where controlP5.draw() has to be called
	 * manually in the sketch's draw() function ). to turn
	 * off the auto drawing of controlP5, use
	 * controlP5.setAutoDraw(false). now you can call
	 * controlP5.draw() any time whenever controllers should
	 * be drawn into the sketch.
	 * 
	 * @param theFlag boolean
	 */
	public void setAutoDraw( boolean theFlag ) {
		if ( isAutoDraw( ) && theFlag == false ) {
			controlWindow.papplet( ).unregisterMethod( "draw" , controlWindow );
		}
		if ( isAutoDraw( ) == false && theFlag == true ) {
			controlWindow.papplet( ).registerMethod( "draw" , controlWindow );
		}
		controlWindow.isAutoDraw = theFlag;
	}

	/**
	 * check if the autoDraw function for the main window is
	 * enabled(true) or disabled(false).
	 * 
	 * @return boolean
	 */
	public boolean isAutoDraw( ) {
		return controlWindow.isAutoDraw;
	}

	/**
	 * 
	 * @see controlP5.ControlBroadcaster
	 */
	public ControlBroadcaster getControlBroadcaster( ) {
		return _myControlBroadcaster;
	}

	/**
	 * @see controlP5.ControlListener
	 */
	public ControlP5 addListener( ControlListener ... theListeners ) {
		getControlBroadcaster( ).addListener( theListeners );
		return this;
	}

	/**
	 * @see controlP5.ControlListener
	 */
	public ControlP5 removeListener( ControlListener ... theListeners ) {
		getControlBroadcaster( ).removeListener( theListeners );
		return this;
	}

	/**
	 * @see controlP5.ControlListener
	 */
	public ControlP5 removeListener( ControlListener theListener ) {
		getControlBroadcaster( ).removeListener( theListener );
		return this;
	}

	/**
	 * @see controlP5.ControlListener
	 */
	public ControlListener getListener( int theIndex ) {
		return getControlBroadcaster( ).getListener( theIndex );
	}

	/**
	 * @see controlP5.CallbackEvent
	 * @see controlP5.CallbackListener
	 */
	public ControlP5 addCallback( CallbackListener ... theListeners ) {
		getControlBroadcaster( ).addCallback( theListeners );
		return this;
	}

	/**
	 * @see controlP5.CallbackEvent
	 * @see controlP5.CallbackListener
	 */
	public ControlP5 addCallback( CallbackListener theListener ) {
		getControlBroadcaster( ).addCallback( theListener );
		return this;
	}

	/**
	 * @see controlP5.CallbackEvent
	 * @see controlP5.CallbackListener
	 */
	public ControlP5 addCallback( CallbackListener theListener , Controller< ? > ... theControllers ) {
		getControlBroadcaster( ).addCallback( theListener , theControllers );
		return this;
	}

	/**
	 * @see controlP5.CallbackEvent
	 * @see controlP5.CallbackListener
	 */
	public ControlP5 removeCallback( CallbackListener ... theListeners ) {
		getControlBroadcaster( ).removeCallback( theListeners );
		return this;
	}

	/**
	 * @see controlP5.CallbackEvent
	 * @see controlP5.CallbackListener
	 */
	public ControlP5 removeCallback( Controller< ? > ... theControllers ) {
		getControlBroadcaster( ).removeCallback( theControllers );
		return this;
	}

	/**
	 * @see controlP5.CallbackEvent
	 * @see controlP5.CallbackListener
	 */
	public ControlP5 removeCallback( Controller< ? > theController ) {
		getControlBroadcaster( ).removeCallback( theController );
		return this;
	}

	/**
	 * TODO
	 * 
	 * @exclude
	 */
	public void addControlsFor( Object theObject ) {

	}

	public Tab getTab( String theName ) {
		for ( int i = 0 ; i < controlWindow.getTabs( ).size( ) ; i++ ) {
			if ( ( ( Tab ) controlWindow.getTabs( ).get( i ) ).getName( ).equals( theName ) ) {
				return ( Tab ) controlWindow.getTabs( ).get( i );
			}
		}
		Tab myTab = addTab( theName );
		return myTab;
	}

	public Tab getTab( ControlWindow theWindow , String theName ) {
		for ( int i = 0 ; i < theWindow.getTabs( ).size( ) ; i++ ) {
			if ( ( ( Tab ) theWindow.getTabs( ).get( i ) ).getName( ).equals( theName ) ) {
				return ( Tab ) theWindow.getTabs( ).get( i );
			}
		}
		Tab myTab = theWindow.add( new Tab( this , theWindow , theName ) );
		return myTab;
	}

	/**
	 * registers a Controller with ControlP5, a Controller
	 * should/must be registered with a unique name. If not,
	 * accessing Controllers by name is not guaranteed. the
	 * rule here is last come last serve, existing
	 * Controllers with the same name will be overridden.
	 * 
	 * @param theController ControllerInterface
	 * @return ControlP5
	 */
	public ControlP5 register( Object theObject , String theIndex , ControllerInterface< ? > theController ) {
		String address = "";
		if ( theObject == papplet ) {
			address = ( theController.getName( ).startsWith( "/" ) ) ? "" : "/";
			address += theController.getName( );
		} else {
			address = ( ( ( theIndex.length( ) == 0 ) || theIndex.startsWith( "/" ) ) ? "" : "/" );
			address += theIndex;
			address += ( theController.getName( ).startsWith( "/" ) ? "" : "/" );
			address += theController.getName( );
		}

		theController.setAddress( address );

		if ( checkName( theController.getAddress( ) ) ) {
			/* in case a controller with the same name
			 * already exists, will be deleted */
			remove( theController.getAddress( ) );
		}

		/* add the controller to the controller map */
		_myControllerMap.put( theController.getAddress( ) , theController );

		/* update the properties' controller address */
		List< ControllerProperty > ps = getProperties( ).get( theController );
		if ( ps != null ) {
			for ( ControllerProperty p : ps ) {
				p.setAddress( theController.getAddress( ) );
			}
		}
		/* initialize the controller */

		theController.init( );

		/* handle controller plugs and map controllers to
		 * its reference objects if applicable. */

		if ( theObject == null ) {
			theObject = papplet;
		}

		if ( theController instanceof Controller< ? > ) {

			if ( !theObject.equals( papplet ) ) {
				( ( Controller< ? > ) ( ( Controller< ? > ) theController ).unplugFrom( papplet ) ).plugTo( theObject );
			}

		}

		if ( !_myObjectToControllerMap.containsKey( theObject ) ) {
			_myObjectToControllerMap.put( theObject , new ArrayList< ControllerInterface< ? >>( ) );
		}

		_myObjectToControllerMap.get( theObject ).add( theController );
		return this;
	}

	public ControlP5 register( ControllerInterface< ? > theController ) {
		return register( papplet , "" , theController );
	}

	/**
	 * Returns a List of all controllers currently
	 * registered.
	 * 
	 * @return List<ControllerInterface<?>>
	 */
	public List< ControllerInterface< ? >> getAll( ) {
		return new ArrayList< ControllerInterface< ? >>( _myControllerMap.values( ) );
	}

	/**
	 * Returns a list of controllers or groups of a
	 * particular type. The following example will return a
	 * list of registered Bangs only:<br />
	 * <code><pre>
	 * List<Bang> list = controlP5.getAll(Bang.class);
	 * println(list);
	 * for(Bang b:list) {
	 *   b.setColorForeground(color(255,255,0));
	 * }
	 * </pre></code> Here the foreground color of all Bangs
	 * is changed to yellow.
	 * 
	 * @param <T>
	 * @param theClass A class that extends
	 *            ControllerInterface, which applies to all
	 *            Controllers and ControllerGroups
	 * @return List<T>
	 */
	@SuppressWarnings( "unchecked" ) public < T > List< T > getAll( Class< T > theClass ) {
		ArrayList< T > l = new ArrayList< T >( );
		for ( ControllerInterface ci : _myControllerMap.values( ) ) {
			if ( ci.getClass( ) == theClass || ci.getClass( ).getSuperclass( ) == theClass ) {
				l.add( ( T ) ci );
			}
		}
		return l;
	}

	protected void deactivateControllers( ) {
		for ( Textfield t : getAll( Textfield.class ) ) {
			t.setFocus( false );
		}
	}

	private String checkAddress( String theName ) {
		if ( !theName.startsWith( "/" ) ) {
			return "/" + theName;
		}
		return theName;
	}

	/**
	 * @excude
	 */
	public void printControllerMap( ) {
		List< String > strs = new ArrayList< String >( );
		System.out.println( "============================================" );
		for ( Iterator it = _myControllerMap.entrySet( ).iterator( ) ; it.hasNext( ) ; ) {
			Map.Entry entry = ( Map.Entry ) it.next( );
			Object key = entry.getKey( );
			Object value = entry.getValue( );
			strs.add( key + " = " + value );
		}
		Collections.sort( strs );
		for ( String s : strs ) {
			System.out.println( s );
		}
		System.out.println( "============================================" );
	}

	/**
	 * removes a controller by instance.
	 * 
	 * TODO Fix this. this only removes the reference to a
	 * controller from the controller map but not its
	 * children, fatal for controller groups!
	 * 
	 * @param theController ControllerInterface
	 */
	protected void remove( ControllerInterface< ? > theController ) {
		_myControllerMap.remove( theController.getAddress( ) );
	}

	/**
	 * removes a controlP5 element such as a controller,
	 * group, or tab by name.
	 * 
	 * @param theString String
	 */
	public void remove( String theName ) {
		String address = checkAddress( theName );

		if ( getController( address ) != null ) {
			getController( address ).remove( );
		}

		if ( getGroup( address ) != null ) {
			getGroup( address ).remove( );
		}

		for ( int i = 0 ; i < controlWindow.getTabs( ).size( ) ; i++ ) {
			if ( controlWindow.getTabs( ).get( i ).getAddress( ).equals( address ) ) {
				controlWindow.getTabs( ).get( i ).remove( );
			}
		}
		_myControllerMap.remove( address );
	}

	public ControllerInterface< ? > get( String theName ) {
		String address = checkAddress( theName );
		if ( _myControllerMap.containsKey( address ) ) {
			return _myControllerMap.get( address );
		}
		return null;
	}

	public ControllerInterface< ? > get( Object theObject , String theName ) {
		return getController( theName , theObject );
	}

	public < C > C get( Class< C > theClass , String theName ) {
		for ( ControllerInterface< ? > ci : _myControllerMap.values( ) ) {
			if ( ci.getClass( ) == theClass || ci.getClass( ).getSuperclass( ) == theClass ) {
				return ( C ) get( theName );
			}
		}
		return null;
	}

	/**
	 * @exclude
	 * @see controlP5.ControlP5#getAll(Class)
	 * @return List<ControllerInterface>
	 */
	@ControlP5.Invisible public List< ControllerInterface< ? >> getList( ) {
		LinkedList< ControllerInterface< ? >> l = new LinkedList< ControllerInterface< ? >>( );
		l.addAll( controlWindow.getTabs( ).get( ) );
		l.addAll( getAll( ) );
		return l;
	}

	public float getValue( String theIndex ) {
		Controller c = getController( theIndex );
		if ( c != null ) {
			return c.getValue( );
		}
		return Float.NaN;
	}

	public Controller< ? > getController( String theName ) {
		String address = checkAddress( theName );
		if ( _myControllerMap.containsKey( address ) ) {
			if ( _myControllerMap.get( address ) instanceof Controller< ? > ) {
				return ( Controller< ? > ) _myControllerMap.get( address );
			}
		}
		return null;
	}

	public ControllerGroup< ? > getGroup( String theGroupName ) {
		String address = checkAddress( theGroupName );
		if ( _myControllerMap.containsKey( address ) ) {
			if ( _myControllerMap.get( address ) instanceof ControllerGroup< ? > ) {
				return ( ControllerGroup< ? > ) _myControllerMap.get( address );
			}
		}
		return null;
	}

	private boolean checkName( String theName ) {
		if ( _myControllerMap.containsKey( checkAddress( theName ) ) ) {
			ControlP5.logger( ).warning( "Controller with name \"" + theName + "\" already exists. overwriting reference of existing controller." );
			return true;
		}
		return false;
	}

	public void moveControllersForObject( Object theObject , ControllerGroup< ? > theGroup ) {
		if ( _myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				( ( Controller< ? > ) c ).moveTo( theGroup );
			}
		}
	}

	public void move( Object theObject , ControllerGroup< ? > theGroup ) {
		moveControllersForObject( theObject , theGroup );
	}

	protected void clear( ) {
		controlWindow.clear( );
		_myControllerMap.clear( );
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public void pre( ) {
		Iterator< FieldChangedListener > itr = _myFieldChangedListenerMap.values( ).iterator( );
		while ( itr.hasNext( ) ) {
			itr.next( ).update( );
		}
	}

	/**
	 * call draw() from your program when autoDraw is
	 * disabled.
	 * 
	 * @exclude
	 */
	@ControlP5.Invisible public void draw( ) {
		if ( !isAutoDraw( ) ) {
			controlWindow.draw( );
		}
	}

	/**
	 * convenience method to access the main window
	 * (ControlWindow class).
	 */
	public ControlWindow getWindow( ) {
		return getWindow( papplet );
	}

	public void mouseEvent( MouseEvent theMouseEvent ) {
		getWindow( ).mouseEvent( theMouseEvent );
	}

	public void keyEvent( KeyEvent theKeyEvent ) {
		getWindow( ).keyEvent( theKeyEvent );
	}

	/**
	 * convenience method to access the pointer of the main
	 * control window.
	 */
	public Pointer getPointer( ) {
		return getWindow( papplet ).getPointer( );
	}

	/**
	 * convenience method to check if the mouse (or pointer)
	 * is hovering over any controller. only applies to the
	 * main window. To receive the mouseover information for
	 * a ControlWindow use
	 * getWindow(nameOfWindow).isMouseOver();
	 */
	public boolean isMouseOver( ) {
		return getWindow( papplet ).isMouseOver( );
	}

	/**
	 * convenience method to check if the mouse (or pointer)
	 * is hovering over a specific controller. only applies
	 * to the main window. To receive the mouseover
	 * information for a ControlWindow use
	 * getWindow(nameOfWindow
	 * ).isMouseOver(ControllerInterface<?>);
	 */
	public boolean isMouseOver( ControllerInterface< ? > theController ) {
		return getWindow( papplet ).isMouseOver( theController );
	}

	/**
	 * convenience method to check if the mouse (or pointer)
	 * is hovering over a specific controller. only applies
	 * to the main window. To receive the mouseover
	 * information for a ControlWindow use
	 * getWindow(nameOfWindow).getMouseOverList();
	 */
	public List< ControllerInterface< ? >> getMouseOverList( ) {
		return getWindow( papplet ).getMouseOverList( );
	}

	public ControlWindow getWindow( PApplet theApplet ) {
		if ( theApplet.equals( papplet ) ) {
			return controlWindow;
		}
		// TODO !!! check for another window in case
		// theApplet is of type
		// PAppletWindow.
		return controlWindow;
	}

	/**
	 * adds a Canvas to the default sketch window.
	 * 
	 * @see controlP5.Canvas
	 */
	public ControlP5 addCanvas( Canvas theCanvas ) {
		getWindow( ).addCanvas( theCanvas );
		return this;
	}

	public ControlP5 removeCanvas( Canvas theCanvas ) {
		getWindow( ).removeCanvas( theCanvas );
		return this;
	}

	public ControlP5 setColor( CColor theColor ) {
		setColorBackground( theColor.getBackground( ) );
		setColorForeground( theColor.getForeground( ) );
		setColorActive( theColor.getActive( ) );
		setColorCaptionLabel( theColor.getCaptionLabel( ) );
		setColorValueLabel( theColor.getValueLabel( ) );
		return this;
	}

	public static CColor getColor( ) {
		return color;
	}

	/**
	 * sets the active state color of tabs and controllers,
	 * this cascades down to all known controllers.
	 */
	public ControlP5 setColorActive( int theColor ) {
		color.setActive( theColor );
		controlWindow.setColorActive( theColor );
		return this;
	}

	/**
	 * sets the foreground color of tabs and controllers,
	 * this cascades down to all known controllers.
	 */
	public ControlP5 setColorForeground( int theColor ) {
		color.setForeground( theColor );
		controlWindow.setColorForeground( theColor );
		return this;
	}

	/**
	 * sets the background color of tabs and controllers,
	 * this cascades down to all known controllers.
	 */
	public ControlP5 setColorBackground( int theColor ) {
		color.setBackground( theColor );
		controlWindow.setColorBackground( theColor );
		return this;
	}

	/**
	 * sets the label color of tabs and controllers, this
	 * cascades down to all known controllers.
	 */
	public ControlP5 setColorCaptionLabel( int theColor ) {
		color.setCaptionLabel( theColor );
		controlWindow.setColorLabel( theColor );
		return this;
	}

	/**
	 * sets the value color of controllers, this cascades
	 * down to all known controllers.
	 */
	public ControlP5 setColorValueLabel( int theColor ) {
		color.setValueLabel( theColor );
		controlWindow.setColorValue( theColor );
		return this;
	}

	public ControlP5 setBackground( int theColor ) {
		controlWindow.setBackground( theColor );
		return this;
	}

	/**
	 * Enables/disables Controllers to be moved around when
	 * ALT-key is down and mouse is dragged. Other key
	 * events are still available like ALT-h to hide and
	 * show the controllers To disable all key events, use
	 * disableKeys()
	 */
	public ControlP5 setMoveable( boolean theFlag ) {
		isMoveable = theFlag;
		return this;
	}

	/**
	 * Checks if controllers are generally moveable
	 * 
	 */
	public boolean isMoveable( ) {
		return isMoveable;
	}

	/**
	 * Saves the current values of controllers into a
	 * default properties file
	 * 
	 * @see controlP5.ControllerProperties
	 */
	public boolean saveProperties( ) {
		return _myProperties.save( );
	}

	/**
	 * Saves the current values of controllers into a file,
	 * the filepath is given by parameter theFilePath.
	 * 
	 * @see controlP5.ControllerProperties
	 */
	public boolean saveProperties( String theFilePath ) {
		return _myProperties.saveAs( theFilePath );
	}

	public boolean saveProperties( String theFilePath , String ... theSets ) {
		return _myProperties.saveAs( theFilePath , theSets );
	}

	/**
	 * Loads properties from a default properties file and
	 * changes values of controllers accordingly.
	 * 
	 * @see controlP5.ControllerProperties
	 * @return
	 */
	public boolean loadProperties( ) {
		return _myProperties.load( );
	}

	/**
	 * Loads properties from a properties file and changes
	 * the values of controllers accordingly, the filepath
	 * is given by parameter theFilePath.
	 * 
	 * @param theFilePath
	 * @return
	 */
	public boolean loadProperties( final String theFilePath ) {
		String path = theFilePath.endsWith( _myProperties.format.getExtension( ) ) ? theFilePath : theFilePath + "." + _myProperties.format.getExtension( );
		path = checkPropertiesPath( path );
		File f = new File( path);
		
		if ( f.exists( ) ) {
			return _myProperties.load( path );
		}
		logger.info( "Properties File " + path + " does not exist." );
		return false;
	}

	String checkPropertiesPath( String theFilePath ) {
		theFilePath = ( theFilePath.startsWith( "/" ) || theFilePath.startsWith( "." ) ) ? theFilePath : papplet.sketchPath( theFilePath );
		return theFilePath;
	}

	/**
	 * @exclude
	 * @param theFilePath
	 * @return
	 */
	@ControlP5.Invisible public boolean loadLayout( String theFilePath ) {
		theFilePath = checkPropertiesPath( theFilePath );
		File f = new File( theFilePath );
		if ( f.exists( ) ) {
			getLayout( ).load( theFilePath );
			return true;
		}
		logger.info( "Layout File " + theFilePath + " does not exist." );
		return false;
	}

	/**
	 * @exclude
	 * @param theFilePath
	 */
	public void saveLayout( String theFilePath ) {
		getLayout( ).save( theFilePath );
	}

	/**
	 * Returns the current version of controlP5
	 * 
	 * @return String
	 */
	public String version( ) {
		return VERSION;
	}

	/**
	 * shows all controllers and tabs in your sketch.
	 * 
	 * @see controlP5.ControlP5#isVisible()
	 * @see controlP5.ControlP5#hide()
	 */

	public void show( ) {
		controlWindow.show( );
	}

	public ControlP5 setBroadcast( boolean theValue ) {
		_myControlBroadcaster.broadcast = theValue;
		return this;
	}

	/**
	 * returns true or false according to the current
	 * visibility flag.
	 * 
	 * @see controlP5.ControlP5#show()
	 * @see controlP5.ControlP5#hide()
	 */
	public boolean isVisible( ) {
		return controlWindow.isVisible( );
	}

	public ControlP5 setVisible( boolean b ) {
		if ( b ) {
			show( );
		} else {
			hide( );
		}
		return this;
	}

	/**
	 * hide all controllers and tabs inside your sketch
	 * window.
	 * 
	 * @see controlP5.ControlP5#show()
	 * @see controlP5.ControlP5#isVisible()
	 */
	public void hide( ) {
		controlWindow.hide( );
	}

	/**
	 * forces all controllers to update.
	 * 
	 * @see controlP5.ControlP5#isUpdate()
	 * @see controlP5.ControlP5#setUpdate()
	 */
	public void update( ) {
		controlWindow.update( );
	}

	/**
	 * checks if automatic updates are enabled. By default
	 * this is true.
	 * 
	 * @see controlP5.ControlP5#update()
	 * @see controlP5.ControlP5#setUpdate(boolean)
	 * @return
	 */
	public boolean isUpdate( ) {
		return isUpdate;
	}

	/**
	 * changes the update behavior according to parameter
	 * theFlag
	 * 
	 * @see controlP5.ControlP5#update()
	 * @see controlP5.ControlP5#isUpdate()
	 * @param theFlag
	 */
	public void setUpdate( boolean theFlag ) {
		isUpdate = theFlag;
		controlWindow.setUpdate( theFlag );
	}

	public boolean setFont( ControlFont theControlFont ) {
		controlFont = theControlFont;
		isControlFont = true;
		updateFont( controlFont );
		return isControlFont;
	}

	public boolean setFont( PFont thePFont , int theFontSize ) {
		controlFont = new ControlFont( thePFont , theFontSize );
		isControlFont = true;
		updateFont( controlFont );
		return isControlFont;
	}

	public boolean setFont( PFont thePFont ) {
		controlFont = new ControlFont( thePFont );
		isControlFont = true;
		updateFont( controlFont );
		return isControlFont;
	}

	protected void updateFont( ControlFont theControlFont ) {
		controlWindow.updateFont( theControlFont );
	}

	public ControlFont getFont( ) {
		return controlFont;
	}

	/**
	 * disables shortcuts such as alt-h for hiding/showing
	 * controllers
	 * 
	 */
	public void disableShortcuts( ) {
		isShortcuts = false;
	}

	public boolean isShortcuts( ) {
		return isShortcuts;
	}

	/**
	 * enables shortcuts.
	 */
	public void enableShortcuts( ) {
		isShortcuts = true;
	}

	public Tooltip getTooltip( ) {
		return _myTooltip;
	}

	public void setTooltip( Tooltip theTooltip ) {
		_myTooltip = theTooltip;
	}

	public void setMouseWheelRotation( int theRotation ) {
		getWindow( ).setMouseWheelRotation( theRotation );
	}

	/**
	 * cp5.begin() and cp5.end() are mechanisms to
	 * auto-layout controllers, see the ControlP5beginEnd
	 * example.
	 */
	public ControllerGroup< ? > begin( ) {
		// TODO replace controlWindow.tab("default") with
		// controlWindow.tabs().get(1);
		return begin( controlWindow.getTab( "default" ) );
	}

	public ControllerGroup< ? > begin( ControllerGroup< ? > theGroup ) {
		setCurrentPointer( theGroup );
		return theGroup;
	}

	public ControllerGroup< ? > begin( int theX , int theY ) {
		// TODO replace controlWindow.tab("default") with
		// controlWindow.tabs().get(1);
		return begin( controlWindow.getTab( "default" ) , theX , theY );
	}

	public ControllerGroup< ? > begin( ControllerGroup< ? > theGroup , int theX , int theY ) {
		setCurrentPointer( theGroup );
		ControllerGroup.set( theGroup.autoPosition , theX , theY );
		theGroup.autoPositionOffsetX = theX;
		return theGroup;
	}

	public ControllerGroup< ? > begin( ControlWindow theWindow ) {
		return begin( theWindow.getTab( "default" ) );
	}

	public ControllerGroup< ? > begin( ControlWindow theWindow , int theX , int theY ) {
		return begin( theWindow.getTab( "default" ) , theX , theY );
	}

	public ControllerGroup< ? > end( ControllerGroup< ? > theGroup ) {
		releaseCurrentPointer( theGroup );
		return theGroup;
	}

	/**
	 * cp5.begin() and cp5.end() are mechanisms to
	 * auto-layout controllers, see the ControlP5beginEnd
	 * example.
	 */
	public ControllerGroup< ? > end( ) {
		return end( controlWindow.getTab( "default" ) );
	}

	public void addPositionTo( int theX , int theY , List< ControllerInterface< ? >> theControllers ) {
		float[] v = new float[] { theX , theY };
		for ( ControllerInterface< ? > c : theControllers ) {
			float[] v1 = new float[ 2 ];
			Controller.set( v1 , Controller.x( c.getPosition( ) ) , Controller.y( c.getPosition( ) ) );
			c.setPosition( Controller.x( v ) + Controller.x( v1 ) , Controller.y( v ) + Controller.y( v1 ) );
		}
	}

	public void addPositionTo( int theX , int theY , ControllerInterface< ? > ... theControllers ) {
		addPositionTo( theX , theY , Arrays.asList( theControllers ) );
	}

	/**
	 * disposes and clears all controlP5 elements. When
	 * running in applet mode, opening new tabs or switching
	 * to another tab causes the applet to call dispose().
	 * therefore dispose() is disabled when running ing
	 * applet mode. TODO implement better dispose handling
	 * for applets.
	 * 
	 * @exclude
	 */
	public void dispose( ) {
		if ( !isApplet ) {
			clear( );
		}
	}

	/* static helper functions including Object-to-Type
	 * conversions, invokes */

	static public Object invoke( final Object theObject , final String theMember , final Object ... theParams ) {
		return invoke( theObject , theObject.getClass( ) , theMember , theParams );
	}

	static public Object invoke( final Object theObject , final Class< ? > theClass , final String theMember , final Object ... theParams ) {
		if ( theClass == null ) {
			return null;
		}
		Class[] cs = new Class[ theParams.length ];

		for ( int i = 0 ; i < theParams.length ; i++ ) {
			Class c = theParams[ i ].getClass( );
			cs[ i ] = classmap.containsKey( c ) ? classmap.get( c ) : c;
		}
		try {
			final Field f = theClass.getDeclaredField( theMember );
			/* TODO check super */
			f.setAccessible( true );
			Object o = theParams[ 0 ];
			Class cf = o.getClass( );
			if ( cf.equals( Integer.class ) ) {
				f.setInt( theObject , i( o ) );
			} else if ( cf.equals( Float.class ) ) {
				f.setFloat( theObject , f( o ) );
			} else if ( cf.equals( Long.class ) ) {
				f.setLong( theObject , l( o ) );
			} else if ( cf.equals( Double.class ) ) {
				f.setDouble( theObject , d( o ) );
			} else if ( cf.equals( Boolean.class ) ) {
				f.setBoolean( theObject , b( o ) );
			} else if ( cf.equals( Character.class ) ) {
				f.setChar( theObject , ( char ) i( o ) );
			} else {
				f.set( theObject , o );
			}
		} catch ( NoSuchFieldException e1 ) {
			try {
				final Method m = theClass.getDeclaredMethod( theMember , cs );
				m.setAccessible( true );
				try {
					return m.invoke( theObject , theParams );
				} catch ( IllegalArgumentException e ) {
					System.err.println( e );
				} catch ( IllegalAccessException e ) {
					System.err.println( e );
				} catch ( InvocationTargetException e ) {
					System.err.println( e );
				}

			} catch ( SecurityException e ) {
				System.err.println( e );
			} catch ( NoSuchMethodException e ) {
				invoke( theObject , theClass.getSuperclass( ) , theMember , theParams );
			}
		} catch ( IllegalArgumentException e ) {
			System.err.println( e );
		} catch ( IllegalAccessException e ) {
			System.err.println( e );
		}
		return null;
	}

	static public boolean b( Object o ) {
		return b( o , false );
	}

	static public boolean b( Object o , boolean theDefault ) {
		return ( o instanceof Boolean ) ? ( ( Boolean ) o ).booleanValue( ) : ( o instanceof Number ) ? ( ( Number ) o ).intValue( ) == 0 ? false : true : theDefault;
	}

	static public boolean b( String o ) {
		return b( o , false );
	}

	static public boolean b( String o , boolean theDefault ) {
		return o.equalsIgnoreCase( "true" ) ? true : theDefault;
	}

	static public int i( Object o ) {
		return i( o , Integer.MIN_VALUE );
	}

	static public int i( Object o , int theDefault ) {
		return ( o instanceof Number ) ? ( ( Number ) o ).intValue( ) : ( o instanceof String ) ? i( s( o ) ) : theDefault;
	}

	static public int i( String o ) {
		return i( o , Integer.MIN_VALUE );
	}

	static public int i( String o , int theDefault ) {
		return isNumeric( o ) ? Integer.parseInt( o ) : theDefault;
	}

	static public float f( Object o ) {
		return f( o , Float.MIN_VALUE );
	}

	static public float f( Object o , float theDefault ) {
		return ( o instanceof Number ) ? ( ( Number ) o ).floatValue( ) : ( o instanceof String ) ? f( s( o ) ) : theDefault;
	}

	static public float f( String o ) {
		return f( o , Float.MIN_VALUE );
	}

	static public float f( String o , float theDefault ) {
		return isNumeric( o ) ? Float.parseFloat( o ) : theDefault;
	}

	static public double d( Object o ) {
		return d( o , Double.MIN_VALUE );
	}

	static public double d( Object o , double theDefault ) {
		return ( o instanceof Number ) ? ( ( Number ) o ).doubleValue( ) : ( o instanceof String ) ? d( s( o ) ) : theDefault;
	}

	static public double d( String o ) {
		return d( o , Double.MIN_VALUE );
	}

	static public double d( String o , double theDefault ) {
		return isNumeric( o ) ? Double.parseDouble( o ) : theDefault;
	}

	static public long l( Object o ) {
		return l( o , Long.MIN_VALUE );
	}

	static public long l( Object o , long theDefault ) {
		return ( o instanceof Number ) ? ( ( Number ) o ).longValue( ) : ( o instanceof String ) ? l( s( o ) ) : theDefault;
	}

	static public String s( Object o ) {
		return ( o != null ) ? o.toString( ) : "";
	}

	static public String s( Object o , String theDefault ) {
		return ( o != null ) ? o.toString( ) : theDefault;
	}

	static public boolean isNumeric( Object o ) {
		return isNumeric( o.toString( ) );
	}

	static public boolean isNumeric( String str ) {
		return str.matches( "(-|\\+)?\\d+(\\.\\d+)?" );
	}

	static public List toList( final Object ... args ) {
		List l = new ArrayList( );
		Collections.addAll( l , args );
		return l;
	}

	static public List toList( Object o ) {
		return o != null ? ( o instanceof List ) ? ( List ) o : ( o instanceof String ) ? toList( o.toString( ) ) : Collections.EMPTY_LIST : Collections.EMPTY_LIST;
	}

	static public Map toMap( final String s ) {
		/* similar to mapFrom(Object ... args) but with type
		 * (Number,String) sensitivity */
		String[] arr = s.trim( ).split( delimiter );
		Map m = new LinkedHashMap( );
		if ( arr.length % 2 == 0 ) {
			for ( int i = 0 ; i < arr.length ; i += 2 ) {
				String s1 = arr[ i + 1 ];
				m.put( arr[ i ] , isNumeric( s1 ) ? s1.indexOf( "." ) == -1 ? i( s1 ) : f( s1 ) : s1 );
			}
		}
		return m;
	}

	static public Map toMap( Object o ) {
		return o != null ? ( o instanceof Map ) ? ( Map ) o : Collections.EMPTY_MAP : Collections.EMPTY_MAP;
	}

	static public Map toMap( final Object ... args ) {
		Map m = new LinkedHashMap( );
		if ( args.length % 2 == 0 ) {
			for ( int i = 0 ; i < args.length ; i += 2 ) {
				m.put( args[ i ] , args[ i + 1 ] );
			}
		}
		return m;
	}

	static public String s( String o ) {
		return ( o != null ) ? o : "";
	}

	static Map< Class< ? > , Class< ? > > classmap = new HashMap< Class< ? > , Class< ? > >( ) {
		{
			put( Integer.class , int.class );
			put( Float.class , float.class );
			put( Double.class , double.class );
			put( Boolean.class , boolean.class );
			put( Character.class , char.class );
			put( Long.class , long.class );
		}
	};

	static public void sleep( long theMillis ) {
		try {
			Thread.sleep( theMillis );
		} catch ( Exception e ) {

		}
	}

	static public String timestamp( ) {
		return new SimpleDateFormat( "yyyyMMdd-HHmmss" ).format( new Date( ) );
	}

	/* add Objects with Annotation */

	public static Logger logger( ) {
		return logger;
	}

	@Retention( RetentionPolicy.RUNTIME ) @interface Invisible {
	}

	@Retention( RetentionPolicy.RUNTIME ) @interface Layout {
	}

}