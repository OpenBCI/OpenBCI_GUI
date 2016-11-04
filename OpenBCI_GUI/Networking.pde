//////////////////////////////////////////////////////////////////////////
//
//    Networking
//    - responsible for sending data over a Network
//    - Three types of networks are available:
//        - UDP
//        - OSC
//        - LSL
//    - In control panel, specify the network and parameters (port, ip, etc).
//      Then, you can receive the streamed data in a variety of different
//      programs, given that you specify the correct parameters to receive
//      the data stream in those networks.
//
//////////////////////////////////////////////////////////////////////////

float[] data_to_send;
float[] aux_to_send;
float[] full_message;

public void sendRawData_dataPacket(DataPacket_ADS1299 data, float scale_to_uV, float scale_for_aux) {
  data_to_send = writeValues(data.values,scale_to_uV);
  aux_to_send = writeValues(data.auxValues,scale_for_aux);

  //full_message = compressArray(data);     //Collect packet into full_message array
  //send to appropriate network type
  if (networkType == 1){
    udp.send_message(data_to_send);       //Send full message to udp
  }else if (networkType == 2){
    osc.send_message(data_to_send);       //Send full message to osc
  }else if (networkType == 3){
    lsl.send_message(data_to_send,aux_to_send);       //Send
  }
}

public void sendPlaybackData(float[] data_to_send,float[]aux_to_send){
  if (networkType == 1){
    udp.send_message(data_to_send);       //Send full message to udp
  }else if (networkType == 2){
    osc.send_message(data_to_send);       //Send full message to osc
  }else if (networkType == 3){
    lsl.send_message(data_to_send,aux_to_send);       //Send
  }
}
// Convert counts to scientific values (uV or G)
private float[] writeValues(int[] values, float scale_fac) {
  int nVal = values.length;
  float[] temp_buffer = new float[nVal];
  for (int Ival = 0; Ival < nVal; Ival++) {
    temp_buffer[Ival] = scale_fac * float(values[Ival]);
  }
  return temp_buffer;
}

//Package all data into one array (full_message) for UDP and OSC
private float[] compressArray(DataPacket_ADS1299 data){
    full_message = new float[1 + data_to_send.length + aux_to_send.length];
    full_message[0] = data.sampleIndex;
    for (int i=0;i<data_to_send.length;i++){
      full_message[i+1] = data_to_send[i];
    }
    for (int i=0;i<aux_to_send.length;i++){
      full_message[data_to_send.length + 1] = aux_to_send[i];
    }
    return full_message;
}

//////////////
// CLASSES //

/**
 * To perform any action on datagram reception, you need to implement this
 * handler in your code. This method will be automatically called by the UDP
 * object each time he receive a nonnull message. This method will send the
 * message to `udpEvent`
 */
// void receive(byte[] data, String ip, int port) {	// <-- extended handler
//   // get the "real" message =
//   // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
//   data = subset(data, 0, data.length-2);
//   String message = new String( data );
//
//   // Be safe, always check to make sure the parent did implement this function
//   if (ganglion.udpRx.udpEventMethod != null) {
//     try {
//       ganglion.udpRx.udpEventMethod.invoke(ganglion.udpRx.parent, message);
//     }
//     catch (Exception e) {
//       System.err.println("Disabling udpEvent() for because of an error.");
//       e.printStackTrace();
//       ganglion.udpRx.udpEventMethod = null;
//     }
//   }
// }

// void clientEvent(Client someClient) {
//   print("Server Says:  ");
//   dataIn = myClient.read();
//   println(dataIn);
//   background(dataIn);
//
//   // get the "real" message =
//   // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
//   data = subset(data, 0, data.length-2);
//   String message = new String( data );
//
//   // Be safe, always check to make sure the parent did implement this function
//   if (ganglion.udpRx.udpEventMethod != null) {
//     try {
//       ganglion.udpRx.udpEventMethod.invoke(ganglion.udpRx.parent, message);
//     }
//     catch (Exception e) {
//       System.err.println("Disabling udpEvent() for because of an error.");
//       e.printStackTrace();
//       ganglion.udpRx.udpEventMethod = null;
//     }
//   }
//
// }

class UDPReceive {
  public Method udpEventMethod;
  public PApplet parent;
  int port;
  String ip;
  boolean listen;
  UDP udp;

  /**
   * @description Used to construct a new UDP connection
   * @param `parent` {PApplet} - The object calling constructor. Implements
   *  `udpEvent` if `parent` wants to recieve messages.
   * @param `port` {int} - The port number to use for the UDP port
   * @param `ip` {String} - The ip address for the UDP connection. Use `localhost`
   *  to keep the port on this computer.
   * @constructor
   */
  public UDPReceive(PApplet parent, int port, String ip) {
    // Grab vars
    this.port  = port;
    this.ip = ip;

    this.udp = new UDP(parent, port);
    println("udp bound to " + port);
    this.udp.setBuffer(1024);
    this.udp.log(false);
    this.udp.listen(true);

    // callback: https://forum.processing.org/one/topic/noob-q-i-d-like-to-learn-more-about-callbacks.html
    // Set parent for callback
    this.parent = parent;

    // Verify that parent actaully implements the callback
    try {
      this.udpEventMethod = this.parent.getClass().getMethod("udpEvent", new Class[] { String.class });
      println("Networking: Good job iplmenting udpEvent callback in parent " + parent);
    }
    catch (Exception e) {
      // No such method declared, there for the parent who created this will not
      //  recieve messages :(
      println("Networking: Error failed to implement udpEvent callback in parent " + this.parent);
      this.udp.listen(false);
    }

  }
}

// UDP SEND //
class UDPSend {
  int port;
  String ip;
  UDP udp;

  UDPSend(int _port, String _ip){
    port = _port;
    ip = _ip;
    udp = new UDP(this);
    udp.setBuffer(1024);
    udp.log(false);
  }
  void send_message(float[] _message){
    String message = Arrays.toString(_message);
    udp.send(message,ip,port);
  }

  void send(String msg){
    udp.send(msg,ip,port);
  }
}

// OSC SEND //
class OSCSend{
  int port;
  String ip;
  String address;
  OscP5 osc;
  NetAddress netaddress;

  OSCSend(int _port, String _ip, String _address){
    port = _port;
    ip = _ip;
    address = _address;
    osc = new OscP5(this,12000);
    netaddress = new NetAddress(ip,port);
  }
  void send_message(float[] _message){
    OscMessage osc_message = new OscMessage(address);
    osc_message.add(_message);
    osc.send(osc_message, netaddress);
  }
}

// LSL SEND //
class LSLSend{
  String data_stream;
  String data_stream_id;
  String aux_stream;
  String aux_stream_id;
  LSL.StreamInfo info_data;
  LSL.StreamOutlet outlet_data;
  LSL.StreamInfo info_aux;
  LSL.StreamOutlet outlet_aux;

  LSLSend(String _data_stream, String _aux_stream){
    data_stream = _data_stream;
    data_stream_id = data_stream + "_id";
    aux_stream = _aux_stream;
    aux_stream_id = aux_stream + "_id";
    info_data = new LSL.StreamInfo(data_stream, "EEG", nchan, openBCI.get_fs_Hz(), LSL.ChannelFormat.float32, data_stream_id);
    outlet_data = new LSL.StreamOutlet(info_data);
    //info_aux = new LSL.StreamInfo("aux_stream", "AUX", 3, openBCI.get_fs_Hz(), LSL.ChannelFormat.float32, aux_stream_id);
    //outlet_aux = new LSL.StreamOutlet(info_aux);
  }
  void send_message(float[] _data_message, float[] _aux_message){
    outlet_data.push_sample(_data_message);
    //outlet_aux.push_sample(_aux_message);
  }
}
