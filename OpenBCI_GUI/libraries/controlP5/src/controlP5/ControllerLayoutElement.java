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
import java.util.HashMap;
import java.util.Map;

class ControllerLayoutElement implements Serializable, Cloneable {
	
	private static final long serialVersionUID = -5006855922546529005L;

	private transient ControllerInterface<?> controller;

	private Class<?> type;

	private Map<String,Object> values;
	
	ControllerLayoutElement(ControllerInterface<?> theController) {
		controller = theController;
		type = theController.getClass();
		values = new HashMap<String,Object>();
	}
	
	private void cascade(Object theObject) {
		
	}

}