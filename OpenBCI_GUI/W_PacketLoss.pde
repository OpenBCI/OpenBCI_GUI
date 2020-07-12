

class W_PacketLoss extends Widget {
    private ControlP5 packetLossCP5;
    private PacketLossTracker packetLossTracker;

    private int samplesLostSession = 0;
    private int samplesLostStream = 0;
    private int samplesReceivedSession = 0;
    private int samplesReceivedStream = 0;
    private int samplesExpectedSession = 0;
    private int samplesExpectedStream = 0;
    private float percentLostSession = 0.f;
    private float percentLostStream = 0.f;

    W_PacketLoss(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        packetLossTracker = ((Board)currentBoard).getPacketLossTracker();
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        samplesLostSession = packetLossTracker.getLostSamplesSession();
        samplesReceivedSession = packetLossTracker.getReceivedSamplesSession();
        samplesExpectedSession = samplesLostSession + samplesReceivedSession;
        percentLostSession = calcPercent(samplesExpectedSession, samplesLostSession);

        samplesLostStream = packetLossTracker.getLostSamplesStream();
        samplesReceivedStream = packetLossTracker.getReceivedSamplesStream();
        samplesExpectedStream = samplesLostStream + samplesReceivedStream;
        percentLostStream = calcPercent(samplesExpectedStream, samplesLostStream);
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();

        textAlign(LEFT);

        int[] colOffset = {0, round(w * 0.25f), round(w * 0.50f), round(w * 0.75f)};
        int[] rowOffset = {20, 40, 60, 80, 100};

        text("packets lost", x + colOffset[0], y+rowOffset[1]);
        text("packets received", x + colOffset[0], y+rowOffset[2]);
        text("packets expected", x + colOffset[0], y+rowOffset[3]);
        text("% packets lost", x + colOffset[0], y+rowOffset[4]);

        text("entire session", x+colOffset[1], y+rowOffset[0]);
        text(nfc(samplesLostSession), x+colOffset[1], y+rowOffset[1]);
        text(nfc(samplesReceivedSession), x+colOffset[1], y+rowOffset[2]);
        text(nfc(samplesExpectedSession), x+colOffset[1], y+rowOffset[3]);
        text(nf(percentLostSession, 0, 4 /*decimals*/), x+colOffset[1], y+rowOffset[4]);

        text("contiguous stream", x+colOffset[2], y+rowOffset[0]);
        text(nfc(samplesLostStream), x+colOffset[2], y+rowOffset[1]);
        text(nfc(samplesReceivedStream), x+colOffset[2], y+rowOffset[2]);
        text(nfc(samplesExpectedStream), x+colOffset[2], y+rowOffset[3]);
        text(nf(percentLostStream, 0, 4 /*decimals*/), x+colOffset[2], y+rowOffset[4]);

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
