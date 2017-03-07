
////////////////////////////////////////////////////
//
//    W_focus.pde (ie "Focus Widget")
//
//    This widget helps you visualize the alpha and beta value and the calculated focused state
//    You can ask a robot to press Up Arrow key stroke whenever you are focused.
//    You can also send the focused state to Arduino
//
//    Created by: Conor Russomanno, November 2016
//
///////////////////////////////////////////////////,

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;


class W_Focus extends Widget {
  //to see all core variables/methods of the Widget class, refer to Widget.pde
  Robot robot;    // a key-stroking robot waiting for focused state
  boolean enableKey = false;  // enable key stroke by the robot
  int keyNum = 0; // 0 - up arrow, 1 - Spacebar
  boolean enableSerial = false; // send the Focused state to Arduino

  // output values
  float alpha_avg = 0, beta_avg = 0;
  boolean isFocused;

  // threshold parameters
  float alpha_thresh = 0.7, beta_thresh = 0.7, alpha_upper = 2;

  // drawing parameters
  boolean showAbout = false;
  PFont myfont = createFont("fonts/Raleway-SemiBold.otf", 12);
  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  color cBack = #020916;
  color cFocus = #ffffff;  //#f0fbfd;
  color cDark = #032e61;
  color cLine = #20669c;
  // float x, y, w, h;  //widget topleft xy, width and height
  float xc, yc, wc, hc; // crystal ball center xy, width and height
  float wg, hg;  //graph width, graph height
  float wl;  // line width
  float xg1, yg1;  //graph1 center xy
  float xg2, yg2;  //graph1 center xy
  float rp;  // padding radius
  float rb;  // button radius
  float xb, yb; // button center xy

  W_Focus(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("StrokeKeyWhenFocused", "KeyPress", Arrays.asList("OFF", "UP", "SPACE"), 0);
    addDropdown("SerialSendFocused", "Serial", Arrays.asList("OFF", "ON"), 0);

    // focus Viz
    try {
      robot = new Robot();
    } catch (AWTException e) {
      e.printStackTrace();
      exit();
    }
    update_graphic_parameters();

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
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
    //alpha_avg = alpha_avg / (openBCI.get_fs_Hz()/Nfft);  // average uV per delta freq
    beta_avg = beta_avg / beta_count;  // average uV per bin
    //beta_avg = beta_avg / (openBCI.get_fs_Hz()/Nfft);  // average uV per delta freq
    //current time = int(float(currentTableRowIndex)/openBCI.get_fs_Hz());

    // version 1
    if (alpha_avg > alpha_thresh && alpha_avg < alpha_upper && beta_avg < alpha_thresh) {
      isFocused = true;
    } else {
      isFocused = false;
    }

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

    //alpha_avg = beta_avg = 0;
    alpha_count = beta_count = 0;

    // ----------- send the focused state to Arduino if turned on -----------
    if (enableSerial) {
      try {
        serial_output.write(int(isFocused) + 48);
        serial_output.write('\n');
      }
      catch(RuntimeException e) {
        if (isVerbose) println("serial not present, search 'serial_output' in OpenBCI.pde and check serial settings.");
      }
    }

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();

    // presettings before drawing Focus Viz
    translate(x, y);
    textAlign(CENTER, CENTER);
    textFont(myfont);

    // draw background rectangle
    fill(cBack);
    noStroke();
    rect(0, 0, w, h);

    // draw focus crystalball
    noStroke();
    if (isFocused) {
      fill(cFocus);
    } else {
      fill(cDark);
    }
    ellipse(xc, yc, wc, hc);
    // draw focus label
    if (isFocused) {
      fill(cFocus);
    } else {
      fill(cLine);
    }
    text("focus", xc, yc + hc/2 + 16);

    // draw alpha meter
    noStroke();
    fill(cDark);
    rect(xg1 - wg/2, yg1 - hg/2, wg, hg);

    stroke(cLine);
    line(xg1 - wl/2, yg1 - hg/2, xg1 + wl/2, yg1 - hg/2);
    float hat = map(alpha_thresh, 0, alpha_upper, 0, hg);  // alpha threshold height
    line(xg1 - wl/2, yg1 + hg/2 - hat, xg1 + wl/2, yg1 + hg/2 - hat);
    line(xg1 - wl/2, yg1 + hg/2, xg1 + wl/2, yg1 + hg/2);

    noStroke();
    fill(cLine);
    text(String.format("%.01f", alpha_upper), xg1 - wl/2 - 14, yg1 - hg/2);
    text(String.format("%.01f", alpha_thresh), xg1 - wl/2 - 14, yg1 + hg/2 - hat);
    text("0.0", xg1 - wl/2 - 14, yg1 + hg/2);

    noStroke();
    fill(cFocus);
    float ha = map(alpha_avg, 0, alpha_upper, 0, hg);  //alpha height
    ha = constrain(ha, 0, hg);
    rect(xg1 - wg/2, yg1 + hg/2 - ha, wg, ha);
    // draw alpha label
    if (alpha_avg > alpha_thresh && alpha_avg < alpha_upper) {
      fill(cFocus);
    } else {
      fill(cLine);
    }
    text("alpha", xg1, yg1 + hg/2 + 16);

    // draw beta meter
    noStroke();
    fill(cDark);
    rect(xg2 - wg/2, yg2 - hg/2, wg, hg);

    stroke(cLine);
    line(xg2 - wl/2, yg2 - hg/2, xg2 + wl/2, yg2 - hg/2);
    float hbt = map(beta_thresh, 0, alpha_upper, 0, hg);  // beta threshold height
    line(xg2 - wl/2, yg2 + hg/2 - hbt, xg2 + wl/2, yg2 + hg/2 - hbt);
    line(xg2 - wl/2, yg2 + hg/2, xg2 + wl/2, yg2 + hg/2);

    noStroke();
    fill(cLine);
    text(String.format("%.01f", alpha_upper), xg2 - wl/2 - 14, yg2 - hg/2);
    text(String.format("%.01f", beta_thresh), xg2 - wl/2 - 14, yg2 + hg/2 - hbt);
    text("0.0", xg2 - wl/2 - 14, yg2 + hg/2);

    noStroke();
    fill(cFocus);
    float hb = map(beta_avg, 0, alpha_upper, 0, hg);  //beta height
    hb = constrain(hb, 0, hg);
    rect(xg2 - wg/2, yg2 + hg/2 - hb, wg, hb);
    // draw beta label
    if (beta_avg < alpha_thresh) {
      fill(cFocus);
    } else {
      fill(cLine);
    }
    text("beta", xg2, yg2 + hg/2 + 16);

    // draw about
    if (showAbout) {
      stroke(255);
      fill(cBack);

      rect(rp, rp, w-rp*2, h-rp*2);
      textAlign(LEFT, TOP);
      fill(cFocus);
      text("About Focus Visualizer:\n\nThis algorithm interprets high alpha values and low beta values as a focused state. It is based on the brainwaves of subject Jordan Frand, but also worked for 30 other subjects including both hildren and adults.\n\nA focused state is where the average alpha wave amplitude is avobe 0.7 uV, and the average beta wave amplitude is below 0.7 uV, both must be below 2 uV to eliminate noise.\n\nHere, “average” means averaged amplitudes in either alpha or beta frequency ranges, divided by FFT resolution bandwidth.\n\nFor more information, contact wangshu.sun@hotmail.com.", rp*1.5, rp*1.5, w-rp*3, h-rp*3);
    }
    // draw the button that toggles information
    noStroke();
    fill(cFocus);
    ellipse(xb, yb, rb, rb);
    fill(cBack);
    textAlign(CENTER, CENTER);
    if (showAbout) {
      text("x", xb, yb);
    } else {
      text("?", xb, yb);
    }

    // revert origin point of draw to default
    translate(-x, -y);
    textAlign(LEFT, BASELINE);

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    update_graphic_parameters();

  }

  void update_graphic_parameters () {
    xc = w/4;
    yc = h/2;
    wc = w/4;
    hc = w/4;
    wg = 0.07*w;
    hg = 0.75*h;
    wl = 0.11*w;
    xg1 = 0.6*w;
    yg1 = 0.5*h;
    xg2 = 0.83*w;
    yg2 = 0.5*h;
    rp = max(w*0.05, h*0.05);
    rb = min(w*0.05, h*0.05);
    xb = w-rp;
    yb = rp;
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...
    if (dist(mouseX,mouseY,xb+x,yb+y) <= rb) {
      showAbout = !showAbout;
    }

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

  }

  //add custom functions here
  void customFunction(){
    //this is a fake function... replace it with something relevant to this widget

  }

};

// //These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void StrokeKeyWhenFocused(int n){
  // println("Item " + (n+1) + " selected from Dropdown 1");
  if(n==0){
    //do this
    w_focus.enableKey = false;
    println("The robot ignores focused state and will not press any key.");
  } else if(n==1){
    //do this instead
    w_focus.enableKey = true;
    w_focus.keyNum = 0;
    println("The robot will keep pressing Arrow Up key when you are focused, and release the key when you lose focus.");
  } else if(n==2){
    //do this instead
    w_focus.enableKey = true;
    w_focus.keyNum = 1;
    println("The robot will keep pressing Spacebar when you are focused, and release the key when you lose focus.");
  }

  closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

void SerialSendFocused(int n){
  if(n==0){
    //do this
    w_focus.enableSerial = false;
    println("Serial write off.");
  } else if(n==1){
    //do this instead
    w_focus.enableSerial = true;
    println("Serial write on, writing character 1 (int 49) when focused, and character 0 (int 48) when losing focus.");
    println("Current output port name: " + serial_output_portName + ". Current baud rate: " + serial_output_baud + ".");
    println("You can change serial settings in OpenBCI_GUI.pde by searching serial_output.");
  }
  closeAllDropdowns();
}
