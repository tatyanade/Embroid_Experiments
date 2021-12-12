import processing.embroider.*;

PEmbroiderGraphics E;
String fileType = ".pes";

PImage image;


void setup() {
  size(700, 700); //100 px = 1 c
  image = loadImage("IMAGE3.png");
  E = new PEmbroiderGraphics(this, width, height);
  E.noStroke();
  E.fill(0);
  E.setStitch(10, 50, 0);
  E.RESAMPLE_MAXTURN = 1;

  E.beginCull();
  E.hatchMode(E.CONCENTRIC);
  E.hatchAngle(PI/2);
  E.hatchSpacing(10);
  E.image(image, (width-image.width)/2, (height-image.height)/2);
  E.endCull();

  E.optimize();
  E.visualize(true, true, true);

  PEmbroiderWrite(E, "TEST");
}

void draw(){
  background(180);
  PVector ND = getND(E,int(frameCount/10));
  E.visualize(true,true,true,int(frameCount/10));
  pushStyle();
  fill(255,0,0);
  noStroke();
  circle(ND.x,ND.y,30);
  popStyle();
  
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

int NDlength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size();
  }
  return n;
}
