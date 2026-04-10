public boolean developerCommandPopupIsOpen = false;

// Instantiate this class to show a popup message
class DeveloperCommandPopup extends PApplet implements Runnable {
    private final int DEFAULT_WIDTH = 500;
    private final int DEFAULT_HEIGHT = 300;

    private final int HEADER_HEIGHT = 55;
    protected final int PADDING = 20;
    private final int PADDING_5 = 5;

    private final int BUTTON_WIDTH = 230;
    protected final int BUTTON_HEIGHT = 30;

    private final int RESPONSE_TEXT_HEIGHT = 50;

    private String message = "Type a custom command and press Send Command.\nWarning: This is an expert mode feature. Use with caution.";
    private String headerMessage = "Developer Commands";

    private color headerColor = OPENBCI_BLUE;
    protected color buttonColor = OPENBCI_BLUE;
    private color backgroundColor = GREY_235;

    protected Textfield customCommandTF;
    protected Button sendCustomCmdButton;
    protected String responseText = "";
    
    protected ControlP5 cp5;

    private LocalTextFieldUpdateHelper popupTextfieldUpdateHelper = new LocalTextFieldUpdateHelper();
    private LocalCopyPaste localCopyPaste = new LocalCopyPaste();

    public DeveloperCommandPopup() {
        super();
        developerCommandPopupIsOpen = true;
        output("Developer Commands: Developer Command Popup Opened.");
        Thread t = new Thread(this);
        t.start();        
    }

    @Override
    public void run() {
        PApplet.runSketch(new String[] {headerMessage}, this);
    }

    @Override
    public void settings() {
        size(DEFAULT_WIDTH, DEFAULT_HEIGHT);
    }

    @Override
    public void setup() {
        surface.setTitle(headerMessage);
        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.toFront();
        frame.requestFocus();

        cp5 = new ControlP5(this);
        cp5.setAutoDraw(false);

        createCustomCommandUI();
    }

    @Override
    public void draw() {

        popupTextfieldUpdateHelper.checkTextfield(customCommandTF);

        final int w = width;
        final int h = height;

        pushStyle();

        // draw bg
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(backgroundColor);
        rect(0, 0, w, h);

        // draw header
        noStroke();
        fill(headerColor);
        rect(0, 0, w, HEADER_HEIGHT);

        //draw header text
        textFont(p0, 24);
        fill(WHITE);
        textAlign(LEFT, CENTER);
        text(headerMessage, 0 + PADDING, HEADER_HEIGHT/2);

        //draw message
        textFont(p3, 16);
        fill(GREY_100);
        textAlign(LEFT, TOP);
        text(message, 0 + PADDING, 0 + PADDING + HEADER_HEIGHT, w - PADDING*2, h - PADDING*2 - HEADER_HEIGHT);

        //draw response
        textFont(p4, 14);
        fill(GREY_100);
        textAlign(LEFT, TOP);
        text("Response: " + responseText, 0 + PADDING, customCommandTF.getPosition()[1] + BUTTON_HEIGHT + PADDING_5, w - PADDING*2, RESPONSE_TEXT_HEIGHT);

        popStyle();
        
        try {
            cp5.draw();
        } catch (ConcurrentModificationException e) {
            println("PopupMessage Base Class: Error drawing cp5" + e.getMessage());
        } catch (ArrayIndexOutOfBoundsException e) {
            println("PopupMessage Base Class: Error drawing cp5" + e.getMessage());
        }
    }

    @Override
    void mousePressed() {

    }

    @Override
    void mouseReleased() {

    }

    @Override
    void keyPressed() {
        if (localCopyPaste.checkIfPressedAllOS()) {
            return;
        }
    }

    @Override
    void keyReleased() {
        localCopyPaste.checkIfReleasedAllOS();
    }

    @Override
    void exit() {
        dispose();
        developerCommandPopupIsOpen = false;
    }

    // Dispose of the popup window externally
    public void exitPopup() {
        output("Developer Commands: Developer Command Popup closed");
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        developerCommandPopupIsOpen = false;
    }
  
    private void createCustomCommandUI() {
        customCommandTF = cp5.addTextfield("customCommand")
            .setPosition(0, 0)
            .setCaptionLabel("")
            .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(OBJECT_BORDER_GREY)  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText("")
            .align(5, 10, 20, 40)
            .setAutoClear(false) //Don't clear textfield when pressing Enter key
            ;
        customCommandTF.setDescription("Type a custom command and Send to board.");
        //Clear textfield on double click
        customCommandTF.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("[ExpertMode] Enter the custom command you would like to send to the board.");
                customCommandTF.clear();
            }
        });
        customCommandTF.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    customCommandTF.setFocus(false);
                }
            }
        });

        sendCustomCmdButton = createButton(cp5, "sendCustomCommand", "Send Command", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        sendCustomCmdButton.setBorderColor(OBJECT_BORDER_GREY);
        sendCustomCmdButton.getCaptionLabel().getStyle().setMarginLeft(1);
        sendCustomCmdButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                String text = dropNonPrintableChars(customCommandTF.getText());
                Pair<Boolean, String> res = ((BoardBrainFlow)currentBoard).sendCommand(text);
                if (res.getKey().booleanValue()) {
                    outputSuccess("[ExpertMode] Success sending command to board: " + text);
                    responseText = res.getValue();
                } else {
                    outputError("[ExpertMode] Failure sending command to board: " + text);
                    responseText = "NO RESPONSE FROM BOARD";
                }
                println("ADSSettingsController: Response == " + res.getValue());
                
            }
        });

        int objectX = width/2;
        int messagePadding = HEADER_HEIGHT + PADDING;
        int objectY = HEADER_HEIGHT + messagePadding + PADDING + PADDING_5;
        customCommandTF.setPosition(objectX - BUTTON_WIDTH - PADDING_5, objectY - BUTTON_HEIGHT/2);
        sendCustomCmdButton.setPosition(objectX + PADDING_5, objectY - BUTTON_HEIGHT/2);
    }
    
    //We need a local copy of this class because this instance is unable to use the global instance from the main GUI.
    public class LocalTextFieldUpdateHelper {

        // textFieldIsActive is used to ignore hotkeys when a textfield is active. Resets to false on every draw loop.
        private boolean textFieldIsActive = false;

        LocalTextFieldUpdateHelper() {
        }
        
        public void resetTextFieldIsActive() {
            textFieldIsActive = false;
        }

        public boolean getAnyTextfieldsActive() {
            return textFieldIsActive;
        }

        public void checkTextfield(Textfield tf) {
            if (tf.isVisible()) {
                tf.setUpdate(true);
                if (tf.isFocus()) {
                    textFieldIsActive = true;
                    localCopyPaste.checkForCopyPaste(tf);
                }
            } else {
                tf.setUpdate(false);
            }
        }
    }

    class LocalCopyPaste {

        private final int CMD_CNTL_KEYCODE = (isLinux() || isWindows()) ? 17 : 157;
        private final int C_KEYCODE = 67;
        private final int V_KEYCODE = 86;
        private boolean commandControlPressed;
        private boolean copyPressed;
        private String value;

        LocalCopyPaste () {

        }
        
        public boolean checkIfPressedAllOS() {
            //This logic mimics the behavior of copy/paste in Mac OS X, and applied to all.
            if (keyCode == CMD_CNTL_KEYCODE) {
                commandControlPressed = true;
                //println("KEYBOARD SHORTCUT: COMMAND PRESSED");
                return true;
            }

            if (commandControlPressed && keyCode == V_KEYCODE) {
                //println("KEYBOARD SHORTCUT: PASTE PRESSED");
                // Get clipboard contents
                String s = GClip.paste();
                //println("FROM CLIPBOARD ~~ " + s);
                // Assign to stored value
                value = s;
                return true;
            }

            if (commandControlPressed && keyCode == C_KEYCODE) {
                //println("KEYBOARD SHORTCUT: COPY PRESSED");
                copyPressed = true;
                return true;
            }

            return false;
        }

        public void checkIfReleasedAllOS() {
            if (keyCode == CMD_CNTL_KEYCODE) {
                commandControlPressed = false;
            }
        }
        
        //Pull stored value from this class and set to null, otherwise return null.
        private String pullValue() {
            if (value == null) {
                return value;
            }
            String s = value;
            value = null;
            return s;
        }

        private void checkForPaste(Textfield tf) {
            if (value == null) {
                return;
            }

            if (tf.isFocus()) {
                StringBuilder status = new StringBuilder("OpenBCI_GUI: User pasted text from the clipboard into ");
                status.append(tf.toString());
                println(status);
                StringBuilder sb = new StringBuilder();
                String existingText = dropNonPrintableChars(tf.getText());
                String val = pullValue();
                //println("EXISTING TEXT =="+ existingText+ "__end. VALUE ==" + val + "__end.");

                // On Mac, Remove 'v' character from the end of the existing text
                existingText = existingText.length() > 0 && isMac() ? existingText.substring(0, existingText.length() - 1) : existingText;

                sb.append(existingText);
                sb.append(val);
                //The 'v' character does make it to the textfield, but this is immediately overwritten here.
                tf.setText(sb.toString());
            } 
        }

        private void checkForCopy(Textfield tf) {
            if (!copyPressed) {
                return;
            }

            if (tf.isFocus()) {
                String s = dropNonPrintableChars(tf.getText());
                if (s.length() == 0) {
                    return;
                }
                StringBuilder status = new StringBuilder("OpenBCI_GUI: User copied text from ");
                status.append(tf.toString());
                status.append(" to the clipboard");
                println(status);
                //println("FOUND TEXT =="+ s+"__end.");
                if (isMac()) {
                    //Remove the 'c' character that was just typed in the textfield
                    s = s.substring(0, s.length() - 1);
                    tf.setText(s);
                    //println("MAC FIXED TEXT =="+ s+"__end.");
                }
                boolean b = GClip.copy(s);
                copyPressed = false;
            } 
        }

        public void checkForCopyPaste(Textfield tf) {
            checkForPaste(tf);
            checkForCopy(tf);
        }
    }
};