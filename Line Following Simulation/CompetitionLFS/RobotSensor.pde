/* Line and Spot Sensor Code
   Ron Grant  June 2020
   
   June 30,2020  per Will - "spot" name for rectangular array of pixels sampled by spot sensor
                            line sensor samples an array of spots, assumed to be adjacent in robot Y (left right) direction
                            without overlap or separation.
                            
   Jun 30 20  - corrected truncation error in halfWidth calculation for line sensor offset                         
                            
                            
   
   
   User defines spot and line sensors in setup()
   
   A spot sensor samples a rectangular array of screen pixels referred to as a "spot".
   A line sensor samples a linear array of spots which are ,for now, adjacent with no space between them, or overlap.
      
   
   updateSensors() called from drawWorld() when view rendered to screen of overhead view of robot pointing toward top of screen.
   This method calculates an intensity value 0.0 to 1.0 for each spot sensor spot. Also it calculates the intensity value for each spot
   in the linear array of spots of a line sensor which it stores in an array which can be accessed by calling read() method for each.
   
   A spot sensor returns a float value.
   The line sensor returns a reference to float array.
   
   e.g. for line sensor  
   
   float[] lineData = lineSensor.read();
   
  

*/



// global sensor lists - built as sensors are defined, generally not needed by "user"

ArrayList <SpotSensor> spotSensorList = new ArrayList<SpotSensor>();   // list of spot sensors, created automatically as spot sensor instances are created  
ArrayList <LineSensor> lineSensorList = new ArrayList<LineSensor>();   // list of line sensors, created automatically as line sensor instances are created 


class SpotSensor {
                              // viewing robot from above
  private float xoff;         // sensor offset from robot center in inches (positive X=distance along robot direction of straight travel, positive Y=distance to right)
  private float yoff;
  private int spotWPix;
  private int spotHPix;       // spot size in pixel
  private float intensity;    // normalized intensity 0.0 (black) to 1.0 (white)
 

 SpotSensor (float xoff, float yoff, int spotWPix, int spotHPix)  // constructor 
 {
   this.xoff = xoff;
   this.yoff = yoff;
   this.spotWPix = spotWPix;
   this.spotHPix = spotHPix;
   
   spotSensorList.add(this);   // add this new instance to list, processed by sensorUpdate()
   
 }
 
 float read() { return intensity; } // return current sensor value, normalized 0.0 (black) to 1.0 (white), used by controller 
    
}


class LineSensor {
  private float xoff;         // sensor offset from robot center in inches (positive X=distance along robot direction of straight travel, positive Y=distance to right)
  private float yoff;
  private int spotWPix;
  private int spotHPix;         // spot size in pixel
  
  private int sensorCells;      // cells (spots) in line sensor   assumed to be spotWPix x spotHPix each with zero space between each sensor pixel
  private float[] sensorTable;  

  LineSensor (float xoff, float yoff, int spotWPix, int spotHPix, int sensorCells)
  {
    this.xoff = xoff;
    this.yoff = yoff;
    this.spotWPix = spotWPix;
    this.spotHPix = spotHPix;
   
    this.sensorCells = sensorCells;
    sensorTable = new float[sensorCells];  // allocate sensor values - use read() or getSensorTable() to access
    
    lineSensorList.add(this); 
    
  }

  int getSensorCellCount () { return sensorCells; }
  
  float[] getSensorTable() { return sensorTable; }   // get reference to array  identical to read()  
  float[] read() { return sensorTable; }             


}


float sampleSensorPixel (float xoff, float yoff, int index, int wPix, int hPix)  // used by updateSensors() to sample screen pixels
                                                                                 // not called by user
{
  
  // for each sample location sample a rectangular region from -wPix/2 to wPix/2 in screen X (robot Y) 
  // and from -hPix/2 to hPix/2 in screen Y (robot X), expecting that wPix and hPix are odd values  
  
  // force wPix and hPix to be odd # for symmetrical pixel array sampling about sensor location
  
  if ((wPix & 1) == 0) wPix++;
  if ((hPix & 1) == 0) hPix++; 
  
  int w2 = wPix/2;    // calc half width height in pixels for cluster rectangular sampling indicies of wPix by hPix region centered at current 
  int h2 = hPix/2;    // sensor location which will include line sensor index (horizontal displacement of index th sensor in the line sensor.)
 
  // (Made some changes - did not update Will's comment here) 
  // Image is a linear array of pixels, ie one dimension array  wjk 6-14-20
  //   index of a pixel is row index * image width + column index
  //   row index is row index of center of sensor element [width * sensorY]
  //    + pixel offset from center of sensor element [yr]
  //   column index is column index of center of sensor [width / 2]
  //    + sensor element offset [2 + x * 5]
  //    + pixel offset from center of sensor element [xr]
 
 
  int sensorY = int (xoff * courseDPI);  // calculate pixel offset of sensor "pixel cluster"     note robot X points up on screen in decending Y pixel coordinates 
  int sensorX = int (yoff * courseDPI);  // from robot center these are pixel values                  robot Y axis points to right on screen 
  
  
  // sample all pixels in sensor pixel (rectangular cluster of screen pixels) - reading Green channel 0..255 0=black 255=bright white  
  
  int count = 0;
  int sum = 0;
  
  for (int yr=-h2; yr<h2+1;yr++)
  for (int xr=-w2; xr<w2+1; xr++)
  {
    
   int scanLine = height/2 - sensorY - yr;       // scanline number (the screen Y coordinate value)
   int indexOffset = index * wPix;               // calculate multi-cell sensor offset , e.g. 0..63 for 64 element line sensor
                                                 // generates an offset = nth pixel cluster assuming pixel clusters are adjacent without overlap or separation
                                                 // this value is 0 for spot sensors
   
   int pixelCol = width/2  + sensorX + xr + indexOffset;   // screen X coordinate calc 
   
      
   int i = width*scanLine + pixelCol;               // index into 1D pixel array    
   
   sum +=  (pixels[i] >> 8) & 0xFF;                 // sample Green channel 0..255 
   
   if ((abs(yr)==h2) || (abs(xr)==w2) )             // make sensor cell bounds visible
     pixels[i] = color (40);                        // dark gray boundary pixels
   else
     pixels[i] = color (100,255,100);               // mark pixel as read - pale green 
                                                    // requires updatePixels() call when finished 
    
   count++;                                         // tally the number of pixels sampled   
  }
   
  return sum/count/255.0; // return normalized value 0.0 (black) to 1.0 (white)
    
}




void updateSensors() // called from drawWorld() after view created at current robot position and heading
                     // iterates through sensor lists, reading all sensor values and storing within sensor class instances
                     // spot sensors sample a single cluster (rect array) of pixels
                     // line sensors sample a linear cluster array or clusters of pixels  
{
   
  loadPixels(); // prepare to access screen pixels in pixels[] array
  
  
  // update spot sensors 
 
  for (SpotSensor ss : spotSensorList)
  {
    ss.intensity = sampleSensorPixel(ss.xoff,ss.yoff,0,ss.spotWPix,ss.spotHPix);     // xoff,yoff,index=0, spot Width and Height
   // println (ss.intensity)l
  }
  
  // update line sensors 
  
  for (LineSensor ls : lineSensorList)
  {
    float[] sensorTable = ls.getSensorTable();   // get a reference to sensor's sensorTable & update it pixel by pixel
 
    int n = ls.getSensorCellCount();  
    
    float halfWidth = (n / 2.0 * ls.spotWPix) / courseDPI;      // half width of line sensor in inches 
                                                                // used to calculate offset of line sensor
                                                                // equal to 1/2 sensor total width applied in robot -Y direction 
    
    //println ("Line sensor half width = ",halfWidth);
    
    for (int index=0; index<n; index++)
    { // for each line sensor pixel index (e.g. 0..63 if 64 pixel sensor)
      sensorTable[index] = sampleSensorPixel(ls.xoff,ls.yoff-halfWidth,index,ls.spotWPix,ls.spotHPix);   // xoff,yoff,index   spot Width and Height (pixel counts)
    }  
  }
  
   
  updatePixels();  // update required since sampled pixels are have been colored green to help with visualization of locations sampled     
}  
