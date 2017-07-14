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


import java.net.DatagramPacket;
import java.util.ArrayList;
import netP5.Bytes;
import netP5.TcpPacket;


/**
 * Osc Bundles are collections of Osc Messages. use bundles to send multiple
 * osc messages to one destination. the OscBundle timetag is supported for
 * sending but not for receiving yet.
 * @related OscMessage
 * @related OscP5
 * @example oscP5bundle
 */
public class OscBundle extends OscPacket {

  protected static final int BUNDLE_HEADER_SIZE = 16;

  protected static final byte[] BUNDLE_AS_BYTES = {0x23, 0x62, 0x75, 0x6E,
                                                  0x64, 0x6C, 0x65, 0x00};

  private int _myMessageSize = 0;

  /**
   * instantiate a new OscBundle object.
   */
  public OscBundle() {
    messages = new ArrayList<OscMessage>();
  }


  protected OscBundle(DatagramPacket theDatagramPacket) {
    inetAddress = theDatagramPacket.getAddress();
    port = theDatagramPacket.getPort();
    hostAddress = inetAddress.toString();
    _myMessageSize = parseBundle(theDatagramPacket.getData(), inetAddress, port, null);
    _myType = BUNDLE;
  }


  protected OscBundle(TcpPacket thePacket) {
    _myTcpClient = thePacket.getTcpConnection();
    inetAddress = _myTcpClient.netAddress().inetaddress();
    port = _myTcpClient.netAddress().port();
    hostAddress = inetAddress.toString();
    _myMessageSize = parseBundle(thePacket.getData(), inetAddress, port, _myTcpClient);
    _myType = BUNDLE;
  }


  /**
   * add an osc message to the osc bundle.
   * @param theOscMessage OscMessage
   */
  public void add(OscMessage theOscMessage) {
    messages.add(new OscMessage(theOscMessage));
    _myMessageSize = messages.size();
  }


  /**
   * clear and reset the osc bundle for reusing.
   * @example oscP5bundle
   */
  public void clear() {
    messages = new ArrayList<OscMessage>();
  }


  /**
   * remove an OscMessage from an OscBundle.
   * @param theIndex int
   */
  public void remove(int theIndex) {
    messages.remove(theIndex);
  }


  /**
   *
   * @param theOscMessage OscMessage
   */
  public void remove(OscMessage theOscMessage) {
    messages.remove(theOscMessage);
  }


  /**
   * request an osc message inside the osc bundle array,
   * @param theIndex int
   * @return OscMessage
   */
  public OscMessage getMessage(int theIndex) {
    return messages.get(theIndex);
  }


  /**
   * get the size of the osc bundle array which contains the osc messages.
   * @return int
   * @example oscP5bundle
   */
  public int size() {
    return _myMessageSize;
  }


  /**
   * set the timetag of an osc bundle. timetags are used to synchronize events and
   * execute events at a given time in the future or immediately. timetags can
   * only be set for osc bundles, not for osc messages. oscP5 supports receiving
   * timetags, but does not queue messages for execution at a set time.
   * @param theTime long
   * @example oscP5bundle
   */
  public void setTimetag(long theTime) {
    final long secsSince1900 = theTime / 1000 + TIMETAG_OFFSET;
    final long secsFractional = ((theTime % 1000) << 32) / 1000;
    timetag = (secsSince1900 << 32) | secsFractional;
  }


  /**
   * returns the current time in milliseconds. use with setTimetag.
   * @return long
   */
  public static long now() {
    return System.currentTimeMillis();
  }


  /**
   * returns a timetag as byte array.
   * @return byte[]
   */
  public byte[] timetag() {
    return Bytes.toBytes(timetag);
  }


  /**
   * @todo get timetag as Date
   */

  /**
   *
   * @return byte[]
   * @invisible
   */
  public byte[] getBytes() {
    byte[] myBytes = new byte[0];
    myBytes = Bytes.append(myBytes, BUNDLE_AS_BYTES);
    myBytes = Bytes.append(myBytes, timetag());
    for (int i = 0; i < size(); i++) {
      byte[] tBytes = getMessage(i).getBytes();
      myBytes = Bytes.append(myBytes, Bytes.toBytes(tBytes.length));
      myBytes = Bytes.append(myBytes, tBytes);
    }
    return myBytes;
  }
}
