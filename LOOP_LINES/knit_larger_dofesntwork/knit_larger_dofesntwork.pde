// Circles Along PEmbroider Path
//   


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "knit_test"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = true;//false;
int frame = 0;
int overlaps = 0;


void setup() {
  size(1200, 900);
  if (!loop) {
    noLoop();
  }
  
  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  
  E.setPath(outputFilePath); 

  E.setStitch(20, 40, 0);
  E.hatchSpacing(18);
  E.hatchMode(PEmbroiderGraphics.SPIRAL);  
  E.fill(0, 0, 0);
  int ystart = 40;

  //changing stitchlength
  int numRows = 20;
  
  ystart +=0;
  for (int i = 0; i < numRows; i ++){
    int x = 50;
    ystart +=20;
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.5);
  }
  
  //ystart += 20;
  //numRows = 10;
  for (int i = 0; i < numRows; i ++){
    int x = 50;
    ystart +=20;    
    //1.8 - 1.803 throws error
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.805);
  }
  ystart +=40;
  
ystart = 40;
 
  //ystart += 20;
  //numRows = 10;
  for (int i = 0; i < numRows; i ++){
    int x = 550;
    ystart +=20;    
    //1.8 - 1.803 throws error
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.805);
  }
    for (int i = 0; i < numRows; i ++){
    int x = 550;
    ystart +=20;
    drawLoopLine(x, ystart, x + 500, ystart ,7, 20, 1.5);
  }
 
//    for (int i = 0; i < numRows; i ++){
//    int x = 50;
//    ystart +=15;
//    //1.8 - 1.803 throws error
//    drawLoopLine(x, ystart, x + 500, ystart ,7, 10, 1.805);
//  }

  //E.optimize();
  E.visualize(true, true, true);
  E.endDraw();
  save(fileName+".png"); //saves a png of design from canvas
  
}

void draw(){
 background(100);
 E.visualize(true,true,true,frameCount);
}


////////////////////// LOOP HELPERS ////////////////////////////////////////////////////////
float loopLineAngle;// = PI/2;

void drawLoopLine(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap){  
  loopLineAngle =3 * PI/2;// 3*PI/4;
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
    E.beginShape();

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
