import brainflow.*;

class BoardNovaXR extends BoardBrainFlow {

    private String ipAddress = "";

    public BoardNovaXR(String ip) {
        ipAddress = ip;
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.ip_address = ipAddress;
        params.ip_protocol = IpProtocolType.TCP.get_code();
        return params;
    }
    
    @Override
    public BoardIds getBoardType() {
        return BoardIds.NOVAXR_BOARD;
    }
};
