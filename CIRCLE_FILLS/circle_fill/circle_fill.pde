/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "circle_fill_5"; // CHANGE ME
PEmbroiderGraphics E;

// Setup draw loop
boolean loop = true;
int frame = 0;

boolean running = true;


float circleMax = 50;
float circleMin = 20;

Pack p;

void setup() {
  size(1000, 1200); //100 px = 1 cm (so 14.2 cm is 1420px)
  if (!loop) {
    noLoop();
  }
  PEmbroiderStart();
  p = new Pack(); 
}


void draw() {
  if (running) {
    background(100);
    p.run();
  } else {
    convertToEmbroidery();
  }
}

void convertToEmbroidery(){
    //E.scale(2);
    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      int circX =  int(p.circles.get(i).position.x);
      int circY = int(p.circles.get(i).position.y);
      int circRad = int(p.circles.get(i).radius);
      fill(random(0,255),random(0,255),random(0,255));
      //text( str(circX) + " ," + str(circY) + " " + str(circRad), circX, circY);  
      text( str(circX) + " ," + str(circY) + " " + str(circRad), circX, circY);      

    }
    
    //E.optimize();
    // background(100);
    
    
        for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      int circX =  int(p.circles.get(i).position.x);
      int circY = int(p.circles.get(i).position.y);
      int circRad = int(p.circles.get(i).radius + random(5,30) );
      //fill(123,122,9);
      //text( str(circX) + " ," + str(circY), circX, circY);
     
      E.circle( circX, circY, circRad); 
      
    }
    PEmbroiderWrite();
    noLoop();

}

void stopRunning(){
  running = false;
}

void keyPressed(){
  if(key == ' '){
    stopRunning();
  }
}


//////// run these at begginning and end of setup ////////////////////////////////////

void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(10, 30, .1);
}

void PEmbroiderWrite() {
  E.optimize();
  E.visualize(true, true, true);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}


///////////////// Original circle packing code from Alberto Giachino
/// source page: http://www.codeplastic.com/2017/09/09/controlled-circle-packing-with-processing/



class Circle {
  PVector position;
  PVector velocity;
  PVector acceleration;

  float radius;
  Circle(float x, float y, float rad,PVector initVel) {
    acceleration = new PVector(0, 0);
    velocity = initVel;//PVector.random2D();
    position = new PVector(x, y);
    radius = rad;
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
    circle(position.x, position.y, radius);
  }
}



class Pack {
  ArrayList<Circle> circles;
  float max_speed = 1;
  float max_force = 1;
  Pack() {  
    initiate();
  }
  void initiate() {
    PVector initVel = new PVector(.1,0);
    int circlesAmount = 65 ;
    circles = new ArrayList<Circle>(); 
    for (int i = 0; i < circlesAmount; i++) {
      addCircle(new Circle(width/2, height/2, random(circleMin,circleMax),initVel.copy()));
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
    if (circle_i.position.x-circle_i.radius/2 < 0 || circle_i.position.x+circle_i.radius/2 > width)
    {
      circle_i.velocity.x*=-1;
      circle_i.update();
    }
    if (circle_i.position.y-circle_i.radius/2 < 0 || circle_i.position.y+circle_i.radius/2 > height)
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
      if (d < circle_i.radius/2+circle_j.radius/2) {
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
    if ((d > 0) && (d < n1.radius/2+n2.radius/2)) {
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
