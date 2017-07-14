package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version. This library is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 04/14/2016
 * @version 2.2.6
 * 
 */

import java.io.Serializable;

/**
 * A CColor instance contains the colors of a controller including the foreground-, background-,
 * active-, captionlabel- and valuelabel-colors.
 */

@SuppressWarnings( "serial" )
public class CColor implements Serializable {

	private int colorBackground = 0xff003652;
	private int colorForeground = 0xff00698c;
	private int colorActive = 0xff08a2cf; // 0699C4;
	private int colorCaptionLabel = 0xffffffff;
	private int colorValueLabel = 0xffffffff;
	private int colorBackgroundAlpha = 0xff;
	private int colorForegroundAlpha = 0xff;
	private int colorActiveAlpha = 0xff; // 0699C4;
	private int colorCaptionLabelAlpha = 0xff;
	private int colorValueLabelAlpha = 0xff;

	private int alpha = 0xff;
	private int maskA = 0x00ffffff;
	int maskR = 0xff00ffff;
	int maskG = 0xffff00ff;
	int maskB = 0xffffff00;

	protected CColor set( CColor theColor ) {
		colorBackground = theColor.colorBackground;
		colorForeground = theColor.colorForeground;
		colorActive = theColor.colorActive;
		colorCaptionLabel = theColor.colorCaptionLabel;
		colorValueLabel = theColor.colorValueLabel;
		colorBackgroundAlpha = theColor.colorBackgroundAlpha;
		colorForegroundAlpha = theColor.colorForegroundAlpha;
		colorActiveAlpha = theColor.colorActiveAlpha;
		colorCaptionLabelAlpha = theColor.colorCaptionLabelAlpha;
		colorValueLabelAlpha = theColor.colorValueLabelAlpha;
		return this;
	}

	protected CColor copyTo( ControllerInterface< ? > theControl ) {
		theControl.setColorBackground( colorBackground );
		theControl.setColorForeground( colorForeground );
		theControl.setColorActive( colorActive );
		theControl.setColorLabel( colorCaptionLabel );
		return this;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	public String toString( ) {

		return ( "bg (" + ( colorBackground >> 16 & 0xff ) + "," + ( colorBackground >> 8 & 0xff ) + "," + ( colorBackground >> 0 & 0xff ) + "), " + "fg (" + ( colorForeground >> 16 & 0xff ) + "," + ( colorForeground >> 8 & 0xff ) + ","
				+ ( colorForeground >> 0 & 0xff ) + "), " + "active (" + ( colorActive >> 16 & 0xff ) + "," + ( colorActive >> 8 & 0xff ) + "," + ( colorActive >> 0 & 0xff ) + "), " + "captionlabel (" + ( colorCaptionLabel >> 16 & 0xff ) + ","
				+ ( colorCaptionLabel >> 8 & 0xff ) + "," + ( colorCaptionLabel >> 0 & 0xff ) + "), " + "valuelabel (" + ( colorValueLabel >> 16 & 0xff ) + "," + ( colorValueLabel >> 8 & 0xff ) + "," + ( colorValueLabel >> 0 & 0xff ) + ")" );
	}

	public CColor( ) {
		set( ControlP5.getColor( ) );
	}

	public CColor( int cfg , int cbg , int cactive , int ccl , int cvl ) {
		setForeground( cfg );
		setBackground( cbg );
		setActive( cactive );
		setCaptionLabel( ccl );
		setValueLabel( cvl );
	}

	public CColor( CColor theColor ) {
		set( theColor );
	}

	/**
	 * @exclude
	 * @param theAlpha
	 */
	public CColor setAlpha( int theAlpha ) {
		System.out.println( "controlP5.CColor.setAlpha: setting alpha values disabled for this version of controlP5." );
		return this;
	}

	public CColor setForeground( int theColor ) {
		if ( ( theColor & 0xff000000 ) == 0 ) {
			colorForeground = 0xff000000;
		} else {
			colorForeground = theColor;
		}
		return this;
	}

	public CColor setBackground( int theColor ) {
		if ( ( theColor & 0xff000000 ) == 0 ) {
			colorBackground = 0xff000000;
		} else {
			colorBackground = theColor;
		}
		return this;
	}

	public CColor setActive( int theColor ) {
		if ( ( theColor & 0xff000000 ) == 0 ) {
			colorActive = 0xff000000;
		} else {
			colorActive = theColor;
		}
		return this;
	}

	public CColor setCaptionLabel( int theColor ) {
		if ( ( theColor & 0xff000000 ) == 0 ) {
			colorCaptionLabel = 0xff000000;
		} else {
			colorCaptionLabel = theColor;
		}
		return this;
	}

	public CColor setValueLabel( int theColor ) {
		if ( ( theColor & 0xff000000 ) == 0 ) {
			colorValueLabel = 0xff000000;
		} else {
			colorValueLabel = theColor;
		}
		return this;
	}

	public int getAlpha( ) {
		return alpha;
	}

	public int getForeground( ) {
		return colorForeground;
	}

	public int getBackground( ) {
		return colorBackground;
	}

	public int getActive( ) {
		return colorActive;
	}

	public int getCaptionLabel( ) {
		return colorCaptionLabel;
	}

	public int getValueLabel( ) {
		return colorValueLabel;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	public int hashCode( ) {
		int result = 23;
		result = 37 * result + colorBackground;
		result = 37 * result + colorForeground;
		result = 37 * result + colorActive;
		return result;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	public boolean equals( Object o ) {
		if ( this == o ) {
			return true;
		}
		if ( o == null || getClass( ) != o.getClass( ) ) {
			return false;
		}
		CColor cc = ( CColor ) o;
		if ( colorBackground != cc.colorBackground || colorForeground != cc.colorForeground || colorActive != cc.colorActive || colorCaptionLabel != cc.colorCaptionLabel || colorValueLabel != cc.colorValueLabel ) {
			return false;
		}
		return true;
	}
}
