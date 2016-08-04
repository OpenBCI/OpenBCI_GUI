/**
 * SquareMesh
 * A very simple demostration of mesh on a square grid.
 */

import org.gwoptics.graphics.graph3D.SquareGridMesh;
import org.gwoptics.graphics.camera.Camera3D;

Camera3D cam;
SquareGridMesh sMesh;

void setup(){
  size(500,300,OPENGL);
  frameRate(30);
  cam = new Camera3D(this);
  cam.setPosition(new PVector(3000,2500,1500));
  cam.setFarLimit(20000);
  sMesh = new SquareGridMesh(40,40,80,80,this);
}

void draw(){
  if(frameCount % 2 == 0){
    for(int i = 0; i <= sMesh.sizeX();i++){
      for(int j = 0; j <= sMesh.sizeY();j++){
        sMesh.setZValue(i,j, (float)(300 * sin(0.02f*i*j) * pow((float)Math.random(),4f)));
      }
    }
  }

  background(200);
  translate(-1750,0,-1750);
  sMesh.draw();
}

