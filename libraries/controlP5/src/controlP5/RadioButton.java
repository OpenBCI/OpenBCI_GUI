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
 * A radioButton is a list of toggles that can be turned on or off. radioButton is of type
 * ControllerGroup, therefore a controllerPlug can't be set. this means that an event from a
 * radioButton can't be forwarded to a method other than controlEvent in a sketch.
 * 
 * a radioButton has 2 sets of values. radioButton.getValue() returns the value of the active
 * radioButton item. radioButton.getArrayValue() returns a float array that represents the active
 * (1) and inactive (0) items of a radioButton.
 * 
 * ControlP5 CheckBox Toggle
 * 
 * @example controllers/ControlP5radioButton
 * 
 * @nosuperclasses Controller Controller
 */
public class RadioButton extends ControlGroup< RadioButton > {

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
	private Object _myPlug;
	private String _myPlugName;
	protected int alignX = RIGHT_OUTSIDE;
	protected int alignY = CENTER;
	protected int _myPaddingX = Label.paddingX;
	protected int _myPaddingY = 0;

	/**
	 * Convenience constructor to extend RadioButton.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public RadioButton( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	/**
	 * @exclude
	 * @param theControlP5
	 * @param theParent
	 * @param theName
	 * @param theX
	 * @param theY
	 */
	public RadioButton( final ControlP5 theControlP5 , final ControllerGroup< ? > theParent , final String theName , final int theX , final int theY ) {
		super( theControlP5 , theParent , theName , theX , theY , 99 , 9 );
		isBarVisible = false;
		isCollapse = false;
		_myRadioToggles = new ArrayList< Toggle >( );
		setItemsPerRow( 1 );
		_myPlug = cp5.papplet;
		_myPlugName = getName( );
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { int.class } ) ) {
			_myPlug = null;
		}
	}

	/**
	 * @param theName
	 * @param theValue
	 * @return
	 */
	public RadioButton addItem( final String theName , final float theValue ) {
		Toggle t = cp5.addToggle( theName , 0 , 0 , itemWidth , itemHeight );
		t.getCaptionLabel( ).align( alignX , alignY ).setPadding( _myPaddingX , _myPaddingY );
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
	public RadioButton addItem( final Toggle theToggle , final float theValue ) {
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
	public RadioButton removeItem( final String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = n-1 ; i >= 0 ; i-- ) {
			if ( ( _myRadioToggles.get( i ) ).getName( ).equals( theName ) ) {
				( _myRadioToggles.get( i ) ).removeListener( this );
				_myRadioToggles.get( i ).remove();
				_myRadioToggles.remove( i );
			}
		}
		updateValues( false );
		updateLayout( );
		return this;
	}

	private void updateAlign( ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).align( alignX , alignY );
		}
	}

	public RadioButton align( int[] a ) {
		return align( a[ 0 ] , a[ 1 ] );
	}

	public RadioButton align( int theX , int theY ) {
		alignX = theX;
		alignY = theY;
		updateAlign( );
		return this;
	}

	public RadioButton alignX( int theX ) {
		return align( theX , alignY );
	}

	public RadioButton alignY( int theY ) {
		return align( alignX , theY );
	}

	public int[] getAlign( ) {
		return new int[] { alignX , alignY };
	}

	public RadioButton setLabelPadding( int thePaddingX , int thePaddingY ) {
		_myPaddingX = thePaddingX;
		_myPaddingY = thePaddingY;
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setPadding( thePaddingX , thePaddingY );
		}
		return this;
	}

	/**
	 * 
	 * @param theDefaultImage
	 * @param theOverImage
	 * @param theActiveImage
	 * @return RadioButton
	 */
	public RadioButton setImages( PImage theDefaultImage , PImage theOverImage , PImage theActiveImage ) {
		setImage( theDefaultImage , DEFAULT );
		setImage( theOverImage , OVER );
		setImage( theActiveImage , ACTIVE );
		return this;
	}

	/**
	 * @param theImage
	 */
	public RadioButton setImage( PImage theImage ) {
		return setImage( theImage , DEFAULT );
	}

	/**
	 * @param theImage
	 * @param theState
	 *            use Controller.DEFAULT (background), or Controller.OVER (foreground), or
	 *            Controller.ACTIVE (active)
	 * @return
	 */
	public RadioButton setImage( PImage theImage , int theState ) {
		if ( theImage != null ) {
			images[ theState ] = theImage;
			availableImages[ theState ] = true;
			for ( int i = 0 ; i < _myRadioToggles.size( ) ; i++ ) {
				_myRadioToggles.get( i ).setImage( theImage , theState );
			}
		}
		return this;
	}

	public RadioButton setSize( PImage theImage ) {
		return setSize( theImage.width , theImage.height );
	}

	public RadioButton setSize( int theWidth , int theHeight ) {
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
	public RadioButton setItemHeight( int theItemHeight ) {
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
	public RadioButton setItemWidth( int theItemWidth ) {
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

	public Toggle getItem( String theName ) {
		for ( Toggle t : _myRadioToggles ) {
			if ( theName.equals( t.getName( ) ) ) {
				return t;
			}
		}
		return null;
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
	public RadioButton setItemsPerRow( final int theValue ) {
		itemsPerRow = theValue;
		updateLayout( );
		return this;
	}

	/**
	 * Sets the spacing in pixels between columns.
	 * 
	 * @param theSpacing
	 */
	public RadioButton setSpacingColumn( final int theSpacing ) {
		spacingColumn = theSpacing;
		updateLayout( );
		return this;
	}

	/**
	 * Sets the spacing in pixels between rows.
	 * 
	 * @param theSpacing
	 */
	public RadioButton setSpacingRow( final int theSpacing ) {
		spacingRow = theSpacing;
		updateLayout( );
		return this;
	}

	public RadioButton deactivateAll( ) {
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
	 * Deactivates all active RadioButton items and only activates the item corresponding to
	 * theIndex.
	 * TODO does not trigger function or value when called by code, fix!
	 * 
	 * @param theIndex
	 */
	public RadioButton activate( int theIndex ) {
		int n = _myRadioToggles.size( );
		if ( theIndex < n ) {
			for ( int i = 0 ; i < n ; i++ ) {
				_myRadioToggles.get( i ).deactivate( );
			}
			( ( Toggle ) _myRadioToggles.get( theIndex ) ).activate( );
			_myValue = _myRadioToggles.get( theIndex ).internalValue( );
			updateValues( true );
		}
		return this;
	}

	/**
	 * @param theIndex
	 */
	public RadioButton deactivate( int theIndex ) {
		if ( !isMultipleChoice && !noneSelectedAllowed ) {
			return this;
		}
		if ( theIndex < _myRadioToggles.size( ) ) {
			Toggle t = _myRadioToggles.get( theIndex );
			if ( t.isActive ) {
				t.deactivate( );
				_myValue = -1;
				updateValues( true );
			}
		}
		return this;
	}

	/**
	 * Actives an item of the Radio button by name.
	 * 
	 * @param theName
	 */
	public RadioButton activate( String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			if ( theName.equals( t.getName( ) ) ) {
				activate( i );
				return this;
			}
		}
		return this;
	}

	/**
	 * Deactivates a RadioButton by name and sets the value of the RadioButton to the default value
	 * -1.
	 * 
	 * @param theName
	 */
	public RadioButton deactivate( String theName ) {
		int n = _myRadioToggles.size( );
		for ( int i = 0 ; i < n ; i++ ) {
			Toggle t = _myRadioToggles.get( i );
			if ( theName.equals( t.getName( ) ) ) {
				t.deactivate( );
				_myValue = -1;
				updateValues( true );
				return this;
			}
		}
		return this;
	}

	/**
	 * @exclude
	 * @param theIndex
	 */
	public RadioButton toggle( int theIndex ) {
		// TODO
		// boolean itemState = ((Toggle)
		// _myRadioToggles.get(theIndex)).getState();
		// if (theIndex < _myRadioToggles.size()) {
		// Toggle t = ((Toggle) _myRadioToggles.get(theIndex));
		// if (t.isActive) {
		// t.deactivate();
		// _myValue = -1;
		// updateValues(true);
		// }
		// }
		ControlP5.logger( ).info( "toggle() not yet implemented, working on it." );
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
		if ( _myPlug != null ) {
			try {
				Method method = _myPlug.getClass( ).getMethod( _myPlugName , int.class );
				method.invoke( _myPlug , ( int ) _myValue );
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
		updateValues( true );
	}

	public RadioButton plugTo( Object theObject ) {
		_myPlug = theObject;
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { int.class } ) ) {
			_myPlug = null;
		}
		return this;
	}

	public RadioButton plugTo( Object theObject , String thePlugName ) {
		_myPlug = theObject;
		_myPlugName = thePlugName;
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { int.class } ) ) {
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
	public RadioButton setNoneSelectedAllowed( boolean theValue ) {
		noneSelectedAllowed = theValue;
		return this;
	}

	/**
	 * Sets the value for all RadioButton items according to the values of the array passed on. 0
	 * will turn off an item, any other value will turn it on.
	 */
	@Override public RadioButton setArrayValue( float[] theArray ) {
		for ( int i = 0 ; i < theArray.length ; i++ ) {
			if ( _myArrayValue[ i ] != theArray[ i ] ) {
				if ( theArray[ i ] == 0 ) {
					deactivate( i );
				} else {
					activate( i );
				}
			}
		}
		super.setArrayValue( theArray );
		return this;
	}

	public RadioButton setColorLabels( int theColor ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setColor( theColor );
		}
		return this;
	}

	public RadioButton hideLabels( ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setVisible( false );
		}
		return this;
	}

	public RadioButton showLabels( ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).setVisible( true );
		}
		return this;
	}

	public RadioButton toUpperCase( boolean theValue ) {
		for ( Toggle t : _myRadioToggles ) {
			t.getCaptionLabel( ).toUpperCase( theValue );
		}
		return this;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override public String getInfo( ) {
		return "type:\tRadioButton\n" + super.getInfo( );
	}

	/**
	 * @deprecated
	 * @exclude
	 */
	@Deprecated public RadioButton add( final String theName , final float theValue ) {
		return addItem( theName , theValue );
	}
}
