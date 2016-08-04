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
  
  full_message = compressArray(data);     //Collect packet into full_message array
  
  //send to appropriate network type
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
  