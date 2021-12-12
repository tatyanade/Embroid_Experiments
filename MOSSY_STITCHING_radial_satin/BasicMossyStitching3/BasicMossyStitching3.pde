/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "mossyConcentricStitching"; // CHANGE ME
PEmbroiderGraphics E;

int frames = 0;


boolean running = true;
boolean debugging = false;
float noiseOffset = 20;
int diamOffset = 30;
int initDiam = 30;
int loops = 10;
float k_Global = 1;

float inset_Global = 8;


PImage image;


void setup() {
  image =  loadImage("TEST3.png"); 
  size(1200, 900); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  E.stroke(255, 0, 0);
  //drawMossyCircle2(E, width/2, height/2, initDiam+diam, initDiam, 1, inset_Global*3, inset_Global*3, 4, 1);
  E.stroke(0, 255, 0);
  //drawMossyCircle2(E, width/2, height/2, initDiam+diamOffset, initDiam, 1, inset_Global*2, inset_Global*2, 3, 5);
  E.stroke(0, 0, 255);
  drawMossyCircle3(E, width/2, height/2, initDiam+diamOffset, initDiam, 1, inset_Global, inset_Global, 2, 2);
  E.stroke(0);
  drawMossyCircle3(E, width/2, height/2, initDiam+diamOffset, initDiam, 1, 0, 0, 1, 3);
  filterRect(E);
  filterReline(E);
  E.visualize(true, true, true);
  PEmbroiderWrite(E, "mossyStitching2");
}


void draw() {
  background(100);



  int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)));
  E.visualize(true, true, true, visualInput);
  frames++;
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




/// Knot Functions

void drawKnot1(PEmbroiderGraphics E, int rad, int x, int y) {
  E.pushMatrix();
  E.translate(x, y);

  //E.strokeWeight(4);
  E.circle(0, 0, rad*2);

  // E.strokeWeight(1);
  // drawStarKnot(E, int(rad*1.3/2.00), 7); // .57
  ////drawStarKnot(E, int(rad*25.0/35.0), 13); // .714
  //E.rotate(PI/11);
  //drawStarKnot(E, int(rad*30.0/35.0), 23); // .85
  //drawStarKnot(E, int(rad*35.0/35.0), 23); // 1
  E.popMatrix();
}


void drawStarKnot(PEmbroiderGraphics E, int rad, int steps) {
  float stepSize = PI*2/float(steps);
  float angleDif = PI;
  for (int i = 0; i<steps; i++) {
    if (i%2==0) {
      connectPointsOnCircle(E, stepSize*float(i), stepSize*float(i)+angleDif, rad);
    } else {
      connectPointsOnCircle(E, stepSize*float(i)+angleDif, stepSize*float(i), rad);
    }
  }
}


void connectPointsOnCircle(PEmbroiderGraphics E, float th1, float th2, int rad) {
  //th1 & th2 are in radians
  // centered on zero
  int x1 = int(cos(th1)*rad);
  int y1 = int(sin(th1)*rad);
  int x2 = int(cos(th2)*rad);
  int y2 = int(sin(th2)*rad);
  E.line(x1, y1, x2, y2);
}

////////////////////////////////////




////////////////////////////Mossy circle2 : no double stitch on inside

void drawMossyCircle2(PEmbroiderGraphics E, int x, int y, int diam1, int diam2, float z, float intOffset, float extOffset, float arLen, float filterTest) {
  z += float(frames)*.07;
  ///// stitching parameters ////
  E.noFill();
  E.strokeWeight(1);
  E.setStitch(20, 300, 0);
  ///// stitching parameters ////

  float theta = random(10); // convert to radians
  float offset = diamOffset*k_Global;//pow(((abs(diam1-diam2)/2)/10), 2)*8; /// double check the usage of this value (not responding as expected)

  float ar = arLen; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//

  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.noFill();
  E.strokeWeight(1);

  for (int j = 0; j<loops; j++) {
    theta = 0;
    thSteps = theta;
    E.beginShape();
    while (thSteps < PI*2+theta) {
      float test = diam1+int(noiseLoop(1, thSteps/(2*PI), z+1)*offset)-extOffset-( diam2+int(noiseLoop(1, thSteps/(2*PI), z)*offset)+intOffset);
      if (test > filterTest) {
        if (i%2 == 0) {
          //Exterior
          int offsetVal = int(noiseLoop(1, thSteps/(2*PI), z+1)*offset);
          PVector P = pol2cart(diam1+offsetVal-extOffset, thSteps);
          E.vertex(P.x, P.y);
        } else {
          //Interior
          int offsetVal = int(noiseLoop(1, thSteps/(2*PI), z)*offset);
          PVector P = pol2cart(diam2+offsetVal+intOffset, thSteps);
          E.vertex(P.x, P.y);
        }
      }
      thSteps += thStep;//random(0,thStep);
      i++;
    }
    E.endShape(CLOSE);
    // set up for next mossy circle
    z += 1;
    diam2 = diam1;
    diam1 += diamOffset;
    thStep = ar*2/(float(diam2)+30*offset/float(diam2));
  }
  E.popMatrix();
}


///////////////////
void drawMossyCircle3(PEmbroiderGraphics E, int x, int y, int diam1, int diam2, float z, float intOffset, float extOffset, float arLen, float filterTest) {
  z += float(frames)*.07;
  ///// stitching parameters ////
  E.noFill();
  E.strokeWeight(1);
  E.setStitch(2, 5, 0);
  ///// stitching parameters ////

  float theta = random(10); // convert to radians
  float offset = noiseOffset;//diamOffset*k_Global;

  float ar = arLen; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//

  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.noFill();
  E.strokeWeight(1);

  for (int j = 0; j<loops; j++) {
    E.stroke(int(random(255)),int(random(255)),int(random(255)));
    theta = 0;
    thSteps = theta;
    while (thSteps < PI*2+theta) {
        if (i%2 == 0) {
          //Exterior
          int offsetVal1 = int(noiseLoop(1, thSteps/(2*PI), z+1)*offset);
          int offsetVal2 = int(noiseLoop(1, (thSteps+thStep)/(2*PI), z)*offset);
          PVector P1 = pol2cart(diam1+offsetVal1-extOffset, thSteps);
          PVector P2 = pol2cart(diam2+offsetVal2+intOffset, thSteps+thStep);
          E.line(P1.x, P1.y, P2.x, P2.y);
        } else {
          //Interior
          int offsetVal1 = int(noiseLoop(1, (thSteps+thStep)/(2*PI), z+1)*offset);
          int offsetVal2 = int(noiseLoop(1, (thSteps)/(2*PI), z)*offset);
          PVector P1 = pol2cart(diam1+offsetVal1-extOffset, thSteps+thStep);
          PVector P2 = pol2cart(diam2+offsetVal2+intOffset, thSteps);
          E.line(P2.x, P2.y, P1.x, P1.y);
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



void filterRect(PEmbroiderGraphics E) {
  PEmbroiderGraphics E_Ref = new PEmbroiderGraphics(this, width, height);
  E_Ref.rectMode(CENTER);
  E_Ref.image(image,width/2-image.width/2, height/2-image.width/2);
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
  E.setStitch(10, 10000, 0);
  for (int i=0; i<E.polylines.size(); i++) {
    int polySize = E.polylines.get(i).size();
    if (polySize > 0) {
      PVector P0 = E.polylines.get(i).get(0);
      PVector P1 = E.polylines.get(i).get(polySize-1);
      E.polylines.get(i).clear();
      E.polylines.get(i).add(P0);
      E.polylines.get(i).add(P1);
    }
  }
}
//////////////////////////////////////////////////////////////////////////////
