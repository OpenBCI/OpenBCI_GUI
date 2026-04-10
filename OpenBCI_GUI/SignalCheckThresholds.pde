class SignalCheckThresholdUI {

    private Textfield thresholdTF;
    private String name;
    private final int textfieldHeight = 14;
    private int defaultValue_Percentage;
    private int defaultValue_kOhms;
    private int valuePercentage;
    private int valuekOhms;
    private CytonSignalCheckMode signalCheckModeCyton;
    private color textColor = OPENBCI_DARKBLUE;
    private color isActiveBorderColor;

    SignalCheckThresholdUI(ControlP5 _cp5, String _name, int _x, int _y, int _w, int _h, color _isActiveBorderColor, CytonSignalCheckMode _mode) {
        signalCheckModeCyton = _mode;
        name = _name;
        isActiveBorderColor = _isActiveBorderColor;
        defaultValue_Percentage = name.equals("errorThreshold") ? 90 : 75;
        valuePercentage = defaultValue_Percentage;
        defaultValue_kOhms = name == "errorThreshold" ? 2500 : 750;
        valuekOhms = defaultValue_kOhms;
        thresholdTF = createTextfield(_cp5, _name, 0, _x, _y, _w, _h, _isActiveBorderColor);
        updateTextfieldModeChanged(_mode);
        //textfieldHeight = _h;
    }

    public void update() {
        textfieldUpdateHelper.checkTextfield(thresholdTF);
    }
    
    public void updateTextfieldModeChanged(CytonSignalCheckMode _mode) {
        signalCheckModeCyton = _mode;
        customThreshold(thresholdTF, getTextfieldIntVal());
    }

    private Textfield createTextfield(ControlP5 _cp5, String name, int intValue, int _x, int _y, int _w, int _h, color _isActiveBorderColor) {
        //Create these textfields under cp5_widget base instance so because they are always visible
        final Textfield myTextfield = _cp5.addTextfield(name)
            .setPosition(_x, _y)
            .setCaptionLabel("")
            .setSize(_w, _h)
            .setFont(p5)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(textColor)  // text color
            .setColorForeground(isActiveBorderColor)  // border color when not selected - grey
            .setColorActive(isSelected_color)  // border color when selected
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

    public float[] getPosition() {
        return thresholdTF.getPosition();
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
                for (int i = 0; i < globalChannelCount; i++) {
                    is_railed[i].setRailedThreshold((double) val);
                }
            } else {
                for (int i = 0; i < globalChannelCount; i++) {
                    is_railed[i].setRailedWarnThreshold((double) val);
                }
            }
            valuePercentage = val;
        } else {
            if (currentBoard instanceof BoardCyton) {
                W_CytonImpedance cytonImpedanceWidget = (W_CytonImpedance) widgetManager.getWidget("W_CytonImpedance");
                if (name == "errorThreshold") {
                    cytonImpedanceWidget.updateElectrodeStatusYellowThreshold((double)val);
                } else {
                    cytonImpedanceWidget.updateElectrodeStatusGreenThreshold((double)val);
                }
            }
            valuekOhms = val;
        }
    }

    private boolean isSignalCheckRailedMode() {
        if (currentBoard instanceof BoardCyton) { 
            return signalCheckModeCyton == CytonSignalCheckMode.LIVE;
        } else {
            return false;
        }
    }
};