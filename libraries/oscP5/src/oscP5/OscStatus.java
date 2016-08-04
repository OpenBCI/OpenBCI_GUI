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

public class OscStatus {


  public static int ERROR = -1;

  public static int DEFAULT = 0;

  public static int CONNECTION_CLOSED = 1;

  public static int CONNECTION_REFUSED = 2;

  public static int CONNECTION_TERMINATED = 4;

  public static int CONNECTION_FAILED = 8;

  public static int SERVER_CLOSED = 16;

  public static int CLIENT_CLOSED = 32;

  public static int SEND_FAILED = 64;

  public static int OSCP5_CLOSED = 1024;

  private int _myIndex = DEFAULT;


  public OscStatus(int theIndex) {
    _myIndex = theIndex;
  }


  public int id() {
    return _myIndex;
  }

}
