// Circles Along PEmbroider Path
//   
// In this code uses two PEmbroiderGraphics objects. 
// We create a path in the first object, E, and then step through the points in E.
// At each point in E we draw a cirlce in E2 so that we end up with a shape filled with circles
//
// E is just a refference object and E2 writes out



/// EMBROIDOTRON SETUP ///
import processing.serial.*;
Serial arduino; 
int s1 = 0;
int s2 = 0;
int totalSteps = 0;
PVector zeroPoint;

/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
PEmbroiderGraphics E2;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// DEBUGGING BOOLEANS ///
boolean doSend = true; // for testing without actually sending points set to false (motors will not move if false)
boolean serialConnected = true; // for testing without connection to arduino set to false 
boolean penPlotter = false;


void setup() {
  size(800, 800);

  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();
  
  E2 = new PEmbroiderGraphics(this, width, height);
  E2.beginDraw();

  E.setStitch(10, 20, 0);
  E.hatchSpacing(8);
  E.hatchMode(PEmbroiderGraphics.SPIRAL);  

  E.noStroke();
  E.fill(0, 0, 0);
  E.pushMatrix();
  E.noStroke();
  E.circle(width/2,height/2, 250);
  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  // This function will go through each point on the PEmbroiderGraphics object and modify or draw based on those points
  // 
  for(int i = 0; i < lenE; i++){
    pointLoc = getNeedleDown(E,i);
    point(pointLoc.x,pointLoc.y);
    E2.circle(pointLoc.x,pointLoc.y,10);
  }
  
  E.popMatrix();
  

  E.visualize(true,true,true);
  E2.visualize();
}


void draw() {
  
;
}






////////////////////// NEEDLE DOWN HELPERS ////////////////////////////////////////////////////////////

PVector getNeedleDown(PEmbroiderGraphics E, int ndIndex) {
  //get the ith needle down
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      if (n >= ndIndex) {
        return needleLoc;
      }
      n++;
    }
  }
  return null; //will return null if the index is outside the needle down list
}

int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      n++;
    }
  }
  return n;
}

////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
