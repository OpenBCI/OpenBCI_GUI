package controlP5;

/**
 * controlP5 is a processing gui library.
 *
 *  2006-2015 by Andreas Schlegel
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
 * @author 		Andreas Schlegel (http://www.sojamo.de)
 * @modified	04/14/2016
 * @version		2.2.6
 *
 */

/**
 * <p>
 * Use a CallbackListener to listen for controller related actions such as pressed, released, etc.
 * Callbacks cn be added via the ControlP5.addCallback() methods.
 * </p>
 * 
 * @example use/ControlP5callback
 * @see controlP5.ControlP5#addCallback(CallbackListener)
 */
public interface CallbackListener {

	public void controlEvent( CallbackEvent theEvent );

}
