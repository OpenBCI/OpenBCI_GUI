// Focus Viz Widget created by Wangshu Sun, Jul 2016
// first extract characteristics alpha and beta average from FFT data of Fp1 and Fp2 (channel 1 & 2)
// then tell whether or not the person is focused by alpha and beta average
// then draw out isFocused, alpha_average, beta_average to the graph
// and also draw a toggle button to show description

//DM: added robot to simulate keystrokes
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

class FocusViz_Widget {
  // widget settings
  int parentContainer = 3; //which container is it mapped to by default?
  
  // threshold parameters
  float alpha_thresh = 0.7, beta_thresh = 0.7, alpha_upper = 2;

  // outputs
  float alpha_avg = 0, beta_avg = 0;
  boolean isFocused;

  // interactivity
  boolean enableKey = false;  // change this to true if you want the robot to simulate key stroke whenever they hit focused state
  Robot robot;

  // drawing parameters
  boolean showAbout = false;
  PFont myfont = createFont("fonts/Raleway-SemiBold.otf", 12);
  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  color cBack = #020916;
  color cFocus = #ffffff;  //#f0fbfd;
  color cDark = #032e61;
  color cLine = #20669c;
  float x, y, w, h;  //widget topleft xy, width and height
  float xc, yc, wc, hc; // crystal ball center xy, width and height 
  float wg, hg;  //graph width, graph height
  float wl;  // line width
  float xg1, yg1;  //graph1 center xy
  float xg2, yg2;  //graph1 center xy
  float rp;  // padding radius
  float rb;  // button radius
  float xb, yb; // button center xy
  
  FocusViz_Widget(PApplet parent) {
    try { 
      robot = new Robot();
    } catch (AWTException e) {
      e.printStackTrace();
      exit();
    }
    x = container[parentContainer].x;
    y = container[parentContainer].y;
    w = container[parentContainer].w;
    h = container[parentContainer].h - navHeight;
    update_graphic_parameters();
  }

  void update() {
    // focus detection algorithm based on Jordan's clean mind: focus == high alpha average && low beta average
    float FFT_freq_Hz, FFT_value_uV;
    int alpha_count = 0, beta_count = 0;

    for (int Ichan=0; Ichan < 2; Ichan++) {  // only consider first two channels
      for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++) {
        FFT_freq_Hz = fftBuff[Ichan].indexToFreq(Ibin);
        FFT_value_uV = fftBuff[Ichan].getBand(Ibin);

        if (FFT_freq_Hz >= 7.5 && FFT_freq_Hz <= 12.5) { //FFT bins in alpha range
         //println("alpha Ibins - EEG_Processing_User: Ichan = " + Ichan + "Ibin = " + Ibin + ", Freq = " + FFT_freq_Hz + "Hz, FFT Value = " + FFT_value_uV + "uV/bin");
         alpha_avg += FFT_value_uV;
         alpha_count ++;
        }
        else if (FFT_freq_Hz > 12.5 && FFT_freq_Hz <= 30) {
          //println("beta Ibins - EEG_Processing_User: Ichan = " + Ichan + "Ibin = " + Ibin + ", Freq = " + FFT_freq_Hz + "Hz, FFT Value = " + FFT_value_uV + "uV/bin");
          beta_avg += FFT_value_uV;
          beta_count ++;
        }
      }
    }

    alpha_avg = alpha_avg / alpha_count;  // average uV per bin
    alpha_avg = alpha_avg / (openBCI.get_fs_Hz()/Nfft);  // average uV per delta freq
    beta_avg = beta_avg / beta_count;  // average uV per bin
    beta_avg = beta_avg / (openBCI.get_fs_Hz()/Nfft);  // average uV per delta freq
    //current time = int(float(currentTableRowIndex)/openBCI.get_fs_Hz());

    // version 1
    if (alpha_avg > alpha_thresh && alpha_avg < alpha_upper && beta_avg < alpha_thresh) {  // from excel  1/1 0.7/0.7
      isFocused = true;
      //println("alpha: " + alpha_avg + " uV, beta: " + beta_avg + " uV, " + "focused");
    } else {
      isFocused = false;
      //println("alpha: " + alpha_avg + " uV, beta: " + beta_avg + " uV, " + "unfocused");
    }
    
    // robot keystroke
    if (enableKey) {
      if (isFocused) {
        robot.keyPress(KeyEvent.VK_UP);
      }
      else {
        robot.keyRelease(KeyEvent.VK_UP);
      }
    }

    //alpha_avg = beta_avg = 0;
    alpha_count = beta_count = 0;
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update position/size of focus_viz
    // update graphic parameters
    float _x = container[parentContainer].x;
    float _y = container[parentContainer].y;
    float _w = container[parentContainer].w;
    float _h = container[parentContainer].h - navHeight;
    if (x!=_x || y!=_y || w !=_w || h!=_h) {  // if any of four changes
      x = _x;
      y = _y;
      w = _w;
      h = _h;
      update_graphic_parameters();
    }
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

  void draw() {
    //draw nav bars and button bars
    noStroke();
    fill(150, 150, 150);
    rect(x, y, w, navHeight); //top bar
    fill(200, 200, 200);
    rect(x, y+navHeight, w, navHeight); //button bar
    fill(255);
    rect(x+2, y+2, navHeight-4, navHeight-4);
    fill(bgColor, 100);
    //rect(x+3,y+3, (navHeight-7)/2, navHeight-10);
    rect(x+4, y+4, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+4, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+((navHeight-10)/2)+5, y+4, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+((navHeight-10)/2)+5, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10 )/2);
    fill(bgColor);
    textAlign(LEFT, CENTER);
    textFont(f);
    textSize(18);
    text("Focus Visualizer", x+navHeight+2, y+navHeight/2 - 2); //title of widget -- left
    
    // presettings
    translate(x, y + navHeight);
    textAlign(CENTER, CENTER);
    textFont(myfont);

    // draw background
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
    // draw focus tag
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
    text("2.0", xg1 - wl/2 - 14, yg1 - hg/2);
    text("0.7", xg1 - wl/2 - 14, yg1 + hg/2 - hat);
    text("0.0", xg1 - wl/2 - 14, yg1 + hg/2);

    noStroke();
    fill(cFocus);
    float ha = map(alpha_avg, 0, alpha_upper, 0, hg);  //alpha height
    ha = constrain(ha, 0, hg);
    rect(xg1 - wg/2, yg1 + hg/2 - ha, wg, ha); 
    // draw alpha tag
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
    text("2.0", xg2 - wl/2 - 14, yg2 - hg/2);
    text("0.7", xg2 - wl/2 - 14, yg2 + hg/2 - hbt);
    text("0.0", xg2 - wl/2 - 14, yg2 + hg/2);

    noStroke();
    fill(cFocus);
    float hb = map(beta_avg, 0, alpha_upper, 0, hg);  //beta height
    hb = constrain(hb, 0, hg);
    rect(xg2 - wg/2, yg2 + hg/2 - hb, wg, hb); 
    // draw beta tag
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
    // draw question/close button 
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

    // revert settings to default
    translate(-x, -y-navHeight);
    textAlign(LEFT, BASELINE);
  }

  void mousePressed() {
    if (dist(mouseX,mouseY,xb+x,yb+y+navHeight) <= rb) {
      showAbout = !showAbout;
    }
  }
  
  //void keyPressed() {
  //  if (key == TAB) {
  //    if (enableKey == false) {
  //      enableKey = true;
  //      println("key simulation activated.");
  //    }
  //    else {
  //      enableKey = false;
  //      println("key simulation deactivated.");
  //    }
  //  }
  //}
}