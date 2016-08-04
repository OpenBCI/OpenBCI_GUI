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

import java.util.List;
import java.util.Vector;

/**
 * Stores objects of type ControllerInterface and CDrawable, mainly for internal use.
 */
public class ControllerList {

	protected List< ControllerInterface< ? >> controllers;

	protected List< CDrawable > drawables;

	public ControllerList( ) {
		controllers = new Vector< ControllerInterface< ? >>( );
		drawables = new Vector< CDrawable >( );
	}

	public void add( ControllerInterface< ? > theController ) {
		if ( controllers.indexOf( theController ) < 0 ) {
			controllers.add( theController );
		}
	}

	protected void remove( ControllerInterface< ? > theController ) {
		controllers.remove( theController );
	}

	protected void addDrawable( CDrawable theController ) {
		if ( drawables.indexOf( theController ) < 0 ) {
			drawables.add( theController );
		}
	}

	protected void removeDrawable( CDrawable theController ) {
		drawables.remove( theController );
	}

	public ControllerInterface< ? > get( int theIndex ) {
		return controllers.get( theIndex );
	}

	public List< ControllerInterface< ? >> get( ) {
		return controllers;
	}

	public CDrawable getDrawable( int theIndex ) {
		return drawables.get( theIndex );
	}

	public List< CDrawable > getDrawables( ) {
		return drawables;
	}

	public int sizeDrawable( ) {
		return drawables.size( );
	}

	public int size( ) {
		return controllers.size( );
	}

	protected void clear( ) {
		controllers.clear( );
	}

	protected void clearDrawable( ) {
		drawables.clear( );
	}

}
