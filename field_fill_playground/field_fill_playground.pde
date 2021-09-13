// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 

void setup(){
}

void draw(){
}



  void test_field() {
  class MyVecField implements PEmbroiderGraphics.VectorField {
    public PVector get(float x, float y) {
      x*=0.01;
      y*=0.01;
      return new PVector(0, 10).rotate(noise(x,y)*2*PI);
    }
  }

  MyVecField mvf = new MyVecField();
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;

  E.noStroke();
  E.fill(0);

  E.circle(100, 100, 500);
  E.quad(10, 10, 80, 20, 50, 90, 5, 30);
  E.rect(100, 5, 100, 100);
  }
