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

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import processing.core.PImage;


/**
 * A multiple-choice radioButton. items are added to a checkBox and can be organized in rows and
 * columns. items of a checkBox are of type Toggle.
 * 
 * @example controllers/ControlP5checkBox
 * 
 * @see controlP5.Toggle
 * 
 */
public class CheckBox extends ControlGroup< CheckBox > {

	private Object _myPlug;

	private String _myPlugName;

	/**
	 * Convenience constructor to extend CheckBox.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public CheckBox( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	/**
	 * A CheckBox should only be added to controlP5 by using controlP5.addCheckBox()
	 * 
	 * @exclude
	 * @param theControlP5
	 * @param theParent
	 * @param theName
	 * @param theX
	 * @param theY
	 */
	public CheckBox( final ControlP5 theControlP5 , final ControllerGroup< ? > theParent , final String theName , final int theX , final int theY ) {
		super( theControlP5 , theParent , theName , theX , theY , 99 , 9 );
		isBarVisible = false;
		isCollapse = false;
		_myRadioToggles = new ArrayList< Toggle >( );
		setItemsPerRow( 1 );
		isMultipleChoice = true;
		_myPlug = cp5.papplet;
		_myPlugName = getName( );
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { float[].class } ) ) {
			_myPlug = null;
		}
	}

	public final CheckBox activateAll( ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			_myRadioToggles.get( i ).activate( );
		}
		updateValues( );
		return this;
	}

	/**
	 * Activates a single checkbox item by index
	 */
	public final CheckBox activate( int theIndex ) {
		if ( theIndex < _myRadioToggles.size( ) ) {
			_myRadioToggles.get( theIndex ).activate( );
			updateValues( );
		}
		return this;
	}

	/**
	 * deactivate a single checkbox item by index
	 */
	public final CheckBox deactivate( int theIndex ) {
		if ( theIndex < _myRadioToggles.size( ) ) {
			_myRadioToggles.get( theIndex ).deactivate( );
			updateValues( );
		}
		return this;
	}

	/**
	 * toggle a single checkbox item by index
	 */
	public final CheckBox toggle( int theIndex ) {
		if ( theIndex < _myRadioToggles.size( ) ) {
			Toggle t = _myRadioToggles.get( theIndex );
			if ( t.getState( ) == true ) {
				t.deactivate( );
			} else {
				t.activate( );
			}
			updateValues( );
		}
		return this;
	}

	/**
	 * deactivate a single checkbox item by name
	 */
	public final void toggle( String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			if ( theName.equals( t.getName( ) ) ) {
				if ( t.getState( ) == true ) {
					t.deactivate( );
				} else {
					t.activate( );
				}
				updateValues( );
				return;
			}
		}
	}

	/**
	 * Activates a single checkbox item by name
	 */
	public final CheckBox activate( String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			if ( theName.equals( t.getName( ) ) ) {
				t.activate( );
				updateValues( );
				return this;
			}
		}
		return this;
	}

	/**
	 * Deactivates a single checkbox item by name
	 */
	public final CheckBox deactivate( String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			if ( theName.equals( t.getName( ) ) ) {
				t.deactivate( );
				updateValues( );
				return this;
			}
		}
		return this;
	}

	private final void updateValues( ) {
		_myValue = -1;
		updateValues( true );
	}

	/**
	 * Sets the value for all CheckBox items according to the values of the array passed on. 0 will
	 * turn off an item, any other value will turn it on.
	 */
	@Override public CheckBox setArrayValue( float[] theArray ) {
		for ( int i = 0 ; i < theArray.length ; i++ ) {
			if ( _myArrayValue[ i ] != theArray[ i ] ) {
				if ( theArray[ i ] == 0 ) {
					_myRadioToggles.get( i ).deactivate( );
				} else {
					_myRadioToggles.get( i ).activate( );
				}
			}
		}
		super.setArrayValue( theArray );
		return this;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override public String getInfo( ) {
		return "type:\tCheckBox\n" + super.getInfo( );
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override public String toString( ) {
		return super.toString( );
	}

	protected List< Toggle > _myRadioToggles;

	protected int spacingRow = 1;

	protected int spacingColumn = 1;

	protected int itemsPerRow = -1;

	protected boolean isMultipleChoice;

	protected int itemHeight = 9;

	protected int itemWidth = 9;

	protected boolean[] availableImages = new boolean[ 3 ];

	protected PImage[] images = new PImage[ 3 ];

	protected boolean noneSelectedAllowed = true;

	/**
	 * @param theName
	 * @param theValue
	 * @return
	 */
	public CheckBox addItem( final String theName , final float theValue ) {
		Toggle t = cp5.addToggle( theName , 0 , 0 , itemWidth , itemHeight );
		t.getCaptionLabel( ).align( RIGHT_OUTSIDE , CENTER ).setPadding( Label.paddingX , 0 );
		t.setMode( ControlP5.DEFAULT );
		t.setImages( images[ 0 ] , images[ 1 ] , images[ 2 ] );
		t.setSize( images[ 0 ] );
		addItem( t , theValue );
		return this;
	}

	/**
	 * @param theToggle
	 * @param theValue
	 * @return
	 */
	public CheckBox addItem( final Toggle theToggle , final float theValue ) {
		theToggle.setGroup( this );
		theToggle.isMoveable = false;
		theToggle.setInternalValue( theValue );
		theToggle.isBroadcast = false;
		_myRadioToggles.add( theToggle );
		updateLayout( );
		getColor( ).copyTo( theToggle );
		theToggle.addListener( this );
		updateValues( false );
		cp5.removeProperty( theToggle );
		return this;
	}

	/**
	 * @param theName
	 */
	public CheckBox removeItem( final String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			if ( ( _myRadioToggles.get( i ) ).getName( ).equals( theName ) ) {
				( _myRadioToggles.get( i ) ).removeListener( this );
				_myRadioToggles.remove( i );
			}
		}
		updateValues( false );
		return this;
	}

	/**
	 * 
	 * @param theDefaultImage
	 * @param theOverImage
	 * @param theActiveImage
	 * @return CheckBox
	 */
	public CheckBox setImages( PImage theDefaultImage , PImage theOverImage , PImage theActiveImage ) {
		setImage( theDefaultImage , DEFAULT );
		setImage( theOverImage , OVER );
		setImage( theActiveImage , ACTIVE );
		return this;
	}

	/**
	 * @param theImage
	 */
	public CheckBox setImage( PImage theImage ) {
		return setImage( theImage , DEFAULT );
	}

	/**
	 * @param theImage
	 * @param theState
	 *            use Controller.DEFAULT (background), or Controller.OVER (foreground), or
	 *            Controller.ACTIVE (active)
	 * @return
	 */
	public CheckBox setImage( PImage theImage , int theState ) {
		if ( theImage != null ) {
			images[ theState ] = theImage;
			availableImages[ theState ] = true;
			for ( int i = 0 ; i < _myRadioToggles.size( ) ; i++ ) {
				_myRadioToggles.get( i ).setImage( theImage , theState );
			}
		}
		return this;
	}

	public CheckBox setSize( PImage theImage ) {
		return setSize( theImage.width , theImage.height );
	}

	public CheckBox setSize( int theWidth , int theHeight ) {
		setItemWidth( theWidth );
		setItemHeight( theHeight );
		return this;
	}

	/**
	 * set the height of a radioButton/checkBox item. by default the height is 11px. in order to
	 * recognize a custom height, the itemHeight has to be set before adding items to a
	 * radioButton/checkBox.
	 * 
	 * @param theItemHeight
	 */
	public CheckBox setItemHeight( int theItemHeight ) {
		itemHeight = theItemHeight;
		for ( Toggle t : _myRadioToggles ) {
			t.setHeight( theItemHeight );
		}
		updateLayout( );
		return this;
	}

	/**
	 * set the width of a radioButton/checkBox item. by default the width is 11px. in order to
	 * recognize a custom width, the itemWidth has to be set before adding items to a
	 * radioButton/checkBox.
	 * 
	 * @param theItemWidth
	 */
	public CheckBox setItemWidth( int theItemWidth ) {
		itemWidth = theItemWidth;
		for ( Toggle t : _myRadioToggles ) {
			t.setWidth( theItemWidth );
		}
		updateLayout( );
		return this;
	}

	/**
	 * Gets a radio button item by index.
	 * 
	 * @param theIndex
	 * @return Toggle
	 */
	public Toggle getItem( int theIndex ) {
		return _myRadioToggles.get( theIndex );
	}

	public List< Toggle > getItems( ) {
		return _myRadioToggles;
	}

	/**
	 * Gets the state of an item - this can be true (for on) or false (for off) - by index.
	 * 
	 * @param theIndex
	 * @return boolean
	 */
	public boolean getState( int theIndex ) {
		if ( theIndex < _myRadioToggles.size( ) && theIndex >= 0 ) {
			return ( ( Toggle ) _myRadioToggles.get( theIndex ) ).getState( );
		}
		return false;
	}

	/**
	 * Gets the state of an item - this can be true (for on) or false (for off) - by name.
	 * 
	 * @param theName
	 * @return
	 */
	public boolean getState( String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			if ( theName.equals( t.getName( ) ) ) {
				return t.getState( );
			}
		}
		return false;
	}

	/**
	 * @exclude
	 */
	public void updateLayout( ) {
		int nn = 0;
		int xx = 0;
		int yy = 0;
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			set( t.position , xx , yy );

			xx += t.getWidth( ) + spacingColumn;
			nn++;
			if ( nn == itemsPerRow ) {
				nn = 0;
				_myWidth = xx;
				yy += t.getHeight( ) + spacingRow;
				xx = 0;
			} else {
				_myWidth = xx;
			}
		}
	}

	/**
	 * Items of a radioButton or a checkBox are organized in columns and rows. SetItemsPerRow sets
	 * the limit of items per row. items exceeding the limit will be pushed to the next row.
	 * 
	 * @param theValue
	 */
	public CheckBox setItemsPerRow( final int theValue ) {
		itemsPerRow = theValue;
		updateLayout( );
		return this;
	}

	/**
	 * Sets the spacing in pixels between columns.
	 * 
	 * @param theSpacing
	 */
	public CheckBox setSpacingColumn( final int theSpacing ) {
		spacingColumn = theSpacing;
		updateLayout( );
		return this;
	}

	/**
	 * Sets the spacing in pixels between rows.
	 * 
	 * @param theSpacing
	 */
	public CheckBox setSpacingRow( final int theSpacing ) {
		spacingRow = theSpacing;
		updateLayout( );
		return this;
	}

	public CheckBox deactivateAll( ) {
		if ( !isMultipleChoice && !noneSelectedAllowed ) {
			return this;
		}
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			( ( Toggle ) _myRadioToggles.get( i ) ).deactivate( );
		}
		_myValue = -1;
		updateValues( true );
		return this;
	}

	/**
	 * {@inheritDoc}
	 * 
	 * @exclude
	 */
	@ControlP5.Invisible @Override public void controlEvent( ControlEvent theEvent ) {

		if ( !isMultipleChoice ) {
			if ( noneSelectedAllowed == false && theEvent.getController( ).getValue( ) < 1 ) {
				if ( theEvent.getController( ) instanceof Toggle ) {
					Toggle t = ( ( Toggle ) theEvent.getController( ) );
					boolean b = t.isBroadcast( );
					t.setBroadcast( false );
					t.setState( true );
					t.setBroadcast( b );
					return;
				}
			}
			_myValue = -1;
			int n = _myRadioToggles.size( );
			for ( int i = 0 ; i < n ; i++ ) {
				Toggle t = _myRadioToggles.get( i );
				if ( !t.equals( theEvent.getController( ) ) ) {
					t.deactivate( );
				} else {
					if ( t.isOn ) {
						_myValue = t.internalValue( );
					}
				}
			}
		}
		updateValues( true );
		if ( _myPlug != null ) {
			try {
				Method method = _myPlug.getClass( ).getMethod( _myPlugName , float[].class );
				method.invoke( _myPlug , ( float[] ) getArrayValue( ) );
			} catch ( SecurityException ex ) {
				ex.printStackTrace( );
			} catch ( NoSuchMethodException ex ) {
				ex.printStackTrace( );
			} catch ( IllegalArgumentException ex ) {
				ex.printStackTrace( );
			} catch ( IllegalAccessException ex ) {
				ex.printStackTrace( );
			} catch ( InvocationTargetException ex ) {
				ex.printStackTrace( );
			}
		}

	}

	public CheckBox plugTo( Object theObject ) {
		_myPlug = theObject;
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { float[].class } ) ) {
			_myPlug = null;
		}
		return this;
	}

	public CheckBox plugTo( Object theObject , String thePlugName ) {
		_myPlug = theObject;
		_myPlugName = thePlugName;
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { float[].class } ) ) {
			_myPlug = null;
		}
		return this;
	}

	protected void updateValues( boolean theBroadcastFlag ) {
		int n = _myRadioToggles.size( );
		_myArrayValue = new float[ n ];
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = ( ( Toggle ) _myRadioToggles.get( i ) );
			_myArrayValue[ i ] = t.getValue( );
		}
		if ( theBroadcastFlag ) {
			ControlEvent myEvent = new ControlEvent( this );
			cp5.getControlBroadcaster( ).broadcast( myEvent , ControlP5Constants.FLOAT );
		}
	}

	/**
	 * In order to always have 1 item selected, use setNoneSelectedAllowed(false), by default this
	 * is true. setNoneSelectedAllowed does not apply when in multipleChoice mode.
	 * 
	 * @param theValue
	 */
	public CheckBox setNoneSelectedAllowed( boolean theValue ) {
		noneSelectedAllowed = theValue;
		return this;
	}

	public CheckBox setColorLabels( int theColor ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setColor( theColor );
		}
		return this;
	}

	public CheckBox hideLabels( ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setVisible( false );
		}
		return this;
	}

	public CheckBox showLabels( ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setVisible( true );
		}
		return this;
	}

	public CheckBox toUpperCase( boolean theValue ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).toUpperCase( theValue );
		}
		return this;
	}

	/**
	 * @deprecated
	 * @exclude
	 */
	@Deprecated public CheckBox add( final String theName , final float theValue ) {
		return addItem( theName , theValue );
	}

}
