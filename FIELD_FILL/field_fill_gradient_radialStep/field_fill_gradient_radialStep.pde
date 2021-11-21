// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "animated_field_stitch"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;
int MODE = 2;
 int stepsMax = 3;
 
PVector center = new PVector(0, 0);



void setup() {
  size(1000, 1000); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();

 
}

void draw() {
  background(180);
  E.clear();
  E.pushMatrix();
  E.setStitch(20, 30, 0);
  setFieldFill(E, frame*.01, 20);
  E.hatchSpacing(2);
  PVector centerPoint = new PVector(width/2, height/2);
  E.fill(0);
  
  E.stroke(0);
  float arLen = 10;
  float theta = 0;
  float r_0 = 20;
  float r = r_0;
  float thetaStep = arLen/r_0;
  
  for (int i = 0;i<600; i++) {
        int x = int((r)*cos(theta))+int(centerPoint.x);
        int y = int((r)*sin(theta))+int(centerPoint.y);
        PVector vect = E.HATCH_VECFIELD.get(x, y);
        vectorTrace(E, x, y, x+vect.x, y+vect.y, 1);
        theta += thetaStep;
        r = theta*3+r_0;
        thetaStep = arLen/r; 
  }

  E.popMatrix(); 
  E.visualize(true, true, false);
}

void vectorTrace(PEmbroiderGraphics E, float x, float y, float x2, float y2, int n) {
  if (n>stepsMax) {
    return;
  }
  E.line(x, y, x2, y2);
  PVector vect = E.HATCH_VECFIELD.get(x2, y2);
  vectorTrace(E, x2, y2, x2+vect.x, y2+vect.y, n+1);
  E.line(x2, y2, x, y);
}




void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  E.setStitch(8, 14, 0);
}

void PEmbroiderWrite() {
  String outputFilePath = sketchPath(fileName+str(int(frame))+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}

void mouseClicked(){
center = new PVector(mouseX,mouseY);
}



///////////////////////////////////////////////////////////
///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {
  MyVecField mvf = new MyVecField(z, len, 2);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  float z;
  float len;
  int mode;
  float thetaMultiplier = .03;
  float radialMultiplier = .02;
  float noiseMultiplier = 3;
  boolean set = false;

  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
    set = true;
  }

  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
  }

  public PVector get(float x, float y) {
    pushStyle();
    stroke(100);
    fill(100);
    popStyle();

    PVector centerPoint = null; // vector that points to the center
    switch(MODE) {
    case 0:
      x*=0.01;
      y*=0.01;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case 1:
      centerPoint = center.copy().sub(x, y);
      if (centerPoint.mag() < 5) {
        return new PVector(0, 0);
      }
      centerPoint.normalize().mult(len).rotate(PI/2);//.rotate(PI/2);
      return centerPoint;
    case 2:
      centerPoint = center.copy().sub(x, y);
      if (centerPoint.mag() < 5) {
        return new PVector(0, 0);
      }

      float heading = centerPoint.heading();
      float mag = centerPoint.mag();

      float noiseVal = (noise(sin(heading)*thetaMultiplier, mag*radialMultiplier)-.5)*noiseMultiplier;
      centerPoint.normalize().mult(-len).rotate(noiseVal);
      return centerPoint;
    }
    return null;
  }
}

//////////////////////////////////
//////////////////////////////////

////////////////////////////////////////////////////////////////


float func_Z(float x, float y) {
  float x_offset = (noise(frame*.05)-.5)*200.00;
  float y_offset = (noise(0, frame*.05)-.5)*200.00;
  return pow(pow(x-x_offset, 2) + pow(y-y_offset, 2), .5);
}


PVector gradient(float x, float y) {
  float h = .1;

  float df_dx= (func_Z(x+h, y)-func_Z(x, y))/h;
  float df_dy= (func_Z(x, y+h)-func_Z(x, y))/h;
  PVector vect = new PVector(df_dx, df_dy);
  return vect;
}
