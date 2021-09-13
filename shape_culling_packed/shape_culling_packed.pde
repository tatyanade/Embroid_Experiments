/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "FrenchKnotty_Packed3"; // CHANGE ME
PEmbroiderGraphics E;


boolean running = true;
boolean debugging = false;

Pack p;



void setup() {
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  p = new Pack(20, 100, 225);
}


void draw() {
  if (running) {
    background(100);
    p.run();
  } else {


    /// DRAW EMBROIDERY ///////////////////////////////



    background(100); 



    /// begin shape cull
    E.CULL_SPACING = 10;

    // CULL .5
    E.hatchMode(PEmbroiderGraphics.PERLIN);
    E.hatchSpacing(20);
    E.fill(0);
    E.beginCull();
    E.pushMatrix();
    E.translate(width/2, height/2);
    E.rotate(0);
    E.hatchAngleDeg(45); 
    E.setStitch(15, 25, .1);
    E.circle(0, 0, 800);
    E.popMatrix();

    


    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      drawMossyCircle( E, int(circ.position.x), int(circ.position.y), int(circ.diameter/16*10), int((circ.diameter-70)/3), i, true);
    }
    E.endCull();

    // CULL 1
    E.hatchMode(PEmbroiderGraphics.PERLIN);
    E.hatchSpacing(5);
    E.fill(0);
    E.beginCull();
    E.pushMatrix();
    E.translate(width/2, height/2);
    E.rotate(3);
    E.hatchAngleDeg(45); 
    E.setStitch(30, 50, .1);
    E.circle(0, 0, 800);
    E.popMatrix();

    


    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      drawMossyCircle( E, int(circ.position.x), int(circ.position.y), int(circ.diameter/16*10), int((circ.diameter-70)/3), i, true);
    }
    E.endCull();
    
    // CULL 2
    E.hatchMode(PEmbroiderGraphics.PERLIN);
    E.hatchSpacing(3);
    E.fill(0);
    E.beginCull();
    E.pushMatrix();
    E.translate(width/2, height/2);
    E.rotate(7);
    E.hatchAngleDeg(45); 
    E.setStitch(60, 80, .1);
    E.circle(0, 0, 800);
    E.popMatrix();

    


    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      drawMossyCircle( E, int(circ.position.x), int(circ.position.y), int(circ.diameter/16*10), int((circ.diameter-70)/3), i, true);
    }
    E.endCull();
    
    E.optimize();
    
    
    /// end shape cull


    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      drawMossyCircle( E, int(circ.position.x), int(circ.position.y), int(circ.diameter/16*10), int((circ.diameter-70)/3), i, false);
    }



    /// end shape culling

    /// END DRAW EMBROIDERY ///////////////////////////////

     E.optimize();
    PEmbroiderWrite();
    noLoop();
  }
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
  E.visualize(true, true, true);//true, true, true);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
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


///////////////////// MOSSY HELPERS ////////////////////////////////////


void drawMossyCircle( PEmbroiderGraphics E, int x, int y, int diam1, int diam2, int z, boolean doCull) {


  ///// stitching parameters ////
  E.noFill();
  E.stroke(0, 0, 0); 
  E.strokeWeight(1);
  E.setStitch(20, 300, 0);
  ///// stitching parameters ////

  float theta = 0; // convert to radians
  float offset = pow(((abs(diam1-diam2)/2)/10), 2)*2;
  println("circle number " + str(z)+":");
  println(offset);
  println(diam1);
  println(diam2);
  println();

  text(z, x, y);

  if (diam2 <50) {
    diam2 = 50;
  }

  float ar = 2; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//

  //println(thStep*float(diam2+25)/2);
  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.noFill();
  E.strokeWeight(1);
  E.stroke(20);

  E.beginShape();
  if (!doCull) {
    while (thSteps < PI*2) {
      int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*offset);
      int offsetIn = int(noiseLoop(1, thSteps/(2*PI), .5+z)*offset);
      if (i%2 == 0) {
        connect2CircleVertex(E, thSteps, thSteps+theta, diam1/2+offsetOut, diam2/2+offsetIn);
      } else {
        connect2CircleVertex(E, thSteps+theta, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
      }
      thSteps += thStep;//random(0,thStep);
      i++;
    }
  } else {
    E.hatchMode(PEmbroiderGraphics.PARALLEL); 
    E.hatchSpacing(5);
    E.fill(170);
    E.setStitch(10, 20, .1);
    E.noStroke();
    E.beginShape();
    thSteps = 0;
    while (thSteps < PI*2) {
      int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*offset);
      PVector p = getPointOnRadius(thSteps, diam1/2+offsetOut);
      E.vertex(p.x, p.y);

      //if (i%2 == 0) {
      // connect2CircleVertex(E, thSteps, thSteps+theta, diam1/2+offsetOut, diam2/2+offsetIn);
      //} else {
      // connect2CircleVertex(E, thSteps+theta, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
      //}
      thSteps += thStep;//random(0,thStep);
      i++;
    }
  }
  E.endShape(CLOSE);

  E.popMatrix();
}






void drawMossyCircle_CULL( PEmbroiderGraphics E, int x, int y, int diam1, int diam2, int z) {


  ///// stitching parameters ////
  E.noFill();
  E.stroke(0, 0, 0); 
  E.strokeWeight(1);
  E.setStitch(20, 300, 0);
  ///// stitching parameters ////


  float theta = 0; // convert to radians
  float offset = 50;

  if (diam2 <50) {
    diam2 = 50;
  }

  float ar = 2; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//
  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.hatchMode(PEmbroiderGraphics.PARALLEL); 
  E.hatchSpacing(5);
  E.fill(170);
  E.setStitch(10, 20, .1);
  E.noStroke();
  E.beginShape();
  thSteps = 0;
  while (thSteps < PI*2) {
    int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*50.00);
    PVector p = getPointOnRadius(thSteps, diam1/2+offsetOut);
    E.vertex(p.x, p.y);

    //if (i%2 == 0) {
    // connect2CircleVertex(E, thSteps, thSteps+theta, diam1/2+offsetOut, diam2/2+offsetIn);
    //} else {
    // connect2CircleVertex(E, thSteps+theta, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
    //}
    thSteps += thStep;//random(0,thStep);
    i++;
  }
  E.endShape(CLOSE);

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


































///////////////// Original circle packing code from Alberto Giachino
/// source page: http://www.codeplastic.com/2017/09/09/controlled-circle-packing-with-processing/



class Circle {
  PVector position;
  PVector velocity;
  PVector acceleration;

  float diameter;
  Circle(float x, float y, float diam, PVector initVel) {
    acceleration = new PVector(0, 0);
    velocity = initVel;//PVector.random2D();
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

  Pack(int numCircles, float minRad, float maxRad) {  
    initiate(numCircles, minRad, maxRad);
  }
  void initiate(int numCircles, float minRad, float maxRad) {
    PVector initVel = new PVector(.1, 0);
    int circlesAmount = numCircles ;
    circles = new ArrayList<Circle>(); 
    for (int i = 0; i < circlesAmount; i++) {
      addCircle(new Circle(width/2, height/2, random(minRad, maxRad), initVel.copy()));
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

  float kSep = 3.45;
  float kAtr = .1;
  PVector getSeparationForce(Circle n1, Circle n2) {
    PVector steer = new PVector(0, 0, 0);
    float d = PVector.dist(n1.position, n2.position);
    if ((d > 0) && (d < n1.diameter/2+n2.diameter/2)) {
      // we apply a force that drops off with d^8 because this goes to zero very quickly it seems to create a good distribution
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      PVector sep = diff.copy().div(pow(d, 6)/kSep);
      steer.add(sep);
    }
    return steer;
  }
  void displayCircle(int i) {
    circles.get(i).display();
  }
}
