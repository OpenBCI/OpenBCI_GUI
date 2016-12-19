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

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;
import processing.event.KeyEvent;

/**
 * 
 * The ControllerInterface is inherited by all ControllerGroup and Controller classes.
 * 
 */
public interface ControllerInterface< T > {

	@ControlP5.Invisible public void init( );

	public int getWidth( );

	public int getHeight( );

	public T setValue( float theValue );

	public float getValue( );

	public T setStringValue( String theValue );

	public String getStringValue( );

	public float[] getArrayValue( );

	public float getArrayValue( int theIndex );

	public T setArrayValue( int theIndex , float theValue );

	public T setArrayValue( float[] theArray );

	public int getId( );

	public float[] getPosition( );

	@ControlP5.Invisible public T setPosition( float theX , float theY );

	@ControlP5.Invisible public T setPosition( float[] thePosition );

	public float[] getAbsolutePosition( );

	public T setAbsolutePosition( float[] thePosition );

	public T updateAbsolutePosition( );

	public ControllerInterface< ? > getParent( );

	public T update( );

	public T setUpdate( boolean theFlag );

	public T bringToFront( );

	public T bringToFront( ControllerInterface< ? > theController );

	public boolean isUpdate( );

	@ControlP5.Invisible public T updateEvents( );

	@ControlP5.Invisible public void continuousUpdateEvents( );

	/**
	 * a method for putting input events like e.g. mouse or keyboard events and queries. this has
	 * been taken out of the draw method for better overwriting capability.
	 * 
	 * 
	 */
	@ControlP5.Invisible public T updateInternalEvents( PApplet theApplet );

	@ControlP5.Invisible public void draw( PGraphics theGraphics );

	public T add( ControllerInterface< ? > theElement );

	public T remove( ControllerInterface< ? > theElement );

	public void remove( );

	public String getName( );

	public String getAddress( );

	public ControlWindow getWindow( );

	public Tab getTab( );

	public boolean setMousePressed( boolean theStatus );

	@ControlP5.Invisible public void keyEvent( KeyEvent theEvent );

	@ControlP5.Invisible public T setAddress( String theAddress );

	public T setId( int theValue );

	public T setLabel( String theString );

	public T setColorActive( int theColor );

	public T setColorForeground( int theColor );

	public T setColorBackground( int theColor );

	public T setColorLabel( int theColor );

	public T setColorValue( int theColor );

	public T setColor( CColor theColor );

	public CColor getColor( );

	public T show( );

	public T hide( );

	public boolean isVisible( );

	public T moveTo( ControllerGroup< ? > theGroup , Tab theTab , ControlWindow theWindow );

	public T moveTo( ControllerGroup< ? > theGroup );

	@ControlP5.Invisible public int getPickingColor( );

	public ControllerProperty getProperty( String thePropertyName );

	public ControllerProperty getProperty( String theSetter , String theGetter );

	public T registerProperty( String thePropertyName );

	public T registerProperty( String theSetter , String theGetter );

	public T removeProperty( String thePropertyName );

	public T removeProperty( String theSetter , String theGetter );

	public boolean isMouseOver( );

	public T setMouseOver( boolean theFlag );
	
	public T setFont( PFont theFont );
	
	public T setFont( ControlFont theFont );
	
	public T addListener( ControlListener theListener );

	public T setCaptionLabel( String theValue );
}
