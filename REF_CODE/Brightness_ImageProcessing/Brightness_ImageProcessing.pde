/**
 * Brightness
 * by Daniel Shiffman. 
 * 
 * This program adjusts the brightness of a part of the image by
 * calculating the distance of each pixel to the mouse.
 */

PImage img;

void setup() {
  size(640, 360);
  frameRate(30);
  img = loadImage("moon-wide.jpg");
  img.loadPixels();
  // Only need to load the pixels[] array once, because we're only
  // manipulating pixels[] inside draw(), not drawing shapes.
  loadPixels();
}

void draw() {
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++ ) {
      // Calculate the 1D location from a 2D grid
      int loc = x + y*img.width;
      // Get the R,G,B values from image
      float b;
      b = brightness((img.pixels[loc]));
      color c = color(b);
      pixels[y*width + x] = c;
    }
  }
  updatePixels();
}
