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
String fileName = "Bitmap"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;


void setup() {
  size(1000, 500);
  if (!loop) {
    noLoop();
  }

  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------
  E = new PEmbroiderGraphics(this,10,10);
  E.beginDraw();

  E2 = new PEmbroiderGraphics(this, width, height);
  E2.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  E2.setPath(outputFilePath);
  
  int circleDiam = 16;
  bitmapImage(E);
  E.optimize();

  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  
  E2.fill(150,20,20);
  E2.setStitch(20,25,.1);
  E2.hatchMode(E2.CROSS);
  E2.hatchSpacing(20);
 // E2.strokeWeight(10);
  //E2.rect(10,10,width-20,height-20);
  
  
  E2.setStitch(7,20,.1);
  E2.strokeWeight(1);
  E2.noFill();

  // This loop goes through each point on in E and draws a circle on top of them
  for (int i = 0; i < lenE; i++) {
    pointLoc = getNeedleDown(E, i);
    E2.pushMatrix();
    E2.translate(pointLoc.x, pointLoc.y);
    E2.rotate(random(10));
    E2.circle(0,0, circleDiam);
    E2.popMatrix();
  }
  E2.optimize();
  

//  E.visualize(true, true, true);
  E2.visualize(true,true,true);
  
 // checkStitchDens(E2);
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


void checkStitchDens(PEmbroiderGraphics E) {
  int rows = height/5;
  int cols = width/5;
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

////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////





































////////////////// DRAW E FUNCTIONS //////////////////////////////////////////////

void drawText(PEmbroiderGraphics E) {
  PFont myFont = createFont("Helvetica-Bold", 360);
  E.TEXT_OPTIMIZE_PER_CHAR = true;
  // E.HATCH_BACKEND = E.FORCE_RASTER;
  E.setStitch(15,16,.1);
  E.hatchMode(PEmbroiderGraphics.CONCENTRIC);
  E.hatchSpacing(15);

  E.beginDraw(); 
  E.clear();
  E.textAlign(CENTER, BASELINE); 
  E.textFont(myFont);
  E.textSize(360);
  E.fill(0);
  E.stroke(0); 

  E.text("hello!", width/2, 400);
  E.optimize();
}

void drawSpiral(PEmbroiderGraphics E, int stitchLen, int hatchSpacing) {
  E.setStitch(10, stitchLen, .1);
  E.hatchSpacing(hatchSpacing);
  E.hatchMode(PEmbroiderGraphics.CONCENTRIC);  

  E.noStroke();
  E.fill(0, 0, 0);
  E.noStroke();
  E.circle(width/4, height/2, 300);
  E.rect(width*3/4-150, height/2-150, 300,300);
}


void experimentalHatching(PEmbroiderGraphics E) {
  float shapeCoords[][] = {
    {579, 51}, {712, 59}, {716, 182}, {744, 300}, {748, 345}, 
    {749, 389}, {732, 470}, {716, 510}, {692, 551}, {648, 618}, 
    {585, 670}, {471, 699}, {372, 729}, {282, 711}, {169, 643}, 
    {88, 562}, {50, 226}, {120, 159}, {252, 183}, {244, 350}, 
    {137, 234}, {137, 350}, {323, 487}, {293, 103}, {365, 78}, 
    {508, 459}, {496, 279}, {575, 276}, {665, 382}, {628, 119}, 
    {598, 228}, {474, 154}};
  E.ellipseMode(CORNER);
  E.strokeWeight(1); 
  E.stroke(0, 0, 0); 
  E.fill(0, 0, 0);  

  //-----------------------
  // Draw "spine" hatch mode (EXPERIMENTAL), which is 
  // based on distance transform & skeletonization.
  // Here, we use the (best) "vector field" (VF) version.
  //
  // Create a bitmap image by drawing to an offscreen graphics buffer.

  PGraphics pg = createGraphics(width, height); 

  pg.beginDraw();
  pg.background(0); 
  pg.ellipseMode(CORNER);
  pg.noStroke(); 
  pg.fill(255); 

  pg.beginShape();
  pg.vertex(50, 75);
  pg.vertex(50, 200);
  pg.vertex( 330, 200);
  pg.vertex( 330, 125);
  pg.quadraticVertex(250, 125, 200, 75);
  pg.vertex(175, 50);
  pg.endShape(CLOSE);

  pg.triangle (410, 200, 460, 050, 510, 400-200); 
  pg.arc      (525, 050, 150, 150, 0, PI*1.25, PIE); 
  pg.arc      (700, 050, 150, 150, 0, PI*1.25, CHORD); 
  pg.square   (300, 250, 200);
  pg.triangle (550, 450, 750, 450, 650, 450-173);
  pg.rect     (770, 250, 100, 200);

  pg.pushMatrix(); 
  pg.translate(875, 0); 
  pg.scale(0.45); 
  pg.beginShape();
  for (int i=0; i<shapeCoords.length; i++) {
    pg.vertex(shapeCoords[i][0], shapeCoords[i][1]);
  }
  pg.endShape(CLOSE);
  pg.popMatrix();

  pg.ellipse   (50, 275, 200, 150);

  pg.endDraw(); 



  E.hatchSpacing(6);
  E.setStitch(10, 30, 3);
  PEmbroiderHatchSpine.setGraphics(E);
  PEmbroiderHatchSpine.hatchSpineVF(pg);
}





void bitmapImage(PEmbroiderGraphics E) {
  PImage myImage = loadImage("broken_heart.png"); 
  E.clear();
  E.fill(0, 0, 0); 
  E.noStroke();

  //-------------------
  // Parallel hatch 
  E.setStitch(5, 13, 0); 
  E.hatchMode(PEmbroiderGraphics.PARALLEL);
  E.hatchAngleDeg(15);
  E.hatchSpacing(13);
  E.image(myImage, 0, 0);

  //-------------------
  // Cross hatch 
  E.setStitch(5, 15, 0);
  E.hatchMode(PEmbroiderGraphics.CROSS); 
  E.HATCH_ANGLE = radians(30);
  E.HATCH_ANGLE2 = radians(0);
  E.hatchSpacing(15); 
  E.image(myImage, 250, 0);

  //-------------------
  // Dense concentric hatch 
  E.hatchMode(PEmbroiderGraphics.CONCENTRIC); 
  E.hatchSpacing(14);
  E.setStitch(9, 13, .1);
  E.image(myImage, 0, 250);
  
  //-------------------
  // Dense concentric hatch 
  E.hatchMode(PEmbroiderGraphics.SPIRAL); 
  E.hatchSpacing(14);
  E.setStitch(9, 12, 1.0);
  E.image(myImage, 250, 250);


  //-------------------
  // Draw fat perpendicular stroke only, no fill. 
  E.noFill(); 
  E.stroke(0, 0, 0); 
  E.setStitch(14, 15, 1.0);
  E.strokeWeight(16); 
  E.strokeSpacing(17);
  E.strokeMode(PEmbroiderGraphics.PERPENDICULAR);
  E.image(myImage, 500, 250);

  //-------------------
  // Draw fat parallel stroke only; no fill. 
  E.stroke(0, 0, 0); 
  E.noFill(); 
  E.strokeWeight(16); 
  E.setStitch(11, 14, 1.0);
  E.strokeMode(PEmbroiderGraphics.TANGENT);
  E.strokeSpacing(17);
  E.image(myImage, 750, 250);

  //-------------------
  // Draw "spine" hatch (experimental), which is 
  // based on distance transform & skeletonization.
  // Here, we use the (best) "vector field" (VF) version.
  // NOTE: SPINE HATCH IS TOO INCONSITENT FOR THIS METHOD
  //E.pushMatrix();
  //E.translate(500, 0);
  //E.setStitch(14, 14, 0.0); 
  //PEmbroiderHatchSpine.setGraphics(E);
  //PEmbroiderHatchSpine.hatchSpineVF(myImage, 14); 
  //E.popMatrix(); 

  //-------------------
  // Draw the original raster image (for reference).
  image(myImage, 750, 0);

  //-------------------
  // Be sure to un-comment E.optimize() and E.endDraw() below
  // when you want to actually export the embroidery file!!!
  // 
  //E.optimize();    // really slow, but good and important
}
/////////////////////////////////////////////////
