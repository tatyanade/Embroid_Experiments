import processing.embroider.*;

PEmbroiderGraphics E;
PEmbroiderGraphics E2;
String fileType = ".pes";

PImage image;


void setup() {
  size(700, 700); //100 px = 1 c
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

  E.hatchMode(E.CONCENTRIC);
  E.hatchAngle(PI/2);
  E.hatchSpacing(3);
  E.image(image, (width-image.width)/2, (height-image.height)/2);
  E.optimize();
  
  cullFilter(E2,E, 2);
  E2.optimize();
  
  E2.visualize(true, true, false);

  PEmbroiderWrite(E, "TEST");
}

void draw() {
  background(180);
  int i = int(frameCount);
  E2.visualize(true, true, true, i);
  traceActiveStitches(E2,i);
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
