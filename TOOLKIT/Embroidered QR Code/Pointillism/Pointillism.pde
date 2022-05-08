
import processing.embroider.*;

String fileType = ".pes";
String fileName = "embroideredQRCode2"; // CHANGE ME
int QR_WIDTH = 25;
PEmbroiderGraphics E;
PImage img;
float knotRad = 15;


void setup() {
  size(1200, 1200);
  E = new PEmbroiderGraphics(this, width, height);
  E.setStitch(5,500,0);
  E.noFill();
  E.stroke(0);
  img = loadImage("frame.png");
  noStroke();
  background(255);
  int[][] QR = readQR();
  
  for (int i = 0; i < QR_WIDTH; i++) {
    for (int j = 0; j < QR_WIDTH; j++) {
      if(QR[j][i] == 1){
        fill(0);
        drawKnot2(E, knotRad, float(j*30+60),float(i*30+60));
        //ellipse(j*20+60,i*20+60,20,20);
      }
    }
  }
  E.visualize();
  PEmbroiderWrite(E,fileName);
}

void draw() {
    background(100);
    int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)+4));
    E.visualize(true, true, true, visualInput);
    pushStyle();
    fill(255);
    stroke(255);
    text(visualInput, 10, 30);
    text(ndLength(E), 10, 50);
    text(ndLength(E), 10, 50);
    popStyle();
}




   

void drawQR() {
  for (int i = 0; i < QR_WIDTH; i++) {
    for (int j = 0; j < QR_WIDTH; j++) {
      int x = int(img.width/QR_WIDTH)*i+img.width/25/2;
      int y = int(img.height/QR_WIDTH)*j+img.height/25/2;
      color pix = img.get(x, y);
      fill(pix);
      ellipse(x+img.width/25/4+img.width, y+img.height/25/4+img.height, 10, 10);
    }
  }
}

int[][] readQR() {
  int[][] myQR = new int[QR_WIDTH][QR_WIDTH];
  for (int i = 0; i < 25; i++) {
    for (int j = 0; j < 25; j++) {
      int x = int(img.width/float(QR_WIDTH))*i+int(img.width/float(QR_WIDTH)/2);
      int y = int(img.height/float(QR_WIDTH))*j+int(img.height/float(QR_WIDTH)/2);
      color pix = img.get(x, y);
      if (pix<-1000) {
        myQR[j][i] = 1;
      } else {
        myQR[j][i] = 0;
      }
    }
  }
  return myQR;
}



void drawKnot2(PEmbroiderGraphics E, float rad, float x, float y) {
  E.pushMatrix();
  E.translate(x, y);
  E.setStitch(4, 1000, 0);
  drawStarKnot(E, int(rad-8*3));

  drawStarKnot(E, int(rad-8*2));

  drawStarKnot(E, int(rad-8));

  E.rotate(PI/11);
  drawStarKnot(E, int(rad-1)); // .85
  E.popMatrix();
}

void drawStarKnot(PEmbroiderGraphics E, int rad) {
  println("/////// New Knot /////");
  if (rad*2>=10) {
    float arLen = 3;
    // arLen = rad*theta
    //
    float thStep = arLen/rad;

    float thSteps = 0;
    int i = 0;

    float angleDif = PI;
    PVector storedVect = new PVector(0, 0);

    while (thSteps < PI*1.1) {
      if (i%2==0) {
        PVector newVect = connectPointsOnCircle(E, thSteps, thSteps+angleDif, rad)[0];
        println(storedVect.sub(newVect).mag());
        storedVect = newVect.copy();
      } else {
        PVector newVect = connectPointsOnCircle(E, thSteps+angleDif, thSteps, rad)[1];
        println(storedVect.sub(newVect).mag());
        storedVect = newVect.copy();
      }
      thSteps += thStep;
      i++;
    }
  }
}

PVector[] connectPointsOnCircle(PEmbroiderGraphics E, float th1, float th2, int rad) {
  //th1 & th2 are in radians
  // centered on zero
  PVector [] vects = new PVector[2];
  int x1 = int(cos(th1)*rad);
  int y1 = int(sin(th1)*rad);
  int x2 = int(cos(th2)*rad);
  int y2 = int(sin(th2)*rad);
  vects[0] = new PVector(x1, y1);
  vects[1] = new PVector(x2, y2);
  E.line(x1, y1, x2, y2);
  return vects;
}


int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size()-1;
  }
  return n;
}



void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}
