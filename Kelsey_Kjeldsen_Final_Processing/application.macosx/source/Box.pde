class Box {

  float speedY; //speed down for rect
  float boxWidth;
  float boxHeight;
  float boxX;
  float boxY;

  Box () {
 //   bricks = loadImage("bricks.png");
    boxHeight = random (20, displayHeight*.075);
    boxWidth = random (displayWidth*.10, displayWidth*.20); //40% width max
    boxX= random (0, width -40);
    boxY= random (-100, 0);
    speedY= random(1, 4);
  }

  void display () {
    fill (#00FF39);
    stroke(1);
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
