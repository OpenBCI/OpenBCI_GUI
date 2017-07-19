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

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * Used to convert Annotations into individual controllers this method of creating controllers is
 * derived from cp5magic by Karsten Schmidt http://hg.postspectacular.com/cp5magic/wiki/Home
 */

class ControllerAutomator {

	static Map< Set< Class< ? >> , Class< ? extends Controller< ? >>> mapping = new HashMap< Set< Class< ? >> , Class< ? extends Controller< ? >>>( );

	static {
		mapping.put( makeKey( boolean.class ) , Toggle.class );
		mapping.put( makeKey( int.class ) , Slider.class );
		mapping.put( makeKey( float.class ) , Slider.class );
		mapping.put( makeKey( String.class ) , Textfield.class );
	}

	static Map< String , Class< ? extends ControllerInterface< ? >>> types = new HashMap< String , Class< ? extends ControllerInterface< ? >>>( );

	static {
		types.put( "slider" , Slider.class );
		types.put( "knob" , Knob.class );
		types.put( "numberbox" , Numberbox.class );
		types.put( "toggle" , Toggle.class );
		types.put( "bang" , Bang.class );
		types.put( "toggle" , Toggle.class );
		types.put( "textfield" , Textfield.class );
		types.put( "label" , Textlabel.class );
		types.put( "textlabel" , Textlabel.class );
		types.put( "list" , ListBox.class );
		types.put( "dropdown" , DropdownList.class );
		types.put( "scrollable" , ScrollableList.class );
	}

	static Set< Class< ? >> makeKey( Class< ? > ... cs ) {
		Set< Class< ? >> set = new HashSet< Class< ? >>( );
		for ( Class< ? > c : cs ) {
			set.add( c );
		}
		return set;
	}

	private ControlP5 cp5;

	ControllerAutomator( ControlP5 c ) {
		cp5 = c;
	}

	private Object[] getParameters( Class< ? >[] cs , String v ) {

		if ( cs[ 0 ] == int.class ) {
			return new Object[] { i( v , 0 ) };
		} else if ( cs[ 0 ] == float.class ) {
			return new Object[] { Float.parseFloat( v ) };
		} else if ( cs[ 0 ] == String.class ) {
			return new Object[] { v };
		} else if ( cs[ 0 ] == boolean.class ) {
			return new Object[] { Boolean.parseBoolean( v ) };
		}
		return new Object[ 0 ];
	}

	/**
	 * analyzes an object and adds fields with ControlElement annotations to controlP5.
	 * 
	 */
	void addControllersFor( final String theAddressSpace , final Object t ) {
		System.out.println("OKOK");
		if ( t instanceof List< ? > ) {
			return;
		}

		Class< ? > c = t.getClass( );

		Field[] fs = c.getFields( );

		Method[] ms = c.getMethods( );

		Map< ControllerInterface , Integer > controllersIndexed = new HashMap< ControllerInterface , Integer >( );

		for ( Method m : ms ) {

			int zindex = 0;

			if ( m.isAnnotationPresent( ControlElement.class ) ) {

				ControlElement ce = m.getAnnotation( ControlElement.class );

				Map< String , String > params = new HashMap< String , String >( );

				Class< ? extends ControllerInterface< ? >> type = null;

				for ( String s : ce.properties( ) ) {
					String[] a = s.split( "=" );
					if ( a[ 0 ].startsWith( "type" ) ) {
						type = types.get( a[ 1 ].toLowerCase( ) );
					} else if ( a[ 0 ].equals( "z-index" ) ) {
						zindex = i( a[ 1 ] , 0 );
					} else {
						params.put( "set" + capitalize( a[ 0 ] ) , a[ 1 ] );
					}
				}

				if ( type == null ) {
					type = mapping.get( makeKey( m.getParameterTypes( ) ) );
				}
				if ( type != null ) {

					ControllerInterface< ? > cntr = null;

					if ( params.containsKey( "setItems" ) ) {

						if ( type.equals( ListBox.class ) ) {

							cntr = cp5.addScrollableList( t , theAddressSpace , m.getName( ) , ce.x( ) , ce.y( ) , 100 , 100 );
							( ( ScrollableList ) cntr ).addItems( params.get( "setItems" ).split( "," ) );
							( ( ScrollableList ) cntr ).setOpen( true );
							( ( ScrollableList ) cntr ).setType(ScrollableList.LIST);

						} else if ( type.equals( DropdownList.class ) ) {

							cntr = cp5.addScrollableList( t , theAddressSpace , m.getName( ) , ce.x( ) , ce.y( ) , 100 , 100 );
							( ( ScrollableList ) cntr ).addItems( params.get( "setItems" ).split( "," ) );
							( ( ScrollableList ) cntr ).setOpen( false );
							( ( ScrollableList ) cntr ).setType(ScrollableList.DROPDOWN);
							
						} else if ( type.equals( ScrollableList.class ) ) {

							cntr = cp5.addScrollableList( t , theAddressSpace , m.getName( ) , ce.x( ) , ce.y( ) , 100 , 100 );
							( ( ScrollableList ) cntr ).addItems( params.get( "setItems" ).split( "," ) );

						}

					} else {
						cntr = cp5.addController( t , theAddressSpace , m.getName( ) , type , ce.x( ) , ce.y( ) );
					}

					controllersIndexed.put( cntr , zindex );

					if ( ce.label( ).length( ) > 0 ) {
						cntr.setCaptionLabel( ce.label( ) );
					}

					for ( Iterator< String > i = params.keySet( ).iterator( ) ; i.hasNext( ) ; ) {
						String k = ( String ) i.next( );
						String v = ( String ) params.get( k );
						for ( Method method : cntr.getClass( ).getMethods( ) ) {
							if ( method.getName( ).equals( k ) ) {
								try {
									Object[] os = getParameters( method.getParameterTypes( ) , v );
									method.setAccessible( true );
									method.invoke( cntr , os );
								} catch ( Exception e ) {
									/* TODO is thrown when running ControlP5annotation example */
									// ControlP5.logger.severe( e.toString( ) );
								}
							}
						}
					}
				}
			}
		}

		for ( Field f : fs ) {

			int zindex = 0;

			if ( f.isAnnotationPresent( ControlElement.class ) ) {

				ControlElement ce = f.getAnnotation( ControlElement.class );

				Map< String , String > params = new HashMap< String , String >( );

				Class< ? extends ControllerInterface< ? >> type = null;

				for ( String s : ce.properties( ) ) {
					String[] a = s.split( "=" );
					if ( a[ 0 ].startsWith( "type" ) ) {
						type = types.get( a[ 1 ].toLowerCase( ) );
					} else if ( a[ 0 ].equals( "z-index" ) ) {
						zindex = i( a[ 1 ] , 0 );
					} else {
						params.put( "set" + capitalize( a[ 0 ] ) , a[ 1 ] );
					}
				}

				ControllerInterface< ? > cntr = null;

				f.setAccessible( true );

				if ( f.getType( ) == float.class || f.getType( ) == int.class ) {

					if ( type == Knob.class ) {

						cntr = cp5.addKnob( t , theAddressSpace , f.getName( ) );

					} else if ( type == Numberbox.class ) {

						cntr = cp5.addNumberbox( t , theAddressSpace , f.getName( ) );

					} else {
						cntr = cp5.addSlider( t , theAddressSpace , f.getName( ) );

					}
					try {
						if ( f.getType( ) == float.class ) {
							cntr.setValue( f.getFloat( t ) );
						} else {
							cntr.setValue( f.getInt( t ) );
						}
					} catch ( Exception e ) {
						ControlP5.logger.severe( e.toString( ) );
					}
				} else if ( f.getType( ) == String.class ) {
					if ( type == Textlabel.class ) {
						String s = "";
						try {
							s = "" + f.get( t );
							if ( f.get( t ) == null ) {
								s = ce.label( );
							}
						} catch ( Exception e ) {
						}
						cntr = cp5.addTextlabel( t , theAddressSpace , f.getName( ) , s );
					} else {
						cntr = cp5.addTextfield( t , theAddressSpace , f.getName( ) );
					}
				} else if ( f.getType( ) == boolean.class ) {
					cntr = cp5.addToggle( t , theAddressSpace , f.getName( ) );
					try {
						cntr.setValue( f.getBoolean( t ) ? 1 : 0 );
					} catch ( Exception e ) {
						ControlP5.logger.severe( e.toString( ) );
					}
				}

				if ( cntr != null ) {

					controllersIndexed.put( cntr , zindex );

					if ( ce.label( ).length( ) > 0 ) {
						cntr.setCaptionLabel( ce.label( ) );
					}
					cntr.setPosition( ce.x( ) , ce.y( ) );

					for ( Iterator< String > i = params.keySet( ).iterator( ) ; i.hasNext( ) ; ) {
						String k = ( String ) i.next( );
						String v = ( String ) params.get( k );
						for ( Method method : cntr.getClass( ).getMethods( ) ) {
							if ( method.getName( ).equals( k ) ) {
								try {
									Object[] os = getParameters( method.getParameterTypes( ) , v );
									method.setAccessible( true );
									method.invoke( cntr , os );
								} catch ( Exception e ) {
									ControlP5.logger.severe( e.toString( ) );
								}
							}
						}
					}
				}
			}
		}

		/* */
		for ( Entry< ControllerInterface , Integer > entry : entriesSortedByValues( controllersIndexed ) ) {
			entry.getKey( ).bringToFront( );
		}
	}

	private static < K , V extends Comparable< ? super V >> List< Entry< K , V >> entriesSortedByValues( Map< K , V > map ) {

		List< Entry< K , V >> sortedEntries = new ArrayList< Entry< K , V >>( map.entrySet( ) );

		Collections.sort( sortedEntries , new Comparator< Entry< K , V >>( ) {
			@Override
			public int compare( Entry< K , V > e1 , Entry< K , V > e2 ) {
				return e1.getValue( ).compareTo( e2.getValue( ) );
			}
		} );

		return sortedEntries;
	}

	/**
	 * capitalizes a string.
	 * 
	 * @param theString
	 * @return String
	 */
	static String capitalize( String theString ) {
		final StringBuilder result = new StringBuilder( theString.length( ) );
		String[] words = theString.split( "\\s" );
		for ( int i = 0 , l = words.length ; i < l ; ++i ) {
			if ( i > 0 )
				result.append( " " );
			result.append( Character.toUpperCase( words[ i ].charAt( 0 ) ) ).append( words[ i ].substring( 1 ) );
		}
		return result.toString( );
	}

	private int i( String o , int theDefault ) {
		return isNumeric( o ) ? Integer.parseInt( o ) : isHex( o ) ? o.length( ) == 6 ? ( int ) Long.parseLong( "FF" + o , 16 ) : ( int ) Long.parseLong( o , 16 ) : theDefault;
	}

	private boolean isNumeric( String str ) {
		return str.matches( "(-|\\+)?\\d+(\\.\\d+)?" );
	}

	private boolean isHex( String str ) {
		// (?:0[xX])?[0-9a-fA-F]+ (This will match with or without 0x prefix)
		// System.out.println( "isHex? " + str + " " + str.matches( "[\\dA-Fa-f]+" ) );
		return str.matches( "[\\dA-Fa-f]+" );
	}
}
