/**
 * A network library for processing which supports UDP, TCP and Multicast.
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

package netP5;

import java.util.Calendar;

public class Logger {
	
	/**
	 * 
	 */
	public static final int ON = 0;
	
	/**
	 * 
	 */
	public static final int OFF = 1;
	
	/**
	 * 
	 */
	public static final int ERROR = 0;
	
	/**
	 * 
	 */
	public static final int WARNING = 1;
	
	/**
	 * 
	 */
	public static final int PROCESS = 2;
	
	/**
	 * 
	 */
	public static final int INFO = 3;
	
	/**
	 * 
	 */
	public static final int DEBUG = 4;
	
	/**
	 * 
	 */
	public static final int ALL = 5;
	
	
	
	public static int[] flags = new int[] { ON, ON, ON, ON, OFF };

        public static void set(int theIndex, int theValue) {
		if (theValue > -1 && theValue < 2) {
			if (theIndex > -1 && theIndex < flags.length) {
				flags[theIndex] = theValue;
				return;
			} else if (theIndex == ALL) {
				for (int i = 0; i < flags.length; i++) {
					flags[i] = theValue;
				}
				return;
			}
		}
	}

	public static void printError(String theLocation, String theMsg) {
		if (flags[ERROR] == ON) {
			println("### " + getTime() + " ERROR @ " + theLocation + " "
					+ theMsg);
		}
	}

	public static void printProcess(String theLocation, String theMsg) {
		if (flags[PROCESS] == ON) {
			println("### " + getTime() + " PROCESS @ " + theLocation + " "
					+ theMsg);
		}
	}

	public static void printWarning(String theLocation, String theMsg) {
		if (flags[WARNING] == ON) {
			println("### " + getTime() + " WARNING @ " + theLocation + " "
					+ theMsg);
		}
	}

	public static void printInfo(String theLocation, String theMsg) {
		if (flags[INFO] == ON) {
			println("### " + getTime() + " INFO @ " + theLocation + " "
					+ theMsg);
		}
	}
	
	public static void printDebug(String theLocation, String theMsg) {
		if (flags[DEBUG] == ON) {
			println("### " + getTime() + " DEBUG @ " + theLocation + " "
					+ theMsg);
		}
	}

	public static void print(String theMsg) {
		System.out.print(theMsg);
	}

	public static void println(String theMsg) {
		System.out.println(theMsg);
	}

	public static void printBytes(byte[] byteArray) {
		for (int i = 0; i < byteArray.length; i++) {
			print(byteArray[i] + " (" + (char) byteArray[i] + ")  ");
			if ((i + 1) % 4 == 0) {
				print("\n");
			}
		}
		print("\n");
	}

	public static String getTime() {
		Calendar cal = Calendar.getInstance();
		return "[" + (cal.get(Calendar.YEAR)) + "/"
				+ (cal.get(Calendar.MONTH) + 1) + "/"
				+ cal.get(Calendar.DAY_OF_MONTH) + " "
				+ cal.get(Calendar.HOUR_OF_DAY) + ":"
				+ cal.get(Calendar.MINUTE) + ":" + cal.get(Calendar.SECOND)
				+ "]";
	}

}
