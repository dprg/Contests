
/*
    draw overhead view of robot in from fixed perspective "above" robot
    collect sensor data
    
    then if courseViewMode (Tab key toggles ON/OFF) overdraw above with
    entire course scaled to viewport.
    
    While courseView mode is active, left click mouse updates current and default position of robot.
   
    Ron Grant
    May 17, 2020
    May 22, 2020  - courseViewMode added
    Jun 28, 20202 - updated for addition of Sensor tab methods
                    moved all sensor code to Sensor, updateSensors() called after overhead robot view rendered
                    to screen (where robot center is center of screen and heading toward "top of screen")
 

*/


int  headingChangeX = -999; // used to log mouseX on right mouse press and hold and drag in X to change heading

void drawWorld(final Robot robot)
{
 
   
  // course is 64 DPI   
 
 
  // need to transform course image into robot coordinates
  // where center of viewport is sensor array orgin
  int cx = width/2;   // screen center
  int cy = height/2;
    
  // compose transform matrix applied to course image
  // transformations applied in reverse order
 
  translate (cx,cy);                     // 5 translate to viewport center  
  scale (courseDPI);                     // scale to pixel units    // 4 scale to pixel units
 
  rotate (radians(90-robot.heading));     // 3 rotate

  translate (-robot.x,-robot.y);           // 2 translate current robot location in inches  to origin
  scale (1.0/64);                          // 1 scale to inches
    
 
  image (course,0,0);                     // draw image to viewport using current transformation matrix
 
  resetMatrix();  // reset current transformation matrix back to default
                  // screen coordinates origin upper left, viewport size widthxheight
 

  translate (width/2,height/2);
  scale (courseDPI,courseDPI);
  strokeWeight(1.0/courseDPI);
 
  updateSensors();  // process image data visible at the moment, top view of course at current robot location
                    // rotated to current robot orientation
 
  // at this point the sensor data has been sampled 
  // it is safe to draw on screen without confusing sensors
 
  resetMatrix();    // reset transform again to allow drawing text in screen coordinates
  pushStyle();
 
  userDraw();       // draw user's robot
  
  // draw robot coordinate axes 
  if (drawRobotCoordAxes) 
  {
     translate (width/2,height/2);
     strokeWeight(3);
     stroke(0,250,0);
     line (0,0,40,0);
     fill (0,250,0);
     text ("Y",40,4);
     stroke(250,0,0);
     line (0,0,0,-40);
     fill (250,0,0);
     text ("X",-6,-40);
     resetMatrix();
  }
  
  popStyle();
  resetMatrix();
 
  if (mousePressed && (mouseButton == RIGHT))  // right mouse down and move horizontally to change robot heading
  {
     enableController = false;
     crumbList.clear();
     
     if (headingChangeX == -999)  // right press just started, log mouse X location 
      headingChangeX = mouseX;
           
      robot.heading = mouseX-headingChangeX;         
      if (robot.heading > 360) robot.heading -= 360;
      if (robot.heading < 0) robot.heading += 360;
   
      robot.headingi = robot.heading;   // make new heading default heading if R-Restart 
  }
    
  if (!mousePressed)          // when mouse released, reset heading change state
     headingChangeX = -999;
      
 
  // overdraw robot view with course image - if in course view mode
 
  if (courseViewMode)        // toggled with TAB key, overdraw window with course scaled to fit window
  {                          // keeping scaling code simple as possible, not correcting for possible aspect ratio distortion

    int cw = course.width;     // width and height of course image in pixels
    int ch = course.height;
    
    float sx = 1.0*cw/width/courseDPI;
    float sy = 1.0*ch/height/courseDPI;
    
    image (course,0,0,width,height);
    if (mousePressed && (mouseButton == LEFT))  // allow moving around on course
    {                                           // e.g. used to determine location of start then
                                                // hardcoded into robot position
      float newX = mouseX*sx;
      float newY = mouseY*sy;
      
      // update robot location and also default location using mouse click location. For now current heading used
      // as default -- might allow adjusting in future
   
      
      
      robot.setCurrentAndInitialLocationAndHeading(newX,newY,robot.heading);
          
      println (String.format ("Robot New Position (%1.1f,%1.1f)",robot.x,robot.y));
      crumbList.clear();
    }  
    
   
    // draw pointer in robot heading direction
    float x = robot.x / sx;
    float y = robot.y / sy;
    
    float a = radians(robot.heading);
    float r = 60;
    strokeWeight(8);
    stroke (50,50,255);
    translate(x,y);
    float xe = -r*cos(a);
    float ye = -r*sin(a);
    line (0,0,xe,ye);
    ellipseMode (CENTER);
    ellipse (0,0,10,10);
    
    translate (xe,ye);
    
  
      
    resetMatrix();
    
    // draw the cookie crumbs -- R)Reset clears list  
    
    stroke (0,255,0); // crumb color  
    strokeWeight(3.0);
    for (PVector p : crumbList)
    {
     // scale from course coordinates in inches to normalized coordinates,
     // enclosed in () then scale to screen
     point ( (p.x * courseDPI /cw)* width, (p.y * courseDPI / ch) * height);
      
    }
    
    strokeWeight(1.0);
    
  }  
   
}
