/**
 * An OSC (Open Sound Control) library for processing.
 *
 * (c) 2004-2012
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author		Andreas Schlegel http://www.sojamo.de
 * @modified	12/23/2012
 * @version		0.9.9
 */

package oscP5;

import java.lang.reflect.Method;
import netP5.Logger;

/**
 * 
 * @invisible
 */
public class OscPlug {

	private boolean _isValid = true;

	private String _myTypetag = "";

	private String _myAddrPattern = "";

	private String _myPattern = "";

	private String _myMethodName;

	private Object _myObject;
	
	public Method method = null;

	private int _myChecker = 0;

	protected boolean isArray = false;

	private static final  int CHECK_ADDRPATTERN_TYPETAG = 0;

	private static final int CHECK_ADDRPATTERN = 1;

	private static final int CHECK_TYPETAG = 2;

	public void plug(final Object theObject, final String theMethodName,
			final String theAddrPattern) {
		_myObject = theObject;
		_myMethodName = theMethodName;
		_myAddrPattern = theAddrPattern;
		_myChecker = CHECK_ADDRPATTERN_TYPETAG;
		if (_myMethodName != null && _myMethodName.length() > 0) {
			Class<?> myClass = theObject.getClass();
			Class<?>[] myParams = null;
			Method[] myMethods = myClass.getMethods();
			_myTypetag = "";
			for (int i = 0; i < myMethods.length; i++) {
				if ((myMethods[i].getName()).equals(_myMethodName)) {
					myParams = myMethods[i].getParameterTypes();
					for (int j = 0; j < myParams.length; j++) {
						_myTypetag += checkType(myParams[j].getName());
					}
					break;
				}
			}
			if (myParams != null) {
				makeMethod(theObject.getClass(), myParams);
			} else {
				Logger.printWarning("OscPlug.plug()",
						"no arguments found for method " + _myMethodName);
			}
		}
	}

	public void plug(final Object theObject, final String theMethodName,
			final String theAddrPattern, final String theTypetag) {
		_myObject = theObject;
		_myMethodName = theMethodName;
		_myAddrPattern = theAddrPattern;
		_myTypetag = theTypetag;
		_myChecker = CHECK_ADDRPATTERN_TYPETAG;

		if (_myMethodName != null && _myMethodName.length() > 0) {
			int tLen = _myTypetag.length();
			Class<?>[] myParams;
			if (tLen > 0) {
				myParams = getArgs(_myTypetag);
			} else {
				myParams = null;
			}

			if (_isValid) {
				makeMethod(theObject.getClass(), myParams);
			}
		}
	}

	public Object getObject() {
		return _myObject;
	}

	private void makeMethod(final Class<?> theObjectsClass, final Class<?>[] theClass) {
		try {
			method = theObjectsClass.getDeclaredMethod(_myMethodName, theClass);
			_myPattern = _myAddrPattern + _myTypetag;
			method.setAccessible(true);
			Logger.printProcess("OscPlug", "plugging " + theObjectsClass
					+ " | " + "addrPattern:" + _myAddrPattern + " typetag:"
					+ _myTypetag + " method:" + _myMethodName);

		} catch (Exception e) {
			final Class<?> theObjecsSuperClass = theObjectsClass.getSuperclass();
			if (theObjecsSuperClass.equals(Object.class)) {
				if (theObjectsClass.getName().equals("java.awt.Component") == false) { // applet fix.
					Logger.printError("OscPlug", "method "
							+ theObjectsClass.getName()
							+ " does not exist in your code.");
				}
			} else {
				makeMethod(theObjecsSuperClass, theClass);
			}
		}
		return;
	}

	public boolean checkMethod(final OscMessage theOscMessage,
			final boolean isArray) {
		String myTypetag;
		/*
		 * if theFlag is true and the arguments of theOscmessage can be
		 * represented as an array of the same type, then only fetch the first
		 * character of the typetag, otherwise use the full typetag.
		 */
		if (isArray) {
			myTypetag = "" + theOscMessage.typetag().charAt(0);
		} else {
			myTypetag = theOscMessage.typetag();
		}
		switch (_myChecker) {
		case (CHECK_ADDRPATTERN_TYPETAG):
			String thePattern = theOscMessage.addrPattern() + myTypetag;
			return thePattern.equals(_myPattern);
		case (CHECK_ADDRPATTERN):
			return (theOscMessage.addrPattern().equals(_myAddrPattern));
		case (CHECK_TYPETAG):
			return (myTypetag.equals(_myTypetag));
		default:
			return false;
		}
	}

	public Method getMethod() {
		return method;
	}
	
	
	public String checkType(final String theName) {
		if (theName.equals("int")) {
			return "i";
		} else if (theName.equals("float")) {
			return "f";
		} else if (theName.equals("java.lang.String")) {
			return "s";
		} else if (theName.equals("[Ljava.lang.String;")) {
			isArray = true;
			return "s";
		}

		else if (theName.equals("char")) {
			return "c";
		} else if (theName.equals("[B")) {
			return "b";
		} else if (theName.equals("[F")) {
			isArray = true;
			return "f";
		} else if (theName.equals("[I")) {
			isArray = true;
			return "i";
		}

		else if (theName.equals("double")) {
			return "d";
		} else if (theName.equals("boolean")) {
			return "T";
		} else if (theName.equals("long")) {
			return "h";
		}
		return "";
	}

	private Class<?>[] getArgs(final String theArgs) {
		char[] tChar = theArgs.toCharArray();
		int tLen = theArgs.length();
		Class<?>[] tClass = new Class[tLen];
		for (int i = 0; i < tLen; i++) {
			switch (tChar[i]) {
			case ('i'):
				tClass[i] = (isArray == true) ? int[].class : int.class;
				break;
			case ('S'):
			case ('s'):
				tClass[i] = (isArray == true) ? String[].class : String.class;
				break;
			case ('f'):
				tClass[i] = (isArray == true) ? float[].class : float.class;
				break;
			case ('d'):
				tClass[i] = double.class;
				break;
			case ('c'):
				tClass[i] = char.class;
				break;
			case ('h'):
			case ('l'):
				tClass[i] = long.class;
				break;
			case ('T'):
				tClass[i] = boolean.class;
				break;
			case ('F'):
				tClass[i] = boolean.class;
				break;
			case ('b'):
				tClass[i] = byte[].class;
				break;
			case ('o'):
				_myChecker = CHECK_ADDRPATTERN;
				tClass = new Class[] { Object[].class };
				break;

			default:
				_isValid = false;
				break;
			}
		}
		if (!_isValid) {
			tClass = null;
			System.out.println("ERROR could't plug method " + _myMethodName);
		}
		return tClass;
	}

}
