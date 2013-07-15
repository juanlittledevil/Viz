// Author: Juan Segovia

Maxim maxim;
AudioPlayer player;

float time = 0;
float time2 = 0;
boolean playAudio;
//float[] spec;
float power = 0;
float topPower = 0;
float go;
int xPos = 0;
boolean pos = true;
boolean changeShape = false;
int fade = 0;

float magnify = 300;
float rotation = 0;
float radius = 0;
int brightness = 0;
int elements = 64;

// Shapes
String[] shapes = { "circle", "square", "rect", "x", "chSquare" };
//String[] shapes = { "chSquare" };
String shape = shapes[0];

void setup() {
  // Setup Screen
  size(1024, 640);
  frameRate(25);
  rectMode(CENTER);
  background(0);
  colorMode(HSB);
  
  // Setup Audio Source
  maxim = new Maxim(this);
  player = maxim.loadFile("STUFFSONG.wav");
  player.setLooping(true);
  player.volume(1.0);
}

void draw() {
  if (playAudio) {
    player.play();
    power = player.getAveragePower();
//    spec = player.getPowerSpectrum();
    go += power * 50;
  
    background(0); // clear the screen so we adhere to the frame rate.
    radius = map(xPos, 0, width, 0, 10);
    rotation = map(mouseY, 0, height, 0, 10);
    brightness = (int) map(power, 0, .5, 0, 255);
    float spacing = TWO_PI/elements;
    translate(width / 2, height / 2); // move everything to the middle of the screen
    noFill(); // prevent the objects from blocking eachother.
    strokeWeight(2);
    
    // cycle through time in a ping pong manner.
    time = time + 0.01;
    time2 = time + 0.5;
    if (pos) {
      if (power > 0) {
        xPos += 1;
        changeShape = true;
        fade = 0;
      } else {
        if (changeShape) {
          changeShape = false;
          shape = shapes[int(random(shapes.length))];
        }
      }
    } else {
      if (power > 0 ) {
        xPos -= 1;
        changeShape = true;
        fade = 0;
      } else {
        if (changeShape) {
          changeShape = false;
          shape = shapes[int(random(shapes.length))];
        }
      }
    }  
    if ( xPos == width || xPos == 0 ) {
      pos = !pos;
    }
        
    print(power + " ");
    print(time % 15 + " ");
    print(go + " ");
    print(shape);
    println();
    
    // Draw all the sapes on the screen.
    for (int i = 0; i < elements; i++) {
      stroke(i * 2, 255, 255);
      if (power > 0) {
        fill((5 * i + go) % 255, 255, brightness);
      } else {
        noFill();
      }
      pushMatrix();
      rotate(spacing * i * (time % 10) );
      translate(sin(spacing * i * radius) * magnify, 0);
      
      // draw shapes depending on what 'shape' is.
      if ( shape == "circle" ) {
        ellipse(0,0,2 * i,2 * i);
      } else if ( shape == "square" ) {
        rect(0,0,2 * i,2 * i, 8);
      } else if ( shape == "chSquare" ) {
        rect(0,0,2 * i,2 * i, int(time2 % 50));
      } else if ( shape == "rect" ) {
        rect(0,0,i, .5 * i);
      } else if ( shape == "x") {
        rotate(PI/i * time);
        strokeWeight(int(random(1, 5)));
        line(0, 0, i + int(random(1, 10)) , i + int(random(1, 10)));
        line(0, i + int(random(1, 10)), i + int(random(1, 10)), 0);
      }
      
      popMatrix();
    }
    
    // Fade to black when no lows are playing...
    if ( power < 0 ) {
      translate(0, 0);
      stroke(0);
      fill(0, 0, 0, fade);
      rect(0, 0, width, height);
      if ( fade < 255 ) { fade += 2; }
    }
  }
}

void mousePressed() {
  playAudio = !playAudio;
  
  if (playAudio) {
    player.play();
    
  } else {
    player.stop();
  }
}
