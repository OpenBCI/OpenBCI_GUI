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

import java.util.ArrayList;

/**
 * OscIn is deprecated. for compatibility with previous versions of oscP5 OscIn
 * is still available.
 * 
 * @invisible
 */
@Deprecated
public class OscIn extends OscMessage {

	public OscIn(OscMessage theOscMessage) {
		super(theOscMessage);
	}

	public int getInt(int thePos) {
		return get(thePos).intValue();
	}

	public char getChar(int thePos) {
		return get(thePos).charValue();
	}

	public float getFloat(int thePos) {
		return get(thePos).floatValue();
	}

	public String getString(int thePos) {
		return get(thePos).stringValue();
	}

	public byte[] getBlob(int thePos) {
		return get(thePos).bytesValue();
	}

	public int[] getMidiBytes(int thePos) {
		return get(thePos).midiValue();
	}

	public int[] getMidi(int thePos) {
		return get(thePos).midiValue();
	}

	public boolean getBoolean(int thePos) {
		return get(thePos).booleanValue();
	}

	/**
	 * this is only for christian's and jens' table communication with vvvv.
	 * 
	 * @return ArrayList
	 */
	public ArrayList getDataList() {
		ArrayList myList = new ArrayList();
		Object[] myArguments = arguments();
		for (int i = 0; i < myArguments.length; i++) {
			myList.add(myArguments[i]);
		}
		return myList;
	}

}
