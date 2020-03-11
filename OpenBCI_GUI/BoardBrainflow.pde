import brainflow.*;
import java.util.*;
import org.apache.commons.lang3.SystemUtils;

abstract class BoardBrainFlow implements Board {
    private DataPacket_ADS1299 dataPacket;
    private BoardShim boardShim = null;

    protected int samplingRate = 0;
    protected int packetNumberChannel = 0;
    protected int[] dataChannels = {};
    protected int[] accelChannels = {};

    protected boolean streaming = false;
    protected float[] lastAccelValues = {};
    protected float[] lastValidAccelValues = {};

    /* Abstract Functions.
     * Implement these in your board.
     */
    abstract protected BrainFlowInputParams getParams();
    abstract public BoardIds getBoardId();

    protected BoardBrainFlow() {
    }

    protected int[] getEXGChannels() throws BrainFlowError{
        int[] channels;
        // for some boards there can be duplicates
        SortedSet<Integer> set = new TreeSet<Integer>();
        // maybe it will be nice to add method like get_exg_channels to brainflow to avoid this ugly code?
        // but I doubt that smth else will need it and in python I know how to implement it better using existing API
        try {
            channels = BoardShim.get_eeg_channels(getBoardIdInt());
            for(int i = 0; i < channels.length; i++) {
                set.add(channels[i]);
            }
        } catch (BrainFlowError e) {
            println("WARNING: failed to get eeg channels from BoardShim");
        }
        try {
            channels = BoardShim.get_emg_channels(getBoardIdInt());
            for(int i = 0; i < channels.length; i++) {
                set.add(channels[i]);
            }
        } catch (BrainFlowError e) {
            println("WARNING: failed to get emg channels from BoardShim");
        }
        try {
            channels = BoardShim.get_ecg_channels(getBoardIdInt());
            for(int i = 0; i < channels.length; i++) {
                set.add(channels[i]);
            }
        } catch (BrainFlowError e) {
            println("WARNING: failed to get ecg channels from BoardShim");
        }
        try {
            channels = BoardShim.get_eog_channels(getBoardIdInt());
            for(int i = 0; i < channels.length; i++) {
                set.add(channels[i]);
            }
        } catch (BrainFlowError e) {
            println("WARNING: failed to get eog channels from BoardShim");
        }
        Integer[] toArray = set.toArray(new Integer[set.size()]);
        int[] primitives = new int[toArray.length];
        for (int i = 0; i < toArray.length; i++) {
            primitives[i] = toArray[i].intValue();
        }

        return primitives;
    }

    @Override
    public boolean initialize() {
        try {
            samplingRate = BoardShim.get_sampling_rate(getBoardIdInt());
            packetNumberChannel = BoardShim.get_package_num_channel(getBoardIdInt());
            dataChannels = getEXGChannels();
            accelChannels = BoardShim.get_accel_channels(getBoardIdInt());
        } catch (BrainFlowError e) {
            println("WARNING: failed to get board info from BoardShim");
            e.printStackTrace();
        }

        lastAccelValues = new float[accelChannels.length];
        lastValidAccelValues = new float[accelChannels.length];
        dataPacket = new DataPacket_ADS1299(getNumChannels(), accelChannels.length);

        try {
            updateToNChan(getNumChannels());

            boardShim = new BoardShim (getBoardIdInt(), getParams());
            // for some reason logger configuration doesnt work in contructor or static initializer block
            // and it looks like smth processing specific
            try {
                BoardShim.enable_dev_board_logger();
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
            boardShim.prepare_session();
            return true; 

        } catch (Exception e) {
            boardShim = null;
            outputError("ERROR: " + e + " when initializing Brainflow board. Data will not stream.");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public void uninitialize() {
        if(isConnected()) {
            try {
                boardShim.release_session();
            } catch (BrainFlowError e) {
                println("WARNING: could not release brainflow board.");
                e.printStackTrace();
            }
        }
    }

    @Override
    public void update() {
        if (!streaming || boardShim == null) {
            return; // early out
        }

        double[][] data;
        int timestamp_channel = 0;
        try {
            data = boardShim.get_board_data();
            timestamp_channel = BoardShim.get_timestamp_channel (getBoardIdInt());
        }
        catch (BrainFlowError e) {
            println ("ERROR: Exception trying to get board data");
            e.printStackTrace();
            return; // early out
        }

        for (int count = 0; count < data[0].length; count++)
        {
            double[] values = new double[data.length];
            for (int i=0; i < data.length; i++) {
                values[i] = data[i][count];
            }

            fillDataPacketWithValues(dataPacket, values);

            // This is also used to let the rest of the code that it may be time to do something
            curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length;
            dataPacket.copyTo(dataPacketBuff[curDataPacketInd]);
        }
        timestamps = Arrays.copyOfRange (data[timestamp_channel], 0, data[timestamp_channel].length);
    }

    protected void fillDataPacketWithValues(DataPacket_ADS1299 dataPacket, double[] values) {

        dataPacket.sampleIndex = (int)Math.round(values[packetNumberChannel]);

        for (int i=0; i < dataChannels.length; i++)
        {
            dataPacket.values[i] = (int)Math.round(values[dataChannels[i]]);
        }

        boolean accelValid = false;
        for (int i=0; i<accelChannels.length; i++)
        {
            lastAccelValues[i] = (float)values[accelChannels[i]];
            if (lastAccelValues[i] != 0.f) {
                accelValid = true;
            }
        }
        
        if(accelValid) {
            lastValidAccelValues = lastAccelValues.clone();
        }
    }

    @Override
    public void startStreaming() {
        println("Brainflow start streaming");
        if(streaming) {
            println("Already streaming, do nothing");
            return;
        }
        try {
            boardShim.start_stream (3600);
            streaming = true;
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception when starting stream");
            e.printStackTrace();
            streaming = false;
        }
    }

    @Override
    public void stopStreaming() {
        println("Brainflow stop streaming");
        if(!streaming) {
            println("Already stopped streaming, do nothing");
            return;
        }
        streaming = false;
        try {
            boardShim.stop_stream ();
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception when stoppping stream");
            e.printStackTrace();
        }
    }

    @Override
    public boolean isConnected() {
        boolean res = false;
        if (boardShim != null) {
            try {
                res = boardShim.is_prepared();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return res;
    }

    @Override
    public int getSampleRate() {
        return samplingRate;
    }

    @Override
    public int getNumChannels() {
        return dataChannels.length;
    }

    public int getBoardIdInt() {
        return getBoardId().get_code();
    }

    @Override
    public void sendCommand(String command) {
        configBoard(command);
    }

    @Override
    public void setSampleRate(int sampleRate) {
        outputWarn("Changing the sampling rate is not possible on brainflow boards. Sampling rate will stay at " + getSampleRate());
    }

    protected void configBoard(String configStr) {
        if(!isConnected()) {
            outputError("Cannot send " + configStr + " to board. The board is not connected");
            return;
        }
        try {
            println("Sending config string to board: " + configStr);
            boardShim.config_board(configStr);
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception sending config string to board: " + configStr);
            e.printStackTrace();
        }
    }
};
