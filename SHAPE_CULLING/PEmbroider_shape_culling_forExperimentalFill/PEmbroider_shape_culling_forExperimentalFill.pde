// Test program for the PEmbroider library for Processing:
// Different methods for overlapping shapes with PEmbroider

import processing.embroider.*;
PEmbroiderGraphics E;
boolean debugging = false;

void setup() {
  noLoop(); 
  size (1250, 1600);
  
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath("PEmbroider_shape_culling2.pes");
  E.setPath(outputFilePath);
 
  E.beginDraw(); 
  E.clear();
  
  //E.scale(2);
  /// CULL 1 /////////////////////////////
  E.fill(0, 0, 0); 
  
  E.CULL_SPACING = 10;

  //One circle culling another, with PARALLEL hatch
  E.hatchMode(PEmbroiderGraphics.PERLIN);
  E.hatchSpacing(5);
  E.fill(0);
  E.beginCull();
  E.pushMatrix();
  E.translate(width/2, height/2);
  E.hatchAngleDeg(45); 
  E.setStitch(30,50,.1);
  E.circle(0, 0, 800);
  E.popMatrix();
  
  // From Mossy Stitching
  int m1 = 300;
  int m2 = 120;
  drawMossyCircle_CULL( E,width/2, height/2, m1, int(m1/3), 0);
  drawMossyCircle_CULL( E,width/2+300, height/2, m2, int(m2/3), 1);
  
  E.endCull();
  
  /// CULL 2 /////////////////////////////
  E.fill(0, 0, 0); 
  
  E.CULL_SPACING = 10;

  //One circle culling another, with PARALLEL hatch
  E.hatchMode(PEmbroiderGraphics.PERLIN);
  E.hatchSpacing(5);
  E.fill(0);
  E.beginCull();
  E.pushMatrix();
  E.translate(width/2, height/2);
  E.rotate(3);
  E.hatchAngleDeg(45); 
  E.setStitch(30,50,.1);
  E.circle(0, 0, 800);
  E.popMatrix();
  
  // From Mossy Stitching
  drawMossyCircle_CULL( E,width/2, height/2, m1, int(m1/3), 0);
  drawMossyCircle_CULL( E,width/2+300, height/2, m2, int(m2/3), 1);
  
  E.endCull();
  
  
  E.optimize();
  
  drawMossyCircle( E,width/2, height/2, m1, int(m1/3), 0);
  drawMossyCircle( E,width/2+300, height/2, m2, int(m2/3), 1);
  

  //-----------------------
  // E.optimize(); // slow but good and important
  E.visualize(true,true,false); //true, true, true);
  E.endDraw(); // write out the file
  save("PEmbroider_shape_culling.png");
}



























/// From "Mossy Float Stitch /////

void drawMossyCircle( PEmbroiderGraphics E,int x, int y, int diam1, int diam2, int z) {


  ///// stitching parameters ////
  E.noFill();
  E.stroke(0, 0, 0); 
  E.strokeWeight(1);
  E.setStitch(20, 300, 0);
  ///// stitching parameters ////


  float theta = 0; // convert to radians
  float offset = 50;
  
  if(diam2 <50){
    diam2 = 50;
  }

  float ar = 2; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//
  
  //println(thStep*float(diam2+25)/2);
  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);
  
  E.noFill();
  E.strokeWeight(1);
  E.stroke(20);

  E.beginShape();
  while (thSteps < PI*2) {
    int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*offset);
    int offsetIn = int(noiseLoop(1, thSteps/(2*PI), .5+z)*offset);
    if (i%2 == 0) {
     connect2CircleVertex(E, thSteps, thSteps+theta, diam1/2+offsetOut, diam2/2+offsetIn);
    } else {
     connect2CircleVertex(E, thSteps+theta, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
    }
    thSteps += thStep;//random(0,thStep);
    i++;
  } 
  E.endShape(CLOSE);
  
  E.popMatrix();
}






void drawMossyCircle_CULL( PEmbroiderGraphics E,int x, int y, int diam1, int diam2, int z) {


  ///// stitching parameters ////
  E.noFill();
  E.stroke(0, 0, 0); 
  E.strokeWeight(1);
  E.setStitch(20, 300, 0);
  ///// stitching parameters ////


  float theta = 0; // convert to radians
  float offset = 50;
  
  if(diam2 <50){
    diam2 = 50;
  }

  float ar = 2; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//
  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);
 
  E.hatchMode(PEmbroiderGraphics.PARALLEL); 
  E.hatchSpacing(5);
  E.fill(170);
  E.setStitch(10,20,.1);
  E.noStroke();
  E.beginShape();
  thSteps = 0;
  while (thSteps < PI*2) {
    int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*50.00);
    PVector p = getPointOnRadius(thSteps,diam1/2+offsetOut);
    E.vertex(p.x,p.y);
    
    //if (i%2 == 0) {
    // connect2CircleVertex(E, thSteps, thSteps+theta, diam1/2+offsetOut, diam2/2+offsetIn);
    //} else {
    // connect2CircleVertex(E, thSteps+theta, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
    //}
    thSteps += thStep;//random(0,thStep);
    i++;
  }
  E.endShape(CLOSE);

  E.popMatrix();
}





void connect2CircleVertex(PEmbroiderGraphics E, float th1, float th2, int rad1, int rad2) {
  // th1 & th2 are in radians
  // centered on zero
  int x1 = int(cos(th1)*rad1);
  int y1 = int(sin(th1)*rad1);
  int x2 = int(cos(th2)*rad2);
  int y2 = int(sin(th2)*rad2);
  E.vertex(x1, y1);
  E.vertex(x2, y2);
}

PVector getPointOnRadius(float th, int rad){
  int x = int(cos(th)*rad);
  int y = int(sin(th)*rad);
  return new PVector(x,y);
}


float noiseLoop(float rad, float t, float z) {
  // we translate the center of the cicle so that there are no neg values
  // note: for some reason some symmetry was observed when the circle was centered on 0,0 and the input loop was symmetrical across the x and y axis
  // we assign t so that 0 is beginning of loop; 1 is end of loop
  float val = 0;
  float theta = t*2*PI; // map t to theta
  float x = cos(theta)*rad+rad;
  float y = sin(theta)*rad+rad;
  if (debugging) {
    println("x: "+str(x));
    println("y: "+str(y));
    pushMatrix();
    translate(width/2, height/2);
    circle(x*100, y*100, 5);
    popMatrix();
  }
  return noise(x, y, z);
}
