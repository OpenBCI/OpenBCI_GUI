

Ten20_node[] Ten20_nodes;
PFont f;

void setup(){
  size(400,400);
  //defineNodes("BASIC");
  defineNodes("ADVANCED");
  textAlign(CENTER);
  f = createFont("SourceCodePro-Regular.ttf", 24);
}

void draw(){
  background(255);
  for(int i = 0; i < Ten20_nodes.length; i++){
    Ten20_nodes[i].draw(width/2, height/2, 120.0);
    
    //if(mouseX Ten20_nodes[i].x-Ten20_nodes[i]&& mouseX && mouseY && mouseY){
    //  //highlight node
    //}
  }
}

class Ten20_node {
  String name;
  float x, y;
  int nodeDiameter = 18;

  
  Ten20_node(String _name, float _x, float _y){
    name = _name;
    x = _x;
    y = _y;
  }
  
  void draw(int _centerX, int _centerY, float _scale){
    noFill();
    stroke(125);
    ellipse(_centerX + x*_scale, _centerY - y*_scale, nodeDiameter, nodeDiameter);
    fill(0);
    textSize(8);
    text(name, _centerX + x*_scale, _centerY - y*_scale + 4);
  }
  
};

void defineNodes(String _type){
 if(_type=="BASIC" || _type=="21"){
   //build basic 1020 head plot
 } else if(_type=="ADVANCED" || _type=="69"){
   //build advanced 1020 head plot
   Ten20_nodes = new Ten20_node[69]; //set size of array to 69 cells
   //fill cells with high-density 1029 locations
   Ten20_nodes[0] = new Ten20_node("Fp1", -0.29, 0.95);
   Ten20_nodes[1] = new Ten20_node("Fpz", 0, 1.0);
   Ten20_nodes[2] = new Ten20_node("Fp2", 0.29, 0.95);
   Ten20_nodes[3] = new Ten20_node("AF7", -0.57, 0.85);
   Ten20_nodes[4] = new Ten20_node("AF5", -0.45, 0.8);
   Ten20_nodes[5] = new Ten20_node("AF3", -0.3, 0.77);
   Ten20_nodes[6] = new Ten20_node("AF1", -0.15, 0.76);
   Ten20_nodes[7] = new Ten20_node("AFz", 0, 0.75);
   Ten20_nodes[8] = new Ten20_node("AF2", 0.15, 0.76);
   Ten20_nodes[9] = new Ten20_node("AF4", 0.3, 0.77);
   Ten20_nodes[10] = new Ten20_node("AF6", 0.45, 0.8);
   Ten20_nodes[11] = new Ten20_node("AF8", 0.57, 0.85);
   Ten20_nodes[12] = new Ten20_node("F7", -0.79, 0.62);
   Ten20_nodes[13] = new Ten20_node("F5", -0.62, 0.56);
   Ten20_nodes[14] = new Ten20_node("F3", -0.42, 0.53);
   Ten20_nodes[15] = new Ten20_node("F1", -0.21, 0.51);
   Ten20_nodes[16] = new Ten20_node("Fz", 0, 0.5);
   Ten20_nodes[17] = new Ten20_node("F2", 0.21, 0.51);
   Ten20_nodes[18] = new Ten20_node("F4", 0.42, 0.53);
   Ten20_nodes[19] = new Ten20_node("F6", 0.62, 0.56);
   Ten20_nodes[20] = new Ten20_node("F8", 0.79, 0.62);
   Ten20_nodes[21] = new Ten20_node("FT7", -0.95, 0.33);
   Ten20_nodes[22] = new Ten20_node("FC5", -0.72, 0.29);
   Ten20_nodes[23] = new Ten20_node("FC3", -0.48, 0.27);
   Ten20_nodes[24] = new Ten20_node("FC1", -0.23, 0.26);
   Ten20_nodes[25] = new Ten20_node("FCz", 0, 0.25);
   Ten20_nodes[26] = new Ten20_node("FC2", 0.23, 0.26);
   Ten20_nodes[27] = new Ten20_node("FC4", 0.48, 0.27);
   Ten20_nodes[28] = new Ten20_node("FC6", 0.72, 0.29);
   Ten20_nodes[29] = new Ten20_node("FT8", 0.95, 0.33);
   Ten20_nodes[30] = new Ten20_node("T7", -1.0, 0.0);
   Ten20_nodes[31] = new Ten20_node("C5", -0.75, 0.0);
   Ten20_nodes[32] = new Ten20_node("C3", -0.5, 0.0);
   Ten20_nodes[33] = new Ten20_node("C1", -0.25, 0.0);
   Ten20_nodes[34] = new Ten20_node("Cz", 0.0, 0.0);
   Ten20_nodes[35] = new Ten20_node("C2", 0.25, 0.0);
   Ten20_nodes[36] = new Ten20_node("C4", 0.5, 0.0);
   Ten20_nodes[37] = new Ten20_node("C6", 0.75, 0.0);
   Ten20_nodes[38] = new Ten20_node("T8", 1.0, 0.0);
   Ten20_nodes[39] = new Ten20_node("TP7", -0.95, -0.33);
   Ten20_nodes[40] = new Ten20_node("CP5", -0.72, -0.29);
   Ten20_nodes[41] = new Ten20_node("CP3", -0.48, -0.27);
   Ten20_nodes[42] = new Ten20_node("CP1", -0.23, -0.26);
   Ten20_nodes[43] = new Ten20_node("CPz", 0.0, -0.25);
   Ten20_nodes[44] = new Ten20_node("CP2", 0.23, -0.26);
   Ten20_nodes[45] = new Ten20_node("CP4", 0.48, -0.27);
   Ten20_nodes[46] = new Ten20_node("CP6", 0.72, -0.29);
   Ten20_nodes[47] = new Ten20_node("TP8", 0.95, -0.33);
   Ten20_nodes[48] = new Ten20_node("P7", -0.79, -0.62);
   Ten20_nodes[49] = new Ten20_node("P5", -0.62, -0.56);
   Ten20_nodes[50] = new Ten20_node("P3", -0.42, -0.53);
   Ten20_nodes[51] = new Ten20_node("P1", -0.21, -0.51);
   Ten20_nodes[52] = new Ten20_node("Pz", 0.0, -0.51);
   Ten20_nodes[53] = new Ten20_node("P2", 0.21, -0.5);
   Ten20_nodes[54] = new Ten20_node("P4", 0.42, -0.51);
   Ten20_nodes[55] = new Ten20_node("P6", 0.62, -0.53);
   Ten20_nodes[56] = new Ten20_node("P8", 0.79, -0.62);
   Ten20_nodes[57] = new Ten20_node("PO7", -0.57, -0.85);
   Ten20_nodes[58] = new Ten20_node("PO5", -0.45, -0.8);
   Ten20_nodes[59] = new Ten20_node("PO3", -0.3, -0.77);
   Ten20_nodes[60] = new Ten20_node("PO1", -0.15, -0.76);
   Ten20_nodes[61] = new Ten20_node("POz", 0.0, -0.75);
   Ten20_nodes[62] = new Ten20_node("PO2", 0.15, -0.76);
   Ten20_nodes[63] = new Ten20_node("PO4", 0.3, -0.77);
   Ten20_nodes[64] = new Ten20_node("PO6", 0.45, -0.8);
   Ten20_nodes[65] = new Ten20_node("PO8", 0.57, -0.85);
   Ten20_nodes[66] = new Ten20_node("O1", -0.29, -0.95);
   Ten20_nodes[67] = new Ten20_node("Oz", 0.0, -1.0);
   Ten20_nodes[68] = new Ten20_node("O2", 0.29, -0.95);
 }
}