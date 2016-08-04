/**
 * ColourMap_Camera
 * This sketch demontrates how to use a simple camera object and Colourmap
 * presets.
 */
import org.gwoptics.graphics.graph3D.*;
import org.gwoptics.graphics.*;
import org.gwoptics.graphics.colourmap.presets.*;

import org.gwoptics.graphics.*;
import org.gwoptics.graphics.camera.*;
import org.gwoptics.graphics.colourmap.*;
import org.gwoptics.graphics.graph3D.*;

Camera3D cam;
SurfaceGraph3D g3d[];
PGraphicsOpenGL g3; 

IGraph3DCallback gcb = new IGraph3DCallback(){
  public float computePoint(float X, float Y) {
    return (float) (Math.sin(X)*Math.sin(Y));
  }
};

void setup() {
  size(500, 500, OPENGL); 
  frameRate(15);

  g3 = (PGraphicsOpenGL) g; 

  cam = new Camera3D(this);
  PVector cam_pos = new PVector(800f,800f,800f);
  cam.setPosition(cam_pos);

  PFont myFont;
  myFont = createFont("FFScala", 32);
  textFont(myFont);

  g3d = new SurfaceGraph3D[4];

  for(int i = 0; i < 4;i++){
    g3d[i] = new SurfaceGraph3D(this, 400, 400,200);		
    g3d[i].setXAxisMin(-5);		
    g3d[i].setXAxisMax(5);	
    g3d[i].setYAxisMin(-5);		
    g3d[i].setYAxisMax(5);
    g3d[i].setZAxisMin(-1);
    g3d[i].setZAxisMax(1);

    switch(i){
    case 0:
      g3d[i].addSurfaceTrace(gcb, 100, 100, PresetColourmaps.getColourmap(Presets.FLIP));
      break;
    case 1:
      g3d[i].addSurfaceTrace(gcb, 100, 100, PresetColourmaps.getColourmap(Presets.COOL));
      break;
    case 2:
      g3d[i].addSurfaceTrace(gcb, 100, 100, PresetColourmaps.getColourmap(Presets.HOT));
      break;
    case 3:
      g3d[i].addSurfaceTrace(gcb, 100, 100, PresetColourmaps.getColourmap(Presets.WARM));
      break;
    default:
      break;
    }

    g3d[i].plotSurfaceTrace(0);
  }
}

void draw() {
  background(204);

  pushMatrix();
  translate(-450,0,-450);
  g3d[0].draw();
  popMatrix();

  pushMatrix();
  translate(50,0,50);
  g3d[1].draw();
  popMatrix();

  pushMatrix();
  translate(-450,0,50);
  g3d[2].draw();
  popMatrix();

  pushMatrix();
  translate(50,0,-450);
  g3d[3].draw();
  popMatrix();
  printFPS();
}

// The following is used to print fps rate on screen independent of the camera 
void printFPS()
{
  PMatrix3D currCameraMatrix = new PMatrix3D(g3.camera);
  camera();
  text("fps = "+(float)round(10000.0*frameCount/millis())/10.0, 70, 30);
  g3.camera = currCameraMatrix;
}



