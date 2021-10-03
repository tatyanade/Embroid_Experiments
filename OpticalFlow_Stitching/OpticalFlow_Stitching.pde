// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;
String fileType = ".pes";
String fileName = "animated_field_stitch"; // CHANGE ME
PEmbroiderGraphics E;
float frame = 0;






import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Movie video;

int frames = 0;

void setup() {
  size(960, 640);
  video = new Movie(this, "video-1616615664.mp4");
  opencv = new OpenCV(this, 960, 640);
  video.loop();
  video.play();
 // frameRate(10);

  PEmbroiderStart();
}

void draw() {
  background(0);

  E.clear();
  E.pushMatrix();
  E.setStitch(20, 30, 0);
  E.hatchSpacing(10);
  E.fill(0);
 // E.translate(width/4, height/4);
  int rows = 20;
  int cols = 20;
  int offset = 14;

  if (frames>3) {
    opencv.loadImage(video);
    opencv.calculateOpticalFlow();

    //  

   // image(video, 0, 0);
    //translate(video.width, 0);
    //E.translate(video.width, 0);
    stroke(255, 0, 0);
   // opencv.drawOpticalFlow();

    // PVector aveFlow = opencv.getAverageFlow();
    float flowScale = .1;

    E.stroke(255);
    E.strokeWeight(1);
    println(video.width);
    println(video.height);
    for (int x = 0; x<video.width; x ++) {
      for (int y = 0; y<video.height; y++) {
        if (x % 10 == 0 && y % 10 == 0) {
          PVector flow = opencv.getFlowAt(x, y);
          //println(y);
          doubleStitch(E,x, y, x + int(flow.x*flowScale), y + int(flow.y*flowScale));
        }
      }
    }
  }

  frames++;
  E.popMatrix();
  E.visualize(true,false,false);
 // if (frame > 50) {
 //   exit();
//  }
}

void movieEvent(Movie m) {
  m.read();
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
  E.visualize(true, true, true);//true, true, true);
  String outputFilePath = sketchPath(fileName+str(frame)+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}
