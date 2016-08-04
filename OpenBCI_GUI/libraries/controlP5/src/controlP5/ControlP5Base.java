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

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import processing.core.PApplet;
import processing.event.Event;

import static controlP5.Controller.*;

/**
 * The ControlP5Base supports the ControlP5 class and
 * implements all adder methods to add controllers to
 * controlP5.
 */
@SuppressWarnings( { "unchecked" , "rawtypes" } ) public class ControlP5Base extends ControlP5Legacy implements ControlP5Constants {

	protected ControlP5 cp5;
	protected ControllerProperties _myProperties;
	private ControllerAutomator _myAutomator;
	protected Map< Object , ArrayList< ControllerInterface< ? >>> _myObjectToControllerMap = new HashMap< Object , ArrayList< ControllerInterface< ? >>>( );
	protected Map< String , FieldChangedListener > _myFieldChangedListenerMap = new HashMap< String , FieldChangedListener >( );
	protected Map< KeyCode , List< ControlKey >> keymap = new HashMap< KeyCode , List< ControlKey >>( );
	protected ControllerGroup< ? > currentGroupPointer;
	protected boolean isCurrentGroupPointerClosed = true;
	protected int autoDirection = HORIZONTAL;

	public Tab getDefaultTab( ) {
		return ( Tab ) cp5.controlWindow.getTabs( ).get( 1 );
	}

	protected void init( ControlP5 theControlP5 ) {
		super.init( theControlP5 );
		cp5 = theControlP5;
		_myProperties = new ControllerProperties( cp5 );
		_myAutomator = new ControllerAutomator( cp5 );
		currentGroupPointer = cp5.controlWindow.getTab( "default" );
	}

	public ControllerLayout getLayout( ) {
		return new ControllerLayout( cp5 );
	}

	public Tab addTab( String theName ) {
		for ( int i = 0 ; i < cp5.getWindow( ).getTabs( ).size( ) ; i++ ) {
			if ( cp5.getWindow( ).getTabs( ).get( i ).getName( ).equals( theName ) ) {
				return ( Tab ) cp5.getWindow( ).getTabs( ).get( i );
			}
		}
		Tab myTab = new Tab( cp5 , cp5.getWindow( ) , theName );
		cp5.getWindow( ).getTabs( ).add( myTab );
		return myTab;
	}

	/**
	 * A Bang triggers an event without passing a value.
	 */
	public Bang addBang( final String theName ) {
		return addBang( null , theName );
	}

	public Bang addBang( final Object theObject , final String theName ) {
		return addBang( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	/**
	 * Triggers an event and passing a value.
	 */

	public Button addButton( String theName ) {
		return addButton( null , theName );
	}

	public Button addButton( final Object theObject , final String theName ) {
		return addButton( theObject , theObject != null ? theObject.toString( ) : "" , theName , 1 );
	}

	public ButtonBar addButtonBar( String theName ) {
		return addButtonBar( null , theName );
	}

	public ButtonBar addButtonBar( final Object theObject , final String theName ) {
		return addButtonBar( theObject , theObject != null ? theObject.toString( ) : "" , theName , 1 );
	}

	/**
	 * Toggles a boolean field or passes a value when
	 * triggered.
	 */
	public Toggle addToggle( final Object theObject , final String theName ) {
		return addToggle( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	public Toggle addToggle( final String theName ) {
		return addToggle( null , theName );
	}

	/**
	 * Adds a default slider with a default width of 100 and
	 * height of 10. the default value range is from 0-100.
	 * 
	 * By default it will be added to the default tab of the
	 * main window. Sliders can be arranged vertically and
	 * horizontally depending on their width and height. The
	 * look of a sliders control can either be a bar or a
	 * handle. you can add tickmarks to a slider or use the
	 * default free-control setting. A slider can be
	 * controller by mouse click, drag or mouse-wheel.
	 */
	public Slider addSlider( String theName ) {
		return addSlider( null , theName );
	}

	public Slider addSlider( Object theObject , String theName ) {
		return addSlider( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	/**
	 * A range controller, a slider that allows control on
	 * both ends of the slider.
	 */
	public Range addRange( final String theName ) {
		return addRange( theName , 0 , 100 , 0 , 100 , 0 , 0 , 100 , 10 );
	}

	public Range addRange( final Object theObject , final String theName ) {
		return addRange( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 100 , 0 , 100 , 0 , 0 , 100 , 10 );
	}

	public Numberbox addNumberbox( String theName ) {
		return addNumberbox( null , theName );
	}

	public Numberbox addNumberbox( Object theObject , String theName ) {
		return addNumberbox( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	/**
	 * Knobs can use limited and endless revolutions, custom
	 * angles and starting points. There are 2 control areas
	 * for a knob, an area closer to the edge allows
	 * 'click-and-adjust' control, a click and drag action
	 * at the inside allows to gradually change the value of
	 * a know when dragged. A knob can be controller by
	 * mouse click, drag or mouse-wheel.
	 */
	public Knob addKnob( String theName ) {
		return addKnob( theName , 0 , 100 );
	}

	public Knob addKnob( Object theObject , String theName ) {
		return addKnob( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	/**
	 * Matrix is a 2-D matrix controller using toggle
	 * controllers in a rows and a columns setup. useful for
	 * software drum machines.
	 */

	public Matrix addMatrix( final String theName ) {
		return addMatrix( theName , 10 , 10 , 0 , 0 , 100 , 100 );
	}

	public Matrix addMatrix( final Object theObject , final String theName ) {
		return addMatrix( theObject , theObject != null ? theObject.toString( ) : "" , theName , 10 , 10 , 0 , 0 , 100 , 100 );
	}

	/**
	 * Adds a 2D slider to controlP5. A 2D slider is a 2D
	 * area with 1 cursor returning its xy coordinates.
	 */
	public Slider2D addSlider2D( final String theName ) {
		return addSlider2D( null , theName );
	}

	public Slider2D addSlider2D( final Object theObject , final String theName ) {
		return addSlider2D( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 100 , 0 , 100 , 0 , 0 , 0 , 0 , 100 , 100 );
	}

	public Textlabel addTextlabel( final String theName ) {
		return addTextlabel( theName , "" , 0 , 0 );
	}

	/**
	 * A Textarea is a label without any controller
	 * functionality and can be used to leave notes,
	 * headlines, etc when extending the dedicated area of
	 * the Textrea, a scrollbar is added on the right.
	 */
	public Textarea addTextarea( final String theName ) {
		return addTextarea( theName , "" , 0 , 0 , 200 , 100 );
	}

	// TODO
	// addTextarea theObject

	/**
	 * A Textfield allows single line text input. If text
	 * goes beyond the edges of a Textfield box, the text
	 * will automatically scroll. Use Arrow keys to navigate
	 * back and forth.
	 */

	public Textfield addTextfield( final String theIndex ) {
		return addTextfield( theIndex , 0 , 0 , 200 , 20 );
	}

	public Textfield addTextfield( final Object theObject , final String theIndex ) {
		return addTextfield( theObject , theObject != null ? theObject.toString( ) : "" , theIndex , 0 , 0 , 200 , 20 );
	}

	/**
	 * Use radio buttons for multiple choice options.
	 */
	public RadioButton addRadioButton( final String theName ) {
		return addRadioButton( null , theName );
	}

	public RadioButton addRadioButton( final Object theObject , final String theName ) {
		return addRadioButton( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 0 );
	}

	/**
	 * Use a checkbox for single choice options.
	 */
	public CheckBox addCheckBox( final String theName ) {
		return addCheckBox( theName , 0 , 0 );
	}

	public CheckBox addCheckBox( final Object theObject , final String theName ) {
		return addCheckBox( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 0 );
	}

	/**
	 * the ScrollableList replaces the DropwdownList and
	 * ListBox, the type for a ScrollableList can be set
	 * with setType(ControlP5.DROPDOWN | ControlP5.LIST).
	 */
	public ScrollableList addScrollableList( final String theName ) {
		return addScrollableList( theName , 0 , 0 , 100 , 200 );
	}

	public ScrollableList addScrollableList( final Object theObject , String theName ) {
		return addScrollableList( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 0 , 100 , 100 );
	}

	/**
	 * Multilist is a tree like menu.
	 */
	public MultiList addMultiList( final String theName ) {
		return addMultiList( null , theName );
	}

	public MultiList addMultiList( final Object theObject , final String theName ) {
		return addMultiList( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 0 , 100 , 100 );
	}

	public ColorWheel addColorWheel( final String theName ) {
		return addColorWheel( null , theName );
	}

	public ColorWheel addColorWheel( final Object theObject , final String theName ) {
		return addColorWheel( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 0 , 200 );
	}

	/**
	 * adds a simple RGBA colorpicker.
	 */
	public ColorPicker addColorPicker( final String theName ) {
		return addColorPicker( null , theName );
	}

	public ColorPicker addColorPicker( final Object theObject , final String theName ) {
		return addColorPicker( theObject , theObject != null ? theObject.toString( ) : "" , theName , 0 , 0 , 255 , 10 );
	}

	public Println addConsole( Textarea theTextarea ) {
		return new Println( theTextarea );
	}

	/**
	 * returns the current framerate of the running sketch.
	 */
	public FrameRate addFrameRate( ) {
		FrameRate myController = new FrameRate( cp5 , ( Tab ) cp5.controlWindow.getTabs( ).get( 1 ) , "-" , 0 , 4 );
		cp5.register( null , "" , myController );
		return myController;
	}

	/**
	 * adds chart support to display float array based data.
	 */
	public Chart addChart( String theName ) {
		return addChart( theName , 0 , 0 , 200 , 100 );
	}

	/**
	 * A controller group can be used to group controllers
	 * for a better organization of single controllers.
	 */

	public Group addGroup( String theName ) {
		return addGroup( theName , 0 , 0 );
	}

	public Group addGroup( final Object theObject , final String theName ) {
		return addGroup( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	public Accordion addAccordion( final String theName ) {
		return addAccordion( null , "" , theName );
	}

	public Accordion addAccordion( final Object theObject , final String theName ) {
		return addAccordion( theObject , theObject != null ? theObject.toString( ) : "" , theName );
	}

	protected void setCurrentPointer( ControllerGroup< ? > theGroup ) {
		currentGroupPointer = theGroup;
		isCurrentGroupPointerClosed = false;
	}

	protected void releaseCurrentPointer( ControllerGroup< ? > theGroup ) {
		if ( isCurrentGroupPointerClosed == false ) {
			currentGroupPointer = theGroup;
			isCurrentGroupPointerClosed = true;
		} else {
			ControlP5.logger( ).warning( "use .end() first before using .begin() again." );
		}
	}

	public void setAutoAddDirection( int theDirection ) {
		if ( theDirection == HORIZONTAL ) {
			autoDirection = HORIZONTAL;
			return;
		}
		autoDirection = VERTICAL;
	}

	public void setAutoSpacing( ) {
		set( Controller.autoSpacing , 10 , 10 );
	}

	public void setAutoSpacing( float theX , float theY ) {
		set( Controller.autoSpacing , theX , theY );
	}

	public void setAutoSpacing( float theX , float theY , float theZ ) {
		setAutoSpacing( theX , theY );
	}

	@SuppressWarnings( "static-access" ) protected void linebreak( Controller< ? > theController , boolean theFlag , int theW , int theH , float[] theSpacing ) {
		if ( x( currentGroupPointer.autoPosition ) + x( theController.autoSpacing ) + theW > cp5.papplet.width ) {
			float x = x( currentGroupPointer.autoPosition ) + currentGroupPointer.autoPositionOffsetX;
			float y = y( currentGroupPointer.autoPosition ) + currentGroupPointer.tempAutoPositionHeight;
			set( currentGroupPointer.autoPosition , x , y );
			currentGroupPointer.tempAutoPositionHeight = 0;
			Controller.set( theController.position , Controller.x( currentGroupPointer.autoPosition ) , Controller.y( currentGroupPointer.autoPosition ) );
			theFlag = false;
		}

		if ( theFlag == true ) {
			float y = y( currentGroupPointer.autoPosition ) + currentGroupPointer.tempAutoPositionHeight;
			set( currentGroupPointer.autoPosition , currentGroupPointer.autoPositionOffsetX , y );
			currentGroupPointer.tempAutoPositionHeight = 0;

		} else {
			if ( theController instanceof Slider ) {
				float x = x( currentGroupPointer.autoPosition ) + theController.getCaptionLabel( ).getWidth( );
				float y = y( currentGroupPointer.autoPosition );
				set( currentGroupPointer.autoPosition , x , y );
			}
			float x = x( currentGroupPointer.autoPosition ) + x( theController.autoSpacing ) + theW;
			float y = y( currentGroupPointer.autoPosition );
			set( currentGroupPointer.autoPosition , x , y );
			if ( ( theH + y( theSpacing ) ) > currentGroupPointer.tempAutoPositionHeight ) {
				currentGroupPointer.tempAutoPositionHeight = theH + y( theSpacing );
			}
		}
	}

	public ControlP5Base addControllersFor( PApplet theApplet ) {
		addControllersFor( "" , theApplet );
		return cp5;
	}

	/**
	 * Adds controllers for a specific object using
	 * annotations.
	 * <p>
	 * Uses a forward slash delimited address, for example:
	 * </p>
	 * <p>
	 * lets say the theAddressSpace parameter is set to
	 * "hello", and the Object (second parameter) contains
	 * an annotated field "x", addControllersFor("hello",
	 * o); will add a controller for field x with address
	 * /hello/x This address can be used with
	 * getController("/hello/x") to access the controller of
	 * that particular Object and field.
	 * </p>
	 */
	public ControlP5Base addControllersFor( final String theAddressSpace , Object t ) {
		_myAutomator.addControllersFor( theAddressSpace , t );
		return cp5;
	}

	public Object getObjectForController( ControllerInterface theController ) {
		for ( Iterator it = _myObjectToControllerMap.entrySet( ).iterator( ) ; it.hasNext( ) ; ) {
			Map.Entry entry = ( Map.Entry ) it.next( );
			Object key = entry.getKey( );
			ArrayList< ControllerInterface > value = ( ArrayList< ControllerInterface > ) entry.getValue( );
			for ( ControllerInterface c : value ) {
				if ( c.equals( theController ) ) {
					return key;
				}
			}
		}
		return null;
	}

	public ControlP5Base setPosition( int theX , int theY , Object o ) {
		if ( o != null && _myObjectToControllerMap.containsKey( o ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( o );
			for ( ControllerInterface< ? > c : cs ) {
				int x = ( int ) x( c.getPosition( ) ) + theX;
				int y = ( int ) y( c.getPosition( ) ) + theY;
				c.setPosition( x , y );
			}
		}
		return cp5;
	}

	public ControlP5Base hide( Object theObject ) {
		if ( theObject != null && _myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				c.hide( );
			}
		}
		return cp5;
	}

	public ControlP5Base show( Object theObject ) {
		if ( theObject != null && _myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				c.show( );
			}
		}
		return cp5;
	}

	/**
	 * for internal use only. use Controller.remove()
	 * instead.
	 * 
	 * @param theObject
	 * @return
	 */
	public ControlP5Base remove( Object theObject ) {
		if ( theObject != null && _myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				c.remove( );
			}
		}
		return cp5;
	}

	public ControlP5Base setColor( CColor theColor , Object theObject ) {
		if ( _myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				c.setColor( theColor );
			}
		}
		return cp5;
	}

	public ControlP5Base listenTo( String theFieldName , Object theObject ) {
		String key = theObject.hashCode( ) + "" + theFieldName.hashCode( );
		FieldChangedListener value = new FieldChangedListener( cp5 );
		value.listenTo( theObject , theFieldName );
		_myFieldChangedListenerMap.put( key , value );
		return cp5;
	}

	public ControlP5Base stopListeningTo( String theFieldName , Object theObject ) {
		String key = theObject.hashCode( ) + "" + theFieldName.hashCode( );
		_myFieldChangedListenerMap.remove( key );
		return cp5;
	}

	public ControlP5Base moveTo( ControllerGroup< ? > theController , Object theObject ) {
		if ( _myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = _myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				c.moveTo( theController );
			}
		}
		return cp5;
	}

	/* Properties */

	public ControllerProperties getProperties( ) {
		return _myProperties;
	}

	public void removeProperty( ControllerInterface< ? > theController ) {
		_myProperties.remove( theController );
	}

	/**
	 * prints a list of public methods of requested class
	 * into the console. You can specify patterns that will
	 * print methods found with only these particular
	 * patterns in their name.
	 * <p>
	 * printed Format: returnType methodName(parameter type)
	 */
	public static void printPublicMethodsFor( Class< ? > theClass , String ... thePattern ) {
		Set< String > set = getPublicMethodsFor( theClass , true , thePattern );
		String str = "";

		str += "/**\n";
		str += "* ControlP5 " + theClass.getSimpleName( ) + "\n";
		str += "*\n";
		str += "*\n";
		str += "* find a list of public methods available for the " + theClass.getSimpleName( ) + " Controller\n";
		str += "* at the bottom of this sketch.\n";
		str += "*\n";
		str += "* by Andreas Schlegel, 2012\n";
		str += "* www.sojamo.de/libraries/controlp5\n";
		str += "*\n";
		str += "*/\n\n";
		str += "/*\n";
		str += "a list of all methods available for the " + theClass.getSimpleName( ) + " Controller\n";
		str += "use ControlP5.printPublicMethodsFor(" + theClass.getSimpleName( ) + ".class);\n";
		str += "to print the following list into the console.\n\n";
		str += "You can find further details about class " + theClass.getSimpleName( ) + " in the javadoc.\n\n";
		str += "Format:\n";
		str += "ClassName : returnType methodName(parameter type)\n\n\n";
		for ( String s : set ) {
			str += s + "\n";
		}
		str += "\n\n*/\n\n";
		println( str );
	}

	public static void printPublicMethodsFor( Class< ? > theClass ) {
		printPublicMethodsFor( theClass , "" );
	}

	public static Set< String > getPublicMethodsFor( Class< ? > theClass ) {
		return getPublicMethodsFor( theClass , true , "" );
	}

	public static Set< String > getPublicMethodsFor( Class< ? > theClass , String ... thePattern ) {
		return getPublicMethodsFor( theClass , true , thePattern );
	}

	public static Set< String > getPublicMethodsFor( Class< ? > theClass , boolean theFlag ) {
		return getPublicMethodsFor( theClass , true , "" );
	}

	public static Set< String > getPublicMethodsFor( Class< ? > theClass , boolean isSuperclass , String ... thePattern ) {
		Set< String > s = new TreeSet< String >( );

		Class< ? > c = theClass;
		while ( c != null ) {
			for ( Method method : c.getDeclaredMethods( ) ) {
				if ( !method.isAnnotationPresent( Deprecated.class ) && !method.isAnnotationPresent( ControlP5.Invisible.class ) && method.getModifiers( ) == Modifier.PUBLIC ) {
					for ( String p : thePattern ) {
						if ( p.length( ) > 0 ) {
							if ( !method.getName( ).toLowerCase( ).contains( p.toLowerCase( ) ) ) {
								continue;
							}
						}
						String params = "";
						for ( Class< ? > t : method.getParameterTypes( ) ) {
							params += t.getSimpleName( ) + ", ";
						}
						if ( params.length( ) > 0 ) {
							params = params.substring( 0 , params.length( ) - 2 );
						}
						s.add( c.getCanonicalName( ) + " : " + method.getReturnType( ).getSimpleName( ).replace( "Object" , theClass.getSimpleName( ) ) + " " + method.getName( ) + "(" + params + ") " );
					}
				}
			}

			if ( isSuperclass ) {
				c = c.getSuperclass( );
			} else {
				c = null;
			}
		}
		return s;
	}

	public int getKeyCode( ) {
		return cp5.getWindow( ).keyCode;
	}

	public char getKey( ) {
		return cp5.getWindow( ).key;
	}

	private char[] fromIntToChar( int ... theChar ) {
		char[] n = new char[ theChar.length ];
		for ( int i = 0 ; i < n.length ; i++ ) {
			if ( theChar[ i ] >= 'a' && theChar[ i ] <= 'z' ) {
				theChar[ i ] -= 32;
			}
			n[ i ] = ( char ) theChar[ i ];
		}
		return n;
	}

	public ControlP5 removeKeyFor( ControlKey theKey , int ... theChar ) {
		removeKeyFor( theKey , fromIntToChar( theChar ) );
		return cp5;
	}

	public ControlP5 mapKeyFor( ControlKey theKey , Object ... os ) {
		List< Integer > l = new ArrayList< Integer >( );
		for ( Object o : os ) {
			if ( o instanceof Integer ) {
				l.add( ( int ) ( Integer ) o );
			} else if ( o instanceof Character ) {
				char c = ( ( Character ) o );
				if ( c >= 'a' && c <= 'z' ) {
					c -= 32;
				}
				l.add( ( int ) c );
			}
		}

		char[] n = new char[ l.size( ) ];
		for ( int i = 0 ; i < l.size( ) ; i++ ) {
			n[ i ] = ( char ) ( ( int ) l.get( i ) );
		}

		KeyCode kc = new KeyCode( n );
		if ( !keymap.containsKey( kc ) ) {
			keymap.put( kc , new ArrayList< ControlKey >( ) );
		}
		keymap.get( kc ).add( theKey );
		cp5.enableShortcuts( );
		return cp5;
	}

	public ControlP5 removeKeyFor( ControlKey theKey , char ... theChar ) {
		List< ControlKey > l = keymap.get( new KeyCode( theChar ) );
		if ( l != null ) {
			l.remove( theKey );
		}
		return cp5;
	}

	public ControlP5 removeKeysFor( char ... theChar ) {
		keymap.remove( new KeyCode( theChar ) );
		return cp5;
	}

	public ControlP5 removeKeysFor( int ... theChar ) {
		removeKeysFor( fromIntToChar( theChar ) );
		return cp5;
	}

	protected int modifiers;

	public boolean isShiftDown( ) {
		return ( modifiers & Event.SHIFT & ( cp5.isShortcuts( ) ? -1 : 1 ) ) != 0;
	}

	public boolean isControlDown( ) {
		return ( modifiers & Event.CTRL & ( cp5.isShortcuts( ) ? -1 : 1 ) ) != 0;
	}

	public boolean isMetaDown( ) {
		return ( modifiers & Event.META & ( cp5.isShortcuts( ) ? -1 : 1 ) ) != 0;
	}

	public boolean isAltDown( ) {
		return ( modifiers & Event.ALT & ( cp5.isShortcuts( ) ? -1 : 1 ) ) != 0;
	}

	static class KeyCode {

		final char[] chars;

		KeyCode( char ... theChars ) {
			chars = theChars;
			Arrays.sort( chars );
		}

		public String toString( ) {
			String s = "";
			for ( char c : chars ) {
				s += c + "(" + ( ( int ) c ) + ") ";
			}
			return s;
		}

		public int size( ) {
			return chars.length;
		}

		public char[] getChars( ) {
			return chars;
		}

		public char get( int theIndex ) {
			if ( theIndex >= 0 && theIndex < size( ) ) {
				return chars[ theIndex ];
			}
			return 0;
		}

		public boolean equals( Object obj ) {
			if ( ! ( obj instanceof KeyCode ) ) {
				return false;
			}

			KeyCode k = ( KeyCode ) obj;

			if ( k.size( ) != size( ) ) {
				return false;
			}

			for ( int i = 0 ; i < size( ) ; i++ ) {
				if ( get( i ) != k.get( i ) ) {
					return false;
				}
			}
			return true;
		}

		boolean contains( char n ) {
			for ( char c : chars ) {
				if ( n == c ) {
					return true;
				}
			}
			return false;
		}

		public int hashCode( ) {
			int hashCode = 0;
			int n = 1;
			for ( char c : chars ) {
				hashCode += c + Math.pow( c , n++ );
			}
			return hashCode;
		}
	}

}
