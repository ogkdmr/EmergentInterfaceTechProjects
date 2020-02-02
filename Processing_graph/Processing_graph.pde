Graph MyArduinoGraph = new Graph(150, 80, 500, 300, color (200, 20, 20));
float[] gestureOne=null;
float[] gestureTwo = null;
float[] gestureThree = null;

float[][] gesturePoints = new float[6][2];
float[] gestureDist = new float[6];
String[] names = {"Nothing", "Left", "Right","Forward", "Back", "Fire"};

String[] packetToSpaceShooter = new String[1]; //this is the name of the gesture that is being sent to the game sketch.

void setup() {

  size(1000, 750); 

  MyArduinoGraph.xLabel="Readnumber";
  MyArduinoGraph.yLabel="Amp";
  MyArduinoGraph.Title=" Graph";  
  noLoop();
  PortSelected= 32;      /* ====================================================================
   adjust this (0,1,2...) until the correct port is selected 
   In my case 2 for COM4, after I look at the Serial.list() string 
   println( Serial.list() );
   [0] "COM1"  
   [1] "COM2" 
   [2] "COM4"
   ==================================================================== */
  SerialPortSetup();      // speed of 115200 bps etc.
}


void draw() {

  background(255);

  /* ====================================================================
   Print the graph
   ====================================================================  */

  if ( DataRecieved3 ) {
    pushMatrix();
    pushStyle();
    MyArduinoGraph.yMax=1000;      
    MyArduinoGraph.yMin=-200;      
    /* ====================================================================
     Gesture compare
     ====================================================================  */
    float totalDist = 0;
    int currentMax = 0;
    float currentMaxValue = -1;
    for (int i = 0; i < 6;i++)

    {

      //  gesturePoints[i][0] = 
      if (mousePressed && mouseX > 750 && mouseX<800 && mouseY > 100*(i+1) && mouseY < 100*(i+1) + 50)
      {
        fill(255, 0, 0);

        gesturePoints[i][0] = Time3[MyArduinoGraph.maxI];
        gesturePoints[i][1] = Voltage3[MyArduinoGraph.maxI];
      }
      else
      {
        fill(255, 255, 255);
      }

   //calucalte individual dist
      gestureDist[i] = dist(Time3[MyArduinoGraph.maxI], Voltage3[MyArduinoGraph.maxI], gesturePoints[i][0], gesturePoints[i][1]);
      totalDist = totalDist + gestureDist[i];
      if(gestureDist[i] < currentMaxValue || i == 0)
      {
         currentMax = i;
        currentMaxValue =  gestureDist[i];
      }
    }
    totalDist=totalDist /5;

    for (int i = 0; i < 6;i++)
    {
      float currentAmmount = 0;
      currentAmmount = 1-gestureDist[i]/totalDist;
      if(currentMax == i)
       {
         fill(0,0,0);
    //       text(names[i],50,450);
       fill(currentAmmount*255.0f, 0, 0);
       //println(names[i]);
       packetToSpaceShooter[0] = names[i];
       
       
       /*
       Asynchronous thread that writes to the "myfifo" pipe. Calls the writeToPipe in that thread.
       */
       thread("writeToPipe");
       }
       
       else
       {
         fill(255,255,255);
       }

      stroke(0, 0, 0);
      rect(750, 100 * (i+1), 20, 20);
      fill(0,0,0);
      textSize(20);
      text(names[i],810,100 * (i+1)+25);

      fill(255, 0, 0);
   //   rect(800,100* (i+1), max(0,currentAmmount*50),50);
    }


  }
}

void stop()
{

  myPort.stop();
  super.stop();
}

/*
Writing data to the pipe for the spaceshooter game to read.
This data is a float value that identifies the gesture.
*/
void writeToPipe() {
  saveStrings("../myfifo", packetToSpaceShooter);
}
