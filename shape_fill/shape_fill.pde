// Test program for the PEmbroider library for Processing:
// Filling an image with the experimental SPINE hatch

import processing.embroider.*;
PEmbroiderGraphics E;
PImage myImage;

void setup() {
  noLoop(); 
  size (600, 600);

  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath("blob.pes");
  E.setPath(outputFilePath); 

  // The image should consist of white shapes on a black background. 
  // The ideal image is an exclusively black-and-white .PNG or .GIF.
  myImage = loadImage("blob.png");

  E.beginDraw(); 
  E.clear();
  
  E.setRenderOrder(E.STROKE_OVER_FILL);
  // Use the Cull feature to make lines and strokes not overlap
  E.beginCull();
  // Draw it once, filled. 
  //E.noStroke();
  E.fill(0, 255, 0); // Blue fill
  E.HATCH_MODE = PEmbroiderGraphics.CROSS;
  //E.HATCH_SPACING = 4;
  //E.HATCH_SCALE = 4.5;
  E.hatchSpacing(15.0); 
  //E.image(myImage, 0, 0); 
  
  // Draw it again, but just the stroke this time. 
  //E.noFill();
  E.strokeWeight(15); 
  E.strokeMode(PEmbroiderGraphics.PERPENDICULAR);
  E.strokeSpacing(3.0); 
  E.strokeLocation(E.INSIDE);
  E.stroke(0, 255,0); // Blue stroke
  E.image(myImage, 0, 0); 
  

  E.endCull();
  


  // Uncomment for the Alternative "Spine" rendering style:
  //PEmbroiderHatchSpine.setGraphics(E);
  //PEmbroiderHatchSpine.hatchSpineVF(myImage, 5);

  //-----------------------
  E.optimize();   // slow, but good and important
  E.visualize(true,true,true);//true,true,true);  // 
  E.printStats(); //
  E.endDraw();    // write out the file
  save("blob.png");
}


//--------------------------------------------
void draw() {
  ;
}
