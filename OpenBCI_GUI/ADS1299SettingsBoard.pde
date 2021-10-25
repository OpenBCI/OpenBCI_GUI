import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.*;


interface ADSSettingsEnum {
    public String getName();
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
}

enum Bias implements ADSSettingsEnum {
    NO_INCLUDE("No"),
    INCLUDE("Yes");

    private String name;

    Bias(String _name) {
        this.name = _name;
    }

    @Override
    public String getName() {
        return name;
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
}

public class ADS1299SettingsValues {
    public PowerDown[] powerDown;
    public Gain[] gain;
    public InputType[] inputType;
    public Bias[] bias;
    public Srb2[] srb2;
    public Srb1[] srb1;

    //Used for Channel On/Off to reflect what happens in Firmware
    public Bias[] previousBias;
    public Srb2[] previousSrb2;
    public InputType[] previousInputType;

    public ADS1299SettingsValues() {
    }
}

class ADS1299Settings {
    
    public ADS1299SettingsValues values;
    public ADS1299SettingsValues previousValues;

    protected Board board;
    protected ADS1299SettingsBoard settingsBoard;

    ADS1299Settings(Board theBoard) {
        board = theBoard;
        settingsBoard = (ADS1299SettingsBoard)theBoard;
        values = new ADS1299SettingsValues();
        previousValues = new ADS1299SettingsValues();

        int channelCount = board.getNumEXGChannels();

        // initialize all arrays with some defaults
        // (which happen to be Cyton defaults, but they don't have to be.
        // we set defaults on board contruction)
        values.powerDown = new PowerDown[channelCount];
        previousValues.powerDown = new PowerDown[channelCount];
        Arrays.fill(values.powerDown, PowerDown.ON);

        values.gain = new Gain[channelCount];
        previousValues.gain = new Gain[channelCount];
        Arrays.fill(values.gain, Gain.X24);

        values.inputType = new InputType[channelCount];
        previousValues.inputType = new InputType[channelCount];
        Arrays.fill(values.inputType, InputType.NORMAL);
        
        values.bias = new Bias[channelCount];
        previousValues.bias = new Bias[channelCount];
        Arrays.fill(values.bias, Bias.INCLUDE);

        values.srb2 = new Srb2[channelCount];
        previousValues.srb2 = new Srb2[channelCount];
        Arrays.fill(values.srb2, Srb2.CONNECT);

        values.srb1 = new Srb1[channelCount];
        previousValues.srb1 = new Srb1[channelCount];
        Arrays.fill(values.srb1, Srb1.DISCONNECT);

        values.previousBias = values.bias.clone();
        values.previousSrb2 = values.srb2.clone();
        values.previousInputType = values.inputType.clone();
    }

    public boolean loadSettingsValues(String filename) {
        try {
            File file = new File(filename);
            StringBuilder fileContents = new StringBuilder((int)file.length());        
            Scanner scanner = new Scanner(file);
            while(scanner.hasNextLine()) {
                fileContents.append(scanner.nextLine() + System.lineSeparator());
            }
            Gson gson = new Gson();
            values = gson.fromJson(fileContents.toString(), ADS1299SettingsValues.class);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getJson() {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        return gson.toJson(values);
    }

    public boolean saveToFile(String filename) {
        String json = getJson();
        try {
            FileWriter writer = new FileWriter(filename);
            writer.write(json);
            writer.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isChannelActive(int chan) {
        return values.powerDown[chan] == PowerDown.ON;
    }

    public void setChannelActive(int chan, boolean active) {
        String oldValues = getJson();
        if (active) {
            values.bias[chan] = values.previousBias[chan];
            values.srb2[chan] = values.previousSrb2[chan];
            values.inputType[chan] = values.previousInputType[chan];
        } else {
            values.previousBias[chan] = values.bias[chan];
            values.previousSrb2[chan] = values.srb2[chan];
            values.previousInputType[chan] = values.inputType[chan];

            values.bias[chan] = Bias.NO_INCLUDE;
            values.srb2[chan] = Srb2.DISCONNECT;
            values.inputType[chan] = InputType.SHORTED;
        }

        values.powerDown[chan] = active ? PowerDown.ON : PowerDown.OFF;
        boolean res = commit(chan);
        if (!res) {
            // restore old settings in UI
            Gson gson = new Gson();
            values = gson.fromJson(oldValues, ADS1299SettingsValues.class);
        }
    }

    //Return true if sendCommand is successful
    public boolean commit(int chan) {
        String command = String.format("x%c%d%d%d%d%d%dX", settingsBoard.getChannelSelector(chan),
                                        values.powerDown[chan].ordinal(), values.gain[chan].ordinal(),
                                        values.inputType[chan].ordinal(), values.bias[chan].ordinal(),
                                        values.srb2[chan].ordinal(), values.srb1[chan].ordinal());

        return board.sendCommand(command).getKey().booleanValue();
    }

    //Return true if all commits are successful
    public boolean[] commitAll() {
        int numChan = board.getNumEXGChannels();
        boolean[] success = new boolean[numChan];
        for (int i=0; i<numChan; i++) {
            success[i] = commit(i);
        }
        return success;
    }

    public void saveAllLastValues() {
        String lastVals = getJson();
        Gson gson = new Gson();
        previousValues = gson.fromJson(lastVals, ADS1299SettingsValues.class);
    }

    public void saveLastValues(int chan) {
        previousValues.gain[chan] = values.gain[chan];
        previousValues.inputType[chan] = values.inputType[chan];
        previousValues.bias[chan] = values.bias[chan];
        previousValues.srb2[chan] = values.srb2[chan];
        previousValues.srb1[chan] = values.srb1[chan];
    }

    public void revertToLastValues(int chan) {
        values.gain[chan] = previousValues.gain[chan];
        values.inputType[chan] = previousValues.inputType[chan];
        values.bias[chan] = previousValues.bias[chan];
        values.srb2[chan] = previousValues.srb2[chan];
        values.srb1[chan] = previousValues.srb1[chan];
    }

    public boolean equalsLastValues(int chan) {        
        boolean equal = previousValues.gain[chan] == values.gain[chan] &&
                        previousValues.inputType[chan] == values.inputType[chan] &&
                        previousValues.bias[chan] == values.bias[chan] &&
                        previousValues.srb2[chan] == values.srb2[chan] &&
                        previousValues.srb1[chan] == values.srb1[chan]
                        ;
        return equal;
    }

    //Get previous or current values as a string
    public String getValuesString(int chan, ADS1299SettingsValues vals) {
        String commandString = String.format("x%c%d%d%d%d%d%dX", settingsBoard.getChannelSelector(chan),
                                        vals.powerDown[chan].ordinal(), vals.gain[chan].ordinal(),
                                        vals.inputType[chan].ordinal(), vals.bias[chan].ordinal(),
                                        vals.srb2[chan].ordinal(), vals.srb1[chan].ordinal());
        return commandString;
    }
}

interface ADS1299SettingsBoard {

    // Interface methods
    public ADS1299Settings getADS1299Settings();
    public char getChannelSelector(int channel);
    public double getGain(int channel);
    public void setUseDynamicScaler(boolean val);
    public boolean getUseDynamicScaler();
};
