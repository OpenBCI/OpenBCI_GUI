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

import java.io.Serializable;

/**
 * A controller property saves the value, address, getter and setter of a registered controller.
 * 
 * @example controllers/ControlP5properties
 */

public class ControllerProperty implements Serializable , Cloneable {

	private static final long serialVersionUID = 4506431150330867327L;
	private String setter;
	private String getter;
	private Class< ? > type;
	private Object value;
	private String address;
	private int id;
	private transient boolean active;
	private transient ControllerInterface< ? > controller;

	ControllerProperty( ControllerInterface< ? > theController , String theSetter , String theGetter ) {
		setController( theController );
		setAddress( theController.getAddress( ) );
		setSetter( theSetter );
		setGetter( theGetter );
		setActive( true );
		setId( theController.getId( ) );
	}

	@Override protected Object clone( ) throws CloneNotSupportedException {
		ControllerProperty clone = ( ControllerProperty ) super.clone( );
		clone.setSetter( getSetter( ) );
		clone.setGetter( getGetter( ) );
		clone.setType( getType( ) );
		clone.setValue( getValue( ) );
		clone.setAddress( getAddress( ) );
		clone.setActive( isActive( ) );
		clone.setController( getController( ) );
		clone.setId( getId( ) );
		return clone;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override public boolean equals( Object o ) {

		if ( this == o ) {
			return true;
		}
		if ( o == null || getClass( ) != o.getClass( ) ) {
			return false;
		}

		ControllerProperty p = ( ControllerProperty ) o;
		if ( !address.equals( p.address ) || !setter.equals( p.setter ) || !getter.equals( p.getter ) ) {
			return false;
		}
		return true;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override public int hashCode( ) {
		int result = 17;
		result = 37 * result + ( address != null ? address.hashCode( ) : 0 );
		result = 37 * result + ( setter != null ? setter.hashCode( ) : 0 );
		result = 37 * result + ( getter != null ? getter.hashCode( ) : 0 );
		return result;
	}

	public void disable( ) {
		active = false;
	}

	public void enable( ) {
		active = true;
	}

	@Override public String toString( ) {
		return address + " " + setter + ", " + getter;
	}

	void setAddress( String theAddress ) {
		address = theAddress;
	}

	String getAddress( ) {
		return address;
	}

	ControllerInterface< ? > getController( ) {
		return controller;
	}

	void setController( ControllerInterface< ? > theController ) {
		controller = theController;
	}

	Object getValue( ) {
		return value;
	}

	void setValue( Object theValue ) {
		value = theValue;
	}

	Class< ? > getType( ) {
		return type;
	}

	void setType( Class< ? > theType ) {
		type = theType;
	}

	boolean isActive( ) {
		return active;
	}

	void setActive( boolean theValue ) {
		active = theValue;
	}

	String getGetter( ) {
		return getter;
	}

	void setGetter( String theValue ) {
		getter = theValue;
	}

	String getSetter( ) {
		return setter;
	}

	void setSetter( String theValue ) {
		setter = theValue;
	}

	int getId( ) {
		return id;
	}

	void setId( int theValue ) {
		id = theValue;
	}

}
