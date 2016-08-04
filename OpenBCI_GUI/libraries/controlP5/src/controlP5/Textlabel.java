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

import java.util.Arrays;
import java.util.List;

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;

/**
 * @example controllers/ControlP5textlabel
 * @nosuperclasses Controller Controller Textarea
 */
public class Textlabel extends Controller< Textlabel > {

	protected int _myLetterSpacing = 0;

	private boolean disabled;

	/**
	 * 
	 * @param theControlP5 ControlP5
	 * @param theParent Tab
	 * @param theName String
	 * @param theValue String
	 * @param theX int
	 * @param theY int
	 */
	protected Textlabel( final ControlP5 theControlP5 , final Tab theParent , final String theName , final String theValue , final int theX , final int theY ) {
		super( theControlP5 , theParent , theName , theX , theY , 200 , 20 );
		_myStringValue = theValue;
		setup( );
	}

	/**
	 * 
	 * @param theValue String
	 * @param theX int
	 * @param theY int
	 */
	protected Textlabel( final String theValue , final int theX , final int theY ) {
		super( "" , theX , theY );
		_myStringValue = theValue;
		setup( );
	}

	protected Textlabel( final String theValue , final int theX , final int theY , final int theW , final int theH , final int theColor ) {
		super( "" , theX , theY );

		_myStringValue = theValue;
		_myValueLabel = new Label( cp5 , _myStringValue , theW , theH , theColor );
		_myValueLabel.setFont( cp5.controlFont == cp5.defaultFont ? cp5.defaultFontForText : cp5.controlFont );
		_myValueLabel.setMultiline( false );
		_myValueLabel.toUpperCase( false );
	}

	public Textlabel( ControlP5 theControlP5 , final String theValue , final int theX , final int theY ) {
		super( "" , theX , theY );

		cp5 = theControlP5;
		_myStringValue = theValue;
		_myValueLabel = new Label( cp5 , _myStringValue , 10 , 10 , 0xffffffff );
		_myValueLabel.setFont( cp5.controlFont == cp5.defaultFont ? cp5.defaultFontForText : cp5.controlFont );
		_myValueLabel.set( _myStringValue );
		_myValueLabel.setMultiline( false );
		_myValueLabel.toUpperCase( false );
	}

	public Textlabel( ControlP5 theControlP5 , final String theValue , final int theX , final int theY , final int theW , final int theH ) {
		super( "" , theX , theY );
		cp5 = theControlP5;
		_myStringValue = theValue;
		_myValueLabel = new Label( cp5 , _myStringValue , theW , theH , 0xffffffff );
		_myValueLabel.setFont( cp5.controlFont == cp5.defaultFont ? cp5.defaultFontForText : cp5.controlFont );
		_myValueLabel.setMultiline( false );
		_myValueLabel.toUpperCase( false );
	}

	protected void setup( ) {
		_myValueLabel = new Label( cp5 , _myStringValue );
		_myValueLabel.setFont( cp5.controlFont == cp5.defaultFont ? cp5.defaultFontForText : cp5.controlFont );
		_myValueLabel.setMultiline( false );
		_myValueLabel.toUpperCase( false );
	}

	@Override public Textlabel setWidth( int theValue ) {
		_myValueLabel.setWidth( theValue );
		return this;
	}

	public Textlabel setHeight( int theValue ) {
		_myValueLabel.setHeight( theValue );
		return this;
	}

	public void draw( final PApplet theApplet ) {
		draw( theApplet.g );
	}

	@Override public void draw( final PGraphics theGraphics ) {
		if ( !disabled ) {
			theGraphics.pushMatrix( );
			theGraphics.translate( x( position ) , y( position ) );
			_myValueLabel.draw( theGraphics , 0 , 0 , this );
			theGraphics.popMatrix( );
		}
	}

	public void draw( ) {
		draw( cp5.pg );
	}

	public void draw( int theX , int theY ) {
		cp5.papplet.pushMatrix( );
		cp5.papplet.translate( theX , theY );
		draw( cp5.pg );
		cp5.papplet.popMatrix( );
	}

	public Textlabel setValue( float theValue ) {
		return this;
	}

	public Textlabel setText( final String theText ) {
		return setValue( theText );
	}

	public Textlabel setLineHeight( int theValue ) {
		_myValueLabel.setLineHeight( theValue );
		return this;
	}

	public int getLineHeight( ) {
		return _myValueLabel.getLineHeight( );
	}
	
	public ControllerStyle getStyle() {
		return _myValueLabel.getStyle( );
	}

	public Textlabel append( String theText , int max ) {
		String str = _myStringValue + theText;

		if ( max == -1 ) {
			return setText( str );
		}

		List< String > strs = Arrays.asList( str.split( "\n" ) );
		return setText( CP.join( strs.subList( Math.max( 0 , strs.size( ) - max ) , strs.size( ) ) , "\n" ) );
	}

	@Override public Textlabel setStringValue( String theValue ) {
		return setValue( theValue );
	}

	public Textlabel setMultiline( final boolean theFlag ) {
		_myValueLabel.setMultiline( true );
		return this;
	}

	/**
	 * set the text of the textlabel.
	 * 
	 * @param theText String
	 */
	public Textlabel setValue( final String theText ) {
		_myStringValue = theText;
		_myValueLabel.set( theText );
		setWidth( _myValueLabel.getWidth( ) );
		setHeight( _myValueLabel.getHeight( ) );
		return this;
	}

	public Textlabel setColor( int theColor ) {
		_myValueLabel.setColor( theColor , true );
		return this;
	}

	/**
	 * set the letter spacing of the font.
	 * 
	 * @param theValue int
	 * @return Textlabel
	 */
	public Textlabel setLetterSpacing( final int theValue ) {
		_myLetterSpacing = theValue;
		_myValueLabel.setLetterSpacing( _myLetterSpacing );
		return this;
	}

	public Textlabel setFont( ControlFont theControlFont ) {
		getValueLabel( ).setFont( theControlFont );
		return this;
	}

	public Textlabel setFont( PFont thePFont ) {
		getValueLabel( ).setFont( thePFont );
		return this;
	}

	protected boolean inside( ) {
		return ( _myControlWindow.mouseX > x( position ) + x( _myParent.getAbsolutePosition( ) ) && _myControlWindow.mouseX < x( position ) + x( _myParent.getAbsolutePosition( ) ) + _myValueLabel.getWidth( )
		    && _myControlWindow.mouseY > y( position ) + y( _myParent.getAbsolutePosition( ) ) && _myControlWindow.mouseY < y( position ) + y( _myParent.getAbsolutePosition( ) ) + _myValueLabel.getHeight( ) );
	}

	public Label get( ) {
		return _myValueLabel;
	}

	private void printConstructorError( String theValue ) {
		ControlP5
		    .logger( )
		    .severe(
		        "The Textlabel constructor you are using has been deprecated, please use constructor\nnew Textlabel(ControlP5,String,int,int) or\nnew Textlabel(ControlP5,String,int,int,int,int) or\nnew Textlabel(ControlP5,String,int,int,int,int,int,int)\ninstead. The Textlabel with value '"
		            + theValue + "' is disabled and will not be rendered." );
	}

}
