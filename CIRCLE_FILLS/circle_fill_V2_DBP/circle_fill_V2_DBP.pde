/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "FrenchKnotty_Packed3"; // CHANGE ME
PEmbroiderGraphics E;

// Setup draw loop
boolean loop = true;
int frame = 0;

boolean running = true;

Pack p;



void setup() {
  size(600, 600); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  p = new Pack(20,20,40);
  
}

int frames;

void draw() {
  if (running) {
    background(100);
    p.run();
  } else {
    background(100);
    E.visualize(true,true,true,frames);
    frames++;
  }
}


void keyPressed(){
  if(key == ' '){
    running = false;
    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      E.circle(circ.position.x,circ.position.y,circ.diameter);
      drawKnot1(E,circ.diameter/2,circ.position.x,circ.position.y);
    }
  }
}


void mousePressed(){
  p.circles.add(new Circle(mouseX,mouseY,random(20,40)));
}

void mouseDragged(){
  p.circles.add(new Circle(mouseX,mouseY,random(20,40)));
}


//////// run these at begginning and end of setup ////////////////////////////////////

void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(8, 14, .1);
}

void PEmbroiderWrite() {
  E.visualize(true, true, true);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}

///////////////////////////////////////////////////////////////////////////////////////

//// Knot Functions

void drawKnot1(PEmbroiderGraphics E, float rad, float x, float y) {
  E.pushMatrix();
  E.translate(x, y);
  E.setStitch(4,400,0);

  E.circle(0, 0, rad*2);

  E.strokeWeight(1);
   drawStarKnot(E, int(rad/2), 7); // .57
  drawStarKnot(E, int(rad*3/4), 13); // .714
  E.rotate(PI/11);
  drawStarKnot(E, int(rad), 21); // .85
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




































///////////////// Original circle packing code from Alberto Giachino
/// source page: http://www.codeplastic.com/2017/09/09/controlled-circle-packing-with-processing/



class Circle {
  PVector position;
  PVector velocity;
  PVector acceleration;

  float diameter;
  Circle(float x, float y, float diam,PVector initVel) {
    acceleration = new PVector(0, 0);
    velocity = initVel;//PVector.random2D();
    position = new PVector(x, y);
    diameter = diam;
  }
  
  Circle(float x, float y, float diam){
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
    position = new PVector(x, y);
    diameter = diam;
  }
  
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }
  void display() {
    circle(position.x, position.y, diameter);
  }
}



class Pack {
  ArrayList<Circle> circles;
  float max_speed = 1;
  float max_force = 1;
  
  Pack(int numCircles,float minRad, float maxRad) {  
    initiate(numCircles,minRad,maxRad);
  }
  void initiate(int numCircles,float minRad, float maxRad) {
    PVector initVel = new PVector(.1,0);
    int circlesAmount = numCircles ;
    circles = new ArrayList<Circle>(); 
    for (int i = 0; i < circlesAmount; i++) {
      addCircle(new Circle(width/2, height/2, random(minRad,maxRad),initVel.copy()));
      initVel.rotate(2*PI/circlesAmount);
    }
  }
  void addCircle(Circle b) {
    circles.add(b);
  }
  void run() {
    PVector[] separate_forces = new PVector[circles.size()];
    int[] near_circles = new int[circles.size()];
    for (int i=0; i<circles.size(); i++) {
      checkBorders(i);
      checkCirclePosition(i);
      applySeparationForcesToCircle(i, separate_forces, near_circles);
      displayCircle(i);
    }
  }
  void checkBorders(int i) {
    Circle circle_i=circles.get(i);
    if (circle_i.position.x-circle_i.diameter/2 < 0 || circle_i.position.x+circle_i.diameter/2 > width)
    {
      circle_i.velocity.x*=-1;
      circle_i.update();
    }
    if (circle_i.position.y-circle_i.diameter/2 < 0 || circle_i.position.y+circle_i.diameter/2 > height)
    {
      circle_i.velocity.y*=-1;
      circle_i.update();
    }
  }
  void checkCirclePosition(int i) {
    Circle circle_i=circles.get(i);
    for (int j=i+1; j<=circles.size(); j++) {
      Circle circle_j = circles.get(j == circles.size() ? 0 : j);
      int count = 0;
      float d = PVector.dist(circle_i.position, circle_j.position);
      if (d < circle_i.diameter/2+circle_j.diameter/2) {
        count++;
      }
      // Zero velocity if no neighbours
      if (count == 0) {
        circle_i.velocity.x = 0.0;
        circle_i.velocity.y = 0.0;
      }
    }
  }
  void applySeparationForcesToCircle(int i, PVector[] separate_forces, int[] near_circles) {
    if (separate_forces[i]==null)
      separate_forces[i]=new PVector();
    Circle circle_i=circles.get(i);
    for (int j=i+1; j<circles.size(); j++) {
      if (separate_forces[j] == null) 
        separate_forces[j]=new PVector();
      Circle circle_j=circles.get(j);
      PVector forceij = getSeparationForce(circle_i, circle_j);
      if (forceij.mag()>0) {
        separate_forces[i].add(forceij);        
        separate_forces[j].sub(forceij);
        near_circles[i]++;
        near_circles[j]++;
      }
    }
    if (near_circles[i]>0) {
      separate_forces[i].div((float)near_circles[i]);
    }
    if (separate_forces[i].mag() >0) {
      separate_forces[i].setMag(max_speed);
      separate_forces[i].sub(circles.get(i).velocity);
      separate_forces[i].limit(max_force);
    }
    PVector separation = separate_forces[i];
    circles.get(i).applyForce(separation);
    circles.get(i).update();
  }
  PVector getSeparationForce(Circle n1, Circle n2) {
    PVector steer = new PVector(0, 0, 0);
    float d = PVector.dist(n1.position, n2.position);
    if ((d > 0) && (d < n1.diameter/2+n2.diameter/2)) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(d);
      steer.add(diff);
    }
    return steer;
  }
  void displayCircle(int i) {
    circles.get(i).display();
  }
}
