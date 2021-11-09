// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "field_fill14"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;
PImage myImage;

///////
float noiseMultiplier = 3;
float thetaMultiplier = .3;
float radialMultiplier = .001;
////



void setup() {
  size(1000, 1000); //100 px = 1 cm (so 14.2 cm is 1420px)
  //for(int i = 0; i<1000000; i++){
  //  println((i+10)*5);
  //}
  myImage = loadImage("TEST4.png"); 
  PEmbroiderStart();
  E.toggleResample(true);
  E.clear();
  E.pushMatrix();
  E.translate(width/2,height/2);

  setFieldFill(E, frame*.01, 20);
  E.noStroke();
  E.fill(0);
 
  
  
  
  E.hatchSpacing(2.2);
  E.setStitch(40, 70, 0);
  E.beginOptimize();
  E.image(myImage, -myImage.width/2, -myImage.height/2);
 // E.rect(0,0,400,400);
  E.endOptimize();
  E.optimize(30,3000);
  println("////////////////");
  println("Polylines:");
  println(E.polylines.size());
  println("////////////////");
  println();
  println("////////////////");
  println("Colors:");
  println(E.colors.size());
  println("////////////////");
  
  
  filterByColor2(E);
  
  
  
  
  
  
  E.popMatrix();
  PEmbroiderWrite();
  E.visualize(true, true, true);
}

void draw() {
  background(180);
  E.visualize(true,true,true,frameCount);
}

void doubleStitch(PEmbroiderGraphics E, float x, float y, float x2, float y2) {
  E.line(x, y, x2, y2);
  E.line(x2, y2, x, y);
}



void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  E.setStitch(8, 14, 0);
}

void PEmbroiderWrite() {
///  E.visualize(true, true, true);//true, true, true);
  String outputFilePath = sketchPath(fileName+str(int(frame))+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}




///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {

  MyVecField mvf = new MyVecField(z, len,1);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd
  PVector center = new PVector(width/2,height/2);
  float z;
  float len;
  int mode;
  float minX = 10000;
  float minY = 10000;
  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
  }

  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
  }

  public PVector get(float x, float y) {
    switch(mode) {
    case 0:
      x*=0.01;
      y*=0.01;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case 1:
       x=x+width/2-myImage.width/2;
       y=y+height/2-myImage.height/2;
       if(minX>x){
         minX = x;
       }
       if(minY>y){
         minY=y;
       }
       PVector centerPoint = center.copy().sub(x,y);//.normalize().mult(10);//.rotate(PI/2);
       if(centerPoint.mag() < 5){
         return new PVector(0,0);
       }
       //point(x,y);
       float heading = centerPoint.heading();
       float mag = centerPoint.mag();
       
       float noiseVal = (noise(sin(heading)*thetaMultiplier,mag*radialMultiplier)-.5)*noiseMultiplier;
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

  println(heightOffset);

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
    println(i);
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
      if(dist>114 && dist<= 155){
        resetPolylineColor(E,i,color(0,255,0));
      }else if(dist > 155){
        resetPolylineColor(E,i,color(0,255,0));
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
      if(dist>90 && dist<= 156){
        Color1.add(E.polylines.get(i));
        colors1.add(color(0));
      }else if(dist > 156){
        Color2.add(E.polylines.get(i));
        colors2.add(color(0,255,0));
      } else {
        Color0.add(E.polylines.get(i));
        colors0.add(color(255,0,0));
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
  E.optimize(10,1000);
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

void filterND_stepOverLAST(PEmbroiderGraphics E, float intRad, float edgWidth) {
  PVector center = new PVector(width/2, height/2);
  for (int i=E.polylines.size()-1; i<E.polylines.size(); i++) {
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

void filterColors(PEmbroiderGraphics E){
  
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


void resetPolylineColor(PEmbroiderGraphics E, int i, color c){
  int r = int(red(c));
  int g = int(green(c));
  int b = int(blue(c));
  int colorVal = 0xFF000000 | ((r & 255) << 16) | ((g & 255) << 8) | (b & 255);
  E.colors.set(i,colorVal);
}


////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
