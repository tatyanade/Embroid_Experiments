class DifferentialLine {
  ArrayList<Node> nodes;
  float maxForce;
  float maxSpeed;
  float desiredSeparation;
  float separationCohesionRation;
  float maxEdgeLen;
  DifferentialLine(float mF, float mS, float dS, float sCr, float eL) {
    nodes = new ArrayList<Node>();
    maxSpeed = mF;
    maxForce = mS;
    desiredSeparation = dS;
    separationCohesionRation = sCr;
    maxEdgeLen = eL;
  }
  void run() {
    for (Node n : nodes) {
      if (!doEndMotion || n.lastNoded > 0) {
        n.run(nodes);
      }
    }
    growth();
  }
  void addNode(Node n) {
    nodes.add(n);
  }
  void addNodeAt(Node n, int index) {
    nodes.add(index, n);
  }
  void growth() {
    for (int i=0; i<nodes.size()-1; i++) {
      Node n1 = nodes.get(i);
      Node n2 = nodes.get(i+1);
      if (!doEndMotion || n1.lastNoded > 0 || n2.lastNoded > 0) {
        float d = PVector.dist(n1.position, n2.position);
        if (d>maxEdgeLen) { // Can add more rules for inserting nodes
          int index = nodes.indexOf(n2);
          PVector middleNode = PVector.add(n1.position, n2.position).div(2);
          addNodeAt(new Node(middleNode.x, middleNode.y, maxForce, maxSpeed, desiredSeparation, separationCohesionRation), index);
          n1.lastNoded ++;
          n2.lastNoded ++;
        } else {
          n1.lastNoded -= .1;
          n2.lastNoded -= .1;
        }
      }
    }
  }
  void render() {
    beginShape();
    noFill();
    stroke(10);
    for (int i=0; i<nodes.size(); i++) {
      PVector p1 = nodes.get(i).position;
      vertex(p1.x, p1.y);
      circle(p1.x, p1.y, 2);
    }
    vertex(nodes.get(0).position.x, nodes.get(0).position.y);
    endShape();
  }

  void render(PEmbroiderGraphics E) {
    E.beginShape();
    for (int i=0; i<nodes.size(); i++) {
      PVector p1 = nodes.get(i).position;
      E.vertex(p1.x, p1.y);
    }
    E.vertex(nodes.get(0).position.x, nodes.get(0).position.y);
    E.endShape(CLOSE);
  }

  
  void renderLoop(PEmbroiderGraphics E) {
    E.beginShape();
    for (int i=0; i<nodes.size(); i++) {
      PVector p1 = nodes.get(i%nodes.size()).position;
      PVector p2 = nodes.get((i+1)%nodes.size()).position;
      drawLoopLine(E,p1.x,p1.y,p2.x,p2.y,8,10,1.7);
    }
    E.endShape(CLOSE);
  }
  
  void exportFrame() {
    saveFrame(day()+""+hour()+""+minute()+""+second()+".png");
  }
  
  
  void drawLoopLine(PEmbroiderGraphics E ,float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap){  
  float r = circleRad;
  float cx = startX;
  float cy = startY;
  
  float lineLength = dist(startX, startY, endX, endY);
  float numCycles = (lineLength/r)*(1/overlap);

  float angleDifference = stitchLength/r;
  float pointsPerCircle = TWO_PI/angleDifference;
  float numSteps = pointsPerCircle*numCycles ;
  
  float dx = (endX-startX)/ numSteps;
  float dy = (endY-startY)/ numSteps;
  
  float curCX = cx;
  float curCY = cy;
  for (int i = 0; i < numSteps; i++){
    float curX = curCX+(r * cos(loopLineAngle));
    float curY = curCY+(r * sin(loopLineAngle));
    
    E.vertex(curX, curY);
    //circle(curX, curY, 1);
    
    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;
  }

}
}
