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


import static controlP5.ControlP5.b;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import static controlP5.ControlP5.s;
import processing.core.PGraphics;

public class ButtonBar extends Controller< ButtonBar > {

	public static int autoWidth = 69;
	public static int autoHeight = 19;

	private List< Map< String , Object >> items = new ArrayList< Map< String , Object >>( );

	/**
	 * Convenience constructor to extend ButtonBar.
	 */
	public ButtonBar( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected ButtonBar( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theX , float theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
	}

	@Override
	@ControlP5.Invisible
	public ButtonBar updateDisplayMode( int theMode ) {
		return updateViewMode( theMode );
	}

	public void changeItem( String theItem , String theKey , Object theValue ) {
		Map m = modifiableItem( theItem );
		if ( !m.equals( Collections.EMPTY_MAP ) ) {
			m.put( theKey , theValue );
		}
	}

	private Map modifiableItem( String theItem ) {
		if ( theItem != null ) {
			for ( Map< String , Object > o : items ) {
				if ( theItem.equals( o.get( "name" ) ) ) {
					return o;
				}
			}
		}
		return Collections.EMPTY_MAP;
	}

	public Map getItem( String theItem ) {
		return Collections.unmodifiableMap( modifiableItem( theItem ) );
	}

	@ControlP5.Invisible
	public ButtonBar updateViewMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new ButtonBarView( );
			break;
		case ( IMAGE ):
			break;
		case ( CUSTOM ):
		default:
			break;

		}
		return this;
	}

	@Override
	public void onClick( ) {
		int index = hover( );
		if ( index > -1 ) {
			for ( Map m : items ) {
				m.put( "selected" , false );
			}
			items.get( index ).put( "selected" , true );
			setValue( hover( ) );
		}
	}

	public int hover( ) {
		int w = getWidth( ) / ( items.isEmpty( ) ? 1 : items.size( ) );
		int h = getHeight( );
		for ( int i = 0 ; i < items.size( ) ; i++ ) {
			if ( getPointer( ).x( ) >= i * w && getPointer( ).x( ) < ( i + 1 ) * w ) {
				return i;
			}
		}
		return -1;
	}

	private class ButtonBarView implements ControllerView< ButtonBar > {

		public void display( PGraphics theGraphics , ButtonBar theController ) {
			theGraphics.noStroke( );
			theGraphics.fill( color.getBackground( ) );
			theGraphics.rect( 0 , 0 , theController.getWidth( ) , theController.getHeight( ) );
			int index = hover( );
			int w = theController.getWidth( ) / ( items.isEmpty( ) ? 1 : items.size( ) );
			int h = theController.getHeight( );
			theGraphics.textFont( theController.getValueLabel( ).getFont( ).pfont );
			theGraphics.pushMatrix( );
			for ( int i = 0 ; i < items.size( ) ; i++ ) {
				int c = b( items.get( i ).get( "selected" ) , false ) ? color.getActive( ) : ( isInside( ) && index == i ) ? isMousePressed ? color.getActive( ) : color.getForeground( ) : color.getBackground( );
				theGraphics.fill( c );
				theGraphics.rect( 0 , 0 , w , h );
				theGraphics.fill( theController.getValueLabel( ).getColor( ) );
				theController.getValueLabel( ).set( s( items.get( i ).get( "text" ) ) ).align( CENTER , CENTER ).draw( theGraphics , 0 , 0 , w , h );
				theGraphics.translate( w , 0 );
			}
			theGraphics.popMatrix( );
		}
	}

	private Map< String , Object > getDefaultItemMap( String theName , Object theValue ) {
		Map< String , Object > item = new HashMap< String , Object >( );
		item.put( "name" , theName );
		item.put( "text" , theName );
		item.put( "value" , theValue );
		item.put( "color" , getColor( ) );
		item.put( "view" , new CDrawable( ) {
			@Override
			public void draw( PGraphics theGraphics ) {
			}

		} );
		item.put( "selected" , false );
		return item;
	}

	public ButtonBar addItem( String theName , Object theValue ) {
		Map< String , Object > item = getDefaultItemMap( theName , theValue );
		items.add( item );
		return this;
	}

	public ButtonBar addItems( String[] theItems ) {
		addItems( Arrays.asList( theItems ) );
		return this;
	}

	public ButtonBar addItems( List< String > theItems ) {
		for ( int i = 0 ; i < theItems.size( ) ; i++ ) {
			addItem( theItems.get( i ).toString( ) , i );
		}
		return this;
	}

	public ButtonBar addItems( Map< String , Object > theItems ) {
		for ( Map.Entry< String , Object > item : theItems.entrySet( ) ) {
			addItem( item.getKey( ) , item.getValue( ) );
		}
		return this;
	}

	public ButtonBar setItems( String[] theItems ) {
		setItems( Arrays.asList( theItems ) );
		return this;
	}

	public ButtonBar setItems( List< String > theItems ) {
		items.clear( );
		return addItems( theItems );
	}

	public ButtonBar setItems( Map< String , Object > theItems ) {
		items.clear( );
		return addItems( theItems );
	}

	public ButtonBar removeItems( List< String > theItems ) {
		for ( String s : theItems ) {
			removeItem( s );
		}
		return this;
	}

	public ButtonBar removeItem( String theName ) {
		if ( theName != null ) {

			List l = new ArrayList( );
			for ( Map m : items ) {
				if ( theName.equals( m.get( "name" ) ) ) {
					l.add( m );
				}
			}
			items.removeAll( l );
		}
		return this;
	}

	private Map< String , Object > getItem( int theIndex ) {
		return items.get( theIndex );
	}

	public List getItems( ) {
		return Collections.unmodifiableList( items );
	}

	public ButtonBar clear( ) {
		for ( int i = items.size( ) - 1 ; i >= 0 ; i-- ) {
			items.remove( i );
		}
		items.clear( );
		return this;
	}

}
