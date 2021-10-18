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
String fileName = "loop_circle-1"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;


void setup() {
  size(800, 800);
  if (!loop) {
    noLoop();
  }
  
  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();

  E2 = new PEmbroiderGraphics(this, width, height);
  E2.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  E2.setPath(outputFilePath);

  E.setStitch(20, 40, 0);
  E.hatchSpacing(18);
  E.hatchMode(PEmbroiderGraphics.SPIRAL);  

  E.fill(0, 0, 0);
  E.noStroke();
  E.circle(width/2, height/2, 250);
  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  PVector pointLoc2 = new PVector();

  E.beginShape();
  // This loop goes through each point on in E and draws a circle on top of them
  for (int i = 0; i < lenE-1; i++) {
    pointLoc = getNeedleDown(E, i);
    pointLoc2 = getNeedleDown(E, i+1);
    drawLoopLine(pointLoc.x, pointLoc.y, pointLoc2.x, pointLoc2.y,10,50,1);
    
    //E2.circle(pointLoc.x, pointLoc.y, 10);
  }
  E.endShape();


  E.visualize(true, true, true);
  E2.visualize();
  E2.endDraw();
  save(fileName+".png"); //saves a png of design from canvas
}


void draw() {
  if (loop) {
    background(100);
    E2.visualize(true, true, true, frame);
    frame ++;
    delay(40);
  }
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

////////////////////// LOOP HELPERS ////////////////////////////////////////////////////////
float loopLineAngle = PI/2;

void drawLoopLine(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap){  
  float r = circleRad;
  float cx = startX;
  float cy = startY;
  
  float lineLength = dist(startX, startY, endX, endY);
  float numCycles = (lineLength/r)*(1/overlap);

  float angleDifference = stitchLength/r;
  float pointsPerCircle = TWO_PI/angleDifference;
  float numSteps = pointsPerCircle*numCycles ;
  
  float dx = (endX-startX)/ numSteps;
  float dy = (endY-startY)/ numSteps;
  
  float curCX = cx;
  float curCY = cy;
  for (int i = 0; i < numSteps; i++){
    float curX = curCX+(r * cos(loopLineAngle));
    float curY = curCY+(r * sin(loopLineAngle));
    
    E.vertex(curX, curY);
    circle(curX, curY, 1);
    
    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;
  }

}
