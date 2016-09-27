
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
//    for (int i = 2; i < r; i++ ) {
        image(dropImage, x, y, r, r);
//    }
  }
}

