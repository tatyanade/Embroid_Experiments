// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = ""; // CHANGE ME
PEmbroiderGraphics E;

int frame;
int nFrames = 70;


int kStitches = 5; // thousands of stitches
float spiralSpacing = 2;
float initTheta = 0;
 



void setup() {
  size(480, 640); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  frameRate(10);

}

void draw() {
  String imageFilename = "frame" + nf((frame%nFrames+1), 3) + ".png";
  drawBlackAndWhite(imageFilename);
  frame++;
}


void drawBlackAndWhite(String imageFilename){
  PImage img;
  img = loadImage(imageFilename);
  img.loadPixels();
  background(255);
  E.clear();
  E.pushMatrix();
  E.translate(width/2, height/2);
  float theta = PI;
  float stepLen = 3;
  int steps = kStitches*1000;
  E.stroke(0);
  E.setStitch(40, 40, .1);
  initTheta = noise(frame*.01)*2*PI; // rotates the spiral without affecting the roation of the graphic
  println(initTheta);
  E.beginShape();
  for (int i=1; i<=steps; i++) {
    float r = theta*spiralSpacing;
    float thetaStep = stepLen/r;
    PVector coord = radi2card(r+offset(r, theta+initTheta, i, img), theta+initTheta);
    E.vertex(coord.x, coord.y);
    theta+= thetaStep;
  }
  E.endShape();
  E.popMatrix();
 // E.endDraw();
  E.visualize(true,true,true);
  println(maxBrightness);
}



float maxBrightness = 0;

float getPixelBrightness(PImage img, int x, int y){
  int loc = x + y*img.width;
  float b = brightness((img.pixels[loc]));
  if(b>maxBrightness){
    maxBrightness = b;
  }
  return b;    
}

float offset(float r, float theta, int i, PImage img) {
  PVector coord = radi2card(r,theta).add(new PVector(width/2,height/2));
  float bright = getPixelBrightness(img,int(coord.x),int(coord.y));
  
  float off = bright/255*2; // THIS CODE CURRENTLY WORKS BEST WITH SILHOUTTES OF WHITE ON BLACK
  if(off > 0){
    // add some randomness 
    off += noise(theta,frame*.5)*3;
  }
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
