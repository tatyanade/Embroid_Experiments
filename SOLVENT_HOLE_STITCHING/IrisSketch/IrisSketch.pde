import processing.embroider.*;
PEmbroiderGraphics E;
float frame = 0;

void setup() {
  size(1200, 1600);
  // noLoop();

  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath("IrisTest.PES");
  E.setPath(outputFilePath); 

  E.noFill();
  E.stroke(0); 
  E.strokeWeight(1);
  E.setStitch(10, 20, 0);
  E.clear();
  frameRate(10);
  noLoop();
  drawIris(width/2, height/2, 300, 0, 14);
  E.visualize();





  save("Iris.png");
  //E.endDraw();
}

void draw() {
}



void drawIris(int x, int y, int diam, float theta, float arcLength) {
  E.pushMatrix();
  E.translate(x, y);

  int circInset = 5;
  E.circle(0, 0, diam+circInset);
  
  
  int rad = diam/2;

  int len = diam/2;

  float thStep = arcLength / rad;
  float thSteps = 0;
  int i = 0;


  while (thSteps<= 2*PI) {
    
    E.rotate(thStep);
    E.pushMatrix();
    E.translate(rad, 0);
    E.rotate(PI/2);
    E.rotate(theta);
    if (i%2 == 0) {
      E.line(-len, 0, len, 0);
    } else {
      E.line(len, 0, -len, 0);
    }
    E.popMatrix();
    
    thSteps+= thStep;
    i++;
  }
  
  E.popMatrix();
}
