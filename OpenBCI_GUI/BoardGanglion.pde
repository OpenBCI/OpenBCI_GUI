///////////////////////////////////////////////////////////////////////////////
//
// This class configures and manages the connection to the OpenBCI Ganglion.
// The connection is implemented via a TCP connection to a TCP port.
// The Gagnlion is configured using single letter text commands sent from the
// PC to the TCP server.  The EEG data streams back from the Ganglion, to the
// TCP server and back to the PC continuously (once started).
//
// Created: AJ Keller, August 2016
//
/////////////////////////////////////////////////////////////////////////////

// import java.io.OutputStream; //for logging raw bytes to an output file

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

class Ganglion {
    final static char GANGLION_BOOTLOADER_MODE = '>';

    final static int NUM_ACCEL_DIMS = 3;

    private int nEEGValuesPerPacket = NCHAN_GANGLION; // Defined by the data format sent by cyton boards
    private int nAuxValuesPerPacket = NUM_ACCEL_DIMS; // Defined by the arduino code

    private final float fsHzBLE = 200.0f;  //sample rate used by OpenBCI Ganglion board... set by its Arduino code
    private final float fsHzWifi = 1600.0f;  //sample rate used by OpenBCI Ganglion board on wifi, set by hub

    private final float MCP3912_Vref = 1.2f;  // reference voltage for ADC in MCP3912 set in hardware
    private final float MCP3912_gain = 1.0;  //assumed gain setting for MCP3912.  NEEDS TO BE ADJUSTABLE JM
    private float scale_fac_uVolts_per_count = (MCP3912_Vref * 1000000.f) / (8388607.0 * MCP3912_gain * 1.5 * 51.0); //MCP3912 datasheet page 34. Gain of InAmp = 80
    private float scale_fac_accel_G_per_count_ble = 0.016;
    private float scale_fac_accel_G_per_count_wifi = 0.001;

    private int curInterface = INTERFACE_NONE;

    private DataPacket_ADS1299 dataPacket;

    private boolean checkingImpedance = false;
    private boolean accelModeActive = true;

    public int[] impedanceArray = new int[NCHAN_GANGLION + 1];

    private int sampleRate = (int)fsHzWifi;

    // Getters
    public float getSampleRate() {
        if (isBLE()) {
            return fsHzBLE;
        } else {
            return hub.getSampleRate();
        }
    }
    
    public float get_scale_fac_uVolts_per_count() {
        return scale_fac_uVolts_per_count;
    }

    public float get_scale_fac_accel_G_per_count() {
        if (isWifi()) {
            return scale_fac_accel_G_per_count_wifi;
        } else {
            return scale_fac_accel_G_per_count_ble;
        }
    }
    public boolean isCheckingImpedance() { return checkingImpedance; }
    public boolean isAccelModeActive() { return accelModeActive; }
    public void overrideCheckingImpedance(boolean val) { checkingImpedance = val; }
    public int getInterface() {
        return curInterface;
    }
    public boolean isBLE () {
        return curInterface == INTERFACE_HUB_BLE || curInterface == INTERFACE_HUB_BLED112;
    }

    public boolean isWifi () {
        return curInterface == INTERFACE_HUB_WIFI;
    }

    public boolean isPortOpen() {
        return hub.isPortOpen();
    }

    private PApplet mainApplet;

    //constructors
    Ganglion() {};  //only use this if you simply want access to some of the constants
    Ganglion(PApplet applet) {
        mainApplet = applet;

        initDataPackets(nEEGValuesPerPacket, nAuxValuesPerPacket);
    }

    public void initDataPackets(int _nEEGValuesPerPacket, int _nAuxValuesPerPacket) {
        nEEGValuesPerPacket = _nEEGValuesPerPacket;
        nAuxValuesPerPacket = _nAuxValuesPerPacket;
        // For storing data into
        dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
        for(int i = 0; i < nEEGValuesPerPacket; i++) {
            dataPacket.values[i] = 0;
        }
        for(int i = 0; i < nAuxValuesPerPacket; i++){
            dataPacket.auxValues[i] = 0;
        }
    }

    public void processImpedance(JSONObject json) {
        int code = json.getInt(TCP_JSON_KEY_CODE);
        if (code == RESP_SUCCESS_DATA_IMPEDANCE) {
            int channel = json.getInt(TCP_JSON_KEY_CHANNEL_NUMBER);
            if (channel < 5) {
                int value = json.getInt(TCP_JSON_KEY_IMPEDANCE_VALUE);
                impedanceArray[channel] = value;
            }
        }
    }

    public void setSampleRate(int _sampleRate) {
        sampleRate = _sampleRate;
        hub.setSampleRate(sampleRate);
        println("Setting sample rate for Ganglion to " + sampleRate + "Hz");
    }

    public void setInterface(int _interface) {
        curInterface = _interface;
        if (isBLE()) {
            setSampleRate((int)fsHzBLE);
            if (_interface == INTERFACE_HUB_BLE) {
                hub.setProtocol(PROTOCOL_BLE);
            } else {
                hub.setProtocol(PROTOCOL_BLED112);
            }
            // hub.searchDeviceStart();
        } else if (isWifi()) {
            setSampleRate((int)fsHzWifi);
            hub.setProtocol(PROTOCOL_WIFI);
            hub.searchDeviceStart();
        }
    }

    // SCANNING/SEARCHING FOR DEVICES
    public int closePort() {
        if (isBLE()) {
            hub.disconnectBLE();
        } else if (isWifi()) {
            hub.disconnectWifi();
        }
        return 0;
    }

    /**
      * @description Sends a start streaming command to the Ganglion Node module.
      */
    void startDataTransfer(){
        hub.changeState(STATE_NORMAL);  // make sure it's now interpretting as binary
        println("Ganglion: startDataTransfer(): sending \'" + command_startBinary);
        if (checkingImpedance) {
            impedanceStop();
            delay(100);
            hub.sendCommand('b');
        } else {
            hub.sendCommand('b');
        }
    }

    /**
      * @description Sends a stop streaming command to the Ganglion Node module.
      */
    public void stopDataTransfer() {
        hub.changeState(STATE_STOPPED);  // make sure it's now interpretting as binary
        println("Ganglion: stopDataTransfer(): sending \'" + command_stop);
        hub.sendCommand('s');
    }

    // Channel setting
    //activate or deactivate an EEG channel...channel counting is zero through nchan-1
    public void changeChannelState(int Ichan, boolean activate) {
        if (isPortOpen()) {
            if ((Ichan >= 0)) {
                if (activate) {
                    println("Ganglion: changeChannelState(): activate: sending " + command_activate_channel[Ichan]);
                    hub.sendCommand(command_activate_channel[Ichan]);
                    w_timeSeries.hsc.powerUpChannel(Ichan);
                } else {
                    println("Ganglion: changeChannelState(): deactivate: sending " + command_deactivate_channel[Ichan]);
                    hub.sendCommand(command_deactivate_channel[Ichan]);
                    w_timeSeries.hsc.powerDownChannel(Ichan);
                }
            }
        }
    }

    /**
      * Used to start accel data mode. Accel arrays will arrive asynchronously!
      */
    public void accelStart() {
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_START);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_ACCEL);
        hub.writeJSON(json);
        println("Ganglion: accel: START");
        accelModeActive = true;
    }

    /**
      * Used to stop accel data mode. Some accel arrays may arrive after stop command
      *  was sent by this function.
      */
    public void accelStop() {
        println("Ganglion: accel: STOP");
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_STOP);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_ACCEL);
        hub.writeJSON(json);
        accelModeActive = false;
    }

    /**
      * Used to start impedance testing. Impedances will arrive asynchronously!
      */
    public void impedanceStart() {
        println("Ganglion: impedance: START");
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_START);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_IMPEDANCE);
        hub.writeJSON(json);
        checkingImpedance = true;
    }

    /**
      * Used to stop impedance testing. Some impedances may arrive after stop command
      *  was sent by this function.
      */
    public void impedanceStop() {
        println("Ganglion: impedance: STOP");
        JSONObject json = new JSONObject();
        json.setString(TCP_JSON_KEY_ACTION, TCP_ACTION_STOP);
        json.setString(TCP_JSON_KEY_TYPE, TCP_TYPE_IMPEDANCE);
        hub.writeJSON(json);
        checkingImpedance = false;
    }

    /**
      * Puts the ganglion in bootloader mode.
      */
    public void enterBootloaderMode() {
        println("Ganglion: Entering Bootloader Mode");
        hub.sendCommand(GANGLION_BOOTLOADER_MODE);
        delay(500);
        closePort();
        haltSystem();
        initSystemButton.setString("START SYSTEM");
        controlPanel.open();
        output("Ganglion now in bootloader mode! Enjoy!");
    }
};
