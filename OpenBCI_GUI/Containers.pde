////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   This code is used for GUI-wide spacing. It defines the GUI layout as a grid
//   with the following design:
//
//   The #s shown below fall at the center of their corresponding container[].
//   Ex: container[1] is the upper left corner of the large rectangle between [0] & [10]
//   Ex 2: container[6] is the entire right half of the same rectangle.
//
//   ------------------------------------------------
//   |                      [0]                     |
//   ------------------------------------------------
//   |                       |         [11]         |
//   |         [1]          [2]---[15]--[3]---[16]--|
//   |                       |         [12]         |
//   |---------[4]----------[5]---------[6]---------|
//   |                       |         [13]         |
//   |         [7]          [8]---[17]--[9]---[18]--|
//   |                       |         [14]         |
//   ------------------------------------------------
//   |                      [10]                    |
//   ------------------------------------------------
//
//   Created by: Conor Russomanno (May 2016)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

boolean drawContainers = false;
Container[] container = new Container[19];

//Viz extends container (example below)
//Viz viz1;
//Viz viz2;

int widthOfLastScreen_C = 0;
int heightOfLastScreen_C = 0;

int topNav_h = 64; //tie this to a global variable or one attached to GUI_Manager
int bottomNav_h = 28; //same

void setupContainers() {

    widthOfLastScreen_C = width;
    heightOfLastScreen_C = height;

    container[0] = new Container(0, 0, width, topNav_h, 0);
    container[5] = new Container(0, topNav_h, width, height - (topNav_h + bottomNav_h), 1);
    container[1] = new Container(container[5], "TOP_LEFT");
    container[2] = new Container(container[5], "TOP");
    container[3] = new Container(container[5], "TOP_RIGHT");
    container[4] = new Container(container[5], "LEFT");
    container[6] = new Container(container[5], "RIGHT");
    container[7] = new Container(container[5], "BOTTOM_LEFT");
    container[8] = new Container(container[5], "BOTTOM");
    container[9] = new Container(container[5], "BOTTOM_RIGHT");
    container[10] = new Container(0, height - bottomNav_h, width, 50, 0);
    container[11] = new Container(container[3], "TOP");
    container[12] = new Container(container[3], "BOTTOM");
    container[13] = new Container(container[9], "TOP");
    container[14] = new Container(container[9], "BOTTOM");
    container[15] = new Container(container[6], "TOP_LEFT");
    container[16] = new Container(container[6], "TOP_RIGHT");
    container[17] = new Container(container[6], "BOTTOM_LEFT");
    container[18] = new Container(container[6], "BOTTOM_RIGHT");

    //setup viz objects... example of container extension (more below)
    //setupVizs();
}

void drawContainers() {
    for(int i = 0; i < container.length; i++){
        container[i].draw();
    }

    //Draw viz objects.. example extension of container class (more below)
    //viz1.draw();
    //viz2.draw();

    //alternative component listener function (line 177 - 187 frame.addComponentListener) for processing 3,
    if (widthOfLastScreen_C != width || heightOfLastScreen_C != height) {
        setupContainers();
        //setupVizs(); //container extension example (more below)
        settings.widthOfLastScreen = width;
        settings.heightOfLastScreen = height;
    }
}

public class Container {

    //key Container Variables
    public float x0, y0, w0, h0; //true dimensions.. without margins
    public float x, y, w, h; //dimensions with margins
    public float margin; //margin

    //constructor 1 -- comprehensive
    public Container(float _x0, float _y0, float _w0, float _h0, float _margin) {

        margin = _margin;

        x0 = _x0;
        y0 = _y0;
        w0 = _w0;
        h0 = _h0;

        x = x0 + margin;
        y = y0 + margin;
        w = w0 - margin*2;
        h = h0 - margin*2;
    }

    //constructor 2 -- recursive constructor -- for quickly building sub-containers based on a super container (aka master)
    public Container(Container master, String _type) {

        margin = master.margin;

        if(_type == "WHOLE"){
            x0 = master.x0;
            y0 = master.y0;
            w0 = master.w0;
            h0 = master.h0;
            w = master.w;
            h = master.h;
            x = master.x;
            y = master.y;
        } else if (_type == "LEFT") {
            x0 = master.x0;
            y0 = master.y0;
            w0 = master.w0/2;
            h0 = master.h0;
            w = (master.w - margin)/2;
            h = master.h;
            x = master.x;
            y = master.y;
        } else if (_type == "RIGHT") {
            x0 = master.x0 + master.w0/2;
            y0 = master.y0;
            w0 = master.w0/2;
            h0 = master.h0;
            w = (master.w - margin)/2;
            h = master.h;
            x = master.x + w + margin;
            y = master.y;
        } else if (_type == "TOP") {
            x0 = master.x0;
            y0 = master.y0;
            w0 = master.w0;
            h0 = master.h0/2;
            w = master.w;
            h = (master.h - margin)/2;
            x = master.x;
            y = master.y;
        } else if (_type == "BOTTOM") {
            x0 = master.x0;
            y0 = master.y0 + master.h0/2;
            w0 = master.w0;
            h0 = master.h0/2;
            w = master.w;
            h = (master.h - margin)/2;
            x = master.x;
            y = master.y + h + margin;
        } else if (_type == "TOP_LEFT") {
            x0 = master.x0;
            y0 = master.y0;
            w0 = master.w0/2;
            h0 = master.h0/2;
            w = (master.w - margin)/2;
            h = (master.h - margin)/2;
            x = master.x;
            y = master.y;
        } else if (_type == "TOP_RIGHT") {
            x0 = master.x0 + master.w0/2;
            y0 = master.y0;
            w0 = master.w0/2;
            h0 = master.h0/2;
            w = (master.w - margin)/2;
            h = (master.h - margin)/2;
            x = master.x + w + margin;
            y = master.y;
        } else if (_type == "BOTTOM_LEFT") {
            x0 = master.x0;
            y0 = master.y0 + master.h0/2;
            w0 = master.w0/2;
            h0 = master.h0/2;
            w = (master.w - margin)/2;
            h = (master.h - margin)/2;
            x = master.x;
            y = master.y + h + margin;
        } else if (_type == "BOTTOM_RIGHT") {
            x0 = master.x0 + master.w0/2;
            y0 = master.y0 + master.h0/2;
            w0 = master.w0/2;
            h0 = master.h0/2;
            w = (master.w - margin)/2;
            h = (master.h - margin)/2;
            x = master.x + w + margin;
            y = master.y + h + margin;
        }
    }

    public void draw() {
        if(drawContainers){
            pushStyle();

            //draw margin area
            fill(102, 255, 71, 100);
            noStroke();
            rect(x0, y0, w0, h0);

            //noFill();
            //stroke(255, 0, 0);
            //rect(x0, y0, w0, h0);

            fill(31, 69, 110, 100);
            noStroke();
            rect(x, y, w, h);

            popStyle();
        }
    }
};

// --- EXAMPLE OF EXTENDING THE CONTAINER --- //

//public class Viz extends Container {
//  public float abc;

//  public Viz(float _abc, Container master) {
//    super(master, "WHOLE");
//    abc = _abc;
//  }

//  void draw() {
//    pushStyle();
//    noStroke();
//    fill(255, 0, 0, 50);
//    rect(x, y, w, h);
//    popStyle();
//  }
//};

//void setupVizs() {
//  viz1 = new Viz (10f, container2);
//  viz2 = new Viz (10f, container4);
//}

// --- END OF EXAMPLE OF EXTENDING THE CONTAINER --- //
