/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "mossyConcentricStitching"; // CHANGE ME
PEmbroiderGraphics E;

void setup() {
  size(1200, 1800); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  
  /// draw 1
  E.noFill();
  E.stroke(0);
  E.strokeWeight(1);
  E.setStitch(6, 8, 0);
 drawMossyUnderlay(E, width/2, height/2, 600,0, 7);
  
  /// draw 2
  E.noStroke();
  E.fill(221, 245, 66);
  E.hatchMode(E.CROSS);
  E.hatchSpacing(12);
  E.setStitch(5, 10, 0);
  drawMossyUnderlay(E, width/2, height/2, 600,30,3);
  
  
  /// draw 3
  E.noFill();
  E.stroke(0,255,0);
  E.strokeSpacing(10);
  E.strokeWeight(25);
  E.setStitch(5, 10, 1);
  drawMossyUnderlay(E, width/2, height/2, 600,15, 20);
  
  /// draw 4
  E.noFill();
  E.stroke(0,0,255);
  E.strokeSpacing(2);
  E.strokeWeight(60);
  E.setStitch(20, 200, 0);
  drawMossyUnderlay(E, width/2, height/2, 600,10, 20);
  
  

  PEmbroiderWrite(E, "NegativeLace_Hole");
}

void draw() {
  background(100);
  int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)+30));
  E.visualize(true, true, true, visualInput);
}


void keyPressed() {
  if (key == ' ') {
    PEmbroiderWrite(E, "NegativeLace_Hole");
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
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}

///////////////////////////////////////////////////////////////////////////////////////



void drawMossyUnderlay(PEmbroiderGraphics E, int x, int y, float diam, float extOff, float arLen) {
  float ar = arLen; // arc length of steps along interior circle arLen = r*th = d/2*th ---> th = 
  float offset = 275;//diamOffset*k_Global;

  ///// stepping parameters ///
  float thSteps = 0;



  ////// translate ///////
  E.pushMatrix();
  E.translate(x, y);
  
  
  E.beginOptimize();
  E.beginShape();
  while(thSteps < 2*PI) {

    //Exterior
    int offsetVal1 = int(noiseLoop(.25, thSteps/(2*PI), 0)*offset);
    PVector P1 = pol2cart(diam/2 + offsetVal1+extOff, thSteps);
    E.vertex(P1.x,P1.y);
    
    //Step theta 
    float thStep = ar/(diam/2 + offsetVal1);
    thSteps += thStep;//random(0,thStep);
  }
  E.endShape(CLOSE);
  E.endOptimize();
  // set up for next mossy circle

  E.popMatrix();
}




/////







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
  float theta = t*2*PI; // map t to theta
  float x = cos(theta)*rad+rad;
  float y = sin(theta)*rad+rad;
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

void moveE(PEmbroiderGraphics E, PVector V) {
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      E.polylines.get(i).get(j).add(V);
    }
  }
}

void moveE(PEmbroiderGraphics E, float x, float y) {
  moveE(E, new PVector(x, y));
}

void filterRect(PEmbroiderGraphics E) {
  PEmbroiderGraphics E_Ref = new PEmbroiderGraphics(this, width, height);
  E_Ref.rectMode(CENTER);
  // E_Ref.image(image,width/2-image.width/2, height/2-image.width/2);
  E_Ref.rect(width/2, height/2, 400, 800);
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
      if (P0.copy().sub(P1).mag()>=minLength) {
        E.polylines.get(i).add(P0);
        E.polylines.get(i).add(P1);
      }
    }
  }
}


void filterInPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref) {
  int i = E.polylines.size()-1;
  ArrayList<PVector> collection =  new ArrayList<PVector>();
  for (int j=0; j<E.polylines.get(i).size(); j++) {
    PVector needleLoc0 = E.polylines.get(i).get(j).copy();
    boolean isInPoly = E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(0)) && !E_Ref.pointInPolygon(needleLoc0, E_Ref.polylines.get(1));
    if (!isInPoly) {
      collection.add(needleLoc0);
    }
  }
  E.polylines.get(i).removeAll(collection);
}

void filterInSomePoly(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref) {
}

//////////////////////////////////////////////////////////////////////////////



////// KNOTTY FUNCTIONS /////
void drawKnot1(PEmbroiderGraphics E, float rad, float x, float y) {
  E.pushMatrix();
  E.translate(x, y);
  E.setStitch(4, 400, 0);
  
  drawStarKnot(E, int(rad-7*3), 4);
  
  drawStarKnot(E, int(rad-7*2), 3.5);

  drawStarKnot(E, int(rad-7), 3.5);

  E.rotate(PI/11);
  drawStarKnot(E, int(rad), 2.5); // .85
  E.popMatrix();
}


void drawStarKnot(PEmbroiderGraphics E, float rad, float arLen) {
  println("/////radius:");
  println(rad*2);
  println("/////////");
  if (rad*2>=5) {

    float thStep = arLen/rad;

    float thSteps = 0;
    int i = 0;

    float angleDif = PI;

    while (thSteps < PI*1.1) {
      if (i%2==0) {
        connectPointsOnCircle(E, thSteps, thSteps+angleDif, rad);
      } else {
        connectPointsOnCircle(E, thSteps+angleDif, thSteps, rad);
      }
      thSteps += thStep;
      i++;
    }
  }
}


void connectPointsOnCircle(PEmbroiderGraphics E, float th1, float th2, float rad) {
  //th1 & th2 are in radians
  // centered on zero
  float x1 = (cos(th1)*rad);
  float y1 = (sin(th1)*rad);
  float x2 = (cos(th2)*rad);
  float y2 = (sin(th2)*rad);
  E.line(x1, y1, x2, y2);
}
