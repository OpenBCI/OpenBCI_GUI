class SignalCheckThresholdUI {

    private Textfield thresholdTF;
    private String name;
    private final int textfieldHeight = 14;
    private int defaultValue_Percentage;
    private int defaultValue_kOhms;
    private int valuePercentage;
    private int valuekOhms;
    private CytonSignalCheckMode signalCheckMode;
    private color textColor = OPENBCI_DARKBLUE;
    private boolean hasUpdatedTextColor = false;

    SignalCheckThresholdUI(ControlP5 _cp5, String _name, int _x, int _y, int _w, int _h, color _textColor, CytonSignalCheckMode _mode) {
        signalCheckMode = _mode;
        name = _name;
        textColor = _textColor;
        defaultValue_Percentage = name.equals("errorThreshold") ? (int)threshold_railed : (int)threshold_railed_warn;
        valuePercentage = defaultValue_Percentage;
        defaultValue_kOhms = name == "errorThreshold" ? 2500 : 750;
        valuekOhms = defaultValue_kOhms;
        thresholdTF = createTextfield(_cp5, _name, 0, _x, _y, _w, _h, _textColor);
        updateTextfieldModeChanged(_mode);
        //textfieldHeight = _h;
    }

    public void update() {
        if (!hasUpdatedTextColor) {
            thresholdTF.setColorValueLabel(textColor);
            thresholdTF.setColorActive(textColor);
            hasUpdatedTextColor = true;
        }

        textfieldUpdateHelper.checkTextfield(thresholdTF);
    }

    public void updateTextfieldModeChanged(CytonSignalCheckMode _mode) {
        signalCheckMode = _mode;
        customThreshold(thresholdTF, getTextfieldIntVal());
    }

    private Textfield createTextfield(ControlP5 _cp5, String name, int intValue, int _x, int _y, int _w, int _h, color _textColor) {
        //Create these textfields under cp5_widget base instance so because they are always visible
        final Textfield myTextfield = _cp5.addTextfield(name)
            .setPosition(_x, _y)
            .setCaptionLabel("")
            .setSize(_w, _h)
            .setFont(f5)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(_textColor)  // text color
            .setColorForeground(color(210))  // border color when not selected - grey
            .setColorActive(isSelected_color)  // border color when selected - green
            .setColorCursor(color(26, 26, 26))
            .setText("%") //set the text
            .align(5, 10, 20, 40)
            .setAutoClear(false)
            ; //Don't clear textfield when pressing Enter key
        //Clear textfield on double click
        myTextfield.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("SessionData: Enter your custom session name.");
                myTextfield.clear();
            }
        });
        //Autogenerate session name if user presses Enter key and textfield value is null
        myTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfield.getText().equals("")) {
                    setTextfieldVal(getDefaultTextfieldIntVal());
                    customThreshold(myTextfield, getDefaultTextfieldIntVal());
                }
                //Pressing ENTER in the Textfield triggers a "Broadcast"
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    //Try to clean up typing accidents from user input in Textfield
                    String rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                    int rcvAsInt = NumberUtils.toInt(rcvString);
                    if (rcvAsInt <= 0) {
                        rcvAsInt = 0; //Only positive values will be used here
                    }
                    setTextfieldVal(rcvAsInt);
                    customThreshold(myTextfield, rcvAsInt);
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    setTextfieldVal(getDefaultTextfieldIntVal());
                    customThreshold(myTextfield, getDefaultTextfieldIntVal());
                }
            }
        });
        return myTextfield;
    }
    
    private void customThreshold(Textfield tf, int value) {
        StringBuilder sb = new StringBuilder();
        sb.append(value);
        sb.append(isSignalCheckRailedMode() ? "%" : " k\u2126");
        tf.setText(sb.toString());
    }

    public void setPosition(int _x, int _y) {
        thresholdTF.setPosition(_x, _y);
    }

    private int getDefaultTextfieldIntVal() {
        return isSignalCheckRailedMode() ? defaultValue_Percentage : defaultValue_kOhms;
    }

    private int getTextfieldIntVal() {
        return isSignalCheckRailedMode() ? valuePercentage : valuekOhms;
    }

    private void setTextfieldVal(int val) {
        if (isSignalCheckRailedMode()) {
            if (name == "errorThreshold") {
                for (int i = 0; i < nchan; i++) {
                    is_railed[i].setRailedThreshold((double) val);
                }
            } else {
                for (int i = 0; i < nchan; i++) {
                    is_railed[i].setRailedWarnThreshold((double) val);
                }
            }
            valuePercentage = val;
        } else {
            if (name == "errorThreshold") {
                w_cytonImpedance.updateElectrodeStatusYellowThreshold((double)val);
            } else {
                w_cytonImpedance.updateElectrodeStatusGreenThreshold((double)val);
            }
            valuekOhms = val;
        }
    }

    private boolean isSignalCheckRailedMode() {
        return signalCheckMode == CytonSignalCheckMode.LIVE;
    }
};