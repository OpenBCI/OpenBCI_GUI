import controlP5.*;

String[][] s = new String[3][];
ControlP5 controlP5;
ListBox l;

void setup() {
  size(400,400);
  controlP5 = new ControlP5(this);
  l = controlP5.addListBox("myList",100,100,120,150);
  // l.actAsPulldownMenu(true);
  l.setItemHeight(23);
  
  
  s[0] = new String[] {
    "a","b","c","d"
  };
  s[1] = new String[] {
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n"
  };
  s[2] = new String[] {
    "l","m","n"
  };
  
  for(int i=0;i<s[1].length;i++) {
    l.addItem(s[1][i],i);
  }
}


void draw() {
  background(0);
}

void keyPressed() {

  switch(key) {
    case('1'):
    println("changing list to items of group 1");
    l.clear();
    for(int i=0;i<s[0].length;i++) {
      // using bit shifting to store 2 values in 1 int
      int n = 0;
      n = n | 1 << 8;  
      n = n | i << 0; 
      l.addItem("1-"+s[0][i],n);
    }
    break;
    case('2'):
    println("changing list to items of group 2");
    l.clear();
    for(int i=0;i<s[1].length;i++) {
      // useing bit shifting to store 2 values in 1 int
      int n = 0;
      n = n | 2 << 8;  
      n = n | i << 0; 
      l.addItem("2-"+s[1][i],n);
    }
    break;
  }
}

void myList(int theValue) {
  println("from myList "+theValue);
}


void controlEvent(ControlEvent theEvent) {
  if(theEvent.isGroup()) {
  print("> "+theEvent.getGroup().getValue());
  int n = int(theEvent.getGroup().getValue());
  println("\t\t group:"+(n >> 8 & 0xff)+", item:"+(n >> 0 & 0xff));
  }
}
