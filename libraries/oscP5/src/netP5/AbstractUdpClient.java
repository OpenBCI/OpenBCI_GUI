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


import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;




/**
 * @invisible
 */
public abstract class AbstractUdpClient {

  protected NetAddress _myNetAddress;

  protected DatagramSocket _mySocket;

  protected boolean isRunning = false;


  /**
   * @invisible
   */
  public AbstractUdpClient() {
    isRunning = openSocket();
  }


  /**
   * @invisible
   * @param theAddr String
   * @param thePort int
   */
  public AbstractUdpClient(String theAddr, int thePort) {

    _myNetAddress = new NetAddress(theAddr, thePort);

    if(!_myNetAddress.isvalid()) {
      Logger.printError("UdpClient", "unknown host " + theAddr);
    }
    isRunning = openSocket();
  }

  /**
   * get the datagram socket of the UDP client. more info at java.net.DatagramSocket
   * @return DatagramSocket
   */
  public DatagramSocket socket() {
    return _mySocket;
  }



  private boolean openSocket() {
    try {
      _mySocket = new DatagramSocket();
    }
    catch (SocketException e) {
      Logger.printError("UdpClient.openSocket", "cant create socket "
                        + e.getMessage());
      return false;
    }

    Logger.printProcess("UdpClient.openSocket", "udp socket initialized.");
    return true;
  }

  /**
   * send a string using UDP to an already specified RemoteAddress.
   * @param theString
   */
  public void send(String theString) {
    send(theString.getBytes());
  }


  /**
   * send a byte array using UDP to an already specified RemoteAddress.
   * @param theBytes byte[]
   */
  public void send(byte[] theBytes) {
    if (_myNetAddress.isvalid()) {
      send(theBytes, _myNetAddress);
    }
    else {
      Logger.printWarning("UdpClient.send",
                          "no InetAddress and port has been set. Packet has not been sent.");
    }
  }

  /**
   * send a byte array to the dedicated remoteAddress.
   * @param theBytes
   * @param theNetAddress
   */
  public void send(final byte[] theBytes,
                   final NetAddress theNetAddress
      ) {
    if (_myNetAddress.isvalid()) {
      send(theBytes, theNetAddress.inetaddress(),theNetAddress.port());
    }
  }

  /**
   * send a byte array to the dedicated remoteAddress.
   * @param thePacket OscPacket
   * @param theAddress String
   * @param thePort int
   */
  public void send(final byte[] theBytes,
                   final String theAddress,
                   final int thePort) {
    try {
      InetAddress myInetAddress = InetAddress.getByName(theAddress);
      send(theBytes, myInetAddress, thePort);
    }
    catch (UnknownHostException e) {
      Logger.printError("UdpClient.send", "while sending to "
                        + theAddress + " " + e);
    }
  }



  /**
   * @invisible
   * @param thePacket DatagramPacket
   */
  public void send(DatagramPacket thePacket) {
    if (isRunning) {
      try {
            _mySocket.send(thePacket);

      }
      catch (IOException e) {
        Logger.printError("UdpClient.send",
                          "ioexception while sending packet. "+e);
      }
    }
  }



  /**
   * send a byte array to the dedicated remoteAddress.
   * @param theBytes byte[]
   * @param theAddress InetAddress
   * @param thePort int
   */
  public void send(final byte[] theBytes,
                   final InetAddress theAddress,
                   final int thePort) {
    if (isRunning) {
      try {
        DatagramPacket myPacket = new DatagramPacket(theBytes,theBytes.length, theAddress, thePort);
        send(myPacket);
      }
      catch (NullPointerException npe) {
        Logger.printError("UdpClient.send",
                          "a nullpointer exception occured." + npe);
      }
    }
    else {
      Logger.printWarning("UdpClient.send",
                          "DatagramSocket is not running. Packet has not been sent.");
    }
  }

}
