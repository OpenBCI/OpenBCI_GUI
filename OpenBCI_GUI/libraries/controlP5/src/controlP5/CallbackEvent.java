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

/**
 * <p>
 * A CallbackEvent is send when a controller action such as enter, leave, press, etc has occurs.
 * 
 * @example use/ControlP5callback
 */
public class CallbackEvent {

	private final int _myAction;

	private final Controller< ? > _myController;

	CallbackEvent( Controller< ? > theController , int theAction ) {
		_myController = theController;
		_myAction = theAction;
	}

	/**
	 * 
	 * @return int Returns an int value of either one of the following static variables
	 *         ControlP5.ACTION_PRESS, ControlP5.ACTION_ENTER, ControlP5.ACTION_LEAVE,
	 *         ControlP5.ACTION_RELEASE, ControlP5.ACTION_RELEASEDOUTSIDE,
	 *         ControlP5.ACTION_BROADCAST
	 */
	public int getAction( ) {
		return _myAction;
	}

	/**
	 * Returns the Controller that triggered the Callback Event.
	 * 
	 * @return Controller
	 */
	public Controller< ? > getController( ) {
		return _myController;
	}

}
