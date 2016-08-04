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

import processing.core.PGraphics;

/**
 * Tabs are used to organize controllers. Tabs are arranged horizontally from the top-left corner by
 * default, Tab extends ControllerGroup, for more available methods see the ControllerGroup
 * documentation. Reposition tabs with {@link controlP5.ControlWindow#setPositionOfTabs(int, int)}
 * 
 * @example controllers/ControlP5tab
 * @nosuperclasses ControllerGroup ControllerGroup
 */
public class Tab extends ControllerGroup< Tab > {

	protected int _myOffsetX = -1000;
	protected int _myOffsetY = -1000;
	protected boolean isActive = false;
	private boolean isAlwaysActive = false;
	protected boolean isEventActive = false;
	protected float _myValue = 0;
	protected String _myStringValue = "";
	public static int padding = 4;
	public boolean autoWidth = true;

	/**
	 * 
	 * @param theControlP5 ControlP5
	 * @param theControlWindow ControlWindow
	 * @param theName String
	 */
	public Tab( ControlP5 theControlP5 , ControlWindow theControlWindow , String theName ) {
		super( theControlP5 , null , theName , 0 , 0 );
		position = new float[ 2 ];
		absolutePosition = new float[ 2 ];
		isMoveable = false;
		isEventActive = theControlP5.isTabEventsActive;
		_myHeight = 16;
		_myWidth = _myLabel.getWidth( ) + padding * 2;
		_myLabel.align( LEFT , CENTER ).setPadding( 0 , 0 );
	}

	protected void setOffset( int theValueX , int theValueY ) {
		_myOffsetX = theValueX;
		_myOffsetY = theValueY;
	}

	protected int height( ) {
		return _myHeight;
	}

	protected boolean updateLabel( ) {
		isInside = inside( );
		return cp5.getWindow( ).getTabs( ).size( ) > 2;
	}

	protected void drawLabel( PGraphics theGraphics ) {
		if ( autoWidth ) {
			_myWidth = _myLabel.getWidth( ) + padding * 2;
		}
		theGraphics.pushMatrix( );
		theGraphics.pushStyle( );
		theGraphics.noStroke( );
		theGraphics.fill( isInside ? color.getForeground( ) : color.getBackground( ) );
		if ( isActive ) {
			theGraphics.fill( color.getActive( ) );
		}
		theGraphics.translate( _myOffsetX , _myOffsetY );
		theGraphics.rect( 0 , 0 , _myWidth - 1 , _myHeight );
		_myLabel.draw( theGraphics , padding , 0 , this );
		theGraphics.popStyle( );
		theGraphics.popMatrix( );
	}

	/**
	 * set the label of the group. TODO overwriting COntrollerGroup.setLabel to set the Width of a
	 * tab after renaming. this should be temporary and fixed in the future.
	 * 
	 * @param theLabel String
	 * @return Tab
	 */
	public Tab setLabel( String theLabel ) {
		_myLabel.set( theLabel );
		return this;
	}

	protected int width( ) {
		return _myWidth;
	}

	/**
	 * @param theWidth
	 * @return
	 */
	public Tab setWidth( int theWidth ) {
		_myWidth = theWidth + padding;
		autoWidth = false;
		return this;
	}

	public Tab setHeight( int theHeight ) {
		_myHeight = theHeight;
		return this;
	}

	protected boolean inside( ) {
		return ( cp5.getWindow( ).mouseX > _myOffsetX && cp5.getWindow( ).mouseX < _myOffsetX + _myWidth && cp5.getWindow( ).mouseY > _myOffsetY && cp5.getWindow( ).mouseY < _myOffsetY + _myHeight );
	}

	/**
	 * {@inheritDoc}
	 */
	@ControlP5.Invisible public void mousePressed( ) {
		cp5.getWindow( ).activateTab( this );
		if ( isEventActive ) {
			cp5.getControlBroadcaster( ).broadcast( new ControlEvent( this ) , ControlP5Constants.METHOD );
		}
	}

	/**
	 * Activates a tab.
	 * 
	 * @param theFlag boolean
	 */
	public Tab setActive( boolean theFlag ) {
		isActive = theFlag;
		return this;
	}

	public Tab setAlwaysActive( boolean theFlag ) {
		isAlwaysActive = theFlag;
		return this;
	}

	/**
	 * checks if a tab is active.
	 * 
	 * @return boolean
	 */
	public boolean isActive( ) {
		return isAlwaysActive ? true : isActive;
	}

	public boolean isAlwaysActive( ) {
		return isAlwaysActive;
	}

	@Override public Tab bringToFront( ) {
		cp5.getWindow( ).activateTab( this );
		return this;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Tab moveTo( ControlWindow theWindow ) {
		cp5.getWindow( ).removeTab( this );
		setTab( theWindow , getName( ) );
		return this;
	}

	/**
	 * activates or deactivates the Event status of a tab, When activated a tab will send a
	 * controlEvent to the main application. By default this is disabled.
	 * 
	 * @param theFlag boolean
	 * @return Tab
	 */
	public Tab activateEvent( boolean theFlag ) {
		isEventActive = theFlag;
		return this;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public String getStringValue( ) {
		return _myStringValue;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public float getValue( ) {
		return _myValue;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override public Tab setValue( float theValue ) {
		_myValue = theValue;
		return this;
	}

	@Deprecated public float value( ) {
		return _myValue;
	}

	@Deprecated public String stringValue( ) {
		return _myStringValue;
	}

}
