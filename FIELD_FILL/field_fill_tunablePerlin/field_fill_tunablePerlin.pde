// implements a version of Perlin fill that adds an additional 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "FrenchKnotty_Packed4"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;



void setup(){
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
 // noLoop();
  PEmbroiderStart();
  background(180);
  E.clear();
  E.pushMatrix();
  E.setStitch(15,25,0);
  setFieldFill(E,2);
  E.hatchSpacing(10);
  E.fill(0);
  E.translate(width/2,height/2);
  E.rect(-100,-100,200,200);
 // println(E.HATCH_VECFIELD.get(width/2,height/2));
  E.popMatrix();
  E.visualize(true,false,false);
  
  
    
}

void draw(){
;
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

void setFieldFill(PEmbroiderGraphics E, float z) {
 
  MyVecField mvf = new MyVecField(z);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd
  float z;
  MyVecField(float z) {
    this.z = z;
  }
  public PVector get(float x, float y) {
    x*=0.01;
    y*=0.01;
    return new PVector(0, 10).rotate(noise(x,y,this.z)*PI*2);
  }
}



////////////////////////////////////////////////////////////////
