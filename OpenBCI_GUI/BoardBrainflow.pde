import brainflow.*;
import java.util.*;
import org.apache.commons.lang3.SystemUtils;

abstract class BoardBrainFlow extends Board {
    private BoardShim boardShim = null;

    protected int samplingRateCache = -1;
    protected int packetNumberChannelCache = -1;
    protected int timeStampChannelCache = -1;
    protected int totalChannelsCache = -1;
    protected int[] exgChannelsCache = null;

    protected boolean streaming = false;

    /* Abstract Functions.
     * Implement these in your board.
     */
    abstract protected BrainFlowInputParams getParams();
    abstract public BoardIds getBoardId();
    
    @Override
    public boolean initializeInternal() {
        // initiate the board shim
        try {

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
    public void uninitializeInternal() {
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
    public void updateInternal() {
        // empty
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
        if (boardShim != null) {
            try {
                return boardShim.is_prepared();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return false;
    }

    @Override
    public int getSampleRate() {
        if(samplingRateCache < 0) {
            try {
                samplingRateCache = BoardShim.get_sampling_rate(getBoardIdInt());
            } catch (BrainFlowError e) {
                println("WARNING: failed to get sample rate from BoardShim");
                e.printStackTrace();
            }
        }

        return samplingRateCache;
    }

    @Override
    public int[] getEXGChannels() {
        if(exgChannelsCache == null) {
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
            exgChannelsCache = new int[toArray.length];
            for (int i = 0; i < toArray.length; i++) {
                exgChannelsCache[i] = toArray[i].intValue();
            }
        }

        return exgChannelsCache;
    }

    @Override
    public int getTimestampChannel() {
        if(timeStampChannelCache < 0) {
            try {
                timeStampChannelCache = BoardShim.get_timestamp_channel(getBoardIdInt());
            } catch (BrainFlowError e) {
                println("WARNING: failed to get timestamp channel from BoardShim");
                e.printStackTrace();
            }
        }

        return timeStampChannelCache;
    }
    
    @Override
    public int getSampleNumberChannel() {
        if(packetNumberChannelCache < 0) {
            try {
                packetNumberChannelCache = BoardShim.get_package_num_channel(getBoardIdInt());
            } catch (BrainFlowError e) {
                println("WARNING: failed to get package num channel from BoardShim");
                e.printStackTrace();
            }
        }

        return packetNumberChannelCache;
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
        outputWarn("Changing the sampling rate is not possible on this board. Sampling rate will stay at " + getSampleRate());
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
    
    @Override
    protected double[][] getNewDataInternal() {
        if(streaming) {
            try {
                return boardShim.get_board_data();
            } catch (BrainFlowError e) {
                println("WARNING: could not get board data.");
                e.printStackTrace();
            }
        }
    
        return emptyData;
    }

    @Override
    public int getTotalChannelCount() {
        if(totalChannelsCache < 0) {
            try {
                totalChannelsCache = BoardShim.get_num_rows(getBoardIdInt());
            } catch (BrainFlowError e) {
                println("WARNING: failed to get num rows from BoardShim");
                e.printStackTrace();
            }
        }

        return totalChannelsCache;
    }
};
