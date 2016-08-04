 /**
 * oscP5flush by andreas schlegel
 * example shows how to send osc messages without having to instantiate an oscP5 object.
 * this can be useful if you are not listening for incoming messages and you
 * want to avoid to have the additional oscP5 thread running listening for incoming 
 * message (which you wont need if you are only sending messages).
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;


NetAddress myRemoteLocation;
void setup() {
  size(400,400);
  frameRate(25);
  /* set up a remote location */
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
}


void draw() {
  background(0);
}


void mousePressed() {
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/test");
  
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(100);
  
  /* send the OscMessage to the remote location. 
   */
  OscP5.flush(myOscMessage,myRemoteLocation);
}
