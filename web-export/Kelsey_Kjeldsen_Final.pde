import ddf.minim.*; //for sound library
Catcher catcher;    // One catcher object
Timer timer;  // Timer for drops
BoxTimer boxTimer; //timer for bricks


int timeLimit = 30000;
int timeStart = millis();
int timeRemaining;
int timePassed;

//sound library coin sound
Minim minim;
AudioSample coin; 
AudioSample boxSound;
PFont f;

//load start screen image
PImage startScreen;
PImage gamePlayingImage;

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
PImage catcherImage;


/* VOID SETUP 
 *********************************************************************/
void setup() {

  //  start screen image load
  startScreen = loadImage("startScreen1.png");
  gamePlayingImage = loadImage("clouds-background.png");
  catcherImage = loadImage("legoMan3.png");

  displayX = round(displayWidth*.8);
  displayY = round(displayHeight*.85); //have to round to make an int
  size(displayX, displayY);

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


  totalDrops = 0;
  lives = 3; //3 lives 
  score = 0;
  bestScore = 0;

  catcher = new Catcher(); // Create the catcher 
  drops = new ArrayList<Drop>();
  timer = new Timer(600);   // Create a timer that goes off every .5 second
  timer.start();             // Starting the timer

  //array of boxes
  boxes = new ArrayList<Box>();
  boxTimer = new BoxTimer (900);   // Create a timer for bricks, goes off every .5 second
  boxTimer.start();  // Starting the timer for bricks
  totalBoxes = 0;
}

/*VOID DRAW 
 ********************************************************/
void draw() {

  /*GAME OVER FUNCTION
   ********************************************************/

  switch (gameState) {
  case GAME_OVER: 
    {
      //  if (gameState==GAME_OVER) {
      image(gamePlayingImage, 0, 0, displayX, displayY);      
      //      background(255);
      textFont(f, 40);
      textAlign(CENTER);
      fill(0);
      text("GAME OVER", width/2, height/2);
      fill(255, 0, 0);
      textFont(f, 20);
      text("SCORE " +score, width/2, height/2+40);
      text("Score to beat " +bestScore, width/2, height/2+80);
      text("To play again press SPACEBAR", width/2, height/2+120);
    }
    break;
  }
  /*PLAYING GAME
   ********************************************************/
  switch (gameState) {
  case GAME_PLAYING: 
    {
      //background white
      //      background(255);
      image(gamePlayingImage, 0, 0, displayX, displayY);

      //display catcher
      catcher.display(); 
      catcher.move();

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
      println ("timeRemaining"+ timeRemaining); 
      println ("timePassed" + timePassed);
      println ("timeStart2 " + timeStart);
      println ("timeLimit" + timeLimit); 

      /*DROP TIMER
       ********************************************************/
      if (timer.isFinished()) {
        // if timer is finished send another drop
        // Initialize one drop
        Drop drop = new Drop();
        drops.add(drop);
        totalDrops++;
        if (totalDrops >= 1000) { 
          // start array over
          totalDrops=0;
        }
        timer.start();
      } 

      /*BRICKS TIMER
       ********************************************************/
      if (boxTimer.isFinished()) {
        // if timer is finished send another box
        // Initialize one drop
        Box box = new Box();
        boxes.add(box);
        totalBoxes++;
        if (totalBoxes >= 10) { 
          // start array over
          totalBoxes=0;
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
          drops.get(i).caught();
          coin.trigger(); //trigger playing sound when collision occurs
          //        levelCounter++; //count this in amount of drops before new level
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

      //      fill(255);
      //      noStroke();
      //      rect( 0, 0, 600, 100);
      textFont(f, 26);
      fill(0);
      textAlign(LEFT); //need to reset this to keep it aligned after CENTER is called
      text("Lives left: " + lives, 60, 30); //x 60 y 30
      fill(#0024FF);
      stroke(1);

      for (int i = lives; i < lives; i = i+30) {
        catcherImage = loadImage("legoMan3.png");
        image(catcherImage, lives, 50, 40, 60);
      }
      //      rect(60, 50, lives*30, 40); //line showing levels and the width is adjusted everytime you lose a life
      fill(0);//black fill
      text("Time Left: " + (timeRemaining)/1000, 400, 30);  //x 400 y 30
      text("Score: " + score, 400, 80);
    }
  }
}


/*KEYS FOR CHANGING GAME STATES
 ********************************************************/
void keyPressed() {
  switch(gameState) {
  case GAME_WAITING:
    //check keys when waiting for game and spacebar to start
    if (key == ' ') {
      //      timeStart = millis(); //want to make sure it starts at 0
      //      gameState = GAME_PLAYING;
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
void restart() {
  gameState = GAME_PLAYING;

  //reset variables
  totalBoxes = 0;
  totalDrops = 0;
  lives = 3;
  score = 0;
  timeStart = millis();
  timeRemaining = 30000;

  //restarting the arrays and timer
  catcher = new Catcher(); // Create the catcher 
  drops = new ArrayList<Drop>();
  timer = new Timer(750);   // Create a timer that goes off every .5 second
  timer.start();             // Starting the timer

  //array of boxes
  boxes = new ArrayList<Box>();
  boxTimer= new BoxTimer(1000);
  boxTimer.start();
}

class Box {

  PImage bricks;
  float speedY; //speed down for rect
  float boxWidth;
  float boxHeight;
  float boxX;
  float boxY;

  Box () {
    bricks = loadImage("bricks.png");
    boxHeight = random (20, displayHeight*.075);
    boxWidth = random (displayWidth*.10, displayWidth*.20); //40% width max
    boxX= random (0, width -40);
    boxY= random (-100, 0);
    speedY= random(1, 4);
  }

  void display () {
    fill (#00FF39);
    stroke(1);
    //    rect(boxX, boxY, boxWidth, boxHeight);
    image(bricks, boxX, boxY, boxWidth, boxHeight); 
    boxY= boxY + speedY;
  }

//needed to reset after a collision so lives dont reduce all at once
void resetWhenCollisionDetected() {
  boxY=-10;
  boxX = random(width); //change x position at the top
  speedY = random(1, 2.5);
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

  void setTime(int t) {
    totalTime = t;
  }

  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 1000ms pass
  boolean isFinished() { 
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
  PImage catcherImage;
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
    catcherImage = loadImage("legoMan3.png");
//    catcherImage = loadShape("legoMan3.svg");
    w = int(displayWidth * .08);
    catcherImage.resize(w, 0);
    smooth();
    x = width/2;
    y = displayY - catcherImage.height;
    speedX = 0;
  }

  void display() {
    stroke(0);
    image(catcherImage, x, y); 
//     shape(catcherImage, x, y, w, w);
  }

  void move () { 
    // Display the catcher
    if (keyPressed) {
      //      catcher.move();
      if (keyCode == LEFT) {
        x -= 4f;
        if (x <= 0) {
          x =0;
        }
      }
      if (keyCode == RIGHT) {
        x += 4f;
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
  boolean isCollidingCircle(Drop d) {
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
  boolean isCollidingBox(Box b) {
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
  color c;
  float r;     

  // New variable to keep track of whether drop is caught
  boolean caught = false;

  Drop() {
    r = 30;               
    x = random(width);    
    y = -r*4;              // Start a little above the window
    speed = random(3, 6);   // Pick a random speed
    drop = loadImage ("coin.png");
  }

  // Move the drop down
  void move() {
    y += speed;
  }

  // Check if it hits the bottom
  boolean reachedBottom() {
    if (y > height + r*4) { 
      return true;
    } else {
      return false;
    }
  }

  // Display the drop
  void display() {
    noStroke();
    for (int i = 2; i < r; i++ ) {
        image(drop, x, y, r, r);
    }
  }

  // If the drop is caught
  void caught() {
    speed =0; //stop drop from moving and set location far off screen
    y = -1000;
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

  void setTime(int t) {
    totalTime = t;
  }

  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 1000ms pass
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}

