import brainflow.*;

import org.apache.commons.lang3.ArrayUtils;

final boolean novaXREnabled = true;

interface NovaXRSettingsEnum {
    public String getName();
    public String getCommand();
}

public enum NovaXRSR implements NovaXRSettingsEnum
{
    SR_250("250Hz", null), 
    SR_500("500Hz", null), 
    SR_1000("1000Hz", null);

    private String name;
    private String command;
 
    NovaXRSR(String _name, String _command) {
        this.name = _name;
        this.command = _command;
    }
 
    @Override
    public String getName() {
        return name;
    }

    @Override
    public String getCommand() {
        return command;
    }
}

public enum NovaXRMode implements NovaXRSettingsEnum
{
    DEFAULT("Default Mode", "d"), 
    INTERNAL_SIGNAL("Internal Signal", "f"), 
    EXTERNAL_SIGNAL("External Signal", "g"), 
    PRESET4("Preset 4", "h"),
    PRESET5("Preset 5", "j");

    private String name;
    private String command;
 
    NovaXRMode(String _name, String _command) {
        this.name = _name;
        this.command = _command;
    }
 
    @Override
    public String getName() {
        return name;
    }

    @Override
    public String getCommand() {
        return command;
    }
}

class NovaXRDefaultSettings extends ADS1299Settings {
    // TODO: modes go here
    NovaXRDefaultSettings(Board theBoard, NovaXRMode mode) {
        super(theBoard);

        // send the mode command to board
        board.sendCommand(mode.getCommand());

        Arrays.fill(powerDown, PowerDown.ON);

        switch(mode) {
            case DEFAULT:
                Arrays.fill(gain, 0, 8, Gain.X8); // channels 1-8 with gain x8
                Arrays.fill(gain, 8, 14, Gain.X4); // 9-14 with gain x4
                Arrays.fill(gain, 14, 16, Gain.X12); // 15-16 with gain x12
                
                Arrays.fill(inputType, InputType.NORMAL);

                // channels 9-14 don't include, all other channels include
                Arrays.fill(bias, Bias.INCLUDE);
                Arrays.fill(bias, 8, 14, Bias.NO_INCLUDE);

                // channels 9-14 Connect, all other channels disconnect
                Arrays.fill(srb2, Srb2.CONNECT);
                Arrays.fill(srb2, 8, 14, Srb2.DISCONNECT);

                Arrays.fill(srb1, Srb1.DISCONNECT);

                break;

            case INTERNAL_SIGNAL:
                Arrays.fill(gain, Gain.X1);
                Arrays.fill(inputType, InputType.TEST);
                Arrays.fill(bias, Bias.NO_INCLUDE);
                Arrays.fill(srb2, Srb2.DISCONNECT);
                Arrays.fill(srb1, Srb1.DISCONNECT);
                break;

            case EXTERNAL_SIGNAL:
                Arrays.fill(gain, Gain.X1);
                Arrays.fill(inputType, InputType.NORMAL);
                Arrays.fill(bias, Bias.NO_INCLUDE);
                Arrays.fill(srb2, Srb2.DISCONNECT);
                Arrays.fill(srb1, Srb1.DISCONNECT);
                break;

            case PRESET4:
                // TODO[NovaXR] This mode is not defined yet
                break;

            case PRESET5:
                // TODO[NovaXR] This mode is not defined yet
                break;

            default:
                break;
        }
    }
}

class BoardNovaXR extends BoardBrainFlow
implements ImpedanceSettingsBoard, EDACapableBoard, PPGCapableBoard, ADS1299SettingsBoard{

    private final char[] channelSelectForSettings = {'1', '2', '3', '4', '5', '6', '7', '8', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

    private ADS1299Settings currentADS1299Settings;
    private boolean[] isCheckingImpedance;

    private int[] edaChannelsCache = null;
    private int[] ppgChannelsCache = null;

    private BoardIds boardId = BoardIds.NOVAXR_BOARD;
    private NovaXRMode initialSettingsMode;

    private final NovaXRDefaultSettings defaultSettings;

    public BoardNovaXR(NovaXRMode mode) {
        super();

        isCheckingImpedance = new boolean[getNumEXGChannels()];
        Arrays.fill(isCheckingImpedance, false);

        initialSettingsMode = mode;

        // store a copy of the default settings. This will be used to undo brainflow's
        // gain scaling to re-scale in gui
        defaultSettings = new NovaXRDefaultSettings(this, NovaXRMode.DEFAULT);
    }

    @Override
    public boolean initializeInternal() {        
        boolean res = super.initializeInternal();

        if (res) {
            // NovaXRDefaultSettings() will send mode command to board
            currentADS1299Settings = new NovaXRDefaultSettings(this, initialSettingsMode);
        }

        return res;
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        return params;
    }

    @Override
    public BoardIds getBoardId() {
        return boardId;
    }

    @Override
    public void setEXGChannelActive(int channelIndex, boolean active) {
        currentADS1299Settings.powerDown[channelIndex] = active ? PowerDown.ON : PowerDown.OFF;
        currentADS1299Settings.commit(channelIndex);
    }
    
    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return currentADS1299Settings.powerDown[channelIndex] == PowerDown.ON;
    }
    
    @Override
    public void setCheckingImpedance(int channel, boolean active) {
        char p = '0';
        char n = '0';

        if (active) {
            Srb2 srb2sSetting = currentADS1299Settings.srb2[channel];
            if (srb2sSetting == Srb2.CONNECT) {
                n = '1';
            }
            else {
                p = '1';
            }
        }

        // for example: z 4 1 0 Z
        String command = String.format("z%c%c%cZ", channelSelectForSettings[channel], p, n);
        sendCommand(command);

        isCheckingImpedance[channel] = active;
    }

    @Override
    public boolean isCheckingImpedance(int channel) {
        return isCheckingImpedance[channel];
    }

    @Override
    protected double[][] getNewDataInternal() {
        double[][] data = super.getNewDataInternal();
        int[] exgChannels = getEXGChannels();
        for (int i = 0; i < exgChannels.length; i++) {
            for (int j = 0; j < data[exgChannels[i]].length; j++) {
                // brainflow assumes default gain. Undo brainflow's scaling and apply new scale.
                double brainflowGain = defaultSettings.gain[i].getScalar();
                double scalar = brainflowGain / currentADS1299Settings.gain[i].getScalar();
                data[exgChannels[i]][j] *= scalar;
            }
        }
        return data;
    }

    @Override
    public ADS1299Settings getADS1299Settings() {
        return currentADS1299Settings;
    }

    @Override
    public char getChannelSelector(int channel) {
        return channelSelectForSettings[channel];
    }

    @Override
    public boolean isPPGActive() {
        return true;
    }

    @Override
    public void setPPGActive(boolean active) {
        outputWarn("PPG is always active for BoardNovaXR");
    }

    @Override
    public int[] getPPGChannels() {
        if (ppgChannelsCache == null) {
            try {
                ppgChannelsCache = BoardShim.get_ppg_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return ppgChannelsCache;
    }

    @Override
    public boolean isEDAActive() {
        return true;
    }

    @Override
    public void setEDAActive(boolean active) {
        outputWarn("EDA is always active for BoardNovaXR");
    }

    @Override
    public int[] getEDAChannels() {
        if (edaChannelsCache == null) {
            try {
                edaChannelsCache = BoardShim.get_eda_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return edaChannelsCache;
    }
    
    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        for (int i=0; i<getEDAChannels().length; i++) {
            channelNames[getEDAChannels()[i]] = "EDA Channel " + i;
        }
        for (int i=0; i<getPPGChannels().length; i++) {
            channelNames[getPPGChannels()[i]] = "PPG Channel " + i;
        }
    }
};
