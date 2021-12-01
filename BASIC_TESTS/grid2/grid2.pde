import processing.embroider.*;

PEmbroiderGraphics E;
String fileType = ".pes";

PImage image;


void setup() {
  size(1200, 1800); //100 px = 1 cm
  noLoop();
  image = loadImage("IMAGE4.png"); 
  E = new PEmbroiderGraphics(this, width, height);
  E.noStroke();
  E.fill(0);
  E.setStitch(10,50,0);
  E.RESAMPLE_MAXTURN = 1;
  
  
  E.hatchMode(E.PARALLEL);
  E.hatchAngle(PI/2);
  //E.image(image,(width-image.width)/2,(height-image.height)/2);
  E.hatchSpacing(60);
  E.rectMode(CENTER);
  E.rect(width/2,height/2,width-40,height-40);
  
  E.hatchMode(E.PARALLEL);
  E.hatchAngle(0);
//  E.image(image,(width-image.width)/2,(height-image.height)/2);
  E.hatchSpacing(120);
  E.rectMode(CENTER);
  E.rect(width/2,height/2,width-40,height-40);
  
  E.optimize();
  E.visualize(true,true,true);
  
  PEmbroiderWrite(E, "TEST");
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}


String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}
