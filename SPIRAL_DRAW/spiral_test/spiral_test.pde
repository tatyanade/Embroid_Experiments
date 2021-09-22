// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = ""; // CHANGE ME
PEmbroiderGraphics E;

int frame;



void setup() {
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  //  E.translate(width/2,height/2);
  //  float theta = 1;
  //  float stepLen = 4;
  //  int steps = 500;
  //  E.setStitch(40,40,.1);
  //  E.beginShape();
  //  for(int i=1; i<=steps;i++){
  //    float r = theta *5;
  //    float thetaStep = stepLen/r;
  //    PVector coord = radi2card(r+offset(theta,i),theta);
  //    E.vertex(coord.x,coord.y);
  //    theta+= thetaStep;
  //  }
  //  E.endShape();

  //E.visualize();
}

void draw() {
  
  background(100);
  
  E.clear();
 // E.beginDraw();
  E.pushMatrix();
  E.translate(width/2, height/2);
  float theta = 1;
  float stepLen = 4;
  int steps = 1000;
  E.setStitch(40, 40, .1);
  E.beginShape();
  for (int i=1; i<=steps; i++) {
    float r = theta *5;
    float thetaStep = stepLen/r;
    PVector coord = radi2card(r+offset(theta, i), theta);
    E.vertex(coord.x, coord.y);
    theta+= thetaStep;
  }
  E.endShape();
  E.popMatrix();
 // E.endDraw();
  
  E.visualize();
  frame++;
}

float offset(float theta, int i) {
  float off = noise(theta,float(frame)*.01)*15;
  if (i%2 == 0) {
    return -1*off;
  }
  return off;
}
void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(8, 14, 0);
}




PVector radi2card(float r, float th) {
  PVector card = new PVector(0, r);
  return card.rotate(th);
}
