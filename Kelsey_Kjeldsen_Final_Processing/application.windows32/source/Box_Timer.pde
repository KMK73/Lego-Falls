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
