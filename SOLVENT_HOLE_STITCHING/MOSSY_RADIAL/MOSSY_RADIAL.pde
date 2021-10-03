/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "mossyConcentricStitching"; // CHANGE ME
PEmbroiderGraphics E;

int frames = 0;


boolean running = true;
boolean debugging = false;



void setup() {
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
}


void draw() {

  background(100);
  E.clear();
  drawMossyCircle2(E, width/2, height/2, 400, 100, 1);
  E.visualize(true, true, true);
  PEmbroiderWrite();
  if (frames>80) {
    exit();
  }
  frames++;
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
  E.printStats();
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

void drawMossyCircle2(PEmbroiderGraphics E, int x, int y, int diam1, int diam2, float z) {
  z += float(frames)*.07;
  ///// stitching parameters ////
  E.noFill();
  E.stroke(0, 0, 0); 
  E.strokeWeight(1);
  E.setStitch(10, 20, 1);
  ///// stitching parameters ////

  float theta = random(10); // convert to radians
  float offset = frames*2;//pow(((abs(diam1-diam2)/2)/10), 2)*8; /// double check the usage of this value (not responding as expected)

  float ar = 1.5; // arc length of steps along interior circle
  float overlap = 1;

  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//

  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.noFill();
  E.strokeWeight(1);
  E.stroke(20);

  for (int j = 0; j<1; j++) {
  }

  for (int j = 0; j<1; j++) {
    //// Exterior //////
    theta = 0;
    thSteps = theta;
    E.stroke(180, 0, 0);
    E.beginShape();
    while (thSteps < PI*2+theta) {

      //Exterior
      int offsetVal = int(noiseLoop(1, thSteps/(2*PI), z+1)*offset);
      PVector P = pol2cart(diam1+offsetVal-20, thSteps);
      E.vertex(P.x, P.y);
      thSteps += thStep;//random(0,thStep);
      i++;
    }
    E.endShape(CLOSE);
    //// END Exterior //////'


    //// INTERIOR //////
    theta = 0;
    thSteps = theta;
    E.stroke(180, 0, 0);
    E.beginShape();
    while (thSteps < PI*2+theta) {

      //Interior
      int offsetVal = int(noiseLoop(1, thSteps/(2*PI), z)*offset);
      PVector P = pol2cart(diam2+offsetVal+20, thSteps);
      E.vertex(P.x, P.y);
      thSteps += thStep+.1;//random(0,thStep);
      i++;
    }
    E.endShape(CLOSE);
    //// END INTERIOR //////







    theta = 0;
    thSteps = theta;
    E.stroke(j*10);
    E.beginShape();
    while (thSteps < PI*2+theta) {

      if (i%2 < 1) {
        //Exterior
        int offsetVal = int(noiseLoop(1, thSteps/(2*PI), z+1)*offset);
        PVector P = pol2cart(diam1+offsetVal+overlap, thSteps);
        E.vertex(P.x, P.y);
      } else {
        //Interior
        int offsetVal = int(noiseLoop(1, thSteps/(2*PI), z)*offset);
        PVector P = pol2cart(diam2+offsetVal, thSteps);
        E.vertex(P.x, P.y);
      }
      thSteps += thStep;//random(0,thStep);
      i++;
    }
    E.endShape(CLOSE);
    // set up for next mossy circle
    z += 1;
    diam2 = diam1;
    diam1 += 150;
    thStep = ar*2/(float(diam2)+30*offset/float(diam2));
  }


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
  return noise(x, y, z);
}




//////////////////////////////////////////////////////////////////////////////
