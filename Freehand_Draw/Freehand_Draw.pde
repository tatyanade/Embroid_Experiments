// Doodle recorder for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.

String extension = ".pes";
String filename = "test";
String name;
boolean safeNaming = true; // makes sure u dont overwrite; turn false to have filename be just extension with no timestamp or version number
int count = 0;

import processing.embroider.*;
PEmbroiderGraphics E;

ArrayList<PVector> currentMark;
ArrayList<ArrayList<PVector>> marks;

int mode = 0;
// 0 = emb
// 1 = sketch
int[] sketchPoints = {};

//===================================================
void setup() { 
  
  size (1400, 900);
  E = new PEmbroiderGraphics(this, width, height);


  if (safeNaming == true){
      name = filename + str(hour()) + "_" + str(minute()) + "_" + str(second());
      String outputFilePath = sketchPath(name + "v" + count + extension);
      E.setPath(outputFilePath);
  } else {
      name = filename;
      String outputFilePath = sketchPath(name + extension);
      E.setPath(outputFilePath);
  }

  currentMark = new ArrayList<PVector>();
  marks = new ArrayList<ArrayList<PVector>>();
  
  

}

void drawSketch(){
  stroke(225,225,0);
 
   beginShape(POINTS);
  
   println(sketchPoints);
   for (int i = 0; i < sketchPoints.length -1 ; i+=2){
     vertex( sketchPoints[i], sketchPoints[i+1]);
   }
   endShape();
}
//===================================================
void draw() {

  drawGrid();
  
  drawSketch();
  // Clear the canvas, init the PEmbroiderGraphics
   
  E.beginDraw(); 
  E.clear();
  E.noFill(); 

  // Set some graphics properties
  E.stroke(0, 0, 0); 
  E.strokeWeight(1); 
  E.strokeSpacing(5.0); 
  E.strokeMode(PEmbroiderGraphics.PERPENDICULAR);
  E.RESAMPLE_MAXTURN = 0.8f; // 
  E.setStitch(10, 40, 0.0);
  
  
  
  // Draw all previous marks
  for (int m=0; m<marks.size(); m++) {
    ArrayList<PVector> mthMark = marks.get(m); 
    E.beginShape(); 
    for (int i=0; i<mthMark.size(); i++) {
      PVector ithPoint = mthMark.get(i); 
      E.vertex (ithPoint.x, ithPoint.y);
    }
    E.endShape();
  }

  // If the mouse is pressed, 
  // add the latest mouse point to current mark,
  // and draw the current mark
  if (mousePressed) {
    
    if( mode == 0){
      currentMark.add(new PVector(mouseX, mouseY));
      
      E.beginShape(); 
      for (int i=0; i<currentMark.size(); i++) {
        PVector ithPoint = currentMark.get(i); 
        E.vertex (ithPoint.x, ithPoint.y) ;
      }
      E.endShape();
    }
    else if (mode == 1){
      sketchPoints[sketchPoints.length + 1] = mouseX;
      sketchPoints[sketchPoints.length + 1] = mouseY;
    }
  }

  E.visualize(true,true,true);
}

//===================================================
void mousePressed() {
  // Create a new current mark
  currentMark = new ArrayList<PVector>();
  currentMark.add(new PVector(mouseX, mouseY));
}

//===================================================
void mouseReleased() {
  // Add the current mark to the arrayList of marks
  marks.add(currentMark); 
  E.printStats();
}

//===================================================
void keyPressed() {
  if (key == 'q'){
   mode = 1; 
  }
  if (key == 'e'){
    mode = 0;
  }
  if (key == ' ') {
    currentMark.clear(); 
    marks.clear();
    setup();
    count = 0;
  } else if (key == 's' || key == 'S') { // S to save
  
    //E.optimize(); // slow, but very good and important

    if (safeNaming == true){
      save(name + "v" + count +".png");
      count+=1;
      E.endDraw(); // write out the file
      String outputFilePath = sketchPath(name + "v" + count + extension);
      E.setPath(outputFilePath);
  } else {
      save(name + ".png");
      E.endDraw(); // write out the file
  }
  


  }
}

void drawGrid(){
  background(200);
  stroke(190);
  for (int x = 0; x < width ; x += 10){
    line(x, 0, x, height);
  }
  for (int y = 0; y < height ; y+= 10){
    line(0, y, width, y);
  }
  stroke(155);
  for (int x = 0; x < width ; x += 50){
    line(x, 0, x, height);
  }
  for (int y = 0; y < height ; y+= 50){
    line(0, y, width, y);
  }
    stroke(255);
  for (int x = 0; x < width ; x += 100){
    line(x, 0, x, height);
  }
  for (int y = 0; y < height ; y+=100){
    line(0, y, width, y);
  }
}
