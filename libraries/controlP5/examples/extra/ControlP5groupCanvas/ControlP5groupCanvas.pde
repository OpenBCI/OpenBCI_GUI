/**
 * ControlP5 Canvas
 *
 * by andreas schlegel, 2011
 * www.sojamo.de/libraries/controlp5
 * 
 */
 
import controlP5.*;
  
ControlP5 cp5;
  
void setup() {
  size(400,600);
  smooth();
  
  cp5 = new ControlP5(this);
  cp5.addGroup("myGroup")
     .setLabel("Testing Canvas")
     .setPosition(100,200)
     .setWidth(200)
     .addCanvas(new TestCanvas())
     ;
}

void draw() {
  background(0);
}


class TestCanvas extends Canvas {
  
  float n;
  float a;
  
  public void setup(PGraphics pg) {
    println("starting a test canvas.");
    n = 1;
  }
  public void draw(PGraphics pg) {
    n += 0.01;
    pg.ellipseMode(CENTER);
    pg.fill(lerpColor(color(0,100,200),color(0,200,100),map(sin(n),-1,1,0,1)));
    pg.rect(0,0,200,200);
    pg.fill(255,150);
    a+=0.01;
    ellipse(100,100,abs(sin(a)*150),abs(sin(a)*150));
    ellipse(40,40,abs(sin(a+0.5)*50),abs(sin(a+0.5)*50));
    ellipse(60,140,abs(cos(a)*80),abs(cos(a)*80));
  }
}
