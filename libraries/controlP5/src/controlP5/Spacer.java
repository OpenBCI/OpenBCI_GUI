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

public class Spacer extends Controller< Spacer > {

	private int _myWeight = 1;

	public Spacer( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 20 , 20 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected Spacer( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theX , float theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myControllerView = new SpacerView( );
	}

	public Spacer setWeight( int theWeight ) {
		_myWeight = theWeight;
		return this;
	}

	public Spacer setColor( int theColor ) {
		getColor( ).setForeground( theColor );
		return this;
	}

	private class SpacerView implements ControllerView< Spacer > {

		public void display( PGraphics g , Spacer c ) {
			g.fill( c.getColor( ).getForeground( ) );
			g.noStroke( );
			if ( c.getWidth( ) >= c.getHeight( ) ) {
				g.rect( 0 , ( c.getHeight( ) / 2 ) - _myWeight / 2 , c.getWidth( ) , _myWeight );
			} else {
				g.rect( ( c.getWidth( ) / 2 ) - _myWeight / 2 , 0 , _myWeight , c.getHeight( ) );
			}
		}
	}

}
