// Test program for the PEmbroider library for Processing:

import processing.embroider.*;
PEmbroiderGraphics E;
PGraphics PG;
ArrayList<PVector> circleCenters = new ArrayList<PVector>();
ArrayList<Float> circRad = new ArrayList<Float>();



void setup() {
  size(1000, 500);

  E = new PEmbroiderGraphics(this, 500, 500);
  E.setPath ( sketchPath("PEmbroider_shape_merging.vp3"));
  setupCircles();

  renderRasterGraphics();

  generateEmbroideryFromRasterGraphics();

  // draw the raster graphics, for reference
  image(PG, 0, 0);

  pushMatrix();
  translate(500, 0);
  E.visualize();
  E.setStitch(10,200,0);
  popMatrix();
}

void draw() {
  background(180);
  updateCircles();
  
  renderRasterGraphics();
  generateEmbroideryFromRasterGraphics();
  


  pushMatrix();
  translate(500, 0);
  E.visualize();
  popMatrix();
  E.clear();
}


void updateCircles() {
  for (int i = 0; i < 20; i++) {
    
    //circleCenters.get(i).add(new PVector(random(-3,3),random(-3,3)));
    circRad.set(i,circRad.get(i)+1);
  }
    println("/////////////");
    println(circleCenters);
    println(circRad);
    println("/////////////");
}



void setupCircles() {
  for (int i = 0; i < 20; i++) {
    circleCenters.add(new PVector(random(width/2), random(height)));
    circRad.add(random(30, 100));
  }
}


//--------------------------------------------
void generateEmbroideryFromRasterGraphics() {
  E.beginDraw();
  E.fill(0, 0, 0);
  E.stroke(0);

  E.HATCH_MODE = PEmbroiderGraphics.CONCENTRIC;
  E.HATCH_SPACING = 2;
  E.hatchRaster(PG, 0, 0);
}

//--------------------------------------------
void renderRasterGraphics() {
  PG = createGraphics(500, 500);
  PG.beginDraw();
  PG.background(0);
  


  // Merged shapes with holes
  PG.noStroke();
  PG.rectMode(CENTER);
  PG.rect(PG.width/2, PG.height/2, PG.width-40, PG.height-40);
  PG.circle(402, 302, 96);
  PG.fill(0);
  for (int i = 0; i < circleCenters.size(); i++) {
    PVector circCenter = circleCenters.get(i);
    float rad = circRad.get(i);
    PG.circle(circCenter.x, circCenter.y, rad);
  }

  PG.endDraw();
}
