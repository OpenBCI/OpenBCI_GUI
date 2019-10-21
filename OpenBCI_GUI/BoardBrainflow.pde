import brainflow.*;
import org.apache.commons.lang3.SystemUtils;

class BoardBrainFlow {
    private DataPacket_ADS1299 rawReceivedDataPacket;
    private DataPacket_ADS1299 missedDataPacket;
    private DataPacket_ADS1299 dataPacket;

    private BoardShim board_shim = null;
    private String ipAddress = "";

    private int packetNumberChannel = 0;
    private int[] eegChannels = {};
    private int[] auxChannels = {};

    private boolean streaming = false;

    //constructors
    BoardBrainFlow() {}

    BoardBrainFlow(PApplet applet, String ip_addr) {
        int boardType = BoardIds.SYNTHETIC_BOARD.get_code(); // nova XR

        try {
            packetNumberChannel = BoardShim.get_package_num_channel(boardType);
            eegChannels = BoardShim.get_eeg_channels(boardType);
            auxChannels = BoardShim.get_other_channels(boardType);

            println(auxChannels);

            BrainFlowInputParams  params = new BrainFlowInputParams ();
            params.ip_address = ipAddress;
            params.ip_protocol = IpProtocolType.TCP.get_code();
            board_shim = new BoardShim (boardType, params);
            board_shim.prepare_session();            
        } catch (BrainFlowError e) {
            println (e);
        } catch (IOException e) {
            println (e);
        } catch (ReflectiveOperationException e) {
            println (e);
        }
        initDataPackets(eegChannels.length, auxChannels.length);
        ipAddress = ip_addr;
    }

    // ~BoardBrainFlow()
    // {
    //     board_shim.release_session ();
    // }

    public void initDataPackets(int eegChannelCount, int auxChannelCount) {
        println("Initializing data packets with " + eegChannelCount + " eeg channels and " + auxChannelCount + " aux.");

        //allocate space for data packet
        rawReceivedDataPacket = new DataPacket_ADS1299(eegChannelCount, auxChannelCount);
        missedDataPacket = new DataPacket_ADS1299(eegChannelCount, auxChannelCount);
        dataPacket = new DataPacket_ADS1299(eegChannelCount, auxChannelCount);
        //set all values to 0 so not null

        for (int i=0; i < eegChannelCount; i++) {
            rawReceivedDataPacket.values[i] = 0;
            dataPacket.values[i] = 0;
            missedDataPacket.values[i] = 0;
        }
        for (int i = 0; i < auxChannelCount; i++) {
            rawReceivedDataPacket.auxValues[i] = 0;
            dataPacket.auxValues[i] = 0;
            missedDataPacket.auxValues[i] = 0;
        }
    }
 
    public void update() {
        if (streaming) {
            try {
                int data_count = board_shim.get_board_data_count();
                double[][] data = board_shim.get_board_data();
                for (int count = 0; count < data_count; count++)
                {
                    dataPacket.sampleIndex = (int)Math.round(data[packetNumberChannel][count]);

                    for (int i=0; i < eegChannels.length; i++)
                    {
                        dataPacket.values[i] = (int)Math.round(data[eegChannels[i]][count]);
                    }

                    for (int i=0; i<auxChannels.length; i++)
                    {
                        dataPacket.auxValues[i] = (int)Math.round(data[auxChannels[i]][count]);
                    }
                    
                    curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length; // This is also used to let the rest of the code that it may be time to do something
                    
                    copyDataPacketTo(dataPacketBuff[curDataPacketInd]);
                }
            }
            catch (BrainFlowError e) {
                println (e);
            }
        }
    }

    public void startDataTransfer() {
        println("start BoardBrainFlow");
        try {
            board_shim.start_stream (3600);
            streaming = true;
        }
        catch (BrainFlowError e) {
            println (e);
            streaming = false;
        }
    }

    public void stopDataTransfer() {
        println("stop BoardBrainFlow");
        streaming = false;
        try {
            board_shim.stop_stream ();
        }
        catch (BrainFlowError e) {
            println (e);
        }
    }

    public int copyDataPacketTo(DataPacket_ADS1299 target) {
        return dataPacket.copyTo(target);
    }
};
