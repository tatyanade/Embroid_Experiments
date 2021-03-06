import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Movie video;

int frames = 0;

void setup() {
  size(1136, 320);
  video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 568, 320);
  video.loop();
  video.play();
}

void draw() {
  background(0);
  println("running");

  if (frames>3) {
    opencv.loadImage(video);
    opencv.calculateOpticalFlow();
    
  //  PVector flow = opencv.getFlowAt(10,10);
    
    image(video, 0, 0);
    translate(video.width, 0);
    stroke(255, 0, 0);
    opencv.drawOpticalFlow();

    PVector aveFlow = opencv.getAverageFlow();
    int flowScale = 50;

    stroke(255);
    strokeWeight(2);
    line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);
  }
  
  frames++;
}

void movieEvent(Movie m) {
  m.read();
}
