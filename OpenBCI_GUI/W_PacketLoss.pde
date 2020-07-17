

class W_PacketLoss extends Widget {
    private ControlP5 packetLossCP5;
    private PacketLossTracker packetLossTracker;

    private PacketRecord sessionPacketRecord;
    private PacketRecord streamPacketRecord;
    private PacketRecord lastMillisPacketRecord;

    W_PacketLoss(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        packetLossTracker = ((Board)currentBoard).getPacketLossTracker();
        sessionPacketRecord = packetLossTracker.getSessionPacketRecord();
        streamPacketRecord = packetLossTracker.getStreamPacketRecord();
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        // TODO hardcoded 10 seconds
        lastMillisPacketRecord = packetLossTracker.getCumulativePacketRecordForLast(10*1000);
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();

        textAlign(LEFT);

        // TODO: make a table class to clean this up a little

        int[] colOffset = {0, round(w * 0.25f), round(w * 0.50f), round(w * 0.75f)};
        int[] rowOffset = {20, 40, 60, 80, 100};
        int pad = 5;

        stroke(0);
        // draw row lines
        line(x, y+rowOffset[0], x+w, y+rowOffset[0]);
        line(x, y+rowOffset[1], x+w, y+rowOffset[1]);
        line(x, y+rowOffset[2], x+w, y+rowOffset[2]);
        line(x, y+rowOffset[3], x+w, y+rowOffset[3]);

        // draw column lines
        line(x+colOffset[1], y, x+colOffset[1], y+rowOffset[4]);
        line(x+colOffset[2], y, x+colOffset[2], y+rowOffset[4]);
        line(x+colOffset[3], y, x+colOffset[3], y+rowOffset[4]);

        text("packets lost", x+colOffset[0]+pad, y+rowOffset[1]-pad);
        text("packets received", x+colOffset[0]+pad, y+rowOffset[2]-pad);
        text("packets expected", x+colOffset[0]+pad, y+rowOffset[3]-pad);
        text("% packets lost", x+colOffset[0]+pad, y+rowOffset[4]-pad);

        text("entire session", x+colOffset[1]+pad, y+rowOffset[0]-pad);
        text(nfc(sessionPacketRecord.numLost), x+colOffset[1]+pad, y+rowOffset[1]-pad);
        text(nfc(sessionPacketRecord.numReceived), x+colOffset[1]+pad, y+rowOffset[2]-pad);
        text(nfc(sessionPacketRecord.getNumExpected()), x+colOffset[1]+pad, y+rowOffset[3]-pad);
        text(nf(sessionPacketRecord.getLostPercent(), 0, 4 /*decimals*/), x+colOffset[1]+pad, y+rowOffset[4]-pad);

        text("contiguous stream", x+colOffset[2]+pad, y+rowOffset[0]-pad);
        text(nfc(streamPacketRecord.numLost), x+colOffset[2]+pad, y+rowOffset[1]-pad);
        text(nfc(streamPacketRecord.numReceived), x+colOffset[2]+pad, y+rowOffset[2]-pad);
        text(nfc(streamPacketRecord.getNumExpected()), x+colOffset[2]+pad, y+rowOffset[3]-pad);
        text(nf(streamPacketRecord.getLostPercent(), 0, 4 /*decimals*/), x+colOffset[2]+pad, y+rowOffset[4]-pad);
        
        text("last 10s", x+colOffset[3]+pad, y+rowOffset[0]-pad);
        text(nfc(lastMillisPacketRecord.numLost), x+colOffset[3]+pad, y+rowOffset[1]-pad);
        text(nfc(lastMillisPacketRecord.numReceived), x+colOffset[3]+pad, y+rowOffset[2]-pad);
        text(nfc(lastMillisPacketRecord.getNumExpected()), x+colOffset[3]+pad, y+rowOffset[3]-pad);
        text(nf(lastMillisPacketRecord.getLostPercent(), 0, 4 /*decimals*/), x+colOffset[3]+pad, y+rowOffset[4]-pad);

        popStyle();

    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
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
