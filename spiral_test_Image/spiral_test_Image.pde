// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = ""; // CHANGE ME
PEmbroiderGraphics E;

int frame;

 PImage img;



void setup() {
  size(1024, 675); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  frameRate(30);
  img = loadImage("pearlEaring.jpg");
  img.loadPixels();

}

void draw() {
  
 // background(img);
 background(255);
 
  
  E.clear();
 // E.beginDraw();
  E.pushMatrix();
  E.translate(width/2, height/2);
  float theta = 1;
  float stepLen = 2;
  int steps = 25*1000;
  E.stroke(0);
  E.setStitch(40, 40, .1);
  E.beginShape();
  for (int i=1; i<=steps; i++) {
    float r = theta;
    float thetaStep = stepLen/r;
    PVector coord = radi2card(r+offset(r, theta, i), theta);
    E.vertex(coord.x, coord.y);
    theta+= thetaStep;
  }
  E.endShape();
  E.popMatrix();
 // E.endDraw();
  E.visualize(true,false,false);
  frame++;
}






//////////////////
// FROM IMAGE PROCESSING CODE
//PImage img;

//void setup() {
//  size(640, 360);
//  frameRate(30);
//  img = loadImage("moon-wide.jpg");
//  img.loadPixels();
//  // Only need to load the pixels[] array once, because we're only
//  // manipulating pixels[] inside draw(), not drawing shapes.
//  loadPixels();
//}

//void draw() {
//  for (int x = 0; x < img.width; x++) {
//    for (int y = 0; y < img.height; y++ ) {
//      // Calculate the 1D location from a 2D grid
//      int loc = x + y*img.width;
//      // Get the R,G,B values from image
//      float b;
//      b = brightness((img.pixels[loc]));
//      color c = color(b);
//      pixels[y*width + x] = c;
//    }
//  }
//  updatePixels();
//}
/////////////////////

//
float getPixelBrightness(PImage img, int x, int y){
  int loc = x + y*img.width;
  float b = brightness((img.pixels[loc]));
  return b;    
}






float offset(float r, float theta, int i) {
  PVector coord = radi2card(r,theta).add(new PVector(width/2,height/2));
  float bright = getPixelBrightness(img,int(coord.x),int(coord.y));
  float off = (255-bright)/255*5;
  if (i%2 == 0) {
    return -1*off;
  }
  return off;
}


float offset2(float r, float theta, int i) {
  PVector coord = radi2card(r,theta).add(new PVector(width/2,height/2));
  float bright = getPixelBrightness(img,int(coord.x),int(coord.y));
  float off = bright/255*5;
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
