/// ORIGINAL CODE PULLED FROM THIS THREAD:
// https://discourse.processing.org/t/creating-voronoi-patterns/14635/3
// NOTE: Clipping is important on the voronoi pattern B/C at the outside the polygons can extend a ways (enough to run out of memory when generating the stitching pattern)

// Import the library, and declare a PEmbroider renderer. 
import processing.embroider.*;
PEmbroiderGraphics E;


import toxi.geom.*;
import toxi.geom.mesh2d.*;
import toxi.util.*;
import toxi.util.datatypes.*;
import toxi.processing.*;
ToxiclibsSupport gfx;


// optional polygon clipper
PolygonClipper2D clip;

ArrayList<PVector> vertices = new ArrayList();

void setup(){
    size(1000, 600, P2D);
    background(255);
    strokeWeight(1);
    smooth(8);
    noFill();
    
    // Create the PEmbroider object
    E = new PEmbroiderGraphics(this, width, height);
    E.beginDraw();
    
    
    
    Voronoi voronoi = new Voronoi();
    gfx = new ToxiclibsSupport(this);
    
    
      // setup clipper with centered octagon
      clip=new ConvexPolygonClipper(new Circle(width/3).toPolygon2D(30).translate(new Vec2D(width/2,height/2)));
    
    for (int i=0; i<40; i++) {
      voronoi.addPoint(new Vec2D(random(width), random(height)));
    }

    //Display sites (red points)
    pushStyle();
    strokeWeight(7);
    stroke(255, 0, 0);
    for (Vec2D p : voronoi.getSites()) {
        point(p.x(), p.y());
    }
    popStyle();
    
    // Embroidery style
    E.fill(0);
    E.hatchSpacing(10);
    E.hatchMode(PEmbroiderGraphics.SATIN);
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
    
    
    
    pushStyle();
    //strokeWeight(8);
    for (PVector v : vertices) {
        circle(v.x, v.y,7);
    }
    popStyle();
    E.visualize();
    
    noLoop();
}
