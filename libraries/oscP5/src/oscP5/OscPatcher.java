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
 * @author              Andreas Schlegel http://www.sojamo.de
 * @modified    12/23/2012
 * @version             0.9.9
 */

package oscP5;

import java.net.InetAddress;
import java.util.ArrayList;
import netP5.Bytes;
import netP5.TcpClient;

/**
 *
 * @invisible
 */
public abstract class OscPatcher {

  
protected static final byte ZEROBYTE = 0x00;

  protected static final byte KOMMA = 0x2c;

  protected static final long TIMETAG_OFFSET = 2208988800L;

  protected static final long TIEMTAG_NOW = 1;

  protected ArrayList<OscMessage> messages;

  protected byte[] _myAddrPattern;

  protected int _myAddrInt = -1;

  protected byte[] _myTypetag = new byte[0];

  protected byte[] _myData = new byte[0];

  protected Object[] _myArguments;
  
  protected boolean isValid = false;

  protected long timetag = 1;

  protected boolean isArray = false;

  protected byte _myArrayType = 0X00;

  protected OscPatcher() {
  }


  protected int parseBundle(final byte[] theBytes,
                            final InetAddress theAddress, final int thePort,
                            final TcpClient theClient) {
    if (theBytes.length > OscBundle.BUNDLE_HEADER_SIZE) {
      timetag = (new Long(Bytes.toLong(Bytes.copy(theBytes, 8, 8)))).longValue();
      int myPosition = OscBundle.BUNDLE_HEADER_SIZE;
      messages = new ArrayList<OscMessage>();
      int myMessageLength = Bytes.toInt(Bytes.copy(theBytes, myPosition,4));
      while (myMessageLength != 0 && (myMessageLength % 4 == 0)
             && myPosition < theBytes.length) {
        myPosition += 4;
        messages.add(new OscMessage(Bytes.copy(theBytes, myPosition,myMessageLength),
                                    theAddress,
                                    thePort,
                                    timetag,
                                    theClient));
        myPosition += myMessageLength;
        if(myPosition >= theBytes.length)
            break;
        myMessageLength = Bytes.toInt(Bytes.copy(theBytes, myPosition,4));
      }
    }
    for (int i = 0; i < messages.size(); i++) {
      if (!messages.get(i).isValid) {
        messages.remove(messages.get(i));
      }
    }

    if (messages.size() > 0) {
      isValid = true;
    }
    return messages.size();
  }


  protected void parseMessage(final byte[] theBytes) {
    int myLength = theBytes.length;
    int myIndex = 0;
    myIndex = parseAddrPattern(theBytes, myLength, myIndex);
    if (myIndex != -1) {
      myIndex = parseTypetag(theBytes, myLength, myIndex);
    }
    if (myIndex != -1) {
      _myData = Bytes.copy(theBytes, myIndex);
      _myArguments = parseArguments(_myData);
      isValid = true;
    }
  }


  protected int parseAddrPattern(final byte[] theBytes, final int theLength,
                                 final int theIndex) {
    if (theLength > 4 && theBytes[4] == KOMMA) {
      _myAddrInt = Bytes.toInt(Bytes.copy(theBytes, 0, 4));
    }
    for (int i = theIndex; i < theLength; i++) {
      if (theBytes[i] == ZEROBYTE) {
        _myAddrPattern = Bytes.copy(theBytes, theIndex, i);
        return i + align(i);
      }
    }
    return -1;
  }


  protected int parseTypetag(final byte[] theBytes, final int theLength,
                             int theIndex) {
    if (theBytes[theIndex] == KOMMA) {
      theIndex++;
      for (int i = theIndex; i < theLength; i++) {
        if (theBytes[i] == ZEROBYTE) {
          _myTypetag = Bytes.copy(theBytes, theIndex, i - theIndex);
          return i + align(i);
        }
      }
    }
    return -1;
  }


  /**
   * cast the arguments passed with the incoming osc message and store them in
   * an object array.
   *
   * @param theBytes
   * @return
   */
  protected Object[] parseArguments(final byte[] theBytes) {
    Object[] myArguments = new Object[0];
    int myTagIndex = 0;
    int myIndex = 0;
    myArguments = new Object[_myTypetag.length];
    isArray = (_myTypetag.length > 0) ? true : false;
    while (myTagIndex < _myTypetag.length) {
      /* check if we still save the arguments as an array */
      if (myTagIndex == 0) {
        _myArrayType = _myTypetag[myTagIndex];
      } else {
        if (_myTypetag[myTagIndex] != _myArrayType) {
          isArray = false;
        }
      }
      switch (_myTypetag[myTagIndex]) {
      case (0x63): // char c
        myArguments[myTagIndex] = (new Character((char) (Bytes
                .toInt(Bytes.copy(theBytes, myIndex, 4)))));
        myIndex += 4;
        break;
      case (0x69): // int i
        myArguments[myTagIndex] = (new Integer(Bytes.toInt(Bytes.copy(
                theBytes, myIndex, 4))));
        myIndex += 4;
        break;
      case (0x66): // float f
        myArguments[myTagIndex] = (new Float(Bytes.toFloat(Bytes.copy(
                theBytes, myIndex, 4))));
        myIndex += 4;

        break;
      case (0x6c): // long l
      case (0x68): // long h
        myArguments[myTagIndex] = (new Long(Bytes.toLong(Bytes.copy(
                theBytes, myIndex, 8))));
        myIndex += 8;
        break;
      case (0x64): // double d
        myArguments[myTagIndex] = (new Double(Bytes.toDouble(Bytes
                .copy(theBytes, myIndex, 8))));
        myIndex += 8;
        break;
      case (0x53): // Symbol S
      case (0x73): // String s
        int newIndex = myIndex;
        StringBuffer stringBuffer = new StringBuffer();

        stringLoop:
                do {
          if (theBytes[newIndex] == 0x00) {
            break stringLoop;
          } else {
            stringBuffer.append((char) theBytes[newIndex]);
          }
          newIndex++;
        } while (newIndex < theBytes.length);

        myArguments[myTagIndex] = (stringBuffer.toString());
        myIndex = newIndex + align(newIndex);
        break;
      case 0x62: // byte[] b - blob
        int myLen = Bytes.toInt(Bytes.copy(theBytes, myIndex, 4));
        myIndex += 4;
        myArguments[myTagIndex] = Bytes.copy(theBytes, myIndex, myLen);
        myIndex += myLen + (align(myLen) % 4);
        break;
      case 0x6d: // midi m
        myArguments[myTagIndex] = Bytes.copy(theBytes, myIndex, 4);
        myIndex += 4;
        break;
        /*
         * no arguments for typetags T,F,N T = true F = false N = false
         */
      }
      myTagIndex++;
    }
    _myData = Bytes.copy(_myData, 0, myIndex);
    return myArguments;
  }


  protected static int align(int theInt) {
    return (4 - (theInt % 4));
  }

}