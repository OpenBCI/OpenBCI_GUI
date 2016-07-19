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
            board.stop();
            return;
          }
          
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }
    }
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
void print_bytes(Serial board, RadioConfigBox rc){
  board.read();
  byte input = byte(inByte);
  StringBuilder sb = new StringBuilder();
    
  while(input != -1){
    print(char(input));
    if(char(input) != '$') sb.append(char(input));
    board.read();
    input = byte(inByte);
  }
  rc.print_onscreen(sb.toString());
  
  print("\n");
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
    board.write(0xF0);
    board.write(0x00);
    delay(100);
    
    print_bytes(board,rcConfig);
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
    if(channel_number > 0){
      board.write(0xF0);
      board.write(0x01);
      board.write(byte(channel_number));
      delay(1000);
      print_bytes(board,rcConfig);
    }
    else rcConfig.print_onscreen("Please Select a Channel");
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
    if(channel_number > 0){
      board.write(0xF0);
      board.write(0x02);
      board.write(byte(channel_number));
      delay(100);
      print_bytes(board,rcConfig);
    }
      
    else rcConfig.print_onscreen("Please Select a Channel");
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
      board.write(0xF0);
      board.write(0x03);
      delay(100);
      
      board.read();
      byte input = byte(inByte);
      boolean space_found = false;
      int hex_to_int = 0;
     
      StringBuilder sb = new StringBuilder();
      
      //special case for error messages
      if(char(input) == 'S'){
        while(input != -1){
          print(char(input));
          if(char(input) != '$' && !space_found) sb.append(char(input));
          else if(space_found && char(input) != '$')hex_to_int = Integer.parseInt(String.format("%02X",input),16);
          
          if(char(input) == ' ')space_found = true;
          
          board.read();
          input = byte(inByte);
        }
        
        sb.append(hex_to_int);
        rcConfig.print_onscreen(sb.toString());
        print(" " + hex_to_int + "\n");
      }
      else{
        while(input != -1){
            print(char(input));
            if(char(input) != '$') sb.append(char(input)); 
            board.read();
            input = byte(inByte);
          }
          
          sb.append(hex_to_int);
          rcConfig.print_onscreen(sb.toString());
          print(" " + hex_to_int + "\n");
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

    board.write(0xF0);
    board.write(0x04);
    board.write(byte(poll_number));
    delay(1000);
    print_bytes(board,rcConfig);
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
    
    board.write(0xF0);
    board.write(0x05);
    delay(100);
    print_bytes(board, rcConfig);
    
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

    board.write(0xF0);
    board.write(0x06);
    delay(100);
    print_bytes(board, rcConfig);
    
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
    board.write(0xF0);
    board.write(0x07);
    delay(100);
    print_bytes(board, rcConfig);
}