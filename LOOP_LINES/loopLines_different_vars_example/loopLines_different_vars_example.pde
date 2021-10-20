// Circles Along PEmbroider Path
//   


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "loop_lines_test_sheet"; // CHANGE ME

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
  String outputFilePath = sketchPath(fileName+fileType);
  E.setStitch(20, 40, 0);
  E.hatchSpacing(18);
  E.hatchMode(PEmbroiderGraphics.SPIRAL);  

  E.fill(0, 0, 0);

  //changing stitchlength
  int numRows = 15;
  for (int i = 0; i < numRows; i ++){
    int x = 50;
    int y = 40 + 50*i;
    drawLoopLine(x, y, x + 200, y , 3+i*2, 10, .8);
  }
  
  //changing overlap value 
  for (int i = 0; i < numRows; i ++){
    int x = 300;
    int y = 40 + 50*i;
    drawLoopLine(x, y, x + 200, y , 8, 10, .5 + i*.1);
  }
  
    //changing overlap value 
  for (int i = 0; i < numRows; i ++){
    int x = 550;
    int y = 40 + 50*i;
    drawLoopLine(x, y, x + 200, y , 8, 5 + i, .8);
  }

  //E.optimize();
  E.visualize(true, true, true);
  E.endDraw();
  save(fileName+".png"); //saves a png of design from canvas
}


////////////////////// LOOP HELPERS ////////////////////////////////////////////////////////
float loopLineAngle = PI/2;

void drawLoopLine(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap){  
  E.beginShape();
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
    E.endShape();

}
