
//////////////////////////////////////////////////////////////
//
// This class creates and manages the head-shaped plot used by the GUI.
// The head includes circles representing the different EEG electrodes.
// The color (brightness) of the electrodes can be adjusted so that the
// electrodes' brightness values dynamically reflect the intensity of the
// EEG signal.  All EEG processing must happen outside of this class.
//
// Created: Chip Audette, Oct 2013
//
// Note: This routine uses aliasing to know which data should be used to
// set the brightness of the electrodes.
//
///////////////////////////////////////////////////////////////

class HeadPlot {
  private float rel_posX,rel_posY,rel_width,rel_height;
  private int circ_x,circ_y,circ_diam;
  private int earL_x, earL_y, earR_x, earR_y, ear_width, ear_height;
  private int[] nose_x, nose_y;
  private float[][] electrode_xy;
  private float[] ref_electrode_xy;
  private float[][][] electrode_color_weightFac;
  private int[][] electrode_rgb;
  private float[][] headVoltage;
  private int elec_diam;
  PFont font;
  public float[] intensity_data_uV;
  public float[] polarity_data;
  private DataStatus[] is_railed;
  private float intense_min_uV=0.0f, intense_max_uV=1.0f, assumed_railed_voltage_uV=1.0f;
  private float log10_intense_min_uV = 0.0f, log10_intense_max_uV=1.0;
  PImage headImage;
  private int image_x,image_y;
  public boolean drawHeadAsContours;
  private boolean plot_color_as_log = true;
  public float smooth_fac = 0.0f;  
  private boolean use_polarity = true;

  HeadPlot(float x,float y,float w,float h,int win_x,int win_y,int n) {
    final int n_elec = n;  //8 electrodes assumed....or 16 for 16-channel?  Change this!!!
    nose_x = new int[3];
    nose_y = new int[3];
    electrode_xy = new float[n_elec][2];   //x-y position of electrodes (pixels?) 
    //electrode_relDist = new float[n_elec][n_elec];  //relative distance between electrodes (pixels)
    ref_electrode_xy = new float[2];  //x-y position of reference electrode
    electrode_rgb = new int[3][n_elec];  //rgb color for each electrode
    font = createFont("Arial",16);
    drawHeadAsContours = true; //set this to be false for slower computers
    
    rel_posX = x;
    rel_posY = y;
    rel_width = w;
    rel_height = h;
    setWindowDimensions(win_x,win_y);
    
    setMaxIntensity_uV(200.0f);  //default intensity scaling for electrodes
  }
  
  public void setIntensityData_byRef(float[] data, DataStatus[] is_rail) {
    intensity_data_uV = data;  //simply alias the data held externally.  DOES NOT COPY THE DATA ITSEF!  IT'S SIMPLY LINKED!
    is_railed = is_rail;
  }
  
  public void setPolarityData_byRef(float[] data) {
    polarity_data = data;//simply alias the data held externally.  DOES NOT COPY THE DATA ITSEF!  IT'S SIMPLY LINKED!
    //if (polarity_data != null) use_polarity = true;
  }
  
  public String getUsePolarityTrueFalse() {
    if (use_polarity) {
      return "True";
    } else {
      return "False";
    }
  }
      
  public void setMaxIntensity_uV(float val_uV) {
    intense_max_uV = val_uV;
    intense_min_uV = intense_max_uV / 200.0 * 5.0f;  //set to 200, get 5
    assumed_railed_voltage_uV = intense_max_uV;
    
    log10_intense_max_uV = log10(intense_max_uV);
    log10_intense_min_uV = log10(intense_min_uV);
  }
  
  public void set_plotColorAsLog(boolean state) {
    plot_color_as_log = state;
  }
  
  //this method defines all locations of all the subcomponents
  public void setWindowDimensions(int win_width, int win_height){
    final int n_elec = electrode_xy.length;
    
    //define the head itself
    float nose_relLen = 0.075f;
    float nose_relWidth = 0.05f;
    float nose_relGutter = 0.02f;
    float ear_relLen = 0.15f;
    float ear_relWidth = 0.075;   
    
    float square_width = min(rel_width*(float)win_width,
                             rel_height*(float)win_height);  //choose smaller of the two
    
    float total_width = square_width;
    float total_height = square_width;
    float nose_width = total_width * nose_relWidth;
    float nose_height = total_height * nose_relLen;
    ear_width = (int)(ear_relWidth * total_width);
    ear_height = (int)(ear_relLen * total_height);
    int circ_width_foo = (int)(total_width - 2.f*((float)ear_width)/2.0f);
    int circ_height_foo = (int)(total_height - nose_height);
    circ_diam = min(circ_width_foo,circ_height_foo);
    //println("headPlot: circ_diam: " + circ_diam);

    //locations: circle center, measured from upper left
    circ_x = (int)((rel_posX+0.5f*rel_width)*(float)win_width);                  //center of head
    circ_y = (int)((rel_posY+0.5*rel_height)*(float)win_height + nose_height);  //center of head
    
    //locations: ear centers, measured from upper left
    earL_x = circ_x - circ_diam/2;
    earR_x = circ_x + circ_diam/2;
    earL_y = circ_y;
    earR_y = circ_y;
    
    //locations nose vertexes, measured from upper left
    nose_x[0] = circ_x - (int)((nose_relWidth/2.f)*(float)win_width);
    nose_x[1] = circ_x + (int)((nose_relWidth/2.f)*(float)win_width);
    nose_x[2] = circ_x;
    nose_y[0] = circ_y - (int)((float)circ_diam/2.0f - nose_relGutter*(float)win_height);
    nose_y[1] = nose_y[0];
    nose_y[2] = circ_y - (int)((float)circ_diam/2.0f + nose_height);


    //define the electrode positions as the relative position [-1.0 +1.0] within the head
    //remember that negative "Y" is up and positive "Y" is down
    float elec_relDiam = 0.12f; //was 0.1425 prior to 2014-03-23
    elec_diam = (int)(elec_relDiam*((float)circ_diam));
    setElectrodeLocations(n_elec,elec_relDiam);
    
    //define image to hold all of this
    image_x = int(round(circ_x - 0.5*circ_diam - 0.5*ear_width));
    image_y = nose_y[2];
    headImage = createImage(int(total_width),int(total_height),ARGB);
    
    //initialize the image
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        headImage.set(Ix,Iy,color(0,0,0,0));
      }
    }  
    
    //define the weighting factors to go from the electrode voltages
    //outward to the full the contour plot
    if (false) {
      //here is a simple distance-based algorithm that works every time, though
      //is not really physically accurate.  It looks decent enough
      computePixelWeightingFactors();
    } else {
      //here is the better solution that is more physical.  It involves an iterative
      //solution, which could be really slow or could fail.  If it does poorly,
      //switch to using the algorithm above.
      int n_wide_full = int(total_width); int n_tall_full = int(total_height);
      computePixelWeightingFactors_multiScale(n_wide_full,n_tall_full);
    }
  } //end of method
  
      
  private void setElectrodeLocations(int n_elec,float elec_relDiam) {
    //try loading the positions from a file
    int n_elec_to_load = n_elec+1;  //load the n_elec plus the reference electrode
    Table elec_relXY = new Table();
    String default_fname = "electrode_positions_default.txt";
    //String default_fname = "electrode_positions_12elec_scalp9.txt";
    try {
      elec_relXY = loadTable(default_fname,"header,csv"); //try loading the default file
    } catch (NullPointerException e) {};
    
    //get the default locations if the file didn't exist
    if ((elec_relXY == null) || (elec_relXY.getRowCount() < n_elec_to_load)) {
      println("headPlot: electrode position file not found or was wrong size: " + default_fname);
      println("        : using defaults...");
      elec_relXY = createDefaultElectrodeLocations(default_fname,elec_relDiam);
    }
    
    //define the actual locations of the electrodes in pixels
    for (int i=0; i < min(electrode_xy.length,elec_relXY.getRowCount()); i++) {
      electrode_xy[i][0] = circ_x+(int)(elec_relXY.getFloat(i,0)*((float)circ_diam));
      electrode_xy[i][1] = circ_y+(int)(elec_relXY.getFloat(i,1)*((float)circ_diam));
    }
    
    //the referenece electrode is last in the file
    ref_electrode_xy[0] = circ_x+(int)(elec_relXY.getFloat(elec_relXY.getRowCount()-1,0)*((float)circ_diam));
    ref_electrode_xy[1] = circ_y+(int)(elec_relXY.getFloat(elec_relXY.getRowCount()-1,1)*((float)circ_diam));
  }
  
  private Table createDefaultElectrodeLocations(String fname,float elec_relDiam) {
    
    //regular electrodes
    float[][] elec_relXY = new float[16][2]; 
    elec_relXY[0][0] = -0.125f;             elec_relXY[0][1] = -0.5f + elec_relDiam*(0.5f+0.2f); //FP1
    elec_relXY[1][0] = -elec_relXY[0][0];  elec_relXY[1][1] = elec_relXY[0][1]; //FP2
    
    elec_relXY[2][0] = -0.2f;            elec_relXY[2][1] = 0f; //C3
    elec_relXY[3][0] = -elec_relXY[2][0];  elec_relXY[3][1] = elec_relXY[2][1]; //C4
    
    elec_relXY[4][0] = -0.3425f;            elec_relXY[4][1] = 0.27f; //T5 (aka P7)
    elec_relXY[5][0] = -elec_relXY[4][0];  elec_relXY[5][1] = elec_relXY[4][1]; //T6 (aka P8)
    
    elec_relXY[6][0] = -0.125f;             elec_relXY[6][1] = +0.5f - elec_relDiam*(0.5f+0.2f); //O1
    elec_relXY[7][0] = -elec_relXY[6][0];  elec_relXY[7][1] = elec_relXY[6][1];  //O2

    elec_relXY[8][0] = elec_relXY[4][0];  elec_relXY[8][1] = -elec_relXY[4][1]; //F7
    elec_relXY[9][0] = -elec_relXY[8][0];  elec_relXY[9][1] = elec_relXY[8][1]; //F8
    
    elec_relXY[10][0] = -0.18f;            elec_relXY[10][1] = -0.15f; //C3
    elec_relXY[11][0] = -elec_relXY[10][0];  elec_relXY[11][1] = elec_relXY[10][1]; //C4    
    
    elec_relXY[12][0] =  -0.5f +elec_relDiam*(0.5f+0.15f);  elec_relXY[12][1] = 0f; //T3 (aka T7?)
    elec_relXY[13][0] = -elec_relXY[12][0];  elec_relXY[13][1] = elec_relXY[12][1]; //T4 (aka T8)    
    
    elec_relXY[14][0] = elec_relXY[10][0];   elec_relXY[14][1] = -elec_relXY[10][1]; //CP3
    elec_relXY[15][0] = -elec_relXY[14][0];  elec_relXY[15][1] = elec_relXY[14][1]; //CP4    
      
    //reference electrode
    float[] ref_elec_relXY = new float[2];
    ref_elec_relXY[0] = 0.0f;    ref_elec_relXY[1] = 0.0f;   
    
    //put it all into a table
    Table table_elec_relXY = new Table();
    table_elec_relXY.addColumn("X",Table.FLOAT);  
    table_elec_relXY.addColumn("Y",Table.FLOAT);
    for (int I = 0; I < elec_relXY.length; I++) {
      table_elec_relXY.addRow();
      table_elec_relXY.setFloat(I,"X",elec_relXY[I][0]);
      table_elec_relXY.setFloat(I,"Y",elec_relXY[I][1]);
    }
    
    //last one is the reference electrode
    table_elec_relXY.addRow();
    table_elec_relXY.setFloat(table_elec_relXY.getRowCount()-1,"X",ref_elec_relXY[0]);
    table_elec_relXY.setFloat(table_elec_relXY.getRowCount()-1,"Y",ref_elec_relXY[1]);
    
    //try writing it to a file
    String full_fname = "Data\\" + fname;
    try { 
      saveTable(table_elec_relXY,full_fname,"csv"); 
    } catch (NullPointerException e) {
      println("headPlot: createDefaultElectrodeLocations: could not write file to " + full_fname);
    };
    
    //return
    return table_elec_relXY;
  } //end of method
  
  //Here, we do a two-step solution to get the weighting factors.  
  //We do a coarse grid first.  We do our iterative solution on the coarse grid.
  //Then, we formulate the full resolution fine grid.  We interpolate these points
  //from the data resulting from the coarse grid.
  private void computePixelWeightingFactors_multiScale(int n_wide_full, int n_tall_full) {
    int n_elec = electrode_xy.length;
    
    //define the coarse grid data structures and pixel locations
    int decimation = 10;
    int n_wide_small = n_wide_full / decimation + 1;  int n_tall_small = n_tall_full / decimation + 1;
    float weightFac[][][] = new float[n_elec][n_wide_small][n_tall_small];
    int pixelAddress[][][] = new int[n_wide_small][n_tall_small][2];
    for (int Ix=0;Ix<n_wide_small;Ix++) { for(int Iy=0;Iy<n_tall_small;Iy++) { pixelAddress[Ix][Iy][0] = Ix*decimation; pixelAddress[Ix][Iy][1] = Iy*decimation;};};
    
    //compute the weighting factors of the coarse grid
    computePixelWeightingFactors_trueAverage(pixelAddress,weightFac);
    
    //define the fine grid data structures
    electrode_color_weightFac = new float[n_elec][n_wide_full][n_tall_full];
    headVoltage = new float[n_wide_full][n_tall_full];
    
    //interpolate to get the fine grid from the coarse grid
    float dx_frac, dy_frac;
    for (int Ix=0;Ix<n_wide_full;Ix++) {
      int Ix_source = Ix/decimation;
      dx_frac = float(Ix - Ix_source*decimation)/float(decimation);
      for (int Iy=0; Iy < n_tall_full; Iy++) {
        int Iy_source = Iy/decimation;
        dy_frac = float(Iy - Iy_source*decimation)/float(decimation);           
        
        for (int Ielec=0; Ielec<n_elec;Ielec++) {
          //println("    : Ielec = " + Ielec);
          if ((Ix_source < (n_wide_small-1)) && (Iy_source < (n_tall_small-1))) {
            //normal 2-D interpolation    
            electrode_color_weightFac[Ielec][Ix][Iy] = interpolate2D(weightFac[Ielec],Ix_source,Iy_source,Ix_source+1,Iy_source+1,dx_frac,dy_frac);
          } else if (Ix_source < (n_wide_small-1)) {
            //1-D interpolation in X
            dy_frac = 0.0f;
            electrode_color_weightFac[Ielec][Ix][Iy] = interpolate2D(weightFac[Ielec],Ix_source,Iy_source,Ix_source+1,Iy_source,dx_frac,dy_frac);
          } else if (Iy_source < (n_tall_small-1)) {
            //1-D interpolation in Y
            dx_frac = 0.0f;
            electrode_color_weightFac[Ielec][Ix][Iy] = interpolate2D(weightFac[Ielec],Ix_source,Iy_source,Ix_source,Iy_source+1,dx_frac,dy_frac);
          } else { 
            //no interpolation, just use the last value
            electrode_color_weightFac[Ielec][Ix][Iy] = weightFac[Ielec][Ix_source][Iy_source];
          }  //close the if block selecting the interpolation configuration
        } //close Ielec loop
      } //close Iy loop
    } // close Ix loop
    
    //clean up the boundaries of our interpolated results to make the look nicer
    int pixelAddress_full[][][] = new int[n_wide_full][n_tall_full][2];
    for (int Ix=0;Ix<n_wide_full;Ix++) { for(int Iy=0;Iy<n_tall_full;Iy++) { pixelAddress_full[Ix][Iy][0] = Ix; pixelAddress_full[Ix][Iy][1] = Iy; };};
    cleanUpTheBoundaries(pixelAddress_full,electrode_color_weightFac);
  } //end of method
  
  
  private float interpolate2D(float[][] weightFac,int Ix1,int Iy1,int Ix2,int Iy2,float dx_frac,float dy_frac) {
    if (Ix1 >= weightFac.length) {
      println("headPlot: interpolate2D: Ix1 = " + Ix1 + ", weightFac.length = " + weightFac.length);
    }
    float foo1 = (weightFac[Ix2][Iy1] - weightFac[Ix1][Iy1])*dx_frac + weightFac[Ix1][Iy1];
    float foo2 = (weightFac[Ix2][Iy2] - weightFac[Ix1][Iy2])*dx_frac + weightFac[Ix1][Iy2];
    return (foo2 - foo1) * dy_frac + foo1;
  }
  
  
  //here is the simpler and more robust algorithm.  It's not necessarily physically real, though.
  //but, it will work every time.  So, if the other method fails, go with this one.
  private void computePixelWeightingFactors() { 
    int n_elec = electrode_xy.length;
    float dist;
    int withinElecInd = -1;
    float elec_radius = 0.5f*elec_diam;
    int pixel_x, pixel_y;
    float sum_weight_fac = 0.0f;
    float weight_fac[] = new float[n_elec];
    float foo_dist;
    
    //loop over each pixel
    for (int Iy=0; Iy < headImage.height; Iy++) {
      pixel_y = image_y + Iy;
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        pixel_x = image_x + Ix;
                
        if (isPixelInsideHead(pixel_x,pixel_y)==false) {
          for (int Ielec=0; Ielec < n_elec; Ielec++) {
            //outside of head...no color from electrodes
            electrode_color_weightFac[Ielec][Ix][Iy]= -1.0f; //a negative value will be a flag that it is outside of the head
          }
        } else {
          //inside of head, compute weighting factors

          //compute distances of this pixel to each electrode
          sum_weight_fac = 0.0f; //reset for this pixel
          withinElecInd = -1;    //reset for this pixel
          for (int Ielec=0; Ielec < n_elec; Ielec++) {
            //compute distance
            dist = max(1.0,calcDistance(pixel_x,pixel_y,electrode_xy[Ielec][0],electrode_xy[Ielec][1]));
            if (dist < elec_radius) withinElecInd = Ielec;
            
            //compute the first part of the weighting factor
            foo_dist = max(1.0,abs(dist - elec_radius));  //remove radius of the electrode
            weight_fac[Ielec] = 1.0f/foo_dist;  //arbitrarily chosen
            weight_fac[Ielec] = weight_fac[Ielec]*weight_fac[Ielec]*weight_fac[Ielec];  //again, arbitrary
            sum_weight_fac += weight_fac[Ielec];
          }
          
          //finalize the weight factor
          for (int Ielec=0; Ielec < n_elec; Ielec++) {
             //is this pixel within an electrode? 
            if (withinElecInd > -1) {
              //yes, it is within an electrode
              if (Ielec == withinElecInd) {
                //use this signal electrode as the color
                electrode_color_weightFac[Ielec][Ix][Iy] = 1.0f;
              } else {
                //ignore all other electrodes
                electrode_color_weightFac[Ielec][Ix][Iy] = 0.0f;
              }
            } else {
              //no, this pixel is not in an electrode.  So, use the distance-based weight factor, 
              //after dividing by the sum of the weight factors, resulting in an averaging operation
              electrode_color_weightFac[Ielec][Ix][Iy] = weight_fac[Ielec]/sum_weight_fac;
            }
          }
        }
      }
    }
  } //end of method
  
  void computePixelWeightingFactors_trueAverage(int pixelAddress[][][],float weightFac[][][]) {
    int n_wide = pixelAddress.length;
    int n_tall = pixelAddress[0].length;
    int n_elec = electrode_xy.length;
    int withinElectrode[][] = new int[n_wide][n_tall]; //which electrode is this pixel within (-1 means that it is not within any electrode)
    boolean withinHead[][] = new boolean[n_wide][n_tall]; //is the pixel within the head?
    int toPixels[][][][] = new int[n_wide][n_tall][4][2];
    int toElectrodes[][][] = new int[n_wide][n_tall][4];
    //int numConnections[][] = new int[n_wide][n_tall];
        
    //find which pixesl are within the head and which pixels are within an electrode
    whereAreThePixels(pixelAddress,withinHead,withinElectrode);
       
    //loop over the pixels and make all the connections
    makeAllTheConnections(withinHead,withinElectrode,toPixels,toElectrodes);
    
    //compute the pixel values when lighting up each electrode invididually
    for (int Ielec=0;Ielec<n_elec;Ielec++) {
      computeWeightFactorsGivenOneElectrode_iterative(toPixels,toElectrodes,Ielec,weightFac);
    }    
  }
  
  private void cleanUpTheBoundaries(int pixelAddress[][][],float weightFac[][][]) {
    int n_wide = pixelAddress.length;
    int n_tall = pixelAddress[0].length;
    int n_elec = electrode_xy.length;
    int withinElectrode[][] = new int[n_wide][n_tall]; //which electrode is this pixel within (-1 means that it is not within any electrode)
    boolean withinHead[][] = new boolean[n_wide][n_tall]; //is the pixel within the head?
       
    //find which pixesl are within the head and which pixels are within an electrode
    whereAreThePixels(pixelAddress,withinHead,withinElectrode);
    
    //loop over the pixels and change the weightFac to reflext where it is
    for (int Ix=0;Ix<n_wide;Ix++) {
      for (int Iy=0;Iy<n_tall;Iy++) {
        if (withinHead[Ix][Iy]==false) {
            //this pixel is outside of the head
            for (int Ielec=0;Ielec<n_elec;Ielec++){
              weightFac[Ielec][Ix][Iy]=-1.0;  //this means to ignore this weight
            }
        } else {
          //we are within the head...there are a couple of things to clean up
         
          //first, is this a legit value?  It should be >= 0.0.  If it isn't, it was a
          //quantization problem.  let's clean it up.
          for (int Ielec=0;Ielec<n_elec;Ielec++) {
            if (weightFac[Ielec][Ix][Iy] < 0.0) {
              weightFac[Ielec][Ix][Iy] = getClosestWeightFac(weightFac[Ielec],Ix,Iy);
            }
          }
          
          //next, is our pixel within an electrode.  If so, ensure it's weights
          //set the value to be the same as the electrode
          if (withinElectrode[Ix][Iy] > -1) {
            //we are!  set the weightFac to reflect this electrode only
            for (int Ielec=0;Ielec<n_elec;Ielec++){
              weightFac[Ielec][Ix][Iy] = 0.0f; //ignore all other electrodes
              if (Ielec == withinElectrode[Ix][Iy]) {
                 weightFac[Ielec][Ix][Iy] = 1.0f;  //become equal to this electrode
              }
            }
          } //close "if within electrode"
        } //close "if within head"
      } //close Iy
    } // close Ix
  } //close method
             
  //find the closest legitimate weightFac          
  private float getClosestWeightFac(float weightFac[][],int Ix,int Iy) {
    int n_wide = weightFac.length;
    int n_tall = weightFac[0].length;
    float sum = 0.0f;
    int n_sum = 0;
    float new_weightFac=-1.0;
    
    
    int step = 1;
    int Ix_test, Iy_test;
    boolean done = false;
    boolean anyWithinBounds;
    while (!done) {
      anyWithinBounds = false;
      
      //search the perimeter at this distance
      sum = 0.0f;
      n_sum = 0;
      
      //along the top
      Iy_test = Iy + step;
      if ((Iy_test >= 0) && (Iy_test < n_tall)) {
        for (Ix_test=Ix-step;Ix_test<=Ix+step;Ix_test++) {
          if ((Ix_test >=0) && (Ix_test < n_wide)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
      
      //along the right
      Ix_test = Ix + step;
      if ((Ix_test >= 0) && (Ix_test < n_wide)) {
        for (Iy_test=Iy-step;Iy_test<=Iy+step;Iy_test++) {
          if ((Iy_test >=0) && (Iy_test < n_tall)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
       //along the bottom
      Iy_test = Iy - step;
      if ((Iy_test >= 0) && (Iy_test < n_tall)) {
        for (Ix_test=Ix-step;Ix_test<=Ix+step;Ix_test++) {
          if ((Ix_test >=0) && (Ix_test < n_wide)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
      
      //along the left
      Ix_test = Ix - step;
      if ((Ix_test >= 0) && (Ix_test < n_wide)) {
        for (Iy_test=Iy-step;Iy_test<=Iy+step;Iy_test++) {
          if ((Iy_test >=0) && (Iy_test < n_tall)) {
            anyWithinBounds=true;
            if (weightFac[Ix_test][Iy_test] >= 0.0) {
              sum += weightFac[Ix_test][Iy_test];
              n_sum++;
            }
          }
        }
      }
  
      if (n_sum > 0) {
        //some good pixels were found, so we have our answer
        new_weightFac = sum / n_sum; //complete the averaging process
        done = true; //we're done
      } else {
        //we did not find any good pixels.  Step outward one more pixel and repeat the search
        step++;  //step outwward
        if (anyWithinBounds) {  //did the last iteration have some pixels that were at least within the domain
          //some pixels were within the domain, so we have space to try again
          done = false;
        } else {
          //no pixels were within the domain.  We're out of space.  We're done.
          done = true;
        }
      }
    }
    return new_weightFac; //good or bad, return our new value
  }

  private void computeWeightFactorsGivenOneElectrode_iterative(int toPixels[][][][],int toElectrodes[][][],int Ielec,float pixelVal[][][]) {
    //Approach: pretend that one electrode is set to 1.0 and that all other electrodes are set to 0.0.
    //Assume all of the pixels start at zero.  Then, begin the simulation as if it were a transient
    //solution where energy is coming in from the connections.  Any excess energy will accumulate
    //and cause the local pixel's value to increase.  Iterate until the pixel values stabalize.
    
    int n_wide = toPixels.length;
    int n_tall = toPixels[0].length;
    int n_dir = toPixels[0][0].length;
    float prevVal[][] = new float[n_wide][n_tall];
    float total,dVal;
    int Ix_targ, Iy_targ;
    float min_val=0.0f, max_val=0.0f;
    boolean anyConnections = false;
    int pixel_step = 1;

    //initialize all pixels to zero
    //for (int Ix=0; Ix<n_wide;Ix++) { for (int Iy=0; Iy<n_tall;Iy++) { pixelVal[Ielec][Ix][Iy]=0.0f; }; };

    //define the iteration limits
    int lim_iter_count = 2000;  //set to something big enough to get the job done, but not so big that it could take forever
    float dVal_threshold = 0.00001;  //set to something arbitrarily small
    float change_fac = 0.2f; //must be small enough to keep this iterative solution stable.  Goes unstable above 0.25
    
    //begin iteration
    int iter_count = 0;
    float max_dVal = 10.0*dVal_threshold;  //initilize to large value to ensure that it starts
    while ((iter_count < lim_iter_count) && (max_dVal > dVal_threshold)) {
      //increment the counter
      iter_count++;
      
      //reset our test value to a large value
      max_dVal = 0.0f;
      
      //reset other values that I'm using for debugging
      min_val = 1000.0f; //init to a big val
      max_val = -1000.f; //init to a small val
      
      //copy current values
      for (int Ix=0; Ix<n_wide;Ix++) { for (int Iy=0; Iy<n_tall;Iy++) { prevVal[Ix][Iy]=pixelVal[Ielec][Ix][Iy]; }; };
      
      //compute the new pixel values
      for (int Ix=0; Ix<n_wide;Ix+=pixel_step) {
        for (int Iy=0; Iy<n_tall;Iy+=pixel_step) {
          //reset variables related to this one pixel
          total=0.0f;
          anyConnections = false;
              
          for (int Idir=0; Idir<n_dir; Idir++) {
            //do we connect to a real pixel?
            if (toPixels[Ix][Iy][Idir][0] > -1) {
              Ix_targ = toPixels[Ix][Iy][Idir][0];  //x index of target pixel
              Iy_targ = toPixels[Ix][Iy][Idir][1];  //y index of target pixel
              total += (prevVal[Ix_targ][Iy_targ]-prevVal[Ix][Iy]);  //difference relative to target pixel
              anyConnections = true;
            }
            //do we connect to an electrode?
            if (toElectrodes[Ix][Iy][Idir] > -1) {
              //do we connect to the electrode that we're stimulating
              if (toElectrodes[Ix][Iy][Idir] == Ielec) {
                //yes, this is the active high one
                total += (1.0-prevVal[Ix][Iy]);  //difference relative to HIGH electrode
              } else {
                //no, this is a low one
                total += (0.0-prevVal[Ix][Iy]);  //difference relative to the LOW electrode
              }
              anyConnections = true;
            }
          }
         
          //compute the new pixel value
          //if (numConnections[Ix][Iy] > 0) {
          if (anyConnections) {
            
            //dVal = change_fac * (total - float(numConnections[Ix][Iy])*prevVal[Ix][Iy]);
            dVal = change_fac * total;
            pixelVal[Ielec][Ix][Iy] = prevVal[Ix][Iy] + dVal;
                        
            //is this our worst change in value?
            max_dVal = max(max_dVal,abs(dVal));
            
            //update our other debugging values, too
            min_val = min(min_val,pixelVal[Ielec][Ix][Iy]);
            max_val = max(max_val,pixelVal[Ielec][Ix][Iy]);
            
          } else {
            pixelVal[Ielec][Ix][Iy] = -1.0; //means that there are no connections
          }
        }
      }
      //println("headPlot: computeWeightFactor: Ielec " + Ielec + ", iter = " + iter_count + ", max_dVal = " + max_dVal);
    }
    //println("headPlot: computeWeightFactor: Ielec " + Ielec + ", solution complete with " + iter_count + " iterations. min and max vals = " + min_val + ", " + max_val);
    if (iter_count >= lim_iter_count) println("headPlot: computeWeightFactor: Ielec " + Ielec + ", solution complete with " + iter_count + " iterations. max_dVal = " + max_dVal);
  } //end of method
    
    
    
//  private void countConnections(int toPixels[][][][],int toElectrodes[][][], int numConnections[][]) {
//    int n_wide = toPixels.length;
//    int n_tall = toPixels[0].length;
//    int n_dir = toPixels[0][0].length;
//    
//    //loop over each pixel
//    for (int Ix=0; Ix<n_wide;Ix++) { 
//      for (int Iy=0; Iy<n_tall;Iy++) {
//        
//        //initialize
//        numConnections[Ix][Iy]=0;
//        
//        //loop through the four directions
//        for (int Idir=0;Idir<n_dir;Idir++) {
//          //is it a connection to another pixel (anything > -1 is a connection)
//          if (toPixels[Ix][Iy][Idir][0] > -1) numConnections[Ix][Iy]++;
//          
//          //is it a connection to an electrode?
//          if (toElectrodes[Ix][Iy][Idir] > -1) numConnections[Ix][Iy]++;
//        }
//      }
//    }
//  }
    
  private void makeAllTheConnections(boolean withinHead[][],int withinElectrode[][], int toPixels[][][][],int toElectrodes[][][]) {
   
    int n_wide = toPixels.length;
    int n_tall = toPixels[0].length;
    int n_elec = electrode_xy.length;
    int curPixel, Ipix, Ielec;
    int n_pixels = n_wide * n_tall;
    int Ix_try, Iy_try;

    
    //loop over every pixel in the image
    for (int Iy=0; Iy < n_tall; Iy++) {
      for (int Ix=0; Ix < n_wide; Ix++) {
        
        //loop over the four connections: left, right, up, down
        for (int Idirection = 0; Idirection < 4; Idirection++) {
          
          Ix_try = -1; Iy_try=-1; //nonsense values
          switch (Idirection) {
              case 0:
                Ix_try = Ix-1; Iy_try = Iy; //left
                break;
              case 1:
                Ix_try = Ix+1; Iy_try = Iy; //right
                break;
              case 2:
                Ix_try = Ix; Iy_try = Iy-1; //up
                break;
              case 3:
                Ix_try = Ix; Iy_try = Iy+1; //down
                break;
           }
          
          //initalize to no connection
          toPixels[Ix][Iy][Idirection][0] = -1;
          toPixels[Ix][Iy][Idirection][1] = -1;
          toElectrodes[Ix][Iy][Idirection] = -1;
          
          //does the target pixel exist
          if ((Ix_try >= 0) && (Ix_try < n_wide)  && (Iy_try >= 0) && (Iy_try < n_tall)) {
            //is the target pixel an electrode
            if (withinElectrode[Ix_try][Iy_try] >= 0) {
              //the target pixel is within an electrode
              toElectrodes[Ix][Iy][Idirection] = withinElectrode[Ix_try][Iy_try];
            } else {
              //the target pixel is not within an electrode.  is it within the head?
              if (withinHead[Ix_try][Iy_try]) {
                toPixels[Ix][Iy][Idirection][0] = Ix_try; //save the address of the target pixel
                toPixels[Ix][Iy][Idirection][1] = Iy_try; //save the address of the target pixel
              }
            }
          }
        } //end loop over direction of the target pixel
      } //end loop over Ix
    } //end loop over Iy 
  } // end of method
  
  private void whereAreThePixels(int pixelAddress[][][], boolean[][] withinHead,int[][] withinElectrode) {
    int n_wide = pixelAddress.length;
    int n_tall = pixelAddress[0].length;
    int n_elec = electrode_xy.length;
    int pixel_x,pixel_y;
    int withinElecInd=-1;
    float dist;
    float elec_radius = 0.5*elec_diam;
    
    for (int Iy=0; Iy < n_tall; Iy++) {
      //pixel_y = image_y + Iy;
      for (int Ix = 0; Ix < n_wide; Ix++) {
        //pixel_x = image_x + Ix;
        
        pixel_x = pixelAddress[Ix][Iy][0]+image_x;
        pixel_y = pixelAddress[Ix][Iy][1]+image_y;
        
        //is it within the head
        withinHead[Ix][Iy] = isPixelInsideHead(pixel_x,pixel_y);
        
        //compute distances of this pixel to each electrode
        withinElecInd = -1;    //reset for this pixel
        for (int Ielec=0; Ielec < n_elec; Ielec++) {
          //compute distance
          dist = max(1.0,calcDistance(pixel_x,pixel_y,electrode_xy[Ielec][0],electrode_xy[Ielec][1]));
          if (dist < elec_radius) withinElecInd = Ielec;
        }
        withinElectrode[Ix][Iy] = withinElecInd;  //-1 means not inside an electrode 
      } //close Ix loop
    } //close Iy loop
    
    //ensure that each electrode is at at least one pixel
    for (int Ielec=0; Ielec<n_elec; Ielec++) {
      //find closest pixel
      float min_dist = 1.0e10;  //some huge number
      int best_Ix=0, best_Iy=0; 
      for (int Iy=0; Iy < n_tall; Iy++) {
        //pixel_y = image_y + Iy;
        for (int Ix = 0; Ix < n_wide; Ix++) {
          //pixel_x = image_x + Ix;
        
          pixel_x = pixelAddress[Ix][Iy][0]+image_x;
          pixel_y = pixelAddress[Ix][Iy][1]+image_y;
          
          dist = calcDistance(pixel_x,pixel_y,electrode_xy[Ielec][0],electrode_xy[Ielec][1]);;
          
          if (dist < min_dist) {
            min_dist = dist;
            best_Ix = Ix;
            best_Iy = Iy;
          }
        } //close Iy loop
      } //close Ix loop
      
      //define this closest point to be within the electrode
      withinElectrode[best_Ix][best_Iy] = Ielec;
    } //close Ielec loop
  } //close method


  //step through pixel-by-pixel to update the image
  private void updateHeadImage() {
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        //is this pixel inside the head?
        if (electrode_color_weightFac[0][Ix][Iy] >= 0.0) { //zero and positive values are inside the head
          //it is inside the head.  set the color based on the electrodes
          headImage.set(Ix,Iy,calcPixelColor(Ix,Iy));
        } else {  //negative values are outside of the head
          //pixel is outside the head.  set to black.
          headImage.set(Ix,Iy,color(0,0,0,0));
        }
      }
    }
  }
  
  private void convertVoltagesToHeadImage() { 
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        //is this pixel inside the head?
        if (electrode_color_weightFac[0][Ix][Iy] >= 0.0) { //zero and positive values are inside the head
          //it is inside the head.  set the color based on the electrodes
          headImage.set(Ix,Iy,calcPixelColor(headVoltage[Ix][Iy]));
        } else {  //negative values are outside of the head
          //pixel is outside the head.  set to black.
          headImage.set(Ix,Iy,color(0,0,0,0));
        }
      }
    }
  }
  

  private void updateHeadVoltages() {
    for (int Iy=0; Iy < headImage.height; Iy++) {
      for (int Ix = 0; Ix < headImage.width; Ix++) {
        //is this pixel inside the head?
        if (electrode_color_weightFac[0][Ix][Iy] >= 0.0) { //zero and positive values are inside the head
          //it is inside the head.  set the voltage based on the electrodes
          headVoltage[Ix][Iy] = calcPixelVoltage(Ix,Iy,headVoltage[Ix][Iy]);

        } else {  //negative values are outside of the head
          //pixel is outside the head.
          headVoltage[Ix][Iy] = -1.0;
        }
      }
    }
  }    

  int count_call=0;
  private float calcPixelVoltage(int pixel_Ix,int pixel_Iy,float prev_val) {
    float weight,elec_volt;
    int n_elec = electrode_xy.length;
    float voltage = 0.0f;
    float low = intense_min_uV;
    float high = intense_max_uV;
    
    for (int Ielec=0;Ielec<n_elec;Ielec++) {
      weight = electrode_color_weightFac[Ielec][pixel_Ix][pixel_Iy];
      elec_volt = max(low,min(intensity_data_uV[Ielec],high));
      
      if (use_polarity) elec_volt = elec_volt*polarity_data[Ielec];
      
      if (is_railed[Ielec].is_railed) elec_volt = assumed_railed_voltage_uV;
      voltage += weight*elec_volt;
    }
    
    //smooth in time
    if (smooth_fac > 0.0f) voltage = smooth_fac*prev_val + (1.0-smooth_fac)*voltage;     
    
    return voltage;
  }
      
    
  private color calcPixelColor(float pixel_volt_uV) {
    float new_rgb[] = {255.0,0.0,0.0}; //init to red
    if (pixel_volt_uV < 0.0) {
      //init to blue instead
      new_rgb[0]=0.0;new_rgb[1]=0.0;new_rgb[2]=255.0;
    }
    float val;
    
    
    float intensity = constrain(abs(pixel_volt_uV),intense_min_uV,intense_max_uV);
    if (plot_color_as_log) {
      intensity = map(log10(intensity), 
                      log10_intense_min_uV,
                      log10_intense_max_uV,
                      0.0f,1.0f);
    } else {
      intensity = map(intensity, 
                intense_min_uV,
                intense_max_uV,
                0.0f,1.0f);
    }
      
    //make the intensity fade NOT from black->color, but from white->color
    for (int i=0; i < 3; i++) {
      val = ((float)new_rgb[i]) / 255.f;
      new_rgb[i] = ((val + (1.0f - val)*(1.0f-intensity))*255.f); //adds in white at low intensity.  no white at high intensity
      new_rgb[i] = constrain(new_rgb[i],0.0,255.0);
    }
    
    //quantize the color to make contour-style plot?
    if (true) quantizeColor(new_rgb);

    return color(int(new_rgb[0]),int(new_rgb[1]),int(new_rgb[2]),255);   
  }
  
  private void quantizeColor(float new_rgb[]) {
    int n_colors = 12;
    int ticks_per_color = 256 / (n_colors+1);
    for (int Irgb=0; Irgb<3; Irgb++) new_rgb[Irgb] = min(255.0,float(int(new_rgb[Irgb]/ticks_per_color))*ticks_per_color);
  }
  

  //compute the color of the pixel given the location
  private color calcPixelColor(int pixel_Ix,int pixel_Iy) {
    float weight;
    
    //compute the weighted average using the precomputed factors
    float new_rgb[] = {0.0,0.0,0.0}; //init to zeros
    for (int Ielec=0; Ielec < electrode_xy.length; Ielec++) {
      //int Ielec = 0;
      weight = electrode_color_weightFac[Ielec][pixel_Ix][pixel_Iy];
      for (int Irgb=0; Irgb<3; Irgb++) {
        new_rgb[Irgb] += weight*electrode_rgb[Irgb][Ielec];
      }
    }
    
    //quantize the color to make contour-style plot?
    if (true) quantizeColor(new_rgb);
       
    return color(int(new_rgb[0]),int(new_rgb[1]),int(new_rgb[2]),255);
  }
  
  private float calcDistance(int x,int y,float ref_x,float ref_y) {
    float dx = float(x) - ref_x;
    float dy = float(y) - ref_y;
    return sqrt(dx*dx + dy*dy);
  }
  
  //compute color for the electrode value
  private void updateElectrodeColors() {
    int rgb[] = new int[]{255,0,0}; //color for the electrode when fully light
    float intensity;
    float val;
    int new_rgb[] = new int[3];
    float low = intense_min_uV;
    float high = intense_max_uV;
    float log_low = log10_intense_min_uV;
    float log_high = log10_intense_max_uV;
    for (int Ielec=0; Ielec < electrode_xy.length; Ielec++) {
      intensity = constrain(intensity_data_uV[Ielec],low,high);
      if (plot_color_as_log) {
        intensity = map(log10(intensity),log_low,log_high,0.0f,1.0f);
      } else {
        intensity = map(intensity,low,high,0.0f,1.0f);
      }
      
      //make the intensity fade NOT from black->color, but from white->color
      for (int i=0; i < 3; i++) {
        val = ((float)rgb[i]) / 255.f;
        new_rgb[i] = (int)((val + (1.0f - val)*(1.0f-intensity))*255.f); //adds in white at low intensity.  no white at high intensity
        new_rgb[i] = constrain(new_rgb[i],0,255);
      }
      
      //change color to dark RED if railed
      if (is_railed[Ielec].is_railed)  new_rgb = new int[]{127,0,0};
      
      //set the electrode color
      electrode_rgb[0][Ielec] = new_rgb[0];
      electrode_rgb[1][Ielec] = new_rgb[1];
      electrode_rgb[2][Ielec] = new_rgb[2];
    }
  }
 
  
  public boolean isPixelInsideHead(int pixel_x, int pixel_y) {
    int dx = pixel_x - circ_x;
    int dy = pixel_y - circ_y;
    float r = sqrt(float(dx*dx) + float(dy*dy));
    if (r <= 0.5*circ_diam) {
      return true;
    } else {
      return false;
    }    
  }
  
  public void update() {
    //do this when new data is available
    
    //update electrode colors
    updateElectrodeColors();
    
    if (false) {
      //update the head image
      if (drawHeadAsContours) updateHeadImage();
    } else {
      //update head voltages
      updateHeadVoltages();
      convertVoltagesToHeadImage();
    }
  }
  
  public void draw() {

    //draw head parts
    fill(255,255,255);
    stroke(63,63,63);
    triangle(nose_x[0], nose_y[0],nose_x[1], nose_y[1],nose_x[2], nose_y[2]);  //nose
    ellipse(earL_x, earL_y, ear_width, ear_height); //little circle for the ear
    ellipse(earR_x, earR_y, ear_width, ear_height); //little circle for the ear
    
    //draw head itself   
   fill(255,255,255,255);  //fill in a white head 
   strokeWeight(2);
   ellipse(circ_x, circ_y, circ_diam, circ_diam); //big circle for the head
    if (drawHeadAsContours) {
      //add the contnours
      image(headImage,image_x,image_y);
      noFill(); //overlay a circle as an outline, but no fill
      strokeWeight(2);
      ellipse(circ_x, circ_y, circ_diam, circ_diam); //big circle for the head
    }
  
    //draw electrodes on the head
    strokeWeight(1);
    for (int Ielec=0; Ielec < electrode_xy.length; Ielec++) {
      if (drawHeadAsContours) {
        noFill(); //make transparent to allow color to come through from below   
      } else {
        fill(electrode_rgb[0][Ielec],electrode_rgb[1][Ielec],electrode_rgb[2][Ielec]);
      }
      ellipse(electrode_xy[Ielec][0], electrode_xy[Ielec][1], elec_diam, elec_diam); //big circle for the head
    }
    
    //add labels to electrodes
    fill(0,0,0);
    textFont(font);
    textAlign(CENTER, CENTER);
    for (int i=0; i < electrode_xy.length; i++) {
            //text(Integer.toString(i),electrode_xy[i][0], electrode_xy[i][1]);
        text(i+1,electrode_xy[i][0], electrode_xy[i][1]);
    }
    text("R",ref_electrode_xy[0],ref_electrode_xy[1]); 
  } //end of draw method
  
};




