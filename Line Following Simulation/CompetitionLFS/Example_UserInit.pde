/*
  userInit() method expects 
  
  1. set global variables and switches
  2. declare sensors
  3. load robot and course 
  4. initialize sensors
  5. write approppate switch funcs. if your robot need them
  
  Note: Line sensors and spot sensors should not overlap. If they do the line sensors will have incorrect values.
 
*/
 

// switches used for robot configurations that use steering other than from the origin
boolean keyReMap = false;
boolean overRideDefaultDriveUpdate = false;
boolean drawRobotCoordAxes = true;               // show robot coordinate axes
boolean hasLineSensor = false;    // if sensors include a lineSensor make true (line sensor must be named "lineSensor1")

int numOfLineSensors = 0;        // Display of sensor readings of line sensor at bottom of simulation window will only show first 4 line sensors 

int courseDPI = 64;              // Course image DPI (64 is suggested value)
float wheelBaseVal = -3;         // value for robot.wheelBase, unless used do not change (or remove)

// global variables for keyboard settings  (Inc = increment, Dec = decrement)   
// note: if keyReMap is true, these are bypassed

float upButtonIncSpeed = 0.5;           // units inches/sec        
float downButtonDecSpeed = 0.5;         // units inches/sec   
float leftButtonDecHeading = 5.0;       // units degrees
float rightButtonIncHeading = 5.0;      // units degrees

float competitionSpeed = 2.0;           // speed that you want robot to run the competition at
float jogSpeed = 0.5;                   // used with single step, it is the speed that the single step is made

// Initial setting of the instruction / data panel displayed in the simulation window (controlled by "P")   
// note: After user is familar with the interface of the simulator they may want to set panelDisplayMode default to 1 or 0.
int panelDisplayMode = 2;  // 0 = panel off, 1 = robot data only (semi-transparent), 2 = full display w/ instr 



// ----------------------------------------------------

// --- primary line of spot sensors for this robot  ---
SpotSensor[] spotP = new SpotSensor[21];

// --- lne sensors ---
LineSensor[] lineSensorArray = new LineSensor[numOfLineSensors];  // do not remove, change, or comment out  


void userInit()  // called from setup() 
{
  // note: A course and robot should be uncommented for each of the different modes. 
  //       This allows for a default course and robot for each mode.
  

    // --- Challenge-2011 course ---
    //course = loadImage("carfLF_64DPI.jpg");      // load Challenge LF course bitmap
    //robot = new Robot (47.5, 12.0, 0, 0);         // define robot initial x,y,heading 
    
    // --- challenge test course 0 ---
    // Simple Black on White and White on Black Tiles
    //course = loadImage("test_course_0-dp_64dpi.jpg");
    //robot = new Robot (17.5, 6.0, 0, 0);         // define robot initial x,y,heading
    
    // --- challenge test course 1 ---
    // Black on White and White on Black Tiles, gap, 90 deg turn, line width
    //course = loadImage("test_course_1-dp_64dpi.jpg");
    //robot = new Robot (25.0, 8.0, 0, 0);         // define robot initial x,y,heading
    
    // --- challenge test course 2 ---
    // Stains
    //course = loadImage("test_course_2-dp_64dpi.jpg");
    //robot = new Robot (15.5, 42.0, 0, 0);         // define robot initial x,y,heading
    
    // --- challenge test course 3 ---
    // Acute angle turn, Notches, Gate
    //course = loadImage("test_course_3-dp_64dpi.jpg");
    //robot = new Robot (19.0, 4.5, 0, 0);         // define robot initial x,y,heading
    
    // --- Ron's advanced LF ---
    //course = loadImage("RG_5x7_Advanced_64DPI_R1.png");
    //robot = new Robot (40,6,0,0);
    
    // ---  Novice LF Fall 2018 ---
    //course = loadImage("Novice_LF_course-Fall_2018_64DPI.jpg");
    //robot = new Robot (30.0,12.0,0,0);
    
    // --- Advanced LF Fall 2018 ---
    course = loadImage("Advanced_LF_course_Fall-2018_64DPI.jpg");
    robot = new Robot (37.0,84.0,0,0);
    
  
  //

  //--------------------------------- 
  // Set up spot sensors, which are updated every draw() and can be read with read() method call.
  // Use care to insure sensors do not overlap since screen locations are read distructively (coloring green)
  
  
    //  --- spotP sensors ---
    int spotSize = 5;     // 5 means 5x5 pixels or 25 pixels, 15 means 15x15 pixels or 225 pixels
    float spotP_X = 1.0;            //2.725;
    float[] spotP_Y = new float[21];  
    
    for (int j = 0; j < 21; j++) {
      spotP_Y[j] = 2.60 - j * .26;       // sensor centered on robot
    }
       
    for (int j = 0; j < spotP_Y.length; j++) {
      spotP[j] = new SpotSensor(spotP_X, spotP_Y[j], spotSize, spotSize);
    }
    
    //  --- line sensors ---
    //lineSensorArray[0] = new LineSensor(1.25, 0, 5, 5, 64); // x,y offset from robot center, spot size (5,5) , number of samples
    //lineSensorArray[1] = new LineSensor(1.5, 0, 5, 5, 64); // x,y offset from robot center, spot size (5,5) , number of samples
    //lineSensorArray[2] = new LineSensor(1.75, 0, 5, 5, 64); // x,y offset from robot center, spot size (5,5) , number of samples
    //lineSensorArray[3] = new LineSensor(2.0, 0, 5, 5, 64); // x,y offset from robot center, spot size (5,5) , number of samples
  
}  

// ---------- stub functions (do not remove) ------------

void keyReMapper ()
{
     // below is an example - if keyReMap = false, comment out between the lines
     // elsewise tailor to your needs
     //------------------------------
     /*
     if (keyCode ==  UP)  robot.wheelVelocity += 0.30;  //1.0
     if (key ==  'S' )     robot.wheelVelocity = 0;
     if (keyCode == DOWN) robot.wheelVelocity -= 0.30;
     if (keyCode == LEFT)  robot.steerAngleR += 0.05;  // steer wheel aft so + steer --> LEFT turn 
     if (keyCode == RIGHT) robot.steerAngleR -= 0.05;  // think of wheel as rudder  wjk 6-21-20
     if (robot.steerAngleR > 1.0 ) robot.steerAngleR = 1.0;
     if (robot.steerAngleR < -1.0 ) robot.steerAngleR = -1.0;
     */
     //------------------------------
}

void alterateDriveUpdate (float dt)
{
  // below is an example - if overRideDefaultDriveUpdate = false, comment out between the lines
  // elsewise tailor to your needs
  //------------------------------
  /*
  robot.speed = robot.wheelVelocity * cos( robot.steerAngleR );
  robot.turnRate = degrees( robot.wheelVelocity * sin( robot.steerAngleR ) / robot.wheelBase ); // CW steer --> CCW turn
  */
  //------------------------------
}
