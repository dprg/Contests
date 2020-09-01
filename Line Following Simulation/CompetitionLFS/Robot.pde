/*
    Robot class, handles update of heading and location on map based on 
    turnRate and velocity (or wheel angle and velocity in case of trike (tricycle) mode 

*/

ArrayList <PVector> crumbList = new ArrayList <PVector> ();   // cookie crumb trail visible in course view 


class Robot {
 float x,y;         // robot position on course in inch coordinates
 float heading;     // robot heading, 0 to 360 degrees CW, 0 is world x- 
 float turnRate;    // roobot turn rate CW in degrees/second 
 float speed;       // robot forward speed in inches/second
 
 // steering-drive wheel is behind front two wheels & axle   wjk 6-21-20  
 // trike varibles   wjk 6-14-20
 
 float wheelBase = wheelBaseVal;    // distance main axle to steer pivot in inches
 float steerAngleR;         // steering angle for front wheel -Pi/2 to +Pi/2 radians, CW is +
 float wheelVelocity;       // steering wheel forward velocity in inches/second
 
 
 float xi,yi;     // inital position
 float headingi;  // initial heading
 float speedi;    // initial speed;   
 
 float crumbThresholdDist;
 float curCrumbX;
 float curCrumbY;
 boolean crumbsEnabled;

  
  
  Robot (float x, float y, float heading, float speed)
  {
    this.xi = x;
    this.yi = y;
    this.headingi = heading;
    this.speedi = speed;
    
    crumbThresholdDist = 0.25;   // distance from previous crumb must exceed this value before new crumb is generated
    turnRate = 0.0;
    
    reset();
    
  } 
  
  void setCurrentAndInitialLocationAndHeading(float x, float y,float h)
  // called on mouse click when course view is displayed (Tab toggles on/off)
  {
    xi = x; yi=y; headingi = h;
    this.x = x;
    this.y = y;
    this.heading = h;
  }
  
  void reset() // reset to initial conditions 
  {
    x = xi;
    y= yi;
    heading = headingi;
    
    speed    = 0.0;
    turnRate = 0.0;
    
    steerAngleR = 0.0;
    wheelVelocity = 0.0;
    
    
    crumbList.clear();
  } 
  
    
  void diffDriveUpdate (float dt) // delta time in seconds - called typically 30 to 60 times per second from draw()
                                  // also can be fixed to a value
  {
  
    // robot (click on image) positioning code in  DrawWorld
   
    // move robot in direction of heading
    // default heading 0 moves in -X, turn 90 to right (heading 90) move in Y-
    
    // looking at image of course. World coordinate origin is taken as upper-left of image with 
    // positive X to right and positive Y down
    //
    //      o----->+X axis
    //      |
    //      |  Course Image 
    //      | 
    //     +Y axis
    //
    
   
    
    float dist = speed * dt;                   // total distance traveled in this delta time timestep in inches
                                               // units:   inches = inches/sec * seconds 
                                            
                                               // now resolve into changes in x and y  
                                               // as a function of heading  
    x -= cos(radians(heading)) * dist;         // if unfamiliar math, google "resolving a vector into components"
    y -= sin(radians(heading)) * dist;        
  
    heading += turnRate*dt;                    // update heading based on turnRate
                                               // units:  degrees = degrees +  degrees/sec * degrees 
  
    if (heading>=360.0) heading -= 360;         // keep heading in 0..360 range,  e.g. 362 would become 2
    if (heading<0.0) heading += 360;           // -5 would become 355
   
   
    // add cookie crumb if robot has moved more than crumbThresholdDist from previous crumb
    if (dist(x,y,curCrumbX,curCrumbY) > crumbThresholdDist)
    {
       crumbList.add(new PVector(x,y));
       curCrumbX = x;
       curCrumbY = y;
    }
  }
  

  
} // end robot class 
