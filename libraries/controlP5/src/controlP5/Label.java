package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser
 * General Public License as published by the Free Software
 * Foundation; either version 2.1 of the License, or (at
 * your option) any later version. This library is
 * distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 59 Temple Place,
 * Suite 330, Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 04/14/2016
 * @version 2.2.6
 * 
 */

import processing.core.PFont;
import processing.core.PGraphics;

/**
 * A custom label using controlP5's BitFonts or PFont based
 * ControlFonts.
 * 
 * 
 * @see controlP5.ControlFont
 * @example controllers/ControlP5Textlabel
 * 
 */
public class Label implements CDrawable {

	public static boolean isToUpperCaseDefault = true;
	protected int _myLetterSpacing = 0;
	protected boolean isMultiline;
	protected boolean isFixedSize;
	protected ControllerStyle _myControllerStyle = new ControllerStyle( );
	protected boolean isVisible = true;
	protected int _myColor = 0xffffffff;
	protected boolean isColorBackground;
	protected boolean isToUpperCase = isToUpperCaseDefault;
	protected boolean changed;
	protected int _myColorBackground = 0xffffffff;
	protected int _myHeight = -1;
	protected int _myWidth = -1;
	protected String _myText = "";
	protected ControlFont _myFontLabel;
	protected int _myLineHeight = 0;
	protected int alignX = ControlP5.LEFT;
	protected int alignY = ControlP5.LEFT;
	protected int textAlign = ControlP5.LEFT;
	public static int paddingX = 4;
	public static int paddingY = 4;
	public int _myPaddingX = paddingX;
	public int _myPaddingY = paddingY;
	protected Labeltype _myLabeltype;
	protected int _myTextHeight = 1;
	protected float offsetYratio = 0;
	private ControlP5 cp5;

	private Label( Label theLabel ) {
		_myText = theLabel.getText( );
		isToUpperCase = theLabel.isToUpperCase( );
		_myLetterSpacing = theLabel.getLetterSpacing( );
		_myLineHeight = theLabel.getLineHeight( );
		_myFontLabel = theLabel.getFont( );
		_myLabeltype = theLabel.getLabeltype( );
	}

	public Label( ControlP5 theControlP5 , String theValue ) {
		init( theControlP5 , theValue , 0 , 0 , _myColor );
	}

	public Label( ControlP5 theControlP5 , String theValue , int theWidth , int theHeight , int theColor ) {
		init( theControlP5 , theValue , theWidth , theHeight , theColor );
	}

	private void init( ControlP5 theControlP5 , String theValue , int theWidth , int theHeight , int theColor ) {
		cp5 = theControlP5;
		_myWidth = theWidth;
		_myHeight = theHeight;
		_myText = theValue;
		_myColor = theColor;
		setLabeltype( new SinglelineLabel( ) );
		setFont( cp5.controlFont );
		setLabeltype( new SinglelineLabel( ) );
		set( _myText );
		_myControllerStyle = new ControllerStyle( );
	}

	Label setLabeltype( Labeltype theType ) {
		_myLabeltype = theType;
		return this;
	}

	Labeltype getLabeltype( ) {
		return _myLabeltype;
	}

	public Label align( int[] a ) {
		alignX = a[ 0 ];
		alignY = a[ 1 ];
		return this;
	}

	public Label align( int theX , int theY ) {
		alignX = theX;
		alignY = theY;
		return this;
	}

	public Label alignX( int theX ) {
		alignX = theX;
		return this;
	}

	public Label alignY( int theY ) {
		alignY = theY;
		return this;
	}

	public int[] getAlign( ) {
		return new int[] { alignX , alignY };
	}

	public Label setPadding( int thePaddingX , int thePaddingY ) {
		_myPaddingX = thePaddingX;
		_myPaddingY = thePaddingY;
		return this;
	}

	public Label setPaddingX( int thePaddingX ) {
		_myPaddingX = thePaddingX;
		return this;
	}

	public Label setPaddingY( int thePaddingY ) {
		_myPaddingY = thePaddingY;
		return this;
	}

	public void draw( PGraphics theGraphics , int theX , int theY , ControllerInterface< ? > theController ) {
		if ( isVisible ) {
			getLabeltype( ).draw( this , theGraphics , theX , theY , theController );
		}
	}

	public void draw( PGraphics theGraphics , int theX , int theY , int theW , int theH ) {
		if ( isVisible ) {
			getLabeltype( ).draw( this , theGraphics , theX , theY , theW , theH );
		}
	}

	@Override public void draw( PGraphics theGraphics ) {
		if ( isVisible ) {
			_myFontLabel.adjust( theGraphics , this );
			draw( theGraphics , 0 , 0 );
		}
	}

	public void draw( PGraphics theGraphics , int theX , int theY ) {
		if ( isVisible ) {
			theGraphics.pushMatrix( );
			theGraphics.translate( _myControllerStyle.marginLeft , _myControllerStyle.marginTop );
			theGraphics.translate( theX , theY );

			if ( isColorBackground ) {

				float ww = getStyle( ).paddingRight + getStyle( ).paddingLeft;
				if ( getStyle( ).backgroundWidth > -1 ) {
					ww += _myControllerStyle.backgroundWidth;
				} else {
					ww += _myFontLabel.getWidth( );
				}
				float hh = getStyle( ).paddingBottom + getStyle( ).paddingTop;
				if ( getStyle( ).backgroundHeight > -1 ) {
					hh += getStyle( ).backgroundHeight;
				} else {
					hh += _myFontLabel.getHeight( );
				}
				theGraphics.fill( _myColorBackground );
				theGraphics.rect( 0 , 1 , ww , hh );
			}
			theGraphics.translate( _myControllerStyle.paddingLeft , _myControllerStyle.paddingTop );
			_myFontLabel.draw( theGraphics , this );
			theGraphics.popMatrix( );
		}
	}

	public Label hide( ) {
		return setVisible( false );
	}

	public Label show( ) {
		return setVisible( true );
	}

	public Label setVisible( boolean theValue ) {
		isVisible = theValue;
		return this;
	}

	public Label updateFont( ControlFont theFont ) {
		return setFont( theFont );
	}

	public Label set( String theValue ) {
		return setText( theValue );
	}

	public Label setText( String theValue ) {
		_myText = theValue;
		setChanged( true );
		return this;
	}

	public Label setFixedSize( boolean theValue ) {
		isFixedSize = theValue;
		return this;
	}

	public boolean isFixedSize( ) {
		return isMultiline ? false : isFixedSize;
	}

	public String getText( ) {
		return _myText;
	}

	public String getTextFormatted( ) {
		return getLabeltype( ).getTextFormatted( );
	}

	public ControllerStyle getStyle( ) {
		return _myControllerStyle;
	}

	public Label setWidth( int theWidth ) {
		_myWidth = theWidth;
		setChanged( true );
		return this;
	}

	public Label setHeight( int theHeight ) {
		_myHeight = theHeight;
		setChanged( true );
		return this;
	}

	public int getWidth( ) {
		return _myLabeltype.getWidth( );
	}

	public int getHeight( ) {
		return _myLabeltype.getHeight( );
	}

	public int getOverflow( ) {
		return getLabeltype( ).getOverflow( );
	}

	public Label setMultiline( boolean theValue ) {
		isMultiline = theValue;
		_myLabeltype = ( isMultiline ) ? new MultilineLabel( ) : new SinglelineLabel( );
		return this;
	}

	public Label toUpperCase( boolean theValue ) {
		isToUpperCase = theValue;
		setChanged( true );
		return this;
	}

	public ControlFont getFont( ) {
		return _myFontLabel;
	}

	public Label setFont( int theBitFontIndex ) {
		ControlP5.logger.warning( "BitFont is now of type PFont, use setFont(PFont) instead." );
		return this;
	}

	public Label setFont( PFont thePFont ) {
		return setFont( new ControlFont( thePFont ) );
	}

	public Label setFont( ControlFont theFont ) {
		setLineHeight( theFont.getSize( ) );
		_myFontLabel = new ControlFont( theFont.getFont( ) , theFont.getSize( ) );
		_myFontLabel.init( this );
		setChanged( true );
		return this;
	}

	public Label setSize( int theSize ) {
		_myFontLabel.setSize( theSize );
		return this;
	}

	protected boolean isChanged( ) {
		return changed;
	}

	protected Label setChanged( boolean theValue ) {
		changed = theValue;
		return this;
	}

	Label setTextHeight( int theHeight ) {
		_myTextHeight = theHeight;
		return this;
	}

	public int getTextHeight( ) {
		return _myFontLabel.getTextHeight( );
	}

	public int getLineHeight( ) {
		return _myLineHeight;
	}

	public Label setOffsetY( int theValue ) {
		return this;
	}

	public Label setOffsetYratio( float theValue ) {
		offsetYratio = theValue;
		setChanged( true );
		return this;
	}

	public float getOffsetYratio( ) {
		return offsetYratio;
	}

	public Label setLineHeight( int theValue ) {
		_myLineHeight = theValue;
		setChanged( true );
		return this;
	}

	public Label setColor( int theValue , boolean theFlag ) {
		setColor( theValue );
		setFixedSize( theFlag );
		return this;
	}

	public Label setColor( int theColor ) {
		_myColor = theColor;
		setChanged( true );
		return this;
	}

	public int getColor( ) {
		return _myColor;
	}

	public Label setColorBackground( int theColor ) {
		enableColorBackground( );
		_myColorBackground = theColor;
		return this;
	}

	public Label disableColorBackground( ) {
		isColorBackground = false;
		return this;
	}

	public Label enableColorBackground( ) {
		isColorBackground = true;
		return this;
	}

	public int getLetterSpacing( ) {
		return _myLetterSpacing;
	}

	public Label setLetterSpacing( int theValue ) {
		_myLetterSpacing = theValue;
		setChanged( true );
		return this;
	}

	public boolean isMultiline( ) {
		return isMultiline;
	}

	public boolean isVisible( ) {
		return isVisible;
	}

	public boolean isToUpperCase( ) {
		return isToUpperCase;
	}

	protected Label copy( ) {
		return new Label( this );
	}

	
	public static void setUpperCaseDefault( boolean theValue ) {
		isToUpperCaseDefault = theValue;
	}

	interface Labeltype {

		public void draw( Label theLabel , PGraphics theGraphics , int theX , int theY , ControllerInterface< ? > theController );

		public void draw( Label theLabel , PGraphics theGraphics , int theX , int theY , int theW , int theH );

		public int getWidth( );

		public int getHeight( );

		public int getOverflow( );

		public String getTextFormatted( );
	}

	class SinglelineTextfield extends SinglelineLabel {

		public String getTextFormatted( ) {
			return _myText;
		}
	}

	class SinglelineLabel implements Labeltype {

		private void align( PGraphics theGraphics , int theAlignX , int theAlignY , int theW , int theH ) {
			int x = 0;
			int y = 0;
			switch ( theAlignX ) {
			case ( ControlP5.CENTER ):
				x = ( theW - _myFontLabel.getWidth( ) ) / 2;
				break;
			case ( ControlP5.LEFT ):
				x = _myPaddingX;
				break;
			case ( ControlP5.RIGHT ):
				x = theW - _myFontLabel.getWidth( ) - _myPaddingX;
				break;
			case ( ControlP5.LEFT_OUTSIDE ):
				x = -_myFontLabel.getWidth( ) - _myPaddingX;
				break;
			case ( ControlP5.RIGHT_OUTSIDE ):
				x = theW + _myPaddingX;
				break;
			}
			switch ( theAlignY ) {
			case ( ControlP5.CENTER ):
				y = theH / 2 + _myFontLabel.getTop( ) - _myFontLabel.getCenter( );
				break;
			case ( ControlP5.TOP ):
				y = 0;
				break;
			case ( ControlP5.BOTTOM ):
				y = theH - _myFontLabel.getHeight( ) - 1;
				break;
			case ( ControlP5.BASELINE ):
				y = theH + _myFontLabel.getTop( ) - 1;
				break;
			case ( ControlP5.BOTTOM_OUTSIDE ):
				y = theH + _myPaddingY;
				break;
			case ( ControlP5.TOP_OUTSIDE ):
				y = -_myFontLabel.getHeight( ) - _myPaddingY;
				break;
			}
			theGraphics.translate( x , y );
		}

		@Override public void draw( Label theLabel , PGraphics theGraphics , int theX , int theY , int theW , int theH ) {
			_myFontLabel.adjust( theGraphics , theLabel );
			theGraphics.pushMatrix( );
			align( theGraphics , alignX , alignY , theW , theH );
			theLabel.draw( theGraphics , theX , theY );
			theGraphics.popMatrix( );
		}

		@Override public void draw( Label theLabel , PGraphics theGraphics , int theX , int theY , ControllerInterface< ? > theController ) {
			draw( theLabel , theGraphics , theX , theY , theController.getWidth( ) , theController.getHeight( ) );
		}

		@Override public int getWidth( ) {
			return isFixedSize ? _myWidth : _myFontLabel.getWidth( );
		}

		@Override public int getHeight( ) {
			return _myFontLabel.getHeight( );
		}

		@Override public int getOverflow( ) {
			return -1;
		}

		@Override public String getTextFormatted( ) {
			return ( isToUpperCase ? _myText.toUpperCase( ) : _myText );
		}
	}

	class MultilineLabel implements Labeltype {

		@Override public void draw( Label theLabel , PGraphics theGraphics , int theX , int theY , int theW , int theH ) {
			_myFontLabel.adjust( theGraphics , theLabel );
			theLabel.draw( theGraphics , theX , theY );
		}

		@Override public void draw( Label theLabel , PGraphics theGraphics , int theX , int theY , ControllerInterface< ? > theController ) {
			_myFontLabel.adjust( theGraphics , theLabel );
			theLabel.draw( theGraphics , theX , theY );
		}

		@Override public int getWidth( ) {
			return _myWidth;
		}

		@Override public int getHeight( ) {
			return _myHeight;
		}

		@Override public int getOverflow( ) {
			return _myFontLabel.getOverflow( );
		}

		@Override public String getTextFormatted( ) {
			return ( isToUpperCase ? _myText.toUpperCase( ) : _myText );
		}

	}

}
