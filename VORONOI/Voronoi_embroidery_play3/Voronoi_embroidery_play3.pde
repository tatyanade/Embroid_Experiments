/**
 * This demo shows the basic usage pattern of the Voronoi class in combination with
 * the ConvexPolygonClipper to constrain the resulting shapes within an octagon boundary.
 *
 * Usage:
 * mouse click: add point to voronoi
 * p: toggle points
 * t: toggle triangles
 * x: clear all
 * r: add random
 * c: toggle clipping
 * h: toggle help display
 * space: save frame
 *
 * Voronoi class ported from original code by L. Paul Chew
 */

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

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

void setup() {
  size(1200, 1000);
  smooth();
  // focus x positions around horizontal center (w/ 33% standard deviation)
  xpos=new BiasedFloatRange(0, width, width/2, 0.333f);
  // focus y positions around bottom (w/ 50% standard deviation)
  ypos=new BiasedFloatRange(0, height, height, 0.5f);
  // setup clipper with centered octagon
  // clip=new ConvexPolygonClipper(new Circle(width*0.45).toPolygon2D(8).translate(new Vec2D(width/2,height/2)));

  clip=new SutherlandHodgemanClipper(new Rect(width*0.125, height*0.125, width*0.75, height*0.75));

  gfx = new ToxiclibsSupport(this);
  textFont(createFont("SansSerif", 10));


  E = new PEmbroiderGraphics(this, width, height);
  E.setPath(sketchPath("Voronoi2"+timeStamp()+".pes"));
  E.beginDraw();

  E2 = new PEmbroiderGraphics(this, width, height);
  E2.setPath(sketchPath("Voronoi_softened"+timeStamp()+".pes"));
  E2.beginDraw();
}

void draw() {
  if (!runningEmbroidery) {
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
  } else {
    // Embroidery style
    if (!ranEmbroidery) {
      background(180);
      E.setStitch(5, 30000, 0); 
      E.hatchSpacing(2.5);
      E.fill(0);
      E.hatchMode(E.SATIN);
      //  E.hatchAngle(PI);
      int i = 0;
      for (Polygon2D poly : voronoi.getRegions()) {
        //E.fill(i);
        E.noStroke();
        E.beginOptimize();
        E.beginShape();
        E.hatchAngle(noise(i, 1)*2*PI);
        if (!poly.isClockwise()) {
          poly.flipVertexOrder();
        }
        poly = poly.offsetShape(-10);
        poly.toOutline();
        poly = clip.clipPolygon(poly);
        for (Vec2D v : poly.vertices) {
          E.vertex(int(v.x), int(v.y));
        }
        E.endShape(CLOSE);
        E.endOptimize();
        i++;
        E.endOptimize();
      }

     // E.optimize();
      E.visualize(true, true, true);
      writePembroider(E,"VoronoiInset");
    } else {
      background(255);
      E.visualize(true,true,true,frame);
      frame++;
    }
    ranEmbroidery = true;
  }
}




void setEmbroideryPresets(int i) {
  switch(i) {
  case 0:
    break;
  case 1:
    break;
  case 2:
    break;
  }
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
    //   int i0 = 0%eLen;//int(random(eLen));
    // int i1 = (0+5)%eLen;//int(random(eLen));
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

////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
