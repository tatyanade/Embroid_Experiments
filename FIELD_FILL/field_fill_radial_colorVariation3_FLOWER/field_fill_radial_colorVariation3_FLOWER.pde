// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "field_fill26"; // CHANGE ME
PEmbroiderGraphics E_EXT;
PEmbroiderGraphics E_INT;
int frame = 0;
PImage image_EXT;
PImage image_INT;

PVector center;
float GradMult = 1;
int MODE = 1;
float hatchSpacing = 7;

boolean doWrite = true;


float randAddition = 0;
boolean edditting = true;

int setStitchVal = 50;





void setup() {
  size(1200, 1200); //100 px = 1 cm (so 14.2 cm is 1420px)
  image_EXT = loadImage("EXTERIOR3.png"); 
  image_INT = loadImage("INTERIOR2.png");
  center = new PVector(width/2, height/2);

  E_INT = new PEmbroiderGraphics(this, width, height);
  E_INT.toggleResample(true);
  E_INT.clear();
  E_INT.pushMatrix();
  E_INT.translate(width/2, height/2);
  E_INT.noStroke();
  E_INT.setStitch(10, 300, 10);
  E_INT.RESAMPLE_MAXTURN = 5;
  E_INT.hatchSpacing(3.5);
  E_INT.fill(0);
  // setFieldFill(E_INT, 0, 10, 0);
  E_INT.hatchMode(E_INT.CROSS);
  // E_INT.image(image_INT, -image_INT.width/2, -image_INT.height/2);
  //setFieldFill(E_INT, 4, 10, 0);
  E_INT.noFill();
  E_INT.stroke(0);
  E_INT.image(image_EXT, -image_EXT.width/2, -image_EXT.height/2);



  // E_INT.image(image_INT, -image_INT.width/2, -image_INT.height/2);
  E_INT.popMatrix();

  backstitchPolylines(E_INT);
  E_INT.optimize(10, 1000);
  PEmbroiderWrite(E_INT, "INTERIOR");


  E_EXT = new PEmbroiderGraphics(this, width, height);
  E_EXT.toggleResample(true);
  E_EXT.clear();
  E_EXT.pushMatrix();
  E_EXT.translate(width/2, height/2);


  setFieldFill(E_EXT, frame*.01, 10);
  E_EXT.noStroke();
  E_EXT.fill(0);



  E_EXT.hatchSpacing(hatchSpacing);
  E_EXT.RESAMPLE_MAXTURN = 5;
  E_EXT.setStitch(setStitchVal-20, setStitchVal, 10);
  E_EXT.image(image_EXT, -image_EXT.width/2, -image_EXT.height/2);
  filterByColor4(E_EXT);









  E_EXT.popMatrix();
  E_EXT.visualize(true, true, true);
}

void draw() {
  if (edditting) {
    background(180);
    E_EXT.visualize(true, true, false);
    E_INT.visualize();
  } else {
    if (doWrite) {
      E_EXT.optimize(10, 1000);
      PEmbroiderWrite(E_EXT, fileName);
      doWrite = false;
    }
    background(180);
    E_EXT.visualize(true, true, true, frame);
    E_INT.visualize(true, true, true, frame);
    frame++;
  }
}

void doubleStitch(PEmbroiderGraphics E, float x, float y, float x2, float y2) {
  E.line(x, y, x2, y2);
  E.line(x2, y2, x, y);
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+timeStamp()+".png"); //saves a png of design from canvas
}

void mousePressed() {
  if (edditting) {
    println("Pressed");
    center = new PVector(mouseX, mouseY);
    resetDesignFill_Color(E_EXT);
    filterByColor4(E_EXT);
  }
}

void mouseDragged() {
  if (edditting) {
    println("Dragged");
    center = new PVector(mouseX, mouseY);
    filterByColor4(E_EXT);
  }
}

void keyPressed() {
  if (edditting) {
    // Handle arrow keys
    if (key == CODED) {
      if (keyCode == UP) {
        GradMult +=.1;
      } else if (keyCode == DOWN) {
        GradMult -=.1;
      } else if (keyCode == RIGHT) {
        randAddition +=1;
      } else if (keyCode == LEFT) {
        randAddition -=1;
      }
    } else {
      if (key == '0') {
        MODE = 0;
        setFieldFill(E_EXT, frame*.01, 10);
      } else if (key == '1') {
        MODE = 1;
        setFieldFill(E_EXT, frame*.01, 10);
      } else if (key == '2') {
        MODE = 2;
        setFieldFill(E_EXT, frame*.01, 10);
      } else if ( key == '3') {
        E_EXT.hatchMode(E_EXT.CROSS);
      } else if ( key == '4') {
        E_EXT.hatchMode(E_EXT.CONCENTRIC);
      } else if (key == 'w') {
        hatchSpacing *= 1.1 ;
      } else if (key == 's') {
        hatchSpacing *= 1/1.1;
      } else if (key == ' ') {
        edditting = false;
      } else if (key == '+') {
        setStitchVal++;
        E_EXT.setStitch(setStitchVal-20, setStitchVal, 10);
      } else if (key == '-') {
        setStitchVal--;
        E_EXT.setStitch(setStitchVal-20, setStitchVal, 10);
      }

      resetDesignFill_Color(E_EXT);
    }
    filterByColor4(E_EXT);
  }
}

void resetDesignFill_Color(PEmbroiderGraphics E) {
  E.clear();
  E.hatchSpacing(hatchSpacing);
  E.pushMatrix();
  E.translate(width/2, height/2);
  E.image(image_EXT, -image_EXT.width/2, -image_EXT.height/2);
  E.popMatrix();
}




///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {

  MyVecField mvf = new MyVecField(z, len);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}

void setFieldFill(PEmbroiderGraphics E, float z, float len, int mode) {

  MyVecField mvf = new MyVecField(z, len, mode);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd
  PVector center1 = new PVector(width/2, height/2);
  float z;
  float len;
  int mode;
  float minX = 10000;
  float minY = 10000;
  float thetaMultiplier;
  float radialMultiplier;
  float noiseMultiplier;
  boolean set = false;

  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
    set = true;
  }

  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
  }

  public PVector get(float x, float y) {
    PVector centerPoint = null; // vector that points to the center
    if (!set) {
      this.mode = MODE;
    }
    switch(mode) {
    case 0:
      x*=0.01;
      y*=0.01;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case 1:
      x=x+width/2-image_EXT.width/2;
      y=y+height/2-image_EXT.height/2;
      centerPoint = center.copy().sub(x, y);
      if (minX>x) {
        minX = x;
      }
      if (minY>y) {
        minY=y;
      }
      //.normalize().mult(10);//.rotate(PI/2);
      if (centerPoint.mag() < 5) {
        return new PVector(0, 0);
      }
      centerPoint.normalize().mult(len).rotate(PI/2);//.rotate(PI/2);
      return centerPoint;
    case 2:
      x=x+width/2-image_EXT.width/2;
      y=y+height/2-image_EXT.height/2;
      centerPoint = center.copy().sub(x, y);
      if (minX>x) {
        minX = x;
      }
      if (minY>y) {
        minY=y;
      }
      if (centerPoint.mag() < 5) {
        return new PVector(0, 0);
      }
      //point(x,y);
      float heading = centerPoint.heading();
      float mag = centerPoint.mag();

      float noiseVal = (noise(sin(heading)*thetaMultiplier, mag*radialMultiplier)-.5)*noiseMultiplier;
      centerPoint.normalize().mult(10).rotate(noiseVal);
      return centerPoint;
    }
    return null;
  }
}



///////////////////////////////////////////////////////////////





























///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// NEEDLE DOWN HELPERS ////////////////////////////////////////////////////////////

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

PVector getPolyND(PEmbroiderGraphics E, int ndIndex, int polylineIndex) {
  return E.polylines.get(polylineIndex).get(ndIndex).copy();
}

int polyndLength(PEmbroiderGraphics E, int polylineIndex) {
  return E.polylines.get(polylineIndex).size();
}

int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size();
  }
  return n;
}

float getndDist(PEmbroiderGraphics E, int i1, int i2) {
  PVector P1 = getND(E, i1);
  PVector P2 = getND(E, i2);
  return P1.sub(P2).mag();
}



void checkStitchDens(PEmbroiderGraphics E) {
  int rows = height/5;
  int cols = width/5;
  float heightOffset = height/rows;
  float widthOffset = width/cols;

  println("Sample size:");
  println(str(widthOffset) + " x " + str(heightOffset));
  int stitchCounters[][] = new int[rows+10][cols+10];

  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  int maxStitches = 0;

  int rowTrack = 100;
  int colTrack = 0;

  // This loop goes through each point  in E counts how many times the needle down falls within a certain stitch counter
  for (int i = 0; i < lenE; i++) {
    pointLoc = getND(E, i);
    int col = int(pointLoc.x/widthOffset);
    int row = int(pointLoc.y/heightOffset);
    if (row<rowTrack) {
      rowTrack = row;
    }
    if (col>colTrack) {
      colTrack = col;
    }

    stitchCounters[row][col]++;
  }

  for (int row=0; row < rows; row ++) {
    for (int col=0; col < cols; col++) {
      int r = int(float(stitchCounters[row][col])*30);
      if (maxStitches<stitchCounters[row][col]) {
        maxStitches =stitchCounters[row][col];
      }
      noStroke();
      fill(r, 0, 0);
      rect(col*widthOffset, row*heightOffset, widthOffset, heightOffset);
    }
  }


  for (int i = 0; i < lenE; i++) {
    pointLoc = getND(E, i);
    fill(255);
    stroke(255, 255, 255, 40);
    point(pointLoc.x, pointLoc.y);
  }

  println("Max Stitches:");
  println(maxStitches);
}


void randomStepPolys(PEmbroiderGraphics E, PEmbroiderGraphics E2, int steps) {
  for (int i=0; i<E.polylines.size(); i++) {
    int eLen = polyndLength(E, i);
    //   int i0 = 0%eLen;//int(random(eLen));
    // int i1 = (0+5)%eLen;//int(random(eLen));
    for (int j=0; j<steps; j++) {
      if (j%2 == 0) {
        int i0 = j%(eLen-1);//i1;
        int i1 = (j+8)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      } else {
        int i1 = j%(eLen-1);//i1;
        int i0 = (j+8)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      }
    }
  }
}



void filterND(PEmbroiderGraphics E, float intRad, float edgRad) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = needleLoc0.sub(center).mag();
      boolean val = abs(dist-edgRad)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

void filterByColor(PEmbroiderGraphics E) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    PVector needleLoc0 = E.polylines.get(i).get(int(E.polylines.get(i).size()/2)).copy();
    float dist = needleLoc0.sub(center).mag();
    if (dist>114 && dist<= 155) {
      resetPolylineColor(E, i, color(0, 255, 0));
    } else if (dist > 155) {
      resetPolylineColor(E, i, color(0, 255, 0));
    }
  }
}


void filterByColor2(PEmbroiderGraphics E) {
  PVector center = new PVector(width/2, height/2);
  ArrayList<ArrayList <PVector>> Color0 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color1 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color2 = new ArrayList<ArrayList <PVector>>();
  ArrayList <Integer> colors0 = new ArrayList <Integer>();
  ArrayList <Integer> colors1 = new ArrayList <Integer>();
  ArrayList <Integer> colors2 = new ArrayList <Integer>();
  for (int i=0; i<E.polylines.size(); i++) {
    PVector needleLoc0 = E.polylines.get(i).get(int(E.polylines.get(i).size()/2)).copy();
    float dist = needleLoc0.sub(center).mag();
    if (dist>90 && dist<= 156) {
      Color1.add(E.polylines.get(i));
      colors1.add(color(0));
    } else if (dist > 156) {
      Color2.add(E.polylines.get(i));
      colors2.add(color(0, 255, 0));
    } else {
      Color0.add(E.polylines.get(i));
      colors0.add(color(255, 0, 0));
    }
  }
  E.polylines.clear();
  E.colors.clear();
  E.polylines.addAll(Color0);
  E.polylines.addAll(Color1);
  E.polylines.addAll(Color2);
  E.colors.addAll(colors0);
  E.colors.addAll(colors1);
  E.colors.addAll(colors2);
  E.optimize(10, 1000);
}

void filterByColor4(PEmbroiderGraphics E) {
  ArrayList<ArrayList <PVector>> Color0 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color1 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color2 = new ArrayList<ArrayList <PVector>>();
  ArrayList <Integer> colors0 = new ArrayList <Integer>();
  ArrayList <Integer> colors1 = new ArrayList <Integer>();
  ArrayList <Integer> colors2 = new ArrayList <Integer>();
  for (int i=0; i<E.polylines.size(); i++) {
    PVector needleLoc0 = E.polylines.get(i).get(int(E.polylines.get(i).size()/2)).copy();
    float dist = needleLoc0.sub(center).mag();
    dist += random(-randAddition, randAddition);
    if (dist>90*GradMult && dist<= 156*GradMult) {
      Color1.add(E.polylines.get(i));
      colors1.add(color(0));
    } else if (dist > 156*GradMult) {
      Color2.add(E.polylines.get(i));
      colors2.add(color(0, 255, 0));
    } else {
      Color0.add(E.polylines.get(i));
      colors0.add(color(255, 0, 0));
    }
  }
  E.polylines.clear();
  E.colors.clear();
  E.polylines.addAll(Color0);
  E.polylines.addAll(Color1);
  E.polylines.addAll(Color2);
  E.colors.addAll(colors0);
  E.colors.addAll(colors1);
  E.colors.addAll(colors2);
  // E.optimize(10, 1000);
}


void filterND_stepOver(PEmbroiderGraphics E, float intRad, float edgWidth) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = abs(needleLoc0.x - center.x);
      boolean val = abs(dist-edgWidth)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

boolean NDaproxIn (PEmbroiderGraphics E, PVector ND) {
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      if (needleLoc.sub(ND).mag()<.001) {
        return true;
      }
    }
  }
  return false;
}


void resetPolylineColor(PEmbroiderGraphics E, int i, color c) {
  int r = int(red(c));
  int g = int(green(c));
  int b = int(blue(c));
  int colorVal = 0xFF000000 | ((r & 255) << 16) | ((g & 255) << 8) | (b & 255);
  E.colors.set(i, colorVal);
}


String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}


void backstitchPolyline(PEmbroiderGraphics E, int i) {
  ArrayList<PVector> collection = new ArrayList<PVector>();
  for (int j=1; j<E.polylines.get(i).size(); j++) {
    PVector needleLoc = E.polylines.get(i).get(j).copy();
    PVector needleLoc_backStitch = E.polylines.get(i).get(j-1).copy();
    collection.add(needleLoc);
    collection.add(needleLoc_backStitch);
  }
  E.polylines.get(i).clear();
  E.polylines.get(i).addAll(collection);
}


void backstitchPolylines(PEmbroiderGraphics E) {
  ArrayList<PVector> collection = new ArrayList<PVector>();
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=1; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      PVector needleLoc_backStitch = E.polylines.get(i).get(j-1).copy();
      collection.add(needleLoc);
      collection.add(needleLoc_backStitch);
    }
    E.polylines.get(i).clear();
    E.polylines.get(i).addAll(collection);
  }
}



////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
