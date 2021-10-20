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
String fileName = "loop_circle-1"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;

//Spine trace img
PImage img;


void setup() {
  size(1300, 1200);
  //background(0);
  if (!loop) {
    noLoop();
  }
  img = loadImage("lace_spine_big.png");
  
  
  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this, width, height);
  E.beginDraw();

  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);

  //E.setStitch(20, 40, 0);
  //E.hatchSpacing(18);
  //E.hatchMode(PEmbroiderGraphics.SPIRAL);  

  //E.fill(0, 0, 0);
  //E.noStroke();
  //E.circle(width/2, height/2, 250);
  traceLines(E, img);
  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  PVector pointLoc2 = new PVector();

//  E2.beginShape();
//  // This loop goes through each point on in E and draws a circle on top of them
//  for (int i = 0; i < lenE-1; i++) {
//    pointLoc = getNeedleDown(E, i);
//    pointLoc2 = getNeedleDown(E, i+1);
//    drawLoopLine(pointLoc.x, pointLoc.y, pointLoc2.x, pointLoc2.y,7,,1);
    
//    //E2.circle(pointLoc.x, pointLoc.y, 10);
//  }
//  E2.endShape();


  //E.visualize(true, true, true);
  E.visualize();
  E.endDraw();
  save(fileName+".png"); //saves a png of design from canvas
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
  print("check1");
  for (int i = 0; i < numSteps; i++){
    print("check2");
    float curX = curCX+(r * cos(loopLineAngle));
    float curY = curCY+(r * sin(loopLineAngle));
    print("check3");
    E.vertex(curX, curY);
    circle(curX, curY, 1);
    
    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;
  }

}

//spine
void traceLines(PEmbroiderGraphics E, PImage img){
  
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
  //println(c);
  //println(c.get(0));
  //println(c.get(0).get(0));
  int redValue = 0;
  noStroke();
  println("c.size()");
  println(c.size());
    
  for (int i = 0; i < c.size(); i++) {
    E.beginShape();
    redValue+=1;
    println("c.get(i).size()");
    println(c.get(i).size());
    println(c.get(i));
    
    
    for (int j = 0; j < c.get(i).size() -1; j++) {
      
       print(" ~~ ");
       println(c.get(i).get(j)); 
       int k = j+1;
       
       int x1 = c.get(i).get(j)[0];
       int y1 = c.get(i).get(j)[1];
       int x2 = c.get(i).get(k)[0];
       int y2 = c.get(i).get(k)[1];
       drawLoopLine(x1, y1, x2, y2, 7, 12, .8);
       //println(c.get(i).get(k)); 
     
      //println("c.get(i).get(j).size()");
      //println(c.get(i).get(j).length);
      fill(redValue,255,0);
      circle(c.get(i).get(j)[0], c.get(i).get(j)[1], 2);
      //println(redValue);
      //println(str(c.get(i).get(j)));
      
      //println("");
      
      //drawLoopLine(c.get(i).get(j)[0], c.get(i).get(j)[1], c.get(i).get(j+1)[0], c.get(i).get(j+1)[1],5,20,1);
      //E.vertex(c.get(i).get(j)[0], c.get(i).get(j)[1]);
    }
    E.endShape();
  }
  
}
