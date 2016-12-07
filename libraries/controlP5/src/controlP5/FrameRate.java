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

public class FrameRate extends Textlabel {

	private int _myInterval = 10;

	private float _myIntervalSum = 0;

	private int cnt = 0;

	protected FrameRate( final ControlP5 theControlP5 , final Tab theParent , final String theValue , final int theX , final int theY ) {
		super( theControlP5 , theParent , "framerate" , "-" , theX , theY );
	}

	public FrameRate setInterval( int theValue ) {
		_myInterval = theValue;
		return this;
	}

	@Override
	public void draw( PGraphics theGraphics ) {
		if ( ( cnt++ ) % _myInterval == 0 ) {
			setText( "" + PApplet.round( _myIntervalSum / _myInterval ) );
			_myIntervalSum = 0;
		}
		_myIntervalSum += cp5.papplet.frameRate;
		super.draw( theGraphics );
	}

}
