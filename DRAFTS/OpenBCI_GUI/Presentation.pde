

///////////////////////////////////////////////////////////////////////////
//
//     Created: 2/19/16
//     by Conor Russomanno for BodyHacking Con DIY Cyborgia Presentation
//     This code is used to organize a neuro-powered presentation... refer to triggers in the EEG_Processing_User class of the EEG_Processing.pde file
//
///////////////////////////////////////////////////////////////////////////

boolean drawPresentation = false;

class Presentation {
  //presentation images
  PImage presentationSlides[] = new PImage[63];
  float timeOfLastSlideChange = 0;  
  int currentSlide = 1;
  int slideCount = 0;
  
  Presentation (){
    //loading presentation images
    println("attempting to load images for presentation...");
    presentationSlides[0] = loadImage("prez-images/DIY_Cyborgia.001.jpg");
    presentationSlides[1] = loadImage("prez-images/DIY_Cyborgia.001.jpg");
    presentationSlides[2] = loadImage("prez-images/DIY_Cyborgia.002.jpg");
    presentationSlides[3] = loadImage("prez-images/DIY_Cyborgia.003.jpg");
    presentationSlides[4] = loadImage("prez-images/DIY_Cyborgia.004.jpg");
    presentationSlides[5] = loadImage("prez-images/DIY_Cyborgia.005.jpg");
    presentationSlides[6] = loadImage("prez-images/DIY_Cyborgia.006.jpg");
    presentationSlides[7] = loadImage("prez-images/DIY_Cyborgia.007.jpg");
    presentationSlides[8] = loadImage("prez-images/DIY_Cyborgia.008.jpg");
    presentationSlides[9] = loadImage("prez-images/DIY_Cyborgia.009.jpg");
    presentationSlides[10] = loadImage("prez-images/DIY_Cyborgia.010.jpg");
    presentationSlides[11] = loadImage("prez-images/DIY_Cyborgia.011.jpg");
    presentationSlides[12] = loadImage("prez-images/DIY_Cyborgia.012.jpg");
    presentationSlides[13] = loadImage("prez-images/DIY_Cyborgia.013.jpg");
    presentationSlides[14] = loadImage("prez-images/DIY_Cyborgia.014.jpg");
    presentationSlides[15] = loadImage("prez-images/DIY_Cyborgia.015.jpg");
    presentationSlides[16] = loadImage("prez-images/DIY_Cyborgia.016.jpg");
    presentationSlides[17] = loadImage("prez-images/DIY_Cyborgia.017.jpg");
    presentationSlides[18] = loadImage("prez-images/DIY_Cyborgia.018.jpg");
    presentationSlides[19] = loadImage("prez-images/DIY_Cyborgia.019.jpg");
    presentationSlides[20] = loadImage("prez-images/DIY_Cyborgia.020.jpg");
    presentationSlides[21] = loadImage("prez-images/DIY_Cyborgia.021.jpg");
    presentationSlides[22] = loadImage("prez-images/DIY_Cyborgia.022.jpg");
    presentationSlides[23] = loadImage("prez-images/DIY_Cyborgia.023.jpg");
    presentationSlides[24] = loadImage("prez-images/DIY_Cyborgia.024.jpg");
    presentationSlides[25] = loadImage("prez-images/DIY_Cyborgia.025.jpg");
    presentationSlides[26] = loadImage("prez-images/DIY_Cyborgia.026.jpg");
    presentationSlides[27] = loadImage("prez-images/DIY_Cyborgia.027.jpg");
    presentationSlides[28] = loadImage("prez-images/DIY_Cyborgia.028.jpg");
    presentationSlides[29] = loadImage("prez-images/DIY_Cyborgia.029.jpg");
    presentationSlides[30] = loadImage("prez-images/DIY_Cyborgia.030.jpg");
    presentationSlides[31] = loadImage("prez-images/DIY_Cyborgia.031.jpg");
    presentationSlides[32] = loadImage("prez-images/DIY_Cyborgia.032.jpg");
    presentationSlides[33] = loadImage("prez-images/DIY_Cyborgia.033.jpg");
    presentationSlides[34] = loadImage("prez-images/DIY_Cyborgia.034.jpg");
    presentationSlides[35] = loadImage("prez-images/DIY_Cyborgia.035.jpg");
    presentationSlides[36] = loadImage("prez-images/DIY_Cyborgia.036.jpg");
    presentationSlides[37] = loadImage("prez-images/DIY_Cyborgia.037.jpg");
    presentationSlides[38] = loadImage("prez-images/DIY_Cyborgia.038.jpg");
    presentationSlides[39] = loadImage("prez-images/DIY_Cyborgia.039.jpg");
    presentationSlides[40] = loadImage("prez-images/DIY_Cyborgia.040.jpg");
    presentationSlides[41] = loadImage("prez-images/DIY_Cyborgia.041.jpg");
    presentationSlides[42] = loadImage("prez-images/DIY_Cyborgia.042.jpg");
    presentationSlides[43] = loadImage("prez-images/DIY_Cyborgia.043.jpg");
    presentationSlides[44] = loadImage("prez-images/DIY_Cyborgia.044.jpg");
    presentationSlides[45] = loadImage("prez-images/DIY_Cyborgia.045.jpg");
    presentationSlides[46] = loadImage("prez-images/DIY_Cyborgia.046.jpg");
    presentationSlides[47] = loadImage("prez-images/DIY_Cyborgia.047.jpg");
    presentationSlides[48] = loadImage("prez-images/DIY_Cyborgia.048.jpg");
    slideCount = 49;
    println("DONE loading images!");
    
  }
  
  public void slideForward() {
    if(currentSlide < slideCount - 1 && drawPresentation){
      println("Slide Forward!");
      currentSlide++;
    }
  }
  
  public void slideBack() {
    if(currentSlide > 0 && drawPresentation){
      println("Slide Back!");
      currentSlide--;
    }
  }
  
  public void draw() {
      // ----- Drawing Presentation -------
    if (drawPresentation == true) {
      image(presentationSlides[currentSlide], 0, 0, width, height);
    }
  }
}