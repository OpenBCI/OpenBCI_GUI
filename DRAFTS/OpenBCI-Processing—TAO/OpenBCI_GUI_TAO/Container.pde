////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public class Container {

  //key Container Variables
  public float CON_X0, CON_Y0, CON_W0, CON_H0; //true dimensions.. without margins
  public float CON_X, CON_Y, CON_W, CON_H; //dimensions with margins
  public float margin; //margin
  public color bdColor, mgColor; //body color and margin color
  public boolean visible; //if this container is visible

  //constructor 1 -- comprehensive
  public Container(float _CON_X0, float _CON_Y0, float _CON_W0, float _CON_H0, float _margin, color _bdColor, color _mgColor, boolean _visible) {
        
    CON_X0 = _CON_X0;
    CON_Y0 = _CON_Y0;
    CON_W0 = _CON_W0;
    CON_H0 = _CON_H0;

    CON_X = CON_X0 + margin;
    CON_Y = CON_Y0 + margin;
    CON_W = CON_W0 - margin*2;
    CON_H = CON_H0 - margin*2;
    
    margin = _margin;
    bdColor = _bdColor;
    mgColor = _mgColor;
    visible = _visible;
  }

  //constructor 2 -- recursive constructor -- for quickly building sub-containers based on a super container (aka master)
  public Container(Container master, String _type) {
    
    bdColor = master.bdColor;
    mgColor = master.mgColor;
    margin = master.margin;
    visible = master.visible;

    if(_type == "WHOLE"){
      CON_X0 = master.CON_X0;
      CON_Y0 = master.CON_Y0;
      CON_W0 = master.CON_W0;
      CON_H0 = master.CON_H0;
      CON_W = master.CON_W;
      CON_H = master.CON_H;
      CON_X = master.CON_X;
      CON_Y = master.CON_Y;
    } else if (_type == "LEFT") {
      CON_X0 = master.CON_X0;
      CON_Y0 = master.CON_Y0;
      CON_W0 = master.CON_W0/2;
      CON_H0 = master.CON_H0;
      CON_W = (master.CON_W - margin)/2;
      CON_H = master.CON_H;
      CON_X = master.CON_X;
      CON_Y = master.CON_Y;
    } else if (_type == "RIGHT") {
      CON_X0 = master.CON_X0 + master.CON_W0/2;
      CON_Y0 = master.CON_Y0;
      CON_W0 = master.CON_W0/2;
      CON_H0 = master.CON_H0;
      CON_W = (master.CON_W - margin)/2;
      CON_H = master.CON_H;
      CON_X = master.CON_X + CON_W + margin;
      CON_Y = master.CON_Y;
    } else if (_type == "TOP") {
      CON_X0 = master.CON_X0;
      CON_Y0 = master.CON_Y0;
      CON_W0 = master.CON_W0;
      CON_H0 = master.CON_H0/2;
      CON_W = master.CON_W;
      CON_H = (master.CON_H - margin)/2;
      CON_X = master.CON_X;
      CON_Y = master.CON_Y;
    } else if (_type == "BOTTOM") {
      CON_X0 = master.CON_X0;
      CON_Y0 = master.CON_Y0 + master.CON_H0/2;
      CON_W0 = master.CON_W0;
      CON_H0 = master.CON_H0/2;
      CON_W = master.CON_W;
      CON_H = (master.CON_H - margin)/2;
      CON_X = master.CON_X;
      CON_Y = master.CON_Y + CON_H + margin;
    } else if (_type == "UPPER_LEFT") {
      CON_X0 = master.CON_X0;
      CON_Y0 = master.CON_Y0;
      CON_W0 = master.CON_W0/2;
      CON_H0 = master.CON_H0/2;
      CON_W = (master.CON_W - margin)/2;
      CON_H = (master.CON_H - margin)/2;
      CON_X = master.CON_X;
      CON_Y = master.CON_Y;
    } else if (_type == "UPPER_RIGHT") {
      CON_X0 = master.CON_X0 + master.CON_W0/2;
      CON_Y0 = master.CON_Y0;
      CON_W0 = master.CON_W0/2;
      CON_H0 = master.CON_H0/2;
      CON_W = (master.CON_W - margin)/2;
      CON_H = (master.CON_H - margin)/2;
      CON_X = master.CON_X + CON_W + margin;
      CON_Y = master.CON_Y;
    } else if (_type == "LOWER_LEFT") {
      CON_X0 = master.CON_X0;
      CON_Y0 = master.CON_Y0 + master.CON_H0/2;
      CON_W0 = master.CON_W0/2;
      CON_H0 = master.CON_H0/2;
      CON_W = (master.CON_W - margin)/2;
      CON_H = (master.CON_H - margin)/2;
      CON_X = master.CON_X;
      CON_Y = master.CON_Y + CON_H + margin;
    } else if (_type == "LOWER_RIGHT") {
      CON_X0 = master.CON_X0 + master.CON_W0/2;
      CON_Y0 = master.CON_Y0 + master.CON_H0/2;
      CON_W0 = master.CON_W0/2;
      CON_H0 = master.CON_H0/2;
      CON_W = (master.CON_W - margin)/2;
      CON_H = (master.CON_H - margin)/2;
      CON_X = master.CON_X + CON_W + margin;
      CON_Y = master.CON_Y + CON_H + margin;
    }
  }

  public void draw() {
   if(visible){
     pushStyle();
  
     //draw margin area 
     fill(mgColor);
     noStroke();
     rect(CON_X0, CON_Y0, CON_W0, CON_H0);
  
     //noFill();
     //stroke(255, 0, 0);
     //rect(CON_X0, CON_Y0, CON_W0, CON_H0);
  
     fill(bdColor);
     noStroke();
     rect(CON_X, CON_Y, CON_W, CON_H);
  
     popStyle();
   }
  }
};








//class Draggable {
// boolean dragging = false; // Is the object being dragged?
// boolean rollover = false; // Is the mouse over the ellipse?
  
// float dragX,dragY,dragW,dragH;          // Location and size
// float dragOffsetX, dragOffsetY; // Mouseclick offset
// float dragRangeX, dragRangeY, dragRangeW, dragRangeH;  //range of dragging

// Draggable(float tempX, float tempY, float tempW, float tempH) {
//   dragX = tempX;
//   dragY = tempY;
//   dragW = tempW;
//   dragH = tempH;
//   dragOffsetX = 0;
//   dragOffsetY = 0;
//   dragRangeX = 0;
//   dragRangeY = 0;
//   dragRangeW = width;
//   dragRangeH = height;
// }

// // // Method to display
// // void display() {
// //   stroke(0);
// //   if (dragging) fill (50);
// //   else if (rollover) fill(100);
// //   else fill(175,200);
// //   ellipse(x,y,w,h);
// // }

// // Is a point inside the rectangle (for click)?
// void clicked(float mx, float my) {
//   //if (isInsideCircle((int)dragX, (int)dragY, (int)dragW, (int)dragH, mx, my)) {
//   if (isInsideCircle(dragX, dragY, dragW, dragH, mx, my)) {
//     dragging = true;
//     // If so, keep track of relative location of click to corner of rectangle
//     dragOffsetX = dragX-mx;
//     dragOffsetY = dragY-my;
//   }
// }
  
// // Is a point inside the rectangle (for rollover)
// void rollover(float mx, float my) {
//   // if (isInsideCircle(dragX, dragY, dragW, dragH, mx, my)) {
//   //   rollover = true;
//   // } else {
//   //   rollover = false;
//   // }
// }

// // Stop dragging
// void stopDragging() {
//   dragging = false;
// }
  
// // Drag the rectangle
// void drag(float mx, float my) {
//   if (isOutOfRange(0.5 * width, 0.5 * height, width, height, mx, my)) return;
//   if (dragging) {
//     dragX = mx + dragOffsetX;
//     dragY = my + dragOffsetY;
//   }
// }

// boolean isInsideCircle(float x, float y, float w, float h, float mX, float mY) {
//   float dx = mX - x;
//   float dy = mY - y;
//   float r = sqrt(dx*dx + dy*dy);
//   if (r <= 0.5 * w) {
//     return true;
//   } else {
//     return false;
//   } 
// }

// boolean isInsideRect(float x, float y, float w, float h, float mX, float mY) {
//   if (mX < x || mY < y || mX > x + w || mY > y + h) return false;
//   else return true;
// }

// boolean isOutOfRange(float x, float y, float w, float h, float mX, float mY) {
//   //if (mX < x || mY < y || mX > x + w || mY > y + h) return true;
//   float dx = mX - x;
//   float dy = mY - y;
//   float r = sqrt(dx*dx + dy*dy);
//   if (r > 0.5 * w) return true;
//   else return false;
// }

//}