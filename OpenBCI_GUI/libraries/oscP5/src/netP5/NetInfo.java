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
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.StringTokenizer;


/**
 * some description
 * @author andreas schlegel
 */
public class NetInfo {

  public NetInfo() {
  }



  public static void print() {
    try {
      java.net.InetAddress i = java.net.InetAddress.getLocalHost();
      System.out.println("### hostname/ip " + i); // name and IP address
      System.out.println("### hostname " + i.getHostName()); // name
      System.out.println("### ip " + i.getHostAddress()); // IP address
      // only
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }



  public static String getHostAddress() {
    try {
      java.net.InetAddress i = java.net.InetAddress.getLocalHost();
      return i.getHostAddress();
    }
    catch (Exception e) {
    }
    return "ERROR";
  }



  public static String lan() {
    Logger.printProcess("NetInfo.checkNetworkStatus : ", getHostAddress());
    return getHostAddress();
  }



  public static String wan() {
    // create URL object.
    String myIp = null;
    URL u = null;
    String URLstring = "http://checkip.dyndns.org";
    boolean isConnectedToInternet = false;
    Logger.printProcess("NetInfo.checkNetworkStatus",
                        "Checking internet  connection ...");
    try {
      u = new URL(URLstring);
    }
    catch (MalformedURLException e) {
      Logger.printError("NetInfo.checkNetworkStatus", "Bad URL "
                        + URLstring + " " + e);
    }

    InputStream in = null;
    try {
      in = u.openStream();
      isConnectedToInternet = true;
    }
    catch (IOException e) {
      Logger.printError("NetInfo.checkNetworkStatus",
                        "! Unable to open  " + URLstring + "\n" + "Either the  "
                        + URLstring
                        + " is unavailable or this machine  is not"
                        + "connected to the internet !");
    }

    if (isConnectedToInternet) {
      try {
        BufferedReader br = new BufferedReader(
            new InputStreamReader(in));
        String line;
        String theToken = "";
        while ( (line = br.readLine()) != null) {
          theToken += line;
        }
        br.close();

        StringTokenizer st = new StringTokenizer(theToken, " <>", false);

        while (st.hasMoreTokens()) {
          String myToken = st.nextToken();
          if (myToken.compareTo("Address:") == 0) {
            myToken = st.nextToken();
            myIp = myToken;
            Logger.printProcess("NetInfo.checkNetworkStatus",
                                "WAN address : " + myIp);
          }
        }
      }
      catch (IOException e) {
        Logger.printError("NetInfo.checkNetworkStatus",
                          "I/O error reading  " + URLstring
                          + " Exception = " + e);
      }
    }
    return myIp;
  }



  /**
   *
   * @param args String[]
   * @invisible
   */
  public static void main(String[] args) {
    NetInfo.wan();
  }
}
