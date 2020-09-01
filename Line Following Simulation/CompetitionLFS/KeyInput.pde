// processing calls this method when a key is pressed  
// commands here to allow manual drive of robot and turning drive controller on/off
//
// Note:  Remember to click on the run window to give focus before pressing keys 

//String keySummary = "SPACE=Controller on/off <- -> turn  up/dn ar. vel, S)top R)eset";
String keySummary = "SPACE=Controller on/off,   Up/Down arrows change speed,   R resets robot";
                    // keypress command summary displayed in draw()
                    
// global variables    --- dep 8-27-20 ---
float oldSpd = 0;
float oldTurnRate = 0;
int stopWatchFlg = 0;
                    

void keyPressed()  // handle keypress events for manual driving of robot.
{
  
   if ((key>='a')&&(key<='z')) key -=32; // shift to uppercase  
  
   if (key == 'R') robotControllerResetCommand();
   
   if (keyReMap) {
     keyReMapper();
   }
   else { 
     if (key ==  'S' )    { oldSpd = robot.speed; oldTurnRate = robot.turnRate; robot.speed = 0; enableController = false; robot.turnRate = 0.0; }
     if (key == 'C' ) { enableController = true; robot.turnRate = oldTurnRate; robot.speed = oldSpd; }
     if (keyCode ==  UP)  robot.speed += upButtonIncSpeed;
     if (keyCode == DOWN) robot.speed -= downButtonDecSpeed; 
     if (keyCode == LEFT)  robot.heading -= leftButtonDecHeading; 
     if (keyCode == RIGHT) robot.heading += rightButtonIncHeading; 
   }

   if (key == ' ') enableController = !enableController;           // toggle allowing controller to update
                                                                   //   position and heading of robot
   if (key == 'P') panelDisplayMode = (panelDisplayMode + 1) % 3;  // cycle display status command panel opacity
   //println(panelDisplayMode);
   if (keyCode == TAB) courseViewMode = !courseViewMode;           // toggle course view  vs robot overhead view
   
   // single step F = forward, B = backwards 
   if (key == 'F') singleStepFwd();
   if (key == 'B') singleStepBkwd();   // note: this is not a retrace of previous move, so has limited value (left undocumented)
   if (key == 'T') competitionTimer();
   
}

void singleStepFwd() 
{
  enableController = true;
  if (overRideDefaultDriveUpdate) {
    robot.wheelVelocity = jogSpeed; 
  }
  else {
    robot.speed = jogSpeed;
  }
  singleStepLoopCntr = 2;
  println("forward");
}

void singleStepBkwd()     // note: doesn't retrace previous move, only moves backwards one step, might not be useful
{
  enableController = true;
  if (overRideDefaultDriveUpdate) {
    robot.wheelVelocity = -jogSpeed; 
  }
  else {
    robot.speed = -jogSpeed;
  }
  singleStepLoopCntr = 2;
  println("backwards");
}

void robotControllerResetCommand()  // called if "R" pressed   -- moved from UserControllerDiffDrive to here --- dep 8-27-20 ---
{
  robot.reset();             // reset position and heading & set velocity and turnRate to zero
  enableController = false;  // turn off controller SPACE BAR turns back on
}

void competitionTimer()
{
  stopWatchFlg++;
  
  if (stopWatchFlg % 2 == 1) {
    if (enableController) {
      sw.start();
    }
    else {
      enableController = true;
      sw.start();
      if (overRideDefaultDriveUpdate) {
         robot.wheelVelocity = competitionSpeed;
      }
      else {
         robot.speed = competitionSpeed;
      }
    }
  }
  if (stopWatchFlg % 2 == 0) {
    enableController = false;
    sw.stop();
    if (overRideDefaultDriveUpdate) {
       robot.wheelVelocity = 0.0;
       robot.steerAngleR = 0.0;
    }
    else {
       robot.speed = 0.0;
       robot.turnRate = 0.0;
    }

  }
}
  
 
  
  
