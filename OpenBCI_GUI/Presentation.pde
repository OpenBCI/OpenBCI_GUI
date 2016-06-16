

///////////////////////////////////////////////////////////////////////////
//
//     Created: 2/19/16
//     by Conor Russomanno for BodyHacking Con DIY Cyborgia Presentation
//     This code is used to organize a neuro-powered presentation... refer to triggers in the EEG_Processing_User class of the EEG_Processing.pde file
//
///////////////////////////////////////////////////////////////////////////

//Global Variables/Constants
Presentation myPresentation;
boolean drawPresentation = false;

class Presentation {
  //presentation images
  PImage presentationSlides[] = new PImage[16];
  float timeOfLastSlideChange = 0;  
  int currentSlide = 1;
  int slideCount = 0;
  boolean lockSlides = false;
  
  Presentation (){
    //loading presentation images
    println("attempting to load images for presentation...");
    presentationSlides[0] = loadImage("prez-images/DemocratizationOfNeurotech.001.jpg");
    presentationSlides[1] = loadImage("prez-images/DemocratizationOfNeurotech.001.jpg");
    presentationSlides[2] = loadImage("prez-images/DemocratizationOfNeurotech.002.jpg");
    presentationSlides[3] = loadImage("prez-images/DemocratizationOfNeurotech.003.jpg");
    presentationSlides[4] = loadImage("prez-images/DemocratizationOfNeurotech.004.jpg");
    presentationSlides[5] = loadImage("prez-images/DemocratizationOfNeurotech.005.jpg");
    presentationSlides[6] = loadImage("prez-images/DemocratizationOfNeurotech.006.jpg");
    presentationSlides[7] = loadImage("prez-images/DemocratizationOfNeurotech.007.jpg");
    presentationSlides[8] = loadImage("prez-images/DemocratizationOfNeurotech.008.jpg");
    presentationSlides[9] = loadImage("prez-images/DemocratizationOfNeurotech.009.jpg");
    presentationSlides[10] = loadImage("prez-images/DemocratizationOfNeurotech.010.jpg");
    presentationSlides[11] = loadImage("prez-images/DemocratizationOfNeurotech.011.jpg");
    presentationSlides[12] = loadImage("prez-images/DemocratizationOfNeurotech.012.jpg");
    presentationSlides[13] = loadImage("prez-images/DemocratizationOfNeurotech.013.jpg");
    presentationSlides[14] = loadImage("prez-images/DemocratizationOfNeurotech.014.jpg");
    presentationSlides[15] = loadImage("prez-images/DemocratizationOfNeurotech.015.jpg");
    //presentationSlides[16] = loadImage("prez-images/DemocratizationOfNeurotech.016.jpg");
    //presentationSlides[17] = loadImage("prez-images/DemocratizationOfNeurotech.017.jpg");
    //presentationSlides[18] = loadImage("prez-images/DemocratizationOfNeurotech.018.jpg");
    //presentationSlides[19] = loadImage("prez-images/DemocratizationOfNeurotech.019.jpg");
    //presentationSlides[20] = loadImage("prez-images/DemocratizationOfNeurotech.020.jpg");
    //presentationSlides[21] = loadImage("prez-images/DemocratizationOfNeurotech.021.jpg");
    //presentationSlides[22] = loadImage("prez-images/DemocratizationOfNeurotech.022.jpg");
    //presentationSlides[23] = loadImage("prez-images/DemocratizationOfNeurotech.023.jpg");
    //presentationSlides[24] = loadImage("prez-images/DemocratizationOfNeurotech.024.jpg");
    //presentationSlides[25] = loadImage("prez-images/DemocratizationOfNeurotech.025.jpg");
    //presentationSlides[26] = loadImage("prez-images/DemocratizationOfNeurotech.026.jpg");
    //presentationSlides[27] = loadImage("prez-images/DemocratizationOfNeurotech.027.jpg");
    //presentationSlides[28] = loadImage("prez-images/DemocratizationOfNeurotech.028.jpg");
    //presentationSlides[29] = loadImage("prez-images/DemocratizationOfNeurotech.029.jpg");
    //presentationSlides[30] = loadImage("prez-images/DemocratizationOfNeurotech.030.jpg");
    //presentationSlides[31] = loadImage("prez-images/DemocratizationOfNeurotech.031.jpg");
    //presentationSlides[32] = loadImage("prez-images/DemocratizationOfNeurotech.032.jpg");
    //presentationSlides[33] = loadImage("prez-images/DemocratizationOfNeurotech.033.jpg");
    //presentationSlides[34] = loadImage("prez-images/DemocratizationOfNeurotech.034.jpg");
    //presentationSlides[35] = loadImage("prez-images/DemocratizationOfNeurotech.035.jpg");
    //presentationSlides[36] = loadImage("prez-images/DemocratizationOfNeurotech.036.jpg");
    //presentationSlides[37] = loadImage("prez-images/DemocratizationOfNeurotech.037.jpg");
    //presentationSlides[38] = loadImage("prez-images/DemocratizationOfNeurotech.038.jpg");
    //presentationSlides[39] = loadImage("prez-images/DemocratizationOfNeurotech.039.jpg");
    //presentationSlides[40] = loadImage("prez-images/DemocratizationOfNeurotech.040.jpg");
    //presentationSlides[41] = loadImage("prez-images/DemocratizationOfNeurotech.041.jpg");
    //presentationSlides[42] = loadImage("prez-images/DemocratizationOfNeurotech.042.jpg");
    //presentationSlides[43] = loadImage("prez-images/DemocratizationOfNeurotech.043.jpg");
    //presentationSlides[44] = loadImage("prez-images/DemocratizationOfNeurotech.044.jpg");
    //presentationSlides[45] = loadImage("prez-images/DemocratizationOfNeurotech.045.jpg");
    //presentationSlides[46] = loadImage("prez-images/DemocratizationOfNeurotech.046.jpg");
    //presentationSlides[47] = loadImage("prez-images/DemocratizationOfNeurotech.047.jpg");
    //presentationSlides[48] = loadImage("prez-images/DemocratizationOfNeurotech.048.jpg");
    slideCount = 28;
    println("DONE loading images!");
    
  }
  
  public void slideForward() {
    if(currentSlide < slideCount - 1 && drawPresentation && !lockSlides){
      println("Slide Forward!");
      currentSlide++;
    }
  }
  
  public void slideBack() {
    if(currentSlide > 0 && drawPresentation && !lockSlides){
      println("Slide Back!");
      currentSlide--;
    }
  }
  
  public void draw() {
      // ----- Drawing Presentation -------
    if (drawPresentation == true) {
      image(presentationSlides[currentSlide], 0, 0, width, height);
    }
    
    if(lockSlides){
      //draw red rectangle to indicate that slides are locked
      pushStyle();
      fill(255,0,0);
      rect(width - 50, 25, 25, 25);
      popStyle();
    }
  }
}