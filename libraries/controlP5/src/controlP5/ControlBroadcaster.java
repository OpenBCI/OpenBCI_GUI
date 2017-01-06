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
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.AbstractMap.SimpleEntry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * The ControlBroadcaster handles all controller value changes and distributes them accordingly to
 * its listeners. The ControlBroadcaster is primarily for internal use only but can be accessed
 * through an instance of the ControlP5 class. Instead of accessing the ControlBroadcaster directly,
 * use the convenience methods available from the ControlP5 class.
 * 
 * @see controlP5.ControlP5#getControlBroadcaster()
 */
public class ControlBroadcaster {

	private int _myControlEventType = ControlP5Constants.INVALID;
	private ControllerPlug _myControlEventPlug = null;
	private ControllerPlug _myControllerCallbackEventPlug = null;
	private ControlP5 cp5;
	private String _myEventMethod = "controlEvent";
	private String _myControllerCallbackEventMethod = "controlEvent";
	private ArrayList< ControlListener > _myControlListeners;
	private Set< Entry< CallbackListener , Controller< ? >>> _myControllerCallbackListeners;
	private static boolean setPrintStackTrace = true;
	private static boolean ignoreErrorMessage = false;
	private static Map< Class< ? > , Field[] > fieldcache = new HashMap< Class< ? > , Field[] >( );
	private static Map< Class< ? > , Method[] > methodcache = new HashMap< Class< ? > , Method[] >( );
	boolean broadcast = true;

	protected ControlBroadcaster( ControlP5 theControlP5 ) {
		cp5 = theControlP5;
		_myControlListeners = new ArrayList< ControlListener >( );
		_myControllerCallbackListeners = new HashSet< Entry< CallbackListener , Controller< ? >>>( );
		_myControlEventPlug = checkObject( cp5.papplet , getEventMethod( ) , new Class[] { ControlEvent.class } );
		_myControllerCallbackEventPlug = checkObject( cp5.papplet , _myControllerCallbackEventMethod , new Class[] { CallbackEvent.class } );
		if ( _myControlEventPlug != null ) {
			_myControlEventType = ControlP5Constants.METHOD;
		}
	}

	public ControlBroadcaster addListener( ControlListener ... theListeners ) {
		for ( ControlListener l : theListeners ) {
			_myControlListeners.add( l );
		}
		return this;
	}

	public ControlBroadcaster removeListener( ControlListener ... theListeners ) {
		for ( ControlListener l : theListeners ) {
			_myControlListeners.remove( l );
		}
		return this;
	}

	/**
	 * Returns a ControlListener by index
	 * 
	 * @param theIndex
	 * @return
	 */
	public ControlListener getListener( int theIndex ) {
		if ( theIndex < 0 || theIndex >= _myControlListeners.size( ) ) {
			return null;
		}
		return _myControlListeners.get( theIndex );
	}

	/**
	 * Returns the size of the ControlListener list
	 * 
	 * @return
	 */
	public int listenerSize( ) {
		return _myControlListeners.size( );
	}

	public ControlBroadcaster addCallback( CallbackListener ... theListeners ) {
		for ( CallbackListener l : theListeners ) {
			_myControllerCallbackListeners.add( new SimpleEntry< CallbackListener , Controller< ? >>( l , new EmptyController( ) ) );
		}
		return this;
	}

	public ControlBroadcaster addCallback( CallbackListener theListener ) {
		_myControllerCallbackListeners.add( new SimpleEntry< CallbackListener , Controller< ? >>( theListener , new EmptyController( ) ) );
		return this;
	}

	/**
	 * Adds a CallbackListener for a list of controllers.
	 * 
	 * @param theListener
	 * @param theController
	 */
	public void addCallback( CallbackListener theListener , Controller< ? > ... theController ) {
		for ( Controller< ? > c : theController ) {
			_myControllerCallbackListeners.add( new SimpleEntry< CallbackListener , Controller< ? >>( theListener , c ) );
		}
	}

	public ControlBroadcaster removeCallback( CallbackListener ... theListeners ) {
		for ( CallbackListener c : theListeners ) {
			_myControllerCallbackListeners.remove( c );
		}
		return this;
	}

	public ControlBroadcaster removeCallback( CallbackListener theListener ) {
		_myControllerCallbackListeners.remove( theListener );
		return this;
	}

	/**
	 * Removes a CallbackListener for a particular controller
	 * 
	 * @param theController
	 */
	public ControlBroadcaster removeCallback( Controller< ? > ... theControllers ) {
		for ( Controller< ? > c : theControllers ) {
			for ( Entry< CallbackListener , Controller< ? >> entry : _myControllerCallbackListeners ) {
				if ( c != null && entry.getValue( ).equals( c ) ) {
					_myControllerCallbackListeners.remove( entry );
				}
			}
		}
		return this;
	}

	public ControlBroadcaster plug( Object theObject , final String theControllerName , final String theTargetMethod ) {
		plug( theObject , cp5.getController( theControllerName ) , theTargetMethod );
		return this;
	}

	public ControlBroadcaster plug( Object theObject , final Controller< ? > theController , final String theTargetMethod ) {
		if ( theController != null ) {
			ControllerPlug myControllerPlug = checkObject( theObject , theTargetMethod , ControlP5Constants.acceptClassList );
			if ( myControllerPlug == null ) {
				return this;
			} else {
				if ( theController.checkControllerPlug( myControllerPlug ) == false ) {
					theController.addControllerPlug( myControllerPlug );
				}
				return this;
			}
		}
		return this;
	}

	static Field[] getFieldsFor( Class< ? > theClass ) {
		if ( !fieldcache.containsKey( theClass ) ) {
			fieldcache.put( theClass , theClass.getDeclaredFields( ) );
		}
		return fieldcache.get( theClass );
	}

	static Method[] getMethodFor( Class< ? > theClass ) {
		if ( !methodcache.containsKey( theClass ) ) {
			methodcache.put( theClass , theClass.getMethods( ) );
		}
		return methodcache.get( theClass );
	}

	protected static ControllerPlug checkObject( final Object theObject , final String theTargetName , final Class< ? >[] theAcceptClassList ) {

		Class< ? > myClass = theObject.getClass( );

		Method[] myMethods = getMethodFor( myClass );

		for ( int i = 0 ; i < myMethods.length ; i++ ) {
			if ( ( myMethods[ i ].getName( ) ).equals( theTargetName ) ) {

				if ( myMethods[ i ].getParameterTypes( ).length == 1 ) {

					// hack to detect controlEvent(CallbackEvent) which is otherwise
					// overwritten by controlEvent(ControlEvent)
					if ( theAcceptClassList.length == 1 ) {
						if ( theAcceptClassList[ 0 ] == CallbackEvent.class ) {
							ControllerPlug cp = new ControllerPlug( CallbackEvent.class , theObject , theTargetName , ControlP5Constants.EVENT , -1 );
							if ( cp.getMethod( ) == null ) {
								return null;
							}
							return cp;
						}
					}
					if ( myMethods[ i ].getParameterTypes( )[ 0 ] == ControlP5Constants.controlEventClass ) {
						return new ControllerPlug( ControlEvent.class , theObject , theTargetName , ControlP5Constants.EVENT , -1 );
					}
					for ( int j = 0 ; j < theAcceptClassList.length ; j++ ) {
						if ( myMethods[ i ].getParameterTypes( )[ 0 ] == theAcceptClassList[ j ] ) {
							return new ControllerPlug( theObject , theTargetName , ControlP5Constants.METHOD , j , theAcceptClassList );
						}
					}
				} else if ( myMethods[ i ].getParameterTypes( ).length == 0 ) {
					return new ControllerPlug( theObject , theTargetName , ControlP5Constants.METHOD , -1 , theAcceptClassList );
				}
				break;
			}
		}

		Field[] myFields = getFieldsFor( myClass );

		for ( int i = 0 ; i < myFields.length ; i++ ) {

			if ( ( myFields[ i ].getName( ) ).equals( theTargetName ) ) {
				for ( int j = 0 ; j < theAcceptClassList.length ; j++ ) {
					if ( myFields[ i ].getType( ) == theAcceptClassList[ j ] ) {
						return new ControllerPlug( theObject , theTargetName , ControlP5Constants.FIELD , j , theAcceptClassList );
					}
				}
				break;
			}
		}
		return null;
	}

	public ControlBroadcaster broadcast( final ControlEvent theControlEvent , final int theType ) {
		if ( broadcast ) {
			for ( ControlListener cl : _myControlListeners ) {
				cl.controlEvent( theControlEvent );
			}
			if ( !theControlEvent.isTab( ) && !theControlEvent.isGroup( ) ) {

				if ( theControlEvent.getController( ).getControllerPlugList( ).size( ) > 0 ) {

					if ( theType == ControlP5Constants.STRING ) {
						for ( ControllerPlug cp : theControlEvent.getController( ).getControllerPlugList( ) ) {
							callTarget( cp , theControlEvent.getStringValue( ) );
						}
					} else if ( theType == ControlP5Constants.ARRAY ) {

					} else if ( theType == ControlP5Constants.BOOLEAN ) {
						for ( ControllerPlug cp : theControlEvent.getController( ).getControllerPlugList( ) ) {
							Controller controller = theControlEvent.getController( );
							if ( controller instanceof Icon ) {
								callTarget( cp , ( ( Icon ) controller ).getBooleanValue( ) );
							} else if ( controller instanceof Button ) {
								callTarget( cp , ( ( Button ) controller ).getBooleanValue( ) );
							} else if ( controller instanceof Toggle ) {
								callTarget( cp , ( ( Toggle ) controller ).getBooleanValue( ) );
							}
						}
					} else {

						for ( ControllerPlug cp : theControlEvent.getController( ).getControllerPlugList( ) ) {
							if ( cp.checkType( ControlP5Constants.EVENT ) ) {
								invokeMethod( cp.getObject( ) , cp.getMethod( ) , new Object[] { theControlEvent } );
							} else {
								callTarget( cp , theControlEvent.getValue( ) );
							}
						}
					}
				}
			}
			if ( _myControlEventType == ControlP5Constants.METHOD ) {
				invokeMethod( _myControlEventPlug.getObject( ) , _myControlEventPlug.getMethod( ) , new Object[] { theControlEvent } );
			}
		}
		return this;
	}

	protected void callTarget( final ControllerPlug thePlug , final float theValue ) {
		if ( thePlug.checkType( ControlP5Constants.METHOD ) ) {
			invokeMethod( thePlug.getObject( ) , thePlug.getMethod( ) , thePlug.getMethodParameter( theValue ) );
		} else if ( thePlug.checkType( ControlP5Constants.FIELD ) ) {
			invokeField( thePlug.getObject( ) , thePlug.getField( ) , thePlug.getFieldParameter( theValue ) );
		}
	}

	protected void callTarget( final ControllerPlug thePlug , final String theValue ) {
		if ( thePlug.checkType( ControlP5Constants.METHOD ) ) {
			invokeMethod( thePlug.getObject( ) , thePlug.getMethod( ) , new Object[] { theValue } );
		} else if ( thePlug.checkType( ControlP5Constants.FIELD ) ) {
			invokeField( thePlug.getObject( ) , thePlug.getField( ) , theValue );
		}
	}

	protected void callTarget( final ControllerPlug thePlug , final boolean theValue ) {
		if ( thePlug.checkType( ControlP5Constants.METHOD ) ) {
			invokeMethod( thePlug.getObject( ) , thePlug.getMethod( ) , new Object[] { theValue } );
		} else if ( thePlug.checkType( ControlP5Constants.FIELD ) ) {
			invokeField( thePlug.getObject( ) , thePlug.getField( ) , theValue );
		}
	}

	private void invokeField( final Object theObject , final Field theField , final Object theParam ) {
		try {
			theField.set( theObject , theParam );
		} catch ( IllegalAccessException e ) {
			ControlP5.logger( ).warning( e.toString( ) );
		}
	}

	private void invokeMethod( final Object theObject , final Method theMethod , final Object[] theParam ) {
		try {
			if ( theParam[ 0 ] == null ) {
				theMethod.invoke( theObject , new Object[ 0 ] );
			} else {
				theMethod.invoke( theObject , theParam );
			}
		} catch ( IllegalArgumentException e ) {
			ControlP5.logger( ).warning( e.toString( ) );
			/**
			 * TODO thrown when plugging a String method/field.
			 */
		} catch ( IllegalAccessException e ) {
			printMethodError( theMethod , e );
		} catch ( InvocationTargetException e ) {
			printMethodError( theMethod , e );
		} catch ( NullPointerException e ) {
			printMethodError( theMethod , e );
		}

	}

	protected String getEventMethod( ) {
		return _myEventMethod;
	}

	protected void invokeAction( CallbackEvent theEvent ) {
		boolean invoke;
		for ( Entry< CallbackListener , Controller< ? >> entry : _myControllerCallbackListeners ) {
			invoke = ( entry.getValue( ).getClass( ).equals( EmptyController.class ) ) ? true : ( entry.getValue( ).equals( theEvent.getController( ) ) ) ? true : false;
			if ( invoke ) {
				entry.getKey( ).controlEvent( theEvent );
			}
		}

		if ( _myControllerCallbackEventPlug != null ) {
			invokeMethod( cp5.papplet , _myControllerCallbackEventPlug.getMethod( ) , new Object[] { theEvent } );
		}
	}

	private void printMethodError( Method theMethod , Exception theException ) {
		if ( !ignoreErrorMessage ) {
			ControlP5.logger( ).severe( "An error occured while forwarding a Controller event, please check your code at " + theMethod.getName( ) + ( !setPrintStackTrace ? " " + "exception:  " + theException : "" ) );
			if ( setPrintStackTrace ) {
				theException.printStackTrace( );
			}
		}
	}

	public static void ignoreErrorMessage( boolean theFlag ) {
		ignoreErrorMessage = theFlag;
	}

	public static void setPrintStackTrace( boolean theFlag ) {
		setPrintStackTrace = theFlag;
	}

	private class EmptyController extends Controller< EmptyController > {

		protected EmptyController( ) {
			this( 0 , 0 );
		}

		protected EmptyController( int theX , int theY ) {
			super( "empty" + ( ( int ) ( Math.random( ) * 1000000 ) ) , theX , theY );
			// TODO Auto-generated constructor stub
		}

		@Override public EmptyController setValue( float theValue ) {
			// TODO Auto-generated method stub
			return this;
		}

	}

	/**
	 * @exclude
	 */
	@Deprecated public void plug( final String theControllerName , final String theTargetMethod ) {
		plug( cp5.papplet , theControllerName , theTargetMethod );
	}
}
