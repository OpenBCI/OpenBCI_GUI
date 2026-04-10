public final int NETWORKING_STREAMS_COUNT = 12;
public boolean networkingSettingsChanged = false;

public class NetworkingSettings {

    private NetworkStreamOut[] streams = new NetworkStreamOut[NETWORKING_STREAMS_COUNT];

    private NetworkingSettingsValues values;

    private NetworkProtocol activeNetworkProtocol = null;

    public NetworkingSettings() {
        values = new NetworkingSettingsValues();
    }

    public String getJson() {
        Gson gson = new GsonBuilder().create();
        return gson.toJson(values);
    }

    public void loadJson(String json) {
        Gson gson = new Gson();
        NetworkingSettingsValues newValues = gson.fromJson(json, NetworkingSettingsValues.class);
        if (newValues == null) {
            outputError("Error loading Networking Settings from JSON");
            return;
        }
        values = newValues;
        networkingSettingsChanged = true;
    }

    public boolean getNetworkingIsStreaming() {
        return activeNetworkProtocol != null;
    }

    public NetworkProtocol getActiveNetworkProtocol() {
        return activeNetworkProtocol;
    }

    public void initializeStreams() {
        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            NetworkDataType dataType = values.getDataType(i);
            if (dataType == NetworkDataType.NONE) {
                streams[i] = null;
                continue;
            }

            switch (values.protocol) {
                case OSC:
                    String baseAddress = "/openbci";
                    String oscIP = values.getOSCIp(i);
                    int oscPort = Integer.parseInt(values.getOSCPort(i));
                    streams[i] = new NetworkStreamOutOSC(dataType, oscIP, oscPort, baseAddress, i);
                    break;
                case UDP:
                    String udpIP = values.getUDPIp(i);
                    int udpPort = Integer.parseInt(values.getUDPPort(i));
                    streams[i] = new NetworkStreamOutUDP(dataType, udpIP, udpPort, i);
                    break;
                case LSL:
                    String lslName = values.getLSLName(i);
                    String lslType = values.getLSLType(i);
                    int numLslDataPoints = getDataTypeNumChanLSL(dataType);
                    streams[i] = new NetworkStreamOutLSL(dataType, lslName, lslType, numLslDataPoints, i);
                    break;
                case SERIAL:
                    if (i > 0) {
                        streams[i] = null;
                        continue;
                    }
                    String serialComPort = values.getSerialPort();
                    int serialBaudRate = Integer.parseInt(values.getSerialBaud());
                    streams[i] = new NetworkStreamOutSerial(dataType, serialComPort, serialBaudRate, ourApplet);
                    break;
            }
        }
    }

    public void startNetwork() {
        activeNetworkProtocol = values.getProtocol();
        for (NetworkStreamOut stream : streams) {
            if (stream != null) {
                stream.start();
            }
        }
    }

    public void stopNetwork() {
        activeNetworkProtocol = null;
        for (NetworkStreamOut stream : streams) {
            if (stream != null) {
                stream.quit();
                stream = null;
            }
        }
    }

    private int getDataTypeNumChanLSL(NetworkDataType dataType) {
        switch (dataType) {
            case TIME_SERIES_FILTERED:
            case TIME_SERIES_RAW:
            case EMG:
                return currentBoard.getNumEXGChannels();
            case FOCUS:
            case MARKER:
                return 1;
            case FFT:
                return 125;
            case AVG_BAND_POWERS:
                return 5;
            case BAND_POWERS:
                //Send out band powers for each channel sequentially
                //Prepend channel number to each array
                return 5 + 1;
            case PULSE:
            case EMG_JOYSTICK:
                return 2;
            case ACCEL_AUX:
                if (currentBoard instanceof AccelerometerCapableBoard) {
                    AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                    if (accelBoard.isAccelerometerActive()) {
                        return accelBoard.getAccelerometerChannels().length;
                    }
                }
                if (currentBoard instanceof AnalogCapableBoard) {
                    AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                    if (analogBoard.isAnalogActive()) {
                        return analogBoard.getAnalogChannels().length;
                    }
                }
                if (currentBoard instanceof DigitalCapableBoard) {
                    DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                    if (digitalBoard.isDigitalActive()) {
                        return digitalBoard.getDigitalChannels().length;
                    }
                }
            default:
                throw new IllegalArgumentException("IllegalArgumentException: Error detecting number of channels for LSL stream data... please fix!");
        }
    }

    public NetworkingSettingsValues getValues() {
        return values;
    }
}

public class NetworkingSettingsValues {

    private NetworkProtocol protocol;
    
    private final NetworkDataType[] DATA_TYPES = new NetworkDataType[NETWORKING_STREAMS_COUNT];
    private LinkedList<String> dataTypeNames;

    private final String[] OSC_IPS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] OSC_PORTS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] OSC_IP_DEFAULTS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] OSC_PORT_DEFAULTS = new String[NETWORKING_STREAMS_COUNT];

    private final String[] UDP_IPS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] UDP_PORTS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] UDP_IP_DEFAULTS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] UDP_PORT_DEFAULTS = new String[NETWORKING_STREAMS_COUNT];

    private final String[] LSL_NAMES = new String[NETWORKING_STREAMS_COUNT];
    private final String[] LSL_TYPES = new String[NETWORKING_STREAMS_COUNT];
    private final String[] LSL_NAME_DEFAULTS = new String[NETWORKING_STREAMS_COUNT];
    private final String[] LSL_TYPE_DEFAULTS = new String[NETWORKING_STREAMS_COUNT];

    private LinkedList<String> baudRates = new LinkedList<String>(Arrays.asList("57600", "115200", "250000", "500000"));
    private String baudRate = baudRates.get(0);
    private String serialPort = "None";

    public NetworkingSettingsValues() {
        protocol = NetworkProtocol.UDP;

        initDataTypeNames();
        initTextfieldDefaults();
        initDataTypeDefaults();
    }
   
    private void initDataTypeDefaults() {
        DATA_TYPES[0] = NetworkDataType.TIME_SERIES_FILTERED;
        DATA_TYPES[1] = NetworkDataType.AVG_BAND_POWERS;
        DATA_TYPES[2] = NetworkDataType.BAND_POWERS;
        DATA_TYPES[3] = NetworkDataType.FFT;
        DATA_TYPES[4] = NetworkDataType.EMG;
        DATA_TYPES[5] = NetworkDataType.EMG_JOYSTICK;
        DATA_TYPES[6] = NetworkDataType.FOCUS;
        DATA_TYPES[7] = NetworkDataType.MARKER;
        DATA_TYPES[8] = NetworkDataType.ACCEL_AUX;
        DATA_TYPES[9] = NetworkDataType.NONE;
        DATA_TYPES[10] = NetworkDataType.NONE;
        DATA_TYPES[11] = NetworkDataType.NONE;
        if (currentBoard instanceof BoardCyton) {
            DATA_TYPES[9] = NetworkDataType.PULSE;
        }
    }

    private void initDataTypeNames() {
        dataTypeNames = new LinkedList<String>(Arrays.asList(
            NetworkDataType.NONE.getString(),
            NetworkDataType.TIME_SERIES_FILTERED.getString(),
            NetworkDataType.AVG_BAND_POWERS.getString(),
            NetworkDataType.BAND_POWERS.getString(),
            NetworkDataType.FFT.getString(),
            NetworkDataType.EMG.getString(),
            NetworkDataType.EMG_JOYSTICK.getString(),
            NetworkDataType.FOCUS.getString(),
            NetworkDataType.MARKER.getString(),
            NetworkDataType.ACCEL_AUX.getString(),
            NetworkDataType.TIME_SERIES_RAW.getString(),
            NetworkDataType.PULSE.getString()
        ));
        if (!(currentBoard instanceof BoardCyton)) {
            dataTypeNames.remove(NetworkDataType.PULSE.getString());
        }
    }

    private void initTextfieldDefaults() {
        final int STARTING_PORT = 12345;

        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            LSL_TYPE_DEFAULTS[i] = "EXG";
        }

        LSL_TYPE_DEFAULTS[1] = "EEG";
        LSL_TYPE_DEFAULTS[2] = "EEG";
        LSL_TYPE_DEFAULTS[3] = "FFT";
        LSL_TYPE_DEFAULTS[4] = "EMG";
        LSL_TYPE_DEFAULTS[5] = "EMG";
        LSL_TYPE_DEFAULTS[6] = "FOCUS";
        LSL_TYPE_DEFAULTS[7] = "MARKER";
        LSL_TYPE_DEFAULTS[8] = "AUX";
        if (currentBoard instanceof BoardCyton) {
            LSL_TYPE_DEFAULTS[9] = "PULSE";
        }

        for (int i = 0; i < NETWORKING_STREAMS_COUNT; i++) {
            OSC_IP_DEFAULTS[i] = "127.0.0.1";
            OSC_PORT_DEFAULTS[i] = Integer.toString(STARTING_PORT + i);
            UDP_IP_DEFAULTS[i] = "127.0.0.1";
            UDP_PORT_DEFAULTS[i] = Integer.toString(STARTING_PORT + i);
            LSL_NAME_DEFAULTS[i] = "obci_stream_" + i;

            OSC_IPS[i] = OSC_IP_DEFAULTS[i];
            OSC_PORTS[i] = OSC_PORT_DEFAULTS[i];
            UDP_IPS[i] = UDP_IP_DEFAULTS[i];
            UDP_PORTS[i] = UDP_PORT_DEFAULTS[i];
            LSL_NAMES[i] = LSL_NAME_DEFAULTS[i];
            LSL_TYPES[i] = LSL_TYPE_DEFAULTS[i];
        }
    }

    public NetworkProtocol getProtocol() {
        return protocol;
    }

    public LinkedList<String> getAllDataTypeNames() {
        return dataTypeNames;
    }

    public NetworkDataType getDataType(int i) {
        return DATA_TYPES[i];
    }

    public String getOSCIp(int i) {
        return OSC_IPS[i];
    }

    public String getOSCPort(int i) {
        return OSC_PORTS[i];
    }

    public String getUDPIp(int i) {
        return UDP_IPS[i];
    }

    public String getUDPPort(int i) {
        return UDP_PORTS[i];
    }

    public String getLSLName(int i) {
        return LSL_NAMES[i];
    }

    public String getLSLType(int i) {
        return LSL_TYPES[i];
    }

    public LinkedList<String> getBaudRateList() {
        return baudRates;
    }

    public String getSerialBaud() {
        return baudRate;
    }

    public String getSerialPort() {
        return serialPort;
    }

    public void setProtocol(int i) {
        protocol = NetworkProtocol.getByIndex(i);
    }

    public void setDataType(int i, int value) {
        DATA_TYPES[i] = NetworkDataType.getByString(dataTypeNames.get(value));
    }

    public void setOSCIp(int i, String ip) {
        OSC_IPS[i] = ip;
    }

    public void setOSCPort(int i, String port) {
        OSC_PORTS[i] = port;
    }

    public void setUDPIp(int i, String ip) {
        UDP_IPS[i] = ip;
    }

    public void setUDPPort(int i, String port) {
        UDP_PORTS[i] = port;
    }

    public void setLSLName(int i, String name) {
        LSL_NAMES[i] = name;
    }

    public void setLSLType(int i, String type) {
        LSL_TYPES[i] = type;
    }

    public void setSerialPort(String port) {
        serialPort = port;
    }

    public void setSerialBaud(String _baudRate) {
        baudRate = _baudRate;
    }
}