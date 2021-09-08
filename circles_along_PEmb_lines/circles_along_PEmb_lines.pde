// Circles Along PEmbroider Path
//   
// In this code uses two PEmbroiderGraphics objects. 
// We create a path in the first object, E, and then step through the points in E.
// At each point in E we draw a cirlce in E2 so that we end up with a shape filled with circles
//
// E is just a refference object and E2 writes out


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
PEmbroiderGraphics E2;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "circ_along_Pemb_path"; // CHANGE ME


void setup() {
  size(800, 800);

  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();
  
  E2 = new PEmbroiderGraphics(this, width, height);
  E2.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  E2.setPath(outputFilePath);

  E.setStitch(10, 20, 0);
  E.hatchSpacing(8);
  E.hatchMode(PEmbroiderGraphics.SPIRAL);  

  E.noStroke();
  E.fill(0, 0, 0);
  E.noStroke();
  E.circle(width/2,height/2, 250);
  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  
  
  // This loop goes through each point on in E and draws a circle on top of them
  for(int i = 0; i < lenE; i++){
    pointLoc = getNeedleDown(E,i);
    E2.circle(pointLoc.x,pointLoc.y,10);
  }
  

  E.visualize(true,true,true);
  E2.visualize();
  E2.endDraw();
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
