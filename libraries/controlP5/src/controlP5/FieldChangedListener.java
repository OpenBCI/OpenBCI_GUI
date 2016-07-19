package controlP5;

import java.lang.reflect.Field;

/**
 * the FieldChangedListener is used to observe changes of variables that are
 * linked to a controller. The FieldChangedListener is for primarily for
 * internal use.
 * 
 * @see controlP5.Controller#listen(boolean)
 */
class FieldChangedListener {

	private FieldValue value;

	private ControlP5 controlP5;

	public FieldChangedListener(ControlP5 theControlP5) {
		controlP5 = theControlP5;
	}

	/**
	 * Assigns a listener to a specific field of an object.
	 * 
	 * this can be done in a more elegant way using generics.
	 * 
	 * @param theObject
	 * @param theFieldName
	 */
	public void listenTo(final Object theObject, final String theFieldName) {
		try {
			Class<?> c = theObject.getClass();
			final Field field = c.getDeclaredField(theFieldName);
			field.setAccessible(true);
			if (field.getType().isAssignableFrom(Float.TYPE)) {
				value = new FieldValue() {
					float then;

					public void check() {
						try {
							float now = (Float) field.get(theObject);
							if (now != then) {
								controlP5.getController(theFieldName, theObject).setValue(now);
								then = now;
							}
						} catch (IllegalAccessException e) {
						}
					}
				};
			} else if (field.getType().isAssignableFrom(Integer.TYPE)) {
				value = new FieldValue() {
					int then;

					public void check() {
						try {
							int now = (Integer) field.get(theObject);
							if (now != then) {
								controlP5.getController(theFieldName, theObject).setValue(now);
								then = now;
							}
						} catch (IllegalAccessException e) {
						}
					}
				};
			} else if (field.getType().isAssignableFrom(Boolean.TYPE)) {
				value = new FieldValue() {
					boolean then;

					public void check() {
						try {
							boolean now = (Boolean) field.get(theObject);
							if (now != then) {
								controlP5.getController(theFieldName, theObject).setValue(now == true ? 1 : 0);
								then = now;
							}
						} catch (IllegalAccessException e) {
						}
					}
				};
			} else if (field.getType().isAssignableFrom(String.class)) {

				value = new FieldValue() {
					String then;

					public void check() {
						try {
							String now = (String) field.get(theObject);
							if (!now.equals(then)) {
								controlP5.getController(theFieldName, theObject).setStringValue(now);
								then = now;
							}
						} catch (IllegalAccessException e) {
						}
					}
				};
			}
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	void update() {
		value.check();
	}
}

interface FieldValue {
	public void check();
}
