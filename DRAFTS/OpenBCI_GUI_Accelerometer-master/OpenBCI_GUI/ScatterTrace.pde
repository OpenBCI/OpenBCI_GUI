
//////////////////
//
// The ScatterTrace class is used to draw and manage the traces on each
// X-Y line plot created using gwoptics graphing library
//
// Created: Chip Audette, May 2014
//
// Based on examples in gwoptics graphic library v0.5.0
// http://www.gwoptics.org/processing/gwoptics_p5lib/
//
// Note that this class does NOT store any of the data used for the
// plot.  Instead, you point it to the data that lives in your
// own program.  In Java-speak, I believe that this is called
// "aliasing"...in this class, I have made an "alias" to your data.
// Some people consider this dangerous.  Because Processing is slow,
// this was one technique for making it faster.  By making an alias
// to your data, you don't need to pass me the data for every update
// and I don't need to make a copy of it.  Instead, once you update
// your data array, the alias in this class is already pointing to
// the right place.  Cool, huh?
//
////////////////

//import processing.core.PApplet;
import org.gwoptics.graphics.*;
import org.gwoptics.graphics.graph2D.*;
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.LabelPos;
import org.gwoptics.graphics.graph2D.traces.Blank2DTrace;
import org.gwoptics.graphics.graph2D.backgrounds.*;
import java.awt.Color;

class ScatterTrace extends Blank2DTrace {
  private float[] dataX;
  private float[][] dataY;
  private float plotYScale = 1f;  //multiplied to data prior to plotting
  private float plotYOffset[];  //added to data prior to plotting, after applying plotYScale
  private int decimate_factor = 1;  // set to 1 to plot all points, 2 to plot every other point, 3 for every third point
  private DataStatus[] is_railed;
  PFont font = createFont("Arial", 16);
  float[] plotXlim;

  public ScatterTrace() {
    //font = createFont("Arial",10);
    plotXlim = new float[] {
      Float.NaN, Float.NaN
    };
  }

  /* set the plot's X and Y data by overwriting the existing data */
  public void setXYData_byRef(float[] x, float[][] y) {
    //dataX = x.clone();  //makes a copy
    dataX = x;  //just copies the reference!
    setYData_byRef(y);
  }   

  public void setYData_byRef(float[][] y) {
    //dataY = y.clone(); //makes a copy
    dataY = y;//just copies the reference!
  }   

  public void setYOffset_byRef(float[] yoff) {
    plotYOffset = yoff;  //just copies the reference!
  }

  public void setYScale_uV(float yscale_uV) {
    setYScaleFac(1.0f/yscale_uV);
  }

  public void setYScaleFac(float yscale) {
    plotYScale = yscale;
  }

  public void set_plotXlim(float val_low, float val_high) {
    if (val_high < val_low) {
      float foo = val_low;
      val_low = val_high;
      val_high = foo;
    }
    plotXlim[0]=val_low;
    plotXlim[1]=val_high;
  }
  public void set_isRailed(DataStatus[] is_rail) {
    is_railed = is_rail;
  }

  //here is the fucntion that gets called with every call to the GUI's own draw() fucntion
  public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
    float x_val;

    if (dataX.length > 0) {       
      pr.canvas.pushStyle();      //save whatever was the previous style
      //pr.canvas.stroke(255, 0, 0);  //set the new line's color
      //pr.canvas.strokeWeight(1);  //set the new line's linewidth

      //draw all the individual segments
      for (int Ichan = 0; Ichan < dataY.length; Ichan++) {
        
        //if colorMode == 1 ...
        switch (Ichan % 8) {
        case 0:
          pr.canvas.stroke(129, 129, 129);  //set the new line's color;
          break;
        case 1:
          pr.canvas.stroke(124, 75, 141);  //set the new line's color;
          break;
        case 2:
          pr.canvas.stroke(54, 87, 158);  //set the new line's color;
          break;
        case 3:
          pr.canvas.stroke(49, 113, 89);  //set the new line's color;
          break;
        case 4:
          pr.canvas.stroke(221, 178, 13);  //set the new line's color;
          break;
        case 5:
          pr.canvas.stroke(253, 94, 52);  //set the new line's color;
          break;
        case 6:
          pr.canvas.stroke(224, 56, 45);  //set the new line's color;
          break;
        case 7:
          pr.canvas.stroke(162, 82, 49);  //set the new line's color;
          break;
        }

        //if colorMode == 2 ... for future dev work ... want to be able to edit colors of EEG montage traces

        // color _RGB = Color.HSBtoRGB(float((255/OpenBCI_Nchannels)*Ichan), 100.0f, 100.0f);
        // println("_RGB: " + _RGB);
        // pr.canvas.stroke(_RGB);

        // pr.canvas.stroke((int((255/OpenBCI_Nchannels)*Ichan)), 125-(int(((255/OpenBCI_Nchannels)*Ichan)/2)), 255-(int((255/OpenBCI_Nchannels)*Ichan)));
        // pr.canvas.stroke((int((255/nchan)*Ichan)), 125-(int(((255/nchan)*Ichan)/2)), 255-(int((255/nchan)*Ichan)));

        float new_x = pr.valToX(dataX[0]);  //first point, convert from data coordinates to pixel coordinates
        float new_y = pr.valToY(dataY[Ichan][0]*plotYScale+plotYOffset[Ichan]);  //first point, convert from data coordinates to pixel coordinate
        float prev_x, prev_y;
        for (int i=1; i < dataY[Ichan].length; i+= decimate_factor) {
          prev_x = new_x;
          prev_y = new_y;
          x_val = dataX[i];
          if ( (Float.isNaN(plotXlim[0])) || ((x_val >= plotXlim[0]) && (x_val <= plotXlim[1])) ) {
            new_x = pr.valToX(x_val);
            new_y = pr.valToY(dataY[Ichan][i]*plotYScale+plotYOffset[Ichan]);
            pr.canvas.line(prev_x, prev_y, new_x, new_y);
            //if (i==1)  println("ScatterTrace: first point: new_x, new_y = " + new_x + ", " + new_y);
          } else {
            //do nothing
          }
        }

        //add annotation for is_railed...doesn't work right
        //        if (is_railed != null) {
        //          if (Ichan < is_railed.length) {
        //            if (is_railed[Ichan]) {
        //              new_x = pr.valToX(-2.0);  //near time zero
        //              new_y = pr.valToY(0.0+plotYOffset[Ichan]);
        //              println("ScatterTrace: text: new_x, new_y = " + new_x + ", " + new_y);
        //              fill(50,50,50);
        //              textFont(font);
        //              textAlign(RIGHT, BOTTOM);
        //              pr.canvas.text("RAILED",new_x,new_y,100);
        //            }
        //          }
        //       }
      }
      pr.canvas.popStyle(); //restore whatever was the previous style
    }
  }

  public void setDecimateFactor(int val) {
    decimate_factor = max(1, val);
    //println("ScatterTrace: setDecimateFactor to " + decimate_factor);
  }
}


// /////////////////////////////////////////////////////////////////////////////////////////////
class ScatterTrace_FFT extends Blank2DTrace {
  private FFT[] fftData;
  private float plotYOffset[];
  private float[] plotXlim = new float[] {
    Float.NaN, Float.NaN
  };
  private float[] goodBand_Hz = {
    -1.0f, -1.0f
  };
  private float[] badBand_Hz = {
    -1.0f, -1.0f
  };
  private boolean showFFTFilteringData = false;
  private DetectionData_FreqDomain[] detectionData;
  private Oscil wave;

  public ScatterTrace_FFT() {
  }

  public ScatterTrace_FFT(FFT foo_fft[]) {
    setFFT_byRef(foo_fft);
    //    if (foo_fft.length != plotYOffset.length) {
    //      plotYOffset = new float[foo_fft.length];
    //    }
  }

  public void setFFT_byRef(FFT foo_fft[]) {
    fftData = foo_fft;//just copies the reference!
  }   

  public void setYOffset(float yoff[]) {
    plotYOffset = yoff;
  }
  public void set_plotXlim(float val_low, float val_high) {
    if (val_high < val_low) {
      float foo = val_low;
      val_low = val_high;
      val_high = foo;
    }
    plotXlim[0]=val_low;
    plotXlim[1]=val_high;
  }

  public void setGoodBand(float band_Hz[]) {
    for (int i=0; i<2; i++) { 
      goodBand_Hz[i]=band_Hz[i];
    };
  }
  public void setBadBand(float band_Hz[]) {
    for (int i=0; i<2; i++) { 
      badBand_Hz[i]=band_Hz[i];
    };
  }
  public void showFFTFilteringData(boolean show) {
    showFFTFilteringData = show;
  }
  public void setDetectionData_freqDomain(DetectionData_FreqDomain[] data) {
    detectionData = data.clone();
  }
  public void setAudioOscillator(Oscil wave_given) {
    wave = wave_given;
  }

  public void TraceDraw(Blank2DTrace.PlotRenderer pr) {
    float x_val, spec_value;

    //save whatever was the previous style
    pr.canvas.pushStyle();      

    //    //add FFT processing bands
    //    float[] fooBand_Hz;
    //    for (int i=0; i<2; i++) {
    //      if (i==0) {
    //        fooBand_Hz = goodBand_Hz;
    //        pr.canvas.stroke(100,255,100);
    //      } else {
    //        fooBand_Hz = badBand_Hz;
    //        pr.canvas.stroke(255,100,100);
    //      }
    //      pr.canvas.strokeWeight(13);
    //      float x1 = pr.valToX(fooBand_Hz[0]);
    //      float x2 = pr.valToX(fooBand_Hz[1]);
    //      if (!showFFTFilteringData) {
    //        x1 = -1.0f; x2=-1.0f; //draw offscreen when not active
    //      }
    //      float y1 = pr.valToY(0.13f);
    //      float y2 = pr.valToY(0.13f);
    //      pr.canvas.line(x1,y1,x2,y2);
    //    }

    if (fftData != null) {      
      pr.canvas.pushStyle();      //save whatever was the previous style

        //draw all the individual segments
      for (int Ichan=0; Ichan < fftData.length; Ichan++) {
        //if colorMode == 1 ...
        switch (Ichan % 8) {
        case 0:
          pr.canvas.stroke(129, 129, 129);  //set the new line's color;
          break;
        case 1:
          pr.canvas.stroke(124, 75, 141);  //set the new line's color;
          break;
        case 2:
          pr.canvas.stroke(54, 87, 158);  //set the new line's color;
          break;
        case 3:
          pr.canvas.stroke(49, 113, 89);  //set the new line's color;
          break;
        case 4:
          pr.canvas.stroke(221, 178, 13);  //set the new line's color;
          break;
        case 5:
          pr.canvas.stroke(253, 94, 52);  //set the new line's color;
          break;
        case 6:
          pr.canvas.stroke(224, 56, 45);  //set the new line's color;
          break;
        case 7:
          pr.canvas.stroke(162, 82, 49);  //set the new line's color;
          break;
        }

        // //if colorMode == 2...
        // // pr.canvas.stroke((int((255/OpenBCI_Nchannels)*Ichan)), 125-(int(((255/OpenBCI_Nchannels)*Ichan)/2)), 255-(int((255/OpenBCI_Nchannels)*Ichan)));
        // pr.canvas.stroke((int((255/nchan)*Ichan)), 125-(int(((255/nchan)*Ichan)/2)), 255-(int((255/nchan)*Ichan)));


        float new_x = pr.valToX(fftData[Ichan].indexToFreq(0));  //first point, convert from data coordinates to pixel coordinates
        float new_y = pr.valToY(fftData[Ichan].getBand(0)+plotYOffset[Ichan]);  //first point, convert from data coordinates to pixel coordinate
        float prev_x, prev_y;
        for (int i=1; i < fftData[Ichan].specSize (); i++) {
          prev_x = new_x;
          prev_y = new_y;
          x_val = fftData[Ichan].indexToFreq(i);
          //only plot those points that are within the frequency limits of the plot
          if ( (Float.isNaN(plotXlim[0])) || ((x_val >= plotXlim[0]) && (x_val <= plotXlim[1])) ) {
            new_x = pr.valToX(x_val);
            //spec_value = fftData[Ichan].getBand(i)/fftData[Ichan].specSize();  //uV_per_bin...this normalization is now done elsewhere
            spec_value = fftData[Ichan].getBand(i);
            new_y = pr.valToY(spec_value+plotYOffset[Ichan]);
            pr.canvas.line(prev_x, prev_y, new_x, new_y);
          } else {
            //do nothing
          } // end if Float.isNan
        }   //end of loop over spec size

          //        //add detection-related graphics
        //        if (showFFTFilteringData) {
        //          //add ellipse showing peak
        //          float new_x2 = pr.valToX(detectionData[Ichan].inband_freq_Hz);
        //          float new_y2 = pr.valToY(detectionData[Ichan].inband_uV);
        //          int diam = 8;
        //          pr.canvas.strokeWeight(1);  //set the new line's linewidth
        //          if (detectionData[Ichan].isDetected) { //if there is a detection, make more prominent
        //            diam = 8;
        //            pr.canvas.strokeWeight(4);  //set the new line's linewidth 
        //          }
        //          ellipseMode(CENTER);
        //          pr.canvas.ellipse(new_x2,new_y2,diam,diam);
        //          
        //          //add horizontal lines indicating the detction threshold and guard level (use a dashed line)
        //          for (int Iband=0;Iband<2;Iband++) {
        //            float x1, x2,y;
        //            if (Iband==1) {
        //              x1 = pr.valToX(badBand_Hz[0]);
        //              x2 = pr.valToX(badBand_Hz[1]);
        //              y = pr.valToY(detectionData[Ichan].guard_uV);
        //            } else {
        //              x1 = pr.valToX(goodBand_Hz[0]);
        //              x2 = pr.valToX(goodBand_Hz[1]);   
        //              y = pr.valToY(detectionData[Ichan].thresh_uV);
        //            }         
        //
        //            pr.canvas.strokeWeight(1.5);
        //            float dx = 8; //how big is the dash+space
        //            float nudge = 2;
        //            float foo_x=min(x1+dx,x2); //start here
        //            while (foo_x < x2) {
        //              pr.canvas.line(foo_x-dx+nudge,y,foo_x-(5*dx)/8+nudge,y);
        //              foo_x += dx;
        //            }
        //          }
        //        }
      } // end loop over channels

      //      //update the audio
      //      if (showFFTFilteringData & (wave != null)) {
      //        //find if any channels have detected, and which is the strongest SNR
      //        float maxExcessSNR = -100.0f;
      //        for (int Ichan=0; Ichan < detectionData.length; Ichan++) {  
      //          if (detectionData[Ichan].isDetected) {
      //            //how much above the threshold are we
      //            maxExcessSNR = max(maxExcessSNR,(detectionData[Ichan].inband_uV)/(detectionData[Ichan].thresh_uV));
      //          }
      //        }
      //        float audioFreq_Hz = calcDesiredAudioFrequency(maxExcessSNR);
      //        if (audioFreq_Hz > 0) {
      //          wave.amplitude.setLastValue(0.8);  //turn on 
      //          wave.frequency.setLastValue(audioFreq_Hz);  //set the desired frequency
      //          println("ScatterTrace: excessSNR = " + maxExcessSNR  + ", freq = " + audioFreq_Hz + " Hz");
      //        } else {
      //          //turn off
      //          wave.amplitude.setLastValue(0.0);
      //        }
      //      } else {
      //        //ensure that the audio is off
      //        wave.amplitude.setLastValue(0);  
      //      }    


      pr.canvas.popStyle(); //restore whatever was the previous style
    }
  }

  float calcDesiredAudioFrequency(float excessSNR) {
    //set some constants
    final float excessSNRRange[] = { 
      1.0f, 3.0f
    };  //not dB, just linear units
    final float freqRange_Hz[] = {
      200.0f, 600.0f
    };

    //compute the desired snr
    float outputFreq_Hz = -1.0f;
    if (excessSNR >= excessSNRRange[0]) {
      excessSNR = constrain(excessSNR, excessSNRRange[0], excessSNRRange[1]);
      outputFreq_Hz = map(excessSNR, excessSNRRange[0], excessSNRRange[1], freqRange_Hz[0], freqRange_Hz[1]);
    }
    return outputFreq_Hz;
  }
};