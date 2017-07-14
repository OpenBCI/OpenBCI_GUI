/**
 * oscP5bundle by andreas schlegel
 * an osc broadcast server.
 * example shows how to create and send osc bundles. 
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
}


void draw() {
  background(0);  
}


void mousePressed() {
  /* create an osc bundle */
  OscBundle myBundle = new OscBundle();
  
  /* createa new osc message object */
  OscMessage myMessage = new OscMessage("/test");
  myMessage.add("abc");
  
  /* add an osc message to the osc bundle */
  myBundle.add(myMessage);
  
  /* reset and clear the myMessage object for refill. */
  myMessage.clear();
  
  /* refill the osc message object again */
  myMessage.setAddrPattern("/test2");
  myMessage.add("defg");
  myBundle.add(myMessage);
  
  myBundle.setTimetag(myBundle.now() + 10000);
  /* send the osc bundle, containing 2 osc messages, to a remote location. */
  oscP5.send(myBundle, myRemoteLocation);
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  print(" typetag: "+theOscMessage.typetag());
  println(" timetag: "+theOscMessage.timetag());
}
