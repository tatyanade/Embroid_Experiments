/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "mossyConcentricStitching"; // CHANGE ME
PEmbroiderGraphics E;

int frames = 0;


boolean running = true;
boolean debugging = false;
float noiseOffset = 40;
int diamOffset = 60;
int initDiam = 30;
int loops = 8;
float k_Global = 1;

float inset_Global = 8;


PImage image;


void setup() {
  size(850, 1650); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  E.stroke(255, 0, 0);
  E.stroke(0, 0, 255);
  drawDoublMossyCirlce(E, width/4, height/4, 1, int(random(50,300)));
  
  drawDoublMossyCirlce(E, width/4*3, height/4, 2, int(random(50,300)));
  
  drawDoublMossyCirlce(E, width/4, height/2, 1, int(random(50,300)));
  
  drawDoublMossyCirlce(E, width/4*3, height/2, 2, int(random(50,300)));
  
  drawDoublMossyCirlce(E, width/4, height/4*3, 3, int(random(50,300)));
  
  drawDoublMossyCirlce(E, width/4*3, height/4*3, 4, int(random(50,300)));
  filterReline(E);
  E.visualize(true, true, true);
  PEmbroiderWrite(E, "mossyStitching2");
}


void draw() {
  background(100);
  int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)));
  E.visualize(true, true, true, visualInput);
}


void keyPressed() {
  if (key == ' ') {
    running = false;
  }
}


//////// run these at begginning and end of setup ////////////////////////////////////

void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(8, 14, .1);
}

void PEmbroiderWrite() {
  String outputFilePath = sketchPath(fileName+str(frames)+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+str(frames)+".png"); //saves a png of design from canvas
}

///////////////////////////////////////////////////////////////////////////////////////










void drawDoublMossyCirlce(PEmbroiderGraphics E, int x, int y, float z, int diamOffset){
  PVector centOff = new PVector(random(-200,200),random(-200,200));
  E.stroke(int(random(255)),int(random(255)),int(random(255)));
  drawMossyCircle(E, x, y, 40, z, 20, 2,centOff, diamOffset);
  drawMossyCircle(E, x, y, 40, z, 10, 1.5,centOff, diamOffset);
  drawMossyCircle(E, x, y, 40, z, 0, 1,centOff, diamOffset);
}


///////////////////
void drawMossyCircle(PEmbroiderGraphics E, int x, int y, int diam2, float z, float zigOffset, float arLen,PVector centOff, int diamOffset) {
  float filterTest = 4;
  float extOffset = zigOffset;
  float intOffset = zigOffset;
  z += float(frames)*.07;
  ///// stitching parameters ////
  E.noFill();
  E.strokeWeight(1);
  E.setStitch(1, 2, 0);
  
  ////
  PEmbroiderGraphics E_Ref = new PEmbroiderGraphics(this, width, height);
  E_Ref.rectMode(CENTER);
 E_Ref.rect(x,y,400,400);
  
  ///// stitching parameters ////

  float theta = random(10); // convert to radians
  float offset = noiseOffset;//diamOffset*k_Global;
  int diam1 = diam2 + diamOffset;

  float ar = arLen; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//

  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x+centOff.x, y+centOff.y);

  E.noFill();
  E.strokeWeight(1);

  for (int j = 0; j<loops; j++) {
    println(offsetMultiplier(diam2));
  //  E.stroke(int(random(255)),int(random(255)),int(random(255)));
    theta = 0;
    thSteps = theta;
    while (thSteps < PI*2+theta) {
      float test = diam1+int(noiseLoop(1, thSteps/(2*PI), z+1)*offset*offsetMultiplier(diam1))-extOffset-( diam2+int(noiseLoop(1, thSteps/(2*PI), z)*offset*offsetMultiplier(diam2))+intOffset);
      if (test > filterTest) {
        if (i%2 == 0) {
          //Exterior
          int offsetVal1 = int(noiseLoop(1, thSteps/(2*PI), z+1)*offset*offsetMultiplier(diam1));
          int offsetVal2 = int(noiseLoop(1, (thSteps+thStep)/(2*PI), z)*offset*offsetMultiplier(diam2));
          PVector P1 = pol2cart(diam1+offsetVal1-extOffset, thSteps);
          PVector P2 = pol2cart(diam2+offsetVal2+intOffset, thSteps+thStep);
          E.line(P1.x, P1.y, P2.x, P2.y);
        } else {
          //Interior
          int offsetVal1 = int(noiseLoop(1, (thSteps+thStep)/(2*PI), z+1)*offset*offsetMultiplier(diam1));
          int offsetVal2 = int(noiseLoop(1, (thSteps)/(2*PI), z)*offset*offsetMultiplier(diam2));
          PVector P1 = pol2cart(diam1+offsetVal1-extOffset, thSteps+thStep);
          PVector P2 = pol2cart(diam2+offsetVal2+intOffset, thSteps);
          E.line(P2.x, P2.y, P1.x, P1.y);
        }
        filterInPoly(E,E_Ref);
      }
      thSteps += thStep;//random(0,thStep);
      i++;
    }
    // set up for next mossy circle
    z += 1;
    diam2 = diam1;
    diam1 += diamOffset;
    thStep = ar*2/(float(diam2)+30*offset/float(diam2));
  }
  E.popMatrix();
  E_Ref.visualize();
}


float offsetMultiplier(float diam){
  float k = 10000;
  float a =1;
  float b = -k/a;
  float val = -k/(pow(diam,2.2)-b)+a;
  return val;
}



///////////////







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


PVector pol2cart(float r, float theta) {
  int x = int(cos(theta)*r);
  int y = int(sin(theta)*r);
  return new PVector(x, y);
}

PVector getPointOnRadius(float th, int rad) {
  int x = int(cos(th)*rad);
  int y = int(sin(th)*rad);
  return new PVector(x, y);
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
  return (noise(x, y, z)-.5)*2;
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


int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size();
  }
  return n;
}

PVector getND(PEmbroiderGraphics E, int ndIndex) {
  //get the ith needle down
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      if (n >= ndIndex) {
        return needleLoc;
      }
      n++;
    }
  }
  return null; //will return null if the index is outside the needle down list
}

void moveE(PEmbroiderGraphics E, PVector V){
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      E.polylines.get(i).get(j).add(V);
    }
  }
}

void moveE(PEmbroiderGraphics E, float x,float y){
  moveE(E, new PVector(x,y));
}

void filterRect(PEmbroiderGraphics E) {
  PEmbroiderGraphics E_Ref = new PEmbroiderGraphics(this, width, height);
  E_Ref.rectMode(CENTER);
 // E_Ref.image(image,width/2-image.width/2, height/2-image.width/2);
 E_Ref.rect(width/2,height/2,400,800);
 // E_Ref.visualize();
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      boolean isInPoly = E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(0));
      if (!isInPoly) {
        collection.add(needleLoc0);
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

void filterReline(PEmbroiderGraphics E) {
  float minLength = 1.8;
  E.setStitch(10, 10000, 0);
  for (int i=0; i<E.polylines.size(); i++) {
    int polySize = E.polylines.get(i).size();
    if (polySize > 0) {
      PVector P0 = E.polylines.get(i).get(0);
      PVector P1 = E.polylines.get(i).get(polySize-1);
      E.polylines.get(i).clear();
      if(P0.copy().sub(P1).mag()>=minLength){
      E.polylines.get(i).add(P0);
      E.polylines.get(i).add(P1);
      }
    }
  }
}


void filterInPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref){
  int i = E.polylines.size()-1;
  ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      boolean isInPoly = E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(0));
      if (!isInPoly) {
        collection.add(needleLoc0);
      }
    }
    E.polylines.get(i).removeAll(collection);
}

void filterInSomePoly(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref){
}

//////////////////////////////////////////////////////////////////////////////
