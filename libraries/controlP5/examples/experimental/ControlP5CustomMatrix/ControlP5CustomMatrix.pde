import controlP5.*;

ControlP5 cp5;

void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);
  int x = 20;
  int y = 8; 
  // init our CustomMatrix
  CustomMatrix m = new CustomMatrix(cp5, "matrix");
  // set parameters for our CustomMatrix
  m.setPosition(50, 100)
  .setSize(200, 200)
  .setInterval(200)
  .setGrid(x,y)
  .setMode(ControlP5.MULTIPLES)
  .setColorBackground(color(120))
  .setBackground(color(40));
  
  // initialize the presets for the CustomMatrix
  m.initPresets();
  
}

void draw() {
  background(0);
}

// function called by our CustomMatrix with name matrix
public void matrix(int x, int y) {
  println("trigger", x, y);
}


// extend the Matrix class since we need to override the Matrix's sequencer
class CustomMatrix extends Matrix {
  
  // add a list to store some presets
  ArrayList<int[][]> presets = new ArrayList<int[][]>();
  int currentPreset = 0;
  Thread update;

  CustomMatrix(ControlP5 cp5, String theName) {
    super(cp5, theName);
    stop(); // stop the default sequencer and
    // create our custom sequencer thread. Here we 
    // check if the sequencer has reached the end and if so
    // we updated to the next preset.
    update = new Thread(theName) {
      public void run( ) {
        while ( true ) {
          cnt++;
          cnt %= _myCellX;
          if (cnt==0) {
            // we reached the end and go back to start and 
            // update the preset 
            next();
          }
          trigger(cnt);
          try {
            sleep( _myInterval );
          } 
          catch ( InterruptedException e ) {
          }
        }
      }
    };
    update.start();
  }
  
  
  void next() {
    currentPreset++;
    currentPreset %= presets.size();
    setCells(presets.get(currentPreset));
  }

  // initialize some random presets.
  void initPresets() {
    for (int i=0;i<4;i++) {
      presets.add(createPreset(_myCellX, _myCellY));
    }
    setCells(presets.get(0));
  }
  
  // create a random preset
  int[][] createPreset(int theX, int theY) {
    int[][] preset = new int[theX][theY];
    for (int x=0;x<theX;x++) {
      for (int y=0;y<theY;y++) {
        preset[x][y] = random(1)>0.5 ? 1:0;
      }
    }
    return preset;
  }
  
}

