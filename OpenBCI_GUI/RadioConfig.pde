/////////////////////////////////////////////////////////////////////////////////
//
//  Radio_Config allows users to manually configure Cyton and Dongle
//
//  Created: Colin Fausnaught, July 2016
//
//  Handles interactions between the radio system and OpenBCI systems
//  using a direct Serial co
//
//  Modified by Joel Murphy, January 2017
//
//  Modified by Richard Waltman, May 2020
//
////////////////////////////////////////////////////////////////////////////////

class RadioConfig {

    private Serial serial_direct_board;
    private final int NUM_RADIO_CHAN = 26;
    private String rcStringReceived = "";
    private boolean autoscanPressed = false;
    private boolean overridePressed = false;

    RadioConfig() {

    }
    //=========== AUTOSCAN ============
    //= Scans through channels until a success message has been found
    //= Used to align Cyton and Dongle on the same radio channel, in case there is a mismatch.
    public void scan_channels(RadioConfigBox rcConfig){
        println("Radios_Config: scan_channels");
        autoscanPressed = true;
        if(serial_direct_board == null){
            if(!connect_to_portName(rcConfig)){
                return;
            }
        }
        for(int i = 1; i < NUM_RADIO_CHAN; i++){
            set_channel_over(rcConfig,i);
            system_status(rcConfig);
            if (board_message != null && board_message.toString().toLowerCase().contains("success")) {
                return;
            }
        }
        autoscanPressed = false;
        closeSerialPort();
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

    public void system_status(RadioConfigBox rcConfig){
        println("Radios_Config: system_status");
        rcStringReceived = "";
        serial_direct_board = null;
        if(!connect_to_portName(rcConfig)){
            return;
        }
        serial_direct_board = new Serial(ourApplet, openBCI_portName, openBCI_baud); //force open the com port
        if(serial_direct_board != null){
            serial_direct_board.write(0xF0);
            serial_direct_board.write(0x07);
            delay(50);
            if(print_bytes(rcConfig)){
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
        closeSerialPort();
    }

    public boolean system_status(){
        println("Cyton AutoConnect Button: system_status");
        rcStringReceived = "";
        serial_direct_board = null;
        if(!connect_to_portName()){
            return false;
        }
        serial_direct_board = new Serial(ourApplet, openBCI_portName, openBCI_baud); //force open the com port
        if(serial_direct_board != null){
            serial_direct_board.write(0xF0);
            serial_direct_board.write(0x07);
            delay(50);
            if(!print_bytes()){
                closeSerialPort();
                return false;
            } else {
                String[] s = split(rcStringReceived, ':');
                closeSerialPort();
                if (s[0].equals("Success")) {
                    outputSuccess("Successfully connected to Cyton using " + openBCI_portName);
                    return true;
                } else {
                    outputError("Failed to connect using " + openBCI_portName + ". Check hardware or try pressing 'Autoscan'.");
                    return false;
                }
            }
        } else {
            println("Error, no board connected");
            return false;
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

    public void get_channel(RadioConfigBox rcConfig){
        println("Radios_Config: get_channel");
        if(serial_direct_board == null){
            if(!connect_to_portName(rcConfig)){
                return;
            }
        }
        serial_direct_board = new Serial(ourApplet, openBCI_portName, openBCI_baud); //force open the com port
        if(serial_direct_board != null){
            serial_direct_board.write(0xF0);
            serial_direct_board.write(0x00);
            delay(100);
            print_bytes(rcConfig);
        }
        else {
            println("Error, no board connected");
            rcConfig.print_onscreen("No board connected!");
        }
        closeSerialPort();
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

    public void set_channel(RadioConfigBox rcConfig, int channel_number){
        println("Radios_Config: set_channel");
        if(serial_direct_board == null){
            if(!connect_to_portName(rcConfig)){
                return;
            }
        }
        serial_direct_board = new Serial(ourApplet, openBCI_portName, openBCI_baud); //force open the com port
        if(serial_direct_board != null){
            if(channel_number > 0){
                serial_direct_board.write(0xF0);
                serial_direct_board.write(0x01);
                serial_direct_board.write(byte(channel_number));
                delay(1000);
                print_bytes(rcConfig);
            }
            else rcConfig.print_onscreen("Please Select a Channel.");
        }
        else {
            println("Error, no board connected");
            rcConfig.print_onscreen("No board connected!");
        }
        closeSerialPort();
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

    public void set_channel_over(RadioConfigBox rcConfig, int channel_number){
        println("Radios_Config: set_ovr_channel");
        overridePressed = true;
        if(serial_direct_board == null){
            if(!connect_to_portName(rcConfig)){
                return;
            }
        }
        serial_direct_board = new Serial(ourApplet, openBCI_portName, openBCI_baud); //force open the com port
        if(serial_direct_board != null){
            if(channel_number > 0){
                serial_direct_board.write(0xF0);
                serial_direct_board.write(0x02);
                serial_direct_board.write(byte(channel_number));
                delay(100);
                print_bytes(rcConfig);
            }

            else rcConfig.print_onscreen("Please Select a Channel.");
        }
        else {
            println("Error, no board connected");
            rcConfig.print_onscreen("No board connected!");
        }
        overridePressed = false;
        closeSerialPort();
    }

    /**** Function to connect to a selected port ****/  // JAM 1/2017
    //    Needs to be connected to something to perform the Radio_Config tasks
   private boolean connect_to_portName(RadioConfigBox rcConfig){
        if(openBCI_portName != "N/A"){
            output("Attempting to open Serial/COM port: " + openBCI_portName);
            try {
                println("Radios_Config: connect_to_portName: Attempting to open serial port: " + openBCI_portName);
                serial_output = new Serial(ourApplet, openBCI_portName, openBCI_baud); //open the com port
                serial_output.clear(); // clear anything in the com port's buffer
                // portIsOpen = true;
                println("Radios_Config: connect_to_portName: Port is open!");
                serial_output.stop();
                return true;
            }
            catch (RuntimeException e){
                if (e.getMessage().contains("Port busy")) {
                    rcConfig.print_onscreen("Port Busy.\n\nTry a different port?");
                    outputError("Radios_Config: Serial Port in use. Try another port or unplug/plug dongle.");
                    // portIsOpen = false;
                } else {
                    println("Error connecting to selected Serial/COM port. Make sure your board is powered up and your dongle is plugged in.");
                    rcConfig.print_onscreen("Error connecting to Serial port.\n\nTry a different port?");
                }
                closeSerialPort();
                println("Failed to connect using " + openBCI_portName);
                return false;
            }
        } else {
            output("No Serial/COM port selected. Please select your Serial/COM port and retry");
            rcConfig.print_onscreen("Select a Serial/COM port, then try again.");
            return false;
        }
    }

    private boolean connect_to_portName(){
        if(openBCI_portName != "N/A"){
            output("Attempting to open Serial/COM port: " + openBCI_portName);
            try {
                println("Radios_Config: connect_to_portName: Attempting to open serial port: " + openBCI_portName);
                serial_output = new Serial(ourApplet, openBCI_portName, openBCI_baud); //open the com port
                serial_output.clear(); // clear anything in the com port's buffer
                // portIsOpen = true;
                println("Radios_Config: connect_to_portName: Port is open!");
                serial_output.stop();
                return true;
            }
            catch (RuntimeException e){
                if (e.getMessage().contains("Port busy")) {
                    serial_output = null;
                    outputError("Radios_Config: Serial Port in use. Try another port or unplug/plug dongle.");
                    // portIsOpen = false;
                } else {
                    println("Error connecting to selected Serial/COM port. Make sure your board is powered up and your dongle is plugged in.");
                }
                closeSerialPort();
                println("Failed to connect using " + openBCI_portName);
                return false;
            }
        } else {
            output("No Serial/COM port selected. Please select your Serial/COM port and retry");
            return false;
        }
    }

    /**** Helper function to read from the serial ****/
    private boolean print_bytes(RadioConfigBox rc){
        if(board_message != null){
            println("Radios_Config: " + board_message.toString());
            rcStringReceived = board_message.toString();
            if(rcStringReceived.equals("Failure: System is Down")) {
                rcStringReceived = "Cyton dongle could not connect to the board. Perhaps they are on different channels? \n\nTry pressing AUTOSCAN.";
            } else if (rcStringReceived.equals("Success: System is Up")) {
                rcStringReceived = "Success: Cyton and Dongle are paired. \n\nReady to Start Session!";
            } else if (!overridePressed && autoscanPressed && rcStringReceived.startsWith("Success: Host override")) {
                rcStringReceived = "Please press AUTOSCAN one more time.";
            }
            rc.print_onscreen(rcStringReceived);
            return true;
        } else {
            println("Radios_Config: Error reading from Serial/COM port");
            rc.print_onscreen("Error reading from Serial port.\n\nTry a different port?");
            return false;
        }
    }

    private boolean print_bytes(){
        if(board_message != null){
            println("Radios_Config: " + board_message.toString());
            rcStringReceived = board_message.toString();
            if(rcStringReceived.equals("Failure: System is Down")) {
                rcStringReceived = "Cyton dongle could not connect to the board. Perhaps they are on different channels? Try pressing AUTOSCAN.";
            } else if (rcStringReceived.equals("Success: System is Up")) {
                rcStringReceived = "Success: Cyton and Dongle are paired. \n\nReady to Start Session!";
            } else if (rcStringReceived.startsWith("Success: Host override")) {
                rcStringReceived = "Please press AUTOSCAN one more time.";
            }
            return true;
        } else {
            println("Radios_Config: Error reading from Serial/COM port");
            return false;
        }
    }

    public void closeSerialPort() {
        if (serial_direct_board != null) {
            serial_direct_board.stop();
        }
        serial_direct_board = null;
    }
}