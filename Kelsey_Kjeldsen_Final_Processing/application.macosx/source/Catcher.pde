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
  }

  void move () { 
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

