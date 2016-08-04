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

/**
 * StringUtils Contains some basic utility methods for handling Strings.
 *
 * Copyright (C) 2003 Johan Känngård
 * Contains code Copyright (C) 2001,2002 Stephen Ostermiller
 * http://ostermiller.org/utils/StringHelper.java.html
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * The GPL is located at: http://www.gnu.org/licenses/gpl.txt
 *
 * @author Johan Känngård, http://dev.kanngard.net/
 * @version 0.4
 */

package netP5;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Enumeration;
import java.util.StringTokenizer;
import java.util.Vector;

/**
 * @invisible
 */
public class StringUtils extends Object {

	/**
	 * Protected because this class does only contain static methods.
	 */
	protected StringUtils() {
	}

	/**
	 * Returns the substring to the right of the specified substring in the
	 * specified String, starting from the left.
	 *
	 * @param source
	 *            the source String to search.
	 * @param searchFor
	 *            the substring to search for in source.
	 * @return the substring that is to the right of searchFor in source.
	 */
	public static String right(String source, String searchFor) {
		int index = source.indexOf(searchFor) + searchFor.length();

		if (index < 0) {
			return "";
		}
		return source.substring(index);
	}

	/**
	 * Returns the substring to the right of the specified substring in the
	 * specified String, starting from the right.
	 *
	 * @param source
	 *            the source String to search.
	 * @param searchFor
	 *            the substring to search for in source.
	 * @return the substring that is to the right of searchFor in source,
	 *         starting from the right.
	 */
	public static String rightBack(String source, String searchFor) {
		int index = source.lastIndexOf(searchFor) + searchFor.length();

		if (index < 0) {
			return "";
		}
		return source.substring(index);
	}

	/**
	 * Returns the substring to the left of the specified substring in the
	 * specified String, starting from the left.
	 *
	 * @param source
	 *            the source String to search.
	 * @param searchFor
	 *            the substring to search for in source.
	 * @return the substring that is to the left of searchFor in source.
	 */
	public static String left(String source, String searchFor) {
		int index = source.indexOf(searchFor);

		if (index <= 0) {
			return "";
		}
		return source.substring(0, index);
	}

	/**
	 * Returns the substring to the left of the specified substring in the
	 * specified String, starting from the right.
	 *
	 * @param source
	 *            the source String to search.
	 * @param searchFor
	 *            the substring to search for in source.
	 * @return the substring that is to the left of searchFor in source,
	 *         starting from the right.
	 */
	public static String leftBack(String source, String searchFor) {
		int index = source.lastIndexOf(searchFor);

		if (index <= 0) {
			return "";
		}
		return source.substring(0, index);
	}

	/**
	 * Returns the substring between two substrings. I.e.
	 * StringUtils.middle("This i a big challenge", "a", "challenge") returns "
	 * big ".
	 *
	 * @param source
	 *            the String to search.
	 * @param start
	 *            the String to the left to search for, from the left.
	 * @param end
	 *            the String to the right to search for, from the right.
	 */
	public static String middle(String source, String start, String end) {
		String one = StringUtils.right(source, start);
		return StringUtils.leftBack(one, end);
	}

	/**
	 * Returns a substring of a String, starting from specified index and with
	 * specified length. I. e. StringUtils.middle("This is a big challenge", 5,
	 * 6) returns " is a "
	 *
	 * @param source
	 *            the String to get a substring from.
	 * @param startIndex
	 *            the index in the source String to get the substring from.
	 * @param length
	 *            the length of the substring to return.
	 */
	public static String middle(String source, int startIndex, int length) {
		return source.substring(startIndex, source.length() - length);
	}

	/**
	 * Replaces substrings in a string.
	 *
	 * @param source
	 *            the source String to replace substrings in.
	 * @param searchFor
	 *            the string to search for.
	 * @param replaceWith
	 *            the string to replace all found searchFor-substrings with.
	 */
	public static String replace(String source, String searchFor,
			String replaceWith) {
		if (source.length() < 1) {
			return "";
		}
		int p = 0;

		while (p < source.length() && (p = source.indexOf(searchFor, p)) >= 0) {
			source = source.substring(0, p) + replaceWith
					+ source.substring(p + searchFor.length(), source.length());
			p += replaceWith.length();
		}
		return source;
	}

	/**
	 * Replaces several substrings in a string.
	 *
	 * @param source
	 *            the source String to replace substrings in.
	 * @param searchFor
	 *            the substrings to search for.
	 * @param replaceWith
	 *            what to replace every searchFor with,
	 */
	public static String replace(String source, String[] searchFor,
			String replaceWith) {
		for (int i = 0; i < searchFor.length; i++) {
			StringUtils.replace(source, searchFor[i], replaceWith);
		}
		return source;
	}

	/**
	 * Splits every String in an array at the specified lengths.
	 *
	 * Example: <code><pre>
	 * String source[] = { &quot;123a123b123c123d&quot;, &quot;Bla1bla2bla3bla4bla5bla6bla7&quot; };
	 * int[] lengths = { 3, 1, 3, 1 };
	 * Vector result = StringUtils.explode(source, lengths);
	 * Object element = null;
	 * String[] rowElements = null;
	 * Enumeration enum = result.elements();
	 * while (enum.hasMoreElements()) {
	 * 	element = enum.nextElement();
	 * 	if (element instanceof String[]) {
	 * 		rowElements = (String[]) element;
	 * 		for (int i = 0; i &lt; rowElements.length; i++) {
	 * 			System.out.println(rowElements[i]);
	 * 		}
	 * 	}
	 * }
	 * </pre></code> The result that will be output: 123 a 123 b
	 *
	 * Bla 1 bla 2
	 *
	 * @return a Vector containing String arrays (the rows).
	 */
	public static Vector explode(String[] source, int[] lengths) {
		Vector v = new Vector();
		for (int i = 0; i < source.length; i++) {
			v.addElement(StringUtils.explode(source[i], lengths));
		}
		return v;
	}

	/**
	 * Splits a string at the specified lengths and returns an array of Strings.
	 *
	 * @param source
	 *            the String to split.
	 * @lengths an array of lengths where to split the String.
	 * @return an array of Strings with the same number of elements as the
	 *         number of elements in the lengths argument. The length of each
	 *         String element is specified by the correspondent lengths array
	 *         element.
	 * @throws IndexOutOfBoundsException
	 *             if any of the length´s are invalid.
	 */
	public static String[] explode(String source, int[] lengths) {
		String[] result = new String[lengths.length];
		int position = 0;
		for (int i = 0; i < lengths.length; i++) {
			if (lengths[i] + position > source.length()) {
				throw new IndexOutOfBoundsException();
			}
			result[i] = source.substring(position, position + lengths[i]);
			position += lengths[i];
		}
		return result;
	}

	/**
	 * Splits a string into an array with a space as delimiter.
	 *
	 * @param source
	 *            the source String to explode.
	 * @return an array of strings that are made out of splitting the string at
	 *         the spaces.
	 */
	public static String[] explode(String source) {
		return StringUtils.explode(source, " ");
	}

	/**
	 * Splits a string into an array with the specified delimiter. Original code
	 * Copyright (C) 2001,2002 Stephen Ostermiller
	 * http://ostermiller.org/utils/StringHelper.java.html
	 *
	 * <p>
	 * This method is meant to be similar to the split function in other
	 * programming languages but it does not use regular expressions. Rather the
	 * String is split on a single String literal. It is equivalent to the
	 *
	 * @Explode function in Lotus Notes / Domino.
	 *          </p>
	 *          <p>
	 *          Unlike java.util.StringTokenizer which accepts multiple
	 *          character tokens as delimiters, the delimiter here is a single
	 *          String literal.
	 *          </p>
	 *          <p>
	 *          Each null token is returned as an empty String. Delimiters are
	 *          never returned as tokens.
	 *          </p>
	 *          <p>
	 *          If there is no delimiter because it is either empty or null, the
	 *          only element in the result is the original String.
	 *          </p>
	 *          <p>
	 *          StringHelper.explode("1-2-3", "-");<br>
	 *          result: {"1", "2", "3"}<br>
	 *          StringHelper.explode("-1--2-", "-");<br>
	 *          result: {"", "1", ,"", "2", ""}<br>
	 *          StringHelper.explode("123", "");<br>
	 *          result: {"123"}<br>
	 *          StringHelper.explode("1-2---3----4", "--");<br>
	 *          result: {"1-2", "-3", "", "4"}<br>
	 *          </p>
	 * @param s
	 *            the String to explode.
	 * @param delimiter
	 *            the delimiter where to split the string.
	 * @return an array of strings that are made out of splitting the string at
	 *         the specified delimiter.
	 * @throws NullPointerException
	 *             if s is null.
	 */
	public static String[] explode(String s, String delimiter) {
		int delimiterLength;
		int stringLength = s.length();

		if (delimiter == null || (delimiterLength = delimiter.length()) == 0) {
			return new String[] { s };
		}
		// a two pass solution is used because a one pass solution would
		// require the possible resizing and copying of memory structures
		// In the worst case it would have to be resized n times with each
		// resize having a O(n) copy leading to an O(n^2) algorithm.
		int count = 0;
		int start = 0;
		int end;

		while ((end = s.indexOf(delimiter, start)) != -1) {
			count++;
			start = end + delimiterLength;
		}
		count++;

		String[] result = new String[count];
		// Scan s again, but this time pick out the tokens
		count = 0;
		start = 0;
		while ((end = s.indexOf(delimiter, start)) != -1) {
			result[count] = s.substring(start, end);
			count++;
			start = end + delimiterLength;
		}
		end = stringLength;
		result[count] = s.substring(start, end);
		return result;
	}

	public static String[] slice(int theNum, String[] theStringArray) {
		if (theNum < theStringArray.length) {
			String[] t = new String[theStringArray.length - theNum];
			for (int i = theNum; i < theStringArray.length; i++) {
				t[i - theNum] = theStringArray[i];
			}
			return t;
		}
		return theStringArray;
	}

	/**
	 * Combines an array to a string, using the specified delimiter.
	 *
	 * @param elements
	 *            the array to combine to a single string.
	 * @param delimiter
	 *            the delimiter to put between the combined elements.
	 * @return the array combined to a string.
	 */
	public static String implode(Object[] elements, String delimiter) {
		StringBuffer buffer = new StringBuffer("");
		for (int i = 0; i < elements.length - 1; i++) {
			buffer.append((String) elements[i] + delimiter);
		}
		buffer.append((String) elements[elements.length - 1]);
		return buffer.toString();
	}

	/**
	 * Combines an array to a string, using a comma and a space as delimiter.
	 *
	 * @param elements
	 *            the array to combine to a single string.
	 * @return the array combined to a string.
	 */
	public static String implode(Object[] elements) {
		return implode(elements, ", ");
	}

	/**
	 * Used by randomString(int) for valid characters.
	 */
	protected static String VALID_RANDOM_CHARACTERS = "abcdefghijkmnopqrstuvwxyz"
			+ "ABCDEFGHJKLMNPQRSTUVWXYZ-_.,;:<>()1234567890%&/=?+";

	/**
	 * Removes all instances of a character in a String.
	 *
	 * @param source
	 *            the String to remove substring in.
	 * @param searchFor
	 *            the character to remove.
	 * @return the replaced String.
	 */
	public static String remove(String source, char searchFor) {
		String s = String.valueOf(searchFor);
		return StringUtils.remove(source, s);
	}

	/**
	 * Removes all instances of a substring in a String.
	 *
	 * @param source
	 *            the String to remove substring in.
	 * @param searchFor
	 *            the substring to remove.
	 * @return the replaced String.
	 */
	public static String remove(String source, String searchFor) {

		return StringUtils.replace(source, searchFor, "");
	}

	/**
	 * Removes all instances of substrings in a String.
	 *
	 * @param source
	 *            the String to remove substrings in.
	 * @param searchFor
	 *            an array of substrings to remove from the source String.
	 * @return the replaced String.
	 */
	public static String remove(String source, String searchFor[]) {
		return StringUtils.replace(source, searchFor, "");
	}

	/**
	 * Removes duplicates of a substring in a String. Case sensitive.
	 *
	 * @param source
	 *            the String to remove duplicates in.
	 * @param searchFor
	 *            the substring that can only occur one at a time, several can
	 *            exist in the source though.
	 */
	public static String removeDuplicates(String source, String searchFor) {
		StringBuffer result = new StringBuffer("");
		Enumeration myEnum = new StringTokenizer(source, searchFor, true);
		String current = "";
		String previous = "";

		while (myEnum.hasMoreElements()) {
			current = (String) myEnum.nextElement();
			if (!current.equals(previous)) {
				result.append(current);
			}
			previous = current;
		}
		return result.toString();
	}

	/**
	 * A utility method to remove duplicate characters from a string. For
	 * example, it would convert "hello" to "helo", and "abcd123abcaaa" to
	 * "abcd123".
	 *
	 * @param source
	 *            the String to remove all duplicate characters in.
	 * @return a String with no duplicate characters.
	 */
	protected String unique(String source) {
		String result = "";

		for (int k = 0; k < source.length(); k++) {
			if (result.indexOf(source.charAt(k)) == -1) {
				result += source.charAt(k);
			}
		}
		return result;
	}

	/**
	 * Prints the stacktrace to a buffer and returns the buffer as a String.
	 *
	 * @param t
	 *            the Throwable you wnat to generate a stacktrace for.
	 * @return the stacktrace of the supplied Throwable.
	 */
	public static String getStackTrace(Throwable t) throws IOException {
		StringWriter sw = new StringWriter();
		t.printStackTrace(new PrintWriter(sw));
		sw.close();
		return sw.toString();
	}

	/**
	 * Checks if a String is empty or null.
	 *
	 * @param s
	 *            the String to test if it is empty or null.
	 * @return true if the String is null or empty ("").
	 */
	public static boolean isEmpty(String s) {
		if (s == null) {
			return true;
		}
		return s.equals("");
	}

	/**
	 * Creates a string of the given width with the given string left justified
	 * (followed by an appropriate number of spaces).
	 *
	 * @param source
	 *            the String to justify
	 * @param length
	 *            the length of the resulting String
	 * @return the source String padded with spaces to fill up the length. If
	 *         the source string is longer than the length argument, the source
	 *         String is returned.
	 */
	public static String leftJustify(String source, int length) {
		if (source.length() >= length) {
			return source;
		}
		return StringUtils.spaces(length - source.length()) + source;
	}

	/**
	 * Creates a string of the given width with the given string right justified
	 * (with an appropriate number of spaces before it).
	 *
	 * @param source
	 *            the String to justify
	 * @param length
	 *            the length of the resulting String
	 * @return the source String padded with spaces to fill up the length. If
	 *         the source string is longer than the length argument, the source
	 *         String is returned.
	 */
	public static String rightJustify(String source, int length) {
		if (source.length() >= length) {
			return source;
		}

		return source + StringUtils.spaces(length - source.length());
	}

	/**
	 * Creates a string of the given width with the given string left justified
	 * (padded by an appropriate number of spaces in front and after it).
	 *
	 * @param source
	 *            the String to justify
	 * @param length
	 *            the length of the resulting String
	 * @return the source String padded with spaces to fill up the length. If
	 *         the source string is longer than the length argument, the source
	 *         String is returned.
	 */
	public static String centerJustify(String source, int length) {
		if (source.length() >= length) {
			return source;
		}
		int leftLength = (length - source.length()) / 2;
		int rightLength = length - (leftLength + source.length());
		return StringUtils.spaces(leftLength) + source
				+ StringUtils.spaces(rightLength);
	}

	/**
	 * Returns a String with the specified number of spaces.
	 *
	 * @param length
	 *            the number of spaces to return.
	 * @return a String consisting of the specified number of spaces.
	 */
	public static String spaces(int length) {
		return duplicate(" ", length);
	}

	/**
	 * Returns a String with the source String copied the specified number of
	 * times.
	 *
	 * @param source
	 *            the source String to copy.
	 * @param length
	 *            the number of copies of source to return.
	 * @return a String consisting of the specified source String copied the
	 *         specified number of times.
	 */
	public static String duplicate(String source, int copies) {
		StringBuffer buf = new StringBuffer();
		for (int i = 0; i < copies; i++) {
			buf.append(source);
		}
		return buf.toString();
	}

	/**
	 * Switches the case of the supplied String. Any lower case characters will
	 * be uppercase and vice versa.
	 *
	 * @param source
	 *            the String to switch case of.
	 * @return the supplied String with switched case.
	 */
	public static String switchCase(String source) {
		char[] sourceArray = source.toCharArray();
		StringBuffer result = new StringBuffer();

		for (int i = 0; i < sourceArray.length; i++) {
			result.append(StringUtils.switchCase(sourceArray[i]));
		}
		return result.toString();
	}

	/**
	 * Switches the case of the supplied character. A lower case character will
	 * be uppercase and vice versa.
	 *
	 * @param source
	 *            the character to switch case of.
	 * @return the supplied character with switched case.
	 */
	public static char switchCase(char source) {
		if (Character.isUpperCase(source)) {
			return Character.toLowerCase(source);
		}
		if (Character.isLowerCase(source)) {
			return Character.toUpperCase(source);
		}
		return source;
	}

	public static int getInt(String theString) {
		int i = 0;
		try {
			i = Integer.valueOf(theString).intValue();
		} catch (Exception iex) {
		}
		return i;
	}

	public static float getFloat(String theString) {
		float i = 0;
		try {
			i = Float.valueOf(theString).floatValue();
		} catch (Exception iex) {
		}
		return i;
	}

	public static String arrayToString(String[] theArray) {
		String myString = "";
		for (int i = 0; i < theArray.length; i++) {
			myString += theArray[i] + ",";
		}
		myString = myString.substring(0, myString.length() - 1);
		return myString;
	}



        public static String arrayToString(String[] theArray, int theStart, int theEnd) {
          String myString = "";
          if (theArray.length > theStart) {
            for (int i = theStart; i < theEnd; i++) {
              myString += theArray[i]+" ";
            }
            myString = myString.substring(0,myString.length()-1);
          }
          return myString;
        }


}
