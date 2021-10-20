// Circles Along PEmbroider Path
//   
// In this code uses two PEmbroiderGraphics objects. 
// We create a path in the first object, E, and then step through the points in E.
// At each point in E we draw a cirlce in E2 so that we end up with a shape filled with circles
//
// E is just a refference object and E2 writes out
import traceskeleton.*;


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "lace_transparent_rats_opt"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;

//Spine trace img
PImage img1;
PImage img2;
PImage img3;
PImage img4;
PImage img5;
PImage img6;

void setup() {
  size(1300, 1200);
  //background(0);
  if (!loop) {
    noLoop();
  }
  img1 = loadImage("algo-1-big.png");
  img2 = loadImage("algo-2-big.png");
  img3 = loadImage("algo-3-big.png");
  img4 = loadImage("algo-4-big.png");
  img5 = loadImage("algo-5-big.png");
  img6 = loadImage("algo-eyes.png");
  
  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();

  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);

  traceLines(E, img5, 5, 3, 3);
  traceLines(E, img4, 4, 4, 2);
  traceLines(E, img3, 7, 6, 1.2);
  traceLines(E, img2, 7, 6, .9);
  traceLines(E, img1, 7, 12, .8);
  noStroke();
  fill(0);
    E.hatchMode(PEmbroiderGraphics.CROSS); 
E.hatchSpacing(4);
  //E.image(img6, 0,0);

  //E.optimize();
  checkStitchDens(E);
  //E.visualize();
  //E.endDraw();
  //save(fileName+".png"); //saves a png of design from canvas
}


void draw() {
  if (loop) {
    background(100);
    E.visualize(true, true, true, frame);
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

//void loopLineImage(PImage img, float stitchLength, float circleRad, float overlap){
  

//}


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

//spine
void traceLines(PEmbroiderGraphics E, PImage img, float stitchLength, float circleRad, float overlap){
  
  E.noFill();
  E.stroke(155);
  
   
  int W = img.width;
  int H = img.height;
  boolean[] im = new boolean[W*H];
  img.loadPixels();
  for (int i=0; i<im.length; i++) {
    im[i] = (img.pixels[i]>>16 & 0xFF)>128;
  }
  
  // Trace the skeletons in the pixels.
  ArrayList<ArrayList<int[]>>  c;
  TraceSkeleton.thinningZS(im, W, H);
  c = TraceSkeleton.traceSkeleton(im, W, H, 0, 0, W, H, 10, 999, null);

  // Fetch every vertex from the arrays produced by the tracer;
  // Add them to some PEmbroider shapes. 

  int redValue = 0;
  noStroke();
    
  for (int i = 0; i < c.size(); i++) {
    E.beginShape();
    redValue+=1;

    
    
    for (int j = 0; j < c.get(i).size() -1; j++) {

       int k = j+1;
       
       int x1 = c.get(i).get(j)[0];
       int y1 = c.get(i).get(j)[1];
       int x2 = c.get(i).get(k)[0];
       int y2 = c.get(i).get(k)[1];
       drawLoopLine(x1, y1, x2, y2, stitchLength,  circleRad,  overlap );

      fill(redValue,255,0);
      circle(c.get(i).get(j)[0], c.get(i).get(j)[1], 2);

    }
    E.endShape();
  }
  
}










void checkStitchDens(PEmbroiderGraphics E) {
  int rows = height/10;
  int cols = width/10;
  float heightOffset = height/rows;
  float widthOffset = width/cols;
  
  println("Sample size:");
  println(str(widthOffset) + " x " + str(heightOffset));
  int stitchCounters[][] = new int[rows][cols];

  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  int maxStitches = 0;

  // This loop goes through each point on in E counts how many times the needle down falls within a certain stitch counter
  for (int i = 0; i < lenE; i++) {
    pointLoc = getNeedleDown(E, i);
    int col = int(pointLoc.x/widthOffset);
    int row = int(pointLoc.y/heightOffset);
    stitchCounters[row][col]++;
  }

  for (int row=0; row < rows; row ++) {
    for (int col=0; col < cols; col++) {
      int r = int(float(stitchCounters[row][col])*10);
      if(maxStitches<stitchCounters[row][col]){
        maxStitches =stitchCounters[row][col];
      }
      noStroke();
      fill(r, 0, 0);
      rect(col*widthOffset, row*heightOffset, widthOffset, heightOffset);
    }
  }
  
  
  for (int i = 0; i < lenE; i++) {
    pointLoc = getNeedleDown(E, i);
    fill(255);
    stroke(255,255,255,40);
    point(pointLoc.x,pointLoc.y);
  }
  
  println("Max Stitches:");
  println(maxStitches);
}
