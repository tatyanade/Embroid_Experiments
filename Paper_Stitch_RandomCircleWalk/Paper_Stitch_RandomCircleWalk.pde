 import processing.embroider.*;
PEmbroiderGraphics E;
PEmbroiderGraphics E2;

void setup() {
  size (1000, 1000);

  E = new PEmbroiderGraphics(this, width, height);

  // Start rendering to the PEmbroiderer.
  E.beginDraw(); 
  E.CIRCLE_DETAIL = 20;
  E.toggleResample(true);
  E.setStitch(10,600, 0);
  
  
  E.circle(width/2, height/2, 400);
  println(getndDist(E,2,1));
  
  
  E.visualize(false, true, false); // Display (preview) the embroidery onscreen.
  
  E2 = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath("output.pes");
  E2.setPath(outputFilePath);
  E2.setStitch(10,1000,0);
  
  int steps = 30;
  int eLen = ndLength(E);
  
  int i0 = int(random(eLen));
  int i1 = int(random(eLen));
  
  for(int i = 0; i < steps; i++){

    PVector P0 = getND(E, i0);
    PVector P1 = getND(E, i1);
    E2.line(P0.x,P0.y,P1.x,P1.y);
    i0 = i1;
    i1 = int(random(eLen));
  }
  
  E2.visualize();
}


void draw() {
  boolean bShowAnimatedProgress = false;
  if (bShowAnimatedProgress) {
    background(255);
    E.visualize(true, false, true, frameCount);
  }
}





///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// NEEDLE DOWN HELPERS ////////////////////////////////////////////////////////////

PVector getND(PEmbroiderGraphics E, int ndIndex) {
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

PVector getPolyND(PEmbroiderGraphics E, int ndIndex, int polylineIndex){
  return E.polylines.get(polylineIndex).get(ndIndex).copy();
}

int polyndLength(PEmbroiderGraphics E, int polylineIndex){
  return E.polylines.get(polylineIndex).size();
}

int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
   n += E.polylines.get(i).size();
 }
  return n;
}

float getndDist(PEmbroiderGraphics E, int i1, int i2){
  PVector P1 = getND(E,i1);
  PVector P2 = getND(E,i2);
  return P1.sub(P2).mag();
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
    pointLoc = getND(E, i);
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
    pointLoc = getND(E, i);
    fill(255);
    stroke(255,255,255,40);
    point(pointLoc.x,pointLoc.y);
  }
  
  println("Max Stitches:");
  println(maxStitches);
}



////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
