/*  Will's Trike Robot Controller (as of Aug 11, 2020)

    Given current sensor data, modify robot heading and velocity as you choose.

    Setting velocity and turnRate  to zero, would allow setting x,y,heading as you please 
*/
/******************
to read spot sensors use read() method returns 0.0 to 1.0
 float v =  spotL.read();
to read line sensor
float[] s = lineSensor1.read();  // returns reference to sensor array of floats    which you can do something like
sensorRunDetector(s);
with few changes to your method now (float[] sensor )
*****************/

  
void userDraw() // called from DrawWorld, if trikeMode
{
    // draw trike steer wheel, total sum of u's   wjk 6- -2020
    stroke(250,0,0);
    strokeWeight(5.0);
    line( width/2, height/2, width/2, 192+height/2);
    strokeWeight(10.0);
    line( width/2, 192 + height/2,
          width/2+64*sin(-robot.steerAngleR), 192+height/2+64*cos(robot.steerAngleR));
    // show steerAngle due ONly to error, no errorRate  wjk 6-25-2020    
    stroke(0, 0,250);                
    strokeWeight(5.0);
    line( width/2, 192 + height/2,
          width/2+64*sin(-uError), 192+height/2+64*cos(uError));        
}   
  
  
  
//---------------
// add 3rd colum to sensorRun, removed color [][0] to [][2] white is now 1 not +
int[][] sensorRun = new int[8][3]; // [][0] is run length, [][1] centroid, [][2] is color (0 or 1)
void sensorRunDetector(float[] sensor)
{
  int n = sensor.length; // total number of sensor samples
  int whtN ;   // New cell is white = 1, black = 0
  int whtO;   // Previous cell
  
  // clear out previous data from sensorRun array
  for(int i=0; i<8; i++) {sensorRun[i][0]=0; sensorRun[i][1]=0; sensorRun[i][2]=0;}
  
  // process sensor[0] first cell of sensor, first cell of first run
  int runIndex = 1;      // for first sensorRun it is 1, runCount is in 0
  int sum = 1;           // moment of sensor[i] = i+1; for sensor[0] it is 1
  int count = 1;         // number of cells in run; for first cell, sensor[0] it is 1
  
  //process remainder of sensor cells
  for (int i=1; i<n; i++)
  {
      if (sensor[i-1]>0.5) whtO = 1; else whtO = 0; // color of previous cell
      if (sensor[i]>0.5) whtN = 1; else whtN = 0;   // color of this curren cell
      if (whtN == whtO)                             // if cell color has not changed, continue run 
        {sum += i+1; count++;}                 // add moment and count of this cell to current run
      else                                     // this cell is first of new run
      {                                        // save run data and start new run 
        sensorRun[runIndex][1] = (n/2)-(sum/count); // save centroid of run      
        sensorRun[runIndex][0] = count;             // save length of run
        sensorRun[runIndex][2] = whtO;              // save color of run
        sum = i+1; count = 1; runIndex++;           // starting moment and count is that of this cell
      }
  } // end for i
  // need to save data for last run
  sensorRun[runIndex][1] = (n/2)-(sum/count); // save centroid of last run      
  sensorRun[runIndex][0] = count;             // save length 
  sensorRun[runIndex][2] = (sensor[n-1]>0.5)? 1 : 0; whtO = -count; // color is that of last cell
  sensorRun[0][0] = runIndex;                 // save number of runs
} // end sensorRunDetector()

//------------------------------------
int[] pathWidthRun = new int[8];  // [0] is number of path width runs, [1] is run index of first path width run
 void pathWidthRuns(int[][] sensorRun)
 {
   int j = 0; 
   for (int i =1; i < sensorRun[0][0] ; i++ )
   {
     if( ( (sensorRun[i][0]>8)  && (sensorRun[i][0]<12) ) // 3/4" path is 9.6 cells wide
       ||( (sensorRun[i][0]>3)  && (sensorRun[i][0]<7 ) ) // 3/8" path is 4.8 cells wide
       ||( (sensorRun[i][0]>17) && (sensorRun[i][0]<25) ) ) //  1 1/5" path is 19.2 cells wide  
     { j++; pathWidthRun[j] = i; }
     pathWidthRun[0] = j;
   }
 }
 
//---------------------------

void controllerUserRobot(Robot robot, float dt)
{
  int y = 0;   // output of linear sensor array  
  int c = 0;   // tracking error
 
  float[] lsa = lineSensorArray[0].read();  // returns reference to sensor array of floats 
                                   // which you can do something like:
                                   // sensorRunDetector(lsa);

  sensorRunDetector(lsa);   // sensorRun[][1]
  
  // which runs are a path width long?
  pathWidthRuns(sensorRun);  // the index of path width long runs are returned in pathWidthRun[]
                             // pathWidthRun[0] is number of runs found
  
  // which run is the path? this is just first effort

  switch ( sensorState )
  {
    case 0:{ // 3 runs,
      if((spotFL2.read()>0.5)&&(spotR2.read()< 0.5) && (spotC.read()>= 0.5)
        && (spotFL.read()>0.5)&&(spotFR.read()>0.5) )
      {
        robot.steerAngleR = - 0.7854; println(" offset to right"); // 3" radius  turn
        toGo = 2.902;   // 39.19 deg turn
        sensorState = 3; // goto offset move, step 1
        break;
      }
      if((spotFL2.read()>0.5)&&(spotL2.read()< 0.5) && (spotC.read()>= 0.5)
        && (spotFL.read()>0.5)&&(spotFR.read()>0.5) )
      {
        robot.steerAngleR =  0.7854; println(" offset to left"); // 3" radius turn   
        toGo = 2.902;   // 39.19 deg turn
        sensorState = 3; // goto offset move, step 1
        break;
      }
      if((spotFR1.read()< 0.5) && (spotC.read()< 0.5) && (spotC2.read()<0.5)
         &&(spotFL.read()>=0.5) && (spotFL2.read()>= 0.5)
         &&(spotL.read()>0.5) && (spotL2.read()>0.5)&&(spotFL2515.read()>0.5)) // acute angle
      {
        toGo = (spotFR17.read()<0.5) ? 5.9 : 7.9; // 90deg turn
        robot.steerAngleR = - 1.05; println(" acute to right"); // 3" radius turn   
        //toGo = 7.9;   // approx. 120deg turn
        sensorState = 4; // goto acute move,
        break;
      }
      if((spotFL17.read()> 0.5) && (spotC.read()> 0.5) && (spotC2.read()>0.5)
         &&(spotFR.read()<=0.5) && (spotFR17.read()<= 0.5)
         &&(spotR.read()<0.5) && (spotR2.read()<0.5) && (spotFR17.read()<0.5)) // left 90 wht
      {
        robot.steerAngleR = + 1.05; println(" 90 to left"); // 3" radius turn   
        toGo = 5.9;   // approx. 90deg turn
        sensorState = 4; // goto acute move,
        break;
      }

             switch (sensorRun[0][0]) // number of runs in lsa
             {
               case 1:{
                 if(sensorRun[0][0] >= 3){trackingUpdate( cOld, dt); break;} // just keep going
                 break;
               }
               case 2:{
                /* if( (abs(sensorRun[1][0])+ abs(sensorRun[2][0])) > 0) 
                    {robot.steerAngleR = HALF_PI ; println(" wide + run");} // left turn
                 else {robot.steerAngleR = - HALF_PI; println(" wide - run");} // right turn
                 toGo = 4.712;   // 90deg turn
                 sensorState = 1; // 90deg turn, step 1
                */
                 break;
               }
               case 3:{  // 3 runs,  run 2 is path -> normal tracking
                 if ( //( abs((sensorRun[2][1]) - cOld) < 3 ) &&    // center run near previous run
                      ( abs(sensorRun[2][0]) < abs(12) ) )        // and not too wide
                 {
                   trackingUpdate( sensorRun[2][1], dt);
                   sensorState = 0;  //  use to track line
                 }
                 break;
               }
               case 4:{
                 break;
               }
               default:{ println( " sensorState 0 default ");}
             } // end of runs switch
             break; // out of outer switch case 0 
    } 
    case 1: { // robot is turning open loop
              toGo -= robot.wheelVelocity * dt;
              sensorState = 1; 
              if( toGo < 0.0)                  // turned enough
              {
                robot.steerAngleR = 0.0; toGo = 1.0; // request 
                sensorState = 2; // goto robot is moving straight forward
              }
              break;
    }
    case 2: { //robot is moving straight forward
             sensorState = 2;
             toGo -= robot.wheelVelocity * dt;
             if( toGo < 0.0)                  // far enough
             { sensorState = 0; } // manuver complete, return to tracking
             break;
    }   
    case 3: { // robot offset move, step 1 open loop
              toGo -= robot.wheelVelocity * dt;
              sensorState = 3; 
              if( toGo < 0.0)                  // turned enough
              {
                if(robot.steerAngleR > 0 )
                { robot.steerAngleR = 0; toGo = 1.0;}
                else
                {robot.steerAngleR = - robot.steerAngleR;// reverse turn direction
                println(" offset to right, step 2"); // 3" radius left turn
                toGo = 2.902;} // request 
                sensorState = 4; // goto offset move, step 2
              }
              break;
    }
    case 4: { //robot offset move, step 2 and acute move
             toGo -= robot.wheelVelocity * dt;
             sensorState = 4;
             if( toGo < 0.0)                  // far enough
             { robot.steerAngleR = 0.0; sensorState = 0; } // manuver complete, return to tracking
             break;
    }   

  default:{ println(" default "); }
  } // switch

  // println (" steer2 ", robot.steerAngleR);
  //println(" runs ", sensorRun[0][0], sensorRun[1][0],sensorRun[2][0], sensorRun[3][0]);
} // Trike controller()

//----------------------------------
  int cOld =0, yOld;
  float error = 0;
  float theta_pR;   // angle from path tangent to robot heading, radian
  float errorRate = 0;
  float delT = 0, delSr = 0;
  float uError;      // components of plant input, robot.steerAngleR
  float uErrorRate;
  float uCurvature;
  int sensorState;
  float toGo = 0.0;  //  = turn angle / robot.wheelBase  wjk 6-27- 2020

void trackingUpdate( int c, float dt)
{
  float dSw = robot.wheelVelocity * dt;
  float dTheta_p = dSw * sin(robot.steerAngleR) / robot.wheelBase;
  float dSr = dSw * cos(robot.steerAngleR); 
   if ( c - cOld == 0 )
   {
     delT += dt;
     delSr += dSr;
     theta_pR += dTheta_p * 0.8;
     //error += dSr * sin(theta_pR); 
   }
   else
   {     
    if (delSr != 0 ) theta_pR = (c - cOld)*0.0781 / delSr; // inch/inch => radians
     delT = 0.0; delSr=0.0;
     error = c * 0.0781; // trackig error in inches
   }
     uError = error * 1.50;  // 0.5
     uErrorRate = 1.60 * theta_pR; 
  
     robot.steerAngleR = uError + uErrorRate;
     if (robot.steerAngleR > 1.0 ) robot.steerAngleR = 1.0;
     if (robot.steerAngleR < -1.0 ) robot.steerAngleR = -1.0;
   
  
     cOld = c;
     //println (" steer ", robot.steerAngleR);
     //println("*** %4.2 %4.2 %4.2", sensorRun[0][0], sensorRun[1][0], sensorRun[2][0]);
    // println(c, error, errorRate, delT,"***", sensorRun[1][0] );
} // tracking Update()
//-------------------------------
