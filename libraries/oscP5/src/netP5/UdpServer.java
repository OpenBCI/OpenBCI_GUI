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
import java.util.Vector;


/**
 *
 * @author andreas schlegel
 *
 */
public class UdpServer extends AbstractUdpServer implements UdpPacketListener {

    protected Object _myParent;

    protected NetPlug _myNetPlug;

    /**
     * new UDP server.
     * by default the buffersize of a udp packet is 1536 bytes. you can set
     * your own individual buffersize with the third parameter int in the constructor.
     * @param theObject Object
     * @param thePort int
     * @param theBufferSize int
     */
    public UdpServer(
    		final Object theObject,
    		final int thePort,
    		final int theBufferSize) {
        super(null, thePort, theBufferSize);
        _myParent = theObject;
        _myListener = this;
        _myNetPlug = new NetPlug(_myParent);
        start();
    }



    public UdpServer(
    		final Object theObject,
    		final int thePort) {
        super(null, thePort, 1536);
        _myParent = theObject;
        _myListener = this;
        _myNetPlug = new NetPlug(_myParent);
        start();
    }


    /**
     * @invisible
     * @param theListener
     * @param thePort
     * @param theBufferSize
     */
    public UdpServer(
    		final UdpPacketListener theListener,
    		final int thePort,
    		final int theBufferSize) {
        super(theListener, thePort, theBufferSize);
    }

    
    /**
     * @invisible
     * @param theListener
     * @param theAddress
     * @param thePort
     * @param theBufferSize
     */
    protected UdpServer(
    		final UdpPacketListener theListener,
    		final String theAddress,
    		final int thePort,
    		final int theBufferSize) {
        super(theListener, theAddress, thePort, theBufferSize);
    }


    /**
     * @invisible
     * @param thePacket DatagramPacket
     * @param thePort int
     */
    public void process(DatagramPacket thePacket, int thePort) {
        _myNetPlug.process(thePacket,thePort);
    }
    
    
	/**
	 * add a listener to the udp server. each incoming packet will be forwarded
	 * to the listener.
	 * @param theListener
	 * @related NetListener
	 */
	public void addListener(NetListener theListener) {
		_myNetPlug.addListener(theListener);
	}
	
	/**
	 * 
	 * @param theListener
	 * @related NetListener
	 */
	public void removeListener(NetListener theListener) {
		_myNetPlug.removeListener(theListener);
	}
	
	/**
	 * 
	 * @param theIndex
	 * @related NetListener
	 * @return
	 */
	public NetListener getListener(int theIndex) {
		return _myNetPlug.getListener(theIndex);
	}
	
	/**
	 * @related NetListener
	 * @return
	 */
	public Vector getListeners() {
		return _myNetPlug.getListeners();
	}
}
