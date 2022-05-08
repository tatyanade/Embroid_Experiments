import processing.embroider.*;
String fileType = ".pes";
String fileName = "spiral_image"; // CHANGE ME
PEmbroiderGraphics E;
PEmbroiderGraphics E2;



void setup() {
  size(800, 800);
  E = new PEmbroiderGraphics(this, width, height);
  parseFile();
  E.visualize();
}

void draw() {
  background(100);
  int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)));
  E.visualize(true, true, false, visualInput);
}

void parseFile() {
  BufferedReader reader = createReader("TEST30-01.svg");
  String line = null;
  try {
    while ((line = reader.readLine()) != null) {
      println("/////NEW OBJECT//////");

      ////state variables
      boolean lineStart = false;
      boolean rectStart = false;
      float x1 = 0;
      float y1 = 0;
      float y2 = 0;
      float x2 = 0;
      float x = 0;
      float y = 0;
      float h = 0;
      float w = 0;
      float zigLen = 1;
      float stWidth = 1;

      String[] pieces = split(line, " ");

      for (String piece : pieces) {
        ////// begin switch
        if (piece.equals("<line")) {
          println("Begin Line");
          lineStart = true;
          E.setStitch(4,400,0);
          E.noFill();
          E.stroke(0);
        } else if (piece.equals("<rect")) {
          println("Begin Rect");
          rectStart = true;
          E.setStitch(5,15,0);
          E.fill(0);
          E.hatchMode(E.CROSS);
          E.hatchSpacing(10);
          E.noStroke();
        } else if (piece.indexOf("x1")==0) {
          println("X1 VALUE:");
          println(piece);
          x1 = getValFl(piece);
        } else if (piece.indexOf("y1")==0) {
          println("Y1 VALUE:");
          println(piece);
          y1 = getValFl(piece);
        } else if (piece.indexOf("x2")==0) {
          println("X2 VALUE:");
          println(piece);
          x2 = getValFl(piece);
        } else if (piece.indexOf("y2")==0) {
          println("Y2 VALUE:");
          println(piece);
          y2 = getValFl(piece);
        } else if (piece.indexOf("x")==0) {
          println("X VALUE:");
          println(piece);
          x = getValFl(piece);
        } else if (piece.indexOf("y")==0) {
          println("Y VALUE:");
          println(piece);
          y = getValFl(piece);
        } else if (piece.indexOf("width=")==0) {
          println("WIDTH VALUE:");
          println(piece);
          w = getValFl(piece);
        } else if (piece.indexOf("height=")==0) {
          println("HEIGHT VALUE:");
          println(piece);
          h = getValFl(piece);
        }  else if (piece.indexOf("stroke=")==0) {
          println("STROKE VALUE:");
          String hexValue  = split(split(piece, "=")[1],"\"")[1];
          color convertedColor = Integer.decode(hexValue);
          println(int(red(convertedColor)),int(green(convertedColor)),int(blue(convertedColor)));
          E.stroke(int(red(convertedColor)),int(green(convertedColor)),int(blue(convertedColor)));
        } else if (piece.indexOf("stroke-width=")==0) {
          println("STROKE-WIDTH VALUE:");
          println(piece);
          stWidth = getValFl(piece);
          if(stWidth <= 2){
            stWidth = 0;
            zigLen = 10;
          } else {
            zigLen = 2;
          }
          if (piece.indexOf("/>")>=0) {
            if (lineStart) {
              println("End Line");
              lineStart = false;
              PVector P0 = new PVector(x1, y1);
              PVector P1 = new PVector(x2, y2);
              zigLine(E, P0, P1, stWidth, zigLen);
            } else if(rectStart){
              println("End Rect");
              E.rect(w,h,x,y);
            }
          } 
        } else if (piece.indexOf("/>")>=0) {
          if (lineStart) {
            println("End Line");
            lineStart = false;
            PVector P0 = new PVector(x1, y1);
            PVector P1 = new PVector(x2, y2);
            zigLine(E, P0, P1, stWidth, zigLen);
          } else if(rectStart){
              println("End Rect");
              E.beginOptimize();
              E.rect(x,y,w,h);
              E.endOptimize();
            }
        } else {
          //println(piece);
        }
        //////// end string switch
      }
    }
    reader.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}


float getValFl(String piece) {
  String[] values = split(piece, "\"");
  return float(values[values.length-2]);
}




/////////////////////
////// zigline helperS (FROM "dowelInset_ChairBack2")

void zigAlongFill(PEmbroiderGraphics E, PEmbroiderGraphics E_Ref, float stWidth, float stLen) {
  for (ArrayList<PVector> poly : E_Ref.polylines) {
    PVector P0 = poly.get(0);
    PVector P1 = poly.get(poly.size()-1);
    zigLine(E, P0, P1, stWidth, stLen);
  }
}


void zigLine(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth, float stLen) {
  zigLine(E, P0, P1, stWidth, 1, stLen);
}


void zigLine(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth, int stDir, float stLen) {
  E.setStitch(1, 1000, 0);
  float stepAmount = int(P1.copy().sub(P0).mag()/stLen);
  PVector step = P1.copy().sub(P0).div(stepAmount);
  PVector P = P0.copy();
  PVector tan = step.copy().rotate(PI/2).normalize().mult(stWidth/2.0);
  E.beginShape();
  int dir=stDir;
  for (int i = 0; i <= stepAmount; i++) {
    E.vertex(P.x+tan.x*dir, P.y+tan.y*dir);
    P.add(step);
    dir *= -1;
  }

  E.endShape();
}

void zigLineCustom(PEmbroiderGraphics E, PVector P0, PVector P1, float stWidth, int stDir, float stLen, float stitchLen) {
  E.setStitch(1, stitchLen, 0);
  float stepAmount = int(P1.copy().sub(P0).mag()/stLen);
  PVector step = P1.copy().sub(P0).div(stepAmount);
  PVector P = P0.copy();
  PVector tan = step.copy().rotate(PI/2).normalize().mult(stWidth/2);
  println(tan);
  E.beginShape();
  int dir=stDir;
  for (int i = 0; i <= stepAmount; i++) {
    E.vertex(P.x+tan.x*dir, P.y+tan.y*dir);
    P.add(step);
    dir *= -1;
  }

  E.endShape();
}

/////////////
/////////////



int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size();
  }
  return n;
}


void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}

String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}
