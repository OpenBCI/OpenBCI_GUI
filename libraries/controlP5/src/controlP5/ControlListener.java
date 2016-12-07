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
 * ControlListener is an interface that can be implemented by a custom class to be notified when
 * controller values change. To add a ControlListener to a controller use Controller.addListner()
 * 
 * @see controlP5.Controller#addListener(ControlListener)
 * @see controlP5.CallbackListener
 * 
 * @example use/ControlP5listenerForSingleController
 */
public interface ControlListener {

	/**
	 * controlEvent is called by controlP5's ControlBroadcaster to inform available listeners about
	 * value changes. Use the CallbackListener to get informed when actions such as pressed,
	 * release, drag, etc are performed.
	 * 
	 * @see controlP5.CallbackListener
	 * @see controlP5.CallbackEvent
	 * @param theEvent
	 *            ControlEvent
	 * @example ControlP5listener
	 */
	public void controlEvent( ControlEvent theEvent );

}
