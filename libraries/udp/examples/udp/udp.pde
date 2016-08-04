/**
 * (./) udp.pde - how to use UDP library as unicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 *
 * Create a communication between Processing<->Pure Data @ http://puredata.info/
 * This program also requires to run a small program on Pd to exchange data  
 * (hum!!! for a complete experimentation), you can find the related Pd patch
 * at http://hypermedia.loeil.org/processing/udp.pd
 * 
 * -- note that all Pd input/output messages are completed with the characters 
 * ";\n". Don't refer to this notation for a normal use. --
 */

// import UDP library
import hypermedia.net.*;


UDP udp;  // define the UDP object

/**
 * init
 */
void setup() {

  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6000 );
  //udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );
}

//process events
void draw() {;}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
    
    String message  = str( key );	// the message to send
    String ip       = "localhost";	// the remote IP address
    int port        = 6100;		// the destination port
    
    // formats the message for Pd
    message = message+";\n";
    // send the message
    udp.send( message, ip, port );
    
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) { 			// <-- default handler
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  
  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
}

