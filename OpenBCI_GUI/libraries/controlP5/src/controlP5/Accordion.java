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

/**
 * <p>
 * An Accordion here is a list of ControlGroups which can be expanded and collapsed. 
 * 
 * @see controlP5.ControllerGroup
 * @see controlP5.ControlGroup
 * @example controllers/ControlP5accordion
 */
@SuppressWarnings( "rawtypes" ) public class Accordion extends ControlGroup< Accordion > {

	
	protected int spacing = 1;
	protected int minHeight = 100;
	protected int itemheight;
	protected int _myMode = SINGLE;

	public Accordion( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 200 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	Accordion( ControlP5 theControlP5 , Tab theTab , String theName , int theX , int theY , int theW ) {
		super( theControlP5 , theTab , theName , theX , theY , theW , 9 );
		hideBar( );
	}

	/**
	 * Adds items of type ControlGroup to the Accordion, only ControlGroups can be added.
	 * 
	 * @exclude
	 * @param theGroup
	 * @return Accordion
	 */
	public Accordion addItem( ControlGroup< ? > theGroup ) {
		theGroup.close( );
		theGroup.moveTo( this );
		theGroup.activateEvent( true );
		theGroup.addListener( this );
		theGroup.setMoveable( false );
		if ( theGroup.getBackgroundHeight( ) < minHeight ) {
			theGroup.setBackgroundHeight( minHeight );
		}
		controllers.add( theGroup );
		updateItems( );
		return this;
	}

	/**
	 * Removes a ControlGroup from the accordion AND from controlP5 remove(ControllerInterface
	 * theGroup) overwrites it's super method. if you want to remove a ControlGroup only from the
	 * accordion, use removeItem(ControlGroup).
	 * 
	 * @see controlP5.Accordion#removeItem(ControlGroup)
	 * @return ControllerInterface
	 */
	@Override public Accordion remove( ControllerInterface< ? > theGroup ) {
		if ( theGroup instanceof ControlGroup< ? > ) {
			controllers.remove( theGroup );
			( ( ControlGroup< ? > ) theGroup ).removeListener( this );
			updateItems( );
		}
		super.remove( theGroup );
		return this;
	}

	/**
	 * Removes a ControlGroup from the accordion and puts it back into the default tab of controlP5.
	 * if you dont have access to a ControlGroup via a variable, use
	 * controlP5.group("theNameOfTheGroup") which will return a
	 * 
	 * @return Accordion
	 */
	public Accordion removeItem( ControlGroup< ? > theGroup ) {
		if ( theGroup == null ) {
			return this;
		}
		controllers.remove( theGroup );
		theGroup.removeListener( this );
		theGroup.moveTo( cp5.controlWindow );
		updateItems( );
		return this;
	}

	/**
	 * UpdateItems is called when changes such as remove, change of height is performed on an
	 * accordion. updateItems() is called automatically for such cases, but by calling updateItems
	 * manually an update will be forced.
	 * 
	 * @return Accordion
	 */
	public Accordion updateItems( ) {
		int n = 0;
		setWidth( _myWidth );

		for ( ControllerInterface< ? > cg : controllers.get( ) ) {
			if ( cg instanceof ControlGroup ) {
				n += ( ( ControlGroup ) cg ).getBarHeight( ) + spacing;
				cg.setPosition( 0 , n );
				if ( ( ( ControlGroup ) cg ).isOpen( ) ) {
					n += ( ( ControlGroup ) cg ).getBackgroundHeight( );
				}
			}
		}
		return this;
	}

	/**
	 * Sets the minimum height of a collapsed item, default value is 100.
	 * 
	 * @param theHeight
	 * @return Accordion
	 */
	public Accordion setMinItemHeight( int theHeight ) {
		minHeight = theHeight;
		for ( ControllerInterface< ? > cg : controllers.get( ) ) {
			if ( cg instanceof ControlGroup ) {
				if ( ( ( ControlGroup ) cg ).getBackgroundHeight( ) < minHeight ) {
					( ( ControlGroup ) cg ).setBackgroundHeight( minHeight );
				}
			}
		}
		updateItems( );
		return this;
	}

	public int getMinItemHeight( ) {
		return minHeight;
	}

	public Accordion setItemHeight( int theHeight ) {
		itemheight = theHeight;
		for ( ControllerInterface< ? > cg : controllers.get( ) ) {
			if ( cg instanceof ControlGroup ) {
				( ( ControlGroup ) cg ).setBackgroundHeight( itemheight );
			}
		}
		updateItems( );
		return this;
	}

	public int getItemHeight( ) {
		return itemheight;
	}

	@Override public Accordion setWidth( int theWidth ) {
		super.setWidth( theWidth );
		for ( ControllerInterface< ? > cg : controllers.get( ) ) {
			if ( cg instanceof ControlGroup ) {
				( ( ControlGroup ) cg ).setWidth( theWidth );
			}
		}
		return this;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override @ControlP5.Invisible public void controlEvent( ControlEvent theEvent ) {
		if ( theEvent.isGroup( ) ) {
			int n = 0;
			for ( ControllerInterface< ? > cg : controllers.get( ) ) {
				if ( cg instanceof ControlGroup ) {
					n += ( ( ControlGroup ) cg ).getBarHeight( ) + spacing;
					cg.setPosition( 0 , n );
					if ( _myMode == SINGLE ) {
						if ( cg == theEvent.getGroup( ) && ( ( ControlGroup ) cg ).isOpen( ) ) {
							n += ( ( ControlGroup ) cg ).getBackgroundHeight( );
						} else {
							( ( ControlGroup ) cg ).close( );
						}
					} else {
						if ( ( ( ControlGroup ) cg ).isOpen( ) ) {
							n += ( ( ControlGroup ) cg ).getBackgroundHeight( );
						}
					}
				}
			}
		}
	}

	public Accordion open( ) {
		int[] n = new int[ controllers.size( ) ];
		for ( int i = 0 ; i < controllers.size( ) ; i++ ) {
			n[ i ] = i;
		}
		return open( n );
	}

	public Accordion close( ) {
		int[] n = new int[ controllers.size( ) ];
		for ( int i = 0 ; i < controllers.size( ) ; i++ ) {
			n[ i ] = i;
		}
		return close( n );
	}

	public Accordion open( int ... theId ) {
		if ( theId[ 0 ] == -1 ) {
			return open( );
		}
		int n = 0 , i = 0;
		for ( ControllerInterface< ? > cg : controllers.get( ) ) {
			if ( cg instanceof ControlGroup ) {
				boolean a = false;
				for ( int j = 0 ; j < theId.length ; j++ ) {
					if ( theId[ j ] == i ) {
						a = true;
					}
				}
				boolean b = ( ( ControlGroup ) cg ).isOpen( ) || a ? true : false;
				i++;
				n += ( ( ControlGroup ) cg ).getBarHeight( ) + spacing;
				cg.setPosition( 0 , n );
				if ( b ) {
					n += ( ( ControlGroup ) cg ).getBackgroundHeight( );
					( ( ControlGroup ) cg ).open( );
				}
			}
		}
		return this;
	}

	public Accordion close( int ... theId ) {
		if ( theId[ 0 ] == -1 ) {
			return close( );
		}
		int n = 0 , i = 0;
		for ( ControllerInterface< ? > cg : controllers.get( ) ) {
			if ( cg instanceof ControlGroup ) {
				boolean a = false;
				for ( int j = 0 ; j < theId.length ; j++ ) {
					if ( theId[ j ] == i ) {
						a = true;
					}
				}
				boolean b = ! ( ( ControlGroup ) cg ).isOpen( ) || a ? true : false;
				i++;
				n += ( ( ControlGroup ) cg ).getBarHeight( ) + spacing;
				( ( ControlGroup ) cg ).setPosition( 0 , n );
				if ( b ) {
					( ( ControlGroup ) cg ).close( );
				} else {
					n += ( ( ControlGroup ) cg ).getBackgroundHeight( );
				}
			}
		}
		return this;
	}

	public Accordion setCollapseMode( int theMode ) {
		if ( theMode == 0 ) {
			_myMode = SINGLE;
		} else {
			_myMode = MULTI;
		}
		return this;
	}
}
