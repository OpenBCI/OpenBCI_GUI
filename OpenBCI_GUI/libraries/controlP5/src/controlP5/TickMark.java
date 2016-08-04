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
import processing.core.PGraphics;

/**
 * Tickmarks are used by the Slider and Knob controller.
 */
public class TickMark implements CDrawable {

	protected Controller< ? > _myParent;

	protected int _myLen = 4;

	protected Label _myLabel;

	protected boolean isLabel;

	public TickMark( Controller< ? > theController ) {
		_myParent = theController;
	}

	public void draw( PGraphics theGraphics ) {
		draw( theGraphics , ControlP5Constants.HORIZONTAL );
	}

	public void draw( PGraphics theGraphics , int theDirection ) {
		theGraphics.pushMatrix( );
		switch ( theDirection ) {
		case ( ControlP5Constants.HORIZONTAL ):
			theGraphics.translate( 0 , _myLen );
			theGraphics.rect( 0 , 0 , 1 , _myLen );
			if ( isLabel ) {
				_myLabel.draw( theGraphics , 0 , _myLen + 4 , _myParent );
			}
			break;
		case ( ControlP5Constants.VERTICAL ):
			theGraphics.translate( -_myLen , 0 );
			theGraphics.rect( 0 , 0 , _myLen , 1 );
			if ( isLabel ) {
				_myLabel.draw( theGraphics , -_myLabel.getWidth( ) , 0 , _myParent );
			}
			break;
		}

		theGraphics.popMatrix( );
	}

	public void setLength( int theLength ) {
		_myLen = theLength;
	}

	public Label setLabel( String theLabeltext ) {
		if ( _myLabel == null ) {
			_myLabel = new Label( _myParent.cp5 , theLabeltext );
			isLabel = true;
		} else {
			_myLabel.set( theLabeltext );
		}
		return _myLabel;
	}

	public Label getLabel( ) {
		if ( _myLabel == null ) {
			setLabel( "?" );
		}
		return _myLabel;
	}

}
