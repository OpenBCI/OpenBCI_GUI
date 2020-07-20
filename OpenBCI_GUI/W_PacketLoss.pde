

class W_PacketLoss extends Widget {
    private Grid dataGrid;
    private PacketLossTracker packetLossTracker;

    private PacketRecord sessionPacketRecord;
    private PacketRecord streamPacketRecord;
    private PacketRecord lastMillisPacketRecord;

    W_PacketLoss(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        dataGrid = new Grid(5/*numRows*/, 4/*numCols*/, 20/*rowHeight*/);
        packetLossTracker = ((Board)currentBoard).getPacketLossTracker();
        sessionPacketRecord = packetLossTracker.getSessionPacketRecord();
        streamPacketRecord = packetLossTracker.getStreamPacketRecord();

        dataGrid.setString("entire session", 0, 1);
        dataGrid.setString("contiguous stream", 0, 2);
        dataGrid.setString("last 10s", 0, 3); // TODO hardcoded 10 seconds

        dataGrid.setString("packets lost", 1, 0);
        dataGrid.setString("packets received", 2, 0);
        dataGrid.setString("packets expected", 3, 0);
        dataGrid.setString("% packets lost", 4, 0);
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        // TODO hardcoded 10 seconds
        lastMillisPacketRecord = packetLossTracker.getCumulativePacketRecordForLast(10*1000);

        dataGrid.setString(nfc(sessionPacketRecord.numLost), 1, 1);
        dataGrid.setString(nfc(sessionPacketRecord.numReceived), 2, 1);
        dataGrid.setString(nfc(sessionPacketRecord.getNumExpected()), 3, 1);
        dataGrid.setString(nf(sessionPacketRecord.getLostPercent(), 0, 4 /*decimals*/) + " %", 4, 1);

        dataGrid.setString(nfc(streamPacketRecord.numLost), 1, 2);
        dataGrid.setString(nfc(streamPacketRecord.numReceived), 2, 2);
        dataGrid.setString(nfc(streamPacketRecord.getNumExpected()), 3, 2);
        dataGrid.setString(nf(streamPacketRecord.getLostPercent(), 0, 4 /*decimals*/) + " %", 4, 2);

        dataGrid.setString(nfc(lastMillisPacketRecord.numLost), 1, 3);
        dataGrid.setString(nfc(lastMillisPacketRecord.numReceived), 2, 3);
        dataGrid.setString(nfc(lastMillisPacketRecord.getNumExpected()), 3, 3);
        dataGrid.setString(nf(lastMillisPacketRecord.getLostPercent(), 0, 4 /*decimals*/) + " %", 4, 3);
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        dataGrid.draw();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        dataGrid.setDim(x, y, w);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    }

    private float calcPercent(float total, float fraction) {
        if(total == 0) {
            return 0;
        }

        return fraction * 100 / total;
    }

};
