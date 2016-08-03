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
import java.net.UnknownHostException;


public abstract class AbstractUdpServer implements Runnable {

	private DatagramSocket _myDatagramSocket = null;

	protected UdpPacketListener _myListener;

	private Thread _myThread = null;

	private int _myPort;

	private String _myAddress;

	private InetAddress _myInetAddress;

	protected int _myDatagramSize = 1536; // common MTU

	private boolean isRunning = true;

	private boolean isSocket = false;

	/**
	 * create a new UdpServer
	 * 
	 * @invisible
	 * @param theListener
	 *            UdpPacketListener
	 * @param thePort
	 *            int
	 * @param theBufferSize
	 *            int
	 */
	public AbstractUdpServer(UdpPacketListener theListener, int thePort,
			int theBufferSize) {
		_myDatagramSize = theBufferSize;
		_myPort = thePort;
		_myListener = theListener;
		if (_myListener != null) {
			start();
		}
	}

	/**
	 * @invisible
	 * @param theListener
	 *            UdpPacketListener
	 * @param theAddress
	 *            String
	 * @param thePort
	 *            int
	 * @param theBufferSize
	 *            int
	 */
	protected AbstractUdpServer(UdpPacketListener theListener,
			String theAddress, int thePort, int theBufferSize) {
		_myDatagramSize = theBufferSize;
		_myAddress = theAddress;
		_myPort = thePort;
		_myListener = theListener;
		if (_myListener != null) {
			start();
		}
	}

	/**
	 * get the datagram socket of the UDP server.
	 * 
	 * @return DatagramSocket
	 */
	public DatagramSocket socket() {
		return _myDatagramSocket;
	}

	/**
	 * @invisible
	 * 
	 */
	public void start() {
		_myThread = null;
		_myDatagramSocket = null;
		_myThread = new Thread(this);
		try {
			Thread.sleep(1000);
		} catch (InterruptedException iex) {
			Logger.printError("UdpServer.start()",
					"oscServer sleep interruption " + iex);
		}
		try {
			_myDatagramSocket = new DatagramSocket(_myPort);
			_myInetAddress = InetAddress.getByName(_myAddress);
			Logger.printProcess("UdpServer.start()",
					"new Unicast DatagramSocket created @ port " + _myPort);
		} catch (IOException ioex) {
			Logger.printError("UdpServer.start()",
					" IOException, couldnt create new DatagramSocket @ port "
							+ _myPort + " " + ioex);
		}

		if (_myDatagramSocket != null) {
			_myThread.start();
			isRunning = _myThread.isAlive();
			isSocket = true;
		} else {
			isRunning = false;
		}
	}

	/**
	 * @invisible
	 */
	public void run() {
		if (_myDatagramSocket != null) {
			if (isRunning) {
				Logger.printProcess("UdpServer.run()",
						"UdpServer is running @ " + _myPort);
			}
		} else {
			Logger.printError("UdpServer.run()",
					"Socket is null. closing UdpServer.");
			return;
		}

		while (isRunning) {
			try {
				byte[] myBuffer = new byte[_myDatagramSize];
				DatagramPacket myPacket = new DatagramPacket(myBuffer,
						_myDatagramSize);
				_myDatagramSocket.receive(myPacket);
				_myListener.process(myPacket, _myPort);
			} catch (IOException ioex) {
				Logger.printProcess("UdpServer.run()", " socket closed.");
				break;
			} catch (ArrayIndexOutOfBoundsException ex) {
				Logger.printError("UdpServer.run()",
						"ArrayIndexOutOfBoundsException:  " + ex);
			}
		}
		dispose();
	}

	/**
	 * stop the UDP server, clean up and delete its reference.
	 */
	public void dispose() {
		isRunning = false;
		_myThread = null;
		if (_myDatagramSocket != null) {
			if (_myDatagramSocket.isConnected()) {
				Logger.printDebug("UdpServer.dispose()", "disconnect()");
				_myDatagramSocket.disconnect();
			}
			Logger.printDebug("UdpServer.dispose()", "close()");
			_myDatagramSocket.close();
			_myDatagramSocket = null;
			Logger.printDebug("UdpServer.dispose()",
					"Closing unicast datagram socket.");
		}
	}

	/**
	 * send a byte array to a previously defined remoteAddress.
	 * 
	 * @param theBytes
	 *            byte[]
	 */
	public void send(byte[] theBytes) {
		if (isSocket) {
			send(theBytes, _myInetAddress, _myPort);
		} else {
			Logger
					.printWarning("UdpClient.send",
							"no InetAddress and port has been set. Packet has not been sent.");
		}
	}

	/**
	 * send a byte array to a dedicated remoteAddress.
	 * 
	 * @param thePacket
	 *            OscPacket
	 * @param theAddress
	 *            String
	 * @param thePort
	 *            int
	 */
	public void send(byte[] theBytes, String theAddress, int thePort) {
		try {
			InetAddress myInetAddress = InetAddress.getByName(theAddress);
			send(theBytes, myInetAddress, thePort);
		} catch (UnknownHostException e) {
			Logger.printError("UdpClient.send", "while sending to "
					+ theAddress + " " + e);
		}
	}

	/**
	 * @invisible
	 * @param thePacket
	 *            DatagramPacket
	 */
	public void send(DatagramPacket thePacket) {
		if (isSocket) {
			try {
				_myDatagramSocket.send(thePacket);
			} catch (IOException e) {
				Logger.printError("UdpClient.send",
						"ioexception while sending packet.");
			}
		}
	}

	/**
	 * send a byte array to a dedicated remoteAddress.
	 * 
	 * @param theBytes
	 *            byte[]
	 * @param theAddress
	 *            InetAddress
	 * @param thePort
	 *            int
	 */
	public void send(byte[] theBytes, InetAddress theAddress, int thePort) {
		if (isSocket) {
			try {
				DatagramPacket myPacket = new DatagramPacket(theBytes,
						theBytes.length, theAddress, thePort);
				send(myPacket);
			} catch (NullPointerException npe) {
				Logger.printError("UdpServer.send",
						"a nullpointer exception occured." + npe);
			}
		} else {
			Logger.printWarning("UdpServer.send",
					"DatagramSocket is not running. Packet has not been sent.");
		}
	}

}
