import brainflow.*;
import org.apache.commons.lang3.SystemUtils;

class BoardBrainflow {
    private int nEEGValuesPerPacket = 8; //defined by the data format sent by cyton boards
    private int nAuxValuesPerPacket = 3; //defined by the data format sent by cyton boards
    private DataPacket_ADS1299 rawReceivedDataPacket;
    private DataPacket_ADS1299 missedDataPacket;
    private DataPacket_ADS1299 dataPacket;

    private BoardShim board_shim = null;
    private String ipAddress = "";

    //constructors
    BoardBrainflow() {};  //only use this if you simply want access to some of the constants
    BoardBrainflow(PApplet applet, String ip_addr) {

        initDataPackets(nEEGValuesPerPacket, nAuxValuesPerPacket);
        ipAddress = ip_addr;
    }

    public void initDataPackets(int _nEEGValuesPerPacket, int _nAuxValuesPerPacket) {
        //allocate space for data packet
        rawReceivedDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
        missedDataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);  //this should always be 8 channels
        dataPacket = new DataPacket_ADS1299(nEEGValuesPerPacket, nAuxValuesPerPacket);            //this could be 8 or 16 channels
        //set all values to 0 so not null

        for (int i = 0; i < nEEGValuesPerPacket; i++) {
            rawReceivedDataPacket.values[i] = 0;
            //prevDataPacket.values[i] = 0;
        }

        for (int i=0; i < nEEGValuesPerPacket; i++) {
            dataPacket.values[i] = 0;
            missedDataPacket.values[i] = 0;
        }
        for (int i = 0; i < nAuxValuesPerPacket; i++) {
            rawReceivedDataPacket.auxValues[i] = 0;
            dataPacket.auxValues[i] = 0;
            missedDataPacket.auxValues[i] = 0;
            //prevDataPacket.auxValues[i] = 0;
        }
    }
 
    public void update() {
        if (board_shim != null) {
            try {
                BoardData boardData = board_shim.get_board_data ();
                List<ArrayList<Double>> data = boardData.get_board_data();
                for (ArrayList<Double> packet : data)
                {
                    dataPacket.sampleIndex = (int)Math.round(packet.get(0));
                    for (int i=0; i < 8; i++)
                    {
                        dataPacket.values[i] = (int)Math.round(packet.get(i+1));
                    }
                    for (int i=8; i<11; i++)
                    {
                        dataPacket.auxValues[i-8] = (int)Math.round(packet.get(i+1));
                    }
                    curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length; // This is also used to let the rest of the code that it may be time to do something
                    
                    copyDataPacketTo(dataPacketBuff[curDataPacketInd]);
                }
            }
            catch (Exception e) {
                println (e);
            }
        }
    }

    public void startDataTransfer() {
        println("start BoardBrainflow");
        try {
            int boardType = 3; // nova XR
            if(ipAddress.isEmpty()) {
                boardType = -1; // synthetic
            }

            board_shim = new BoardShim (boardType, ipAddress, true);
            board_shim.prepare_session();
            board_shim.start_stream (3600);
        }
        catch (Exception e) {
                println (e);
        }
    }

    public void stopDataTransfer() {
        println("stop BoardBrainflow");
        try {
            board_shim.stop_stream ();
            board_shim.release_session ();
            board_shim = null;
        }
        catch (Exception e) {
            println (e);
        }
    }

    public int copyDataPacketTo(DataPacket_ADS1299 target) {
        return dataPacket.copyTo(target);
    }
};
