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


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.io.InputStream;
import java.io.OutputStream;


/**
 * @invisible
 */
public abstract class AbstractTcpClient implements Runnable {

  private Socket _mySocket;

  protected TcpPacketListener _myTcpPacketListener;

  private PrintWriter _myOutput = null;

  private BufferedReader _myInput = null;

  private OutputStream _myOutputStream = null;

  protected byte[] _myBytes = new byte[0];

  protected StringBuffer _myStringBuffer = new StringBuffer(0);

  protected AbstractTcpServer _myTcpServer;

  protected NetAddress _myNetAddress;

  protected int _myServerPort;

  private Thread _myThread;

  private char TERMINATOR = '\0';
  
  /**
   * terminator is readline.
   */
  public static final int MODE_READLINE = 0;

  /**
   * terminator is terminated, by default this is character '\0'
   * and can be set with setTerminator
   */
  public static final int MODE_TERMINATED = 1;

  /**
   * terminator is newline.
   */
  public static final int MODE_NEWLINE = 2;
  
  /**
   * no terminator required, packets are sent via
   * a tcp stream.
   */
  public static final int MODE_STREAM = 3;

  private final int _myMode;

  /**
   * @invisible
   * @param theTcpPacketListener TcpPacketListener
   * @param theHost String
   * @param thePort int
   */
  public AbstractTcpClient(final TcpPacketListener theTcpPacketListener,
                           final String theHost,
                           final int thePort) {
    this(theTcpPacketListener, theHost, thePort, MODE_READLINE);
  }

  /**
   * @invisible
   * @param theHost String
   * @param thePort int
   */
  public AbstractTcpClient(final String theHost,
                           final int thePort) {
    this(null, theHost, thePort, MODE_READLINE);
  }

  /**
   * @invisible
   * @param theTcpPacketListener TcpPacketListener
   * @param theHost String
   * @param thePort int
   * @param theMode int
   */
  public AbstractTcpClient(final TcpPacketListener theTcpPacketListener,
                           final String theHost,
                           final int thePort,
                           final int theMode) {
    _myTcpPacketListener = theTcpPacketListener;
    _myNetAddress = new NetAddress(theHost, thePort);
    _myMode = theMode;
    startSocket();
  }

  /**
   * @invisible
   * @param theHost String
   * @param thePort int
   * @param theMode int
   */
  public AbstractTcpClient(final String theHost,
                           final int thePort,
                           final int theMode) {
    this(null, theHost, thePort, theMode);
  }


  /**
   * @invisible
   * @param theTcpServer AbstractTcpServer
   * @param theSocket Socket
   * @param theTcpPacketListener TcpPacketListener
   * @param theServerPort int
   * @param theMode int
   */
  public AbstractTcpClient(final AbstractTcpServer theTcpServer,
                           final Socket theSocket,
                           final TcpPacketListener theTcpPacketListener,
                           final int theServerPort,
                           final int theMode) {
    _myTcpServer = theTcpServer;
    _mySocket = theSocket;
    _myTcpPacketListener = theTcpPacketListener;
    _myServerPort = theServerPort;
    _myMode = theMode;
    startSocket();
  }


  private void startSocket() {
    try {
      if (_mySocket == null) {
        _mySocket = new Socket(_myNetAddress.address(), _myNetAddress.port());
      } else {
        _myNetAddress = new NetAddress(_mySocket.getInetAddress().getHostAddress(),
                                       _mySocket.getPort());
      }
      Logger.printProcess("TcpClient", "### starting new TcpClient " + _myNetAddress);
      if (_myMode == MODE_STREAM) {
        _myOutputStream = _mySocket.getOutputStream();
      }
      init();
    } catch (final IOException e) {
      Logger.printError("TcpClient",
                        "IOException while trying to create a new socket.");
//      handleStatus(NetStatus.CONNECTION_FAILED); // FIX! NetPlug is still null at this point.  NetPlug has to exist first.
    }
  }


  /**
   * when a TCP connection is lost, reconnect to the server with reconnect().
   */
  public void reconnect() {
    try {
      Thread.sleep(1000);
    } catch(final Exception e) { }
    startSocket();
  }


  private void init() {
    _myThread = new Thread(this);
    _myThread.start();
  }

  /**
   * to parse an incomming tcp message, a terminator character is required to
   * determine the end of the message so that it can be parsed and forwarded.
   *  
   * @param theTerminator
   */
  public void setTerminator(final char theTerminator) {
    TERMINATOR = theTerminator;
  }

  /**
   * stop and dispose a tcp client.
   */
  public void dispose() {
    try {
      // do io streams need to be closed first?
      if (_myInput != null) {
        _myInput.close();
      }
      if (_myOutput != null) {
        _myOutput.close();
      }

    } catch (final Exception e) {
      e.printStackTrace();
    }
    _myInput = null;
    _myOutput = null;

    try {
      if (_mySocket != null) {
        _mySocket.close();
      }

    } catch (final Exception e) {
      e.printStackTrace();
    }
    if(_myThread==null) {
      return;
    }
    _mySocket = null;
    _myThread = null;
    handleStatus(NetStatus.CONNECTION_CLOSED);
    Logger.printProcess("TcpClient.dispose", "TcpClient closed.");
  }

  /**
   * @invisible
   */
  public void run() {
    if (_myMode == MODE_STREAM) {
      try {
        try {
          // sleep a little bit to avoid threading and nullpointer
          // issues when reconnecting.
          _myThread.sleep(500);
        } catch (final Exception e) {

        }

        final InputStream in = _mySocket.getInputStream();
        while (!_mySocket.isClosed() && _mySocket != null) {
          final int myLen = Bytes.toIntBigEndian(in);
          if (myLen < 0) {
            break;
          }
          _myBytes = Bytes.toByteArray(in, myLen);
          handleInput();
        }
      } catch (final java.net.SocketException se) {
        System.out.println("Connection reset.");
      } catch (final Exception e) {
        System.out.println("### EXCEPTION " + e);
      }
      try {
        handleStatus(NetStatus.SERVER_CLOSED);
        handleStatus(NetStatus.CONNECTION_TERMINATED);
        dispose();
      } catch (final NullPointerException e) {
        System.out.println("### nullpointer while calling handleStatus.");
      }
    } else {
      while (Thread.currentThread() == _myThread) {
        switch (_myMode) {
        case (MODE_TERMINATED):
          read();
          break;
        case (MODE_READLINE):
        default:
          readline();
          break;
        }
        break;
      }
    }
    if (_myTcpServer != null) {
      _mySocket = null;
      _myTcpServer.remove(this);
    }
  }


  private void read() {
    try {
      _myInput = new BufferedReader(new InputStreamReader(_mySocket.getInputStream()));

      final char[] charBuffer = new char[1];
      while (_myInput.read(charBuffer, 0, 1) != -1) {

        /**@todo
         * StringBuffer size is limited yet.
         * increase the buffer size dynamically.
         */
        _myStringBuffer = new StringBuffer(4096);
        while (charBuffer[0] != TERMINATOR && charBuffer[0] != 3) {
          _myStringBuffer.append(charBuffer[0]);
          _myInput.read(charBuffer, 0, 1);
        }
        _myBytes = _myStringBuffer.toString().getBytes();
        handleInput();
      }
    } catch (final IOException e) {
      Logger.printProcess("TcpClient.read()", "connection has been terminated.");
      if (_myTcpServer == null) {
        handleStatus(NetStatus.SERVER_CLOSED);
      }
      handleStatus(NetStatus.CONNECTION_TERMINATED);
    }
  }


  private void readline() {
    try {
      _myOutput = new PrintWriter(_mySocket.getOutputStream(), true);
      _myInput = new BufferedReader(new InputStreamReader(_mySocket.getInputStream()));
      String inputLine;

      while ((inputLine = _myInput.readLine()) != null) {
        _myStringBuffer = new StringBuffer(inputLine);
        _myBytes = _myStringBuffer.toString().getBytes();
        handleInput();
      }
    } catch (final IOException e) {
      Logger.printProcess("TcpClient.readline()", "connection has been terminated.");
      handleStatus(NetStatus.CONNECTION_TERMINATED);
      if (_myTcpServer == null) {
        handleStatus(NetStatus.SERVER_CLOSED);
      }
    }
  }

  /**
   * @invisible
   */
  public abstract void handleInput();

  /**
   * @invisible
   * @param theIndex
   */
  public abstract void handleStatus(int theIndex);

  /**
   * @invisible
   * @return
   */
  public TcpPacketListener listener() {
    return _myTcpPacketListener;
  }

  /**
   * get the server port.
   * @return
   */
  public int serverport() {
    return _myServerPort;
  }

  /**
   * get the instance of the socket. more info at java.net.Socket
   * @return
   */
  public Socket socket() {
    return _mySocket;
  }

  
  /**
   * get the mode of the terminator. 
   * @return
   */
  public int mode() {
    return _myMode;
  }


  public String getString() {
    return _myStringBuffer.toString();
  }


  public StringBuffer getStringBuffer() {
    return _myStringBuffer;
  }


  public void send(final byte[] theBytes) {
    if (_myMode == MODE_STREAM) {
      try {
        Bytes.toStream(_myOutputStream, theBytes);
      } catch (final Exception ex) {
        handleStatus(NetStatus.SEND_FAILED);
      }
    } else {
      System.out.println("### sending bytes is only supported for STREAMs");
    }
  }


  public void send(final byte[][] theBytes) {
    if (_myMode == MODE_STREAM) {
      try {
        for (int i = 0; i < theBytes.length; i++) {
          Bytes.toStream(_myOutputStream, theBytes[i]);
        }
      } catch (final Exception ex) {
        handleStatus(NetStatus.SEND_FAILED);
      }
    } else {
      System.out.println("### sending bytes is only supported for STREAMs");
    }

  }


  public void send(final String theString) {
    if (_myMode == MODE_STREAM) {
      send(theString.getBytes());
    } else {
      switch (_myMode) {
      case (MODE_TERMINATED):
        _myOutput.write(theString + TERMINATOR);
        break;
      case (MODE_NEWLINE):
        _myOutput.write(theString + "\n");
        break;
      case (MODE_READLINE):
      default:
        _myOutput.println(theString);
        break;
      }
      _myOutput.flush();
    }
  }


  public NetAddress netAddress() {
    return _myNetAddress;
  }


  /**
   * @deprecated
   * @invisible
   * @return NetAddress
   */

  public NetAddress netaddress() {
    return _myNetAddress;
  }


  /**
   * @param theNetAddress NetAddress
   * @return boolean
   */
  public boolean equals(final NetAddress theNetAddress) {
    if (theNetAddress.address().equals(_myNetAddress.address()) &&
        theNetAddress.port() == _myNetAddress.port()) {
      return true;
    }
    return false;
  }


  public boolean equals(final TcpClient theClient) {
    return equals(theClient.netAddress());
  }

}
