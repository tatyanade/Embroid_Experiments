// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "animated_field_stitch"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;



void setup() {
  size(1000, 1000); //100 px = 1 cm (so 14.2 cm is 1420px)
  // noLoop();
  PEmbroiderStart();
}

void draw() {
  background(190);
  E.clear();
  E.pushMatrix();
  E.setStitch(20, 30, 0);
  setFieldFill(E, frame*.01, 20);
  E.hatchSpacing(2);
  E.fill(0);
  E.translate(width/2, height/2);
  int rows = 20;
  int cols = 20;
  int offset = 10;
  
  
  //// begin draw field
pushMatrix();
translate(width/2,height/2);

for (int i = -cols; i<cols; i++) {
      for (int j = -rows; j<rows; j++) {
        int x = i*offset;
        int y = j*offset;
        PVector vect = E.HATCH_VECFIELD.get(x, y);
       // line(x, y, x+vect.x, y+vect.y);
        pushStyle();
        noStroke();
        fill(func_Z(x,y)/50*255);
        println(func_Z(x,y));
        //circle(x,y,offset/2);
        popStyle();
      }
  }
  
  popMatrix();
  
  

 
  
  
  
  //// end draw field
  E.rect(-cols*offset,-rows*offset,cols*offset*2,rows*offset*2);
  //for (int i = -cols; i<cols; i++) {
  //  if (i%2 == 0) {
  //    for (int j = -rows; j<rows; j++) {
  //      int x = i*offset;
  //      int y = j*offset;
  //      PVector vect = E.HATCH_VECFIELD.get(x, y);
  //      doubleStitch(E, x, y, x+vect.x, y+vect.y);
  //    }
  //  } else {
  //    for (int j = rows-1; j>=-rows; j--) {
  //      int x = i*offset;
  //      int y = j*offset;
  //      PVector vect = E.HATCH_VECFIELD.get(x, y);
  //      doubleStitch(E, x, y, x+vect.x, y+vect.y);
  //    }
  //  }
  //}
  E.popMatrix(); 
  PEmbroiderWrite();
  E.visualize(true, false, false);
  frame++;
  if (frame > 30) {
    //exit();
  }
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

  MyVecField mvf = new MyVecField(z, len,2);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd

  float z;
  float len;
  int mode;
  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
    // println(z);
  }

  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
    // println(z);
  }

  public PVector get(float x, float y) {
    switch(mode) {
    case 0:
      x*=0.01;
      y*=0.01;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case 1:
     // println(gradient(x,y));
      return gradient(x,y).mult(10);
    case 2: 
       return gradient(x,y).normalize().rotate(PI/2).mult(10);
    }
    return null;
  }
}



////////////////////////////////////////////////////////////////


float func_Z(float x, float y) {
  float x_offset = noise(frame*.05)*100.00;
  float y_offset = noise(0,frame*.05)*100.00;
  return noise(x*.008,y*.008)*50;//pow(pow(x-x_offset,2) + pow(y-y_offset,2),.5);
}


PVector gradient(float x, float y){
  float h = .1;
  
  float df_dx= (func_Z(x+h,y)-func_Z(x,y))/h;
  float df_dy= (func_Z(x,y+h)-func_Z(x,y))/h;
  PVector vect = new PVector(df_dx,df_dy);
  
//  println(vect);
 // println(func_Z(x,y+h)-func_Z(x,y));
  return vect;
}
