/**
 * ControlP5 KeyEventAndWheel
 *
 * with controlP5 2.0 all java.awt dependencies have been removed
 * as a consequence the option to use the MouseWheel for some controllers
 * has been removed. But the following example shows how to manually add
 * the mouseWheel support.
 *
 * With early versions of the processing 2.0 beta releases the keyEvent forwarding
 * does not work as expected and needs to be forwarded manually. 
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */


import controlP5.*;
import java.util.*;

ControlP5 cp5;

void setup() {
  size(700, 300);
  cp5 = new ControlP5(this);


  cp5.addNumberbox("numberbox")
     .setPosition(20, 20)
     .setSize(100, 20)
     ;

  cp5.addSlider("slider")
     .setPosition(20, 70)
     .setSize(200, 20)
     ;

  cp5.addKnob("knob")
     .setPosition(20, 120)
     .setRadius(50)
     ;

  List<String> drops = new ArrayList<String>();
  for(int i=0;i<100;i++) {
    drops.add("item "+i);
  }
  
  cp5.addDropdownList("drop")
     .setPosition(300, 30)
     .setWidth(200)
     .addItems(drops)
     ;
  
  cp5.addListBox("list")
     .setPosition(520, 30)
     .setSize(150,200)
     .addItems(drops)
     ;
     
  cp5.addTextarea("area")
     .setPosition(300, 150)
     .setSize(200,100)
     .setLineHeight(10)
     .setText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam feugiat porttitor tempus. Donec hendrerit aliquam mauris, a interdum ante pellentesque et. In dui erat, condimentum et sodales eget, scelerisque quis libero. Nam non nibh vitae enim auctor fringilla sit amet quis magna. Quisque ultricies mi at arcu vulputate imperdiet tristique purus adipiscing. Maecenas pretium odio ac leo aliquam id commodo nulla eleifend. Aenean in pharetra mauris. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nulla suscipit, nisl vitae eleifend tincidunt, dolor justo sollicitudin nunc, sit amet rhoncus odio purus eu purus. Cras bibendum placerat elementum. Donec in lorem libero. Praesent auctor, felis quis volutpat facilisis, neque turpis tempor nisi, interdum viverra enim purus vel mi. Nam faucibus accumsan lorem, convallis consectetur elit vulputate ut.");
     ;
  // add mousewheel support, now hover the slide with your mouse
  // and use the mousewheel (or trackpad on a macbook) to change the 
  // value of the slider.   
  addMouseWheelListener();
}


void draw() {
  background(0);
} 


void controlEvent(ControlEvent event) {
  println(event);
}

// When working in desktop mode, you can add mousewheel support for 
// controlP5 by using java.awt.event.MouseWheelListener and 
// java.awt.event.MouseWheelEvent

void addMouseWheelListener() {
  frame.addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent e) {
      cp5.setMouseWheelRotation(e.getWheelRotation());
    }
  }
  );
}

