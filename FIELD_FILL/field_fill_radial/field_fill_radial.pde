// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "field_fill1"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;



void setup() {
  size(1000, 1000); //100 px = 1 cm (so 14.2 cm is 1420px)
  // noLoop();
  PEmbroiderStart();
  E.clear();
  E.pushMatrix();
  E.translate(width/2,height/2);

  setFieldFill(E, frame*.01, 20);
  E.noStroke();
  E.fill(0);
  int rows = 20;
  int cols = 20;
  int offset = 10;
 
  
  
  
  E.hatchSpacing(10);
  E.setStitch(15, 30, 0);
  E.beginOptimize();
  E.rectMode(CENTER);
  E.rect(0,0,400,400);
  E.endOptimize();
  E.optimize(20,2000);
 
  E.fill(30);
  E.setStitch(70, 120, 0);
  E.hatchSpacing(5);
  E.beginOptimize();
  E.rectMode(CENTER);
  E.rect(0,0,400,400);
  E.endOptimize();
  
  
  E.popMatrix();
  PEmbroiderWrite();
  E.visualize(true, true, true);
}

void draw() {

}

void doubleStitch(PEmbroiderGraphics E, float x, float y, float x2, float y2) {
  E.line(x, y, x2, y2);
  E.line(x2, y2, x, y);
}



void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  E.setStitch(8, 14, 0);
}

void PEmbroiderWrite() {
///  E.visualize(true, true, true);//true, true, true);
  String outputFilePath = sketchPath(fileName+str(int(frame))+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}




///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {

  MyVecField mvf = new MyVecField(z, len,1);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd
  PVector center = new PVector(width/2,height/2);
  float z;
  float len;
  int mode;
  float minX = 10000;
  float minY = 10000;
  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
  }

  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
  }

  public PVector get(float x, float y) {
    switch(mode) {
    case 0:
      x*=0.01;
      y*=0.01;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case 1:
       x=x-10+width/2-200;
       y=y-10+height/2-200;
       if(minX>x){
         minX = x;
       }
       if(minY>y){
         minY=y;
       }
       PVector centerPoint = center.copy().sub(x,y);//.normalize().mult(10);//.rotate(PI/2);
       if(centerPoint.mag() < 5){
         return new PVector(0,0);
       }
       centerPoint.normalize().mult(10);
       println(centerPoint);
       return centerPoint;
       
    }
    return null;
  }
}



///////////////////////////////////////////////////////////////
