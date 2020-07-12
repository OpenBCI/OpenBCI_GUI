

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
        text(nfc(samplesLostSession), x+colOffset[1]+pad, y+rowOffset[1]-pad);
        text(nfc(samplesReceivedSession), x+colOffset[1]+pad, y+rowOffset[2]-pad);
        text(nfc(samplesExpectedSession), x+colOffset[1]+pad, y+rowOffset[3]-pad);
        text(nf(percentLostSession, 0, 4 /*decimals*/), x+colOffset[1]+pad, y+rowOffset[4]-pad);

        text("contiguous stream", x+colOffset[2]+pad, y+rowOffset[0]-pad);
        text(nfc(samplesLostStream), x+colOffset[2]+pad, y+rowOffset[1]-pad);
        text(nfc(samplesReceivedStream), x+colOffset[2]+pad, y+rowOffset[2]-pad);
        text(nfc(samplesExpectedStream), x+colOffset[2]+pad, y+rowOffset[3]-pad);
        text(nf(percentLostStream, 0, 4 /*decimals*/), x+colOffset[2]+pad, y+rowOffset[4]-pad);

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
