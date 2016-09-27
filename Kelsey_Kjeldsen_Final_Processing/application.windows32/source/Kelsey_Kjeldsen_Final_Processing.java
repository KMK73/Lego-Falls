import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Kelsey_Kjeldsen_Final_Processing extends PApplet {

 //for sound library
Catcher catcher;    // One catcher object
Timer timer;  // Timer for drops
BoxTimer boxTimer; //timer for bricks

//countown game timer variables
int timeLimit = 30000;
int timeStart = millis();
int timeRemaining;
int timePassed;

//sound library coin sound
Minim minim;
AudioSample coin; 
AudioSample boxSound;
PFont f;

//load global images
PImage startScreen; //game start image with text
PImage gamePlayingImage; //just grass image
PImage catcherImage; //catcher LEGO man
PImage dropImage; //drop
PImage gameEndImage; //full grass image
PImage bricks;

// An array of drop objects
ArrayList<Drop> drops;
int totalDrops = 0; // totalDrops

/*GAME STATES VARIABLES
 *********************************************************************/
int gameState;
final int GAME_WAITING = 0; //is the error from the "final" part??
final int GAME_PLAYING = 1;
final int GAME_OVER = 2;


//setting the boxes
ArrayList<Box> boxes;
int totalBoxes = 0; // total boxes

//dynamic screen size variables 
int displayX;
int displayY;

// Variables to keep track of score, level, lives left
int score;      // User's score
int lives;     // 5 lives per level 
int bestScore;

int r = 50; //radius of drop image
int y;


/* VOID SETUP 
 *********************************************************************/
public void setup() {

  /* LOADING ALL GLOBAL IMAGES-------------------------------------------
  */
  dropImage = loadImage ("star coin.png");
  startScreen = loadImage("startScreen1.png");
  gameEndImage = loadImage("grass background.jpg");
  gamePlayingImage = loadImage("grass-background-2.png");
  catcherImage = loadImage ("legoMan3.png");
bricks = loadImage("bricks.png");
  displayX = round(displayWidth*.8f);  
  displayY = round(displayHeight*.85f); //have to round to make an int
  size(displayX, displayY);
//  size(displayWidth, displayHeight);
  image(startScreen, 0, 0, displayX, displayY);


  //timer for until game ends
  timeLimit = 30000;
  timeStart = millis();


  //sound import
  minim = new Minim(this);
  coin = minim.loadSample("coin-04.wav", 512);
  boxSound = minim.loadSample("collision.wav", 512);

  //start of game, when it ends value is 2 (game actually over)
  gameState = GAME_WAITING;

  smooth();
  ellipseMode(CENTER);
  f = createFont("LEGOBRIX", 20, true); 


  //  totalDrops = 0;
  lives = 2; //3 lives 
  score = 0;
  bestScore = 0;

  catcher = new Catcher(); // Create the catcher 
  drops = new ArrayList<Drop>();
  timer = new Timer(500);   // Create a timer that goes off every .5 second
  timer.start();             // Starting the timer

  //array of boxes
  boxes = new ArrayList<Box>();
  boxTimer = new BoxTimer (1500 );   // Create a timer for bricks, goes off every .5 second
  boxTimer.start();  // Starting the timer for bricks
  totalBoxes = 0;
}

/*VOID DRAW 
 ********************************************************/
public void draw() {

  /*GAME OVER FUNCTION
   ********************************************************/

  switch (gameState) {
  case GAME_OVER: 
    {
      image(gameEndImage, 0, 0,displayX, displayY);  

      textFont(f, 40);
      textAlign(CENTER);
      fill(0); //black text
      text("GAME OVER", (width/2), (height/2)-40);
      textFont(f, 40);
      fill(255, 0, 0);
      text("YOUR SCORE " +score, width/2, height/2+40);
      fill(0);
      text("Score to beat " +bestScore, width/2, height/2+100);
      text("To play again press SPACEBAR", width/2, height/2+200);
    }
    break;
  }
  /*PLAYING GAME
   ********************************************************/
  switch (gameState) {
  case GAME_PLAYING: 
    {
      //removing start screen from memory cache 
      //background image
      background(0xff3bccdd);

      /*COUNTDOWN TIMER for time remaining in game
       ********************************************************/
      timePassed = (millis() - timeStart);
      timeRemaining = (timeLimit - timePassed);
      //when timer hits 0 seconds game over 
      if (timeRemaining <=0) {
        gameState = GAME_OVER;
        if (score > bestScore) {
          bestScore = score;
        }
      }

      /*DROP TIMER to drop coins
       ********************************************************/
      if (timer.isFinished()) {
        // if timer is finished send another drop
        // Initialize one drop
        Drop drop = new Drop();
        drops.add(drop);
        totalDrops++;
        //        y = -r*4;
        //        image(dropImage, random(width), y, r, r);
        if (totalDrops >= 20) { 
          // start array over
//          totalDrops = 0;
          drops.remove(0);
        }
        timer.start();
      } 

      /*BRICKS TIMER to drop bricks
       ********************************************************/
      if (boxTimer.isFinished()) {
        // if timer is finished send another box
        // Initialize one drop
        Box box = new Box();
        boxes.add(box);
        totalBoxes++;
        if (totalBoxes >= 20) { 
          // start array over
          totalBoxes=0;
          boxes.remove(0);
        }
        boxTimer.start();
      } 

      /*DROPS COLLISION and DISPLAY
       ********************************************************/
      for (int i = 0; i < drops.size (); i++ ) {
        drops.get(i).move();
        drops.get(i).display();

        // Everytime you catch a drop, the score goes up
        if (catcher.isCollidingCircle(drops.get(i))) {
          //drops.get(i).caught();
          drops.remove(i);
//          drops.remove(0);
          
          coin.trigger(); //trigger playing sound when collision occurs
          score++;
        }
      }


      /*BRICKS COLLISION and DISPLAY
       ********************************************************/
      for (int i = 0; i < boxes.size (); i++ ) {
        boxes.get(i).display();
        // collision detection
        if (catcher.isCollidingBox(boxes.get(i))) {
          boxSound.trigger(); //trigger playing sound when collision occurs
          lives--;
          //        boxes.get(i).resetWhenCollisionDetected(); //allow the box to go back to the top
          boxes.remove(i);

          //If lives reach 0 the game is over
          if (lives <= 0) {
            gameState = GAME_OVER;
            if (score > bestScore) {
              bestScore = score;
            }
          }
        }
      }


      /*TOP ELEMENTS on game screen. Lives left, time remaining, game score
       ********************************************************/

      textFont(f, 26);
      fill(0);
      textAlign(LEFT); //need to reset this to keep it aligned after CENTER is called
      text("Lives left: " + lives, 60, 30); //x 60 y 30
      fill(255, 0, 0);//red
      stroke(1);
      rect(60, 50, lives*30, 40); //line showing levels and the width is adjusted everytime you lose a life
      fill(0);//red fill
      text("Time Left: " + (timeRemaining)/1000, 400, 30);  //x 400 y 30
      text("Score: " + score, 400, 80);
      //grass background on bottom
      image(gamePlayingImage, 0, height - gamePlayingImage.height);
      
      //display catcher in front of grass
      catcher.display(); 
      catcher.move();
    }
  }
//  println("Drops size:" + drops.size());
//  println("Box size:"+ boxes.size());
}


/*KEYS FOR CHANGING GAME STATES
 ********************************************************/
public void keyPressed() {
  switch(gameState) {
  case GAME_WAITING:
    //check keys when waiting for game and spacebar to start
    if (key == ' ') {
      g.removeCache(startScreen);
      restart();
    }
    break;

  case GAME_PLAYING:
    break;

  case GAME_OVER:
    if (key == ' ') {
      //call restart function to start game again with spacebar
      restart();
    }
    break;
  }
}  

/*RESETING THE GAME AFTER GAME ENDS
 ********************************************************/
public void restart() {
  gameState = GAME_PLAYING;

  //reset variables
  totalBoxes = 0;
  totalDrops = 0;
  lives = 2;
  score = 0;
  timeStart = millis();
  timeRemaining = 30000;

  //restarting the arrays and timer
  catcher = new Catcher(); // Create the catcher 
  drops = new ArrayList<Drop>();
  timer = new Timer(500);   // Create a timer that goes off every .5 second
  timer.start();             // Starting the timer

  //array of boxes
  boxes = new ArrayList<Box>();
  boxTimer= new BoxTimer(1000);
  boxTimer.start();
}
       
class Box {

  float speedY; //speed down for rect
  float boxWidth;
  float boxHeight;
  float boxX;
  float boxY;

  Box () {
 //   bricks = loadImage("bricks.png");
    boxHeight = random (20, displayHeight*.075f);
    boxWidth = random (displayWidth*.10f, displayWidth*.20f); //40% width max
    boxX= random (0, width -40);
    boxY= random (-100, 0);
    speedY= random(1, 4);
  }

  public void display () {
    fill (0xff00FF39);
    stroke(1);
    image(bricks, boxX, boxY, boxWidth, boxHeight); 
    boxY= boxY + speedY;
  }

//needed to reset after a collision so lives dont reduce all at once
public void resetWhenCollisionDetected() {
  boxY=-10;
  boxX = random(width); //change x position at the top
  speedY = random(1, 2.5f);
}
}
/*code adapted from:
 // Learning Processing
 // Daniel Shiffman
 adapted by: Kelsey Kjeldsen
 ********************************************************/

//timer to drop bricks
class BoxTimer {

  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  BoxTimer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  public void setTime(int t) {
    totalTime = t;
  }

  // Starting the timer
  public void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 1000ms pass
  public boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}
class Catcher {
//  PImage catcherImage;
//  PShape catcherImage;
  int w;   // width
  float x, y; // location
  float speedX;
  /*code adapted from:
   // Learning Processing
   // Daniel Shiffman
   adapted by: Kelsey Kjeldsen
   ********************************************************/
  Catcher() {
//    catcherImage = loadImage("legoMan3.png");
    w = PApplet.parseInt(displayWidth * .08f);
    catcherImage.resize(w, 0);
    smooth();
    x = width/2;
    y = displayY - catcherImage.height;
    speedX = 0;
  }

  public void display() {
    stroke(0);
    image(catcherImage, x, y); 
  }

  public void move () { 
    // Display the catcher
    if (keyPressed) {
      //      catcher.move();
      if (keyCode == LEFT) {
        x -= 6f;
        if (x <= 0) {
          x =0;
        }
      }
      if (keyCode == RIGHT) {
        x += 6f;
        if (x >= width- catcherImage.width) {
          x =width-catcherImage.width;
        }
      }
    }
  }

  /*code adapted from:
   http://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection
   adapted by: Kelsey Kjeldsen
   ********************************************************/
  public boolean isCollidingCircle(Drop d) {
    //calculate the distance in absolute value of the drops and the rectangle
    float circleDistanceX = abs(d.x - x - catcherImage.width/2);
    float circleDistanceY = abs(d.y - y - catcherImage.height/2);
    if (circleDistanceX > (catcherImage.width/2 + d.r)) { 
      return false;
    }
    if (circleDistanceY > (catcherImage.height/2 + d.r)) { 
      return false;
    }

    if (circleDistanceX <= (catcherImage.width/2)) { 
      return true;
    } 
    if (circleDistanceY <= (catcherImage.height/2)) { 
      return true;
    }

    float cornerDistance_sq = pow(circleDistanceX - catcherImage.width/2, 2) +
      pow(circleDistanceY - catcherImage.height/2, 2);

    return (cornerDistance_sq <= pow(d.r, 2));
  }

  //Box b is made for a temporary reference of either box1 or box2 when they pass through the boolean
  public boolean isCollidingBox(Box b) {
    float myX2 = x+ catcherImage.width; // box x and width
    //    float myX2 = x + w; // box x and width
    float myY2 = y + catcherImage.height; //box y and height
    float otherX2 = b.boxX + b.boxWidth;
    float otherY2 = b.boxY + b.boxHeight;  

    //checking if the boxes hit each other by returning false when they are not touching 
    if ( x < b.boxX && myX2 < b.boxX) { //totally to the left not touching
      return false;
    }

    if ( x > otherX2 && myX2 > otherX2) { //totally right not touching 
      return false;
    }

    if ( y < b.boxY && myY2 < b.boxY) { //totally above not touching 
      return false;
    }

    if ( y > otherY2 && myY2 > otherY2) { //totally below not touching 
      return false;
    }

    return true; //because if all are false then they are colliding BOOM
  }
}


/*code adapted from:
 // Learning Processing
 // Daniel Shiffman
 adapted by: Kelsey Kjeldsen
 ********************************************************/

class Drop {
  float x, y;
  PImage drop;  
  float speed; 
  float r;     

  // New variable to keep track of whether drop is caught
  boolean caught = false;

  Drop() {
    r = 50;               
    x = random(width);    
    y = -r*4;              // Start a little above the window
    speed = random(3, 6);   // Pick a random speed
//    drop = loadImage ("star coin.png");

  }

  // Move the drop down
  public void move() {
    y += speed;
  }

  // Check if it hits the bottom
  public boolean reachedBottom() {
    if (y > height + r*4) { 
      return true;
    } else {
      return false;
    }
  }

  // Display the drop
  public void display() {
    noStroke();
//    for (int i = 2; i < r; i++ ) {
        image(dropImage, x, y, r, r);
//    }
  }
}

/*code adapted from:
 // Learning Processing
 // Daniel Shiffman
 adapted by: Kelsey Kjeldsen
 ********************************************************/

class Timer {

  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  public void setTime(int t) {
    totalTime = t;
  }

  // Starting the timer
  public void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 1000ms pass
  public boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "Kelsey_Kjeldsen_Final_Processing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
