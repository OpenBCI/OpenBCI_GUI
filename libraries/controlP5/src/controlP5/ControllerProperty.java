package controlP5;

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

	@Override
	protected Object clone( ) throws CloneNotSupportedException {
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
	@Override
	public boolean equals( Object o ) {

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
	@Override
	public int hashCode( ) {
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

	@Override
	public String toString( ) {
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
