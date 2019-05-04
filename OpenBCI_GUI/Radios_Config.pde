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
//  rather than the Cyton class. I just found this easier to work
//  with.
//
//  Modified by Joel Murphy, January 2017
//
////////////////////////////////////////////////////////////////////////////////

String rcStringReceived = "";

void autoconnect(){
    //Serial locBoard; //local serial instance just to make sure it's openbci, then connect to it if it is
    String[] serialPorts = new String[Serial.list().length];
    String serialPort  = "";
    serialPorts = Serial.list();


    for(int i = 0; i < serialPorts.length; i++){
        try{
            serialPort = serialPorts[i];
            board = new Serial(this,serialPort,115200);
            println("try " + i + " " + serialPort + " at 115200 baud");
            output("Attempting to connect at 115200 baud to " + serialPort);  // not working
            delay(5000);

            board.write('v'); //modified by JAM 1/17
            delay(2000);
            if(confirm_openbci()) {
                println("Board connected on port " +serialPorts[i] + " with BAUD 115200");
                output("Connected to " + serialPort + "!");
                openBCI_portName = serialPorts[i];
                openBCI_baud = 115200;
                board.stop();
                return;
            } else {
                println("Board not on port " + serialPorts[i] +" with BAUD 115200");
                board.stop();
            }
        }
        catch (Exception e){
            println("Exception " + serialPorts[i] + " " + e);
        }

        try{
            board = new Serial(this,serialPort,230400);
            println("try " + i + " " + serialPort + " at 230400 baud");
            output("Attempting to connect at 230400 baud to " + serialPort);  // not working
            delay(5000);

            board.write('v'); //modified by JAM 1/17
            delay(2000);
            if(confirm_openbci()) {  // was just confrim_openbci  JAM 1/2017
                println("Board connected on port " +serialPorts[i] + " with BAUD 230400");
                output("Connected to " + serialPort + "!"); // not working
                openBCI_baud = 230400;
                openBCI_portName = serialPorts[i];
                board.stop();
                return;
            } else {
                println("Board not on port " + serialPorts[i] +" with BAUD 230400");
                board.stop();
            }

        }
        catch (Exception e){
            println("Exception " + serialPorts[i] + " " + e);
        }
    }
}

/**** Helper function for connection of boards ****/
boolean confirm_openbci(){
    //println(board_message.toString());
    // if(board_message.toString().toLowerCase().contains("registers")) return true;
    // print("board "); print(board_message.toString()); println("message");
    if(board_message != null){
        if(board_message.toString().toLowerCase().contains("ads")){
            return true;
        }
    }
    return false;
}

boolean confirm_openbci_v2(){
    //println(board_message.toString());
    if(board_message.toString().toLowerCase().contains("success"))  return true;
    // if(board_message.toString().contains("v2."))  return true;
    else return false;
}
/**** Helper function for autoscan ****/
boolean confirm_connected(){
    if( board_message != null && board_message.toString().toLowerCase().contains("success")) return true; // JAM added .containes("success")
    else return false;
}

/**** Helper function to read from the serial easily ****/
boolean print_bytes(RadioConfigBox rc){
    if(board_message != null){
        println("Radios_Config: " + board_message.toString());
        rcStringReceived = board_message.toString();
        if(rcStringReceived.equals("Failure: System is Down")) {
            rcStringReceived = "Cyton dongle could not connect to the board. Perhaps they are on different channels? Try pressing AUTOSCAN.";
        }
        rc.print_onscreen(rcStringReceived);
        return true;
    } else {
        return false;
    }
}

void print_bytes_error(RadioConfigBox rcConfig){
    println("Radios_Config: Error reading from Serial/COM port");
    rcConfig.print_onscreen("Error reading from Serial port. Try a different port?");
    board = null;
}

/**** Function to connect to a selected port ****/  // JAM 1/2017
//    Needs to be connected to something to perform the Radio_Config tasks
boolean connect_to_portName(RadioConfigBox rcConfig){
    if(openBCI_portName != "N/A"){
        output("Attempting to open Serial/COM port: " + openBCI_portName);
        try {
            println("Radios_Config: connect_to_portName: Attempting to open serial port: " + openBCI_portName);
            serial_output = new Serial(this, openBCI_portName, openBCI_baud); //open the com port
            serial_output.clear(); // clear anything in the com port's buffer
            // portIsOpen = true;
            println("Radios_Config: connect_to_portName: Port is open!");
            // changeState(HubState.COMINIT);
            board = serial_output;
            return true;
        }
        catch (RuntimeException e){
            if (e.getMessage().contains("<init>")) {
                serial_output = null;
                println("Radios_Config: connect_to_portName: Port in use, trying again later...");
                // portIsOpen = false;
            } else {
                println("Error connecting to selected Serial/COM port. Make sure your board is powered up and your dongle is plugged in.");
                rcConfig.print_onscreen("Error connecting to Serial port. Try a different port?");
            }
            board = null;
            println("Failed to connect using " + openBCI_portName);
            return false;
        }
    } else {
        output("No Serial/COM port selected. Please select your Serial/COM port and retry");
        rcConfig.print_onscreen("Select a Serial/COM port, then try again");
        return false;
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
    println("Radios_Config: system_status");

    if(board == null){
        if(!connect_to_portName(rcConfig)){
            return;
        }
    }
    if(board != null){
        board.write(0xF0);
        board.write(0x07);
        delay(100);
        if(!print_bytes(rcConfig)){
            print_bytes_error(rcConfig);
        } else {
            String[] s = split(rcStringReceived, ':');
            if (s[0].equals("Success")) {
                outputSuccess("Successfully connected to Cyton using " + openBCI_portName);
            } else {
                outputError("Failed to connect using " + openBCI_portName + ". Check hardware or try pressing 'Autoscan'.");
            }
        }
    } else {
        println("Error, no board connected");
        rcConfig.print_onscreen("No board connected!");
    }
}

//Scans through channels until a success message has been found
void scan_channels(RadioConfigBox rcConfig){
    println("Radios_Config: scan_channels");
    if(board == null){
        if(!connect_to_portName(rcConfig)){
            return;
        }
    }
    for(int i = 1; i < 26; i++){

        set_channel_over(rcConfig,i);
        system_status(rcConfig);
        if(confirm_connected()) return; // break;
    }
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
    println("Radios_Config: get_channel");
    if(board == null){
        if(!connect_to_portName(rcConfig)){
            return;
        }
    }

    if(board != null){
        board.write(0xF0);
        board.write(0x00);
        delay(100);
        if(!print_bytes(rcConfig)){
            print_bytes_error(rcConfig);
        }
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
    println("Radios_Config: set_channel");
    if(board == null){
        if(!connect_to_portName(rcConfig)){
            return;
        }
    }
    if(board != null){
        if(channel_number > 0){
            board.write(0xF0);
            board.write(0x01);
            board.write(byte(channel_number));
            delay(1000);
            if(!print_bytes(rcConfig)){
                print_bytes_error(rcConfig);
            }
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
    println("Radios_Config: set_ovr_channel");
    if(board == null){
        if(!connect_to_portName(rcConfig)){
            return;
        }
    }
    if(board != null){
        if(channel_number > 0){
            board.write(0xF0);
            board.write(0x02);
            board.write(byte(channel_number));
            delay(100);
            if(!print_bytes(rcConfig)){
                print_bytes_error(rcConfig);
            }
        }

        else rcConfig.print_onscreen("Please Select a Channel");
    }

    else {
        println("Error, no board connected");
        rcConfig.print_onscreen("No board connected!");
    }
}
