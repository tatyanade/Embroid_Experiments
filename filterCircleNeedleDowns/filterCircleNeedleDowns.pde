import processing.embroider.*;
PEmbroiderGraphics E;

void setup() {
  size (800, 800);

  E = new PEmbroiderGraphics(this, width, height);
  E.setPath(sketchPath("filterCircles.pes"));

  E.beginDraw();
  E.fill(0);
  E.noStroke();
  E.setStitch(5, 12, 5);
  E.toggleResample(true);
  E.hatchMode(E.CROSS);
  E.hatchSpacing(5);
  E.rectMode(CENTER);
  E.beginOptimize();
  E.rect(width/2, height/2, width-40, height-40);
  E.endOptimize();
  int filterCircs = 3;

  PVector[] centers = new PVector[filterCircs];
  float [] rads = new float[filterCircs];

  for (int i = 0; i<filterCircs; i++) {
    centers[i] = new PVector(random(0, width), random(0, height));
    rads[i] = random(50, 100);
  }

  filterCircles(E, centers, rads); ////////////// Filtering Happens Here <----------------------------------------

  for (int i = 0; i<centers.length; i++) {
    pushStyle();
    noFill();
    E.noFill();
    E.stroke(30);
    E.circle(centers[i].x, centers[i].y, rads[i]*2);
    popStyle();
  }

  E.visualize(true, true, true); // Display (preview) the embroidery onscreen.
  E.endDraw();
}



///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// NEEDLE DOWN HELPERS ////////////////////////////////////////////////////////////


/// FILTER FUNCTIONS

void filterCircles(PEmbroiderGraphics E, PVector[] centers, float[] rads) {
  boolean showRemoved = false;
  if (centers.length != rads.length) {
    println("WARNING ON filterCircles");
  }


  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=1; j<E.polylines.get(i).size()-1; j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      boolean doInclude = true;

      for (int l = 0; l < centers.length; l++) {
        float dist = needleLoc0.copy().sub(centers[l]).mag();//centers[l]).mag();
        doInclude = doInclude && dist>=rads[l];
      }

      if (!doInclude) {
        collection.add(E.polylines.get(i).get(j));
        if (showRemoved) {
          pushStyle();
          fill(255, 0, 0);
          circle(needleLoc0.x, needleLoc0.y, 10);
          popStyle();
        }
      }
    }
    println(collection);
    E.polylines.get(i).removeAll(collection);
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



///// END FILTER FUNCTIONS

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
