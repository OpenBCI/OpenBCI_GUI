/**
 * oscP5tcp by andreas schlegel
 * example shows how to use the TCP protocol with oscP5.
 * what is TCP? http://en.wikipedia.org/wiki/Transmission_Control_Protocol
 * in this example both, a server and a client are used. typically 
 * this doesnt make sense as you usually wouldnt communicate with yourself
 * over a network. therefore this example is only to make it easier to 
 * explain the concept of using tcp with oscP5.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;


OscP5 oscP5tcpServer;

OscP5 oscP5tcpClient;

NetAddress myServerAddress;

void setup() {
  /* create  an oscP5 instance using TCP listening @ port 11000 */
  oscP5tcpServer = new OscP5(this, 11000, OscP5.TCP);
  
  /* create an oscP5 instance using TCP. 
   * the remote address is 127.0.0.1 @ port 11000 = the server from above
   */
  oscP5tcpClient = new OscP5(this, "127.0.0.1", 11000, OscP5.TCP);
}


void draw() {
  background(0);  
}


void mousePressed() {
  /* the tcp client sends a message to the server it is connected to.*/
  oscP5tcpClient.send("/test", new Object[] {new Integer(1)});
}


void keyPressed() {
  /* check how many clients are connected to the server. */
  println(oscP5tcpServer.tcpServer().getClients().length);
}

void oscEvent(OscMessage theMessage) {
  /* in this example, both the server and the client share this oscEvent method */
  System.out.println("### got a message " + theMessage);
  if(theMessage.checkAddrPattern("/test")) {
    /* message was send from the tcp client */
    OscMessage m = new OscMessage("/response");
    m.add("server response: got it");
    /* server responds to the client's message */
    oscP5tcpServer.send(m,theMessage.tcpConnection());
  }
}
