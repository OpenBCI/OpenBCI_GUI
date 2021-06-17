void setup() {
  size(1000, 700, P3D); 
}

void draw() {
  background(200);
  noStroke();
  lights();
  translate(500, 500, 0);
  rotateX(mouseY * 0.05);
  rotateY(mouseX * 0.05);
  //fill(mouseX * 2, 0, 160);
  //sphereDetail(mouseX / 4);
  sphere(40);
}