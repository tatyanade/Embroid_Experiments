// Circles Along PEmbroider Path
//   


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "knit_large_loose"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;


void setup() {
  size(1000, 1000);
  if (!loop) {
    noLoop();
  }
  
  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath); 
  
  E.setStitch(20, 40, 0);
  E.noFill();
  
  loopRect(100,100,600,600,10,20,1,1);
  
  //E.optimize();
  E.visualize(true, true, true);
  //E.endDraw();
  //save(fileName+".png"); //saves a png of design from canvas
  
}

//void draw(){
// background(100);
// E.visualize(true,true,true,frameCount);
//}

void loopRect(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap, float rowOverlap){
  rect(startX, startY, endX, endY);
  float rectWidth = endX-startX;
  float rectHeight = endY - startY;
  
  float ystart = startY;
  
  float numRows = rectWidth/(circleRad*2)/rowOverlap;
   
    for (float i = 0; i < numRows; i ++){
      float x = startX + circleRad;
      ystart += rowOverlap*circleRad;    
      drawLoopLine(startX, ystart, x + (endX-startX), ystart ,10, 30, 1.5);
    }
  
  
  
}



////////////////////// LOOP HELPERS ////////////////////////////////////////////////////////
float loopLineAngle = PI;

void drawLoopLine(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap){  
  loopLineAngle = 0;//PI/2;
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
    circle(curX, curY,2);
    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;

  }
      E.endShape();

}
