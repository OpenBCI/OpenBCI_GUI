//Used in the Focus Widget to provide auditory neurofeedback
//Adjust amplitude of calming audio samples using normalized band power data

import processing.sound.*;

Minim minim;
AudioPlayer[] soundPlayers;

void asyncLoadAudioFiles() {
    final int _numSoundFiles = 5;
    minim = new Minim(this);
    soundPlayers = new AudioPlayer[_numSoundFiles];
    println("OpenBCI_GUI: AuditoryFeedback: Loading Audio...");
    for (int i = 0; i < _numSoundFiles; i++) {
        soundPlayers[i] = minim.loadFile("bp" + (i+1) + ".mp3");
    }
    println("OpenBCI_GUI: AuditoryFeedback: Done Loading Audio!");
}

class AuditoryNeurofeedback {

    private int x, y, w, h;
    private ControlP5 localCP5;
    private Button startStopButton;
    private SoundFile[] soundFiles;
    //There will always be 5 band powers, and 5 possible concurrent audio files for playback
    private final int numSoundFiles = 5;

    AuditoryNeurofeedback(int _x, int _y, int _w, int _h) {

        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);
        createStartStopButton(_x, _y, _w, _h);

        soundFiles = new SoundFile[numSoundFiles];
        for (int i = 0; i < numSoundFiles; i++) {
            soundFiles[i] = new SoundFile(ourApplet, "bp" + (i+1) + ".mp3");
            //soundFiles[i].amp(0.7);
        }
    }

    public void update(double[] bandPowers) {
        for (int i = numSoundFiles-1; i >= 0; i--) {
            float val = map((float)bandPowers[i], 0.0, 1.0, 0.1, 0.7);
            soundFiles[i].amp(val);
        }
        
    }

    public void update(float val) {
        if (val > .55) {
            val = .55;
        }
        for (int i = 0; i < numSoundFiles; i++) {
            soundFiles[i].amp(val);
        }
    }

    public void draw() {
        localCP5.draw();
    }

    public void screenResized(int _x, int _y) {
        localCP5.setGraphics(ourApplet, 0, 0);
        startStopButton.setPosition(_x, _y);
    }

    public void killAudio() {
        for (int i = 0; i < numSoundFiles; i++) {
            soundFiles[i].stop();
        }
    }

    private void createStartStopButton(int _x, int _y, int _w, int _h) {
        //This is a generalized createButton method that allows us to save code by using a few patterns and method overloading
        startStopButton = createButton(localCP5, "startStopButton", "Toggle Neurofeedback", _x, _y, _w, _h, p4, 14, colorNotPressed, OPENBCI_DARKBLUE);
        //Set the border color explicitely
        startStopButton.setBorderColor(OBJECT_BORDER_GREY);
        //For this button, only call the callback listener on mouse release
        startStopButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
                if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
                    if (soundFiles[0].isPlaying()) {
                        killAudio();
                    } else {
                        for (int i = 0; i < numSoundFiles; i++) {
                            soundFiles[i].loop();
                        }
                    }   
                }
            }
        });
        startStopButton.setDescription("Here is the description for this UI object.");
    }

}