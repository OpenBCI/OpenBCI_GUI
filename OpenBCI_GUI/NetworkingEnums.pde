public enum NetworkProtocol implements IndexingInterface {
    UDP (0, "UDP"),
    OSC (1, "OSC"),
    LSL (2, "LSL"),
    SERIAL (3, "Serial");

    private int index;
    private String label;
    private static final NetworkProtocol[] VALUES = values();

    NetworkProtocol(int index, String label) {
        this.index = index;
        this.label = label;
    }

    public int getIndex() {
        return index;
    }

    public String getString() {
        return label;
    }

    public static NetworkProtocol getByIndex(int _index) {
        for (NetworkProtocol protocol : NetworkProtocol.values()) {
            if (protocol.getIndex() == _index) {
                return protocol;
            }
        }
        return null;
    }

    public static NetworkProtocol getByString(String _name) {
        for (NetworkProtocol protocol : NetworkProtocol.values()) {
            if (protocol.getString() == _name) {
                return protocol;
            }
        }
        return null;
    }
}

public enum NetworkDataType implements IndexingInterface {
    NONE (-1, "None", null, null),
    TIME_SERIES_FILTERED (0, "TimeSeriesFilt", "timeSeriesFiltered", "time-series-filtered"),
    TIME_SERIES_RAW (1, "TimeSeriesRaw", "timeSeriesRaw", "time-series-raw"),
    FOCUS (2, "Focus", "focus", "focus"),
    FFT (3, "FFT", "fft", "fft"),
    EMG (4, "EMG", "emg", "emg"),
    AVG_BAND_POWERS (5, "AvgBandPowers", "avgBandPowers", "avg-band-powers"),
    BAND_POWERS (6, "BandPowers", "bandPowers", "band-powers"),
    ACCEL_AUX (7, "AccelAux", "accelAux", "accel-aux"),
    PULSE (8, "Pulse", "pulse", "pulse"),
    EMG_JOYSTICK (9, "EMGJoystick", "emgJoystick", "emg-joystick"),
    MARKER (10, "Marker", "marker", "marker");

    private int index;
    private String label;
    private String udpKey;
    private String oscKey;
    private static final NetworkDataType[] VALUES = values();

    NetworkDataType(int index, String label, String udpKey, String oscKey) {
        this.index = index;
        this.label = label;
        this.udpKey = udpKey;
        this.oscKey = oscKey;
    }

    public int getIndex() {
        return index;
    }

    public String getString() {
        return label;
    }

    public String getUDPKey() {
        return udpKey;
    }

    public String getOSCKey() {
        return oscKey;
    }

    public static NetworkDataType getByString(String _name) {
        for (NetworkDataType dataType : NetworkDataType.values()) {
            if (dataType.getString() == _name) {
                return dataType;
            }
        }
        return null;
    }
} 