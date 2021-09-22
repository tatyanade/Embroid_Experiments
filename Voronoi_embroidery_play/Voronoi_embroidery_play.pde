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
PolygonClipper2D clip;

// switches
boolean doShowPoints = true;
boolean doShowDelaunay;
boolean doShowHelp=true;
boolean doClip;
boolean doSave;
boolean runningEmbroidery = false;

// Import the library, and declare a PEmbroider renderer. 
import processing.embroider.*;
PEmbroiderGraphics E;

void setup() {
  size(600, 600);
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
  E.setPath(sketchPath("Voronoi.pes"));
  E.beginDraw();
  
}

void draw() {
  if(!runningEmbroidery){
  background(255);
  stroke(0);
  noFill();
  // draw all voronoi polygons, clip them if needed...
  for (Polygon2D poly : voronoi.getRegions()) {// get regions is all the polyg
    
    if (doClip) {
      gfx.polygon2D(clip.clipPolygon(poly));
    } 
    else {
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
  if (doSave) {
    saveFrame("voronoi-" + DateUtils.timeStamp() + ".png");
    doSave = false;
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
    E.fill(0);
    E.hatchSpacing(8);
    E.hatchMode(PEmbroiderGraphics.CONCENTRIC);
    E.setStitch(40, 50, 0); 
    E.hatchAngle(PI);
    //
    
    
    int i = 0;
    for (Polygon2D poly : voronoi.getRegions()) {
      E.beginShape();
      poly = clip.clipPolygon(poly);
      println(poly);
      for (Vec2D v : poly.vertices) {
        E.hatchAngle(noise(i)*2*PI);
        E.vertex(int(v.x),int(v.y));
      }
      E.endShape(CLOSE);
      i++;
      println(i);
    }
    E.optimize();
    E.visualize(true,true,true);
    E.endDraw();
    noLoop();
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
