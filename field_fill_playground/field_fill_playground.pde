// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "FrenchKnotty_Packed4"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;



void setup(){
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
 // noLoop();
  PEmbroiderStart();
  
  

  
  
  //E.pushMatrix();
  //setFieldFill(E,PI/4,10);
  //E.hatchSpacing(10);
  //E.fill(0);
  //E.translate(width/2,height/2);
  //E.rect(-100,-100,200,200);
  //println(E.HATCH_VECFIELD.get(width/2,height/2));
  //E.popMatrix();
  
  
    
}

void draw(){
  background(180);
  E.clear();
  E.pushMatrix();
  E.setStitch(20,30,0);
  setFieldFill(E,frame*.01,10);
  E.hatchSpacing(10);
  E.fill(0);
  E.translate(width/2,height/2);
  E.rect(-100,-100,200,200);
 // println(E.HATCH_VECFIELD.get(width/2,height/2));
  E.popMatrix();
  E.visualize(true,false,false);
  
  frame++;
}



void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(8, 14, 0);
}

void PEmbroiderWrite() {
  E.visualize(true, true, true);//true, true, true);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}

  
  
  
  ///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {
 
  MyVecField mvf = new MyVecField(z,len);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd
  
  float z;
  float len;
  MyVecField(float z,float len) {
    this.z = z;
    this.len = len;
   // println(z);
  }
  public PVector get(float x, float y) {
    x*=0.05;
    y*=0.05;
    return new PVector(0, len).rotate(y+z);
  }
}



////////////////////////////////////////////////////////////////
