   // Simple Example Controller using centroid of single dark span
   // just for fun added velocity control -- needs refinement
   
// this simple controller solves RG_5x7_Advanced_64DPI_R1.png
// only problem is notch was near edge, had to make "floor" beyond course light to avoid foiling robot.

// global variables
int cOld =0;


void userDraw() {  }  // do nothing, code can be added here. Trike controller draws wheel features helpful to see wheel turn angle.


void controllerUserRobot(Robot robot, float dt) 
{
   // dt not used here 
   // crude attempt to control velocity as function of current centroid error - not well researched 
  
   float[] sensor =  lineSensorArray[0].read();  // returns reference to sensor array of floats  wjk 7-6-20 
   int c = calcSignedCentroidSingleDarkSpan(sensor) ; 
   println(c);
   robot.turnRate = -c * 25.0 + (c - cOld) * 0.80;  // turn rate in degrees per second was 3.0 
   //up/robot.speed    = 1.0 + abs(8.0/(abs(c/2)+1));    // comment out for manual velocity control using + - keyboard
   
   cOld = c;  
}

//-------------------------------
int calcSignedCentroidSingleDarkSpan(float[] sensor)  // 0=line centered under sensor array  + to right , - to left
                                                      // float[] was int[]     wjk 7-6-20
{
  int n = sensor.length; // total number of sensor samples
  // calculate centroid of single black line 
  
  int sum = 0;
  int count = 0;
  int centroid = 0;
  for (int i=0; i<n; i++)
     if (sensor[i]<0.5) { sum+= i;  count++; }
  if (count>0)
      centroid = (n/2)-(sum/count);  // make centroid signed value  0 at center
      
  /* comments and suggestd changes  by wjk
  
  // sensor resolution is 1/2 sensor cell width      wjk 6-19-20
  // so let units of moment_arm and centroid be 1/2 sensor cell width
  // then moment arm of cell 0 is 1 unit [not zero] ie 1/2 width of cell 0
  // and moment arm of cell 1 is 3 units, cell 2 is 5 units, cell i is (2*i)+1
  // centroid unit = .5 cell/unit * 5 pixel/cell * inch/64 pixel = 0.0391 inch/unit

  for (int i = 0; i<n; i++)     // i=0 is first cell to righr of center
      if (sensor[i]<0.5) { sum += 2*i+1;  count++; }
  if (count > 0 ) centroid = n - sum /count;    // units of 1/2 cell width !!!!
  */
  
  return centroid; 
}

//-------------------------------
