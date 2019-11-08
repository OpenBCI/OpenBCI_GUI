
//////////////////////////////////////////////////////
//                                                  //
//                  W_Spectrogram.pde               //
//                                                  //
//                                                  //
//    Created by: Richard Waltman, September 2019   //
//                                                  //
//////////////////////////////////////////////////////

class W_Spectrogram extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    //put your custom variables here...
    Button widgetTemplateButton;

    //Minim minim;
    AudioPlayer jingle;
    //FFT fftLin_L;
    //FFT fftLin_R;
    int xPos = 0;
    int hueLimit = 160;
    boolean isActive = false;

    PImage img;
    int prevW = 0;
    int prevH = 0;

    int lastShift = 0;
    final int scrollSpeed = 100;

    W_Spectrogram(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        xPos = w - 1; //draw on the right, and shift pixels to the left
        prevW = w;
        prevH = h;

        img = createImage(w, h, RGB);
        lastShift = millis();


        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        //addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
        //addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
        //addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

        widgetTemplateButton = new Button (x + w/2, y + navHeight, 200, navHeight, "SelectSoundFile", 12);
        widgetTemplateButton.setFont(p4, 14);
        widgetTemplateButton.setURL("https://openbci.github.io/Documentation/docs/06Software/01-OpenBCISoftware/GUIWidgets#custom-widget");
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
        if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
            widgetTemplateButton.setIsActive(false);
            widgetTemplateButton.setIgnoreHover(true);
        } else {
            widgetTemplateButton.setIgnoreHover(false);
        }

        /*
        if (this.isActive) {
            // perform a forward FFT on the samples in jingle's mix buffer
            // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
            fftLin_L.forward(jingle.left);
            fftLin_R.forward(jingle.right);
            // increment the x position
            xPos = xPos + 1;
            // wrap around at the screen width
            if (xPos >= w) {
                xPos = 0;
            }
        }

        final int INTERVAL = 10;
        
        void setup()
        {
        size(400, 400);
        smooth();
        background(255);
        }
        
        void draw()
        {
        // Scroll one column of pixels per frame
        loadPixels();
        for (int r = 0; r < height; r++)
        {
            arrayCopy(pixels, width * r, pixels, width * r + 1, width - 1);
        }
        updatePixels();
        // Add a line from time to time
        if (frameCount % INTERVAL == 0)
        {
            stroke(color(random(0, 50), random(50, 200), random(100, 255)));
            strokeWeight(random(2, 10));
            line(random(INTERVAL, width), 0, random(INTERVAL, width), height);
        }
        }



        */
        if (isRunning) {
            //Make sure we are always draw new pixels on the right
            xPos = w - 1;
        }

        if (prevW != w || prevH != h) {
            img.resize(w, h);
            prevW = w;
            prevH = h;
            println("+++++ IMG W == " + img.width + " || IMG H == " + img.height);
        }
        
        //println("+++++++XPOS  == " + xPos + " || RightEdge == " + (w));
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();
        widgetTemplateButton.draw();

        if (isRunning) {
            img.loadPixels();

            //Shift all pixels to the left! (every scrollspeed ms)
            if(millis() - lastShift > scrollSpeed) {
                for (int r = 0; r < h; r++) {
                    if (r != 0) {
                        arrayCopy(img.pixels, w * r, img.pixels, w * r - 1, w);
                    } else {
                        //When there would be an ArrayOutOfBoundsException, account for it!
                        arrayCopy(img.pixels, w * r + 1, img.pixels, r * w, w);
                    }
                }

                lastShift += scrollSpeed;
            }
            //for (int i = 0; i < fftLin_L.specSize() - 80; i++) {
            for (int i = 0; i < h/2; i++) {
                //LEFT SPECTROGRAM ON TOP
                float hueValue = hueLimit - map((fftBuff[0].getBand(i)*32), 0, 256, 0, hueLimit);
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(int(hueValue), 100, 80);
                // plot a point using the specified stroke
                //point(xPos, i);
                int loc = xPos + (h/2 - i) * (img.width);
                if (loc >= img.width * img.height) loc = img.width * img.height - 1;
                try {
                    img.pixels[loc] = color(int(hueValue), 100, 80);
                } catch (Exception e) {
                    println("Major drawing error Spectrogram Left image!");
                }

                //RIGHT SPECTROGRAM ON BOTTOM
                hueValue = hueLimit - map((fftBuff[1].getBand(i)*32), 0, 256, 0, hueLimit);
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(int(hueValue), 100, 80);
                // Pixel = X + ((Y + Height/2) * Width)
                loc = xPos + ((i + img.height/2) * img.width);
                if (loc >= img.width * img.height) loc = img.width * img.height - 1;
                try {
                    img.pixels[loc] = color(int(hueValue), 100, 80);
                } catch (Exception e) {
                    println("Major drawing error Spectrogram Right image!");
                }
            }
            img.updatePixels();
            image(img, x, y);
        }
        popStyle();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
        
        cp5.setGraphics(pApplet, 0, 0);
        //put your code here...
        widgetTemplateButton.setPos(x + w/2 - widgetTemplateButton.but_dx/2, y - navHeight);


    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
        if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
            if(widgetTemplateButton.isMouseHere()){
                widgetTemplateButton.setIsActive(true);
            }
        }
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        //put your code here...
        if(widgetTemplateButton.isActive && widgetTemplateButton.isMouseHere()){
            selectInput("Select a sound file for playback:", "loadSoundFromFile");
        }

        widgetTemplateButton.setIsActive(false);

    }

    /*
    void start() {

        this.isActive = true;

        // loop the file
        jingle.loop();
        
        // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
        // note that this needs to be a power of two 
        // and that it means the size of the spectrum will be 1024. 
        // see the online tutorial for more info.
        fftLin_L = new FFT(jingle.bufferSize(), jingle.sampleRate());
        fftLin_R = fftLin_L;
        // calculate the averages by grouping frequency bands linearly. use 30 averages.
        fftLin_L.linAverages(30);
        fftLin_R.linAverages(30);

        img.resize(w, h);
    }

    void stop() {
        this.isActive = false;
        // always close Minim audio classes when you are done with them
        jingle.close();
        // always stop Minim before exiting
        minim.stop();
        //super.stop();
    }
    */
};

/*
void loadSoundFromFile(File selection) {
    if (w_spectrogram.isActive) w_spectrogram.stop();
    w_spectrogram.jingle = minim.loadFile(selection.getAbsolutePath(), 512);
    w_spectrogram.start();
}
*/


