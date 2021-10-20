// Circles Along PEmbroider Path
//   
// In this code uses two PEmbroiderGraphics objects. 
// We create a path in the first object, E, and then step through the points in E.
// At each point in E we draw a cirlce in E2 so that we end up with a shape filled with circles
//
// E is just a refference object and E2 writes out


/// PEMBROIDER SETUP///
import processing.embroider.*;
PEmbroiderGraphics E;
PEmbroiderGraphics E2;
int stitchPlaybackCount = 0;
int lastStitchTime = 0;
PVector center;

/// FILE NAME /////
String fileType = ".pes";
String fileName = "loop_circle-1"; // CHANGE ME

// LOOP VARIABLES ///
boolean loop = false;
int frame = 0;
int overlaps = 0;

// DIFF LINE VARIABLES //
float _maxForce = 1; // Maximum steering force
float _maxSpeed = 2; // Maximum speed
float _desiredSeparation = 30;
float _separationCohesionRation = 1.001;
float _maxEdgeLen = 10;
DifferentialLine _diff_line;

boolean doEndMotion = false;
boolean addEdge = true;
boolean showVisuals = true; // slower but pretty
boolean animateSim = true;

ArrayList<Node> setNodes;



void setup() {
  size(800, 800);

  setNodes = new ArrayList<Node>();
  
  

  //// DEFINE EMBROIDERY DESIGN HERE ////////////////// <------------------------------------------------ CHANGE HERE ----------------------

  E = new PEmbroiderGraphics(this, width, height);
  E2 = new PEmbroiderGraphics(this, width, height); // ref object
  E.beginDraw();
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);

  String filePath = sketchPath("dif_coral_"+timeStamp()+".pes");
  E.setPath(filePath);
  E.beginDraw();

  E.toggleResample(true);
  E.setStitch(20, 30, 0);
  E.stroke(180, 0, 0);
  E.translate(width/2, height/2);
  E.translate(-width/2, -height/2);

  E2.setStitch(4, 6, 0);
  E2.noFill();
  E2.CIRCLE_DETAIL = 6;
  int w= 500;
  int h= 500;
  //E2.rect(width/2-w/2, height/2-h/2, w, h);
  E2.circle(width/2,height/2,w*1.5);

  if (addEdge) {
    addSetNodes(E2, setNodes);
  }

  _diff_line = new DifferentialLine(_maxForce, _maxSpeed, _desiredSeparation, _separationCohesionRation, _maxEdgeLen);
  float nodesStart = 20;
  float angInc = TWO_PI/nodesStart;
  float rayStart = 50;
  for (float a=0; a<TWO_PI; a+=angInc) {
    float x = width/2 + cos(a) * rayStart;
    float y = height/2 + sin(a) * rayStart;
    _diff_line.addNode(new Node(x, y, _diff_line.maxForce, _diff_line.maxSpeed, _diff_line.desiredSeparation, _diff_line.separationCohesionRation));
  }
  if (!animateSim) {
    for (int i = 0; i <350; i++) {
      println(i);
      _diff_line.run();
    }
    _diff_line.renderLoop(E);
  }

  E.visualize(true, true, true);
  save(fileName+".png"); //saves a png of design from canvas
}


void draw() {
  if (animateSim) {
    background(180);
    _diff_line.run();
    E.clear();
    _diff_line.renderLoop(E);
    E.visualize(true, true, true);
  }
}

void keyPressed(){
  if(key == ' '){
    writeOut(E,frameCount);
  }
}



void writeOut(PEmbroiderGraphics E, int i){
  String filePath = sketchPath("OUTPUT"+timeStamp()+i+".pes");
  E.setPath(filePath);
  E.endDraw();
}







////////////////////// NEEDLE DOWN HELPERS ////////////////////////////////////////////////////////////

PVector getNeedleDown(PEmbroiderGraphics E, int ndIndex) {
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

int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      n++;
    }
  }
  return n;
}

////////////////////// LOOP HELPERS ////////////////////////////////////////////////////////
float loopLineAngle = PI/2;

void drawLoopLine(float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap) {  
  float r = circleRad;
  float cx = startX;
  float cy = startY;

  float lineLength = dist(startX, startY, endX, endY);
  float numCycles = (lineLength/r)*(1/overlap);

  float angleDifference = stitchLength/r;
  float pointsPerCircle = TWO_PI/angleDifference;
  float numSteps = pointsPerCircle*numCycles ;

  float dx = (endX-startX)/ numSteps;
  float dy = (endY-startY)/ numSteps;

  float curCX = cx;
  float curCY = cy;
  for (int i = 0; i < numSteps; i++) {
    float curX = curCX+(r * cos(loopLineAngle));
    float curY = curCY+(r * sin(loopLineAngle));

    E2.vertex(curX, curY);
    circle(curX, curY, 1);

    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;
  }
}


String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}

void addSetNodes(PEmbroiderGraphics E, ArrayList<Node> setNodes) {
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector ND = E.polylines.get(i).get(j).copy();
      setNodes.add(new Node(ND.x, ND.y, true));
    }
  }
}
