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

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Vector;

import netP5.AbstractTcpClient;
import netP5.Logger;
import netP5.NetAddress;
import netP5.NetAddressList;
import netP5.NetInfo;
import netP5.TcpClient;
import netP5.TcpPacket;
import netP5.TcpPacketListener;
import netP5.TcpServer;
import netP5.UdpPacketListener;

/**
 * oscP5 is an osc implementation for the programming environment processing.
 * osc is the acronym for open sound control, a network protocol developed at
 * cnmat, uc berkeley. open sound control is a protocol for communication among
 * computers, sound synthesizers, and other multimedia devices that is optimized
 * for modern networking technology and has been used in many application areas.
 * for further specifications and application implementations please visit the
 * official osc site.
 * 
 * @usage Application
 * @example oscP5sendReceive
 * @related OscProperties
 * @related OscMessage
 * @related OscBundle
 */

/**
 * TODO add better error message handling for oscEvents, see this post
 * http://forum.processing.org/topic/oscp5-major-problems-with-error-handling# 25080000000811163
 */
public class OscP5 implements UdpPacketListener, TcpPacketListener {

	/*
	 * @TODO implement polling option to avoid threading and synchronization
	 * issues. check email from tom lieber. look into mutex objects.
	 * http://www.google.com/search?hl=en&q=mutex+java&btnG=Search
	 */

	// protected ArrayList _myOscPlugList = new ArrayList();

	protected HashMap<String, ArrayList<OscPlug>> _myOscPlugMap = new HashMap<String, ArrayList<OscPlug>>();

	protected NetInfo _myNetInfo;

	private OscNetManager _myOscNetManager;

	protected final static int NONE = OscNetManager.NONE;

	public final static boolean ON = OscProperties.ON;

	public final static boolean OFF = OscProperties.OFF;

	/**
	 * a static variable used when creating an oscP5 instance with a sepcified network protocol.
	 */
	public final static int UDP = OscProperties.UDP;

	/**
	 * a static variable used when creating an oscP5 instance with a sepcified network protocol.
	 */
	public final static int MULTICAST = OscProperties.MULTICAST;

	/**
	 * a static variable used when creating an oscP5 instance with a sepcified network protocol.
	 */
	public final static int TCP = OscProperties.TCP;

	protected final Object parent;

	private OscProperties _myOscProperties;

	private Class<?> _myParentClass;

	private Method _myEventMethod;

	private Class<?> _myEventClass = OscMessage.class;

	private boolean isEventMethod;

	private boolean isBroadcast = false;

	private NetAddress _myBroadcastAddress;

	private boolean isOscIn = false;

	/**
	 * @invisible
	 */
	public static final String VERSION = "0.9.9";


	/**
	 * @param theParent Object
	 * @param theProperties OscProperties
	 * @usage Application
	 */
	public OscP5(final Object theParent, final OscProperties theProperties) {
		welcome();
		parent = theParent;

		registerDispose(parent);

		_myOscProperties = theProperties;
		_myOscNetManager = new OscNetManager();
		_myOscNetManager.start(_myOscProperties);
		if (_myOscProperties.networkProtocol() == OscProperties.TCP) {
			_myOscNetManager.addTcpListener(this);
		}
		else {
			_myOscNetManager.addUdpListener(this);
		}
		isEventMethod = checkEventMethod();
		if (_myOscProperties.networkProtocol() == OscProperties.MULTICAST) {
			Logger.printInfo("OscP5", "is joining a multicast group @ " + _myOscProperties.remoteAddress().address() + ":" + _myOscProperties.remoteAddress().port());
		}
		else {
			Logger.printInfo("OscP5", "is running. you (" + ip() + ") are listening @ port " + _myOscProperties.remoteAddress().port());
		}
	}


	/**
	 * @param theParent Object
	 * @param theAddress String
	 * @param thePort int
	 * @param theMode int
	 * @usage Application
	 */
	public OscP5(final Object theParent, final String theAddress, final int thePort, final int theMode) {
		welcome();
		parent = theParent;
		_myOscProperties = new OscProperties();

		registerDispose(parent);

		switch (theMode) {
		case (MULTICAST):
			_myOscProperties.setNetworkProtocol(MULTICAST);
			_myOscProperties.setRemoteAddress(theAddress, thePort);
			_myOscProperties.setListeningPort(thePort);
			_myOscNetManager = new OscNetManager();
			_myOscNetManager.start(_myOscProperties);
			_myOscNetManager.addUdpListener(this);
			Logger.printInfo("OscP5", "is joining a multicast group @ " + _myOscProperties.remoteAddress().address() + ":" + _myOscProperties.remoteAddress().port());
			break;
		case (UDP):
			_myOscProperties.setRemoteAddress(theAddress, thePort);
			initUDP(thePort);
			break;
		case (TCP):
			_myOscProperties.setNetworkProtocol(TCP);
			_myOscProperties.setRemoteAddress(theAddress, thePort);
			_myOscNetManager = new OscNetManager();
			_myOscNetManager.start(_myOscProperties);
			_myOscNetManager.addTcpListener(this);
			break;
		}
		isEventMethod = checkEventMethod();
	}


	public OscP5(final Object theParent, final int theReceiveAtPort, final int theMode) {
		welcome();
		parent = theParent;

		registerDispose(parent);

		_myOscProperties = new OscProperties();
		switch (theMode) {
		case (UDP):
			initUDP(theReceiveAtPort);
			break;
		case (TCP):
			_myOscProperties.setNetworkProtocol(TCP);
			_myOscProperties.setListeningPort(theReceiveAtPort);
			_myOscNetManager = new OscNetManager();
			_myOscNetManager.start(_myOscProperties);
			_myOscNetManager.addTcpListener(this);
			break;
		case (MULTICAST):
			Logger.printWarning("OscP5", "please specify a multicast address. use " + "OscP5(Object theObject, String theMulticastAddress, int thePort, int theMode)");
			break;
		}
		isEventMethod = checkEventMethod();
	}


	/**
	 * @param theParent Object
	 * @param theReceiveAtPort int
	 * @usage Application
	 */
	public OscP5(final Object theParent, final int theReceiveAtPort) {
		welcome();
		parent = theParent;

		registerDispose(parent);

		initUDP(theReceiveAtPort);
		isEventMethod = checkEventMethod();
	}


	private void welcome() {
		System.out.println("OscP5 " + VERSION + " " + "infos, comments, questions at http://www.sojamo.de/oscP5\n\n");
	}


	private void registerDispose(Object theObject) {
		try {
			Object parent = null;
			String child = "processing.core.PApplet";
			try {
				Class<?> childClass = Class.forName(child);
				Class<?> parentClass = Object.class;

				if (parentClass.isAssignableFrom(childClass)) {
					parent = childClass.newInstance();
					parent = theObject;
				}
			} catch (Exception e) {
				// System.out.println(e);
			}
			try {
				Method method = parent.getClass().getMethod("registerDispose", Object.class);
				try {
					method.invoke(parent, new Object[] { this });
				} catch (IllegalArgumentException e) {
					// System.out.println(e);
				} catch (IllegalAccessException e) {
					// System.out.println(e);
				} catch (InvocationTargetException e) {
					// System.out.println(e);
				}
			} catch (SecurityException e) {
				// System.out.println("fail (1) " + e);
			} catch (NoSuchMethodException e) {
				// System.out.println("fail (2) " + e);
			}
		} catch (NullPointerException e) {
			System.err.println("Register Dispose\n" + e);
		}
	}


	private void initUDP(final int theReceiveAtPort) {
		_myOscProperties = new OscProperties();
		_myOscProperties.setListeningPort(theReceiveAtPort);
		_myOscNetManager = new OscNetManager();
		_myOscNetManager.start(_myOscProperties);
		_myOscNetManager.addUdpListener(this);
		Logger.printInfo("OscP5", "is running. you (" + ip() + ") are listening @ port " + theReceiveAtPort);
	}


	/**
	 * check which eventMethod exists in the Object oscP5 was started from. this is necessary for
	 * backwards compatibility for oscP5 because the previous parameterType for the eventMethod was
	 * OscIn and is now OscMessage.
	 * 
	 * @return boolean
	 * @invisible
	 */
	private boolean checkEventMethod() {
		_myParentClass = parent.getClass();
		try {
			Method[] myMethods = _myParentClass.getDeclaredMethods();
			for (int i = 0; i < myMethods.length; i++) {
				if (myMethods[i].getName().indexOf(_myOscProperties.eventMethod()) != -1) {
					Class<?>[] myClasses = myMethods[i].getParameterTypes();
					if (myClasses.length == 1) {
						_myEventClass = myClasses[0];
						isOscIn = ((_myEventClass.toString()).indexOf("OscIn") != -1) ? true : false;
						break;
					}
				}
			}

		} catch (Throwable e) {
			System.err.println(e);
		}

		String tMethod = _myOscProperties.eventMethod();
		if (tMethod != null) {
			try {
				Class<?>[] tClass = { _myEventClass };
				_myEventMethod = _myParentClass.getDeclaredMethod(tMethod, tClass);
				_myEventMethod.setAccessible(true);
				return true;
			} catch (SecurityException e1) {
				// e1.printStackTrace();
				Logger.printWarning("OscP5.plug", "### security issues in OscP5.checkEventMethod(). (this occures when running in applet mode)");
			} catch (NoSuchMethodException e1) {
			}
		}
		// online fix, since an applet throws a security exception when calling
		// setAccessible(true);
		if (_myEventMethod != null) {
			return true;
		}
		return false;
	}


	/**
	 * get the current version of oscP5.
	 * 
	 * @return String
	 */
	public String version() {
		return VERSION;
	}


	/**
	 * @invisible
	 */
	public void dispose() {
		stop();
	}


	public void addListener(OscEventListener theListener) {
		_myOscProperties.listeners().add(theListener);
	}


	public void removeListener(OscEventListener theListener) {
		_myOscProperties.listeners().remove(theListener);
	}


	public Vector<OscEventListener> listeners() {
		return _myOscProperties.listeners();
	}


	/**
	 * osc messages can be automatically forwarded to a specific method of an object. the plug
	 * method can be used to by-pass parsing raw osc messages - this job is done for you with the
	 * plug mechanism. you can also use the following array-types int[], float[], String[]. (but
	 * only as on single parameter e.g. somemethod(int[] theArray) {} ).
	 * 
	 * @param theObject Object, can be any Object
	 * @param theMethodName String, the method name an osc message should be forwarded to
	 * @param theAddrPattern String, the address pattern of the osc message
	 * @param theTypeTag String
	 * @example oscP5plug
	 * @usage Application
	 */
	public void plug(final Object theObject, final String theMethodName, final String theAddrPattern, final String theTypeTag) {
		final OscPlug myOscPlug = new OscPlug();
		myOscPlug.plug(theObject, theMethodName, theAddrPattern, theTypeTag);
		// _myOscPlugList.add(myOscPlug);
		if (_myOscPlugMap.containsKey(theAddrPattern)) {
			_myOscPlugMap.get(theAddrPattern).add(myOscPlug);
		}
		else {
			ArrayList<OscPlug> myOscPlugList = new ArrayList<OscPlug>();
			myOscPlugList.add(myOscPlug);
			_myOscPlugMap.put(theAddrPattern, myOscPlugList);
		}
	}


	/**
	 * @param theObject Object, can be any Object
	 * @param theMethodName String, the method name an osc message should be forwarded to
	 * @param theAddrPattern String, the address pattern of the osc message
	 * @example oscP5plug
	 * @usage Application
	 */
	public void plug(final Object theObject, final String theMethodName, final String theAddrPattern) {
		final Class<?> myClass = theObject.getClass();
		final Method[] myMethods = myClass.getDeclaredMethods();
		Class<?>[] myParams = null;
		for (int i = 0; i < myMethods.length; i++) {
			String myTypetag = "";
			try {
				myMethods[i].setAccessible(true);
			} catch (Exception e) {
			}
			if ((myMethods[i].getName()).equals(theMethodName)) {
				myParams = myMethods[i].getParameterTypes();
				OscPlug myOscPlug = new OscPlug();
				for (int j = 0; j < myParams.length; j++) {
					myTypetag += myOscPlug.checkType(myParams[j].getName());
				}

				myOscPlug.plug(theObject, theMethodName, theAddrPattern, myTypetag);
				// _myOscPlugList.add(myOscPlug);
				if (_myOscPlugMap.containsKey(theAddrPattern)) {
					_myOscPlugMap.get(theAddrPattern).add(myOscPlug);
				}
				else {
					ArrayList<OscPlug> myOscPlugList = new ArrayList<OscPlug>();
					myOscPlugList.add(myOscPlug);
					_myOscPlugMap.put(theAddrPattern, myOscPlugList);
				}

			}
		}
	}


	private void handleSystemMessage(final OscMessage theOscMessage) {
		if (theOscMessage.addrPattern().startsWith("/sys/ping")) {
			send("/sys/pong", new Object[0], _myBroadcastAddress);
		}
		else if (theOscMessage.addrPattern().startsWith("/sys/register")) {
			if (theOscMessage.tcpConnection() != null) {
				if (theOscMessage.checkTypetag("s")) {
					theOscMessage.tcpConnection().setName(theOscMessage.get(0).stringValue());
				}
			}
		}
	}


	private void callMethod(final OscMessage theOscMessage) {

		if (theOscMessage.addrPattern().startsWith("/sys/")) {
			handleSystemMessage(theOscMessage);
			// finish this for oscbroadcaster
			// return;
		}

		// forward the message to all OscEventListeners
		for (int i = listeners().size() - 1; i >= 0; i--) {
			((OscEventListener) listeners().get(i)).oscEvent(theOscMessage);
		}

		/* check if the arguments can be forwarded as array */

		if (theOscMessage.isArray) {
			// for (int i = 0; i < _myOscPlugList.size(); i++) {
			// OscPlug myPlug = ((OscPlug) _myOscPlugList.get(i));
			// if (myPlug.isArray && myPlug.checkMethod(theOscMessage, true)) {
			// invoke(myPlug.getObject(), myPlug.getMethod(),
			// theOscMessage.argsAsArray());
			// }
			// }

			if (_myOscPlugMap.containsKey(theOscMessage.addrPattern())) {
				ArrayList<OscPlug> myOscPlugList = _myOscPlugMap.get(theOscMessage.addrPattern());
				for (int i = 0; i < myOscPlugList.size(); i++) {
					OscPlug myPlug = (OscPlug) myOscPlugList.get(i);
					if (myPlug.isArray && myPlug.checkMethod(theOscMessage, true)) {
						// Should we set the following here? The old code did
						// not:
						// theOscMessage.isPlugged = true;
						invoke(myPlug.getObject(), myPlug.getMethod(), theOscMessage.argsAsArray());
					}
				}
			}

		}
		/* check if there is a plug method for the current message */
		// for (int i = 0; i < _myOscPlugList.size(); i++) {
		// OscPlug myPlug = ((OscPlug) _myOscPlugList.get(i));
		// if (!myPlug.isArray && myPlug.checkMethod(theOscMessage, false)) {
		// theOscMessage.isPlugged = true;
		// invoke(myPlug.getObject(), myPlug.getMethod(), theOscMessage
		// .arguments());
		// }
		// }

		if (_myOscPlugMap.containsKey(theOscMessage.addrPattern())) {
			ArrayList<OscPlug> myOscPlugList = _myOscPlugMap.get(theOscMessage.addrPattern());
			for (int i = 0; i < myOscPlugList.size(); i++) {
				OscPlug myPlug = (OscPlug) myOscPlugList.get(i);
				if (!myPlug.isArray && myPlug.checkMethod(theOscMessage, false)) {
					theOscMessage.isPlugged = true;
					invoke(myPlug.getObject(), myPlug.getMethod(), theOscMessage.arguments());
				}
			}
		}

		/* if no plug method was detected, then use the default oscEvent mehtod */
		Logger.printDebug("OscP5.callMethod ", "" + isEventMethod);
		if (isEventMethod) {
			try {
				if (isOscIn) {
					invoke(parent, _myEventMethod, new Object[] { new OscIn(theOscMessage) });
					Logger.printDebug("OscP5.callMethod ", "invoking OscIn " + isEventMethod);
				}
				else {
					invoke(parent, _myEventMethod, new Object[] { theOscMessage });
					Logger.printDebug("OscP5.callMethod ", "invoking OscMessage " + isEventMethod);
				}
			} catch (ClassCastException e) {
				Logger.printError("OscHandler.callMethod", " ClassCastException." + e);
			}
		}
	}


	private void invoke(final Object theObject, final Method theMethod, final Object[] theArgs) {
		try {
			theMethod.invoke(theObject, theArgs);
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			Logger.printError("OscP5", "ERROR. an error occured while forwarding an OscMessage\n " + "to a method in your program. please check your code for any \n"
					+ "possible errors that might occur in the method where incoming\n " + "OscMessages are parsed e.g. check for casting errors, possible\n "
					+ "nullpointers, array overflows ... .\n" + "method in charge : " + theMethod.getName() + "  " + e);
		}
	}


	/**
	 * incoming osc messages from an udp socket are parsed, processed and forwarded to the parent.
	 * 
	 * @invisible
	 * @param thePacket DatagramPacket
	 * @param thePort int
	 */
	public void process(final DatagramPacket thePacket, final int thePort) {
		synchronized (this) {
			OscPacket p = OscPacket.parse(thePacket);
			if (p.isValid()) {
				if (p.type() == OscPacket.BUNDLE) {
					for (int i = 0; i < ((OscBundle) p).size(); i++) {
						callMethod(((OscBundle) p).getMessage(i));
					}
				}
				else {
					callMethod((OscMessage) p);
				}
			}
			notifyAll();
		}
	}


	/**
	 * @invisible
	 * @see netP5.TcpPacketListener#process(netP5.TcpPacket, int)
	 */
	public void process(final TcpPacket thePacket, final int thePort) {
		synchronized (this) {
			OscPacket p = OscPacket.parse(thePacket);
			if (p.isValid()) {
				if (p.type() == OscPacket.BUNDLE) {
					for (int i = 0; i < ((OscBundle) p).size(); i++) {
						callMethod(((OscBundle) p).getMessage(i));
					}
				}
				else {
					callMethod((OscMessage) p);
				}
			}
			notifyAll();
		}
	}


	/**
	 * @invisible
	 * @param theTcpClient AbstractTcpClient
	 */
	public void remove(AbstractTcpClient theTcpClient) {
	}


	/**
	 * @invisible
	 * @param theIndex int
	 */
	public void status(int theIndex) {
	}


	/**
	 * returns the current properties of oscP5.
	 * 
	 * @return OscProperties
	 * @related OscProperties
	 * @usage Application
	 */
	public OscProperties properties() {
		return _myOscProperties;
	}


	/**
	 * @invisible
	 * @return boolean
	 */
	public boolean isBroadcast() {
		return isBroadcast;
	}


	/**
	 * @return String
	 * @invisible
	 */
	public String ip() {
		return NetInfo.getHostAddress();
	}


	/**
	 * oscP5 has a logging mechanism which prints out processes, warnings and errors into the
	 * console window. e.g. turn off the error log with setLogStatus(Logger.ERROR, Logger.OFF);
	 * 
	 * @param theIndex int
	 * @param theValue int
	 * @usage Application
	 */
	public static void setLogStatus(final int theIndex, final int theValue) {
		Logger.set(theIndex, theValue);
	}


	/**
	 * @param theValue
	 */
	public static void setLogStatus(final int theValue) {
		for (int i = 0; i < Logger.ALL; i++) {
			Logger.set(i, theValue);
		}
	}


	/**
	 * set timeToLive of a multicast packet.
	 * 
	 * @param theTTL int
	 */
	public void setTimeToLive(int theTTL) {
		_myOscNetManager.setTimeToLive(theTTL);
	}


	/**
	 * @param theHost NetAddress
	 * @invisible
	 */
	public void disconnect(final NetAddress theHost) {
		if (theHost.isvalid() && theHost.name.length() > 1) {
			String myAddrPattern = "/sys/disconnect/" + theHost.name + "/" + theHost.port();
			send(myAddrPattern, new Object[0], theHost);
			isBroadcast = false;
			_myBroadcastAddress = null;
		}
	}


	/**
	 * @param theNetAddress NetAddress
	 * @param theName String
	 * @param theArguments String[]
	 * @invisible
	 */
	public void connect(final NetAddress theNetAddress, final String theName, final String[] theArguments) {
		if (theNetAddress.isvalid()) {
			_myBroadcastAddress = theNetAddress;
			_myBroadcastAddress.name = theName;
			String myAddrPattern = "/sys/connect/" + theName + "/" + _myOscProperties.listeningPort();
			send(myAddrPattern, theArguments, _myBroadcastAddress);
			isBroadcast = true;
		}
	}


	/**
	 * netinfo() returns an instance of a NetInfo Object from which you can get LAN and WAN
	 * information.
	 * 
	 * @return NetInfo
	 */
	public NetInfo netInfo() {
		return _myNetInfo;
	}


	/**
	 * return the instance of the running TCP server if in TCP mode.
	 * 
	 * @return TcpServer
	 */
	public TcpServer tcpServer() {
		return _myOscNetManager.tcpServer();
	}


	/**
	 * return the instance of the running TCP client if in TCP mode.
	 * 
	 * @return TcpClient
	 */
	public TcpClient tcpClient() {
		return _myOscNetManager.tcpClient();
	}


	/**
	 * you can send osc packets in many different ways. see below and use the send method that fits
	 * your needs.
	 * 
	 * 
	 * @param thePacket OscPacket
	 * @param theNetAddress NetAddress
	 * @usage Application
	 */
	public void send(final OscPacket thePacket, final NetAddress theNetAddress) {
		_myOscNetManager.send(thePacket, theNetAddress);
	}


	/**
	 * @param thePacket OscPacket
	 * @usage Application
	 * @example oscP5sendReceive
	 */
	public void send(final OscPacket thePacket) {
		_myOscNetManager.send(thePacket);
	}


	/**
	 * @param thePacket OscPacket
	 * @param theNetAddressList NetAddressList
	 * @usage Application
	 */
	public void send(final OscPacket thePacket, final NetAddressList theNetAddressList) {
		_myOscNetManager.send(thePacket, theNetAddressList);
	}


	/**
	 * @param theAddrPattern String
	 * @param theArguments Object[]
	 * @usage Application
	 */
	public void send(final String theAddrPattern, final Object[] theArguments) {
		_myOscNetManager.send(theAddrPattern, theArguments);
	}


	/**
	 * @param theAddrPattern String
	 * @param theArguments Object[]
	 * @param theNetAddressList NetAddressList
	 * @usage Application
	 */
	public void send(final String theAddrPattern, final Object[] theArguments, final NetAddressList theNetAddressList) {
		_myOscNetManager.send(theAddrPattern, theArguments, theNetAddressList);
	}


	/**
	 * @param theAddrPattern String
	 * @param theArguments Object[]
	 * @param theNetAddress NetAddress
	 * @usage Application
	 */
	public void send(final String theAddrPattern, final Object[] theArguments, final NetAddress theNetAddress) {
		_myOscNetManager.send(theAddrPattern, theArguments, theNetAddress);
	}


	/**
	 * @param theAddrPattern String
	 * @param theArguments Object[]
	 * @param theNetAddress NetAddress
	 * @usage Application
	 */
	public void send(final String theAddrPattern, final Object[] theArguments, final String theAddress, int thePort) {
		_myOscNetManager.send(theAddrPattern, theArguments, theAddress, thePort);
	}


	/**
	 * send to tcp client
	 * 
	 * @param thePacket OscPacket
	 * @param theClient TcpClient
	 */
	public void send(final OscPacket thePacket, final TcpClient theClient) {
		theClient.send(thePacket.getBytes());
	}


	/**
	 * @param theAddrPattern String
	 * @param theArguments Object[]
	 * @param theClient TcpClient
	 */
	public void send(final String theAddrPattern, final Object[] theArguments, final TcpClient theClient) {
		send(new OscMessage(theAddrPattern, theArguments), theClient);
	}


	/**
	 * the send method offers a lot of possibilities. have a look at the send documentation.
	 * 
	 * @param thePacket OscPacket
	 * @param theIpAddress String
	 * @param thePort int
	 * @usage Application
	 * @deprecated
	 */
	public void send(final OscPacket thePacket, final String theIpAddress, final int thePort) {
		_myOscNetManager.send(thePacket, theIpAddress, thePort);
	}


	/**
	 * stop oscP5 and close open Sockets.
	 */
	public void stop() {
		Logger.printDebug("OscP5.stop", "starting to stop oscP5.");
		_myOscNetManager.stop();
		Logger.printDebug("OscP5.stop", "stopping oscP5.");
	}


	/**
	 * a static method to send an OscMessage straight out of the box without having to instantiate
	 * oscP5.
	 * 
	 * @param theOscMessage OscMessage
	 * @param theNetAddress NetAddress
	 * @example oscP5flush
	 */
	public static void flush(final OscMessage theOscMessage, final NetAddress theNetAddress) {
		flush(theOscMessage.getBytes(), theNetAddress);
	}


	public static void flush(final OscPacket theOscPacket, final NetAddress theNetAddress) {
		flush(theOscPacket.getBytes(), theNetAddress);
	}


	public static void flush(final String theAddrPattern, final Object[] theArguments, final NetAddress theNetAddress) {
		flush((new OscMessage(theAddrPattern, theArguments)).getBytes(), theNetAddress);
	}


	public static void flush(final byte[] theBytes, final NetAddress theNetAddress) {
		DatagramSocket mySocket;
		try {
			mySocket = new DatagramSocket();

			DatagramPacket myPacket = new DatagramPacket(theBytes, theBytes.length, theNetAddress.inetaddress(), theNetAddress.port());
			mySocket.send(myPacket);
		} catch (SocketException e) {
			Logger.printError("OscP5.openSocket", "cant create socket " + e.getMessage());
		} catch (IOException e) {
			Logger.printError("OscP5.openSocket", "cant create multicastSocket " + e.getMessage());
		}
	}


	/*
	 * DEPRECATED methods and constructors.
	 */

	/**
	 * @param theBytes byte[]
	 * @param theAddress String
	 * @param thePort int
	 * @deprecated
	 */
	public static void flush(final byte[] theBytes, final String theAddress, final int thePort) {
		flush(theBytes, new NetAddress(theAddress, thePort));
	}


	/**
	 * @param theOscMessage OscMessage
	 * @param theAddress String
	 * @param thePort int
	 * @deprecated
	 */
	public static void flush(final OscMessage theOscMessage, final String theAddress, final int thePort) {
		flush(theOscMessage.getBytes(), new NetAddress(theAddress, thePort));
	}


	/**
	 * old version of constructor. still in here for backwards compatibility.
	 * 
	 * @deprecated
	 * @invisible
	 */
	public OscP5(final Object theParent, final String theHost, final int theSendToPort, final int theReceiveAtPort, final String theMethodName) {
		welcome();
		parent = theParent;

		registerDispose(parent);

		_myOscProperties = new OscProperties();
		_myOscProperties.setRemoteAddress(theHost, theSendToPort);
		_myOscProperties.setListeningPort(theReceiveAtPort);
		_myOscProperties.setEventMethod(theMethodName);
		_myOscNetManager = new OscNetManager();
		_myOscNetManager.start(_myOscProperties);
		_myOscNetManager.addUdpListener(this);
		isEventMethod = checkEventMethod();
	}


	/**
	 * @deprecated
	 * @param theAddrPattern String
	 * @return OscMessage
	 * @invisible
	 */
	public OscMessage newMsg(String theAddrPattern) {
		return new OscMessage(theAddrPattern);
	}


	/**
	 * @deprecated
	 * @param theAddrPattern String
	 * @return OscMessage
	 * @invisible
	 */

	public OscBundle newBundle() {
		return new OscBundle();
	}


	/**
	 * used by the monome library by jklabs
	 * 
	 * @deprecated
	 * @invisible
	 */
	public void disconnectFromTEMP() {
	}


	/**
	 * @deprecated
	 * @param theParent Object
	 * @param theAddress String
	 * @param thePort int
	 */
	public OscP5(final Object theParent, final String theAddress, final int thePort) {
		this(theParent, theAddress, thePort, OscProperties.MULTICAST);
	}

}
