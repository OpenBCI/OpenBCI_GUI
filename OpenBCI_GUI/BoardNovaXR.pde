import brainflow.*;

import org.apache.commons.lang3.ArrayUtils;

class BoardNovaXR extends BoardBrainFlow {

    private final char[] activateChannelChars = {'1', '2', '3', '4', '5', '6', '7', '8', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'};
    private final char[] deactivateChannelChars = {'!', '@', '#', '$', '%', '^', '&', '*', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};
    private final char[] channelSelectForSettings = {'1', '2', '3', '4', '5', '6', '7', '8', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'};

    private String ipAddress = "";

    public BoardNovaXR(String ip) {
        super(BoardIds.NOVAXR_BOARD);
        ipAddress = ip;

        try {
            int[] eegChannels = BoardShim.get_eeg_channels(getBoardTypeInt());
            int[] emgChannels = BoardShim.get_emg_channels(getBoardTypeInt());

            // datachannels is set to eeg in the base class. we're re-setting it here because we want to
            // display emg data in the time series for NovaXR
            dataChannels = ArrayUtils.addAll(eegChannels, emgChannels);
        } catch (BrainFlowError e) {
            println("WARNING: failed to get data channels from BoardShim");
            e.printStackTrace();
        }
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.ip_address = ipAddress;
        params.ip_protocol = IpProtocolType.UDP.get_code();
        return params;
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        if (channelIndex >= getNumChannels()) {
            println("ERROR: Can't toggle channel " + (channelIndex + 1) + " when there are only " + getNumChannels() + "channels");
        }

        char[] charsToUse = active ? activateChannelChars : deactivateChannelChars;
        configBoard(str(charsToUse[channelIndex]));
    }

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
    }
};
