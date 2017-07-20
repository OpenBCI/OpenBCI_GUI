/**
 * oscP5properities by andreas schlegel
 * example shows how to use osc properties. 
 * if you need more specific settings for your osc session,
 * osc properties serves your needs.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
import oscP5.*;
import netP5.*;

OscP5 oscP5;

void setup() {
  size(400,400);
  frameRate(25);

  /* create a new osc properties object */
  OscProperties properties = new OscProperties();
  
  /* set a default NetAddress. sending osc messages with no NetAddress parameter 
   * in oscP5.send() will be sent to the default NetAddress.
   */
  properties.setRemoteAddress("127.0.0.1",12000);
  
  /* the port number you are listening for incoming osc packets. */
  properties.setListeningPort(12000);
  
  
  /* Send Receive Same Port is an option where the sending and receiving port are the same.
   * this is sometimes necessary for example when sending osc packets to supercolider server.
   * while both port numbers are the same, the receiver can simply send an osc packet back to
   * the host and port the message came from.
   */
  properties.setSRSP(OscProperties.ON);
  
  /* set the datagram byte buffer size. this can be useful when you send/receive
   * huge amounts of data, but keep in mind, that UDP is limited to 64k
  */
  properties.setDatagramSize(1024);
  
  /* initialize oscP5 with our osc properties */
  oscP5 = new OscP5(this,properties);    
  
  /* print your osc properties */
  println(properties.toString());
}



void mousePressed() {
  /* create a new osc message with address pattern /test */
  OscMessage myMessage = new  OscMessage("/test");
  myMessage.add(200);
  
  /* send the osc message to the default netAddress, set in the OscProperties above.*/
  oscP5.send(myMessage);
}


void draw() {
  background(0);  
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
