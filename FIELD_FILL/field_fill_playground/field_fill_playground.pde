// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "animated_field_stitch"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;



void setup() {
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
  // noLoop();
  PEmbroiderStart();
}

void draw() {
  background(190);
  E.clear();
  E.pushMatrix();
  E.setStitch(20, 30, 0);
  setFieldFill(E, frame*.01, 20);
  E.hatchSpacing(10);
  E.fill(0);
  E.translate(width/4, height/4);
  int rows = 20;
  int cols = 20;
  int offset = 14;
  
  
  for (int i = 0; i<cols; i++) {
    if (i%2 == 0) {
      for (int j = 0; j<rows; j++) {
        int x = i*offset;
        int y = j*offset;
        PVector vect = E.HATCH_VECFIELD.get(x, y);
        doubleStitch(E,x, y, x+vect.x, y+vect.y);
      }
    } else {
        for (int j = rows-1; j>=0; j--) {
        int x = i*offset;
        int y = j*offset;
        PVector vect = E.HATCH_VECFIELD.get(x, y);
        doubleStitch(E,x, y, x+vect.x, y+vect.y);
      }
    }
  }
  E.popMatrix(); 
  PEmbroiderWrite();
  E.visualize(true, true, true);
  frame++;
  if(frame > 10){
    exit();
  }
}

void doubleStitch(PEmbroiderGraphics E, float x, float y, float x2, float y2){
  E.line(x,y,x2,y2);
  E.line(x2,y2,x,y);
}



void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  E.setStitch(8, 14, 0);
}

void PEmbroiderWrite() {
  E.visualize(true, true, true);//true, true, true);
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



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd

  float z;
  float len;
  MyVecField(float z, float len) {
    this.z = z;
    this.len = len;
    // println(z);
  }
  public PVector get(float x, float y) {
    x*=0.01;
    y*=0.01;
    return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
  }
}



////////////////////////////////////////////////////////////////
