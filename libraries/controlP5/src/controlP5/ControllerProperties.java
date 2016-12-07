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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.StringReader;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import processing.core.PApplet;
import processing.data.JSONArray;
import processing.data.JSONObject;

/**
 * Values of controllers can be stored inside properties files which can be saved to file or memory.
 * 
 * @example controllers/ControlP5properties
 */
public class ControllerProperties {

	public final static int OPEN = 0;
	public final static int CLOSE = 1;
	public static String defaultName = "controlP5";
	
	
	PropertiesStorageFormat format;

	/**
	 * all ControllerProperties will be stored inside Map allProperties. ControllerProperties need to be unique or will
	 * otherwise be overwritten.
	 * 
	 * A hashSet containing names of PropertiesSets is assigned to each ControllerProperty. HashSets are used instead of
	 * ArrayList to only allow unique elements.
	 */

	private Map< ControllerProperty , HashSet< String >> allProperties;

	/**
	 * A set of unique property-set names.
	 */
	private Set< String > allSets;
	final ControlP5 controlP5;
	private String _myDefaultSetName = "default";
	public static final Logger logger = Logger.getLogger( ControllerProperties.class.getName( ) );
	private Map< String , Set< ControllerProperty >> _mySnapshots;

	public ControllerProperties( ControlP5 theControlP5 ) {
		controlP5 = theControlP5;
		// setFormat( new SerializedFormat( ) );
		setFormat( new JSONFormat( ) );
		allProperties = new HashMap< ControllerProperty , HashSet< String >>( );
		allSets = new HashSet< String >( );
		addSet( _myDefaultSetName );
		_mySnapshots = new LinkedHashMap< String , Set< ControllerProperty >>( );
	}

	public Map< ControllerProperty , HashSet< String >> get( ) {
		return allProperties;
	}

	/**
	 * adds a property based on names of setter and getter methods of a controller.
	 * 
	 * @param thePropertySetter
	 * @param thePropertyGetter
	 */
	public ControllerProperty register( ControllerInterface< ? > theController , String thePropertySetter , String thePropertyGetter ) {
		ControllerProperty p = new ControllerProperty( theController , thePropertySetter , thePropertyGetter );
		if ( !allProperties.containsKey( p ) ) {
			// register a new property with the main properties container
			allProperties.put( p , new HashSet< String >( ) );
			// register the property wit the default properties set
			allProperties.get( p ).add( _myDefaultSetName );
		}
		return p;
	}

	/**
	 * registering a property with only one parameter assumes that there is a setter and getter function present for the
	 * Controller. register("value") for example would create a property reference to setValue and getValue. Notice that
	 * the first letter of value is being capitalized.
	 * 
	 * @param theProperty
	 * @return
	 */
	public ControllerProperties register( ControllerInterface< ? > theController , String theProperty ) {
		theProperty = Character.toUpperCase( theProperty.charAt( 0 ) ) + theProperty.substring( 1 );
		register( theController , "set" + theProperty , "get" + theProperty );
		return this;
	}

	public ControllerProperties remove( ControllerInterface< ? > theController , String theSetter , String theGetter ) {
		ControllerProperty cp = new ControllerProperty( theController , theSetter , theGetter );
		allProperties.remove( cp );
		return this;
	}

	public ControllerProperties remove( ControllerInterface< ? > theController ) {
		ArrayList< ControllerProperty > list = new ArrayList< ControllerProperty >( allProperties.keySet( ) );
		for ( ControllerProperty cp : list ) {
			if ( cp.getController( ).equals( theController ) ) {
				allProperties.remove( cp );
			}
		}
		return this;
	}

	public ControllerProperties remove( ControllerInterface< ? > theController , String theProperty ) {
		return remove( theController , "set" + theProperty , "get" + theProperty );
	}

	public List< ControllerProperty > get( ControllerInterface< ? > theController ) {
		List< ControllerProperty > props = new ArrayList< ControllerProperty >( );
		List< ControllerProperty > list = new ArrayList< ControllerProperty >( allProperties.keySet( ) );
		for ( ControllerProperty cp : list ) {
			if ( cp.getController( ).equals( theController ) ) {
				props.add( cp );
			}
		}
		return props;
	}

	public ControllerProperty getProperty( ControllerInterface< ? > theController , String theSetter , String theGetter ) {
		ControllerProperty cp = new ControllerProperty( theController , theSetter , theGetter );
		Iterator< ControllerProperty > iter = allProperties.keySet( ).iterator( );
		while ( iter.hasNext( ) ) {
			ControllerProperty p = iter.next( );
			if ( p.equals( cp ) ) {
				return p;
			}
		}
		// in case the property has not been registered before, it will be
		// registered here automatically - you don't need to call
		// Controller.registerProperty() but can use Controller.getProperty()
		// instead.
		return register( theController , theSetter , theGetter );
	}

	public ControllerProperty getProperty( ControllerInterface< ? > theController , String theProperty ) {
		theProperty = Character.toUpperCase( theProperty.charAt( 0 ) ) + theProperty.substring( 1 );
		return getProperty( theController , "set" + theProperty , "get" + theProperty );
	}

	public HashSet< ControllerProperty > getPropertySet( ControllerInterface< ? > theController ) {
		HashSet< ControllerProperty > set = new HashSet< ControllerProperty >( );
		Iterator< ControllerProperty > iter = allProperties.keySet( ).iterator( );
		while ( iter.hasNext( ) ) {
			ControllerProperty p = iter.next( );
			if ( p.getController( ).equals( theController ) ) {
				set.add( p );
			}
		}
		return set;
	}

	public ControllerProperties addSet( String theSet ) {
		allSets.add( theSet );
		return this;
	}

	/**
	 * Moves a ControllerProperty from one set to another.
	 */
	public ControllerProperties move( ControllerProperty theProperty , String fromSet , String toSet ) {
		if ( !exists( theProperty ) ) {
			return this;
		}
		if ( allProperties.containsKey( theProperty ) ) {
			if ( allProperties.get( theProperty ).contains( fromSet ) ) {
				allProperties.get( theProperty ).remove( fromSet );
			}
			addSet( toSet );
			allProperties.get( theProperty ).add( toSet );
		}
		return this;
	}

	public ControllerProperties move( ControllerInterface< ? > theController , String fromSet , String toSet ) {
		HashSet< ControllerProperty > set = getPropertySet( theController );
		for ( ControllerProperty cp : set ) {
			move( cp , fromSet , toSet );
		}
		return this;
	}

	/**
	 * copies a ControllerProperty from one set to other(s);
	 */
	public ControllerProperties copy( ControllerProperty theProperty , String ... theSet ) {
		if ( !exists( theProperty ) ) {
			return this;
		}
		for ( String s : theSet ) {
			allProperties.get( theProperty ).add( s );
			if ( !allSets.contains( s ) ) {
				addSet( s );
			}
		}
		return this;
	}

	public ControllerProperties copy( ControllerInterface< ? > theController , String ... theSet ) {
		HashSet< ControllerProperty > set = getPropertySet( theController );
		for ( ControllerProperty cp : set ) {
			copy( cp , theSet );
		}
		return this;
	}

	/**
	 * removes a ControllerProperty from one or multiple sets.
	 */
	public ControllerProperties remove( ControllerProperty theProperty , String ... theSet ) {
		if ( !exists( theProperty ) ) {
			return this;
		}
		for ( String s : theSet ) {
			allProperties.get( theProperty ).remove( s );
		}
		return this;
	}

	public ControllerProperties remove( ControllerInterface< ? > theController , String ... theSet ) {
		HashSet< ControllerProperty > set = getPropertySet( theController );
		for ( ControllerProperty cp : set ) {
			remove( cp , theSet );
		}
		return this;
	}

	/**
	 * stores a ControllerProperty in one particular set only.
	 */
	public ControllerProperties only( ControllerProperty theProperty , String theSet ) {
		// clear all the set-references for a particular property
		allProperties.get( theProperty ).clear( );
		// add theSet to the empty collection of sets for this particular
		// property
		allProperties.get( theProperty ).add( theSet );
		return this;
	}

	ControllerProperties only( ControllerInterface< ? > theController , String ... theSet ) {
		return this;
	}

	private boolean exists( ControllerProperty theProperty ) {
		return allProperties.containsKey( theProperty );
	}

	public ControllerProperties print( ) {
		for ( Entry< ControllerProperty , HashSet< String >> entry : allProperties.entrySet( ) ) {
			System.out.println( entry.getKey( ) + "\t" + entry.getValue( ) );
		}
		return this;
	}

	/**
	 * deletes a ControllerProperty from all Sets including the default set.
	 */
	public ControllerProperties delete( ControllerProperty theProperty ) {
		if ( !exists( theProperty ) ) {
			return this;
		}
		allProperties.remove( theProperty );
		return this;
	}

	private boolean updatePropertyValue( ControllerProperty theProperty ) {
		Method method;
		try {
			method = theProperty.getController( ).getClass( ).getMethod( theProperty.getGetter( ) );
			Object value = method.invoke( theProperty.getController( ) );
			theProperty.setType( method.getReturnType( ) );
			theProperty.setValue( value );
			if ( checkSerializable( value ) ) {
				return true;
			}
		} catch ( Exception e ) {
			logger.severe( "" + e );
		}
		return false;
	}

	private boolean checkSerializable( Object theProperty ) {
		try {
			ByteArrayOutputStream out = new ByteArrayOutputStream( );
			ObjectOutputStream stream = new ObjectOutputStream( out );
			stream.writeObject( theProperty );
			stream.close( );
			return true;
		} catch ( Exception e ) {
			return false;
		}
	}

	/**
	 * logs all registered properties in memory. Here, clones of properties are stored inside a map and can be accessed
	 * by key using the getLog method.
	 * 
	 * @see controlP5.ControllerProperties#getSnapshot(String)
	 * @param theKey
	 * @return ControllerProperties
	 */
	public ControllerProperties setSnapshot( String theKey ) {
		Set< ControllerProperty > l = new HashSet< ControllerProperty >( );
		for ( ControllerProperty cp : allProperties.keySet( ) ) {
			updatePropertyValue( cp );
			try {
				l.add( ( ControllerProperty ) cp.clone( ) );
			} catch ( CloneNotSupportedException e ) {
				// TODO Auto-generated catch block
			}
		}
		_mySnapshots.put( theKey , l );
		return this;
	}

	/**
	 * convenience method, setSnapshot(String) also works here since it will override existing log with the same key.
	 */
	public ControllerProperties updateSnapshot( String theKey ) {
		return setSnapshot( theKey );
	}

	/**
	 * removes a snapshot by key.
	 */
	public ControllerProperties removeSnapshot( String theKey ) {
		_mySnapshots.remove( theKey );
		return this;
	}

	ControllerProperties setSnapshot( String theKey , String ... theSets ) {
		return this;
	}

	/**
	 * saves a snapshot into your sketch's sketch folder.
	 */
	public ControllerProperties saveSnapshot( String theKey ) {
		saveSnapshotAs( controlP5.papplet.sketchPath( theKey ) , theKey );
		return this;
	}

	/**
	 * saves a snapshot to the file with path given by the first parameter (thePropertiesPath).
	 */
	public ControllerProperties saveSnapshotAs( String thePropertiesPath , String theKey ) {
		Set< ControllerProperty > log = _mySnapshots.get( theKey );
		if ( log == null ) {
			return this;
		}
		thePropertiesPath = getPathWithExtension( format , controlP5.checkPropertiesPath( thePropertiesPath ) );

		format.compile( log , thePropertiesPath );

		return this;
	}

	private String getPathWithExtension( PropertiesStorageFormat theFormat , String thePropertiesPath ) {
		return ( thePropertiesPath.endsWith( "." + theFormat.getExtension( ) ) ) ? thePropertiesPath : thePropertiesPath + "." + theFormat.getExtension( );
	}

	/**
	 * restores properties previously stored as snapshot in memory.
	 * 
	 * @see controlP5.ControllerProperties#setSnapshot(String)
	 */
	public ControllerProperties getSnapshot( String theKey ) {
		Set< ControllerProperty > l = _mySnapshots.get( theKey );
		if ( l != null ) {
			for ( ControllerProperty cp : l ) {
				ControllerInterface< ? > ci = controlP5.getController( cp.getAddress( ) );
				ci = ( ci == null ) ? controlP5.getGroup( cp.getAddress( ) ) : ci;
				ControlP5.invoke( ( Controller ) ci , cp.getSetter( ) , cp.getValue( ) );
			}
		}
		return this;
	}

	/**
	 * properties stored in memory can be accessed by index, getSnapshotIndices() returns the index of the snapshot
	 * list.
	 */
	public ArrayList< String > getSnapshotIndices( ) {
		return new ArrayList< String >( _mySnapshots.keySet( ) );
	}

	/**
	 * load properties from the default properties file 'controlP5.properties'
	 */
	public boolean load( ) {
		return load( controlP5.papplet.sketchPath( defaultName + "." + format.getExtension( ) ) );
	}

	public boolean load( String thePropertiesPath ) {
		return format.load( getPathWithExtension( format , controlP5.checkPropertiesPath( thePropertiesPath ) ) );
	}
	
	/**
	 * use ControllerProperties.SERIALIZED, ControllerProperties.XML or ControllerProperties.JSON as parameter.
	 */
	public void setFormat( PropertiesStorageFormat theFormat ) {
		format = theFormat;
	}

	public void setFormat( String theFormat ) {
		if ( theFormat.equals( ControlP5.JSON ) ) {
			setFormat( new JSONFormat( ) );
		} else if ( theFormat.equals( ControlP5.SERIALIZED ) ) {
			setFormat( new SerializedFormat( ) );
		} else {
			System.out.println( "sorry format " + theFormat + " does not exist." );
		}
	}

	/**
	 * saves all registered properties into the default 'controlP5.properties' file into your sketch folder.
	 */
	public boolean save( ) {
		System.out.println( "save properties using format " + format + " (" + format.getExtension( ) + ") " + controlP5.papplet.sketchPath( defaultName ) );
		format.compile( allProperties.keySet( ) , getPathWithExtension( format , controlP5.papplet.sketchPath( defaultName ) ) );
		return true;
	}

	/**
	 * saves all registered properties into a file specified by parameter thePropertiesPath.
	 */
	public boolean saveAs( final String thePropertiesPath ) {
		format.compile( allProperties.keySet( ) , getPathWithExtension( format , controlP5.checkPropertiesPath( thePropertiesPath ) ) );
		return true;
	}

	/**
	 * saves a list of properties sets into a file specified by parameter thePropertiesPath.
	 */
	public boolean saveAs( String thePropertiesPath , String ... theSets ) {
		thePropertiesPath = controlP5.checkPropertiesPath( thePropertiesPath );
		HashSet< ControllerProperty > sets = new HashSet< ControllerProperty >( );
		Iterator< ControllerProperty > iter = allProperties.keySet( ).iterator( );
		while ( iter.hasNext( ) ) {
			ControllerProperty p = iter.next( );
			if ( allProperties.containsKey( p ) ) {
				HashSet< String > set = allProperties.get( p );
				for ( String str : set ) {
					for ( String s : theSets ) {
						if ( str.equals( s ) ) {
							sets.add( p );
						}
					}
				}
			}
		}
		format.compile( sets , getPathWithExtension( format , thePropertiesPath ) );
		return true;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	public String toString( ) {
		String s = "";
		s += this.getClass( ).getName( ) + "\n";
		s += "total num of properties:\t" + allProperties.size( ) + "\n";
		for ( ControllerProperty c : allProperties.keySet( ) ) {
			s += "\t" + c + "\n";
		}
		s += "total num of sets:\t\t" + allSets.size( ) + "\n";
		for ( String set : allSets ) {
			s += "\t" + set + "\n";
		}
		return s;
	}

	interface PropertiesStorageFormat {

		public void compile( Set< ControllerProperty > theProperties , String thePropertiesPath );

		public boolean load( String thePropertiesPath );

		public String getExtension( );

	}

	class XMLFormat implements PropertiesStorageFormat {
		public void compile( Set< ControllerProperty > theProperties , String thePropertiesPath ) {
			System.out.println( "Dont use the XMLFormat yet, it is not fully implemented with 0.5.9, use SERIALIZED instead." );
			System.out.println( "Compiling with XMLFormat" );
			StringBuffer xml = new StringBuffer( );
			xml.append( "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" );
			xml.append( "<properties name=\"" + thePropertiesPath + "\">\n" );
			for ( ControllerProperty cp : theProperties ) {
				if ( cp.isActive( ) ) {
					updatePropertyValue( cp );
					xml.append( getXML( cp ) );
				}
			}
			xml.append( "</properties>" );
			controlP5.papplet.saveStrings( thePropertiesPath , PApplet.split( xml.toString( ) , "\n" ) );
			System.out.println( "saving xml, " + thePropertiesPath );
		}

		public String getExtension( ) {
			return "xml";
		}

		public boolean load( String thePropertiesPath ) {
			String s;
			try {
				s = PApplet.join( controlP5.papplet.loadStrings( thePropertiesPath ) , "\n" );
			} catch ( Exception e ) {
				logger.warning( thePropertiesPath + ", file not found." );
				return false;
			}
			System.out.println( "loading xml \n" + s );
			try {
				DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance( );
				DocumentBuilder db = dbf.newDocumentBuilder( );
				InputSource is = new InputSource( );
				is.setCharacterStream( new StringReader( s ) );
				Document doc = db.parse( is );
				doc.getDocumentElement( ).normalize( );
				NodeList nodeLst = doc.getElementsByTagName( "property" );
				for ( int i = 0 ; i < nodeLst.getLength( ) ; i++ ) {
					Node node = nodeLst.item( i );
					if ( node.getNodeType( ) == Node.ELEMENT_NODE ) {
						Element fstElmnt = ( Element ) node;
						String myAddress = getElement( fstElmnt , "address" );
						String mySetter = getElement( fstElmnt , "setter" );
						String myType = getElement( fstElmnt , "type" );
						String myValue = getElement( fstElmnt , "value" );
						// String myClass = getElement(fstElmnt, "class");
						// String myGetter = getElement(fstElmnt, "getter");
						try {
							System.out.print( "setting controller " + myAddress + "   " );
							ControllerInterface< ? > ci = controlP5.getController( myAddress );
							ci = ( ci == null ) ? controlP5.getGroup( myAddress ) : ci;
							System.out.println( ci );
							Method method;
							try {
								Class< ? > c = getClass( myType );
								System.out.println( myType + " / " + c );
								method = ci.getClass( ).getMethod( mySetter , new Class[] { c } );
								method.setAccessible( true );
								method.invoke( ci , new Object[] { getValue( myValue , myType , c ) } );
							} catch ( Exception e ) {
								logger.severe( e.toString( ) );
							}
						} catch ( Exception e ) {
							logger.warning( "skipping a property, " + e );
						}
					}

				}
			} catch ( SAXException e ) {
				logger.warning( "SAXException, " + e );
				return false;
			} catch ( IOException e ) {
				logger.warning( "IOException, " + e );
				return false;
			} catch ( ParserConfigurationException e ) {
				logger.warning( "ParserConfigurationException, " + e );
				return false;
			}
			return true;
		}

		private Object getValue( String theValue , String theType , Class< ? > theClass ) {
			if ( theClass == int.class ) {
				return Integer.parseInt( theValue );
			} else if ( theClass == float.class ) {
				return Float.parseFloat( theValue );
			} else if ( theClass == boolean.class ) {
				return Boolean.parseBoolean( theValue );
			} else if ( theClass.isArray( ) ) {
				System.out.println( "this is an array: " + theType + ", " + theValue + ", " + theClass );
				int dim = 0;
				while ( true ) {
					if ( theType.charAt( dim ) != '[' || dim >= theType.length( ) ) {
						break;
					}
					dim++;
				}
			} else {
				System.out.println( "is array? " + theClass.isArray( ) );
			}
			return theValue;
		}

		private Class< ? > getClass( String theType ) {
			if ( theType.equals( "int" ) ) {
				return int.class;
			} else if ( theType.equals( "float" ) ) {
				return float.class;
			} else if ( theType.equals( "String" ) ) {
				return String.class;
			}
			try {
				return Class.forName( theType );
			} catch ( ClassNotFoundException e ) {
				logger.warning( "ClassNotFoundException, " + e );
			}
			return null;
		}

		private String getElement( Element theElement , String theName ) {
			NodeList fstNmElmntLst = theElement.getElementsByTagName( theName );
			Element fstNmElmnt = ( Element ) fstNmElmntLst.item( 0 );
			NodeList fstNm = fstNmElmnt.getChildNodes( );
			return ( ( Node ) fstNm.item( 0 ) ).getNodeValue( );
		}

		public String getXML( ControllerProperty theProperty ) {
			// Mapping Between JSON and Java Entities
			// http://code.google.com/p/json-simple/wiki/MappingBetweenJSONAndJavaEntities
			String s = "\t<property>\n";
			s += "\t\t<address>" + theProperty.getAddress( ) + "</address>\n";
			s += "\t\t<class>" + CP.formatGetClass( theProperty.getController( ).getClass( ) ) + "</class>\n";
			s += "\t\t<setter>" + theProperty.getSetter( ) + "</setter>\n";
			s += "\t\t<getter>" + theProperty.getGetter( ) + "</getter>\n";
			s += "\t\t<type>" + CP.formatGetClass( theProperty.getType( ) ) + "</type>\n";
			s += "\t\t<value>" + cdata( OPEN , theProperty.getValue( ).getClass( ) ) + ( theProperty.getValue( ).getClass( ).isArray( ) ? CP.arrayToString( theProperty.getValue( ) ) : theProperty.getValue( ) )
			    + cdata( CLOSE , theProperty.getValue( ).getClass( ) ) + "</value>\n";
			s += "\t</property>\n";
			return s;
		}

		private String cdata( int a , Class< ? > c ) {
			if ( c == String.class || c.isArray( ) ) {
				return ( a == OPEN ? "<![CDATA[" : "]]>" );
			}
			return "";
		}
	}

	public class JSONFormat implements PropertiesStorageFormat {

		public void compile( Set< ControllerProperty > theProperties , String thePropertiesPath ) {
			long t = System.currentTimeMillis( );
			JSONObject json = new JSONObject( );
			for ( ControllerProperty cp : theProperties ) {

				if ( cp.isActive( ) ) {
					if ( updatePropertyValue( cp ) ) {
						cp.setId( cp.getController( ).getId( ) );

						if ( !json.keys( ).contains( cp.getAddress( ) ) ) {
							json.setJSONObject( cp.getAddress( ) , new JSONObject( ) );
						}
						JSONObject item = json.getJSONObject( cp.getAddress( ) );
						String key = cp.getSetter( );
						key = Character.toLowerCase( key.charAt( 3 ) ) + key.substring( 4 );
						if ( cp.getValue( ) instanceof Number ) {
							if ( cp.getValue( ) instanceof Integer ) {
								item.setInt( key , ControlP5.i( cp.getValue( ) ) );
							} else if ( cp.getValue( ) instanceof Float ) {
								item.setFloat( key , ControlP5.f( cp.getValue( ) ) );
							} else if ( cp.getValue( ) instanceof Double ) {
								item.setDouble( key , ControlP5.d( cp.getValue( ) ) );
							}
						} else if ( cp.getValue( ) instanceof Boolean ) {
							item.setBoolean( key , ControlP5.b( cp.getValue( ) ) );
						} else {

							if ( cp.getValue( ).getClass( ).isArray( ) ) {
								JSONArray arr = new JSONArray( );
								if ( cp.getValue( ) instanceof int[] ) {
									for ( Object o : ( int[] ) cp.getValue( ) ) {
										arr.append( ControlP5.i( o ) );
									}
								} else if ( cp.getValue( ) instanceof float[] ) {
									for ( Object o : ( float[] ) cp.getValue( ) ) {
										arr.append( ControlP5.f( o ) );
									}
								}
								item.setJSONArray( key , arr );
							} else {
								item.setString( key , cp.getValue( ).toString( ) );
							}
						}
					}
				}
			}
			json.save( new File( getPathWithExtension( this , thePropertiesPath ) ) , "" );
		}

		public String getExtension( ) {
			return "json";
		}

		public boolean load( String thePropertiesPath ) {
			JSONReader reader = new JSONReader( controlP5.papplet );
			Map< ? , ? > entries = ControlP5.toMap( reader.parse( thePropertiesPath ) );
			for ( Map.Entry entry : entries.entrySet( ) ) {
				String name = entry.getKey( ).toString( );
				Controller c = controlP5.getController( name );
				Map< ? , ? > values = ControlP5.toMap( entry.getValue( ) );
				for ( Map.Entry value : values.entrySet( ) ) {
					String i0 = value.getKey( ).toString( );
					String member = "set" + Character.toUpperCase( i0.charAt( 0 ) ) + i0.substring( 1 );
					Object i1 = value.getValue( );
					if ( i1 instanceof Number ) {
						ControlP5.invoke( c , member , ControlP5.f( value.getValue( ) ) );
					} else if ( i1 instanceof String ) {
						ControlP5.invoke( c , member , ControlP5.s( value.getValue( ) ) );
					} else if ( i1 instanceof float[] ) {
						ControlP5.invoke( c , member , (float[])i1 );
					} else {
						if ( i1 instanceof List ) {
							List l = ( List ) i1;
							float[] arr = new float[ l.size( ) ];
							for ( int i = 0 ; i < l.size( ) ; i++ ) {
								arr[ i ] = ControlP5.f( l.get( i ) );
							}
							ControlP5.invoke( c , member , arr );
						} else {
							ControlP5.invoke( c , member , value.getValue( ) );
						}

					}
				}
			}
			return false;
		}
	}

	private class JSONReader {

		private final PApplet papplet;

		public JSONReader( Object o ) {
			if ( o instanceof PApplet ) {
				papplet = ( PApplet ) o;
			} else {
				papplet = null;
				System.out.println( "Sorry, argument is not of instance PApplet" );
			}
		}

		public Object parse( String s ) {
			if ( s.indexOf( "{" ) >= 0 ) {
				return get( JSONObject.parse( s ) , new LinkedHashMap( ) );
			} else {
				return get( papplet.loadJSONObject( s ) , new LinkedHashMap( ) );
			}
		}

		Object get( Object o , Object m ) {
			if ( o instanceof JSONObject ) {
				if ( m instanceof Map ) {
					Set set = ( ( JSONObject ) o ).keys( );
					for ( Object o1 : set ) {
						Object o2 = ControlP5.invoke( o , "opt" , o1.toString( ) );
						if ( o2 instanceof JSONObject ) {
							Map m1 = new LinkedHashMap( );
							( ( Map ) m ).put( o1.toString( ) , m1 );
							get( o2 , m1 );
						} else if ( o2 instanceof JSONArray ) {
							List l1 = new ArrayList( );
							( ( Map ) m ).put( o1.toString( ) , l1 );
							get( o2 , l1 );
						} else {
							( ( Map ) m ).put( o1.toString( ) , o2 );
						}
					}
				}
			} else if ( o instanceof JSONArray ) {
				if ( m instanceof List ) {
					List l = ( ( List ) m );
					int n = 0;
					Object o3 = ControlP5.invoke( o , "opt" , n );
					while ( o3 != null ) {
						if ( o3 instanceof JSONArray ) {
							List l1 = new ArrayList( );
							l.add( l1 );
							get( o3 , l1 );
						} else if ( o3 instanceof JSONObject ) {
							Map l1 = new LinkedHashMap( );
							l.add( l1 );
							get( o3 , l1 );
						} else {
							l.add( o3 );
						}
						o3 = ControlP5.invoke( o , "opt" , ++n );
					}
				} else {
					System.err.println( "JSONReader type mismatch." );
				}
			}
			return m;
		}

	}

	public class SerializedFormat implements PropertiesStorageFormat {

		public boolean load( String thePropertiesPath ) {
			try {
				FileInputStream fis = new FileInputStream( thePropertiesPath );
				ObjectInputStream ois = new ObjectInputStream( fis );
				int size = ois.readInt( );
				logger.info( "loading " + size + " property-items. " );

				for ( int i = 0 ; i < size ; i++ ) {
					try {
						ControllerProperty cp = ( ControllerProperty ) ois.readObject( );
						ControllerInterface< ? > ci = controlP5.getController( cp.getAddress( ) );
						ci = ( ci == null ) ? controlP5.getGroup( cp.getAddress( ) ) : ci;
						ci.setId( cp.getId( ) );
						Method method;
						try {
							method = ci.getClass( ).getMethod( cp.getSetter( ) , new Class[] { cp.getType( ) } );
							method.setAccessible( true );
							method.invoke( ci , new Object[] { cp.getValue( ) } );
						} catch ( Exception e ) {
							logger.severe( e.toString( ) );
						}

					} catch ( Exception e ) {
						logger.warning( "skipping a property, " + e );
					}
				}
				ois.close( );
			} catch ( Exception e ) {
				logger.warning( "Exception during deserialization: " + e );
				return false;
			}
			return true;
		}

		public String getExtension( ) {
			return "ser";
		}

		public void compile( Set< ControllerProperty > theProperties , String thePropertiesPath ) {
			int active = 0;
			int total = 0;
			HashSet< ControllerProperty > propertiesToBeSaved = new HashSet< ControllerProperty >( );
			for ( ControllerProperty cp : theProperties ) {
				if ( cp.isActive( ) ) {
					if ( updatePropertyValue( cp ) ) {
						active++;
						cp.setId( cp.getController( ).getId( ) );
						propertiesToBeSaved.add( cp );
					}
				}
				total++;
			}

			int ignored = total - active;

			try {
				FileOutputStream fos = new FileOutputStream( thePropertiesPath );
				ObjectOutputStream oos = new ObjectOutputStream( fos );

				logger.info( "Saving property-items to " + thePropertiesPath );
				oos.writeInt( active );

				for ( ControllerProperty cp : propertiesToBeSaved ) {
					if ( cp.isActive( ) ) {
						oos.writeObject( cp );
					}
				}
				logger.info( active + " items saved, " + ( ignored ) + " items ignored. Done saving properties." );
				oos.flush( );
				oos.close( );
				fos.close( );
			} catch ( Exception e ) {
				logger.warning( "Exception during serialization: " + e );
			}
		}
	}
}
