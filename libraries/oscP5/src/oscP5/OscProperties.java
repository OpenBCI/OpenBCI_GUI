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


import netP5.Logger;
import netP5.NetAddress;
import java.util.Vector;

/**
 * osc properties are used to start oscP5 with more specific settings.
 * osc properties have to be passed to oscP5 in the constructor when
 * starting a new instance of oscP5.
 * @related OscP5
 * @example oscP5properties
 */
public class OscProperties {

  public static final boolean ON = true;

  public static final boolean OFF = false;

  /**
   * @related setNetworkProtocol ( )
   */
  public static final int UDP = 0;

  /**
   * @related setNetworkProtocol ( )
   */
  public static final int MULTICAST = 1;


  /**
   * @related setNetworkProtocol ( )
   */
  public static final int TCP = 2;


  protected static final String[] _myProtocols = {"udp", "tcp", "multicast"};

  protected boolean isLocked = false;

  protected final Vector<OscEventListener> listeners;

  private NetAddress _myRemoteAddress = new NetAddress("", 0);

  private int _myListeningPort = 0;

  private int _myDatagramSize = 1536; // common MTU

  protected String _myDefaultEventMethodName = "oscEvent";

  private int _myNetworkProtocol = UDP;

  private boolean _mySendStatus = false;

  private boolean _mySRSP = OFF; // (S)end (R)eceive (S)ame (P)ort

  public OscProperties(OscEventListener theParent) {
    this();
    listeners.add(theParent);
  }



  /**
   * create a new OscProperties Object.
   */
  public OscProperties() {
    listeners = new Vector<OscEventListener>();
  }



  /**
   *
   * @return OscEventListener
   * @invisible
   */
  public Vector<OscEventListener> listeners() {
    return listeners;
  }



  /**
   *
   * @return boolean
   * @related OscProperties
   * @invisible
   */
  public boolean sendStatus() {
    return _mySendStatus;
  }



  /**
   * set the remote host address. set ip address and port of the host
   * message should be sent to.
   * @param theHostAddress String
   * @param thePort int
   * @related OscProperties
   */
  public void setRemoteAddress(final String theHostAddress, final int thePort) {
    _myRemoteAddress = new NetAddress(theHostAddress, thePort);
    _mySendStatus = _myRemoteAddress.isvalid();
  }

  /**
   * set the remote host address. set ip address and port of the host
   * message should be sent to.
   * @param theNetAddress NetAddress
   * @related OscProperties
   */
  public void setRemoteAddress(NetAddress theNetAddress) {
    _myRemoteAddress = theNetAddress;
    _mySendStatus = _myRemoteAddress.isvalid();
  }


  /**
   *set port number you are listening for incoming osc packets.
   * @param thePort int
   * @related OscProperties
   */
  public void setListeningPort(final int thePort) {
    _myListeningPort = thePort;
  }



  /**
   * set the size of the datagrampacket byte buffer.
   * the default size is 1536 bytes.
   * @param theSize int
   * @related OscProperties
   */
  public void setDatagramSize(final int theSize) {
    if (!isLocked) {
      _myDatagramSize = theSize;
    }
    else {
      Logger.printWarning("OscProperties.setDatagramSize",
                          "datagram size can only be set before initializing oscP5\ncurrent datagram size is "
                          + _myDatagramSize);
    }
  }



  /**
   * set the name of the default event method.
   * the event method is the method to which incoming osc messages
   * are forwarded. the default name for the event method is
   * "oscEvent"
   * @param theEventMethod String
   * @related OscProperties
   */
  public void setEventMethod(final String theEventMethod) {
    _myDefaultEventMethodName = theEventMethod;
  }



  /**
   * set the network protocol over which osc messages are transmitted.
   * options are OscProperties.UDP and OscProperties.MULTICAST
   * the network protocol can only be set before initializing
   * oscP5.
   * @param theProtocol int
   * @related OscProperties
   * @related UDP
   * @related TCP
   * @related MULTICAST
   * @related networkProtocol ( )
   */
  public void setNetworkProtocol(final int theProtocol) {
    if (!isLocked) {
      if (theProtocol > 2) {
        Logger.printWarning("OscProperties.setNetworkProtocol",
                            "not in the range of supported Network protocols. the network protocol defaults to UDP");
      }
      else {
        _myNetworkProtocol = theProtocol;
      }
    }
    else {
      Logger.printWarning("OscProperties.setNetworkProtocol",
                          "network protocol can only be set before initializing oscP5.");
    }
  }



  /**
   * SRSP stand for Send and Receive on Same Port.
   * by default osc packets are not received and sent by the same port.
   * if you need to send and receive on the same port call
   * setSRSP(OscProperties.ON)
   * @param theFlag boolean
   * @related OscProperties
   */
  public void setSRSP(final boolean theFlag) {
    _mySRSP = theFlag;
  }



  /**
   * you can send and receive at the same port while on a udp con
   * @return boolean
   * @related OscProperties
   */
  public boolean srsp() {
    return _mySRSP;
  }



  /**
   * returns the port number currently used to receive osc packets.
   * @return int
   * @related OscProperties
   */
  public int listeningPort() {
    return _myListeningPort;
  }



  /**
   * returns a NetAddress of the remote host you are sending
   * osc packets to. by default this is null.
   * @return NetAddress
   * @related OscProperties
   */
  public NetAddress remoteAddress() {
    return _myRemoteAddress;
  }



  /**
   * returns the current size of the datagram bytebuffer.
   * @return int
   * @related OscProperties
   */
  public int datagramSize() {
    return _myDatagramSize;
  }



  /**
   *
   * @return String
   * @related OscProperties
   */
  public String eventMethod() {
    return _myDefaultEventMethodName;
  }



  /**
   * returns the network protocol being used to transmit osc packets. returns an int.
   * 0 (UDP), 1 (MULTICAST), 2 (TCP)
   * @return int
   * @related OscProperties
   */
  public int networkProtocol() {
    return _myNetworkProtocol;
  }



  /**
   * prints out the current osc properties settings.
   * @return String
   * @related OscProperties
   */
  public String toString() {
    String s = "\nnetwork protocol: " + (_myProtocols[_myNetworkProtocol])
        + "\n";
    s += "host: " + ((_myRemoteAddress.address()!=null) ? _myRemoteAddress.address():"host address not set.") + "\n";
    s += "sendToPort: " + _myRemoteAddress.port() + "\n";
    s += "receiveAtPort: " + listeningPort() + "\n";
    s += "datagramSize: " + _myDatagramSize + "\n";
    s += "event Method: " + _myDefaultEventMethodName + "\n";
    s += "(S)end(R)eceive(S)ame(P)ort: " + this._mySRSP + "\n\n";
    return s;
  }

}
