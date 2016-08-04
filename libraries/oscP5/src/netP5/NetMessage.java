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


import java.net.DatagramPacket;

import java.net.InetAddress;


/**
 * @author andreas schlegel
 */
public class NetMessage {

  private InetAddress _myInetAddress;

  private int _myPort;

  private String _myString = "";

  private byte[] _myData = new byte[0];

  private TcpClient _myTcpClient;

  private boolean isDatagramPacket = false;
  
  private int _myProtocol;
  
  private DatagramPacket _myDatagramPacket;
  
  private TcpPacket _myTcpPacket;
  
  protected NetMessage(DatagramPacket theDatagramPacket) {
	_myDatagramPacket = theDatagramPacket;
    _myInetAddress = theDatagramPacket.getAddress();
    _myPort = theDatagramPacket.getPort();
    _myData = theDatagramPacket.getData();
    _myProtocol = NetP5.UDP;
    isDatagramPacket = true;
  }
  

  protected NetMessage(TcpPacket theTcpPacket) {
	_myTcpPacket = theTcpPacket;
    _myInetAddress = theTcpPacket.getTcpConnection().socket().getInetAddress();
    _myPort = theTcpPacket.getTcpConnection().socket().getPort();
    _myString = theTcpPacket.getTcpConnection().getString();
    _myData =  theTcpPacket.getData();
    _myProtocol = NetP5.TCP;
    _myTcpClient = theTcpPacket.getTcpConnection();
  }
  
  
  public TcpPacket getTcpPacket() {
	  return _myTcpPacket;
  }
  
  public DatagramPacket getDatagramPacket() {
	  return _myDatagramPacket;
  }

  protected void setProtocol(int theType) {
	  _myProtocol = theType;
  }
  

  /**
   * get the data of the message as bytes.
   * @return
   */
  public byte[] getData() {
    return _myData;
  }

  
  /**
   * get the data the message as string.
   * @return
   */
  public String getString() {
    if(isDatagramPacket) {
      return new String(_myData);
    } else {
      return _myString;
    }
  }
  
  /**
   * get the protocol type the message was sent over.
   * NetP5.TCP or NetP5.UDP are possible.
   * @return
   */
  public int protocol() {
	  return _myProtocol;
  } 


  /**
   * get the port the net message was received at.
   * @return
   */
  public int port() {
    return _myPort;
  }



  public TcpClient tcpConnection() {
    return _myTcpClient;
  }



  public String address() {
    return _myInetAddress.getHostAddress();
  }



  public InetAddress inetAddress() {
    return _myInetAddress;
  }

}
