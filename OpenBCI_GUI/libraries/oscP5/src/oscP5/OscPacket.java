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
import java.net.InetAddress;
import netP5.Bytes;
import netP5.NetAddress;
import netP5.TcpPacket;
import netP5.TcpClient;

/**
 * @invisible
 */
public abstract class OscPacket extends OscPatcher {

    protected static final int MESSAGE = 0;


    protected static final int BUNDLE = 1;


    protected InetAddress inetAddress;


    protected String hostAddress;


    protected int _myType;


    protected TcpClient _myTcpClient = null;


    protected int port;

    /**
     * @invisible
     */
    public OscPacket() {}


    protected static OscPacket parse(DatagramPacket theDatagramPacket) {
        if (evaluatePacket(theDatagramPacket.getData()) == MESSAGE) {
            return new OscMessage(theDatagramPacket);
        } else {
            return new OscBundle(theDatagramPacket);
        }
    }


    protected static OscPacket parse(TcpPacket theTcpPacket) {
        if (evaluatePacket(theTcpPacket.getData()) == MESSAGE) {
            return new OscMessage(theTcpPacket);
        } else {
            return new OscBundle(theTcpPacket);
        }
    }


    private static int evaluatePacket(byte[] theBytes) {
        return (Bytes.areEqual(OscBundle.BUNDLE_AS_BYTES, Bytes.copy(theBytes, 0, OscBundle.BUNDLE_AS_BYTES.length))) ? BUNDLE
                : MESSAGE;
    }


    /**
     * when in TCP mode, tcpConnection() returns the instance of the TcpClient that has sent the OscMessage.
     * @return TcpClient
     */
    public TcpClient tcpConnection() {
        return _myTcpClient;
    }


    protected boolean isValid() {
        return isValid;
    }


    protected int type() {
        return _myType;
    }


    public int port() {
        return port;
    }


    public NetAddress netAddress() {
        return new NetAddress(inetAddress, port);
    }


    /**
     * @deprecated
     * @invisible
     * @return NetAddress
     */
    public NetAddress netaddress() {
        return new NetAddress(inetAddress, port);
    }


    /**
     * @return String
     */
    public String address() {
        return hostAddress;
    }


    /**
     * @return byte[]
     * @invisible
     */
    public abstract byte[] getBytes();

}
