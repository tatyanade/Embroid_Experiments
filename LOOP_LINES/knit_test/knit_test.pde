// Circles Along PEmbroider Path
//   


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "knit_test-silly"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;


void setup() {
  size(600, 900);
  if (!loop) {
    noLoop();
  }
  
  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  E.setStitch(20, 40, 0);
  E.hatchSpacing(18);
  E.hatchMode(PEmbroiderGraphics.SPIRAL);  
   E.beginShape();
  E.fill(0, 0, 0);
  int ystart = 40;

  //changing stitchlength
  int numRows = 8;
  
  
  for (int i = 0; i < 6; i ++){
    int x = 50;
    ystart +=30;    
    //1.8 - 1.803 throws error
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, .905);
  }
  ystart += 40;
  for (int i = 0; i < numRows; i ++){
    int x = 50;
    ystart +=20;
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.5);
  }
  
  ystart += 40;
  //numRows = 10;
  for (int i = 0; i < numRows; i ++){
    int x = 50;
    ystart +=20;    
    //1.8 - 1.803 throws error
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.805);
  }
  ystart +=40;
  
  numRows = 6;
  for (int i = 0; i < numRows; i ++){
    int x = 50;
    ystart +=30;    
    //1.8 - 1.803 throws error
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.805);
  }
  ystart +=60;
  

  
  //  for (int i = 0; i < numRows; i ++){
  //  int x = 50;
  //  ystart +=15;
  //  //1.8 - 1.803 throws error
  //  drawLoopLine(x, ystart, x + 500, ystart ,7, 10, 1.805);
  //}

  E.endShape();
  E.optimize();
  E.visualize(true, true, true);
  E.endDraw();
  save(fileName+".png"); //saves a png of design from canvas
  
}


////////////////////// LOOP HELPERS ////////////////////////////////////////////////////////
float loopLineAngle = PI/2;

void drawLoopLine(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap){  
  loopLineAngle = PI/2;
  //E.beginShape();
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
    //circle(curX, curY,2);
    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;
  }
  //  E.endShape();

}
