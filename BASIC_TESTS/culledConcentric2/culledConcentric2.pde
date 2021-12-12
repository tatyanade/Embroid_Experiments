import processing.embroider.*;

PEmbroiderGraphics E;
PEmbroiderGraphics E2;
String fileType = ".pes";

PImage image;


void setup() {
  size(1400, 700); //100 px = 1 c
  image = loadImage("IMAGE3.png");
  E = new PEmbroiderGraphics(this, width, height);
  E2 = new PEmbroiderGraphics(this, width, height);;
  E.noStroke();
  E.fill(0);
  E.setStitch(10, 30, 0);
  E.RESAMPLE_MAXTURN = 1;
  
  E2.noFill();
  E2.stroke(10);
  E2.setStitch(4, 15, 0);
  E2.RESAMPLE_MAXTURN = 1;
  
  image.filter(GRAY);
  E.hatchMode(E.CONCENTRIC);
  E.hatchSpacing(20);
  E.hatchRaster(image, (width/4-image.width/2), (height-image.height)/2);
  
  E.optimize();
  E2.translate(width/2,0);
  cullFilter(E2,E, 4.5);
  E2.optimize();

  frameRate(20);
}

boolean showAnimation = true;
int frame = 0;

void draw() {
  if(showAnimation){
  background(180);
  int i = int(frameCount);
  E.visualize(true, true, true);
  traceActiveStitches(E,i);
  E2.visualize(true, true, true); // E2 is the culled version
  traceActiveStitches(E2,i);
  
  pushStyle();
  fill(0);
  stroke(0);
  text("UNCULLED",(width/4-image.width/2),40);
  text("CULLED",(width/4-image.width/2)+width/2,40);
  popStyle();
  } else {
    background(0);
    checkStitchDens(E);
    checkStitchDens(E2);
  }
}

void keyPressed(){
  if(key == ' '){
    if(showAnimation){
    showAnimation = false;
    } else {
      showAnimation = true;
    }
  }
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}


String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}


void filterND(PEmbroiderGraphics E) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = needleLoc0.sub(center).mag();
      if (dist>250) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

void cullFilter(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref, float cullSpacing){
  E.CULL_SPACING = cullSpacing;
  E.beginCull();
  for (int i=0; i<E_Ref.polylines.size(); i++) {
    E.beginShape();
    for (int j=0; j<E_Ref.polylines.get(i).size(); j++) {
      PVector needleLoc = E_Ref.polylines.get(i).get(j).copy();
      E.vertex(needleLoc.x,needleLoc.y);
    }
    E.endShape(OPEN);
  }
  E.endCull();
}

int NDlength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size();
  }
  return n;
}


void traceActiveStitches(PEmbroiderGraphics E, int ndIndex) {
  int n = 0;
  pushStyle();
  for (int i = 0; i < E.polylines.size(); i++) {
    for (int j = 0; j < E.polylines.get(i).size()-1; j++) {
      PVector p0 = E.polylines.get(i).get(j);
      PVector p1 = E.polylines.get(i).get(j+1);
      noStroke();
      if (j == 0) {
        
      }
      
      n++;
      if (n>=ndIndex) {
      fill(255, 0 , 0);   
      circle(p1.x, p1.y, 6);
      circle(p0.x, p0.y, 6);
      break;
      }
    }
    if (n >= ndIndex) {
      break;
    }
    
  }
  popStyle();
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

  // This loop goes through each point  in E counts how many times the needle down falls within a certain stitch counter
  for (int i = 0; i < lenE; i++) {
    pointLoc = getND(E, i);
    int col = int(pointLoc.x/widthOffset);
    int row = int(pointLoc.y/heightOffset);

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
      if(r == 0){
        fill(r,0,0,0);
      }
      rect(col*widthOffset, row*heightOffset, widthOffset, heightOffset);
    }
  }


  println("Max Stitches:");
  println(maxStitches);
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


//////////////
//////////////
