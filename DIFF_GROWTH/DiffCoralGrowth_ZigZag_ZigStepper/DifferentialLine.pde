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
    for (int i=1; i<nodes.size()-1; i++) {
        Node n = nodes.get(i);
        n.run(nodes);
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
    //vertex(nodes.get(0).position.x, nodes.get(0).position.y);
    endShape(OPEN);
  }
  
  void renderZig() {
    noFill();
    stroke(10);
    beginShape();
    int dir = 1;
    for (int i=0; i<nodes.size()-1; i++) {
      PVector p1 = nodes.get(i).position;
      PVector p2 = nodes.get(i+1).position;
      PVector tan = p2.copy().sub(p1).normalize();
      tan.rotate(PI/2);
      tan.mult(3);
      println(tan);
      vertex(p1.x+tan.x*dir, p1.y+tan.y*dir);
      dir*= -1;
    }
    endShape(OPEN);
  }

  void render(PEmbroiderGraphics E) {
    E.beginShape();
    for (int i=0; i<nodes.size(); i++) {
      PVector p1 = nodes.get(i).position;
      E.vertex(p1.x, p1.y);
    }
   // E.vertex(nodes.get(0).position.x, nodes.get(0).position.y);
    E.endShape();
  }
  void exportFrame() {
    saveFrame(day()+""+hour()+""+minute()+""+second()+".png");
  }
  
  void renderZig(PEmbroiderGraphics E) {
    int dir = 1;
    E.beginShape();
    for (int i=0; i<nodes.size()-1; i++) {
      PVector p1 = nodes.get(i).position;
      PVector p2 = nodes.get(i+1).position;
      PVector tan = p2.copy().sub(p1).normalize();
      tan.rotate(PI/2);
      tan.mult(3);
      println(tan);
      E.vertex(p1.x+tan.x*dir, p1.y+tan.y*dir);
      dir*= -1;
    }
   // E.vertex(nodes.get(0).position.x, nodes.get(0).position.y);
    E.endShape();
  }
  
  
}
