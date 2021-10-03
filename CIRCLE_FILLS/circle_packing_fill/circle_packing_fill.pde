
/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "circle_fill_7"; // CHANGE ME
PEmbroiderGraphics E;
PImage myImage;

// Setup draw loop
boolean loop = true;
int frame = 0;

boolean running = true;


float circleMax = 40;
float circleMin = 20;

//Pack p;




//https://github.com/zmorph/codeplastic/blob/master/circle_packing/circle_packing.pde

import processing.dxf.*;
import processing.svg.*;


Pack pack;

boolean growing = false;
int n_start = 100;

void setup() {
  

  size(1230, 900);
    myImage = loadImage("bg3.png");

    PEmbroiderStart();

  noFill();
  strokeWeight(1.5);
  stroke(5);

  noiseDetail(2, 0.1);

  pack = new Pack(n_start);
}


int[] coords = {
  0, 0, 100,200, 400,200, 600,130, 700, 100, 800, 200, 1000,300, 800, 850, 500,600, 200,400, 100,200,0,0
};

void draw() {
  background(#f5f4f4);
    
  image(myImage, 0, 0); 
  //stroke(255,255,0);
  //fill(255,255,0);
  //beginShape();
  //for (int i = 0; i < coords.length; i += 2) {
  //  curveVertex(coords[i], coords[i + 1]);
  //}
  
  //endShape();

  noFill();
  stroke(155,0,155);
  pack.run();

  if (growing)
    pack.addCircle(new Circle(width/2, height/2));

  //saveFrame("frames/#####.tif");
}




void convertToEmbroidery(){
    //E.scale(2);
    
    //old code for priting center coords
    //for (int i=0; i<pack.circles.size(); i++) {
    //  Circle circ = pack.circles.get(i);
    //  int circX =  int(pack.circles.get(i).position.x);
    //  int circY = int(pack.circles.get(i).position.y);
    //  int circRad = int(pack.circles.get(i).radius);
    //  //fill(random(0,255),random(0,255),random(0,255));
    //  //text( str(circX) + " ," + str(circY) + " " + str(circRad), circX, circY);  
    //  //text( str(circX) + " ," + str(circY) + " " + str(circRad), circX, circY);  
      

    //}
    
    //E.optimize();
    // background(100);
    
    
        for (int i=0; i<pack.circles.size(); i++) {
      Circle circ = pack.circles.get(i);
      int circX =  int(pack.circles.get(i).position.x);
      int circY = int(pack.circles.get(i).position.y);
      //int circRad = int(pack.circles.get(i).radius + random(5,30) );
            int circRad = int(pack.circles.get(i).radius + random(0,0) );

      //fill(123,122,9);
      //text( str(circX) + " ," + str(circY), circX, circY);
      
        }
    //drawFill();
          
    for ( int i = pack.circles.size()-1; i > 0; i --){
      print(i);
      int circX =  int(pack.circles.get(i).position.x);
      int circY = int(pack.circles.get(i).position.y);
      //int circRad = int(pack.circles.get(i).radius + random(5,30) );
      int circRad = int(pack.circles.get(i).radius + random(0,0) );
      
      int pixelCoord = toSingleCoord( circX, circY);
      
      if(colorCheck(circX, circY, circRad)){     
      E.circle( circX, circY, circRad+10); 
        }
      
    }
    
   drawStroke();
    
    
    PEmbroiderWrite();
    noLoop();

}

void drawStroke(){
  noFill();
  E.strokeWeight(15); 
  E.strokeMode(PEmbroiderGraphics.PERPENDICULAR);
  E.strokeSpacing(3.0); 
  E.strokeLocation(E.INSIDE);
  E.stroke(0, 255,0); // Blue stroke
  E.image(myImage, 0, 0); 
}


void drawFill(){
  noStroke();
  E.setRenderOrder(E.STROKE_OVER_FILL);
  // Use the Cull feature to make lines and strokes not overlap
  E.beginCull();
  // Draw it once, filled. 
  //E.noStroke();
  E.fill(0, 255, 0); // Blue fill
  E.hatchMode(PEmbroiderGraphics.PERLIN); 
  E.HATCH_MODE = PEmbroiderGraphics.PERLIN;
  E.HATCH_SPACING = 10;
  E.HATCH_SCALE = 4.5;
  //E.hatchSpacing(15.0); 
  E.image(myImage, 0, 0);
}

boolean colorCheck(int x, int y, int rad){
       
      int pixelCoord = toSingleCoord( x, y);
      
      float r = red(myImage.pixels[pixelCoord]);
      float g = green(myImage.pixels[pixelCoord]);
      float b = blue(myImage.pixels[pixelCoord]);
      if(r == 0 && g == 0 && b == 0){ 
      return false;}
      else {
        return true;
      }
}


void stopRunning(){
  running = false;
}


//////// run these at begginning and end of setup ////////////////////////////////////

void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(10, 30, .1);
}

void PEmbroiderWrite() {
  E.optimize();
  E.visualize(true, true, true);
  E.endDraw(); // write out the file
  save(fileName+".png"); //saves a png of design from canvas
}











class Pack {
  ArrayList<Circle> circles;

  float max_speed = 1;
  float max_force = 1;

  float border = 5;

  float min_radius =circleMin;
  float max_radius = circleMax;

  Pack(int n) {  
    initiate(n);
  }

  void initiate(int n) {
    circles = new ArrayList<Circle>(); 
    for (int i = 0; i < n; i++) {
      addCircle(new Circle(width/2, height/2));
    }
  }

  void addCircle(Circle b) {
    circles.add(b);
  }

  void run() {

    PVector[] separate_forces = new PVector[circles.size()];
    int[] near_circles = new int[circles.size()];

    for (int i=0; i<circles.size(); i++) {
      checkBorders(i);
      updateCircleRadius(i);
      applySeparationForcesToCircle(i, separate_forces, near_circles);
      displayCircle(i);
    }
  }

  void checkBorders(int i) {
    Circle circle_i=circles.get(i);
    if (circle_i.position.x-circle_i.radius/2 < border)
      circle_i.position.x = circle_i.radius/2 + border;
    else if (circle_i.position.x+circle_i.radius/2 > width - border)
      circle_i.position.x = width - circle_i.radius/2 - border;
    if (circle_i.position.y-circle_i.radius/2 < border)
      circle_i.position.y = circle_i.radius/2 + border;
    else if (circle_i.position.y+circle_i.radius/2 > height - border)
      circle_i.position.y = height - circle_i.radius/2 - border;
  }

  void updateCircleRadius(int i) {
    circles.get(i).updateRadius(min_radius, max_radius);
  }

  void applySeparationForcesToCircle(int i, PVector[] separate_forces, int[] near_circles) {

    if (separate_forces[i]==null)
      separate_forces[i]=new PVector();

    Circle circle_i=circles.get(i);

    for (int j=i+1; j<circles.size(); j++) {

      if (separate_forces[j] == null) 
        separate_forces[j]=new PVector();

      Circle circle_j=circles.get(j);

      PVector forceij = getSeparationForce(circle_i, circle_j);

      if (forceij.mag()>.04) {
        separate_forces[i].add(forceij);        
        separate_forces[j].sub(forceij);
        near_circles[i]++;
        near_circles[j]++;
      }
      
        if (forceij.mag()<.029) {
        separate_forces[i].add(forceij);        
        separate_forces[j].sub(forceij);
        near_circles[i]--;
        near_circles[j]--;
      }
    }

    if (near_circles[i]>0) {
      separate_forces[i].div((float)near_circles[i]);
    }

    if (separate_forces[i].mag() >0) {
      separate_forces[i].setMag(max_speed);
      separate_forces[i].sub(circles.get(i).velocity);
      separate_forces[i].limit(max_force);
    }

    PVector separation = separate_forces[i];

    circles.get(i).applyForce(separation);
    circles.get(i).update();

    // If they have no intersecting neighbours they will stop moving
    circle_i.velocity.x = 0.0;
    circle_i.velocity.y = 0.0;
  }

  PVector getSeparationForce(Circle n1, Circle n2) {
    PVector steer = new PVector(0, 0, 0);
    float d = PVector.dist(n1.position, n2.position);
    if ((d > 0) && (d < n1.radius/2+n2.radius/2 + border)) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(d);
      steer.add(diff);
    }
    return steer;
  }

  String getSaveName() {
    return  day()+""+hour()+""+minute()+""+second();
  }

  void exportDXF() {
    String exportName = getSaveName()+".dxf";
    RawDXF dxf = (RawDXF)createGraphics(width, height, DXF, exportName);
    dxf.beginDraw();
    for (int i=0; i<circles.size(); i++) {
      Circle p = circles.get(i);
      dxfCircle(p.position.x, p.position.y, p.radius/2., dxf);
    }
    dxf.endDraw();
    dxf.dispose();
    dxf.endRaw();

    println(exportName + " saved.");
  } 

  void dxfCircle(float x, float y, float r, RawDXF dxf) {
    dxf.println("0");
    dxf.println("CIRCLE");
    dxf.println("10");
    dxf.println(Float.toString(x));
    dxf.println("20");
    dxf.println(Float.toString(height - y));
    dxf.println("40");
    dxf.println(Float.toString(r));
  }

  void exportSVG() {
    String exportName = getSaveName()+".svg";
    PGraphics pg = createGraphics(width, height, SVG, exportName);
    pg.beginDraw();
    pg.rect(0, 0, width, height);
    for (int i=0; i<circles.size(); i++) {
      Circle p = circles.get(i);
      pg.ellipse(p.position.x, p.position.y, p.radius, p.radius);
    } 
    pg.endDraw();
    pg.dispose();
    println(exportName + " saved.");
  }

  void displayCircle(int i) {
    circles.get(i).display();
  }
}

class Circle {

  PVector position;
  PVector velocity;
  PVector acceleration;

  float radius = 1;

  Circle(float x, float y) {
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
    position = new PVector(x, y);
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update() {
    //velocity.add(noise(100+position.x*0.01, 100+position.y*0.01)*0.5, noise(200+position.x*0.01, 200+position.y*0.01)*0.5); 
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void updateRadius(float min, float max) {
    radius = min + noise(position.x*0.01, position.y*0.01) * (max-min);
  }

  void display() {
    ellipse(position.x, position.y, radius, radius);
  }
}

void mouseDragged() {
  pack.addCircle(new Circle(mouseX, mouseY));
}

void mouseClicked() {
  pack.addCircle(new Circle(mouseX, mouseY));
}

int toSingleCoord(int x, int y) {
  return ((y*width) + x);
  
}

boolean isBlack(int x, int y){
  
      int pixelCoord = toSingleCoord( x, y);
      
      float r = red(myImage.pixels[pixelCoord]);
      float g = green(myImage.pixels[pixelCoord]);
      float b = blue(myImage.pixels[pixelCoord]);
      if(r == 0 && g == 0 && b == 0){ 
        return true;
      }
      return false;
}

boolean hasAnyBlack(int x, int y, int rad){
  rad+=5;
  if (isBlack(x,y)){
    return true;
  } else if (isBlack(x + rad/2, y)) {
    return true;
  } else if (isBlack(x - rad/2, y)) {
    return true;
  } else if (isBlack(x, y - rad/2)) {
    return true;
  } else if (isBlack(x, y + rad/2)) {
    return true;
  } 
  
  return false;
  
}

void keyPressed() {
 
  if (key == 'r' || key == 'R') {
    pack.initiate(n_start);
    noiseSeed((long)random(100000));
  } else if (key == 'p' || key == 'P') {
    growing=!growing;
  } else if (key == 'd' || key == 'D'){
    
    for ( int i = pack.circles.size()-1; i > 0; i --){
      print(i);
      int circX =  int(pack.circles.get(i).position.x);
      int circY = int(pack.circles.get(i).position.y);
      //int circRad = int(pack.circles.get(i).radius + random(5,30) );
      int circRad = int(pack.circles.get(i).radius + random(0,0) );
      
      if (hasAnyBlack(circX, circY, circRad)){
          pack.circles.remove(i);
      }
      //println( "___" +r+"," + g+","+b);
    }
      
  //} else if (key == 's' || key == 'S') {
  //  String name = ""+day()+hour()+minute()+second();
  //  pack.exportDXF();
  //  pack.exportSVG();
  //  saveFrame(name+".png");
  //  println(name + " saved.");
  }
  
  if(key == ' '){
    convertToEmbroidery();
  }
}
