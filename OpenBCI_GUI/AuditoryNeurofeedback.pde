//Used in the Focus Widget to provide auditory neurofeedback
//Adjust amplitude of calming audio samples using normalized band power data or predicted metric

Minim minim;
FilePlayer[] auditoryNfbFilePlayers;
ddf.minim.ugens.Gain[] auditoryNfbGains;
AudioOutput audioOutput;
boolean audioOutputIsAvailable;

//Pre-load audio files into memory in delayedSetup for best app performance and no waiting
void asyncLoadAudioFiles() {
    final int _numSoundFiles = 5;
    minim = new Minim(this);
    auditoryNfbFilePlayers = new FilePlayer[_numSoundFiles];
    auditoryNfbGains = new ddf.minim.ugens.Gain[_numSoundFiles];
    audioOutput = minim.getLineOut();
    println("OpenBCI_GUI: AuditoryFeedback: Loading Audio...");
    for (int i = 0; i < _numSoundFiles; i++) {
        //Use large buffer size and cache files in memory
        try {
            auditoryNfbFilePlayers[i] = new FilePlayer( minim.loadFileStream("bp" + (i+1) + ".mp3", 2048, true) );
            auditoryNfbGains[i] = new ddf.minim.ugens.Gain(-15.0f);
            auditoryNfbFilePlayers[i].patch(auditoryNfbGains[i]).patch(audioOutput);
        } catch (Exception e) {
            outputError("AuditoryFeedback: Unable to load audio files. To enable this feature, please connect or turn on an audio device and restart the GUI.");
            audioOutputIsAvailable = false;
            return;
        }
    }
    println("OpenBCI_GUI: AuditoryFeedback: Done Loading Audio!");
    audioOutputIsAvailable = true;
}

class AuditoryNeurofeedback {

    private int x, y, w, h;
    private ControlP5 localCP5;
    public Button startStopButton;
    public Button modeButton;
    private boolean usingBandPowers = false;
    //There will always be 5 band powers, and 5 possible concurrent audio files for playback
    private final int NUM_SOUND_FILES = auditoryNfbFilePlayers.length;
    private final float MIN_GAIN = -42.0;
    private final float MAX_GAIN = -7.0;
    private final int MAX_BUTTON_W = 120;
    private int buttonW = 120;
    private int buttonH;

    AuditoryNeurofeedback(int _x, int _y, int _w, int _h) {
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);
        buttonH = _h;
        createStartStopButton(_x, _y, buttonW, buttonH);
        createModeButton(_x, _y, buttonW, buttonH);
    }

    //Use band powers or prediction value to control volume of each sound file
    public void update(double[] bandPowers, float predictionVal) {
        if (!audioOutputIsAvailable) {return;}
        if (usingBandPowers) {
            for (int i = 0; i < NUM_SOUND_FILES; i++) {
                float gain = map((float)bandPowers[i], 0.1, .7, MIN_GAIN + 20f, MAX_GAIN);
                auditoryNfbGains[i].setValue(gain);
            }
        } else {
            float gain = map(predictionVal, 0.0, 1.0, MIN_GAIN, MAX_GAIN);
            for (int i = 0; i < NUM_SOUND_FILES; i++) {
                auditoryNfbGains[i].setValue(gain);
            }
        }
    }

    public void draw() {
        localCP5.draw();
    }

    public void screenResized(int _x, int _y, int _w, int _h) {
        localCP5.setGraphics(ourApplet, 0, 0);
        buttonW = (_w - 6) / 2;
        buttonW = buttonW > MAX_BUTTON_W ? MAX_BUTTON_W : buttonW;
        startStopButton.setPosition(_x - buttonW - 3, _y);
        startStopButton.setSize(buttonW, _h);
        modeButton.setPosition(_x + 3, _y);
        modeButton.setSize(buttonW, _h);
    }

    public void killAudio() {
        if (!audioOutputIsAvailable) {return;}
        for (int i = 0; i < NUM_SOUND_FILES; i++) {
            auditoryNfbFilePlayers[i].pause();
            auditoryNfbFilePlayers[i].rewind();
        }
    }

    private void createStartStopButton(int _x, int _y, int _w, int _h) {
        //This is a generalized createButton method that allows us to save code by using a few patterns and method overloading
        startStopButton = createButton(localCP5, "startStopButton", "Turn Audio On", _x, _y, _w, _h, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        //Set the border color explicitely
        startStopButton.setBorderColor(OBJECT_BORDER_GREY);
        //For this button, only call the callback listener on mouse release
        startStopButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!audioOutputIsAvailable) {
                    outputError("AuditoryFeedback: Unable to load audio files. To enable this feature, please connect or turn on an audio device and restart the GUI.");
                    return;
                }
                //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
                if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
                    if (auditoryNfbFilePlayers[0].isPlaying()) {
                        killAudio();
                        startStopButton.getCaptionLabel().setText("Turn Audio On");
                    } else {
                        for (int i = 0; i < NUM_SOUND_FILES; i++) {
                            auditoryNfbFilePlayers[i].loop();
                        }
                        startStopButton.getCaptionLabel().setText("Turn Audio Off");
                    }
                }
            }
        });
        startStopButton.setDescription("Start and Stop Auditory Feedback.");
    }

    private void createModeButton(int _x, int _y, int _w, int _h) {
        //This is a generalized createButton method that allows us to save code by using a few patterns and method overloading
        modeButton = createButton(localCP5, "modeButton", "Use Band Powers", _x, _y, _w, _h, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        //Set the border color explicitely
        modeButton.setBorderColor(OBJECT_BORDER_GREY);
        //For this button, only call the callback listener on mouse release
        modeButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
                if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
                    String s = !usingBandPowers ? "Use Metric" : "Use Band Powers";
                    modeButton.getCaptionLabel().setText(s);
                    usingBandPowers = !usingBandPowers;
                }
            }
        });
        modeButton.setDescription("Change Auditory Feedback mode. Use the Metric to control all notes at once, or use Band Powers to control certain notes of the chord.");
    }

}