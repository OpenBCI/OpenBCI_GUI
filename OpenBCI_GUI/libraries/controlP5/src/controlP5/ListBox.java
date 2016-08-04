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

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.KeyEvent;

/**
 * A ListBox is a list of vertically aligned items which can be scrolled if required.
 * 
 * @see controlP5.ListBox
 * @example controllers/ControlP5listBox
 */
public class ListBox extends Controller< ListBox > implements ControlListener {

	private int _myType = LIST;
	protected int _myBackgroundColor = 0x00ffffff;
	protected int itemHeight = 13;
	protected int barHeight = 10;
	private float scrollSensitivity = 1;
	private boolean isOpen = true;
	protected List< Map< String , Object > > items;
	protected int itemRange = 5;
	protected int itemHover = -1;
	private int itemIndexOffset = 0;
	private int itemSpacing = 1;
	private int _myDirection = PApplet.DOWN;
	private boolean isBarVisible = true;
	static public final int LIST = ControlP5.LIST;
	static public final int DROPDOWN = ControlP5.DROPDOWN;
	static public final int CHECKBOX = ControlP5.CHECKBOX; /* TODO */
	static public final int TREE = ControlP5.TREE; /* TODO */

	public ListBox( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 99 , 199 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected ListBox( ControlP5 theControlP5 , ControllerGroup< ? > theGroup , String theName , int theX , int theY , int theW , int theH ) {
		super( theControlP5 , theGroup , theName , theX , theY , theW , theH );
		items = new ArrayList< Map< String , Object > >( );
		updateHeight( );
	}

	public boolean isOpen( ) {
		return isOpen;
	}

	public ListBox open( ) {
		return setOpen( true );
	}

	public ListBox close( ) {
		return setOpen( false );
	}

	public ListBox setOpen( boolean b ) {
		isOpen = b;
		return this;
	}

	@Override public int getHeight( ) {
		return isOpen ? super.getHeight( ) : barHeight;
	}

	public ListBox setType( int theType ) {
		_myType = theType;
		return this;
	}

	public void setDirection( int theDirection ) {
		_myDirection = ( theDirection == PApplet.UP ) ? PApplet.UP : PApplet.DOWN;
	}

	@Override protected boolean inside( ) {
		/* constrain the bounds of the controller to the
		 * dimensions of the cp5 area, required since
		 * PGraphics as render area has been introduced. */
		float x0 = PApplet.max( 0 , x( position ) + x( _myParent.getAbsolutePosition( ) ) );
		float x1 = PApplet.min( cp5.pgw , x( position ) + x( _myParent.getAbsolutePosition( ) ) + getWidth( ) );
		float y0 = PApplet.max( 0 , y( position ) + y( _myParent.getAbsolutePosition( ) ) );
		float y1 = PApplet.min( cp5.pgh , y( position ) + y( _myParent.getAbsolutePosition( ) ) + getHeight( ) );
		if ( y1 < y0 ) {
			float ty = y0;
			y0 = y1;
			y1 = ty;
		}
		return ( _myControlWindow.mouseX > x0 && _myControlWindow.mouseX < x1 && _myControlWindow.mouseY > ( y1 < y0 ? y1 : y0 ) && _myControlWindow.mouseY < ( y0 < y1 ? y1 : y0 ) );
	}

	@Override protected void onRelease( ) {
		if ( !isDragged ) {
			if ( getPointer( ).y( ) >= 0 && getPointer( ).y( ) <= barHeight ) {
				setOpen( !isOpen( ) );
			} else if ( isOpen ) {

				double n = Math.floor( ( getPointer( ).y( ) - barHeight ) / itemHeight );

				// n += itemRange; /* UP */
				int index = ( int ) n + itemIndexOffset;

				Map m = items.get( index );

				switch ( _myType ) {
				case ( LIST ):
					setValue( index );
					for ( Object o : items ) {
						( ( Map ) o ).put( "state" , false );
					}
					m.put( "state" , !ControlP5.b( m.get( "state" ) ) );
					break;
				case ( DROPDOWN ):
					setValue( index );
					setOpen( false );
					getCaptionLabel( ).setText( ( m.get( "text" ).toString( ) ) );
					break;
				case ( CHECKBOX ):
					m.put( "state" , !ControlP5.b( m.get( "state" ) ) );
					break;
				}

			}
		}
	}

	@Override protected void onDrag( ) {
		scroll( getPointer( ).dy( ) );
	}

	@Override protected void onScroll( int theValue ) {
		scroll( theValue );
	}

	private void scroll( int theValue ) {
		if ( isOpen ) {
			itemIndexOffset += theValue;
			itemIndexOffset = ( int ) ( Math.floor( Math.max( 0 , Math.min( itemIndexOffset , items.size( ) - itemRange ) ) ) );
			itemHover = -2;
		}
	}

	@Override protected void onLeave( ) {
		itemHover = -1;
	}

	private void updateHover( ) {
		if ( getPointer( ).y( ) > barHeight ) {
			double n = Math.floor( ( getPointer( ).y( ) - barHeight ) / itemHeight );
			itemHover = ( int ) ( itemIndexOffset + n );
		} else {
			itemHover = -1;
		}
	}

	@Override protected void onEnter( ) {
		updateHover( );
	}

	@Override protected void onMove( ) {
		updateHover( );
	}

	@Override protected void onEndDrag( ) {
		updateHover( );
	}

	private int updateHeight( ) {
		itemRange = ( PApplet.abs( getHeight( ) ) - ( isBarVisible( ) ? barHeight : 0 ) ) / itemHeight;
		return itemHeight * ( items.size( ) < itemRange ? items.size( ) : itemRange );
	}

	public ListBox setItemHeight( int theHeight ) {
		itemHeight = theHeight;
		updateHeight( );
		return this;
	}

	public ListBox setBarHeight( int theHeight ) {
		barHeight = theHeight;
		updateHeight( );
		return this;
	}

	public int getBarHeight( ) {
		return barHeight;
	}

	public ListBox setScrollSensitivity( float theSensitivity ) {
		scrollSensitivity = theSensitivity;
		return this;
	}

	public ListBox setBarVisible( boolean b ) {
		isBarVisible = b;
		updateHeight( );
		return this;
	}

	public boolean isBarVisible( ) {
		return isBarVisible;
	}

	private Map< String , Object > getDefaultItemMap( String theName , Object theValue ) {
		Map< String , Object > item = new HashMap< String , Object >( );
		item.put( "name" , theName );
		item.put( "text" , theName );
		item.put( "value" , theValue );
		item.put( "color" , getColor( ) );
		item.put( "view" , new CDrawable( ) {
			@Override public void draw( PGraphics theGraphics ) {
			}

		} );
		item.put( "state" , false );
		return item;
	}

	public ListBox addItem( String theName , Object theValue ) {
		Map< String , Object > item = getDefaultItemMap( theName , theValue );
		items.add( item );
		return this;
	}

	public ListBox addItems( String[] theItems ) {
		addItems( Arrays.asList( theItems ) );
		return this;
	}

	public ListBox addItems( List< String > theItems ) {
		for ( int i = 0 ; i < theItems.size( ) ; i++ ) {
			addItem( theItems.get( i ).toString( ) , i );
		}
		return this;
	}

	public ListBox addItems( Map< String , Object > theItems ) {
		for ( Map.Entry< String , Object > item : theItems.entrySet( ) ) {
			addItem( item.getKey( ) , item.getValue( ) );
		}
		return this;
	}

	public ListBox setItems( String[] theItems ) {
		setItems( Arrays.asList( theItems ) );
		return this;
	}

	public ListBox setItems( List< String > theItems ) {
		items.clear( );
		return addItems( theItems );
	}

	public ListBox setItems( Map< String , Object > theItems ) {
		items.clear( );
		return addItems( theItems );
	}

	public ListBox removeItems( List< String > theItems ) {
		for ( String s : theItems ) {
			removeItem( s );
		}
		return this;
	}

	public ListBox removeItem( String theName ) {
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

	public void updateItemIndexOffset( ) {
		int m1 = items.size( ) > itemRange ? ( itemIndexOffset + itemRange ) : items.size( );
		int n = ( m1 - items.size( ) );
		if ( n >= 0 ) {
			itemIndexOffset -= n;
		}
	}

	public Map< String , Object > getItem( int theIndex ) {
		return items.get( theIndex );
	}

	public Map< String , Object > getItem( String theName ) {
		if ( theName != null ) {
			for ( Map< String , Object > o : items ) {
				if ( theName.equals( o.get( "name" ) ) ) {
					return o;
				}
			}
		}
		return Collections.EMPTY_MAP;
	}

	public List getItems( ) {
		return Collections.unmodifiableList( items );
	}

	public ListBox clear( ) {
		for ( int i = items.size( ) - 1 ; i >= 0 ; i-- ) {
			items.remove( i );
		}
		items.clear( );
		itemIndexOffset = 0;
		return this;
	}

	@Override public void controlEvent( ControlEvent theEvent ) {
		// TODO Auto-generated method stub
	}

	public ListBox setBackgroundColor( int theColor ) {
		_myBackgroundColor = theColor;
		return this;
	}

	public int getBackgroundColor( ) {
		return _myBackgroundColor;
	}

	@Override @ControlP5.Invisible public ListBox updateDisplayMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
			_myControllerView = new ListBoxView( );
			break;
		case ( IMAGE ):
		case ( SPRITE ):
		case ( CUSTOM ):
		default:
			break;
		}
		return this;
	}

	static public class ListBoxView implements ControllerView< ListBox > {

		public void display( PGraphics g , ListBox c ) {

			// setHeight( -200 ); /* UP */

			g.noStroke( );

			if ( c.isBarVisible( ) ) {
				boolean b = c.itemHover == -1 && c.isInside && !c.isDragged;
				g.fill( b ? c.getColor( ).getForeground( ) : c.getColor( ).getBackground( ) );
				g.rect( 0 , 0 , c.getWidth( ) , c.barHeight );
				g.pushMatrix( );
				g.translate( c.getWidth( ) - 8 , c.barHeight / 2 - 2 );
				g.fill( c.getColor( ).getCaptionLabel( ) );
				if ( c.isOpen( ) ) {
					g.triangle( -3 , 0 , 3 , 0 , 0 , 3 );
				} else {
					g.triangle( -3 , 3 , 3 , 3 , 0 , 0 );
				}
				g.popMatrix( );

				c.getCaptionLabel( ).align( PApplet.LEFT , PApplet.CENTER ).draw( g , 4 , c.barHeight / 2 );
			}

			if ( c.isOpen( ) ) {
				int bar = ( c.isBarVisible( ) ? c.barHeight : 0 );
				int h = ( ( c.updateHeight( ) ) );
				g.pushMatrix( );
				// g.translate( 0 , - ( h + bar +
				// c.itemSpacing ) ); /* UP */
				g.fill( c.getBackgroundColor( ) );
				g.rect( 0 , bar , c.getWidth( ) , h );
				g.pushMatrix( );
				g.translate( 0 , ( bar == 0 ? 0 : ( c.barHeight + c.itemSpacing ) ) );
				/* draw visible items */
				c.updateItemIndexOffset( );
				int m0 = c.itemIndexOffset;
				int m1 = c.items.size( ) > c.itemRange ? ( c.itemIndexOffset + c.itemRange ) : c.items.size( );
				for ( int i = m0 ; i < m1 ; i++ ) {
					Map< String , Object > item = c.items.get( i );
					CColor color = ( CColor ) item.get( "color" );
					g.fill( ( b( item.get( "state" ) ) ) ? color.getActive( ) : ( i == c.itemHover ) ? ( c.isMousePressed ? color.getActive( ) : color.getForeground( ) ) : color.getBackground( ) );
					g.rect( 0 , 0 , c.getWidth( ) , c.itemHeight - 1 );
					c.getValueLabel( ).align( PApplet.LEFT , PApplet.CENTER ).set( item.get( "text" ).toString( ) ).draw( g , 4 , c.itemHeight / 2 );
					g.translate( 0 , c.itemHeight );
				}
				g.popMatrix( );

				if ( c.isInside ) {
					int m = c.items.size( ) - c.itemRange;
					if ( m > 0 ) {
						g.fill( c.getColor( ).getCaptionLabel( ) );
						g.pushMatrix( );
						int s = 4; /* spacing */
						int s2 = s / 2;
						g.translate( c.getWidth( ) - s , c.barHeight );
						int len = ( int ) PApplet.map( ( float ) Math.log( m * 10 ) , 0 , 10 , h , 0 );
						int pos = ( int ) ( PApplet.map( c.itemIndexOffset , 0 , m , s2 , h - len - s2 ) );
						g.rect( 0 , pos , s2 , len );
						g.popMatrix( );
					}
				}
				g.popMatrix( );
			}

		}

	}

	public void keyEvent( KeyEvent theKeyEvent ) {
		if ( isInside && theKeyEvent.getAction( ) == KeyEvent.PRESS ) {
			switch ( theKeyEvent.getKeyCode( ) ) {
			case ( ControlP5.UP ):
				scroll( theKeyEvent.isAltDown( ) ? -itemIndexOffset : theKeyEvent.isShiftDown( ) ? -10 : -1 );
				updateHover( );
				break;
			case ( ControlP5.DOWN ):
				scroll( theKeyEvent.isAltDown( ) ? items.size( ) - itemRange : theKeyEvent.isShiftDown( ) ? 10 : 1 );
				updateHover( );
				break;
			case ( ControlP5.LEFT ):
				break;
			case ( ControlP5.RIGHT ):
				break;
			case ( ControlP5.ENTER ):
				onRelease( );
				break;
			}
		}
	}
	/* TODO keycontrol: arrows, return dragging moving items
	 * sorting custom view custom event types */
}
