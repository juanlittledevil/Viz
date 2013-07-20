// --  Viz --
// Version 1.0
// Author: Juan Segovia
// Description: Audio Visualizer app. process audio from maxim player.
// Created: 7/14/13
//
// =========================================================================================
//     Globally defined variables.
// =========================================================================================

Maxim maxim;
PImage titleImage;
AudioPlayer player;

// Audio File to load.
String audioFile = "STUFFSONG.mp3";

// Other variables which require tweaking...
int elements = 64;               // this gets randomized later...
float threshold = 0.28;           // used to in beat detection. (the color)
float thresh2 = 0.22;            // used to control expand.
float thresh3 = 0.24;            // used to control when shapes are chnaged.
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

// =========================================================================================
//       SETUP
// =========================================================================================

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

// =========================================================================================
//      Draw udates the screen. This is by all means the (main method)
// =========================================================================================

void draw() {
  if (playAudio) {
    // ============
    // Audio  setup
    // ============
    player.play();
    power = player.getAveragePower();
    go += amp * 50;
    
    // beat detection...
    if ( power > threshold && wait < 0 ) {
      amp += power;
      wait += 10;
    }
    wait--;
 
    // ========
    // Graphics
    // ========
    // Reset the screen prior to drawing new frame.
    background(0);
    strokeWeight(2);
    noFill(); 
    
    // Variables used for movement are based on timers, and size of the screen.
    radius = map(xPos, 0, width, 0, 10);
    rotation = map(int(time2 % height), 0, height, 0, 10);
    brightness = (int) map(power, 0, .5, 0, 255);
    
    // spacing is determined by the number of elemts and are aranged in a circle
    float spacing = TWO_PI/elements;
    
    // move everything to the middle of the screen
    translate(width / 2, height / 2);
    
    // ============
    // Timed events
    // ============
    // cycle through time in a ping pong manner.
    // update time keepers.
    time = time + 0.01;
    time2 = time + 0.5;
        
    // Radius is being set with xPos this hack makes it ping pong.
    if ( xPos == width || xPos == 0 ) {
      pos = !pos;
    }

    if (power > thresh2) {
      if (pos) {
        xPos += 1;
      } else {
        xPos -= 1;
      }
    }

      
    // Change the shapes on the screen at random.
    if (power > thresh3) {
      changeShape = true;
      
      // reset the fade amount so we see stuff on the screen.
      fade = 0;
      
    } else {
      // if changeSpae is true and power is less than threshold
      // let's change stuff.
      if (changeShape) {
        changeShape = false;
        shape = shapes[int(random(shapes.length))];
        elements = int(random(32, 124));
      }
    }
    
    // =================================
    // Draw all the sapes on the screen.
    // =================================
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
        rect(0,0,i, (.5 * i + go) % 20);
      } else if ( shape == "x") {
        rotate(PI/i * time);
        strokeWeight(int(random(1, 5)));
        line(0, 0, i + int(random(1, 10)) , i + int(random(1, 10)));
        line(0, i + int(random(1, 10)), i + int(random(1, 10)), 0);
      }
      
      popMatrix();
    }
    
    // =========================================
    // Fade to black when no lows are playing...
    // =========================================
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
        tint(255, int(time3));
        image(titleImage, -590, 180);
        titleOn = true;
      }
    }
    
    // ====================
    // Draw the title image
    // ====================
    if (titleOn) {
      tint(255, int(time3));
      image(titleImage, -590, 180);
      time3 += .6;
      if (time3 > 255) {
        time3 = 0;
        titleOn = false;
      }
    }
  }
}

// =========================================================================================
//   EVENTS
// =========================================================================================

void mousePressed() {
  playAudio = !playAudio;
  
  if (playAudio) {
    player.play();
    
  } else {
    player.stop();
  }
}
