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
public class Group extends ControlGroup< Group > {

	/**
	 * Convenience constructor to extend Group.
	 * 
	 * @example use/ControlP5extendController
	 */
	public Group( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 99 , 9 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	public Group( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , int theX , int theY , int theW , int theH ) {
		super( theControlP5 , theParent , theName , theX , theY , theW , theH );
	}

}
