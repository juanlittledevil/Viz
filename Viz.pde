// --  Viz --
// Version 1.0
// Author: Juan Segovia
// Description: Audio Visualizer app. process audio from maxim player.
// Created: 7/14/13


Maxim maxim;
PImage titleImage;
AudioPlayer player;

// Audio File to load.
String audioFile = "STUFFSONG.mp3";

// Other variables which require tweaking...
int elements = 64;               // this gets randomized later...
float threshold = 0.28;           // used to in beat detection. (the color)
float thresh2 = 0.22;            // used to control when shapes are chnaged and/or moved.
float fadeThresh = 0.1;          // used to control when to fade to black.
float magnify = random(200,400); // used to set how much of the screen we use or go out of...

// Initialization of other variables used in the program...
int xPos = 0;                    // init only..
int brightness = 0;              // init only..
int wait = 0;                    // init only..
int fade = 0;                    // init only..

boolean playAudio;               // init only..
boolean pos = true;              // init only.. (used to move through space)
boolean changeShape = false;     // init only.. (used to determine if it's time to swich shapes)
boolean titleOn = true;          // init only..

float amp = 0;                   // init only.. (used in beat detection.)
float rotation = 0;              // init only..
float radius = 0;                // init only..
float time = 0;                  // init only..
float time2 = 0;                 // init only..
float time3 = 0;
float power = 0;                 // init only..
float go = 0;                    // init only..
//float[] spec;


// Shapes
String[] shapes = { "circle", "square", "rect", "x", "chSquare" };
String shape = shapes[int(random(shapes.length))];

void setup() {
  // Setup Screen
  size(1024, 640);
  frameRate(25);
  rectMode(CENTER);
  background(0);
  colorMode(HSB);
  
  // Image.
  titleImage = loadImage("STUFFSONG.png");
  
  // Setup Audio Source
  maxim = new Maxim(this);
  player = maxim.loadFile(audioFile);
  player.setLooping(false);
  player.volume(1.0);
}

void draw() {
  if (playAudio) {
    player.play();
    power = player.getAveragePower();
//    spec = player.getPowerSpectrum();
    go += amp * 50;
    
    // beat detection...
    if ( power > threshold && wait < 0 ) {
      amp += power;
      wait += 10;
    }
    wait--;
  
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
    
    // Radius is being set with xPos this hack makes it ping pong.
    if (pos) {
      if (power > thresh2) {
        xPos += 1;
        changeShape = true;
        fade = 0;
      } else {
        if (changeShape) {
          changeShape = false;
          shape = shapes[int(random(shapes.length))];
          elements = int(random(32, 124));
        }
      }
    } else {
      if (power > thresh2) {
        xPos -= 1;
        changeShape = true;
        fade = 0;
      } else {
        if (changeShape) {
          changeShape = false;
          shape = shapes[int(random(shapes.length))];
          elements = int(random(32, 124));
        }
      }
    }  
    if ( xPos == width || xPos == 0 ) {
      pos = !pos;
    }

//    // Debug prints...        
//    print(power + " ");
//    print(amp + " ");
//    print(time % 15 + " ");
//    print(go + " ");
//    print(shape);
//    println();
    
    // Draw all the sapes on the screen.
    for (int i = 0; i < elements; i++) {
      stroke(i * 2, 255, 255);
      if (amp > 0) {
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
    if ( power < fadeThresh ) {
      translate(0, 0);
      stroke(0);
      fill(0, 0, 0, fade);
      rect(0, 0, width, height);
      if ( fade < 255 ) {
        fade += 2;
      } else {
        magnify = random(200,400);
      }
      if ( fade > 100 ) {
        image(titleImage, -590, 180);
        titleOn = true;
      }
    }
    if (titleOn) {
        image(titleImage, -590, 180);
        time3 += .6;
        if (time3 > 200) {
          time3 = 0;
          titleOn = false;
        }
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
