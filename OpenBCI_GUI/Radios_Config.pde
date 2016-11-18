/////////////////////////////////////////////////////////////////////////////////
//
//  Radios_Config will be used for radio configuration
//  integration. Also handles functions such as the "autconnect"
//  feature.
//
//  Created: Colin Fausnaught, July 2016
//
//  Handles interactions between the radio system and OpenBCI systems.
//  It is important to note that this is using Serial communication directly
//  rather than the OpenBCI_ADS1299 class. I just found this easier to work
//  with.
//
//  KNOWN ISSUES:
//
//  TODO:
////////////////////////////////////////////////////////////////////////////////
boolean isOpenBCI;
int baudSwitch = 0;

void autoconnect(){
    //Serial locBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();



    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          board = new Serial(this,serialPort,115200);
          println(serialPort);

          delay(1000);

          board.write('?');
          //board.write(0x07);
          delay(1000);
          if(confirm_openbci()) {
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

          delay(1000);

          board.write('?');
          //board.write(0x07);
          delay(1000);
          if(confirm_openbci()) {
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

Serial autoconnect_return_default() throws Exception{

    Serial locBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    Serial retBoard;
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();


    for(int i = 0; i < serialPorts.length; i++){

      try{
          serialPort = serialPorts[i];
          locBoard = new Serial(this,serialPort,115200);

          delay(100);

          locBoard.write(0xF0);
          locBoard.write(0x07);
          delay(1000);

          if(confirm_openbci_v2()) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 115200");
            no_start_connection = true;
            openBCI_portName = serialPorts[i];
            openBCI_baud = 115200;
            isOpenBCI = false;

            return locBoard;
          }
          else locBoard.stop();
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 115200");
        }
    }


    throw new Exception();
}

Serial autoconnect_return_high() throws Exception{

    Serial localBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();


    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          localBoard = new Serial(this,serialPort,230400);

          delay(100);

          localBoard.write(0xF0);
          localBoard.write(0x07);
          delay(1000);
          if(confirm_openbci_v2()) {
            println("Board connected on port " +serialPorts[i] + " with BAUD 230400");
            no_start_connection = true;
            openBCI_portName = serialPorts[i];
            openBCI_baud = 230400;
            isOpenBCI = false;

            return localBoard;
          }
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }

    }
    throw new Exception();
}

/**** Helper function for connection of boards ****/
boolean confirm_openbci(){
  //println(board_message.toString());
  if(board_message.toString().toLowerCase().contains("registers")) return true;
  else return false;
}

boolean confirm_openbci_v2(){
  //println(board_message.toString());
  if(board_message.toString().toLowerCase().contains("success"))  return true;
  else return false;
}
/**** Helper function for autoscan ****/
boolean confirm_connected(){
  if( board_message != null && board_message.toString().charAt(0) == 'S') return true;
  else return false;
}

/**** Helper function to read from the serial easily ****/
void print_bytes(RadioConfigBox rc){
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
      board = null;
      board = autoconnect_return_default();
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
      board = null;
      board = autoconnect_return_high();
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
void scan_channels(RadioConfigBox rcConfig){

  for(int i = 1; i < 26; i++){

    set_channel_over(rcConfig,i);
    system_status(rcConfig);
    if(confirm_connected()) break;
  }
}
