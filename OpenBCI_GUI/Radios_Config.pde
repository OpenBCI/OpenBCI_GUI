//////////////////
//
//  Radios_Config will be used for radio configuration 
//  integration. Also handles functions such as the "autconnect"
//  feature.
//
//  Created: Colin Fausnaught, July 2016
//
//  More to come...
////////////////

boolean no_start_connection = false;
boolean isOpenBCI;
int baudSwitch = 0;

void autoconnect(){
    Serial locBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();
    
    
    
    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          locBoard = new Serial(this,serialPort,115200);
          println(serialPort);
          
          delay(100);
          
          locBoard.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci()) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 115200"); 
            openBCI_portName = serialPorts[i];
            openBCI_baud = 115200;
            locBoard.stop();
            return;
          }
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 115200");
        }
      try{
          locBoard = new Serial(this,serialPort,230400);
          println(serialPort);
          
          delay(100);
          
          locBoard.write(0xF0);
          locBoard.write(0x07);
          delay(100);
          if(confirm_openbci()) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 230400");
            openBCI_baud = 230400;
            openBCI_portName = serialPorts[i];
            locBoard.stop();
            return;
          }
          
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }
    }
}

Serial autoconnect_return_high(RadioConfigBox rc) throws Exception{
  
    Serial locBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();
    
    
    
    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          locBoard = new Serial(this,serialPort,230400);
          println(serialPort);
          
          delay(100);
          
          locBoard.write(0xF0);
          locBoard.write(0x07);
          delay(1000);
          //print_bytes(rc);
          if(confirm_openbci()) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 230400");
            no_start_connection = true;
            openBCI_portName = serialPorts[i];
            isOpenBCI = false;
                        
            return locBoard;
          }
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }    
      
    }
    throw new Exception();
}

Serial autoconnect_return_default(RadioConfigBox rc) throws Exception{
  
    Serial locBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();
    
    
    for(int i = 0; i < serialPorts.length; i++){
     
      try{
          serialPort = serialPorts[i];
          locBoard = new Serial(this,serialPort,115200);
          println(serialPort);
          
          delay(100);
          
          locBoard.write(0xF0);
          locBoard.write(0x07);
          delay(1000);
          //print_bytes(rc);
          if(confirm_openbci()) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 115200"); 
            no_start_connection = true;
            openBCI_portName = serialPorts[i];
            isOpenBCI = false;
            
            return locBoard;
          }
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 115200");
        }
    }
    throw new Exception();
}

boolean confirm_openbci(){
  if(board_message.toString().charAt(0) == 'S' || board_message.toString().charAt(0) == 'F') return true;
  else return false;
}

/**** Helper function to throw away all bytes coming in from board ****/
void trash_bytes(Serial board){
  board.read();
  byte input = byte(inByte);
  
  while(input != -1){
    board.read();
    input = byte(inByte);
  }
}

/**** Helper function to read from the serial easily ****/
void print_bytes( RadioConfigBox rc){
  println(board_message.toString());
  rc.print_onscreen(board_message.toString());
}


//============== GET CHANNEL ===============
//= Gets channel information from the radio.
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x00).
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void get_channel(RadioConfigBox rcConfig){
  if(board != null){
    board.write(0xF0);
    board.write(0x00);
    delay(100);
    
    print_bytes(rcConfig);
  }
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
  }

//============== SET CHANNEL ===============
//= Sets the radio and board channel.
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x01) followed by the number to
//= set the board and radio to. Channels can
//= only be 1-25.
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_channel(RadioConfigBox rcConfig, int channel_number){
  if(board != null){
    if(channel_number > 0){
      board.write(0xF0);
      board.write(0x01);
      board.write(byte(channel_number));
      delay(1000);
      print_bytes(rcConfig);
    }
    else rcConfig.print_onscreen("Please Select a Channel");
  }
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
}

//========== SET CHANNEL OVERRIDE ===========
//= Sets the radio channel only
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x02) followed by the number to
//= set the board and radio to. Channels can
//= only be 1-25.
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_channel_over(RadioConfigBox rcConfig, int channel_number){
  if(board != null){
    if(channel_number > 0){
      board.write(0xF0);
      board.write(0x02);
      board.write(byte(channel_number));
      delay(100);
      print_bytes(rcConfig);
    }
      
    else rcConfig.print_onscreen("Please Select a Channel");
  }
  
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
}

//================ GET POLL =================
//= Gets the poll time
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x03).
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void get_poll(RadioConfigBox rcConfig){
  if(board != null){
      board.write(0xF0);
      board.write(0x03);
      isGettingPoll = true;
      delay(100);
      board_message.append(hexToInt);
      print_bytes(rcConfig);
      isGettingPoll = false;
      spaceFound = false;
  }
  
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
}

//=========== SET POLL OVERRIDE ============
//= Sets the poll time
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x04) followed by the number to
//= set as the poll value. Channels can only 
//= be 0-255.
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_poll(RadioConfigBox rcConfig, int poll_number){
  if(board != null){
    board.write(0xF0);
    board.write(0x04);
    board.write(byte(poll_number));
    delay(1000);
    print_bytes(rcConfig);
  }
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
}

//========== SET BAUD TO DEFAULT ===========
//= Sets BAUD to it's default value (115200)
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x05). 
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_baud_default(RadioConfigBox rcConfig, String serialPort){
  if(board != null){
    board.write(0xF0);
    board.write(0x05);
    delay(1000);
    print_bytes(rcConfig);
    delay(1000);
    
    
    try{
      board.stop();
      board = autoconnect_return_default(rcConfig);
    }
    catch (Exception e){
      println("error setting serial to BAUD 115200");
    }
  }
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
}

//====== SET BAUD TO HIGH-SPEED MODE =======
//= Sets BAUD to a higher rate (230400)
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x06). 
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_baud_high(RadioConfigBox rcConfig, String serialPort){
  if(board != null){
    board.write(0xF0);
    board.write(0x06);
    delay(1000);
    print_bytes(rcConfig);
    delay(1000);
    
    try{
      board.stop();
      board = autoconnect_return_high(rcConfig);
    }
    catch (Exception e){
      println("error setting serial to BAUD 230400");
    }
  }
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
      
}

//=========== GET SYSTEM STATUS ============
//= Get's the current status of the system
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x07). 
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void system_status(RadioConfigBox rcConfig){
  if(board != null){
    board.write(0xF0);
    board.write(0x07);
    delay(100);
    print_bytes(rcConfig);
  }
  else {
    println("Error, no board connected");
    rcConfig.print_onscreen("No board connected!");
  }
}

//Scans through channels until a success message has been found
void scan_channels(){
  scanningChannels = true;
  /*
  byte input = byte(board.read());
  StringBuilder sb = new StringBuilder();
  String the_string = "Success: System is Up$$$";
  
  while(input != -1){
    if(char(input) != '$') sb.append(char(input));
    input = byte(board.read());
  }
  
  
  for(int i = 1; i < 26; i++){
    channel_number = i;
    //Channel override
    board.write(0xF0);
    board.write(0x02);
    board.write(byte(channel_number));
    delay(100);
    
    input = byte(board.read());
    //throw out data from override
    while(input != -1){
      input = byte(board.read());
    }
    
    //Channel Status
    board.write(0xF0);
    board.write(0x07);
    delay(100);
    
    input = byte(board.read());
    sb = new StringBuilder();
    
    while(input != -1){
      sb.append(char(input));
      input = byte(board.read());
    }
    
    println(the_string);
    println(sb.toString());
    
    if(sb.toString().equals(the_string)) {
      print_onscreen("Successfully connected to channel: " + i);
      println("Successfully connected to channel: " + i); 
      return;
    }
    
    
    
  }
  
  print_onscreen("Could not connect, is your board powered on?");
  println("Could not connect, is your board powered on?");

      */
}