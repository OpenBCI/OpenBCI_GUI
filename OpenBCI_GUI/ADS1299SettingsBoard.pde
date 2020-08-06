
interface ADSSettingsEnum {
    public String getName();
    public ADSSettingsEnum getNext();
}

enum PowerDown implements ADSSettingsEnum {
    ON("Active"),
    OFF("Inactive");

    private String name;

    PowerDown(String _name) {
        this.name = _name;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public PowerDown getNext() {
        PowerDown[] vals = values();
        return vals[(this.ordinal()+1) % vals.length];
    }
}

// the scalar values are actually used to scale eeg data
enum Gain implements ADSSettingsEnum {
    X1("x1", 1.0),
    X2("x2", 2.0),
    X4("x4", 4.0),
    X6("x6", 6.0),
    X8("x8", 8.0),
    X12("x12", 12.0),
    X24("x24", 24.0);

    private String name;
    private double scalar;

    Gain(String _name, double _scalar) {
        this.name = _name;
        this.scalar = _scalar;

    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public Gain getNext() {
        Gain[] vals = values();
        return vals[(this.ordinal()+1) % vals.length];
    }

    public double getScalar() {
        return scalar;
    }
}

enum InputType implements ADSSettingsEnum {
    NORMAL("Normal"),
    SHORTED("Shorted"),
    BIAS_MEAS("Bias Meas"),
    MVDD("MVDD"),
    TEMP("Temp"),
    TEST("Test"),
    BIAS_DRP("BIAS DRP"),
    BIAS_DRN("BIAS DRN");

    private String name;

    InputType(String _name) {
        this.name = _name;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public InputType getNext() {
        InputType[] vals = values();
        return vals[(this.ordinal()+1) % vals.length];
    }
}

enum Bias implements ADSSettingsEnum {
    NO_INCLUDE("Don't Include"),
    INCLUDE("Include");

    private String name;

    Bias(String _name) {
        this.name = _name;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public Bias getNext() {
        Bias[] vals = values();
        return vals[(this.ordinal()+1) % vals.length];
    }
}

enum Srb2 implements ADSSettingsEnum {
    DISCONNECT("Off"),
    CONNECT("On");

    private String name;

    Srb2(String _name) {
        this.name = _name;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public Srb2 getNext() {
        Srb2[] vals = values();
        return vals[(this.ordinal()+1) % vals.length];
    }
}

enum Srb1 implements ADSSettingsEnum {
    DISCONNECT("Off"),
    CONNECT("On");

    private String name;

    Srb1(String _name) {
        this.name = _name;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public Srb1 getNext() {
        Srb1[] vals = values();
        return vals[(this.ordinal()+1) % vals.length];
    }
}

class ADS1299Settings {
    protected PowerDown[] powerDown;
    protected Gain[] gain;
    protected InputType[] inputType;
    protected Bias[] bias;
    protected Srb2[] srb2;
    protected Srb1[] srb1;

    protected Board board;
    protected ADS1299SettingsBoard settingsBoard;

    private Bias[] previousBias;
    private Srb2[] previousSrb2; 

    ADS1299Settings(Board theBoard) {
        board = theBoard;
        settingsBoard = (ADS1299SettingsBoard)theBoard;

        int channelCount = board.getNumEXGChannels();

        // initialize all arrays with some defaults
        // (which happen to be Cyton defaults, but they don't have to be.
        // we set defaults on board contruction)
        powerDown = new PowerDown[channelCount];
        Arrays.fill(powerDown, PowerDown.ON);

        gain = new Gain[channelCount];
        Arrays.fill(gain, Gain.X24);

        inputType = new InputType[channelCount];
        Arrays.fill(inputType, InputType.NORMAL);
        
        bias = new Bias[channelCount];
        Arrays.fill(bias, Bias.INCLUDE);

        srb2 = new Srb2[channelCount];
        Arrays.fill(srb2, Srb2.CONNECT);

        srb1 = new Srb1[channelCount];
        Arrays.fill(srb1, Srb1.DISCONNECT);

        previousBias = bias.clone();
        previousSrb2 = srb2.clone();
    }

    public boolean isChannelActive(int chan) {
        return powerDown[chan] == PowerDown.ON;
    }

    public void setChannelActive(int chan, boolean active) {
        if (active) {
            bias[chan] = previousBias[chan];
            srb2[chan] = previousSrb2[chan];

        } else {
            previousBias[chan] = bias[chan];
            previousSrb2[chan] = srb2[chan];

            bias[chan] = Bias.NO_INCLUDE;
            srb2[chan] = Srb2.DISCONNECT;
        }

        powerDown[chan] = active ? PowerDown.ON : PowerDown.OFF;
        commit(chan);
    }

    public void commit(int chan) {
        String command = String.format("x%c%d%d%d%d%d%dX", settingsBoard.getChannelSelector(chan),
                                        powerDown[chan].ordinal(), gain[chan].ordinal(),
                                        inputType[chan].ordinal(), bias[chan].ordinal(),
                                        srb2[chan].ordinal(), srb1[chan].ordinal());

        board.sendCommand(command);
    }

    public void commitAll() {
        for (int i=0; i<board.getNumEXGChannels(); i++) {
            commit(i);
        }
    }
}


interface ADS1299SettingsBoard {

    // Interface methods
    public ADS1299Settings getADS1299Settings();
    public char getChannelSelector(int channel);
    public double getGain(int channel);
    public void setDynamicScaler(boolean val);
    public boolean getDynamicScaler();
};
