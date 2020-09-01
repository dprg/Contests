/*
  Example Controller similar to Ron Grant's (shows how to use userDraw() and how to make an array of spot sensors)

  Steps for use:
     1. Define the visual representation of your robot in userDrawRobot().
     2. Define sensor reads and sensor results interpretation in controllerUserRobot().
     3. Add any necessary functions for algorithms used.
     4. Make sure that UserInit (see UserInit tab) is properly configured.
*/

// Global Variables
int cOld = 0;

void userDraw() 
{ 
    stroke(250,0,0);
    strokeWeight(10.0);     
        
    // representation of two wheels 3" from centerline
    // --- left wheel --- 
    line( width/2 - courseDPI * 3, height/2 - courseDPI * 0.5,
          width/2 - courseDPI * 3,height/2 + courseDPI * 0.5);    
          
    // --- right wheel ---
    line( width/2 + courseDPI * 3, height/2 - courseDPI * 0.5,
          width/2 + courseDPI * 3,height/2 + courseDPI * 0.5);          
    
       
    // --- ctr marker --- 
    stroke(0, 250,0);
    strokeWeight(2.0);     
  
    line( width/2, height/2  - courseDPI * ( 2.725 + .25) ,
          width/2, height/2 + courseDPI * -(2.725 - .25));      
        
}  


void controllerUserRobot(Robot robot, float dt) 
{
  
   // --- primary sensor array of spot sensors --- 
   float[] spotPintensities = new float[spotP.length];        
   for(int j = 0; j < spotP.length; j++) {                // get intensity values of primary sensor array
     spotPintensities[j]  =  spotP[j].read();
   }
   
     
   int c = calcSignedCentroidSingleDarkSpan_rg(spotPintensities) ;   
   
   
   
   // PD controller
   //robot.turnRate = -c * 25.0 + (c - cOld) * 0.80;  // turn rate in degrees per second was 3.0 -- Ron's original
   robot.turnRate = c * 10.0 + (c - cOld) * 0.80;  // used on dp robot


   cOld = c;  
}

//-------------------------------
// Ron Grant's centroid routine (renamed to give credit and to prevent conflicts)
int calcSignedCentroidSingleDarkSpan_rg(float[] sensor)  // 0=line centered under sensor array  + to right , - to left
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

float[] deltaIntensities(float[] intensities)
{
  float[] delta;
  delta = new float[intensities.length];
  for(int i = 0, j = 1; i < intensities.length - 1 && j < intensities.length; i++, j++)  {
    //delta[i] = 1 - abs(intensities[j] -intensities[i]); // attempt to use Ron's centroid routine by taking the abs values are subtracted from 1  
    delta[i] = intensities[j] - intensities[i];   
  }
    return (delta);
}


int[][] determineIndexOfTrans(float[] deltas)
{
  int[][] temp;
  temp = new int[deltas.length][2];
  int[][] indxOfTrans;

  int cntr = 0;
  for(int i=0; i < deltas.length; i++) {
     if (deltas[i] != 0) {
        temp[cntr][0] = i;
        if (deltas[i] > 0) {
          temp[cntr][1] = -1;
        }
        else {
          temp[cntr][1] = 1;
        }
        cntr++;
     }
  }
 
  indxOfTrans = new int[cntr][2];  //- 1];
  
  for (int j = 0; j < indxOfTrans.length; j++) {
    indxOfTrans[j][0] = temp[j][0];
    indxOfTrans[j][1] = temp[j][1];
    
  }
  
  return(indxOfTrans);
}

int[] trimIndexOfTransList(int[][] indxOfTrans)      // ,float[] transitions) 
{
  int[] temp;
  temp = new int[indxOfTrans.length];
  int[] trimmedIndxOfTrans;
  
  int cntr = 0;
  
  for(int i = 0, j = 1; i < indxOfTrans.length - 1 && j < indxOfTrans.length; i++, j++ )  {
    if ((indxOfTrans[i][1] * indxOfTrans[j][1] > 0))  {      // sign of both transitions are the same, so they are both part of the same transition
       /*
       if (cntr == 0) {                                    // 1st transition
          temp[cntr] = indxOfTrans[i][0];
       }
       else {
         temp[cntr] = indxOfTrans[j][0];                  // trying for widest spread on single line
       }
       */
       
       temp[cntr] = indxOfTrans[j][0];
       
       cntr++;
    }
  }
    
  trimmedIndxOfTrans = new int[cntr]; 
  for (int k = 0; k < trimmedIndxOfTrans.length; k++) {
    trimmedIndxOfTrans[k] = temp[k];
  }
  
  return(trimmedIndxOfTrans);

}

float[] ctrMostTrans(float[] densities, int[][] transitions, int ctrSensorIndx)
{
  int lowerLmt = 0, upperLmt = 0;
  
  if (transitions.length > 1) {                    // at least 2 transitions
    for(int j = 0; j < transitions.length; j++) {
      if ((transitions[j][0] > ctrSensorIndx) && (upperLmt == 0)) {    // has transition beyond the center of the sensor
                                                                       // and this is the 1st transition beyond center
        upperLmt = transitions[j][0];                                       
        lowerLmt = transitions[j-1][0];
      }
    }
    if (upperLmt == 0) {                                             // no transition above center
       upperLmt = transitions[transitions.length - 1][0];            // note: still at least 2 transitions
       lowerLmt = transitions[transitions.length - 2][0];    
    }
  }
  
  // case of 1 transition
    // do something here

  // case of 0 transitions
     // do something here
     
  float[] modifiedDensityArray = new float[upperLmt - lowerLmt + 1];     //2];
  for (int j = 1; j < modifiedDensityArray.length; j++) {                           // + 1; j++) {
    modifiedDensityArray[j] = 0;                                   //densities[j * lowerLmt];
  }
  print(lowerLmt);
  print(", ");
  println(upperLmt);
  return(modifiedDensityArray);

}

// concept of centroidHistory
