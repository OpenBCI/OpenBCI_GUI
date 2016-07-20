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

void autoconnect(){
    Serial board; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();
    
    
    
    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          board = new Serial(this,serialPort,115200);
          println(serialPort);
          
          delay(100);
          
          board.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci(board)) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 115200"); 
            openBCI_portName = serialPorts[i];
            openBCI_baud = 115200;
            board.stop();
            return;
          }
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 115200");
        }
      try{
          board = new Serial(this,serialPort,230400);
          println(serialPort);
          
          delay(100);
          
          board.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci(board)) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 230400");
            openBCI_baud = 230400;
            openBCI_portName = serialPorts[i];
            board.stop();
            return;
          }
          
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }
    }
}

Serial autoconnect_return() throws Exception{
  
    Serial board; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();
    
    
    
    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          board = new Serial(this,serialPort,115200);
          println(serialPort);
          
          delay(100);
          
          board.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci(board)) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 115200"); 
            no_start_connection = true;
            
            return board;
          }
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 115200");
        }
      try{
          board = new Serial(this,serialPort,230400);
          println(serialPort);
          
          delay(100);
          
          board.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci(board)) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 230400");
            no_start_connection = true;
            return board;
          }
          
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }
    }
    throw new Exception();
}

boolean confirm_openbci(Serial board){
  byte input = byte(inByte);
  println(char(input));
  if(char(input) == 'F' || char(input) == 'S' || char(input) == '$'){/*trash_bytes(board); */return true;}
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

void get_channel(Serial board, RadioConfigBox rcConfig){
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

void set_channel(Serial board, RadioConfigBox rcConfig, int channel_number){
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

void set_channel_over(Serial board, RadioConfigBox rcConfig, int channel_number){
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

void get_poll(Serial board, RadioConfigBox rcConfig){
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

void set_poll(Serial board, RadioConfigBox rcConfig, int poll_number){
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

void set_baud_default(Serial board, RadioConfigBox rcConfig, String serialPort){
  if(board != null){
    board.write(0xF0);
    board.write(0x05);
    delay(100);
    print_bytes( rcConfig);
    
    try{
      board.stop();
      board = new Serial(this,serialPort,115200);
      println(serialPorts[serialPorts.length -1]);
      byte input = byte(board.read());
      
      while(input != -1){
        print(char(input));
        input = byte(board.read());
      }
      print("\n");
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

void set_baud_high(Serial board, RadioConfigBox rcConfig, String serialPort){
  if(board != null){
    board.write(0xF0);
    board.write(0x06);
    delay(100);
    print_bytes( rcConfig);
    
    try{
      board.stop();
      board = new Serial(this,serialPort,230400);
      println(serialPorts[serialPorts.length -1]);
      byte input = byte(board.read());
      
      while(input != -1){
        print(char(input));
        input = byte(board.read());
      }
      print("\n");
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

void system_status(Serial board, RadioConfigBox rcConfig){
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