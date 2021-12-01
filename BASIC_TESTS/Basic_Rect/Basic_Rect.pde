// "Hello World" program for the PEmbroider library for Processing. 
// Generates a smily face and the words "hello world". 

// Import the library, and declare a PEmbroider renderer. 
import processing.embroider.*;
PEmbroiderGraphics E;

void setup() {
  size (1200, 1600);
  float cx = width/2; 
  float cy = height/2 - 40;

  // Create the PEmbroider object
  E = new PEmbroiderGraphics(this, width, height);

  E.toggleResample(true); // Turn resampling on (good for embroidery machines)
  E.setStitch(44,70,0);
  E.hatchSpacing(15);
  E.hatchAngle(PI/4);
  E.hatchMode(E.PARALLEL);
  E.noFill();
  E.strokeWeight(44);
  E.strokeSpacing(6);
  
  PEmbroiderWriter.PES.TRUNCATED = false;
  PEmbroiderWriter.PES.VERSION = 1;
  PEmbroiderWriter.TITLE = "RECT";
  E.rect(10,10,width-20,height-20);

  E.optimize(); // VERY SLOW, but ESSENTIAL for good file output!
  E.visualize(true, true, true); // Display (preview) the embroidery onscreen.
  String outputFilePath = sketchPath("Basic_Rect.pes");
  E.setPath(outputFilePath);
  E.endDraw(); // Uncomment this to write out the embroidery file.

}


void draw() {
  boolean bShowAnimatedProgress = false;
  if (bShowAnimatedProgress) {
    background(255);
    E.visualize(true, false, true, frameCount);
  }
}
