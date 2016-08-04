/**
 * (./) udp_multicast.pde - how to use UDP library as multicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 *
 * Pass the mouse coordinates over the network to draw an "multi-user picture".
 *
 * --
 *
 * about multicasting:
 * The only difference between unicast/broadcast and multicast address is that 
 * all interfaces identified by that address receive the same data. Multicasting
 * provide additional options in the UDP object (see the documentation for 
 * more informations), but the usage is commonly the same: simply add the 
 * multicast group address in his initialization to reflect a multicast 
 * connection.
 *
 * (note: currently applets are not allowed to use multicast sockets)
 */

// import UDP library
import hypermedia.net.*;


UDP udp;  // the UDP object


/**
 * init the frame and the UDP object.
 */
void setup() {
  
  // to simplify the program, we use a byte[] array to pass the previous and
  // the current mouse coordinates. The PApplet size must be defined with 
  // values <=255
  size( 255, 255 );
  background( 0 );
  
  // create a multicast connection on port 6000
  // and join the group at the address "224.0.0.1"
  udp = new UDP( this, 6000, "224.0.0.1" );
  // wait constantly for incomming data
  udp.listen( true );
  // ... well, just verifies if it's really a multicast socket and blablabla
  println( "init as multicast socket ... "+udp.isMulticast() );
  println( "joins a multicast group  ... "+udp.isJoined() );
  
}

// process events
void draw() {
}


/**
 * on mouse move : 
 * send the mouse positions over the network
 */
void mouseMoved() {
  
    byte[] data = new byte[4];	// the data to be send
    
    // add the mouse positions
    data[0] = byte(mouseX);
    data[1] = byte(mouseY);
    data[2] = byte(pmouseX);
    data[3] = byte(pmouseY);
    
    // by default if the ip address and the port number are not specified, UDP 
    // send the message to the joined group address and the current socket port.
    udp.send( data ); // = send( data, group_ip, port );
    
    // note: by creating a multicast program, you can also send a message to a
    // specific address (i.e. send( "the messsage", "192.168.0.2", 7010 ); )
}

/**
 * This is the program receive handler. To perform any action on datagram 
 * reception, you need to implement this method in your code. She will be 
 * automatically called by the UDP object each time he receive a nonnull 
 * message.
 */
void receive( byte[] data ) {
  
  // retrieve the mouse coordonates
  int x  = int( data[0] );
  int y  = int( data[1] );
  int px = int( data[2] );
  int py = int( data[3] );
  
  // slowly, clears the previous lines
  noStroke();
  fill( 0, 0, 0, 7 );
  rect( 0, 0, width, height);
  
  // and draw a single line with the given mouse positions
  stroke( 255 );
  line( x, y, px, py );
  
}
