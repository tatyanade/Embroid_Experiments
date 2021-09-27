/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "FrenchKnotty_Packed4"; // CHANGE ME
PEmbroiderGraphics E;


boolean running = true;
boolean debugging = false;

Pack p;



void setup() {
  size(1200, 1600); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  p = new Pack(5, 100, 170);
}


void draw() {
  if (running) {
    background(100);
    p.run();
  } else {


    /// DRAW EMBROIDERY ///////////////////////////////



    background(100); 



    /// begin shape cull
    int cullLayers = 7; // number of layers for culled shape

    for (int j = 0; j<cullLayers; j++) {

      PGraphics pg = createGraphics(width, height);
      pg.beginDraw();
      pg.background(0);
      pg.noStroke();

      pg.pushMatrix();
      pg.translate(width/2, height/2);
      pg.fill(255);
      pg.circle(0, 0, 400);
      pg.popMatrix();

      pg.fill(0);
      for (int i=0; i<p.circles.size(); i++) {
        Circle circ = p.circles.get(i);
        drawMossyCircle( E, int(circ.position.x), int(circ.position.y), int(circ.diameter/16*10), int((circ.diameter-30)/3-20), i, true, pg);
      }

      pg.endDraw();
      E.beginOptimize();
      
      if (j==0) {
        E.fill(0,40,0);
        E.hatchSpacing(6); // decrease per cull (min is 3)
        //setFieldFill(E, j*2,10);
        E.hatchMode(E.CONCENTRIC);
        E.setStitch(20, 30, .1);
        E.hatchRaster(pg);
      } else {
        E.fill(0,40+j*30,0);
        E.hatchSpacing(4); // decrease per cull (min is 3)
        setFieldFill(E, j*2,10+j);
        E.setStitch(60*j*10, 100+j*10, .1);
        setFieldFill(E, j*2,20);
        E.setStitch(100, 140, .1);
        E.hatchRaster(pg);
      }
      E.endOptimize();
    }

    /// end shape cull

 //   E.beginOptimize();

    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      // next line not working in this code
      drawMossyCircle(E, int(circ.position.x), int(circ.position.y), int(circ.diameter/16*10), int((circ.diameter-30)/3-20), i, false, null);
    }
 //   E.endOptimize();



    /// END DRAW EMBROIDERY ///////////////////////////////


    PEmbroiderWrite();
   // checkStitchDens(E);
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


void drawMossyCircle( PEmbroiderGraphics E, int x, int y, int diam1, int diam2, int z, boolean doCull, PGraphics pg) {


  ///// stitching parameters ////
  E.noFill();
  // E.noStroke();
  E.stroke(0, 0, 0); 
  E.strokeLocation(E.INSIDE);
  E.setStitch(20, 40, 0);
  E.hatchSpacing(20);
  E.strokeSpacing(15);
  E.strokeMode(E.TANGENT);
  E.hatchMode(E.CONCENTRIC);
  E.strokeWeight(5);
  ///// stitching parameters ////

  float theta = 0; // convert to radians
  float offset = pow(((abs(diam1-diam2)/2)/10), 2)*2;
  println("circle number " + str(z)+":");
  println(offset);
  println(diam1);
  println(diam2);
  println();

  text(z, x, y);

  //if (diam2 <50) {
  //  diam2 = 50;
  //}

  float ar = 2; // arc length of steps along interior circle
  float thStep = ar*2/(float(diam2)+30*offset/float(diam2));//

  //println(thStep*float(diam2+25)/2);
  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.beginShape();
  if (!doCull) {
    //E.beginShape();
    //while (thSteps < PI*2) {





    //  int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*offset);
    //  int offsetIn = int(noiseLoop(1, thSteps/(2*PI), .5+z)*offset);
    //  if (i%2 == 0) {
    //    connect2CircleVertex(E, thSteps, thSteps+theta, diam1/2+offsetOut, diam2/2+offsetIn);
    //  } else {
    //    connect2CircleVertex(E, thSteps+theta, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
    //  }
    //  thSteps += thStep;//random(0,thStep);
    //  i++;
    //}

    //E.endShape(true);
  } else {
    thSteps = 0;
    pg.pushMatrix();
    pg.translate(x, y);
    pg.beginShape();
    while (thSteps < PI*2) {
      int offsetOut = int(noiseLoop(1, thSteps/(2*PI), 0+z)*offset);
      PVector p = getPointOnRadius(thSteps, diam1/2+offsetOut);
      pg.vertex(p.x, p.y);
      thSteps += thStep;
      i++;
    }
    pg.endShape();
    pg.popMatrix();
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


///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {

  MyVecField mvf = new MyVecField(z,len);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  float z;
  float len;
  MyVecField(float z,float len) {
    this.z = z;
    this.len = len;
  }
  public PVector get(float x, float y) {
    x*=0.01;
    y*=0.01;
    return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
  }
}


////////////////////////////////////////////////////////////////


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


void checkStitchDens(PEmbroiderGraphics E) {
  int rows = height/10;
  int cols = width/10;
  float heightOffset = height/rows;
  float widthOffset = width/cols;

  println("Sample size:");
  println(str(widthOffset) + " x " + str(heightOffset));
  int stitchCounters[][] = new int[rows][cols];

  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  int maxStitches = 0;

  // This loop goes through each point on in E counts how many times the needle down falls within a certain stitch counter
  for (int i = 0; i < lenE; i++) {
    pointLoc = getNeedleDown(E, i);
    int col = int(pointLoc.x/widthOffset);
    int row = int(pointLoc.y/heightOffset);
    stitchCounters[row][col]++;
  }

  for (int row=0; row < rows; row ++) {
    for (int col=0; col < cols; col++) {
      int r = int(float(stitchCounters[row][col])*10);
      if (maxStitches<stitchCounters[row][col]) {
        maxStitches =stitchCounters[row][col];
      }
      noStroke();
      fill(r, 0, 0);
      rect(col*widthOffset, row*heightOffset, widthOffset, heightOffset);
    }
  }


  for (int i = 0; i < lenE; i++) {
    pointLoc = getNeedleDown(E, i);
    fill(255);
    stroke(255, 255, 255, 40);
    point(pointLoc.x, pointLoc.y);
  }

  println("Max Stitches:");
  println(maxStitches);
}

////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////





































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
