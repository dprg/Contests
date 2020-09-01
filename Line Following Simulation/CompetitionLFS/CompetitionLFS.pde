/*
  Line Following Robot Simulation (LFS)
  Low Level Support - Ron Grant May 17,2020
 
  See: KeyInput for description of keyboard commands
 
  Robot Heading 0   world X-
  Heading 90  world Y-
 
 
 Load course bitmap then display in viewport using drawWorld() method to render robot's look down view
 at X,Y location within bitmap (scaled to inch units) and heading 0..360
 
 Robot initial position of (48,12) places robot near start/finish line. Heading 0 looking along initial line
 to follow. At this point heading of 90 would drive off the course from above (right turn)
 
 
 Rev2 includes new features   May 22
 
 Tab - toggle overhead view with left mouse click select new location
 R- reset to last position and heading clicked in overhead view
 P- Panel opacity cycle  OFF,50% transparent, 100% opaque
 S- Stop Robot
 
 Display shows velocity and controller ON/OFF status
 
 turnRate (previously headingRate) now managed by diffDriveUpdate()
 
 made off course lighter because robot was seeing "line" off edge of course where in one sample
 course I placed a notch
 
 Ron's sample controller runs RG_5x7_Advanced_64DPI_R1.png without problem.
 Now for the more tricky stuff!
 
 June 27, 2020 - RG Added new Sensor Tab including SpotSensor and LineSensor Class
 Also updateSensors() called from drawWorld() method.
 Also, some code to display line sensor updated in this file
 
 Aug 7, 2020  -  Added detection of window focus, indicating need to click for key commands to be received by window.
 Aug 10,2020  -  Added ability to set heading in Course View using right mouse button hold and drag horizontally
                 
                 Also, you can hold left mouse down and drag (pointer drawn with circle at robot position and ray indicating 
                 heading. 
                 
                 Robot heading can be changed in robot view using right mouse button, turns off controller.
                 You might want to S-Stop robot first 
                 
                 Created UserInit tab and moved user init code there include load course, init robot, define sensors
                 Global trikeMode and drawRobotCoordAxes also in this tab.
                 
                 UserControllerDiffDrive has Ron's simple differential drive controller code
                 UserControllerTrike has Will's trike controller -- work in progress, solves about 1/2 of Challenge as of Aug 8
                 
                 Stop (DiffDrive Mode) stops robot and turns off controller
             
  Aug 11,2020    Set size back to 800x600  higher resolutions can bog down.
                 Lower resolutions like 640x480 may work better on slower machines.
                 Might want to consider scale 
                 
  Sep 01,2020    Created competition version of LFS. Modifies LFS so that a competitor only has to provide a UserController and 
                 UserInit file to run simulator. Added these features:
                 1) Added stop watch feature.
                 2) Added single click competition start / stop functionality.
                 3) Created "Pit_Area" directory to store competitor robots waiting to run.
                 4) Added single-step jog feature.
                 5) Expanded line sensor display up to 4 line sensors.
                 6) Divided information panel into simulator status and interface panels, allowing a view that only shows status
                    and hides the interface instuctions.
                 7) Added function switch or stubs for alternate key remapping and drive update. This allows the separation of
                    unusal robot configurations from the main simimulator files (for example: Will's trike).
                    
                 Future wish list:
                 1) Log sensor data and robot positional data to file.
                 2) Visual indication of spot sensor status on simulator window.
                 
                 --- dep ---
                 
                 
   Author: Ron Grant              
   Modifiers: Will Kuhnle   --- wjk ---
              Doug Paradis  --- dep ---
 
 Note: If you are interested in making simulation deterministic, delta time timestep could be fixed to a value
 and you would need to consider giving robot some pre-set velocity rather than accepting arrow key presses to accelerate
 the robot.
 
 
 
*/

PImage course;   // courseImage 64 DPI rendition of course 6x12 tiles + 1/2 tile borders for total 7x13 foot course area  
// tiles are 12x12 inches (12x64 x 12x64 pixels = 768x768 pixels)
// total image size of 7x13 foot area is (5376 x 9984 pixels)
// loaded in setup()

//int courseDPI = 64; // default userInit() can override 

Robot robot;   // robot initialized below in setup()   - see Robot tab for class definition  

boolean enableController = false;  // off by default, SPACE to toggle on/off 
boolean courseViewMode;            // off by default, TAB to toggle on/off
//int panelDisplayMode = defaultDisplayMode;    // moved to UserInit by --- dep 8/29/20 ---
PShape rectInstructions;  // The PShape object for rectangle with command instructions --- dep 8/28/20 ---
int singleStepLoopCntr = 0;   // used with single step functions --- dep 8/29/20 ---

        

//*********************************               

void setup() // processing calls this method first, then starts calling draw() at 30 to 60 times per second
{
 rectInstructions = createShape(RECT, 20, 40, 699, 130);  // The PShape object for rectangle with command instructions
 size (800,600);   // define viewport size and optionally  renderer
 userInit();
 
 // stop watch
  sw = new StopWatchTimer();
  //sw.start();
}

//******************************
int lastDrawTime = 0;

void draw ()  // method called by Processing at 30 to 60 times per second (1 frame time)
{
  background (150);  // fill screen greay , only visible if we drive off of image

  // calculate elapsed time since last frame in seconds
  float dt = (millis()- lastDrawTime) * 0.001;   
  lastDrawTime = millis();
  if (dt>0.5) return;                  // skip draw if excessive dt

  // dt = 0.02;  // optionally force a given delta time for this frame

  // switch to allow override of the default drive update
  if (overRideDefaultDriveUpdate) {
    alterateDriveUpdate (dt);
    robot.diffDriveUpdate(dt);
  }
  else {
    robot.diffDriveUpdate(dt);         // update robot position and heading based on velocity and turnRate
  }
  
  

  // draw robot's look-down view of the course based on current location
  // and heading, updating sensor array
  
  
  // single-step routine to allow robot to move one step per button push (button is F)
  if (singleStepLoopCntr > 1) {
    singleStepLoopCntr = 2;           // to prevent keyboard queue windup 
    singleStepLoopCntr--;
  }
  else if (singleStepLoopCntr == 1) { 
    enableController = false;
    robot.wheelVelocity = 0.0;
    robot.speed = 0.0;
    robot.turnRate = 0.0;
  }
      

  
  drawWorld(robot);                // draw robot's look-down view of the course based on current location 
                                   // and heading, updating sensor array  

  //----------------------                                                 
  // process sensor data, alter robot velocity,heading and/or x,y location

  if (enableController)   // if turned off, no update.
  {
    controllerUserRobot(robot, dt);
  }


  //------------------------
  // display status info at top of screen

  int alpha = panelDisplayMode*127;  // display panel opacity 0% 50% 100%  controlled by pressing P
  stroke (240);
  fill (0, 0, 50, alpha);   // dark gray, alpha transparency  
  rectMode (CORNER);
  // rect(20, 20, 700, 130);   //700, 110);   // --- dep 8-27-20 ---
  rect(20, 20, 700, 40);   // --- dep 8-27-20 ---
  rectInstructions.setFill(color(5));
  shape(rectInstructions, 0, 0);
  if (panelDisplayMode <= 1) {
     rectInstructions.setVisible(false);
  }
  else {
     rectInstructions.setVisible(true);
  }
  //rect(20,40, 700,130);    // --- dep 8-27-20 ---
  fill (240, alpha);      // color,alpha transparency 50%
  textSize (15);     // 20);
  String cs = enableController ? "ON" : "off";
  if (keyReMap) {
    text (String.format ("Robot Pos: (%3.1f %3.1f)  Steering %3.3f   Heading: %03.0f deg    Vel %1.1f ips", //wjk 7-1 20 <-----------------------------------------<<<<
      robot.x, robot.y, robot.steerAngleR, robot.heading, robot.wheelVelocity), 30, 40);
  }
  else {
    text (String.format ("Robot Pos: (%3.1f %3.1f)    Heading: %03.0f deg   Speed: %1.1f ips    Controller: %s", 
      robot.x, robot.y, robot.heading, robot.speed, cs), 30, 40);
  }
  
  if (courseViewMode)  
  {
    // text ("move to new location, left click mouse on new position", 30, 80); // was 30,90
    text ("Click left mouse button to move to new position", 30, 80); // was 30,90
 
  }
  if (rectInstructions.isVisible()) {
    text (keySummary, 30, 80); //  was 30,60  keySummary defined in KeyInput tab

    text ("Hold right mouse button down and drag horz. to change heading, click to set heading to 0",30,100);
    text ("S stops robot in place, C resumes robot, F single-step forward, T to stop timer and retain time",30,120);  // B is also mapped to single-step backwards, but it isn't a retrace ---dep 8-27-20 ---

    if (!focused)  // if window does not have focus, indicate that fact to user
    {
      pushStyle();
      fill (255, 70, 70);   // pale red
      text ("Click in application window to give focus for key command response", 20, 140);    //120);
      popStyle();
    } else text ("Tab - toggle couse/robot view    P - Panel visibility (off, transparent, opaque)", 30, 140);    //120);
  }
 
  // draw sensor data at bottom of screen
  // visual confirmation of screen being sampled correctly.
  // Also, note that screen pixels are colored green as they are
  // sampled for confirmation of region being sampled

  if (hasLineSensor) {
    fill (0, 0, 20);
    rect (0, height-((numOfLineSensors) * 32), width, numOfLineSensors * 32 );
  
    for(int j = 0; j < numOfLineSensors; j++) {
      float[] sensor = lineSensorArray[j].read();   // added June 20  - get new line sensor data array (modified 8/31/20 dep)

  
      for (int i=0; i<sensor.length; i++)
      {
        stroke (240); // light gray border
        if (sensor[i] > 0.5) fill (240);
        else fill (0);
        
        if (j == 0){
          rect (120+i*8 + 20, height - 20, 6, 6);
          text ("lineSensor["+ j + "]", 15, height - 15);     //height - ( j*15) - 15);
        }
        if (j == 1){
          rect (120+i*8 + 20, height - 40, 6, 6);
          text ("lineSensor["+ j + "]", 15, height - 32);     //height - ( j*15) - 15);
        }
        if (j == 2){
          rect (120+i*8 + 20, height - 60, 6, 6);
          text ("lineSensor["+ j + "]", 15, height - 52);     //height - ( j*15) - 15);
        }
        if (j == 3){
          rect (120+i*8 + 20, height - 80, 6, 6);
          text ("lineSensor["+ j + "]", 15, height - 70);     //height - ( j*15) - 15);
        }

        fill (240);

      }
   }
 }

 // --- timer block in window ---
   stroke (240);
   fill (255, 70, 70);   // pale red
   rect(680, 420, 80, 40); 
   fill (0,0,255);
   text(nf(sw.minute(), 2)+":"+nf(sw.second(), 2)+":"+nf(sw.hundredthSecond(), 2), 688, 445);

   

} // end of draw()
