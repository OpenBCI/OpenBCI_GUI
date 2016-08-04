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

import java.util.ArrayList;
import java.util.List;

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;
import processing.event.KeyEvent;

/**
 * ControllerGroup is an abstract class and is extended by class ControlGroup, Tab, or the ListBox.
 * 
 */
public abstract class ControllerGroup< T > implements ControllerInterface< T > , ControlP5Constants , ControlListener {

	protected float[] position = new float[ 2 ];
	protected float[] positionBuffer = new float[ 2 ];
	protected float[] absolutePosition = new float[ 2 ];
	protected ControllerList controllers;
	protected List< ControlListener > _myControlListener;
	// protected ControlWindow _myControlWindow;
	protected ControlP5 cp5;
	protected ControllerGroup< ? > _myParent;
	protected String _myName;
	protected int _myId = -1;
	protected CColor color = new CColor( );
	protected boolean isMousePressed = false;
	// only applies to the area of the title bar of a group
	protected boolean isInside = false;
	// applies to the area including controllers, currently only supported for listbox
	protected boolean isInsideGroup = false;
	protected boolean isVisible = true;
	protected boolean isOpen = true;
	protected boolean isBarVisible = true;
	protected boolean isArrowVisible = true;
	protected Button _myCloseButton;
	protected boolean isMoveable = true;
	protected Label _myLabel;
	protected Label _myValueLabel;
	protected int _myWidth = 99;
	protected int _myHeight = 9;
	protected boolean isUpdate;
	protected List< Canvas > _myCanvas;
	protected float _myValue;
	protected String _myStringValue;
	protected float[] _myArrayValue;
	protected boolean isCollapse = true;
	protected int _myPickingColor = 0x6600ffff;
	protected float[] autoPosition = new float[] { 10 , 30 };
	protected float tempAutoPositionHeight = 0;
	protected float autoPositionOffsetX = 10;
	private String _myAddress = "";
	private boolean mouseover;
	protected final T me;

	/**
	 * Convenience constructor to extend ControllerGroup.
	 */
	public ControllerGroup( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	public ControllerGroup( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theX , float theY ) {
		position = new float[] { theX , theY };
		cp5 = theControlP5;
		me = ( T ) this;
		color.set( ( theParent == null ) ? cp5.color : theParent.color );
		_myName = theName;
		controllers = new ControllerList( );
		_myCanvas = new ArrayList< Canvas >( );
		_myControlListener = new ArrayList< ControlListener >( );
		_myLabel = new Label( cp5 , _myName );
		_myLabel.setText( _myName );
		_myLabel.setColor( color.getCaptionLabel( ) );
		_myLabel.align( LEFT , TOP );
		setParent( ( theParent == null ) ? this : theParent );
	}

	protected ControllerGroup( int theX , int theY ) {
		position = new float[] { theX , theY };
		me = ( T ) this;
		controllers = new ControllerList( );
		_myCanvas = new ArrayList< Canvas >( );
	}

	@ControlP5.Invisible public void init( ) {
	}

	@ControlP5.Invisible @Override public ControllerInterface< ? > getParent( ) {
		return _myParent;
	}

	void setParent( ControllerGroup< ? > theParent ) {

		if ( _myParent != null && _myParent != this ) {
			_myParent.remove( this );
		}

		_myParent = theParent;

		if ( _myParent != this ) {
			_myParent.add( this );
		}

		set( absolutePosition , x( position ) , y( position ) );
		set( absolutePosition , x( absolutePosition ) + x( _myParent.absolutePosition ) , y( absolutePosition ) + y( _myParent.absolutePosition ) );
		set( positionBuffer , x( position ) , y( position ) );

		if ( cp5.getWindow( ) != null ) {
			setMouseOver( false );
		}
	}

	public final T setGroup( ControllerGroup< ? > theGroup ) {
		setParent( theGroup );
		return me;
	}

	public final T setGroup( String theName ) {
		setParent( cp5.getGroup( theName ) );
		return me;
	}

	public final T moveTo( ControllerGroup< ? > theGroup , Tab theTab , ControlWindow theControlWindow ) {
		if ( theGroup != null ) {
			setGroup( theGroup );
			return me;
		}

		if ( theControlWindow == null ) {
			theControlWindow = cp5.controlWindow;
		}

		setTab( theControlWindow , theTab.getName( ) );
		return me;
	}

	public final T moveTo( ControllerGroup< ? > theGroup ) {
		moveTo( theGroup , null , null );
		return me;
	}

	public final T moveTo( Tab theTab ) {
		moveTo( null , theTab , theTab.getWindow( ) );
		return me;
	}

	public T moveTo( PApplet thePApplet ) {
		moveTo( cp5.controlWindow );
		return me;
	}

	public T moveTo( ControlWindow theControlWindow ) {
		moveTo( null , theControlWindow.getTab( "default" ) , theControlWindow );
		return me;
	}

	public final T moveTo( String theTabName ) {
		moveTo( null , cp5.controlWindow.getTab( theTabName ) , cp5.controlWindow );
		return me;
	}

	public final T moveTo( String theTabName , ControlWindow theControlWindow ) {
		moveTo( null , theControlWindow.getTab( theTabName ) , theControlWindow );
		return me;
	}

	public final T moveTo( ControlWindow theControlWindow , String theTabName ) {
		moveTo( null , theControlWindow.getTab( theTabName ) , theControlWindow );
		return me;
	}

	public final T moveTo( Tab theTab , ControlWindow theControlWindow ) {
		moveTo( null , theTab , theControlWindow );
		return me;
	}

	public final T setTab( String theName ) {
		setParent( cp5.getTab( theName ) );
		return me;
	}

	public final T setTab( ControlWindow theWindow , String theName ) {
		setParent( cp5.getTab( theWindow , theName ) );
		return me;
	}

	public final T setTab( Tab theTab ) {
		setParent( theTab );
		return me;
	}

	public Tab getTab( ) {
		if ( this instanceof Tab ) {
			return ( Tab ) this;
		}
		if ( _myParent instanceof Tab ) {
			return ( Tab ) _myParent;
		}
		return _myParent.getTab( );
	}

	protected void updateFont( ControlFont theControlFont ) {
		_myLabel.updateFont( theControlFont );
		if ( _myValueLabel != null ) {
			_myValueLabel.updateFont( theControlFont );
		}
		for ( int i = 0 ; i < controllers.size( ) ; i++ ) {
			if ( controllers.get( i ) instanceof Controller< ? > ) {
				( ( Controller< ? > ) controllers.get( i ) ).updateFont( theControlFont );
			} else {
				( ( ControllerGroup< ? > ) controllers.get( i ) ).updateFont( theControlFont );
			}
		}
	}

	@ControlP5.Invisible public float[] getAbsolutePosition( ) {
		return new float[] { x( absolutePosition ) , y( absolutePosition ) };
	}

	@ControlP5.Invisible public T setAbsolutePosition( float[] thePos ) {
		set( absolutePosition , x( thePos ) , y( thePos ) );
		return me;
	}

	public float[] getPosition( ) {
		return new float[] { x( position ) , y( position ) };
	}

	public T setPosition( float theX , float theY ) {
		set( position , ( int ) theX , ( int ) theY );
		set( positionBuffer , x( position ) , y( position ) );
		updateAbsolutePosition( );
		return me;
	}

	public T setPosition( float[] thePosition ) {
		setPosition( x( thePosition ) , y( thePosition ) );
		return me;
	}

	public T updateAbsolutePosition( ) {
		set( absolutePosition , x( position ) , y( position ) );
		set( absolutePosition , x( absolutePosition ) + x( _myParent.getAbsolutePosition( ) ) , y( absolutePosition ) + y( _myParent.getAbsolutePosition( ) ) );
		for ( int i = 0 ; i < controllers.size( ) ; i++ ) {
			controllers.get( i ).updateAbsolutePosition( );
		}
		return me;
	}

	@ControlP5.Invisible public void continuousUpdateEvents( ) {
		if ( controllers.size( ) <= 0 ) {
			return;
		}
		for ( int i = controllers.size( ) - 1 ; i >= 0 ; i-- ) {
			( ( ControllerInterface< ? > ) controllers.get( i ) ).continuousUpdateEvents( );
		}
	}

	public T update( ) {
		if ( controllers.size( ) <= 0 ) {
			return me;
		}
		for ( int i = controllers.size( ) - 1 ; i >= 0 ; i-- ) {
			if ( ( ( ControllerInterface< ? > ) controllers.get( i ) ).isUpdate( ) ) {
				( ( ControllerInterface< ? > ) controllers.get( i ) ).update( );
			}
		}
		return me;
	}

	/**
	 * enables or disables the update function of a controller.
	 */
	@Override public T setUpdate( boolean theFlag ) {
		isUpdate = theFlag;
		for ( int i = 0 ; i < controllers.size( ) ; i++ ) {
			( ( ControllerInterface< ? > ) controllers.get( i ) ).setUpdate( theFlag );
		}
		return me;
	}

	/**
	 * checks the update status of a controller.
	 */
	public boolean isUpdate( ) {
		return isUpdate;
	}

	@ControlP5.Invisible public T updateEvents( ) {
		if ( isOpen ) {
			for ( int i = controllers.size( ) - 1 ; i >= 0 ; i-- ) {
				( ( ControllerInterface< ? > ) controllers.get( i ) ).updateEvents( );
			}
		}
		if ( isVisible ) {
			if ( ( isMousePressed == cp5.getWindow( ).mouselock ) ) {
				if ( isMousePressed && cp5.isAltDown( ) && isMoveable ) {
					if ( !cp5.isMoveable ) {
						set( positionBuffer , x( positionBuffer ) + cp5.getWindow( ).mouseX - cp5.getWindow( ).pmouseX , y( positionBuffer ) + cp5.getWindow( ).mouseY - cp5.getWindow( ).pmouseY );
						if ( cp5.isShiftDown( ) ) {
							set( position , ( ( ( int ) ( x( positionBuffer ) ) / 10 ) * 10 ) , ( ( ( int ) ( y( positionBuffer ) ) / 10 ) * 10 ) );
						} else {
							set( position , x( positionBuffer ) , y( positionBuffer ) );
						}
						updateAbsolutePosition( );
					}
				} else {
					if ( isInside ) {
						setMouseOver( true );
					}
					if ( inside( ) ) {
						if ( !isInside ) {
							isInside = true;
							onEnter( );
							setMouseOver( true );
						}
					} else {
						if ( isInside && !isMousePressed ) {
							onLeave( );
							isInside = false;
							setMouseOver( false );
						}
					}
				}
			}
		}
		return me;
	}

	@ControlP5.Invisible public T updateInternalEvents( PApplet theApplet ) {
		return me;
	}

	public boolean isMouseOver( ) {
		mouseover = isInside || isInsideGroup || !isBarVisible;
		return mouseover;
	}

	public T setMouseOver( boolean theFlag ) {

		mouseover = ( !isBarVisible ) ? false : theFlag;

		if ( !mouseover ) {
			isInside = false;
			isInsideGroup = false;
			cp5.getWindow( ).removeMouseOverFor( this );
			for ( int i = controllers.size( ) - 1 ; i >= 0 ; i-- ) {
				controllers.get( i ).setMouseOver( false );
			}
		} else {
			// TODO since inside can be either isInside or isInsideGroup, there are 2 options here,
			// which i am not sure how to handle them yet.
			cp5.getWindow( ).setMouseOverController( this );
		}
		return me;
	}

	@ControlP5.Invisible public final void draw( PGraphics theGraphics ) {
		if ( isVisible ) {
			theGraphics.pushMatrix( );
			theGraphics.translate( x( position ) , y( position ) );
			preDraw( theGraphics );
			drawControllers( cp5.papplet , theGraphics );
			postDraw( theGraphics );
			if ( _myValueLabel != null ) {
				_myValueLabel.draw( theGraphics , 2 , 2 , this );
			}
			theGraphics.popMatrix( );
		}
	}

	protected void drawControllers( PApplet theApplet , PGraphics theGraphics ) {
		if ( isOpen ) {

			for ( Canvas cc : _myCanvas ) {
				if ( cc.mode( ) == Canvas.PRE ) {
					cc.draw( theGraphics );
				}
			}
			for ( ControllerInterface< ? > ci : controllers.get( ) ) {
				if ( ci.isVisible( ) ) {
					ci.updateInternalEvents( theApplet );
					ci.draw( theGraphics );
				}
			}

			for ( CDrawable cd : controllers.getDrawables( ) ) {
				cd.draw( theGraphics );
			}

			for ( Canvas cc : _myCanvas ) {
				if ( cc.mode( ) == Canvas.POST ) {
					cc.draw( theGraphics );
				}
			}
		}
	}

	protected void preDraw( PGraphics theGraphics ) {
	}

	protected void postDraw( PGraphics theGraphics ) {
	}

	/**
	 * Adds a canvas to a controllerGroup such as a tab or group. Use processing's draw methods to
	 * add visual content.
	 */
	public Canvas addCanvas( Canvas theCanvas ) {
		_myCanvas.add( theCanvas );
		// TODO theCanvas.setup( cp5.papplet );
		return theCanvas;
	}

	/**
	 * Removes a canvas from a controller group.
	 */
	public T removeCanvas( Canvas theCanvas ) {
		_myCanvas.remove( theCanvas );
		return me;
	}

	/**
	 * Adds a controller to the group, but use Controller.setGroup() instead.
	 */
	public T add( ControllerInterface< ? > theElement ) {
		controllers.add( theElement );
		return me;
	}

	@Override public T bringToFront( ) {
		return bringToFront( this );
	}

	@Override public T bringToFront( ControllerInterface< ? > theController ) {
		if ( _myParent instanceof Tab ) {
			moveTo( ( Tab ) _myParent );
		} else {
			_myParent.bringToFront( theController );
		}
		if ( theController != this ) {
			if ( controllers.get( ).contains( theController ) ) {
				controllers.remove( theController );
				controllers.add( theController );
			}
		}
		return me;
	}

	/**
	 * Removes a controller from the group, but use Controller.setGroup() instead.
	 */

	public T remove( ControllerInterface< ? > theElement ) {
		if ( theElement != null ) {
			theElement.setMouseOver( false );
		}
		controllers.remove( theElement );
		return me;
	}

	@ControlP5.Invisible public T addDrawable( CDrawable theElement ) {
		controllers.addDrawable( theElement );
		return me;
	}

	public T remove( CDrawable theElement ) {
		controllers.removeDrawable( theElement );
		return me;
	}

	/**
	 * removes the group from controlP5.
	 */
	public void remove( ) {
		cp5.getWindow( ).removeMouseOverFor( this );
		if ( _myParent != null ) {
			_myParent.remove( this );
		}
		if ( cp5 != null ) {
			cp5.remove( this );
		}

		for ( int i = controllers.size( ) - 1 ; i >= 0 ; i-- ) {
			controllers.get( i ).remove( );
		}
		controllers.clear( );
		controllers.clearDrawable( );
		controllers = new ControllerList( );
		if ( this instanceof Tab ) {
			cp5.getWindow( ).removeTab( ( Tab ) this );
		}
	}

	public String getName( ) {
		return _myName;
	}

	public String getAddress( ) {
		return _myAddress;
	}

	@Override public T setAddress( String theAddress ) {
		if ( _myAddress.length( ) == 0 ) {
			_myAddress = theAddress;
		}
		return me;
	}

	public ControlWindow getWindow( ) {
		return cp5.getWindow( );
	}

	@ControlP5.Invisible public void keyEvent( KeyEvent theEvent ) {
		for ( int i = 0 ; i < controllers.size( ) ; i++ ) {
			( ( ControllerInterface< ? > ) controllers.get( i ) ).keyEvent( theEvent );
		}
	}

	public boolean setMousePressed( boolean theStatus ) {
		if ( !isVisible ) {
			return false;
		}
		for ( int i = controllers.size( ) - 1 ; i >= 0 ; i-- ) {
			if ( ( ( ControllerInterface< ? > ) controllers.get( i ) ).setMousePressed( theStatus ) ) {
				return true;
			}
		}
		if ( theStatus == true ) {
			if ( isInside ) {
				isMousePressed = true;
				mousePressed( );
				return true;
			}
		} else {
			if ( isMousePressed == true ) {
				isMousePressed = false;
				mouseReleased( );
			}
		}
		return false;
	}

	protected void mousePressed( ) {
	}

	protected void mouseReleased( ) {
	}

	protected void onEnter( ) {
	}

	protected void onLeave( ) {
	}

	protected void onScroll( int theAmount ) {
	}

	public T setId( int theId ) {
		_myId = theId;
		return me;
	}

	public int getId( ) {
		return _myId;
	}

	public T setColor( CColor theColor ) {
		for ( ControllerInterface< ? > ci : controllers.get( ) ) {
			ci.setColor( theColor );
		}
		return me;
	}

	public T setColorActive( int theColor ) {
		color.setActive( theColor );
		for ( ControllerInterface< ? > ci : controllers.get( ) ) {
			ci.setColorActive( theColor );
		}
		return me;
	}

	public T setColorForeground( int theColor ) {
		color.setForeground( theColor );
		for ( ControllerInterface< ? > ci : controllers.get( ) ) {
			ci.setColorForeground( theColor );
		}
		return me;
	}

	public T setColorBackground( int theColor ) {
		color.setBackground( theColor );
		for ( ControllerInterface< ? > ci : controllers.get( ) ) {
			ci.setColorBackground( theColor );
		}
		return me;
	}

	public T setColorLabel( int theColor ) {
		color.setCaptionLabel( theColor );
		if ( _myLabel != null ) {
			_myLabel.setColor( color.getCaptionLabel( ) );
		}
		for ( ControllerInterface< ? > ci : controllers.get( ) ) {
			ci.setColorLabel( theColor );
		}
		return me;
	}

	public T setColorValue( int theColor ) {
		color.setValueLabel( theColor );
		if ( _myValueLabel != null ) {
			_myValueLabel.setColor( color.getValueLabel( ) );
		}
		for ( ControllerInterface< ? > ci : controllers.get( ) ) {
			ci.setColorValue( theColor );
		}
		return me;
	}

	public T setLabel( String theLabel ) {
		_myLabel.set( theLabel );
		return me;
	}

	public boolean isVisible( ) {
		if ( _myParent != null && _myParent != this ) {
			if ( getParent( ).isVisible( ) == false ) {
				return false;
			}
		}
		return isVisible;
	}

	public T setVisible( boolean theFlag ) {
		isVisible = theFlag;
		return me;
	}

	public T hide( ) {
		isVisible = false;
		return me;
	}

	public T show( ) {
		isVisible = true;
		return me;
	}

	/**
	 * set the moveable status of the group, when false, the group can't be moved.
	 */
	public T setMoveable( boolean theFlag ) {
		isMoveable = theFlag;
		return me;
	}

	public boolean isMoveable( ) {
		return isMoveable;
	}

	public T setOpen( boolean theFlag ) {
		isOpen = theFlag;
		return me;
	}

	public boolean isOpen( ) {
		return isOpen;
	}

	public T open( ) {
		setOpen( true );
		return me;
	}

	public T close( ) {
		setOpen( false );
		return me;
	}

	/**
	 * TODO redesign or deprecate remove the close button.
	 */
	@ControlP5.Invisible public T removeCloseButton( ) {
		if ( _myCloseButton == null ) {
			_myCloseButton.remove( );
		}
		_myCloseButton = null;
		return me;
	}

	public T setTitle( String theTitle ) {
		getCaptionLabel( ).set( theTitle );
		return me;
	}

	public T hideBar( ) {
		isBarVisible = false;
		return me;
	}

	public T showBar( ) {
		isBarVisible = true;
		return me;
	}

	public boolean isBarVisible( ) {
		return isBarVisible;
	}

	public T hideArrow( ) {
		isArrowVisible = false;
		return me;
	}

	public T showArrow( ) {
		isArrowVisible = true;
		return me;
	}

	/**
	 * TODO redesign or deprecate add a close button to the controlbar of this controlGroup.
	 */
	@ControlP5.Invisible public T addCloseButton( ) {
		if ( _myCloseButton == null ) {
			_myCloseButton = new Button( cp5 , this , getName( ) + "close" , 1 , _myWidth + 1 , -10 , 12 , 9 );
			_myCloseButton.setCaptionLabel( "X" );
			_myCloseButton.addListener( this );
		}
		return me;
	}

	@ControlP5.Invisible public int getPickingColor( ) {
		return _myPickingColor;
	}

	public CColor getColor( ) {
		return color;
	}

	public T setValue( float theValue ) {
		_myValue = theValue;
		return me;
	}

	public float getValue( ) {
		return _myValue;
	}

	public String getStringValue( ) {
		return _myStringValue;
	}

	public T setStringValue( String theValue ) {
		_myStringValue = theValue;
		return me;
	}

	public float[] getArrayValue( ) {
		return _myArrayValue;
	}

	public float getArrayValue( int theIndex ) {
		if ( theIndex >= 0 && theIndex < _myArrayValue.length ) {
			return _myArrayValue[ theIndex ];
		} else {
			return Float.NaN;
		}
	}

	public T setArrayValue( int theIndex , float theValue ) {
		if ( theIndex >= 0 && theIndex < _myArrayValue.length ) {
			_myArrayValue[ theIndex ] = theValue;
		}
		return me;
	}

	public T setArrayValue( float[] theArray ) {
		_myArrayValue = theArray;
		return me;
	}

	public Controller< ? > getController( String theController ) {
		return cp5.getController( theController );
	}

	public T setCaptionLabel( String theValue ) {
		getCaptionLabel( ).set( theValue );
		return me;
	}

	public Label getCaptionLabel( ) {
		return _myLabel;
	}

	public Label getValueLabel( ) {
		return _myValueLabel;
	}

	public T enableCollapse( ) {
		isCollapse = true;
		return me;
	}

	public T disableCollapse( ) {
		isCollapse = false;
		return me;
	}

	public boolean isCollapse( ) {
		return isCollapse;
	}

	public int getWidth( ) {
		return _myWidth;
	}

	public int getHeight( ) {
		return _myHeight;
	}

	public T setWidth( int theWidth ) {
		_myWidth = theWidth;
		return me;
	}

	public T setHeight( int theHeight ) {
		_myHeight = theHeight;
		return me;
	}

	public T setSize( int theWidth , int theHeight ) {
		setWidth( theWidth );
		// setHeight(theHeight) will set the Height of the bar therefore will not be used here.
		return me;
	}

	protected boolean inside( ) {
		return ( cp5.getWindow( ).mouseX > x( position ) + x( _myParent.absolutePosition ) && cp5.getWindow( ).mouseX < x( position ) + x( _myParent.absolutePosition ) + _myWidth
		    && cp5.getWindow( ).mouseY > y( position ) + y( _myParent.absolutePosition ) - _myHeight && cp5.getWindow( ).mouseY < y( position ) + y( _myParent.absolutePosition ) );
	}

	public ControllerProperty getProperty( String thePropertyName ) {
		return cp5.getProperties( ).getProperty( this , thePropertyName );
	}

	public ControllerProperty getProperty( String theSetter , String theGetter ) {
		return cp5.getProperties( ).getProperty( this , theSetter , theGetter );
	}

	public T registerProperty( String thePropertyName ) {
		cp5.getProperties( ).register( this , thePropertyName );
		return me;
	}

	public T registerProperty( String theSetter , String theGetter ) {
		cp5.getProperties( ).register( this , theSetter , theGetter );
		return me;
	}

	public T removeProperty( String thePropertyName ) {
		cp5.getProperties( ).remove( this , thePropertyName );
		return me;
	}

	public T removeProperty( String theSetter , String theGetter ) {
		cp5.getProperties( ).remove( this , theSetter , theGetter );
		return me;
	}

	public void controlEvent( ControlEvent theEvent ) {
	}

	public T addListener( final ControlListener theListener ) {
		_myControlListener.add( theListener );
		return me;
	}

	public T removeListener( final ControlListener theListener ) {
		_myControlListener.remove( theListener );
		return me;
	}

	public int listenerSize( ) {
		return _myControlListener.size( );
	}

	@Override public String toString( ) {
		return getName( ) + " [" + getClass( ).getSimpleName( ) + "]";
	}

	public String getInfo( ) {
		return "type:\tControllerGroup" + "\nname:\t" + _myName + "\n" + "label:\t" + _myLabel.getText( ) + "\n" + "id:\t" + _myId + "\n" + "value:\t" + _myValue + "\n" + "arrayvalue:\t" + CP.arrayToString( _myArrayValue ) + "\n" + "position:\t"
		    + position + "\n" + "absolute:\t" + absolutePosition + "\n" + "width:\t" + getWidth( ) + "\n" + "height:\t" + getHeight( ) + "\n" + "color:\t" + getColor( ) + "\n" + "visible:\t" + isVisible + "\n" + "moveable:\t" + isMoveable + "\n";
	}

	/**
	 * convenience method to fill a float array in favor of theArray[0] = 1.2; etc.
	 * takes a float array and fills it (starting from index 0) with arguments starting from index 1.  
	 */
	static public float[] set( float[] theArray , float ... theValues ) {
		if ( theValues.length > theArray.length ) {
			System.arraycopy( theValues , 0 , theArray , 0 , theArray.length );
		} else {
			System.arraycopy( theValues , 0 , theArray , 0 , theValues.length );
		}
		return theArray;
	}

	/**
	 * returns the first element of the float array.
	 */
	static public float x( float[] theArray ) {
		if ( theArray.length > 0 ) {
			return theArray[ 0 ];
		}
		return 0;
	}

	/**
	 * returns the second element of the float array.
	 */
	static public float y( float[] theArray ) {
		if ( theArray.length > 1 ) {
			return theArray[ 1 ];
		}
		return 0;
	}

	@Override public T setFont( PFont thePFont ) {
		getValueLabel( ).setFont( thePFont );
		getCaptionLabel( ).setFont( thePFont );
		return me;
	}

	@Override public T setFont( ControlFont theFont ) {
		getValueLabel( ).setFont( theFont );
		getCaptionLabel( ).setFont( theFont );
		return me;
	}

}
