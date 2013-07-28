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
float time4 = 1;
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
        translate(width/time4 % 10, int(height/time4));
        time4 = time4 + 0.001;
        if (time4 > 25.0) {
          time4 = 1;
        }
        rotate(HALF_PI/time4);
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

int HORIZONTAL = 0;
int VERTICAL   = 1;
int UPWARDS    = 2;
int DOWNWARDS  = 3;

class Widget
{

  
  PVector pos;
  PVector extents;
  String name;

  color inactiveColor = color(60, 60, 100);
  color activeColor = color(100, 100, 160);
  color bgColor = inactiveColor;
  color lineColor = color(255);
  
  
  
  void setInactiveColor(color c)
  {
    inactiveColor = c;
    bgColor = inactiveColor;
  }
  
  color getInactiveColor()
  {
    return inactiveColor;
  }
  
  void setActiveColor(color c)
  {
    activeColor = c;
  }
  
  color getActiveColor()
  {
    return activeColor;
  }
  
  void setLineColor(color c)
  {
    lineColor = c;
  }
  
  color getLineColor()
  {
    return lineColor;
  }
  
  String getName()
  {
    return name;
  }
  
  void setName(String nm)
  {
    name = nm;
  }


  Widget(String t, int x, int y, int w, int h)
  {
    pos = new PVector(x, y);
    extents = new PVector (w, h);
    name = t;
    //registerMethod("mouseEvent", this);
  }

  void display()
  {
  }

  boolean isClicked()
  {
    
    if (mouseX > pos.x && mouseX < pos.x+extents.x 
      && mouseY > pos.y && mouseY < pos.y+extents.y)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  public void mouseEvent(MouseEvent event)
  {
    //if (event.getFlavor() == MouseEvent.PRESS)
    //{
    //  mousePressed();
    //}
  }
  
  
  boolean mousePressed()
  {
    return isClicked();
  }
  
  boolean mouseDragged()
  {
    return isClicked();
  }
  
  
  boolean mouseReleased()
  {
    return isClicked();
  }
}

class Button extends Widget
{
  PImage activeImage = null;
  PImage inactiveImage = null;
  PImage currentImage = null;
  color imageTint = color(255);
  
  Button(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }
  
  void setImage(PImage img)
  {
    setInactiveImage(img);
    setActiveImage(img);
  }
  
  void setInactiveImage(PImage img)
  {
    if(currentImage == inactiveImage || currentImage == null)
    {
      inactiveImage = img;
      currentImage = inactiveImage;
    }
    else
    {
      inactiveImage = img;
    }
  }
  
  void setActiveImage(PImage img)
  {
    if(currentImage == activeImage || currentImage == null)
    {
      activeImage = img;
      currentImage = activeImage;
    }
    else
    {
      activeImage = img;
    }
  }
  
  void setImageTint(float r, float g, float b)
  {
    imageTint = color(r,g,b);
  }

  void display()
  {
    if(currentImage != null)
    {
      //float imgHeight = (extents.x*currentImage.height)/currentImage.width;
      float imgWidth = (extents.y*currentImage.width)/currentImage.height;
      
      
      pushStyle();
      imageMode(CORNER);
      tint(imageTint);
      image(currentImage, pos.x, pos.y, imgWidth, extents.y);
      stroke(bgColor);
      noFill();
      rect(pos.x, pos.y, imgWidth,  extents.y);
      noTint();
      popStyle();
    }
    else
    {
      pushStyle();
      stroke(lineColor);
      fill(bgColor);
      rect(pos.x, pos.y, extents.x, extents.y);
  
      fill(lineColor);
      textAlign(CENTER, CENTER);
      text(name, pos.x + 0.5*extents.x, pos.y + 0.5* extents.y);
      popStyle();
    }
  }
  
  boolean mousePressed()
  {
    if (super.mousePressed())
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
      return true;
    }
    return false;
  }
  
  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
      return true;
    }
    return false;
  }
}

class Toggle extends Button
{
  boolean on = false;

  Toggle(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }


  boolean get()
  {
    return on;
  }

  void set(boolean val)
  {
    on = val;
    if (on)
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
    }
    else
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
    }
  }

  void toggle()
  {
    set(!on);
  }

  
  boolean mousePressed()
  {
    return super.isClicked();
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      toggle();
      return true;
    }
    return false;
  }
}

class RadioButtons extends Widget
{
  public Toggle [] buttons;
  
  RadioButtons (int numButtons, int x, int y, int w, int h, int orientation)
  {
    super("", x, y, w*numButtons, h);
    buttons = new Toggle[numButtons];
    for (int i = 0; i < buttons.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x+i*(w+5);
        by = y;
      }
      else
      {
        bx = x;
        by = y+i*(h+5);
      }
      buttons[i] = new Toggle("", bx, by, w, h);
    }
  }
  
  void setNames(String [] names)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(i >= names.length)
        break;
      buttons[i].setName(names[i]);
    }
  }
  
  void setImage(int i, PImage img)
  {
    setInactiveImage(i, img);
    setActiveImage(i, img);
  }
  
  void setAllImages(PImage img)
  {
    setAllInactiveImages(img);
    setAllActiveImages(img);
  }
  
  void setInactiveImage(int i, PImage img)
  {
    buttons[i].setInactiveImage(img);
  }

  
  void setAllInactiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setInactiveImage(img);
    }
  }
  
  void setActiveImage(int i, PImage img)
  {
    buttons[i].setActiveImage(img);
  }
  
  
  
  void setAllActiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setActiveImage(img);
    }
  }

  void set(String buttonName)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].getName().equals(buttonName))
      {
        buttons[i].set(true);
      }
      else
      {
        buttons[i].set(false);
      }
    }
  }
  
  int get()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return i;
      }
    }
    return -1;
  }
  
  String getString()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return buttons[i].getName();
      }
    }
    return "";
  }

  void display()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].display();
    }
  }

  boolean mousePressed()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mousePressed())
      {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseDragged()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseReleased())
      {
        for(int j = 0; j < buttons.length; j++)
        {
          if(i != j)
            buttons[j].set(false);
        }
        //buttons[i].set(true);
        return true;
      }
    }
    return false;
  }
}

class Slider extends Widget
{
  float minimum;
  float maximum;
  float val;
  int textWidth = 60;
  int orientation = HORIZONTAL;

  Slider(String nm, float v, float min, float max, int x, int y, int w, int h, int ori)
  {
    super(nm, x, y, w, h);
    val = v;
    minimum = min;
    maximum = max;
    orientation = ori;
    if(orientation == HORIZONTAL)
      textWidth = 60;
    else
      textWidth = 20;
    
  }

  float get()
  {
    return val;
  }

  void set(float v)
  {
    val = v;
    val = constrain(val, minimum, maximum);
  }

  void display()
  {
    
    float textW = textWidth;
    if(name == "")
      textW = 0;
    pushStyle();
    textAlign(LEFT, TOP);
    fill(lineColor);
    text(name, pos.x, pos.y);
    stroke(lineColor);
    noFill();
    if(orientation ==  HORIZONTAL){
      rect(pos.x+textW, pos.y, extents.x-textWidth, extents.y);
    } else {
      rect(pos.x, pos.y+textW, extents.x, extents.y-textW);
    }
    noStroke();
    fill(bgColor);
    float sliderPos; 
    if(orientation ==  HORIZONTAL){
        sliderPos = map(val, minimum, maximum, 0, extents.x-textW-4); 
        rect(pos.x+textW+2, pos.y+2, sliderPos, extents.y-4);
    } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textW-4); 
        rect(pos.x+2, pos.y+textW+2, extents.x-4, sliderPos);
    } else if(orientation == UPWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textW-4); 
        rect(pos.x+2, pos.y+textW+2 + (extents.y-textW-4-sliderPos), extents.x-4, sliderPos);
    };
    popStyle();
  }

  
  boolean mouseDragged()
  {
    if (super.mouseDragged())
    {
      float textW = textWidth;
      if(name == "")
        textW = 0;
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textW, pos.x+extents.x-4, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textW, pos.y+extents.y-4, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textW, pos.y+extents.y-4, maximum, minimum));
      };
      return true;
    }
    return false;
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      float textW = textWidth;
      if(name == "")
        textW = 0;
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textW, pos.x+extents.x-10, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textW, pos.y+extents.y-10, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textW, pos.y+extents.y-10, maximum, minimum));
      };
      return true;
    }
    return false;
  }
}

class MultiSlider extends Widget
{
  Slider [] sliders;
  /*
  MultiSlider(String [] nm, float min, float max, int x, int y, int w, int h, int orientation)
  {
    super(nm[0], x, y, w, h*nm.length);
    sliders = new Slider[nm.length];
    for (int i = 0; i < sliders.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x;
        by = y+i*h;
      }
      else
      {
        bx = x+i*w;
        by = y;
      }
      sliders[i] = new Slider(nm[i], 0, min, max, bx, by, w, h, orientation);
    }
  }
  */
  MultiSlider(int numSliders, float min, float max, int x, int y, int w, int h, int orientation)
  {
    super("", x, y, w, h*numSliders);
    sliders = new Slider[numSliders];
    for (int i = 0; i < sliders.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x;
        by = y+i*h;
      }
      else
      {
        bx = x+i*w;
        by = y;
      }
      sliders[i] = new Slider("", 0, min, max, bx, by, w, h, orientation);
    }
  }
  
  void setNames(String [] names)
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(i >= names.length)
        break;
      sliders[i].setName(names[i]);
    }
  }

  void set(int i, float v)
  {
    if(i >= 0 && i < sliders.length)
    {
      sliders[i].set(v);
    }
  }
  
  float get(int i)
  {
    if(i >= 0 && i < sliders.length)
    {
      return sliders[i].get();
    }
    else
    {
      return -1;
    }
    
  }

  void display()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      sliders[i].display();
    }
  }

  
  boolean mouseDragged()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseReleased())
      {
        return true;
      }
    }
    return false;
  }
}


