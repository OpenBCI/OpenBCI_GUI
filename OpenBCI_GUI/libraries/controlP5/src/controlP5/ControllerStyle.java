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

import java.io.Serializable;


/**
 * Labels use the ControllerStyle class to store margin and padding information.
 * 
 * @see controlP5.Label#getStyle()
 * 
 * @example extra/ControlP5style
 */
public class ControllerStyle implements Serializable {

	private static final long serialVersionUID = 3250201688970310633L;

	public int paddingTop = 0;
	public int paddingRight = 0;
	public int paddingBottom = 0;
	public int paddingLeft = 0;
	public int marginTop = 0;
	public int marginRight = 0;
	public int marginBottom = 0;
	public int marginLeft = 0;
	public int background;
	public int backgroundWidth = -1;
	public int backgroundHeight = -1;
	public int color;

	public ControllerStyle margin( int theValue ) {
		marginTop = theValue;
		marginRight = theValue;
		marginBottom = theValue;
		marginLeft = theValue;
		return this;
	}

	public ControllerStyle padding( int theValue ) {
		paddingTop = theValue;
		paddingRight = theValue;
		paddingBottom = theValue;
		paddingLeft = theValue;
		return this;
	}

	public ControllerStyle setPadding( int theTop , int theRight , int theBottom , int theLeft ) {
		padding( theTop , theRight , theBottom , theLeft );
		return this;
	}

	public ControllerStyle setPaddingTop( int theValue ) {
		paddingTop = theValue;
		return this;
	}

	public ControllerStyle setPaddingBottom( int theValue ) {
		paddingBottom = theValue;
		return this;
	}

	public ControllerStyle setPaddingRight( int theValue ) {
		paddingRight = theValue;
		return this;
	}

	public ControllerStyle setPaddingLeft( int theValue ) {
		paddingLeft = theValue;
		return this;
	}

	public ControllerStyle margin( int theTop , int theRight , int theBottom , int theLeft ) {
		marginTop = theTop;
		marginRight = theRight;
		marginBottom = theBottom;
		marginLeft = theLeft;
		return this;
	}

	public ControllerStyle setMargin( int theTop , int theRight , int theBottom , int theLeft ) {
		margin( theTop , theRight , theBottom , theLeft );
		return this;
	}

	public ControllerStyle setMarginTop( int theValue ) {
		marginTop = theValue;
		return this;
	}

	public ControllerStyle setMarginBottom( int theValue ) {
		marginBottom = theValue;
		return this;
	}

	public ControllerStyle setMarginRight( int theValue ) {
		marginRight = theValue;
		return this;
	}

	public ControllerStyle setMarginLeft( int theValue ) {
		marginLeft = theValue;
		return this;
	}

	public ControllerStyle padding( int theTop , int theRight , int theBottom , int theLeft ) {
		paddingTop = theTop;
		paddingRight = theRight;
		paddingBottom = theBottom;
		paddingLeft = theLeft;
		return this;
	}

	public ControllerStyle moveMargin( int theTop , int theRight , int theBottom , int theLeft ) {
		marginTop += theTop;
		marginRight += theRight;
		marginBottom += theBottom;
		marginLeft += theLeft;
		return this;
	}

	public ControllerStyle movePadding( int theTop , int theRight , int theBottom , int theLeft ) {
		paddingTop += theTop;
		paddingRight += theRight;
		paddingBottom += theBottom;
		paddingLeft += theLeft;
		return this;
	}

}
