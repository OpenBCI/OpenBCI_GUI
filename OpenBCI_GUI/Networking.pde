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



public void sendRawData_dataPacket(DataPacket_ADS1299 data, float scale_to_uV, float scale_for_aux) {
  //println(Integer.toString(data.sampleIndex));
  float[] data_to_send = writeValues(data.values,scale_to_uV);
  //println(data_to_send);
  if (networkType == 1){
    udp.send_message(data_to_send);
  }else if (networkType == 2){
    println("wot");
    osc.send_message(data_to_send);
  }else if (networkType == 3){
    lsl.send_message(data_to_send);
  }
  float[] aux_to_send = writeValues(data.auxValues,scale_for_aux);
}
private float[] writeValues(int[] values, float scale_fac) {          
  int nVal = values.length;
  float[] temp_buffer = new float[nVal];
  for (int Ival = 0; Ival < nVal; Ival++) {
    temp_buffer[Ival] = scale_fac * float(values[Ival]);
  }
  return temp_buffer;
}

//////////////
// CLASSES //

// UDP SEND //
class UDPSend{
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
   println(_message);
    String message = Arrays.toString(_message);
    OscMessage osc_message = new OscMessage(address);
    println(message);
    osc_message.add(message);
    println(osc_message);
    
    osc.send(osc_message, netaddress);
  }
}


//https://github.com/jfrey-xx/LSLLink/blob/master/examples/SendData/SendData.pde
// LSL SEND //
class LSLSend{
  String data_stream;
  String data_stream_id;
  String aux_stream;
  String aux_stream_id;
  LSL.StreamInfo info;
  LSL.StreamOutlet outlet;
  
  LSLSend(String _data_stream, String _aux_stream){
    data_stream = _data_stream;
    data_stream_id = data_stream + "_id";
    aux_stream = _aux_stream;
    aux_stream_id = aux_stream + "_id";
    info = new LSL.StreamInfo(data_stream, "EEG", nchan, openBCI.get_fs_Hz(), LSL.ChannelFormat.float32, data_stream_id);
    outlet = new LSL.StreamOutlet(info);
    //info = new LSL.StreamInfo("BioSemi", "EEG", 8, 60, LSL.ChannelFormat.float32, "myuid324457");

  }
  void send_message(float[] _message){
    outlet.push_sample(_message);
  }
}
  