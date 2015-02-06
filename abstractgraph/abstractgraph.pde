// Abstract representation of outputs
// Loosely based on the idea of planets and moons

import processing.serial.*;

Serial myPort;
PFont f;
boolean setupComplete = false;
int maxSize = 100;

// These values must match the arduino file!
int nAnalogPins = 6;
int nDigitalPins = 14;

// last value
int[] aValues;
int[] dValues;

// last position
int[][] aPos;
int[][] dPos;
double[] aAngle;
double[] aRadius;

int[] aColors;
int[] dColors;

int[] aPinsToPlot = {0,5};
int[] dPinsToPlot = {2,4};

void setup() {
  aValues = new int[nAnalogPins];
  dValues = new int[nDigitalPins];
  
  aColors = new int[nAnalogPins];
  dColors = new int[nDigitalPins];
  
  aPos = new int[nAnalogPins][2];
  aAngle = new double[nAnalogPins];
  aRadius = new double[nAnalogPins];
  dPos = new int[nDigitalPins][2];
  
  // set window size:
  size(600, 400);
  frame.setResizable(false);

  // initialize positions
  int[] center = {width/2, height/2};
  int rad = height/6;
  for (int i=0; i<aPos.length; i++) {
    double theta = Math.PI*2 / nAnalogPins;
    double angle = theta * i;
    aPos[i][0] = (int)(rad * Math.cos(angle)) + center[0]; // x
    aPos[i][1] = (int)(rad * Math.sin(angle)) + center[1]; // y
    aAngle[i] = angle;
    aRadius[i] = rad;
  }
  
  int dRadius = height/3;
  for (int i=0; i<dPos.length; i++) {
    double theta = Math.PI*2 / nDigitalPins;
    double angle = theta * i;
    dPos[i][0] = (int)(dRadius * Math.cos(angle)) + center[0]; // x
    dPos[i][1] = (int)(dRadius * Math.sin(angle)) + center[1]; // y
  }
  
  // Open the Arduino's serial port
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
  
  // set inital background:
  colorMode(HSB,100);
  background(0);
  f = createFont("Arial", 12, true);
  textFont(f);
  
  // assign colors (same as graph)  
  int hue = 0;
  int dHue = 100 / nAnalogPins;
  aColors = new int[nAnalogPins];
  for (int i=0;i<nAnalogPins;i++) {
    aColors[i] = hue;
    hue += dHue;
  }
  
  hue = 0;
  dHue = 100 / nDigitalPins;
  dColors = new int[nDigitalPins];
  for (int i=0;i<nDigitalPins;i++) {
    dColors[i] = hue;
    hue += dHue;
  }
  
  setupComplete = true;
}

void getData() {
  String inString = myPort.readStringUntil('\n');
  if (inString != null && inString.startsWith("$")) {
    // format is like: "$A0:9,A1:88,D3:9,"
    inString = inString.substring(1);
    // get the substrings
    String[] inputs = split(inString, ",");
    for (int i=0; i < inputs.length-1; i++) {
      // last one will always be blank
      if (inputs[i].length() > 0) {
        String[] temp = inputs[i].split(":");
        if (temp.length == 2) {
          String label = temp[0];
          int idx = int(label.substring(1));
          int value = int(temp[1]);
          if (label.charAt(0) == 'A') {
            aValues[idx] = value;
          } else if (label.charAt(0) == 'D') {
            dValues[idx] = value;
          }
        }
      }
    }
  }
}

void drawCurrentPositions() {
  for (int i : aPinsToPlot) {
    float size = map(aValues[i], 0, 1023, 5, maxSize);
    float b = map(aValues[i],0,1023,100,50);
    fill(aColors[i], 100, b, 100);
    stroke(aColors[i], 100, b, 100);
    ellipse(aPos[i][0], aPos[i][1], size, size);
  }
  for (int i : dPinsToPlot) {
    float size = map(dValues[i], 0, 1, maxSize/7, maxSize/5);
    int b = (dValues[i] == 0)?50:100;
    fill(dColors[i], 50, b, 100);
    stroke(dColors[i], 50, b, 100);
    rect(dPos[i][0], dPos[i][1], size, size, 3);
  }
}

void movePlanets() {
  // analog 'planets' will rotate around the center, falling in and out as their 'mass' increases/decreases
  // speed also varies such that planets further out move at a slower angular rate (qualitative version of Kepler's Second Law) 
  double dTheta = Math.PI / 50; // speed
  int[] center = {width/2, height/2};
  for (int i : aPinsToPlot) {
    double newRad = map(aValues[i],0,1023,75,200); // where the planet *should* be
    double dRad = aRadius[i] - newRad;
    aRadius[i] -= dRad/5; // speed of radial motion
    if (aRadius[i] < 75)
      aRadius[i] = 75;
    else if (aRadius[i] > 200)
      aRadius[i] = 200;
    
    aAngle[i] += (dTheta * (225-aRadius[i])/50); // first number should be > max radius, second controls angular speed
    if (aAngle[i] > Math.PI*2)
      aAngle[i] -= Math.PI*2;
    aPos[i][0] = (int)(aRadius[i] * Math.cos(aAngle[i])) + center[0]; // x
    aPos[i][1] = (int)(aRadius[i] * Math.sin(aAngle[i])) + center[1]; // y
  }
}

void moveMoons() {
  // digital 'moons' are pulled towards planets
  for (int i : dPinsToPlot) {
    PVector diff = new PVector(0,0);
    for (int j : aPinsToPlot) {
      PVector moonToPlanet = new PVector(dPos[i][0] - aPos[j][0],dPos[i][1] - aPos[j][1]);
      // f = g mm/r^2
      float r2 = moonToPlanet.magSq();
      float f = aValues[j] / r2;
      moonToPlanet.mult(f); // weight by signal
      diff.add(moonToPlanet);
    }
    diff.normalize();
    diff.mult(2); // speed
    
    // update positions
    dPos[i][0] -= diff.x;
    if (dPos[i][0] > width)
      dPos[i][0] = width;
    else if (dPos[i][0] < 0)
      dPos[i][0] = 0;
      
    dPos[i][1] -= diff.y;
    if (dPos[i][1] > height)
      dPos[i][1] = height;
    else if (dPos[i][1] < 0)
      dPos[i][1] = 0;
  }
}

void draw() {
  getData();
  if (!setupComplete)
    return;
    
  // Fade effect
  fill(0, 50);
  stroke(0);
  rect(0,0,width, height);
  
  drawCurrentPositions();
  movePlanets();
  moveMoons();
}
