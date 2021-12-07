import brainflow.*;
import java.util.*;

import org.apache.commons.lang3.SystemUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.commons.lang3.tuple.ImmutablePair;

abstract class BoardBrainFlow extends Board {

    protected BoardShim boardShim = null;
    protected int samplingRateCache = -1;
    protected int sampleIndexChannelCache = -1;
    protected int timeStampChannelCache = -1;
    protected int totalChannelsCache = -1;
    protected int[] exgChannelsCache = null;
    protected int[] otherChannelsCache = null;

    protected boolean streaming = false;
    protected double time_last_datapoint = -1.0;
    protected boolean data_popup_displayed = false;

    /* Abstract Functions.
     * Implement these in your board.
     */
    abstract protected BrainFlowInputParams getParams();
    abstract public BoardIds getBoardId();
    
    @Override
    public boolean initializeInternal() {
        try {
            boardShim = new BoardShim (getBoardIdInt(), getParams());
            try {
                BoardShim.enable_dev_board_logger();
                BoardShim.set_log_file(directoryManager.getConsoleDataPath() + "Brainflow_" +
                    directoryManager.getFileNameDateTime() + ".txt");
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
        super.startStreaming();

        println("Brainflow start streaming");
        if(streaming) {
            println("Already streaming, do nothing");
            return;
        }

        try {
            boardShim.start_stream (450000, brainflowStreamer);
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
        super.stopStreaming();
        
        println("Brainflow stop streaming");
        if(!streaming) {
            println("Already stopped streaming, do nothing");
            return;
        }
        try {
            boardShim.stop_stream();
            streaming = false;
            time_last_datapoint = -1.0;
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception when stoppping stream");
            e.printStackTrace();
            streaming = true;
        }

        if (eegDataSource != DATASOURCE_PLAYBACKFILE && eegDataSource != DATASOURCE_STREAMING) {
            dataLogger.fileWriterBF.incrementBrainFlowStreamerFileNumber();
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
    public boolean isStreaming() {
        return streaming;
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
    public int getSampleIndexChannel() {
        if(sampleIndexChannelCache < 0) {
            try {
                sampleIndexChannelCache = BoardShim.get_package_num_channel(getBoardIdInt());
            } catch (BrainFlowError e) {
                println("WARNING: failed to get package num channel from BoardShim");
                e.printStackTrace();
            }
        }

        return sampleIndexChannelCache;
    }

    public int getBoardIdInt() {
        return getBoardId().get_code();
    }

    @Override
    public Pair<Boolean, String> sendCommand(String command) {
        if (command != null && isConnected()) {
            try {
                println("Sending config string to board: " + command);
                String resp = boardShim.config_board(command);
                return new ImmutablePair<Boolean, String>(Boolean.valueOf(true), resp);
            }
            catch (BrainFlowError e) {
                outputError("ERROR: " + e + " when sending command: " + command);
                e.printStackTrace();
                return new ImmutablePair<Boolean, String>(Boolean.valueOf(false), "");
            }
        }
        return new ImmutablePair<Boolean, String>(Boolean.valueOf(false), "");
    }
    
    @Override
    protected double[][] getNewDataInternal() {
        if(streaming) {
            try {
                double[][] data = boardShim.get_board_data();
                if ((data[0].length == 0) && (time_last_datapoint > 0)) {
                    double cur_time = System.currentTimeMillis() / 1000L;
                    double timeout = 5.0;
                    if (cur_time - time_last_datapoint > timeout) {
                        if (data_popup_displayed == false) {
                            PopupMessage msg = new PopupMessage("Data Streaming Error",
                                "No new data received in " + timeout + " seconds. Please check your device and restart a GUI session.");
                        }
                        data_popup_displayed = true;
                    }
                } else {
                    time_last_datapoint = System.currentTimeMillis() / 1000L;
                    data_popup_displayed = false;
                }
                return data;
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

    protected int[] getOtherChannels() {
        if (otherChannelsCache == null) {
            try {
                otherChannelsCache = BoardShim.get_other_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return otherChannelsCache;
    }
};
