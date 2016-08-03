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
import java.net.ServerSocket;
import java.util.Enumeration;
import java.util.Vector;

/**
 * @invisible
 */

public abstract class AbstractTcpServer implements Runnable, TcpPacketListener {

	protected ServerSocket _myServerSocket;

	protected static int _myPort;

	protected TcpPacketListener _myTcpPacketListener = null;

	protected Vector _myTcpClients;

	protected Thread _myThread;

	public final static int MODE_READLINE = TcpClient.MODE_READLINE;

	public final static int MODE_TERMINATED = TcpClient.MODE_TERMINATED;

	public final static int MODE_NEWLINE = TcpClient.MODE_NEWLINE;

	public final static int MODE_STREAM = TcpClient.MODE_STREAM;

	protected final int _myMode;

	protected Vector _myBanList;

	/**
	 * @invisible
	 * @param thePort
	 *            int
	 * @param theMode
	 *            int
	 */
	public AbstractTcpServer(
			final int thePort, 
			final int theMode) {
		_myPort = thePort;
		_myMode = theMode;
		_myTcpPacketListener = this;
		init();
	}

	/**
	 * @invisible
	 * @param theTcpPacketListener
	 *            TcpPacketListener
	 * @param thePort
	 *            int
	 * @param theMode
	 *            int
	 */
	public AbstractTcpServer(
			final TcpPacketListener theTcpPacketListener,
			final int thePort, 
			final int theMode) {
		_myPort = thePort;
		_myMode = theMode;
		_myTcpPacketListener = theTcpPacketListener;
		init();
	}

	protected void init() {
		_myBanList = new Vector();
		_myServerSocket = null;
		_myTcpClients = new Vector();
		try {
			Thread.sleep(1000);
		} catch (InterruptedException iex) {
			Logger.printError("TcpServer.start()",
					"TcpServer sleep interuption " + iex);
			return;
		}
		try {
			_myServerSocket = new ServerSocket(_myPort);
		} catch (IOException e) {
			Logger.printError("TcpServer.start()", "TcpServer io Exception "
					+ e);
			return;
		}

		_myThread = new Thread(this);
		_myThread.start();
		Logger.printProcess("TcpServer", "ServerSocket started @ " + _myPort);
	}

	/**
	 * ban an IP address from the server.
	 * @param theIP
	 */
	public void ban(String theIP) {
		_myBanList.add(theIP);
		for (int i = _myTcpClients.size() - 1; i >= 0; i--) {
			if (((TcpClient) _myTcpClients.get(i)).netAddress().address()
					.equals(theIP)) {
				((TcpClient) _myTcpClients.get(i)).dispose();
			}
		}
	}

	/**
	 * remove the ban for an IP address.
	 * @param theIP
	 */
	public void unBan(String theIP) {
		_myBanList.remove(theIP);
	}
	

	private boolean checkBanList(ServerSocket theSocket) {
		try {
			String mySocketAddress = theSocket.getInetAddress()
					.getHostAddress();
			String mySocketName = theSocket.getInetAddress().getHostName();
			for (int i = _myBanList.size() - 1; i >= 0; i--) {
				if (mySocketAddress.equals(_myBanList.get(i))
						|| mySocketName.equals(_myBanList.get(i))) {
					return false;
				}
			}
			return true;
		} catch (Exception e) {
		}
		return false;
	}

	/**
	 * get the server socket object. more at java.net.ServerSocket
	 * @return
	 */
	public ServerSocket socket() {
		return _myServerSocket;
	}

	/**
	 * @invisible
	 */
	public void run() {
		threadLoop: while (Thread.currentThread() == _myThread) {
			try {
				/**
				 * @author when synchronized, disconnected clients are only
				 *         removed from _myTcpClients when there is a new
				 *         connection.
				 */
				// synchronized(_myTcpClients) {
				if (checkBanList(_myServerSocket)) {
					TcpClient t = new TcpClient(this, _myServerSocket.accept(),
							_myTcpPacketListener, _myPort, _myMode);
					if (NetP5.DEBUG) {
						System.out.println("### new Client @ " + t);
					}
					_myTcpClients.addElement(t);
					Logger.printProcess("TcpServer.run", _myTcpClients.size()
							+ " currently running.");
				}
			}
			// }
			catch (IOException e) {
				Logger.printError("TcpServer", "IOException. Stopping server.");
				break threadLoop;
			}
		}
		dispose();
	}

	/**
	 * send a string to the connected client(s).
	 * @param theString
	 */
	public synchronized void send(final String theString) {
		try {
			Enumeration en = _myTcpClients.elements();
			while (en.hasMoreElements()) {
				((TcpClient) en.nextElement()).send(theString);
			}
		} catch (NullPointerException e) {

		}
	}

	/**
	 * send a byte array to the connected client(s).
	 * @param theBytes
	 */
	public synchronized void send(final byte[] theBytes) {
		try {
			Enumeration en = _myTcpClients.elements();
			while (en.hasMoreElements()) {
				((TcpClient) en.nextElement()).send(theBytes);
			}
		} catch (NullPointerException e) {

		}
	}

	/**
	 * kill the server.
	 */
	public void dispose() {
		try {
			_myThread = null;

			if (_myTcpClients != null) {
				Enumeration en = _myTcpClients.elements();
				while (en.hasMoreElements()) {
					remove((TcpClient) en.nextElement());
				}
				_myTcpClients = null;
			}

			if (_myServerSocket != null) {
				_myServerSocket.close();
				_myServerSocket = null;
			}
		} catch (IOException e) {
			Logger.printError("TcpServer.dispose", "IOException " + e);
		}
	}

	/**
	 * get the number of connected clients.
	 * @return
	 */
	public int size() {
		return _myTcpClients.size();
	}

	/**
	 * get a list of all connected clients. an array of type TcpClient[]
	 * will be returned.
	 * @return
	 */
	public TcpClient[] getClients() {
		TcpClient[] s = new TcpClient[_myTcpClients.size()];
		_myTcpClients.toArray(s);
		return s;
	}

	/**
	 * get a client at a specific position the client list.
	 * @param theIndex
	 * @return
	 */
	public TcpClient getClient(final int theIndex) {
		return (TcpClient) _myTcpClients.elementAt(theIndex);
	}

	/**
	 * @invisible
	 * @param thePacket
	 *            TcpPacket
	 * @param thePort
	 *            int
	 */
	public void process(final TcpPacket thePacket, final int thePort) {
		handleInput(thePacket, thePort);
	}

	/**
	 * @invisible
	 * @param thePacket
	 *            TcpPacket
	 * @param thePort
	 *            int
	 */
	public abstract void handleInput(final TcpPacket thePacket,
			final int thePort);

	/**
	 * remove a TcpClient from the server's client list.
	 * @param theTcpClient
	 *            TCPClientAbstract
	 */
	public void remove(AbstractTcpClient theTcpClient) {
		if (_myTcpPacketListener != null && !_myTcpPacketListener.equals(this)) {
			_myTcpPacketListener.remove(theTcpClient);
		}
		theTcpClient.dispose();
		_myTcpClients.removeElement(theTcpClient);
		Logger.printProcess("TcpServer", "removing TcpClient.");
	}

}
