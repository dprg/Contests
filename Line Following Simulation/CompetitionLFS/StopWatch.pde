//global variables / object//s
StopWatchTimer sw;
/* 
=================================================================
   Stop watch class from 
   https://forum.processing.org/one/topic/timer-in-processing.html

==================================================================
*/

class StopWatchTimer {
  int startTime = 0, stopTime = 0;
  boolean running = false; 
  void start() {
    startTime = millis();
    running = true;
  }
  void stop() {
    stopTime = millis();
    running = false;
  }
  int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime);
    }
    else {
      elapsed = (stopTime - startTime);
    }
    return elapsed;
  }
  int hundredthSecond(){
    return (getElapsedTime() / 10) % 100;
  }
  int second() {
    return (getElapsedTime() / 1000) % 60;
  }
  int minute() {
    return (getElapsedTime() / (1000*60)) % 60;
  }
  //int hour() {
  //  return (getElapsedTime() / (1000*60*60)) % 24;
  //}
}
// ====================================================
