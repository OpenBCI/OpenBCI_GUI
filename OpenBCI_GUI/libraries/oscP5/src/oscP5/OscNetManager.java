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

import netP5.AbstractMulticast;
import netP5.AbstractTcpClient;
import netP5.Logger;
import netP5.Multicast;
import netP5.NetAddress;
import netP5.NetAddressList;
import netP5.TcpClient;
import netP5.TcpPacket;
import netP5.TcpPacketListener;
import netP5.TcpServer;
import netP5.UdpClient;
import netP5.UdpPacketListener;
import netP5.UdpServer;


/**
 * @invisible
 */

public class OscNetManager
    implements UdpPacketListener, TcpPacketListener {

  protected OscProperties _myOscProperties;

  protected UdpClient _myUdpClient = null;

  protected UdpServer _myUdpServer = null;

  protected TcpServer _myTcpServer = null;

  protected TcpClient _myTcpClient = null;

  protected boolean isTcpClient = false;

  protected boolean isTcpServer = false;

  protected AbstractMulticast _myMulticast = null;

  protected ArrayList<UdpPacketListener> _myUdpListener = new ArrayList<UdpPacketListener>();

  protected ArrayList<TcpPacketListener> _myTcpListener = new ArrayList<TcpPacketListener>();

  public final static int NONE = 0;

  public void start(final OscProperties theOscProperties) {
    stop();
    _myOscProperties = theOscProperties;
    int networkProtocol = _myOscProperties.networkProtocol();
	switch (networkProtocol) {
      case (OscProperties.UDP):
        newUdp();
        break;
      case (OscProperties.MULTICAST):
        newMulticast();
        break;
      case (OscProperties.TCP):
        newTcp();
        break;
    }
    _myOscProperties.isLocked = true;
  }


  protected void stop() {
    _myUdpClient = null;
    if (_myMulticast != null) {
    	Logger.printDebug("OscP5.stop", "multicast.");
      _myMulticast.dispose();
    }
    if (_myUdpServer != null) {
    	Logger.printDebug("OscP5.stop", "stopping udpserver.");
      _myUdpServer.dispose();
    }
    _myMulticast = null;
    _myUdpServer = null;
    Logger.printProcess("OscP5", "stopped.");
  }


  private void newUdp() {
    if (_myOscProperties.remoteAddress() != null && _myOscProperties.remoteAddress().isvalid()) {
      _myUdpClient = new UdpClient(_myOscProperties.remoteAddress().address(), _myOscProperties.remoteAddress().port());
    }
    else {
      _myUdpClient = new UdpClient();
    }

    if (_myOscProperties.listeningPort() > 0) {
      _myUdpServer = new UdpServer(this, _myOscProperties.listeningPort(), _myOscProperties.datagramSize());
    }
  }


  private void newTcp() {
    if (_myOscProperties.listeningPort() > 0) {
      _myTcpServer = new TcpServer(this, _myOscProperties.listeningPort(), TcpServer.MODE_STREAM);
      isTcpServer = true;
    }
    else if (_myOscProperties.remoteAddress().isvalid()) {
      _myTcpClient = new TcpClient(
          this,
          _myOscProperties.remoteAddress().address(),
          _myOscProperties.remoteAddress().port(),
          TcpClient.MODE_STREAM);
      isTcpClient = true;
    }
  }


  private void newMulticast() {
    if (_myOscProperties.remoteAddress() != null && _myOscProperties.remoteAddress().isvalid()) {
      _myMulticast = new Multicast(
          this,
          _myOscProperties.remoteAddress().address(),
          _myOscProperties.remoteAddress().port(),
          _myOscProperties.datagramSize());

    }
    else {
      // ESCA-JAVA0266:
    System.out.println("ERROR @ Multicast");
    }

  }


  public void setTimeToLive(final int theTTL) {
    if (_myMulticast != null) {
      _myMulticast.setTimeToLive(theTTL);
    }
    else {
      Logger.printWarning("OscNetManager.setTimeToLive", "only supported for multicast session.");
    }
  }


  public TcpServer tcpServer() {
    return _myTcpServer;
  }


  public TcpClient tcpClient() {
    return _myTcpClient;
  }


  /**
   * @param theListener DatagramPacketListener
   */
  public void addUdpListener(final UdpPacketListener theListener) {
    _myUdpListener.add(theListener);
  }


  /**
   * @param theListener DatagramPacketListener
   */
  public void removeUdpListener(final UdpPacketListener theListener) {
    _myUdpListener.remove(theListener);
  }


  /**
   * @param theListener TcpPacketListener
   */
  public void addTcpListener(final TcpPacketListener theListener) {
    _myTcpListener.add(theListener);
  }


  /**
   * @param theListener TcpPacketListener
   */
  public void removeTcpListener(final TcpPacketListener theListener) {
    _myTcpListener.remove(theListener);
  }


  /**
   * @param thePacket OscPacket
   */
  public void send(final OscPacket thePacket) {
    if (_myOscProperties.sendStatus() == false && _myOscProperties.networkProtocol() != OscProperties.TCP) {
      Logger.printWarning("OscNetManager.send", "please specify a remote address. send(OscPacket theOscPacket) "
                          + "is only supported when there is a host specified in OscProperties.");
    }
    else {
      try {
        switch (_myOscProperties.networkProtocol()) {
          case (OscProperties.UDP):
            if (_myOscProperties.srsp()) {
              _myUdpServer.send(
                  thePacket.getBytes(),
                  _myOscProperties.remoteAddress().inetaddress(),
                  _myOscProperties.remoteAddress().port());

            }
            else {
              _myUdpClient.send(
                  thePacket.getBytes(),
                  _myOscProperties.remoteAddress().inetaddress(),
                  _myOscProperties.remoteAddress().port());
            }
            break;
          case (OscProperties.TCP):
            if (isTcpServer) {
              _myTcpServer.send(thePacket.getBytes());
            }
            else if (isTcpClient) {
              _myTcpClient.send(thePacket.getBytes());
            }
            break;
          case (OscProperties.MULTICAST):
            _myMulticast.send(thePacket.getBytes());
            break;
        }
      }
      catch (final NullPointerException e) {
        Logger.printError("OscManager.send", "NullPointerException " + e);
      }
    }
  }


  public void send(final DatagramPacket thePacket) {
    if (_myOscProperties.srsp()) {
      _myUdpServer.send(thePacket);
    }
    else {
      _myUdpClient.send(thePacket);
    }
  }


  /**
   * @param thePacket OscPacket
   * @param theAddress String
   * @param thePort int
   */
  public void send(final OscPacket thePacket, final String theAddress, final int thePort) {
    try {
      switch (_myOscProperties.networkProtocol()) {
        case (OscProperties.UDP):
          if (_myOscProperties.srsp()) {
            _myUdpServer.send(thePacket.getBytes(), theAddress, thePort);
          }
          else {
            _myUdpClient.send(thePacket.getBytes(), theAddress, thePort);
          }
          break;
        case (OscProperties.MULTICAST):
          _myMulticast.send(thePacket.getBytes());
          break;
        case (OscProperties.TCP):
          Logger.printWarning(
              "OscP5.send",
              "send(OscPacket thePacket,String theAddress,int thePort) is not supported in TCP mode.");
          break;
      }
    }
    catch (final NullPointerException e) {
      Logger.printError("OscP5.send", "NullPointerException " + e);
    }
  }


  /**
   * @param thePacket OscPacket
   * @param theList OscHostList
   */
  public void send(final OscPacket thePacket, final NetAddressList theList) {
    switch (_myOscProperties.networkProtocol()) {
      case (OscProperties.UDP):
        final byte[] myBytes = thePacket.getBytes();
        final DatagramPacket myPacket = new DatagramPacket(myBytes, myBytes.length);
        for (int i = 0; i < theList.list().size(); i++) {
          myPacket.setAddress(theList.get(i).inetaddress());
          myPacket.setPort(theList.get(i).port());
          send(myPacket);
        }
        break;
      case (OscProperties.TCP):
        Logger.printWarning(
            "OscP5.send",
            "send(OscPacket thePacket,NetAddressList theList) is not supported in TCP mode.");
        break;
    }
  }


  /**
   * @param thePacket OscPacket
   * @param theHost NetAddress
   */
  public void send(final OscPacket thePacket, final NetAddress theHost) {
    switch (_myOscProperties.networkProtocol()) {

      case (OscProperties.UDP):
        if (theHost.isvalid()) {
          final byte[] myBytes = thePacket.getBytes();
          final DatagramPacket myPacket = new DatagramPacket(myBytes, myBytes.length);
          myPacket.setAddress(theHost.inetaddress());
          myPacket.setPort(theHost.port());
          send(myPacket);
        }
        break;
      case (OscProperties.TCP):
        Logger.printWarning("OscP5.send", "send(OscPacket thePacket,NetAddress theHost) is not supported in TCP mode.");
        break;
    }
  }


  /**
   * @param theAddrPattern String
   * @param theArguments Object[]
   */
  public void send(final String theAddrPattern, final Object[] theArguments) {
    send(new OscMessage(theAddrPattern, theArguments));
  }


  public void send(final String theAddrPattern, final Object[] theArguments, final String theAddress, final int thePort) {
    send(new OscMessage(theAddrPattern, theArguments), theAddress, thePort);
  }


  public void send(final String theAddrPattern, final Object[] theArguments, final NetAddressList theList) {
    send(new OscMessage(theAddrPattern, theArguments), theList);
  }


  public void send(final String theAddrPattern, final Object[] theArguments, final NetAddress theHost) {
    send(new OscMessage(theAddrPattern, theArguments), theHost);
  }


  public void process(final DatagramPacket thePacket, final int thePort) {
    for (int i = 0; i < _myUdpListener.size(); i++) {
      _myUdpListener.get(i).process(thePacket, thePort);
    }
  }


  public void process(final TcpPacket thePacket, final int thePort) {
    for (int i = 0; i < _myTcpListener.size(); i++) {
      _myTcpListener.get(i).process(thePacket, thePort);
    }
  }


  public void remove(final AbstractTcpClient theClient) {}


  public void status(final int theIndex) {}
}
