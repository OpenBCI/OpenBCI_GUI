

class W_PacketLoss extends Widget {
    private ControlP5 packetLossCP5;
    private PacketLossTracker packetLossTracker;

    private int samplesLostSession = 0;
    private int samplesLostStream = 0;
    private int samplesReceivedSession = 0;
    private int samplesReceivedStream = 0;
    private int samplesExpectedSession = 0;
    private int samplesExpectedStream = 0;

    W_PacketLoss(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        packetLossTracker = ((Board)currentBoard).getPacketLossTracker();
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        samplesLostSession = packetLossTracker.getLostSamplesSession();
        samplesReceivedSession = packetLossTracker.getReceivedSamplesSession();
        samplesExpectedSession = samplesLostSession + samplesReceivedSession;
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();

        textAlign(LEFT);

        text("SamplesLostSession: " + samplesLostSession, x, y+20);
        text("SamplesReceivedSession: " + samplesReceivedSession, x, y+40);
        text("SamplesExpectedSession: " + samplesExpectedSession, x, y+60);

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

};
