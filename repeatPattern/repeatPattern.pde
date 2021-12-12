import processing.embroider.*;
PEmbroiderGraphics E_Ref;
PEmbroiderGraphics E;



void setup(){
  size(1000, 500);
  E = new PEmbroiderGraphics(this, width, height);
  E_Ref = new PEmbroiderGraphics(this, width, height);
  E.setPath( sketchPath("Output.pes"));
  
  E_Ref.circle(10,10,10);
}


void createRepeate(PEmbroiderGraphics E_Ref,PEmbroiderGraphics E){
  /// we use the pattern built in E_Ref and create a repeate pattern using E
}
