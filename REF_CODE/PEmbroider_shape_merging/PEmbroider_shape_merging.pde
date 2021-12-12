// Test program for the PEmbroider library for Processing:

import processing.embroider.*;
PEmbroiderGraphics E;
PGraphics PG; 
ArrayList<PVector> CircleCenters = new ArrayList<PVector>();
ArrayList<Integer> circRad = new ArrayList<Integer>();



void setup() {
  size(1000, 500); 
  noLoop(); 

  PG = createGraphics(500, 500);

  E = new PEmbroiderGraphics(this, 500, 500);
  E.setPath ( sketchPath("PEmbroider_shape_merging.vp3")); 

  renderRasterGraphics(); 
  generateEmbroideryFromRasterGraphics();

  // draw the raster graphics, for reference
  image(PG, 0, 0);

  pushMatrix(); 
  translate(500,0); 
  E.visualize();
  popMatrix(); 
  E.optimize(); // slow, but good and important
  // E.endDraw(); // write out the file
}


//--------------------------------------------
void generateEmbroideryFromRasterGraphics() {
  E.beginDraw(); 
  E.clear();
  E.fill(0,0,0);
  E.stroke(0); 

  E.HATCH_MODE = PEmbroiderGraphics.CONCENTRIC;
  E.HATCH_SPACING = 10;
  E.hatchRaster(PG, 0, 0);
}


//--------------------------------------------
void renderRasterGraphics() {
  PG.beginDraw();
  PG.background(0);


  // Merged shapes with holes
  PG.noStroke();
  PG.rectMode(CENTER);
  PG.rect(PG.width/2, PG.height/2, PG.width-40, PG.height-40);
  PG.circle(402, 302, 96);
  PG.fill(0);
  for(int i = 0; i < 20; i++){
  PG.circle(random(PG.width), random(PG.height), random(30,100));
  }

  PG.endDraw();
}


//--------------------------------------------
void draw() {
  ;
}
