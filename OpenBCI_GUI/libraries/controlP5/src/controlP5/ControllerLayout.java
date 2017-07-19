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

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.logging.Logger;


class ControllerLayout {

	private ControlP5 cp5;

	public static final Logger logger = Logger.getLogger( ControllerLayout.class.getName( ) );

	static {
		Map< Class< ? > , Class< ? >> datatypes = new HashMap< Class< ? > , Class< ? >>( );
		datatypes.put( Integer.class , int.class );
		datatypes.put( Float.class , float.class );
		datatypes.put( Boolean.class , boolean.class );
		datatypes.put( Character.class , char.class );
		datatypes.put( Long.class , long.class );
		datatypes.put( Double.class , double.class );
		datatypes.put( Byte.class , byte.class );
		datatypes.put( CColor.class , CColor.class );
	}

	ControllerLayout( ControlP5 theControlP5 ) {
		cp5 = theControlP5;
	}

	public void save( String theLayoutPath ) {
		theLayoutPath = cp5.checkPropertiesPath( theLayoutPath );
		Class< ? >[] classes = new Class< ? >[] { RadioButton.class , ListBox.class , ColorPicker.class , DropdownList.class };
		HashSet< ControllerLayoutElement > layoutelements = new HashSet< ControllerLayoutElement >( );
		for ( ControllerInterface< ? > c : cp5.getList( ) ) {
			if ( !Arrays.asList( classes ).contains( c.getParent( ).getClass( ) ) ) {
				layoutelements.add( new ControllerLayoutElement( c ) );
				System.out.print( c.getAddress( ) );
				System.out.print( " (" + c.getName( ) + ") " );
				System.out.print( "\tpos:" + Controller.x( c.getPosition( ) ) + "," + Controller.y( c.getPosition( ) ) );
				System.out.print( "\tdim:" + c.getWidth( ) + "," + c.getHeight( ) );
				System.out.print( "\tparent:" + c.getParent( ) );
				System.out.println( "\tclass:" + c.getClass( ).getSimpleName( ) );
			}
		}
		try {
			FileOutputStream fos = new FileOutputStream( theLayoutPath );
			ObjectOutputStream oos = new ObjectOutputStream( fos );

			logger.info( "Saving layout-items to " + theLayoutPath );
			oos.writeInt( layoutelements.size( ) );

			for ( ControllerLayoutElement ce : layoutelements ) {
				oos.writeObject( ce );
			}
			oos.flush( );
			oos.close( );
			fos.close( );
		} catch ( Exception e ) {
			logger.warning( "Exception during serialization: " + e );
		}
	}

	protected boolean isClassAssignableFromSuperclass( Class< ? > theClass , Class< ? > theSuper ) {
		Class< ? > _mySuper = theClass.getSuperclass( );
		while ( _mySuper.getSuperclass( ) != null ) {
			if ( _mySuper.isAssignableFrom( theSuper ) ) {
				return true;
			}
			_mySuper = _mySuper.getSuperclass( );
		}
		return false;
	}

	public void load( String theLayoutPath ) {
		theLayoutPath = cp5.checkPropertiesPath( theLayoutPath );
		ArrayList< ControllerLayoutElement > list = new ArrayList< ControllerLayoutElement >( );
		try {
			FileInputStream fis = new FileInputStream( theLayoutPath );
			ObjectInputStream ois = new ObjectInputStream( fis );
			int size = ois.readInt( );
			logger.info( "loading " + size + " layout-items." + fis.getFD( ) );

			for ( int i = 0 ; i < size ; i++ ) {
				try {
					ControllerLayoutElement ce = ( ControllerLayoutElement ) ois.readObject( );
					list.add( ce );
				} catch ( Exception e ) {
					logger.warning( "skipping a property, " + e );
				}
			}
			ois.close( );
		} catch ( Exception e ) {
			logger.warning( "Exception during deserialization: " + e );
		}

		for ( ControllerLayoutElement ce : list ) {
			/* ControllerInterface ci = cp5.getController(ce.getName());
			 * if (ci == null) {
			 * try {
			 * if (isClassAssignableFromSuperclass(ce.getType(), ControllerGroup.class)) {
			 * ControllerGroup c = (ControllerGroup) cp5.addGroup(null, "", ce.getName(), ce.getType(), ce.getX(), ce.getY(), ce.getWidth(),
			 * ce.getHeight());
			 * c.setWidth(ce.getWidth());
			 * c.setHeight(ce.getHeight());
			 * if (c instanceof ListBox) {
			 * System.out.println("found listbox or dropdownlist!");
			 * ((ListBox) c).setHeight(200);
			 * ((ListBox) c).setBarHeight(ce.getHeight());
			 * }
			 * } else {
			 * Controller c = (Controller) cp5.addController(ce.getName(), ce.getType(), ce.getX(), ce.getY());
			 * c.setWidth(ce.getWidth());
			 * c.setHeight(ce.getHeight());
			 * }
			 * } catch (Exception e) {
			 * 
			 * }
			 * }
			 * ci = cp5.get(ce.getName());
			 * if (ci != null) {
			 * ci.setAddress(ce.getAddress());
			 * System.out.println("name:" + ce.getName() + "\tparent:" + ce.getParent() + "\telement:" + ci + "\ttype:" + ce.getType() + "\t" +
			 * ce.getHeight());
			 * } else {
			 * System.out.println("could not create " + ce.getName() + "," + ce.getType());
			 * }
			 * // if(cp5.get(ce.getName()) instanceof DropdownList) {
			 * // DropdownList dl = (DropdownList)(cp5.get(ce.getName()));
			 * // dl.setHeight(200);
			 * // } */
		}

		for ( ControllerLayoutElement ce : list ) {
			/* ControllerInterface ci = cp5.get(ce.getName());
			 * if (ci != null) {
			 * ControllerGroup g = cp5.getGroup(ce.getParent());
			 * if (g == null) {
			 * g = cp5.getTab(ce.getParent());
			 * }
			 * if (g != null) {
			 * ci.moveTo(g);
			 * }
			 * } */
		}
	}

}
