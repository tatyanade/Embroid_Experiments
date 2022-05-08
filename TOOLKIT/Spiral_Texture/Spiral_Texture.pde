// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "spiral_image"; // CHANGE ME
PEmbroiderGraphics E;

int frame;

PImage img;

/// File picker bits
String globalFileBin;
boolean globalBinFilled = false;
/////


void setup() {
  size(800, 800); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  grabInput();
  img = loadImage(globalFileBin);
  noLoop();
  img.loadPixels();
  
  drawSpiralized(E);
  E.visualize(true,true,true);
  PEmbroiderWrite(E, "spiralizedBits");
}

void draw(){
}


float offset=10;
void drawSpiralized(PEmbroiderGraphics E){
  background(255);
  E.pushMatrix();
  E.translate(width/2, height/2);
  float theta = 1;
  float stepLen = 1.9;
  int steps = 1000*10;
  E.stroke(0);
  E.setStitch(10, 40, 0);
  E.beginShape();
  for (int i=1; i<=steps; i++) {
    float r = theta/(2*PI)*offset*2;
    float thetaStep = stepLen/r;
    PVector coord = radi2card(r+offset(r, theta, i), theta);
    E.vertex(coord.x, coord.y);
    theta+= thetaStep;
  }
  E.endShape();
  E.popMatrix();
}

boolean inbound(PVector P){
  boolean in = true;
  in &= (P.x>0 & P.x<width);
  in &= (P.y>0 & P.y<height);
  return in;
}

float getPixelBrightness(PImage img, int x, int y){
  int loc = x + y*img.width;
  float b = brightness((img.pixels[loc]));
  return b;    
}

float offset(float r, float theta, int i) {
  PVector coord = radi2card(r,theta).add(new PVector(width/2,height/2));
  float bright = getPixelBrightness(img,int(coord.x),int(coord.y));
  float off = (255-bright)/255*offset;// offset amount goes down as the brightness goes up (neg, lin proportionality)
  if(off < 1){
    off = 0;
  }
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

void grabInput(){
  selectInput("Input file here", "fileSelection");
  while(!globalBinFilled){
    println("");
  }
  globalBinFilled = false;
}

void fileSelection(File selection) {
  if (selection == null) {
    globalFileBin = ("Window was closed or the user hit cancel.");
    exit();
  } else {
    globalFileBin = (selection.getAbsolutePath());
  }
  globalBinFilled = true;
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+timeStamp()+".png"); //saves a png of design from canvas
}

String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}
