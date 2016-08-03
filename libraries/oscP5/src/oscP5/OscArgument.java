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

/**
 * an osc argument contains one value of values from a received osc message.
 * you can convert the value into the required format, e.g. from Object to int
 * theOscMessage.get(0).intValue();
 * @related OscMessage
 * @example oscP5oscArgument
 */
public class OscArgument {
	protected Object value;

    /**
     * @invisible
     */
    public OscArgument() {}

	/**
         * get the int value of the osc argument.
	 * @return int
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public int intValue() {
		return ((Integer) value).intValue();
	}

	/**
	 * get the char value of the osc argument.
	 * @return char
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public char charValue() {
		return ((Character) value).charValue();
	}

	/**
	 * get the float value of the osc argument.
	 * @return float
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public float floatValue() {
		return ((Float) value).floatValue();
	}

	/**
	 * get the double value of the osc argument.
	 * @return double
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public double doubleValue() {
		return ((Double) value).doubleValue();
	}

	/**
	 * get the long value of the osc argument.
	 * @return long
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public long longValue() {
		return ((Long) value).longValue();
	}

	/**
	 * get the boolean value of the osc argument.
	 * @return boolean
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public boolean booleanValue() {
		return ((Boolean) value).booleanValue();
	}

        /**
         * get the String value of the osc argument.
         * @return String
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
         */
        public String stringValue() {
         return ((String) value);
        }


	/**
	 *
	 * @return String
	 */
	public String toString() {
		return ((String) value);
	}

	/**
	 * get the byte array of the osc argument.
	 * @return byte[]
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
	 */
	public byte[] bytesValue() {
		return ((byte[]) value);
	}

        /**
         * get the byte array (blob) of the osc argument.
         * @return byte[]
         * @related intValue ( )
         * @related floatValue ( )
         * @related charValue ( )
         * @related stringValue ( )
         * @related doubleValue ( )
         * @related longValue ( )
         * @related booleanValue ( )
         * @related bytesValue ( )
         * @related blobValue ( )
         * @example oscP5parsing
         */
        public byte[] blobValue() {
                return ((byte[]) value);
        }


	/**
	 *
	 * @return int[]
	 */
	public int[] midiValue() {
		int[] myInt = new int[4];
		byte[] myByte = (byte[]) value;
		for (int i = 0; i < 4; i++) {
			myInt[i] = (int) (myByte[i]);
		}
		return (myInt);
	}
}
