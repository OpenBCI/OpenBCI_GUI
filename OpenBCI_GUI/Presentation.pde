

///////////////////////////////////////////////////////////////////////////
//
//     Created: 2/19/16
//     by Conor Russomanno for BodyHacking Con DIY Cyborgia Presentation
//     This code is used to organize a neuro-powered presentation... refer to triggers in the EEG_Processing_User class of the EEG_Processing.pde file
//
///////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

Presentation myPresentation;
boolean drawPresentation = false;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//------------------------------------------------------------------------
//                       Classes
//------------------------------------------------------------------------

class Presentation {
    //presentation images
    int slideCount = 4;
    PImage presentationSlides[] = new PImage[slideCount];
    float timeOfLastSlideChange = 0;
    int currentSlide = 0;
    boolean lockSlides = false;

    Presentation (){
        //loading presentation images
        //println("attempting to load images for presentation...");
        presentationSlides[0] = loadImage("prez-images/Presentation.000.jpg");
        presentationSlides[1] = loadImage("prez-images/Presentation.001.jpg");
        presentationSlides[2] = loadImage("prez-images/Presentation.002.jpg");
        presentationSlides[3] = loadImage("prez-images/Presentation.003.jpg");
        // presentationSlides[4] = loadImage("prez-images/Presentation.004.jpg");
        // presentationSlides[5] = loadImage("prez-images/Presentation.005.jpg");
        // presentationSlides[6] = loadImage("prez-images/Presentation.006.jpg");
        // presentationSlides[7] = loadImage("prez-images/Presentation.007.jpg");
        // presentationSlides[8] = loadImage("prez-images/Presentation.008.jpg");
        // presentationSlides[9] = loadImage("prez-images/Presentation.009.jpg");
        // presentationSlides[10] = loadImage("prez-images/Presentation.010.jpg");
        // presentationSlides[11] = loadImage("prez-images/Presentation.011.jpg");
        // presentationSlides[12] = loadImage("prez-images/Presentation.012.jpg");
        // presentationSlides[13] = loadImage("prez-images/Presentation.013.jpg");
        // presentationSlides[14] = loadImage("prez-images/Presentation.014.jpg");
        // presentationSlides[15] = loadImage("prez-images/Presentation.015.jpg");
        // slideCount = 4;
        //println("DONE loading images!");
    }

    public void slideForward() {
        if(currentSlide < slideCount - 1 && drawPresentation && !lockSlides){
            println("Slide Forward!");
            currentSlide++;
        } else{
            println("No more slides. Can't go forward...");
        }
    }

    public void slideBack() {
        if(currentSlide > 0 && drawPresentation && !lockSlides){
            println("Slide Back!");
            currentSlide--;
        } else {
            println("On the first slide. Can't go back...");
        }
    }

    public void draw() {
            // ----- Drawing Presentation -------
        pushStyle();

        image(presentationSlides[currentSlide], 0, 0, width, height);


        if(lockSlides){
            //draw red rectangle to indicate that slides are locked
            pushStyle();
            fill(255,0,0);
            rect(width - 50, 25, 25, 25);
            popStyle();
        }

        textFont(p3, 16);
        fill(openbciBlue);
        textAlign(CENTER);
        text("Press [Enter] to exit presentation mode.", width/2, 31*(height/32));

        popStyle();
    }
}
