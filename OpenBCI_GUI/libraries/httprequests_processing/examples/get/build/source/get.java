import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import http.requests.*; 
import http.requests.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class get extends PApplet {



public void setup()
{
	
	

	GetRequest get = new GetRequest("https://github.com/OpenBCI/OpenBCI_GUI/tags");
	get.send();
	println("Reponse Content: " + get.getContent());
	println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
}


public void setup()
{
	size(400,400);
	smooth();

	GetRequest get = new GetRequest("https://github.com/OpenBCI/OpenBCI_GUI/tags");
	get.send();
	//println("Reponse Content: " + get.getContent());
	//println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
	output = createWriter("openBCIreleases.txt");
	output.println(get.getContent());

}

public void keyPressed() {
	output.flush();
	output.close();
	exit();
}
  public void settings() { 	size(400,400); 	smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "get" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
