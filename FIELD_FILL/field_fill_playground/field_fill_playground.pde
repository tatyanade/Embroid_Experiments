// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "dense_animated_field"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;
float vectLen = 14;
int rows = 30;
int cols = 30;
int offset = 8;
float circleFrame = 300;



void setup() {
  size(400, 400); //100 px = 1 cm (so 14.2 cm is 1420px)
  // noLoop();
  PEmbroiderStart();
  for(int i = 0; i < 1000000; i++){ 
    println(i);
  }
}

void draw() {
  background(190);
  E.clear();
  E.pushMatrix();
  E.setStitch(20, 70, 0);
  setFieldFill(E, frame*.1, vectLen, MyVecField.NOISE2);
  E.hatchSpacing(10);
  E.fill(0);


  int xOff = width/2-cols*offset/2;
  int yOff = height/2-rows*offset/2;
  E.translate(width/2-cols*offset/2, height/2-rows*offset/2);


  for (int i = 0; i<cols; i++) {
    if (i%2 == 0) {
      for (int j = 0; j<rows; j++) {
        int x = i*offset;
        int y = j*offset;
        PVector vect = E.HATCH_VECFIELD.get(x+xOff, y+yOff);
        doubleStitch(E, x, y, x+vect.x, y+vect.y);
      }
    } else {
      for (int j = rows-1; j>=0; j--) {
        int x = i*offset;
        int y = j*offset;
        PVector vect = E.HATCH_VECFIELD.get(x+xOff, y+yOff);
        doubleStitch(E, x, y, x+vect.x, y+vect.y);
      }
    }
  }
  E.popMatrix(); 
 // PEmbroiderWrite();
  E.visualize(true, true, true);
  frame++;
  circleFrame -= circleFrame/300*10;
  println(frame);
  println(circleFrame);
  println();
  if (frame > 400) {
    exit();
  }
}

void doubleStitch(PEmbroiderGraphics E, float x, float y, float x2, float y2) {
  float xCent = cols*offset/2;
  float yCent = rows*offset/2;
  if (pow(pow(x-xCent, 2)+pow(y-yCent, 2), .5)< circleFrame) {
    E.line(x, y, x2, y2);
    E.line(x2, y2, x, y);
  }
}



void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  E.setStitch(8, 14, 0);
}

void PEmbroiderWrite() {
 // E.visualize(true, true, true);//true, true, true);
  String outputFilePath = sketchPath(fileName+str(frame)+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}




///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {

  MyVecField mvf = new MyVecField(z, len);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}

void setFieldFill(PEmbroiderGraphics E, float z, float len, int mode) {

  MyVecField mvf = new MyVecField(z, len, mode);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd

  float z;
  float len;
  int mode;
  static final int NOISE = 0;
  static final int MOUSE = 1;
  static final int SIN = 2;
  static final int NOISE2 = 3;
  
  
  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
    // println(z);
  }

  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
  }
  public PVector get(float x, float y) {
    switch (mode) {
    case NOISE:
      x*=0.009;
      y*=0.009;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case MOUSE:
      return new PVector(mouseX-x, mouseY-y).normalize().mult(len);
    case SIN:
      x*=0.02;
      y*=0.02;
      return new PVector(cos(x),sin(y)).mult(len);
     case NOISE2: 
      x*=0.008;
      y*=0.008;
      return new PVector(0, len).rotate(noise(x, y, z)*5*PI); 
    }
    return null;
  }
}



////////////////////////////////////////////////////////////////
