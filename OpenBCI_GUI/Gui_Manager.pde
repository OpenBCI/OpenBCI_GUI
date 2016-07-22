
////////////////////////////////////////////////////
//
// This class creates and manages all of the graphical user interface (GUI) elements
// for the primary display.  This is the display with the head, with the FFT frequency
// traces, and with the montage of time-domain traces.  It also holds all of the buttons.
//
// Chip Audette, Oct 2013 - May 2014
//
// Requires the plotting library from gwoptics.  Built on gwoptics 0.5.0
// http://www.gwoptics.org/processing/gwoptics_p5lib/
//
///////////////////////////////////////////////////

//import processing.core.PApplet;
import org.gwoptics.graphics.*;
import org.gwoptics.graphics.graph2D.*;
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.LabelPos;
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace;
import org.gwoptics.graphics.graph2D.backgrounds.*;
import ddf.minim.analysis.*; //for FFT
import java.util.*; //for Array.copyOfRange()

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

//GUI plotting constants
GUI_Manager gui;
color bgColor = color(1, 18, 41);
int navBarHeight = 32;
float default_vertScale_uV = 200.0f;  //used for vertical scale of time-domain montage plot and frequency-domain FFT plot
float displayTime_sec = 5f;    //define how much time is shown on the time-domain montage plot (and how much is used in the FFT plot?)
float dataBuff_len_sec = displayTime_sec + 3f; //needs to be wider than actual display so that filter startup is hidden

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

void initializeGUI() {
  verbosePrint("OpenBCI_GUI: initializeGUI: Starting...");
  String filterDescription = dataProcessing.getFilterDescription(); verbosePrint("OpenBCI_GUI: initializeGUI: 2");
  gui = new GUI_Manager(this, win_x, win_y, nchan, displayTime_sec, default_vertScale_uV, filterDescription, smoothFac[smoothFac_ind]); verbosePrint("OpenBCI_GUI: initializeGUI: 3");
  //associate the data to the GUI traces
  gui.initDataTraces(dataBuffX, dataBuffY_filtY_uV, fftBuff, dataProcessing.data_std_uV, is_railed, dataProcessing.polarity); verbosePrint("OpenBCI_GUI: initializeGUI: 4");
  //limit how much data is plotted...hopefully to speed things up a little
  gui.setDoNotPlotOutsideXlim(true); verbosePrint("OpenBCI_GUI: initializeGUI: 5");
  gui.setDecimateFactor(2); verbosePrint("OpenBCI_GUI: initializeGUI: Done.");
}

void incrementFilterConfiguration() {
  dataProcessing.incrementFilterConfiguration();

  //update the button strings
  gui.filtBPButton.but_txt = "BP Filt\n" + dataProcessing.getShortFilterDescription();
  gui.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
}

void incrementNotchConfiguration() {
  dataProcessing.incrementNotchConfiguration();

  //update the button strings
  gui.filtNotchButton.but_txt = "Notch\n" + dataProcessing.getShortNotchDescription();
  gui.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
}

//------------------------------------------------------------------------
//                       Classes
//------------------------------------------------------------------------

class GUI_Manager {
  ScatterTrace montageTrace;
  ScatterTrace_FFT fftTrace;
  Graph2D gMontage, gFFT, gSpectrogram;
  GridBackground gbMontage, gbFFT;
  Button stopButton;
  PlotFontInfo fontInfo;
  
  HeadPlot headPlot1;
  
  Button[] chanButtons;
  // Button guiPageButton;
  //boolean showImpedanceButtons;
  Button[] impedanceButtonsP;
  Button[] impedanceButtonsN;
  Button biasButton;
  Button intensityFactorButton;
  Button loglinPlotButton;
  Button filtBPButton;
  Button filtNotchButton;
  Button fftNButton;
  Button smoothingButton;
  Button maxDisplayFreqButton;
  Button showPolarityButton;

  //these two buttons toggle between EEG graph state (they are mutually exclusive states)
  Button showMontageButton; // to show uV time graph as opposed to channel controller
  Button showChannelControllerButton; //to drawChannelController on top of gMontage
  // boolean isChannelControllerVisible;

  TextBox titleMontage, titleFFT,titleSpectrogram;
  TextBox[] chanValuesMontage;
  TextBox[] impValuesMontage;
  boolean showMontageValues;
  public int guiPage;
  boolean vertScaleAsLog = true;
  Spectrogram spectrogram;
  boolean showSpectrogram;
  int whichChannelForSpectrogram;

  //define some color variables
  int bgColorGraphs = 255;
  int gridColor = 200;
  int borderColor = 50;
  int axisColor = 50;
  int fontColor = 255;

  // MontageController mc;
  ChannelController cc;
  
  private float fftYOffset[];
  private float default_vertScale_uV=200.0; //this defines the Y-scale on the montage plots...this is the vertical space between traces
  private float[] vertScaleFactor = {1.0f, 2.0f, 5.0f, 50.0f, 0.25f, 0.5f};
  private int vertScaleFactor_ind = 0;
  float vertScale_uV=default_vertScale_uV;
  float vertScaleMin_uV_whenLog = 0.1f;
  float montage_yoffsets[];
  private float[] maxDisplayFreq_Hz = {20.0f, 40.0f, 60.0f, 120.0f};
  private int maxDisplayFreq_ind = 2;
  
  public final static int GUI_PAGE_CHANNEL_ONOFF = 0;
  public final static int GUI_PAGE_IMPEDANCE_CHECK = 1;
  public final static int GUI_PAGE_HEADPLOT_SETUP = 2;
  public final static int N_GUI_PAGES = 3;
  
  public final static String stopButton_pressToStop_txt = "Stop Data Stream";
  public final static String stopButton_pressToStart_txt = "Start Data Stream";
  
  GUI_Manager(PApplet parent,int win_x, int win_y,int nchan,float displayTime_sec, float default_yScale_uV, 
    String filterDescription, float smooth_fac) {  
//  GUI_Manager(PApplet parent,int win_x, int win_y,int nchan,float displayTime_sec, float yScale_uV, float fs_Hz,
//      String montageFilterText, String detectName) {
    showSpectrogram = false;  
    whichChannelForSpectrogram = 0; //assume
    
     //define some layout parameters
    float axes_x, axes_y;
    float spacer_bottom = 30/float(win_y); //want this to be a fixed 30 pixels
    float spacer_top = float(controlPanelCollapser.but_dy)/float(win_y);
    float gutter_topbot = 0.03f;
    float gutter_left = 0.08f;  //edge around the GUI
    float gutter_right = 0.015f;  //edge around the GUI
    float height_UI_tray = 0.1f + spacer_bottom; //0.1f;//0.10f;  //empty space along bottom for UI elements
    float left_right_split = 0.5f;  //notional dividing line between left and right plots, measured from left
    float available_top2bot = 1.0f - 2*gutter_topbot - height_UI_tray;
    float up_down_split = 0.5f;   //notional dividing line between top and bottom plots, measured from top
    float gutter_between_buttons = 0.005f; //space between buttons
    float title_gutter = 0.02f;
    float headPlot_fromTop = 0.12f;
    fontInfo = new PlotFontInfo();

    //montage control panel variables
    // float x_cc = float(win_x)*(left_right_split+gutter_right - 0.01f);
    float x_cc = 5;
    // float y_cc = float(win_y)*(gutter_topbot+title_gutter+spacer_top);
    float y_cc = float(win_y)*(height_UI_tray);
    float w_cc = float(win_x)*(0.09f-gutter_right); //width of montage controls (on left of montage)
    float h_cc = float(win_y)*(available_top2bot-title_gutter-spacer_top); //height of montage controls (on left of montage)
  
    //setup the montage plot...the right side 
    default_vertScale_uV = default_yScale_uV;  //here is the vertical scaling of the traces
    // float[] axisMontage_relPos = { 
    //   left_right_split+gutter_left, 
    //   gutter_topbot+title_gutter+spacer_top, 
    //   (1.0f-left_right_split)-gutter_left-gutter_right, 
    //   available_top2bot-title_gutter-spacer_top
    // }; //from left, from top, width, height

    float[] axisMontage_relPos = {  
      gutter_left, 
      height_UI_tray, 
      left_right_split-gutter_left, 
      available_top2bot-title_gutter-spacer_top
    }; //from left, from top, width, height
    axes_x = float(win_x)*axisMontage_relPos[2];  //width of the axis in pixels
    axes_y = float(win_y)*axisMontage_relPos[3];  //height of the axis in pixels
    gMontage = new Graph2D(parent, int(axes_x), int(axes_y), false);  //last argument is whether the axes cross at zero
    setupMontagePlot(gMontage, win_x, win_y, axisMontage_relPos,displayTime_sec,fontInfo,filterDescription);

    verbosePrint("GUI_Manager: Buttons: " + int(float(win_x)*axisMontage_relPos[0]) + ", " + (int(float(win_y)*axisMontage_relPos[1])-40));

    showMontageButton = new Button (int(float(win_x)*axisMontage_relPos[0]) - 1, int(float(win_y)*axisMontage_relPos[1])-45, 125, 21, "EEG DATA", 14); 
    showMontageButton.makeDropdownButton(true);
    showMontageButton.setColorPressed(color(184,220,105));
    showMontageButton.setColorNotPressed(color(255));
    showMontageButton.hasStroke(false);
    showMontageButton.setIsActive(true);
    showMontageButton.buttonFont = f1;
    showMontageButton.textColorActive = bgColor;


    showChannelControllerButton = new Button (int(float(win_x)*axisMontage_relPos[0])+127, int(float(win_y)*axisMontage_relPos[1])-45, 125, 21, "CHAN SET", 14);
    showChannelControllerButton.makeDropdownButton(true);
    showChannelControllerButton.setColorPressed(color(184,220,105));
    showChannelControllerButton.setColorNotPressed(color(255));
    showChannelControllerButton.hasStroke(false);
    showChannelControllerButton.setIsActive(false);
    showChannelControllerButton.textColorActive = bgColor;

    //setup montage controller
    cc = new ChannelController(x_cc, y_cc, w_cc, h_cc, axes_x, axes_y);


    //setup the FFT plot...bottom on left side
    float[] axisFFT_relPos = { 
      gutter_left + left_right_split, // + 0.1f, 
      up_down_split*available_top2bot + height_UI_tray + gutter_topbot, 
      (1f-left_right_split)-gutter_left-gutter_right, 
      available_top2bot*(1.0f-up_down_split) - gutter_topbot-title_gutter - spacer_top
    }; //from left, from top, width, height
    axes_x = int(float(win_x)*axisFFT_relPos[2]);  //width of the axis in pixels
    axes_y = int(float(win_y)*axisFFT_relPos[3]);  //height of the axis in pixels
    gFFT = new Graph2D(parent, int(axes_x), int(axes_y), false);  //last argument is whether the axes cross at zero
    setupFFTPlot(gFFT, win_x, win_y, axisFFT_relPos,fontInfo);
        
    //setup the spectrogram plot
//    float[] axisSpectrogram_relPos = axisMontage_relPos;
//    axes_x = int(float(win_x)*axisSpectrogram_relPos[2]);
//    axes_y = int(float(win_y)*axisSpectrogram_relPos[3]);
//    gSpectrogram = new Graph2D(parent, axes_x, axes_y, false);  //last argument is wheter the axes cross at zero
//    setupSpectrogram(gSpectrogram, win_x, win_y, axisMontage_relPos,displayTime_sec,fontInfo);
//    int Nspec = 256;
//    int Nstep = 32;
//    spectrogram = new Spectrogram(Nspec,openBCI.fs_Hz,Nstep,displayTime_sec);
//    spectrogram.clim[0] = java.lang.Math.log(gFFT.getYAxis().getMinValue());   //set the minium value for the color scale on the spectrogram
//    spectrogram.clim[1] = java.lang.Math.log(gFFT.getYAxis().getMaxValue()/10.0); //set the maximum value for the color scale on the spectrogram
//    updateMaxDisplayFreq();
    
    //setup the head plot...top on the left side
    float[] axisHead_relPos = axisFFT_relPos.clone();
    // axisHead_relPos[1] = gutter_topbot + spacer_top;  //set y position to be at top of left side
    axisHead_relPos[1] = headPlot_fromTop;  //set y position to be at top of right side
    axisHead_relPos[3] = available_top2bot*up_down_split  - gutter_topbot;
    headPlot1 = new HeadPlot(axisHead_relPos[0],axisHead_relPos[1],axisHead_relPos[2],axisHead_relPos[3],win_x,win_y,nchan);
    setSmoothFac(smooth_fac);
    
    //setup the buttons
    int w,h,x,y;
    h = 26;     //button height, was 25
    y = 2;      //button y position, measured top
              
    // //// Is this block used anymore?  Chip 2014-11-23
    //setup the gui page button
    w = 80; //button width
    x = (int)((3*gutter_between_buttons + left_right_split) * win_x);
    // x = int(float(win_x)*0.3f);
    // guiPageButton = new Button(x,y,w,h,"Page\n" + (guiPage+1) + " of " + N_GUI_PAGES,fontInfo.buttonLabel_size);
    // //// End Ques by Chip 2014-11-12    
        
    //setup the channel on/off buttons...only plot 8 buttons, even if there are more channels
    //because as of 4/3/2014, you can only turn on/off the higher channels (the ones above chan 8)
    //by also turning off the corresponding lower channel.  So, deactiving channel 9 must also
    //deactivate channel 1, therefore, we might as well use just the 1 button.
    int xoffset = (int)(float(win_x)*0.5f);

    w = 80;   //button width
    int w_orig = w;
    //if (nchan > 10) w -= (nchan-8)*2; //make the buttons skinnier
    int nChanBut = min(nchan,8);
    chanButtons = new Button[nChanBut];
    String txt;
    for (int Ibut = 0; Ibut < nChanBut; Ibut++) {
      x = calcButtonXLocation(Ibut, win_x, w, xoffset,gutter_between_buttons);
      txt = "Chan\n" + Integer.toString(Ibut+1);
      if (nchan > 8+Ibut) txt = txt + "+" + Integer.toString(Ibut+1+8);
      chanButtons[Ibut] = new Button(x,y,w,h,txt,fontInfo.buttonLabel_size);
    }
    
    //setup the impedance measurement (lead-off) control buttons
    //showImpedanceButtons = false; //by default, do not show the buttons
    int vertspace_pix = max(1,int(gutter_between_buttons*win_x/4));
    int w1 = w_orig;  //use same width as for buttons above
    int h1 = h/2-vertspace_pix;  //use buttons with half the height
    impedanceButtonsP = new Button[nchan];
    for (int Ibut = 0; Ibut < nchan; Ibut++) {
      x = calcButtonXLocation(Ibut, win_x, w1, xoffset, gutter_between_buttons);
      impedanceButtonsP[Ibut] = new Button(x,y,w1,h1,"Imp P" + (Ibut+1),fontInfo.buttonLabel_size);
    }    
    impedanceButtonsN = new Button[nchan];
    for (int Ibut = 0; Ibut < nchan; Ibut++) {
      x = calcButtonXLocation(Ibut, win_x, w1, xoffset, gutter_between_buttons);
      impedanceButtonsN[Ibut] = new Button(x,y+h-h1,w1,h1,"Imp N" + (Ibut+1),fontInfo.buttonLabel_size);
    }
    h1 = h;
    x = calcButtonXLocation(nchan, win_x, w1, xoffset, gutter_between_buttons);
    biasButton = new Button(x,y,w1,h1,"Bias\n" + "Auto",fontInfo.buttonLabel_size);


    //setup the buttons to control the processing and frequency displays
    int Ibut=0;    
    w = 70;    
    h = 26;
    y = 2;

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    maxDisplayFreqButton = new Button(x,y,w,h,"Max Freq\n" + round(maxDisplayFreq_Hz[maxDisplayFreq_ind]) + " Hz",fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    showPolarityButton = new Button(x,y,w,h,"Polarity\n" + headPlot1.getUsePolarityTrueFalse(),fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    smoothingButton = new Button(x,y,w,h,"Smooth\n" + headPlot1.smooth_fac,fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    loglinPlotButton = new Button(x,y,w,h,"Vert Scale\n" + get_vertScaleAsLogText(),fontInfo.buttonLabel_size);

    //x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    //fftNButton = new Button(x,y,w,h,"FFT N\n" + Nfft,fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    intensityFactorButton = new Button(x,y,w,h,"Vert Scale\n" + round(vertScale_uV) + "uV",fontInfo.buttonLabel_size);

    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    filtNotchButton = new Button(x,y,w,h,"Notch\n" + dataProcessing.getShortNotchDescription(),fontInfo.buttonLabel_size);    
    
    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    filtBPButton = new Button(x,y,w,h,"BP Filt\n" + dataProcessing.getShortFilterDescription(),fontInfo.buttonLabel_size);

    set_vertScaleAsLog(true);
    
    //setup start/stop button
    // x = win_x - int(gutter_right*float(win_x)) - w;
    //x = width/2 - w;
    x = calcButtonXLocation(Ibut++, win_x, w, xoffset,gutter_between_buttons);
    int w_wide = 120;    //button width, wider
    x = x + w - w_wide-((int)(gutter_between_buttons*win_x));  //adjust the x position for the wider button, plus double the gutter
    stopButton = new Button(x,y,w_wide,h,stopButton_pressToStart_txt,fontInfo.buttonLabel_size);
    stopButton.setColorNotPressed(color(184, 220, 105));
 

    //set the initial display page for the GUI
    setGUIpage(GUI_PAGE_HEADPLOT_SETUP);  
  } 
  private int calcButtonXLocation(int Ibut,int win_x,int w, int xoffset, float gutter_between_buttons) {
    // return xoffset + (Ibut * (w + (int)(gutter_between_buttons*win_x)));
    return width - ((Ibut+1) * (w + 2)) - 1;
  }
  
  public void setDefaultVertScale(float val_uV) {
    default_vertScale_uV = val_uV;
    updateVertScale();
  }
  public void setVertScaleFactor_ind(int ind) {
    vertScaleFactor_ind = max(0,ind);
    if (ind >= vertScaleFactor.length) vertScaleFactor_ind = 0;
    updateVertScale();
  }
  public void incrementVertScaleFactor() {
    setVertScaleFactor_ind(vertScaleFactor_ind+1);  //wrap-around is handled inside the function
  }
  public void updateVertScale() {
    vertScale_uV = default_vertScale_uV*vertScaleFactor[vertScaleFactor_ind];
    //println("GUI_Manager: updateVertScale: vertScale_uV = " + vertScale_uV);
    
    //update how the plots are scaled
    if (montageTrace != null) montageTrace.setYScale_uV(vertScale_uV);  //the Y-axis on the montage plot is fixed...the data is simply scaled prior to plotting
    if (gFFT != null) gFFT.setYAxisMax(vertScale_uV);
    headPlot1.setMaxIntensity_uV(vertScale_uV);
    intensityFactorButton.setString("Vert Scale\n" + round(vertScale_uV) + "uV");
    
    //update the Yticks on the FFT plot
    if (gFFT != null) {
      if (vertScaleAsLog) {
        gFFT.setYAxisTickSpacing(1);
      } else {
        gFFT.setYAxisTickSpacing(pow(10.0,floor(log10(vertScale_uV/4))));
      }
    }
    
  }
  public String get_vertScaleAsLogText() {
    if (vertScaleAsLog) {
      return "Log";
    } else {
      return "Linear";
    }
  }
  public void set_vertScaleAsLog(boolean state) {
    vertScaleAsLog = state;
    
    //change the FFT Plot
    if (gFFT != null) {
      if (vertScaleAsLog) {
          gFFT.setYAxisMin(vertScaleMin_uV_whenLog);
          Axis2D ay=gFFT.getYAxis();
          ay.setLogarithmicAxis(true);
          updateVertScale();  //force a re-do of the Yticks
      } else {
          Axis2D ay=gFFT.getYAxis();
          ay.setLogarithmicAxis(false);
          gFFT.setYAxisMin(0.0f);
          updateVertScale();  //force a re-do of the Yticks
      }
    }
    
    //change the head plot
    headPlot1.set_plotColorAsLog(vertScaleAsLog);
    
    //change the button
    if (loglinPlotButton != null) {
      loglinPlotButton.setString("Vert Scale\n" + get_vertScaleAsLogText());
    }
  }
  
  public void setSmoothFac(float fac) {
    headPlot1.smooth_fac = fac;
  }
  
  public void setMaxDisplayFreq_ind(int ind) {
    maxDisplayFreq_ind = max(0,ind);
    if (ind >= maxDisplayFreq_Hz.length) maxDisplayFreq_ind = 0;
    updateMaxDisplayFreq();
  }
  public void incrementMaxDisplayFreq() {
    setMaxDisplayFreq_ind(maxDisplayFreq_ind+1);  //wrap-around is handled inside the function
  }
  public void updateMaxDisplayFreq() {
    //set the frequency limit of the display
    float foo_Hz = maxDisplayFreq_Hz[maxDisplayFreq_ind];
    gFFT.setXAxisMax(foo_Hz);
    if (fftTrace != null) fftTrace.set_plotXlim(0.0f,foo_Hz);
    //gSpectrogram.setYAxisMax(foo_Hz);
    
    //set the ticks
    if (foo_Hz < 38.0f) {
      foo_Hz = 5.0f;
    } else if (foo_Hz < 78.0f) {
      foo_Hz = 10.0f;
    } else if (foo_Hz < 168.0f) {
      foo_Hz = 20.0f;
    } else {
      foo_Hz = (float)floor(foo_Hz / 50.0) * 50.0f;
    }
    gFFT.setXAxisTickSpacing(foo_Hz);
    //gSpectrogram.setYAxisTickSpacing(foo_Hz);
    
    if (maxDisplayFreqButton != null) maxDisplayFreqButton.setString("Max Freq\n" + round(maxDisplayFreq_Hz[maxDisplayFreq_ind]) + " Hz");
  }  
  
  
  public void setDoNotPlotOutsideXlim(boolean state) {
    if (state) {
      //println("GUI_Manager: setDoNotPlotAboveXlim: " + gFFT.getXAxis().getMaxValue());
      fftTrace.set_plotXlim(gFFT.getXAxis().getMinValue(),gFFT.getXAxis().getMaxValue());
      montageTrace.set_plotXlim(gMontage.getXAxis().getMinValue(),gMontage.getXAxis().getMaxValue());
    } else {
      fftTrace.set_plotXlim(Float.NaN,Float.NaN);
    }
  }
  public void setDecimateFactor(int fac) {
    montageTrace.setDecimateFactor(fac);
  }
    
  public void setupMontagePlot(Graph2D g, int win_x, int win_y, float[] axis_relPos,float displayTime_sec, PlotFontInfo fontInfo,String filterDescription) {
  
    g.setAxisColour(axisColor, axisColor, axisColor);
    g.setFontColour(fontColor, fontColor, fontColor);
  
    int x1,y1;
    x1 = int(axis_relPos[0]*float(win_x));
    g.position.x = x1;
    y1 = int(axis_relPos[1]*float(win_y));
    g.position.y = y1;
    //g.position.y = 0;
  
    g.setYAxisMin(-nchan-1.0f);
    g.setYAxisMax(0.0f);
    g.setYAxisTickSpacing(1f);
    g.setYAxisMinorTicks(0);
    g.setYAxisLabelAccuracy(0);
    g.setYAxisLabel("EEG Channel");
    g.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, true);
    g.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
    g.setXAxisMin(-displayTime_sec);
    g.setXAxisMax(0f);
    g.setXAxisTickSpacing(1f);
    g.setXAxisMinorTicks(1);
    g.setXAxisLabelAccuracy(0);
    g.setXAxisLabel("Time (sec)");
    g.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
    // switching on Grid, with different colours for X and Y lines
    gbMontage = new  GridBackground(new GWColour(bgColorGraphs));
    gbMontage.setGridColour(gridColor, gridColor, gridColor, gridColor, gridColor, gridColor);
    g.setBackground(gbMontage);

    g.setBorderColour(borderColor,borderColor,borderColor);
    
    // add title
    titleMontage = new TextBox("EEG Data (" + filterDescription + ")",0,0);
    int x2 = x1 + int(round(0.5*axis_relPos[2]*float(win_x)));
    int y2 = y1 - 2;  //deflect two pixels upward
    titleMontage.x = x2;
    titleMontage.y = y2;
    titleMontage.textColor = color(bgColor);
    titleMontage.setFontSize(14);
    titleMontage.alignH = CENTER;
    
    //add channel data values and impedance values
    int x3, y3;
    //float w = int(round(axis_relPos[2]*win_x));
    TextBox fooBox = new TextBox("",0,0); 
    chanValuesMontage = new TextBox[nchan];
    impValuesMontage = new TextBox[nchan];
    Axis2D xAxis = g.getXAxis();
    Axis2D yAxis = g.getYAxis();
    int h = int(round(axis_relPos[3]*win_y));
    for (int i=0; i<nchan; i++) {
      y3 = y1 + h - yAxis.valueToPosition((float)(-(i+1))); //set to be on the centerline of the trace
      for (int j=0; j<2; j++) { //loop over the different text box types
        switch (j) {
          case 0:
            //voltage value text
            x3 = x1 + xAxis.valueToPosition(xAxis.getMaxValue()) - 2;  //set to right edge of plot.  nudge 2 pixels to the left
            fooBox = new TextBox("0.00 uVrms",x3,y3);
            break;
          case 1:
            //impedance value text
            x3 = x1 + xAxis.valueToPosition(xAxis.getMinValue()) + 2;  //set to left edge of plot.  nudge 2 pixels to the right
            fooBox = new TextBox("0.00 kOhm",x3,y3);
            break;
        }
        fooBox.textColor = color(0,0,0);
        fooBox.drawBackground = true;
        fooBox.backgroundColor = color(255,255,255, 125);
        noStroke();
        switch (j) {
          case 0:
            //voltage value text
            fooBox.alignH = RIGHT;
            chanValuesMontage[i] = fooBox;
            break;
          case 1:
            //impedance value text
            fooBox.alignH = LEFT;
            impValuesMontage[i] = fooBox;
            break;
        }
      }
    }
    showMontageValues = true;  // default to having them NOT displayed    
  }
  
  public void setupFFTPlot(Graph2D g, int win_x, int win_y, float[] axis_relPos,PlotFontInfo fontInfo) {
  
    g.setAxisColour(axisColor, axisColor, axisColor);
    g.setFontColour(fontColor, fontColor, fontColor);
  
    int x1,y1;
    x1 = int(axis_relPos[0]*float(win_x));
    g.position.x = x1;
    y1 = int(axis_relPos[1]*float(win_y));
    g.position.y = y1;
    //g.position.y = 0;
  
    //setup the y axis
    g.setYAxisMin(vertScaleMin_uV_whenLog);
    g.setYAxisMax(vertScale_uV);
    g.setYAxisTickSpacing(1);
    g.setYAxisMinorTicks(0);
    g.setYAxisLabelAccuracy(0);
    //g.setYAxisLabel("EEG Amplitude (uV/sqrt(Hz))");  // Some people prefer this...but you'll have to change the normalization in OpenBCI_GUI\processNewData()
    g.setYAxisLabel("EEG Amplitude (uV per bin)");  // CHIP 2014-10-24...currently, this matches the normalization in OpenBCI_GUI\processNewData()
    g.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
    //get the Y-axis and make it log
    Axis2D ay=g.getYAxis();
    ay.setLogarithmicAxis(true);
  
    //setup the x axis
    g.setXAxisMin(0f);
    g.setXAxisMax(maxDisplayFreq_Hz[maxDisplayFreq_ind]);
    g.setXAxisTickSpacing(10f);
    g.setXAxisMinorTicks(2);
    g.setXAxisLabelAccuracy(0);
    g.setXAxisLabel("Frequency (Hz)");
    g.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
  
  
    // switching on Grid, with differetn colours for X and Y lines
    gbFFT = new  GridBackground(new GWColour(bgColorGraphs));
    gbFFT.setGridColour(gridColor, gridColor, gridColor, gridColor, gridColor, gridColor);
    g.setBackground(gbFFT);

    g.setBorderColour(borderColor,borderColor,borderColor);
    
    // add title
    titleFFT = new TextBox("FFT Plot",0,0);
    int x2 = x1 + int(round(0.5*axis_relPos[2]*float(win_x)));
    int y2 = y1 - 2;  //deflect two pixels upward
    titleFFT.x = x2;
    titleFFT.y = y2;
    titleFFT.textColor = color(255,255,255);
    titleFFT.setFontSize(16);
    titleFFT.alignH = CENTER;
  }
  
  public void setupSpectrogram(Graph2D g, int win_x, int win_y, float[] axis_relPos,float displayTime_sec, PlotFontInfo fontInfo) {
    //start by setting up as if it were the montage plot
    //setupMontagePlot(g, win_x, win_y, axis_relPos,displayTime_sec,fontInfo,title);
    
    g.setAxisColour(220, 220, 220);
    g.setFontColour(255, 255, 255);
  
    int x1 = int(axis_relPos[0]*float(win_x));
    g.position.x = x1;
    int y1 = int(axis_relPos[1]*float(win_y));
    g.position.y = y1;
    
    //setup the x axis
    g.setXAxisMin(-displayTime_sec);
    g.setXAxisMax(0f);
    g.setXAxisTickSpacing(1f);
    g.setXAxisMinorTicks(1);
    g.setXAxisLabelAccuracy(0);
    g.setXAxisLabel("Time (sec)");
    g.setXAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setXAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
 
    //setup the y axis...frequency
    g.setYAxisMin(0.0f-0.5f);
    g.setYAxisMax(maxDisplayFreq_Hz[maxDisplayFreq_ind]);
    g.setYAxisTickSpacing(10.0f);
    g.setYAxisMinorTicks(2);
    g.setYAxisLabelAccuracy(0);
    g.setYAxisLabel("Frequency (Hz)");
    g.setYAxisLabelFont(fontInfo.fontName,fontInfo.axisLabel_size, false);
    g.setYAxisTickFont(fontInfo.fontName,fontInfo.tickLabel_size, false);
        
        
    //make title
    titleSpectrogram = new TextBox(makeSpectrogramTitle(),0,0);
    int x2 = x1 + int(round(0.5*axis_relPos[2]*float(win_x)));
    int y2 = y1 - 2;  //deflect two pixels upward
    titleSpectrogram.x = x2;
    titleSpectrogram.y = y2;
    titleSpectrogram.textColor = color(255,255,255);
    titleSpectrogram.setFontSize(16);
    titleSpectrogram.alignH = CENTER;
  }
  
  public void initializeMontageTraces(float[] dataBuffX, float [][] dataBuffY) {
    
    //create the trace object, add it to the  plotting object, and set the data and scale factor
    //montageTrace  = new ScatterTrace();  //I can't have this here because it dies. It must be in setup()
    gMontage.addTrace(montageTrace);
    montageTrace.setXYData_byRef(dataBuffX, dataBuffY);
    montageTrace.setYScaleFac(1f / vertScale_uV);
    //montageTrace.setYScaleFac(1.0f); //for OpenBCI_GUI_Simpler
    
    //set the y-offsets for each trace in the fft plot.
    //have each trace bumped down by -1.0.
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      montage_yoffsets[Ichan]=(float)(-(Ichan+1));
    }
    montageTrace.setYOffset_byRef(montage_yoffsets);
  }
  
  
  public void initializeFFTTraces(ScatterTrace_FFT fftTrace,FFT[] fftBuff,float[] fftYOffset,Graph2D gFFT) {
    for (int Ichan = 0; Ichan < fftYOffset.length; Ichan++) {
      //set the Y-offste for the individual traces in the plots
      fftYOffset[Ichan]= 0f;  //set so that there is no additional offset
    }
    
    //make the trace for the FFT and add it to the FFT Plot axis
    //fftTrace = new ScatterTrace_FFT(fftBuff); //can't put this here...must be in setup()
    fftTrace.setYOffset(fftYOffset);
    gFFT.addTrace(fftTrace);
  }
    
    
  public void initDataTraces(float[] dataBuffX,float[][] dataBuffY,FFT[] fftBuff,float[] dataBuffY_std, DataStatus[] is_railed, float[] dataBuffY_polarity) {      
    //initialize the time-domain montage-plot traces
    montageTrace = new ScatterTrace();
    montage_yoffsets = new float[nchan];
    initializeMontageTraces(dataBuffX,dataBuffY);
    montageTrace.set_isRailed(is_railed);
  
    //initialize the FFT traces
    fftTrace = new ScatterTrace_FFT(fftBuff); //can't put this here...must be in setup()
    fftYOffset = new float[nchan];
    initializeFFTTraces(fftTrace,fftBuff,fftYOffset,gFFT);
    
    //link the data to the head plot
    headPlot1.setIntensityData_byRef(dataBuffY_std,is_railed);
    headPlot1.setPolarityData_byRef(dataBuffY_polarity);
  }

  public void setShowSpectrogram(boolean show) {
    showSpectrogram = show;
  } 

  public void tellGUIWhichChannelForSpectrogram(int Ichan) { // Ichan starts at zero
    if (Ichan != whichChannelForSpectrogram) {
      whichChannelForSpectrogram = Ichan;
      titleSpectrogram.string = makeSpectrogramTitle();
    }
  }
  public String makeSpectrogramTitle() {
    return ("Spectrogram, Channel " + (whichChannelForSpectrogram+1) + " (As Received)");
  }
  
 
  public void setGUIpage(int page) {
    if ((page >= 0) && (page < N_GUI_PAGES)) {
      guiPage = page;
    } else {
      guiPage = 0;
    }
    //update the text on the button
    // guiPageButton.setString("Page\n" + (guiPage+1) + " of " + N_GUI_PAGES);
  }
  
  public void incrementGUIpage() {
    setGUIpage( (guiPage+1) % N_GUI_PAGES );
  }
  
  public boolean isMouseOnGraph2D(Graph2D g, int mouse_x, int mouse_y) {
    GraphDataPoint dataPoint = new GraphDataPoint();
    getGraph2DdataPoint(g,mouse_x,mouse_y,dataPoint);
    if ( (dataPoint.x >= g.getXAxis().getMinValue()) &
         (dataPoint.x <= g.getXAxis().getMaxValue()) &
         (dataPoint.y >= g.getYAxis().getMinValue()) &
         (dataPoint.y <= g.getYAxis().getMaxValue()) ) {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean isMouseOnMontage(int mouse_x, int mouse_y) {
    return isMouseOnGraph2D(gMontage,mouse_x,mouse_y);
  }
  public boolean isMouseOnFFT(int mouse_x, int mouse_y) {
    return isMouseOnGraph2D(gFFT,mouse_x,mouse_y);
  }

  public void getGraph2DdataPoint(Graph2D g, int mouse_x,int mouse_y, GraphDataPoint dataPoint) {
    int rel_x = mouse_x - int(g.position.x);
    int rel_y = g.getYAxis().getLength() - (mouse_y - int(g.position.y));
    dataPoint.x = g.getXAxis().positionToValue(rel_x);
    dataPoint.y = g.getYAxis().positionToValue(rel_y);
  }
  public void getMontageDataPoint(int mouse_x, int mouse_y, GraphDataPoint dataPoint) {
    getGraph2DdataPoint(gMontage,mouse_x,mouse_y,dataPoint);
    dataPoint.x_units = "sec";
    dataPoint.y_units = "uV";  
  }  
  public void getFFTdataPoint(int mouse_x,int mouse_y,GraphDataPoint dataPoint) {
    getGraph2DdataPoint(gFFT, mouse_x,mouse_y,dataPoint);
    dataPoint.x_units = "Hz";
    dataPoint.y_units = "uV/sqrt(Hz)";
  }
    
//  public boolean isMouseOnHeadPlot(int mouse_x, int mouse_y) {
//    return headPlot1.isPixelInsideHead(mouse_x,mouse_y) {
//  }
  
  public void update(float[] data_std_uV,float[] data_elec_imp_ohm) {
    //assume new data has already arrived via the pre-existing references to dataBuffX and dataBuffY and FftBuff
    montageTrace.generate();  //graph doesn't update without this
    fftTrace.generate(); //graph doesn't update without this
    headPlot1.update();
    //headPlot_widget.headPlot.update();
    cc.update();

    //update the text strings
    String fmt; float val;
    for (int Ichan=0; Ichan < data_std_uV.length; Ichan++) {
      //update the voltage values
      val = data_std_uV[Ichan];
      chanValuesMontage[Ichan].string = String.format(getFmt(val),val) + " uVrms";
      if (montageTrace.is_railed != null) {
        if (montageTrace.is_railed[Ichan].is_railed == true) {
          chanValuesMontage[Ichan].string = "RAILED";
        } else if (montageTrace.is_railed[Ichan].is_railed_warn == true) {
          chanValuesMontage[Ichan].string = "NEAR RAILED";
        }
      } 
      
      //update the impedance values
      val = data_elec_imp_ohm[Ichan]/1000;
      impValuesMontage[Ichan].string = String.format(getFmt(val),val) + " kOhm";
      if (montageTrace.is_railed != null) {
        if (montageTrace.is_railed[Ichan].is_railed == true) {
          impValuesMontage[Ichan].string = "RAILED";
        }
      }
    }
  }
  
  private String getFmt(float val) {
    String fmt;
      if (val > 100.0f) {
        fmt = "%.0f";
      } else if (val > 10.0f) {
        fmt = "%.1f";
      } else {
        fmt = "%.2f";
      }
      return fmt;
  }
  
  public void draw() {
    if(!drawEMG){
      headPlot1.draw();
    }
    
    //draw montage or spectrogram
    if (showSpectrogram == false) {

      //show time-domain montage, only if full channel controller is not visible, to save some processing
      gMontage.draw(); 
    
      //add annotations
      if (showMontageValues) {
        for (int Ichan = 0; Ichan < chanValuesMontage.length; Ichan++) {
          chanValuesMontage[Ichan].draw();
        }
      }
    } else {
      //show the spectrogram
      gSpectrogram.draw();  //draw the spectrogram axes
      titleSpectrogram.draw(); //draw the spectrogram title

      //draw the spectrogram image
      PVector pos = gSpectrogram.position;
      Axis2D ax = gSpectrogram.getXAxis();
      int x = ax.valueToPosition(ax.getMinValue())+(int)pos.x;
      int w = ax.valueToPosition(ax.getMaxValue());
      ax = gSpectrogram.getYAxis();
      int y =  (int) pos.y - ax.valueToPosition(ax.getMinValue()); //position needs top-left.  The MAX value is at the top-left for this plot.
      int h = ax.valueToPosition(ax.getMaxValue());
      //println("GUI_Manager.draw(): x,y,w,h = " + x + " " + y + " " + w + " " + h);
      float max_freq_Hz = gSpectrogram.getYAxis().getMaxValue()-0.5f;
      spectrogram.draw(x,y,w,h,max_freq_Hz);
    }

    //draw the regular FFT spectrum display
    gFFT.draw(); 
    titleFFT.draw();//println("completed FFT draw..."); 
   
    //draw the UI buttons and other elements 
    stopButton.draw();

    //commented out because pages 1-2 are being moved to the left of the EEG montage
    // guiPageButton.draw();

    switch (guiPage) {  //the rest of the elements depend upon what GUI page we're on
      //note: GUI_PAGE_CHANNEL_ON_OFF is the default at the end
      case GUI_PAGE_IMPEDANCE_CHECK:
        //show impedance buttons and text
        for (int Ichan = 0; Ichan < chanButtons.length; Ichan++) {
          impedanceButtonsP[Ichan].draw(); //P-channel buttons
          impedanceButtonsN[Ichan].draw(); //N-channel buttons
        }
        for (int Ichan = 0; Ichan < impValuesMontage.length; Ichan++) {
          impValuesMontage[Ichan].draw();  //impedance values on montage plot
        }
        biasButton.draw();
        break;
      case GUI_PAGE_HEADPLOT_SETUP:
        intensityFactorButton.draw();
        loglinPlotButton.draw();
        filtBPButton.draw();
        filtNotchButton.draw();
        //fftNButton.draw();
        smoothingButton.draw();
        showPolarityButton.draw();
        maxDisplayFreqButton.draw();
        break;
      default:  //assume GUI_PAGE_CHANNEL_ONOFF:
        //show channel buttons
        for (int Ichan = 0; Ichan < chanButtons.length; Ichan++) { chanButtons[Ichan].draw(); }
        //detectButton.draw();
        //spectrogramButton.draw();
    }
    
    if (showMontageValues) {
      for (int Ichan = 0; Ichan < chanValuesMontage.length; Ichan++) {
        chanValuesMontage[Ichan].draw();
      }
    }

    // if(controlPanelCollapser.isActive){
    //   controlPanel.draw();
    // }
    // controlPanelCollapser.draw();

    cc.draw();
    if(cc.showFullController == false){
      titleMontage.draw();
    }
    showMontageButton.draw();
    showChannelControllerButton.draw();

  }

  public void mousePressed(){
    verbosePrint("GUI_Manager: mousePressed: mouse pressed.");
    //if showMontage button pressed
    if(showMontageButton.isMouseHere()){
      //turn off visibility of channel full controller
      cc.showFullController = false;
      showMontageButton.setIsActive(true);
      showMontageButton.buttonFont = f1;
      showChannelControllerButton.setIsActive(false);
      showChannelControllerButton.buttonFont = f2;
    }
    //if showChannelController is pressed
    if(showChannelControllerButton.isMouseHere()){
      cc.showFullController = true;
      showMontageButton.setIsActive(false);
      showMontageButton.buttonFont = f2;
      showChannelControllerButton.setIsActive(true);
      showChannelControllerButton.buttonFont = f1;
    }

    //if cursor inside channel controller
    // if(mouseX >= cc.x1 && mouseX <= (cc.x2 - cc.w2) && mouseY >= cc.y1 && mouseY <= (cc.y1 + cc.h1) ){ 
      verbosePrint("GUI_Manager: mousePressed: Channel Controller mouse pressed...");
      cc.mousePressed();
    // }
    

    //turn off visibility of graph
    // turn on drawing and interactivity of channel controller

    //however, the on/off & impedance values must show to the right at all times ... so it should change a boolean in ChannelController

  }

  public void mouseReleased(){
    //verbosePrint("GUI_Manager: mouseReleased()");

    // if(mouseX >= cc.x1 && mouseX <= (cc.x2 - cc.w2) && mouseY >= cc.y1 && mouseY <= (cc.y1 + cc.h1) ){ 
    verbosePrint("GUI_Manager: mouseReleased(): Channel Controller mouse released...");
    cc.mouseReleased();


    stopButton.setIsActive(false);
    // guiPageButton.setIsActive(false);
    intensityFactorButton.setIsActive(false);
    loglinPlotButton.setIsActive(false);
    filtBPButton.setIsActive(false);
    filtNotchButton.setIsActive(false);
    smoothingButton.setIsActive(false);
    showPolarityButton.setIsActive(false);
    maxDisplayFreqButton.setIsActive(false);
    biasButton.setIsActive(false);
  }
 
};