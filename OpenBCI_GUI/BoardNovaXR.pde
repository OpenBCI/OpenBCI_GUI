import brainflow.*;

import org.apache.commons.lang3.ArrayUtils;

final boolean novaXREnabled = true;

public enum NovaXRMode
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
 
    public String getName() {
        return name;
    }

    public String getCommand() {
        return command;
    }
}

class BoardNovaXR extends BoardBrainFlow
implements ImpedanceSettingsBoard, EDACapableBoard, PPGCapableBoard {

    private final char[] deactivateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] activateChannelChars = {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    private final char[] channelSelectForSettings = {'1', '2', '3', '4', '5', '6', '7', '8', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

    private double[] scalers = null;
    private Map<Character, Integer> gainCommandMap = new HashMap<Character, Integer>() {{
        put('0', 1);
        put('1', 2);
        put('2', 4);
        put('3', 6);
        put('4', 8);
        put('5', 12);
        put('6', 24);
    }};
    // same for all channels for now, more likely will be a map soon
    private final double brainflowGain = 24.0;

    private int[] edaChannelsCache = null;
    private int[] ppgChannelsCache = null;

    private boolean[] exgChannelActive;

    private BoardIds boardId = BoardIds.NOVAXR_BOARD;

    public BoardNovaXR() {
        super();
        scalers = new double[getNumEXGChannels()];
        for (int i = 0; i < scalers.length; i++) {
            scalers[i] = 1.0;
        }
    }

    @Override
    public boolean initializeInternal() {        
        exgChannelActive = new boolean[getNumEXGChannels()];
        Arrays.fill(exgChannelActive, true);

        return super.initializeInternal();
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
        char[] charsToUse = active ? activateChannelChars : deactivateChannelChars;
        configBoard(str(charsToUse[channelIndex]));
        exgChannelActive[channelIndex] = active;
    }
    
    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return exgChannelActive[channelIndex];
    }

    @Override
    public void setImpedanceSettings(int channel, char pORn, boolean active) {
        char p = '0';
        char n = '0';

        if (active) {
            if (pORn == 'p') {
                p = '1';
            }
            else if (pORn == 'n') {
                n = '1';
            }
        }

        // for example: z 4 1 0 Z
        String command = String.format("z%c%c%cZ", channelSelectForSettings[channel], p, n);
        configBoard(command);
    }

    @Override
    protected double[][] getNewDataInternal() {
        double[][] data = super.getNewDataInternal();
        int[] exgChannels = getEXGChannels();
        for (int i = 0; i < exgChannels.length; i++) {
            for (int j = 0; j < data[exgChannels[i]].length; j++) {
                data[exgChannels[i]][j] *= scalers[i];
            }
        }
        return data;
    }

    public void setChannelSettings(int channel, char[] channelSettings) {
        char powerDown = channelSettings[0];
        char gain = channelSettings[1];
        char inputType = channelSettings[2];
        char bias = channelSettings[3];
        char srb2 = channelSettings[4];
        char srb1 = channelSettings[5];

        String command = String.format("x%c%c%c%c%c%c%cX", channelSelectForSettings[channel],
                                        powerDown, gain, inputType, bias, srb2, srb1);
        configBoard(command);
        scalers[channel] = brainflowGain / gainCommandMap.get(gain);
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
