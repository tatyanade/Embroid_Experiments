//Helpful ref thread: https://discourse.processing.org/t/creating-voronoi-patterns/14635/12
import toxi.geom.*;
import toxi.geom.mesh2d.*;

import toxi.util.*;
import toxi.util.datatypes.*;

import toxi.processing.*;

// ranges for x/y positions of points
FloatRange xpos, ypos;

// helper class for rendering
ToxiclibsSupport gfx;

// empty voronoi mesh container
Voronoi voronoi = new Voronoi();

// optional polygon clipper
PolygonClipper2D clip; // see toxi.geom for refference on this object

// switches
boolean doShowPoints = true;
boolean doShowDelaunay;
boolean doShowHelp=true;
boolean doClip;
boolean doSave;
boolean runningEmbroidery = false;
boolean ranEmbroidery = false;



int offset = 3;
int frame = 0;

// Import the library, and declare a PEmbroider renderer.
import processing.embroider.*;
PEmbroiderGraphics E;
PEmbroiderGraphics E2;

//Ref images
PImage image_TEST;

/// File picker bits
String globalFileBin;
boolean globalBinFilled = false;
///

void setup() {

  size(800, 800);
  grabInput();
  image_TEST = loadImage(globalFileBin);
  // focus x positions around horizontal center (w/ 33% standard deviation)
  xpos=new BiasedFloatRange(0, width, width/2, 0.333f);
  // focus y po
  ypos=new BiasedFloatRange(0, height, height, 0.5f);
  // setup clipper with centered octagon
  // clip=new ConvexPolygonClipper(new Circle(width*0.45).toPolygon2D(8).translate(new Vec2D(width/2,height/2)));

  clip=new SutherlandHodgemanClipper(new Rect(0, 0, width, height));

  gfx = new ToxiclibsSupport(this);
  textFont(createFont("SansSerif", 10));


  E = new PEmbroiderGraphics(this, width, height);
  E.setPath(sketchPath("Voronoi2"+timeStamp()+".pes"));
  E.beginDraw();

  E2 = new PEmbroiderGraphics(this, width, height);
  E2.beginDraw();
  E2.fill(0);
  E2.hatchMode(E.CROSS);
  E2.setStitch(10,20,1);
  E2.hatchSpacing(15);
  E2.image(image_TEST, width/2-image_TEST.width/2, height/2-image_TEST.height/2);
  E2.optimize();
  E2.visualize(true,true,true);
  writePembroider(E2, "VoronoiUnderStitch");
  
  E2.clear();
  E2.noFill();
  E2.image(image_TEST, width/2-image_TEST.width/2, height/2-image_TEST.height/2);
}

ArrayList<Polygon2D> polyINSETS = new ArrayList<Polygon2D>();


void draw() {
  if (!runningEmbroidery) {
    VORONOI_DRAW();
    E2.visualize(true,true,true);
  } else {
    if (!ranEmbroidery) {
      SETUP_EMBROIDERY();
      ranEmbroidery = true;
    } else {
      background(255);
      E.visualize(true, true, true, frame*10);
      frame++;
    }
  }
}



void VORONOI_DRAW() {
  background(255);
  stroke(0);
  noFill();
  // draw all voronoi polygons, clip them if needed...
  for (Polygon2D poly : voronoi.getRegions()) {// get regions is all the polyg

    if (doClip) {
      gfx.polygon2D(clip.clipPolygon(poly));
    } else {
      gfx.polygon2D(poly);
    }
  }

  // draw original points added to voronoi
  if (doShowPoints) {
    fill(255, 0, 255);
    noStroke();
    for (Vec2D c : voronoi.getSites()) {
      ellipse(c.x, c.y, 5, 5);
    }
  }

  if (doShowHelp) {
    fill(255, 0, 0);
    text("p: toggle points", 20, 20);
    text("t: toggle triangles", 20, 40);
    text("x: clear all", 20, 60);
    text("r: add random", 20, 80);
    text("c: toggle clipping", 20, 100);
    text("h: toggle help display", 20, 120);
    text("space: save frame", 20, 140);
    text("e: generate embroidery design", 20, 160);
  }
}


void SETUP_EMBROIDERY() {
  background(180);
  E.setStitch(1, 3, 0);
  E.fill(0);
  E.hatchMode(E.PARALLEL);
  E.noStroke();
  int i = 0;
  for (Polygon2D poly : voronoi.getRegions()) {
    E.beginOptimize();
    /// color variation happens here!!!!! <--------------
    E.fill(int(random(0,255)),int(random(0,255)),int(random(0,255)));
    E.beginShape();
    E.hatchAngle(noise(i, 1)*2*PI);
    E.hatchSpacing(2);
    poly = clip.clipPolygon(poly);

    if (!poly.isClockwise()) {
      poly.flipVertexOrder();
    }

    poly = poly.offsetShape(-2);



    for (Vec2D v : poly.vertices) {
      E.vertex(int(v.x), int(v.y));
    }
    E.endShape(CLOSE);
    E.endOptimize();
    i++;
  }

  filterInRefPoly(E, E2); //filters out all points outside the H
  
  filterStitchLen(E); //cuts apart all paths that fall outside the H (using simple dist check method)
  E.optimize();// only use this line if the internal polygons are separate colors
  filterReline(E); //we turn all stitches into long stitches 
  writePembroider(E, "VoronoiInset");
}


void grabInput(){
  selectInput("Input file here", "fileSelection");
  while(!globalBinFilled){
    println("");
  }
  globalBinFilled = false;
}

void fileSelection(File selection) {
  if (selection == null) {
    globalFileBin = ("Window was closed or the user hit cancel.");
    exit();
  } else {
    globalFileBin = (selection.getAbsolutePath());
  }
  globalBinFilled = true;
}



void keyPressed() {
  switch(key) {
  case ' ':
    doSave = true;
    break;
  case 't':
    doShowDelaunay = !doShowDelaunay;
    break;
  case 'x':
    voronoi = new Voronoi();
    break;
  case 'p':
    doShowPoints = !doShowPoints;
    break;
  case 'c':
    doClip=!doClip;
    break;
  case 'h':
    doShowHelp=!doShowHelp;
    break;
  case 'r':
    for (int i = 0; i < 10; i++) {
      voronoi.addPoint(new Vec2D(xpos.pickRandom(), ypos.pickRandom()));
    }
    break;
  case 'e':
    println("WOULD RUN PEMBROIDER CODE HERE");
    runningEmbroidery = true;
    break;
  }
}

void mousePressed() {
  voronoi.addPoint(new Vec2D(mouseX, mouseY));
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


void labelND(PEmbroiderGraphics E, int ind) {
  int n = 0;
  pushStyle();
  stroke(0);
  fill(0);
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector ND = E.polylines.get(i).get(j).copy();
      text(n, ND.x, ND.y);
      n++;
      if (n>ind) {
        break;
      }
    }
  }
  popStyle();
}


void stepPolys(PEmbroiderGraphics E, PEmbroiderGraphics E2) {
  for (int i=0; i<E.polylines.size(); i++) {
    int eLen = polyndLength(E, i);
    for (int j=0; j<eLen; j++) {
      if (j%2 == 0) {
        int i0 = j%(eLen-1);//i1;
        int i1 = (j+offset)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      } else {
        int i1 = j%(eLen-1);//i1;
        int i0 = (j+offset)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      }
    }
  }
}

void stepPolysVert(PEmbroiderGraphics E, PEmbroiderGraphics E2) {
  for (int i=0; i<E.polylines.size(); i++) {
    int eLen = polyndLength(E, i);
    //   int i0 = 0%eLen;//int(random(eLen));
    // int i1 = (0+5)%eLen;//int(random(eLen));
    E2.beginShape();
    for (int j=0; j<eLen; j++) {
      if (j%2 == 0) {
        int i0 = j%(eLen-1);//i1;
        int i1 = (j+offset)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.vertex(P0.x, P0.y);
        E2.vertex(P1.x, P1.y);
      } else {
        int i1 = j%(eLen-1);//i1;
        int i0 = (j+offset)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.vertex(P0.x, P0.y);
        E2.vertex(P1.x, P1.y);
      }
    }
    E2.endShape();
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

void writePembroider(PEmbroiderGraphics E) {
  E.setPath(sketchPath("Voronoi_softened"+timeStamp()+".pes"));
  E.endDraw();
}

void writePembroider(PEmbroiderGraphics E, String name) {
  E.setPath(sketchPath(name+timeStamp()+".pes"));
  E.endDraw();
}

String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}



void filterRect(PEmbroiderGraphics E) {
  PEmbroiderGraphics E_Ref = new PEmbroiderGraphics(this, width, height);
  E_Ref.rectMode(CENTER);
  // E_Ref.image(image,width/2-image.width/2, height/2-image.width/2);
  E_Ref.circle(width/2, height/2, 800);
  // E_Ref.visualize();
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      boolean isInPoly = E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(0));
      if (!isInPoly) {
        collection.add(needleLoc0);
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}


void filterInRefPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref) {
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      boolean isInPoly = E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(0));
      if (!isInPoly) {
        collection.add(needleLoc0);
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

void filterReline(PEmbroiderGraphics E) {
  filterStitchLen(E);
  float minLength = 2;
  E.setStitch(10, 10000, 0);
  for (int i=0; i<E.polylines.size(); i++) {
    int polySize = E.polylines.get(i).size();
    if (polySize > 0) {
      PVector P0 = E.polylines.get(i).get(0);
      PVector P1 = E.polylines.get(i).get(polySize-1);
      E.polylines.get(i).clear();
      if (P0.copy().sub(P1).mag()>=minLength) {
        E.polylines.get(i).add(P0);
        E.polylines.get(i).add(P1);
      }
    }
  }
}

void filterStitchLen(PEmbroiderGraphics E) {
  ArrayList<ArrayList<PVector>> collection =  new ArrayList<ArrayList<PVector>>();
  ArrayList<Integer> colors =  new ArrayList<Integer>();
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> poly = new ArrayList<PVector>();
    int sz = E.polylines.get(i).size();
    for (int j=0; j<sz-1; j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      PVector needleLoc1 = E.polylines.get(i).get(j+1).copy();
      float dist = needleLoc0.copy().sub(needleLoc1).mag();
      if (dist > 10) {
        poly.add(needleLoc0);
        collection.add(poly);
        colors.add(E.colors.get(i));
        poly = new ArrayList<PVector>();
      } else {
        poly.add(needleLoc0);
      }
    }
    if(sz>=1){
    poly.add(E.polylines.get(i).get(sz-1));
    }
    collection.add(poly);
    colors.add(E.colors.get(i));
  }
  E.clear();
  color C = color(0,0,255);
  for(int i = 0; i<collection.size(); i++){
   if(collection.get(i).size()>0){
    E.pushPolyline(collection.get(i),colors.get(i));
   }
  }
}


void filterInPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref) {
  // this only works on the last poly in the set (kind of a silly function)
  int i = E.polylines.size()-1;
  ArrayList<PVector> collection =  new ArrayList<PVector>();
  for (int j=0; j<E.polylines.get(i).size(); j++) {
    PVector needleLoc0 = E.polylines.get(i).get(j).copy();
    boolean isInPoly = E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(0));
    if (!isInPoly) {
      collection.add(needleLoc0);
    }
  }
  E.polylines.get(i).removeAll(collection);
}






////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
