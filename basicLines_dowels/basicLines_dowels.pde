import processing.embroider.*;
PEmbroiderGraphics E;
float dowelOffset = 55;

void setup() {
  size (500, 500);

  E = new PEmbroiderGraphics(this, width, height);
  E.setPath(sketchPath("basicLines.pes"));

  // Start rendering to the PEmbroiderer.
  E.beginDraw();
  E.noFill();
  E.stroke(180, 0, 0);
  E.toggleResample(true);
  float theta =  0;
  PVector P0 = new PVector(width/2, height/2);
  PVector P1 = new PVector(0, -200).rotate(theta).add(P0);
  PVector P2 = new PVector(0, 200).rotate(theta).add(P0);
  dowelStitch_withInteriorLace(E, P1, P2, 400);

  E.visualize(true, true, true); // Display (preview) the embroidery onscreen.
  E.endDraw();
}

void zigLine(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth) {
  zigLine(E, P0, P1, stWidth, 1, 10);
}


void zigLine(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth, int stDir, float stLen) {
  E.setStitch(1, 1000, 0);
  float stepAmount = int(P1.copy().sub(P0).mag()/stLen);
  PVector step = P1.copy().sub(P0).div(stepAmount);
  PVector P = P0.copy();
  PVector tan = step.copy().rotate(PI/2).normalize().mult(stWidth/2.0);
  E.beginShape();
  int dir=stDir;
  for (int i = 0; i <= stepAmount; i++) {
    E.vertex(P.x+tan.x*dir, P.y+tan.y*dir);
    P.add(step);
    dir *= -1;
  }

  E.endShape();
}

void zigLineCustom(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth, int stDir, float stLen, float stitchLen) {
  E.setStitch(1, stitchLen, 0);
  float stepAmount = int(P1.copy().sub(P0).mag()/stLen);
  PVector step = P1.copy().sub(P0).div(stepAmount);
  PVector P = P0.copy();
  PVector tan = step.copy().rotate(PI/2).normalize().mult(stWidth/2);
  println(tan);
  E.beginShape();
  int dir=stDir;
  for (int i = 0; i <= stepAmount; i++) {
    E.vertex(P.x+tan.x*dir, P.y+tan.y*dir);
    P.add(step);
    dir *= -1;
  }

  E.endShape();
}

void dowelStitch_withInteriorLace(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth) {
    E.rectMode(CENTER);
    E.fill(40);
    E.hatchMode(E.CROSS);
    E.hatchSpacing(15);
    E.noStroke();
    E.beginOptimize();
    E.rect(width/2,height/2,stWidth,abs(P0.y-P1.y));
    E.endOptimize();
    E.noFill();
    dowelStitch(E,P0.copy().add(stWidth/2-dowelOffset/2,0),P1.copy().add(stWidth/2-dowelOffset/2,0));
    dowelStitch(E,P0.copy().sub(stWidth/2-dowelOffset/2,0),P1.copy().sub(stWidth/2-dowelOffset/2,0));
    E.stroke(0);
    
    
    zigLineCustom(E, P0, P1, stWidth, 1, 5, 10);
    filterND_stepOverLAST(E, stWidth/2 - dowelOffset, stWidth/2); // this only works when P0 -> P1 is vertical
    
}

void foldLine(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth) {
  E.setStitch(10, 15, 0);
  E.line(P0.x, P0.y, P1.x, P1.y);
  E.setStitch(10, 60, 0);
  zigLine(E, P1, P0, stWidth, 1, 20);
  zigLine(E, P0, P1, stWidth, 1, 20);
}

void dowelStitch(PEmbroiderGraphics E, PVector P0, PVector P1){
  E.stroke(180, 0, 0);
  E.setStitch(1,60,0);
  E.line(P0.x, P0.y, P1.x, P1.y);
  E.stroke(15);
  zigLine(E, P0, P1, dowelOffset-10, 1, 20);
  zigLine(E, P1, P0, dowelOffset-10, 1, 20);
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

PVector getPolyND(PEmbroiderGraphics E, int ndIndex, int polylineIndex) {
  return E.polylines.get(polylineIndex).get(ndIndex).copy();
}

int polyndLength(PEmbroiderGraphics E, int polylineIndex) {
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

float getndDist(PEmbroiderGraphics E, int i1, int i2) {
  PVector P1 = getND(E, i1);
  PVector P2 = getND(E, i2);
  return P1.sub(P2).mag();
}



void checkStitchDens(PEmbroiderGraphics E) {
  int rows = height/5;
  int cols = width/5;
  float heightOffset = height/rows;
  float widthOffset = width/cols;

  println(heightOffset);

  println("Sample size:");
  println(str(widthOffset) + " x " + str(heightOffset));
  int stitchCounters[][] = new int[rows+10][cols+10];

  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  int maxStitches = 0;

  int rowTrack = 100;
  int colTrack = 0;

  // This loop goes through each point  in E counts how many times the needle down falls within a certain stitch counter
  for (int i = 0; i < lenE; i++) {
    pointLoc = getND(E, i);
    int col = int(pointLoc.x/widthOffset);
    int row = int(pointLoc.y/heightOffset);
    if (row<rowTrack) {
      rowTrack = row;
    }
    if (col>colTrack) {
      colTrack = col;
    }

    stitchCounters[row][col]++;
  }

  for (int row=0; row < rows; row ++) {
    for (int col=0; col < cols; col++) {
      int r = int(float(stitchCounters[row][col])*30);
      if (maxStitches<stitchCounters[row][col]) {
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
    stroke(255, 255, 255, 40);
    point(pointLoc.x, pointLoc.y);
  }

  println("Max Stitches:");
  println(maxStitches);
}


void randomStepPolys(PEmbroiderGraphics E, PEmbroiderGraphics E2, int steps) {
  for (int i=0; i<E.polylines.size(); i++) {
    int eLen = polyndLength(E, i);
    println(i);
    //   int i0 = 0%eLen;//int(random(eLen));
    // int i1 = (0+5)%eLen;//int(random(eLen));
    for (int j=0; j<steps; j++) {
      if (j%2 == 0) {
        int i0 = j%(eLen-1);//i1;
        int i1 = (j+8)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      } else {
        int i1 = j%(eLen-1);//i1;
        int i0 = (j+8)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      }
    }
  }
}



void filterND(PEmbroiderGraphics E, float intRad, float edgRad) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = needleLoc0.sub(center).mag();
      boolean val = abs(dist-edgRad)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}


void filterND_stepOver(PEmbroiderGraphics E, float intRad, float edgWidth) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = abs(needleLoc0.x - center.x);
      boolean val = abs(dist-edgWidth)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

void filterND_stepOverLAST(PEmbroiderGraphics E, float intRad, float edgWidth) {
  PVector center = new PVector(width/2, height/2);
  for (int i=E.polylines.size()-1; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = abs(needleLoc0.x - center.x);
      boolean val = abs(dist-edgWidth)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

boolean NDaproxIn (PEmbroiderGraphics E, PVector ND) {
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      if (needleLoc.sub(ND).mag()<.001) {
        return true;
      }
    }
  }
  return false;
}


////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
