////////////////////////////////////////////////////
//
//    W_Media.pde (ie "Media")
//
//    This converts Presentation Mode into a Widget!
//    Use this widget to display media and sync with external triggers.
//
//    Created by: Richard Waltman, April 2020
//
///////////////////////////////////////////////////,

class W_Media extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    // Make this public because it is accessed in systemDraw to draw on top
    public Presentation myPresentation;
    public boolean drawPresentation = false;
    private Button makeFullscreenButton;

    W_Media(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        myPresentation = new Presentation();

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        /*
        addDropdown("PDropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
        addDropdown("PDropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
        addDropdown("PDropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);
        */
        makeFullscreenButton = new Button (x + w - 160 - 10, y - navH + 2, 160, navH - 4, "Make Fullscreen", 12);
        makeFullscreenButton.setFont(p4, 14);
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. makeFullscreenButton)
        if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
            makeFullscreenButton.setIsActive(false);
            makeFullscreenButton.setIgnoreHover(true);
        } else {
            makeFullscreenButton.setIgnoreHover(false);
        }
        

    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        makeFullscreenButton.draw();

        popStyle();

    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //put your code here...
        makeFullscreenButton.setPos(x + w - 160 - 10, y - navH + 2);


    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. makeFullscreenButton)
        if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
            if(makeFullscreenButton.isMouseHere()){
                makeFullscreenButton.setIsActive(true);
            }
        }
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        //put your code here...
        if(makeFullscreenButton.isActive && makeFullscreenButton.isMouseHere()){
            drawPresentation = true;
        }
        makeFullscreenButton.setIsActive(false);

    }

    //add custom functions here
    void customFunction(){
        //this is a fake function... replace it with something relevant to this widget

    }

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
            text("Press [Escape] to exit presentation mode.", width/2, 31*(height/32));

            popStyle();
        }
    }
};

/*
//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void PDropdown1(int n){
    println("Item " + (n+1) + " selected from Dropdown 1");
    if(n==0){
        //do this
    } else if(n==1){
        //do this instead
    }

    closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

void PDropdown2(int n){
    println("Item " + (n+1) + " selected from Dropdown 2");
    closeAllDropdowns();
}

void PDropdown3(int n){
    println("Item " + (n+1) + " selected from Dropdown 3");
    closeAllDropdowns();
}
*/

