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