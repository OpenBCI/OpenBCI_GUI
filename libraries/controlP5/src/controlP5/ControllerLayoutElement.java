package controlP5;

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