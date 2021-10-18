// Test program for the PEmbroider library for Processing:
// Making a multi-color embroidery 
// based on individually colored .PNGs
import traceskeleton.*;

import processing.embroider.*;
PEmbroiderGraphics E;
PImage  color_black;
PImage  color_white;
PImage  color_grey;
PImage  color_green;
PImage  color_brown;




void setup() {
  noLoop(); 
  size (800, 800);

  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath("ghumpkin-3.jef");
  E.setPath(outputFilePath); 
  
  // The image should consist of white shapes on a black background. 
  // The ideal image is an exclusively black-and-white .PNG or .GIF.
  color_black =    loadImage("black.png");
  color_white = loadImage("white.png");
  color_grey =  loadImage("grey2.png");
  color_green =   loadImage("green2.png");
  color_brown =  loadImage("brown.png");



  E.beginDraw(); 
  E.clear();

  // Stroke properties
  E.noStroke();

  // Fill properties
  E.hatchSpacing(4.0); 
  E.PARALLEL_RESAMPLING_OFFSET_FACTOR = 0.33;

  E.hatchAngle(0);
  E.hatchMode(PEmbroiderGraphics.SATIN); 
  E.setStitch(600, 600, 0.5);
  E.hatchSpacing(3);
  E.fill(255, 255, 255);
  E.image(color_white, 0, 0); 
  
  E.strokeWeight(2);
  traceLines(E, color_grey);

  E.hatchMode(PEmbroiderGraphics.CONCENTRIC); 
  E.setStitch(10, 20, 0);
  E.noStroke();
  E.fill(0,0,0);
  E.hatchSpacing(2);
  E.image(color_black, 0, 0); 
 
  
  E.noStroke();
  E.hatchMode(PEmbroiderGraphics.CONCENTRIC); 
  E.setStitch(10, 20, 0);
  E.fill(135, 135, 135);
  E.hatchSpacing(2);
  //E.image(color_grey, 0, 0); 
  
  E.hatchMode(PEmbroiderGraphics.CONCENTRIC); 
  E.setStitch(10, 20, 0);
  E.fill(0, 255, 0);
  E.hatchSpacing(2);
  E.image(color_green, 0, 0); 
  
  E.hatchMode(PEmbroiderGraphics.CONCENTRIC); 
  E.setStitch(10, 20, 0);
  E.fill(80, 80, 20);
  E.hatchSpacing(2);
  E.image(color_brown, 0, 0); 
  
  
  
  
  
  
  
  
  
  //-----------------------
  //E.optimize();   // slow, but good and important
  //setting first vaule true shows colorized preview
  E.visualize(true, true, true);  // 
  //E.printStats(); //
  //E.endDraw();    // write out the file
}

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
  for (int i = 0; i < c.size(); i++) {
    E.beginShape();
    for (int j = 0; j < c.get(i).size(); j++) {
      E.vertex(c.get(i).get(j)[0], c.get(i).get(j)[1]);
    }
    E.endShape();
  }
  
}

//--------------------------------------------
void draw() {
  ;
}
