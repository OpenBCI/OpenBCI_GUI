
////////////////////////////////////////////////////
//
//    W_focus.pde (ie "Focus Widget")
//
//    This widget helps you visualize the alpha and beta value and the calculated focused state
//    You can ask a robot to press Up Arrow key stroke whenever you are focused.
//    You can also send the focused state to Arduino
//
//    Created by: Wangshu Sun, August 2016
//
///////////////////////////////////////////////////,

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

// color enums
public enum FocusColors {
    GREEN, CYAN, ORANGE
}

class W_Focus extends Widget {
    //to see all core variables/methods of the Widget class, refer to Widget.pde
    Robot robot;    // a key-stroking robot waiting for focused state
    boolean enableKey = false;  // enable key stroke by the robot
    int keyNum = 0; // 0 - up arrow, 1 - Spacebar
    boolean enableSerial = false; // send the Focused state to Arduino

    // output values
    float alpha_avg = 0, beta_avg = 0;
    boolean isFocused;

    // alpha, beta threshold default values
    float alpha_thresh = 0.7, beta_thresh = 0.7, alpha_upper = 2, beta_upper = 2;

    // drawing parameters
    boolean showAbout = false;
    PFont myfont = createFont("fonts/Raleway-SemiBold.otf", 12);
    PFont f = f1; //for widget title

    FocusColors focusColors = FocusColors.GREEN;

    color cBack, cDark, cMark, cFocus, cWave, cPanel;

    // float x, y, w, h;  //widget topleft xy, width and height
    float xc, yc, wc, hc; // crystal ball center xy, width and height
    float wg, hg;  //graph width, graph height
    float wl;  // line width
    float xg1, yg1;  //graph1 center xy
    float xg2, yg2;  //graph1 center xy
    float rp;  // padding radius
    float rb;  // button radius
    float xb, yb; // button center xy

    // two sliders for alpha and one slider for beta
    FocusSlider sliderAlphaMid, sliderBetaMid;
    FocusSlider_Static sliderAlphaTop;
    Button infoButton;
    int infoButtonSize = 18;

    W_Focus(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        // initialize graphics parameters
        onColorChange();
        update_graphic_parameters();

        // sliders
        sliderAlphaMid = new FocusSlider(x + xg1 + wg * 0.8, y + yg1 + hg/2, y + yg1 - hg/2, alpha_thresh / alpha_upper);
        sliderAlphaTop = new FocusSlider_Static(x + xg1 + wg * 0.8, y + yg1 + hg/2, y + yg1 - hg/2);
        sliderBetaMid = new FocusSlider(x + xg2 + wg * 0.8, y + yg2 + hg/2, y + yg2 - hg/2, beta_thresh / beta_upper);

        ///Focus widget settings
        settings.focusThemeSave = 0;
        settings.focusKeySave = 0;

        //Dropdowns.
        addDropdown("ChooseFocusColor", "Theme", Arrays.asList("Green", "Orange", "Cyan"), settings.focusThemeSave);
        addDropdown("StrokeKeyWhenFocused", "KeyPress", Arrays.asList("OFF", "UP", "SPACE"), settings.focusKeySave);

        //More info button
        infoButton = new Button(x + w - dropdownWidth * 2 - infoButtonSize - 10, y - navH + 2, infoButtonSize, infoButtonSize, "?", 14);
        infoButton.setCornerRoundess((int)(navHeight-6));
        infoButton.setFont(p5,12);
        infoButton.setColorNotPressed(color(57,128,204));
        infoButton.setFontColorNotActive(color(255));
        infoButton.setHelpText("Click this button to view details on the Focus Widget.");
        infoButton.hasStroke(false);

        // prepare simulate keystroking
        try {
            robot = new Robot();
        } catch (AWTException e) {
            e.printStackTrace();
            exit();
        }

    }

    void onColorChange() {
        switch(focusColors) {
            case GREEN:
                cBack = #ffffff;   //white
                cDark = #3068a6;   //medium/dark blue
                cMark = #4d91d9;    //lighter blue
                cFocus = #b8dc69;   //theme green
                cWave = #ffdd3a;    //yellow
                cPanel = #f5f5f5;   //little grey
                break;
            case ORANGE:
                cBack = #ffffff;   //white
                cDark = #377bc4;   //medium/dark blue
                cMark = #5e9ee2;    //lighter blue
                cFocus = #fcce51;   //orange
                cWave = #ffdd3a;    //yellow
                cPanel = #f5f5f5;   //little grey
                break;
            case CYAN:
                cBack = #ffffff;   //white
                cDark = #377bc4;   //medium/dark blue
                cMark = #5e9ee2;    //lighter blue
                cFocus = #91f4fc;   //cyan
                cWave = #ffdd3a;    //yellow
                cPanel = #f5f5f5;   //little grey
                break;
        }
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
        updateFocusState(); // focus calculation
        invokeKeyStroke();  // robot keystroke

        // update sliders
        sliderAlphaMid.update();
        sliderAlphaTop.update();
        sliderBetaMid.update();

        // update threshold values
        alpha_thresh = alpha_upper * sliderAlphaMid.getVal();
        beta_thresh = beta_upper * sliderBetaMid.getVal();

        alpha_upper = sliderAlphaTop.getVal() * 2;
        beta_upper = alpha_upper;

        sliderAlphaMid.setVal(alpha_thresh / alpha_upper);
        sliderBetaMid.setVal(beta_thresh / beta_upper);
    }

    void updateFocusState() {
        // focus detection algorithm based on Jordan's clean mind: focus == high alpha average && low beta average
        float FFT_freq_Hz, FFT_value_uV;
        int alpha_count = 0, beta_count = 0;

        for (int Ichan=0; Ichan < 2; Ichan++) {  // only consider first two channels
            for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++) {
                FFT_freq_Hz = fftBuff[Ichan].indexToFreq(Ibin);
                FFT_value_uV = fftBuff[Ichan].getBand(Ibin);

                if (FFT_freq_Hz >= 7.5 && FFT_freq_Hz <= 12.5) { //FFT bins in alpha range
                    alpha_avg += FFT_value_uV;
                    alpha_count ++;
                }
                else if (FFT_freq_Hz > 12.5 && FFT_freq_Hz <= 30) {  //FFT bins in beta range
                    beta_avg += FFT_value_uV;
                    beta_count ++;
                }
            }
        }

        alpha_avg = alpha_avg / alpha_count;  // average uV per bin
        beta_avg = beta_avg / beta_count;  // average uV per bin

        // version 1
        if (alpha_avg > alpha_thresh && alpha_avg < alpha_upper && beta_avg < beta_thresh) {
            isFocused = true;
        } else {
            isFocused = false;
        }
    }

    void invokeKeyStroke() {
        // robot keystroke
        if (enableKey) {
            if (keyNum == 0) {
                if (isFocused) {
                    robot.keyPress(KeyEvent.VK_UP);    //if you want to change to other key, google "java keyEvent" to see the full list
                }
                else {
                    robot.keyRelease(KeyEvent.VK_UP);
                }
            }
            else if (keyNum == 1) {
                if (isFocused) {
                    robot.keyPress(KeyEvent.VK_SPACE);    //if you want to change to other key, google "java keyEvent" to see the full list
                }
                else {
                    robot.keyRelease(KeyEvent.VK_SPACE);
                }
            }
        }
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        //----------------- presettings before drawing Focus Viz --------------
        translate(x, y);
        textAlign(CENTER, CENTER);
        textFont(myfont);

        //----------------- draw background rectangle and panel -----------------
        fill(cBack);
        noStroke();
        rect(0, 0, w, h);

        fill(cPanel);
        noStroke();
        rect(rp, rp, w-rp*2, h-rp*2);

        //----------------- draw focus crystalball -----------------
        noStroke();
        if (isFocused) {
            fill(cFocus);
            stroke(cFocus);
        } else {
            fill(cDark);
        }
        ellipse(xc, yc, wc, hc);
        noStroke();
        // draw focus label
        if (isFocused) {
            fill(cFocus);
            text("focused!", xc, yc + hc/2 + 16);
        } else {
            fill(cMark);
            text("not focused", xc, yc + hc/2 + 16);
        }

        //----------------- draw alpha meter -----------------
        noStroke();
        fill(cDark);
        rect(xg1 - wg/2, yg1 - hg/2, wg, hg);

        float hat = map(alpha_thresh, 0, alpha_upper, 0, hg);  // alpha threshold height
        stroke(cMark);
        line(xg1 - wl/2, yg1 + hg/2, xg1 + wl/2, yg1 + hg/2);
        line(xg1 - wl/2, yg1 - hg/2, xg1 + wl/2, yg1 - hg/2);
        line(xg1 - wl/2, yg1 + hg/2 - hat, xg1 + wl/2, yg1 + hg/2 - hat);

        // draw alpha zone and text
        noStroke();
        if (alpha_avg > alpha_thresh && alpha_avg < alpha_upper) {
            fill(cFocus);
        } else {
            fill(cMark);
        }
        rect(xg1 - wg/2, yg1 - hg/2, wg, hg - hat);
        text("alpha", xg1, yg1 + hg/2 + 16);

        // draw connection between two sliders
        stroke(cMark);
        line(xg1 + wg * 0.8, yg1 - hg/2 + 10, xg1 + wg * 0.8, yg1 + hg/2 - hat - 10);

        noStroke();
        fill(cMark);
        text(String.format("%.01f", alpha_upper), xg1 - wl/2 - 14, yg1 - hg/2);
        text(String.format("%.01f", alpha_thresh), xg1 - wl/2 - 14, yg1 + hg/2 - hat);
        text("0.0", xg1 - wl/2 - 14, yg1 + hg/2);

        stroke(cWave);
        strokeWeight(4);
        float ha = map(alpha_avg, 0, alpha_upper, 0, hg);  //alpha height
        ha = constrain(ha, 0, hg);
        line(xg1 - wl/2, yg1 + hg/2 - ha, xg1 + wl/2, yg1 + hg/2 - ha);
        strokeWeight(1);

        //----------------- draw beta meter -----------------
        noStroke();
        fill(cDark);
        rect(xg2 - wg/2, yg2 - hg/2, wg, hg);

        float hbt = map(beta_thresh, 0, beta_upper, 0, hg);  // beta threshold height
        stroke(cMark);
        line(xg2 - wl/2, yg2 + hg/2, xg2 + wl/2, yg2 + hg/2);
        line(xg2 - wl/2, yg2 - hg/2, xg2 + wl/2, yg2 - hg/2);
        line(xg2 - wl/2, yg2 + hg/2 - hbt, xg2 + wl/2, yg2 + hg/2 - hbt);

        // draw beta zone and text
        noStroke();
        if (beta_avg < beta_thresh) {
            fill(cFocus);
        } else {
            fill(cMark);
        }
        rect(xg2 - wg/2, yg2 + hg/2 - hbt, wg, hbt);
        text("beta", xg2, yg2 + hg/2 + 16);

        // draw connection between slider and bottom
        stroke(cMark);
        float yt = yg2 + hg/2 - hbt + 10;   // y threshold
        yt = constrain(yt, yg2 - hg/2 + 10, yg2 + hg/2);
        line(xg2 + wg * 0.8, yg2 + hg/2, xg2 + wg * 0.8, yt);

        noStroke();
        fill(cMark);
        text(String.format("%.01f", beta_upper), xg2 - wl/2 - 14, yg2 - hg/2);
        text(String.format("%.01f", beta_thresh), xg2 - wl/2 - 14, yg2 + hg/2 - hbt);
        text("0.0", xg2 - wl/2 - 14, yg2 + hg/2);

        stroke(cWave);
        strokeWeight(4);
        float hb = map(beta_avg, 0, beta_upper, 0, hg);  //beta height
        hb = constrain(hb, 0, hg);
        line(xg2 - wl/2, yg2 + hg/2 - hb, xg2 + wl/2, yg2 + hg/2 - hb);
        strokeWeight(1);

        translate(-x, -y);

        //------------------ draw sliders --------------------
        sliderAlphaMid.draw();
        sliderAlphaTop.draw();
        sliderBetaMid.draw();

        //----------------- draw about button -----------------
        translate(x, y);
        if (showAbout) {
            stroke(cDark);
            fill(cBack);

            rect(rp, rp, w-rp*2, h-rp*2);
            textAlign(LEFT, TOP);
            fill(cDark);
            text("This widget recognizes a focused mental state by looking at alpha and beta wave levels on channel 1 & 2. For better result, try setting the smooth at 0.98 in FFT plot.\n\nThe algorithm thinks you are focused when the alpha level is between 0.7~2uV and the beta level is between 0~0.7 uV, otherwise it thinks you are not focused. It is designed based on Jordan Frand’s brainwave and tested on other subjects, and you can playback Jordan's file in W_Focus folder.\n\nYou can turn on KeyPress and use your focus play a game, so whenever you are focused, the specified UP arrow or SPACE key will be pressed down, otherwise it will be released. You can also try out the Arduino output feature, example and instructions are included in W_Focus folder. For more information, contact wangshu.sun@hotmail.com.", rp*1.5, rp*1.5, w-rp*3, h-rp*3);
        }
        
        /*
        noStroke();
        fill(cDark);
        ellipse(xb, yb, rb, rb);
        fill(cBack);
        textAlign(CENTER, CENTER);
        if (showAbout) {
            text("x", xb, yb);
        } else {
            text("?", xb, yb);
        }
        */

        //----------------- revert origin point of draw to default -----------------
        translate(-x, -y);
        textAlign(LEFT, BASELINE);
        // draw the button that toggles information
        infoButton.draw();
        popStyle();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        infoButton.setPos(x + w - dropdownWidth * 2 - infoButtonSize - 10, y - navH + 2);

        update_graphic_parameters();

        //update sliders...
        sliderAlphaMid.screenResized(x + xg1 + wg * 0.8, y + yg1 + hg/2, y + yg1 - hg/2);
        sliderAlphaTop.screenResized(x + xg1 + wg * 0.8, y + yg1 + hg/2, y + yg1 - hg/2);
        sliderBetaMid.screenResized(x + xg2 + wg * 0.8, y + yg2 + hg/2, y + yg2 - hg/2);
    }

    void update_graphic_parameters () {
        xc = w/4;
        yc = h/2;
        wc = w/4;
        hc = w/4;
        wg = 0.07*w;
        hg = 0.64*h;
        wl = 0.11*w;
        xg1 = 0.6*w;
        yg1 = 0.5*h;
        xg2 = 0.83*w;
        yg2 = 0.5*h;
        rp = max(w*0.05, h*0.05);
        rb = 20;
        xb = w-rp;
        yb = rp;
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        //  about button
        if (!this.dropdownIsActive) {
            if (dist(mouseX,mouseY,xb+x,yb+y) <= rb) {
                showAbout = !showAbout;
            }
        }

        if (infoButton.isMouseHere()) {
            infoButton.setIsActive(true);
        }

        // sliders
        sliderAlphaMid.mousePressed();
        sliderAlphaTop.mousePressed();
        sliderBetaMid.mousePressed();
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if (infoButton.isActive && infoButton.isMouseHere()) {
            showAbout = !showAbout;
        }
        infoButton.setIsActive(false);

        // sliders
        sliderAlphaMid.mouseReleased();
        sliderAlphaTop.mouseReleased();
        sliderBetaMid.mouseReleased();
    }

};

/* ---------------------- Supporting Slider Classes ---------------------------*/

// abstract basic slider
public abstract class BasicSlider {
    float x, y, w, h;  // center x, y. w, h means width and height of triangle
    float yBot, yTop;   // y range. Notice val of top y is less than bottom y
    boolean isPressed = false;
    color cNormal = #CCCCCC;
    color cPressed = #FF0000;

    BasicSlider(float _x, float _yBot, float _yTop) {
        x = _x;
        yBot = _yBot;
        yTop = _yTop;
        w = 10;
        h = 10;
    }

    // abstract functions

    abstract void update();
    abstract void screenResized(float _x, float _yBot, float _yTop);
    abstract float getVal();
    abstract void setVal(float _val);

    // shared functions

    void draw() {
        if (isPressed) fill(cPressed);
        else fill(cNormal);
        noStroke();
        triangle(x-w/2, y, x+w/2, y-h/2, x+w/2, y+h/2);
    }

    void mousePressed() {
        if (abs(mouseX - (x)) <= w/2 && abs(mouseY - y) <= h/2) {
            isPressed = true;
        }
    }

    void mouseReleased() {
        if (isPressed) {
            isPressed = false;
        }
    }
}

// middle slider that changes value and move
public class FocusSlider extends BasicSlider {
    private float val = 0;  // val = 0 ~ 1 -> yBot to yTop
    final float valMin = 0;
    final float valMax = 0.90;
    FocusSlider(float _x, float _yBot, float _yTop, float _val) {
        super(_x, _yBot, _yTop);
        val = constrain(_val, valMin, valMax);
        y = map(val, 0, 1, yBot, yTop);
    }

    public void update() {
        if (isPressed) {
            float newVal = map(mouseY, yBot, yTop, 0, 1);
            val = constrain(newVal, valMin, valMax);
            y = map(val, 0, 1, yBot, yTop);
            println("Focus: " + val);
        }
    }

    public void screenResized(float _x, float _yBot, float _yTop) {
        x = _x;
        yBot = _yBot;
        yTop = _yTop;
        y = map(val, 0, 1, yBot, yTop);
    }

    public float getVal() {
        return val;
    }

    public void setVal(float _val) {
        val = constrain(_val, valMin, valMax);
        y = map(val, 0, 1, yBot, yTop);
    }
}

// top slider that changes value but doesn't move
public class FocusSlider_Static extends BasicSlider {
    private float val = 0;  // val = 0 ~ 1 -> yBot to yTop
    final float valMin = 0.5;
    final float valMax = 5.0;
    FocusSlider_Static(float _x, float _yBot, float _yTop) {
        super(_x, _yBot, _yTop);
        val = 1;
        y = yTop;
    }

    public void update() {
        if (isPressed) {
            float diff = map(mouseY, yBot, yTop, -0.07, 0);
            val = constrain(val + diff, valMin, valMax);
            println("Focus: " + val);
        }
    }

    public void screenResized(float _x, float _yBot, float _yTop) {
        x = _x;
        yBot = _yBot;
        yTop = _yTop;
        y = yTop;
    }

    public float getVal() {
        return val;
    }

    public void setVal(float _val) {
        val = constrain(_val, valMin, valMax);
    }

}

/* ---------------- Global Functions For Menu Entries --------------------*/

// //These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void StrokeKeyWhenFocused(int n){
    // println("Item " + (n+1) + " selected from Dropdown 1");
    if(n==0){
        //do this
        w_focus.enableKey = false;
        //println("The robot ignores focused state and will not press any key.");
    } else if(n==1){
        //do this instead
        w_focus.enableKey = true;
        w_focus.keyNum = 0;
        //println("The robot will keep pressing Arrow Up key when you are focused, and release the key when you lose focus.");
    } else if(n==2){
        //do this instead
        w_focus.enableKey = true;
        w_focus.keyNum = 1;
        //println("The robot will keep pressing Spacebar when you are focused, and release the key when you lose focus.");
    }
    settings.focusKeySave = n;
    closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

void ChooseFocusColor(int n){
    if(n==0){
        w_focus.focusColors = FocusColors.GREEN;
        w_focus.onColorChange();
    } else if(n==1){
        w_focus.focusColors = FocusColors.ORANGE;
        w_focus.onColorChange();
    } else if(n==2){
        w_focus.focusColors = FocusColors.CYAN;
        w_focus.onColorChange();
    }
    settings.focusThemeSave = n;
    closeAllDropdowns();
}
