// Plot analog and digital inputs on a graph

import processing.serial.*;
import java.util.LinkedList;

Serial myPort;
PFont f;
boolean setupComplete = false;

// These values must match the arduino file!
int nAnalogPins = 6;
int nDigitalPins = 14;

LinkedList<Integer>[] aValues;
int[] aColors;

LinkedList<Integer>[] dValues;
int[] dColors;

void setup () {
  frameRate(15);
  aValues = new LinkedList[nAnalogPins];
  for (int i=0; i < nAnalogPins; i++) {
    aValues[i] = new LinkedList<Integer>();
  }
  
  dValues = new LinkedList[nDigitalPins];
  for (int i=0; i < nDigitalPins; i++) {
    dValues[i] = new LinkedList<Integer>();
  }
  
  // set window size:
  size(800, 600);
  frame.setResizable(true);

  // Open the Arduino's serial port
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
  
  // set inital background:
  colorMode(HSB,100);
  background(0);
  f = createFont("Arial", 12, true);
  textFont(f);
  
  // assign colors  
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

void draw() {
  // everything goes in serial
}

void serialEvent(Serial myPort) {
  try{
  String inString = myPort.readStringUntil('\n');
  if (inString != null && inString.startsWith("$")) {
    // format is like: "$A0:9,A1:88,D3:9,"
    inString = inString.substring(1);
    // get the substrings
    String[] inputs = split(inString, ",");
    for (int i=0; i < inputs.length-1; i++) { // last one will always be blank
      if (inputs[i].length() > 0) {
        String[] temp = inputs[i].split(":");
        String label = temp[0];
        int idx = int(label.substring(1));
        int value = int(temp[1]);
        if (label.charAt(0) == 'A') {
          aValues[idx].addFirst(value); // add to front of list
          if (aValues[idx].size() >= width) {
            aValues[idx].pollLast(); // remove end of list
          }
        } else if (label.charAt(0) == 'D') {
          dValues[idx].addFirst(value);
          if (dValues[idx].size() >= width) {
            dValues[idx].pollLast();
          }
        }
      }
    }
    
    if (setupComplete) {
      // now that we have the data, plot it
      background(0);
      
      // axis labels
      stroke(50);
      fill(50);
      line(0,2*height/3,width,2*height/3);
      
      int maxHeight = 2*height/3;
      int nTicks = 10;
      for (int i=0; i < nTicks; i++) {
        int y = i * maxHeight / nTicks;
        line(0, y, width, y);
        text(""+1023/nTicks*i, 0, y); 
      }
      
      // analog graph: top 2/3
      for (int i=0; i < nAnalogPins; i++) {
        stroke(aColors[i],100,100);
        int prevVal = aValues[i].peek();
        int xPos = 1;
        for (Integer curVal : aValues[i]) {
          float prevHeight = map(prevVal, 0, 1023, 3, 2*height/3);
          float curHeight = map(curVal, 0, 1023, 3, 2*height/3);
          line(xPos-1, prevHeight, xPos, curHeight);
          xPos++;
          prevVal = curVal;
        }
      }
      
      // legend
      int lblY = 10;
      int dLbl = 25;
      for (int i=0; i < nAnalogPins; i++) {
        stroke(0);
        fill(aColors[i],100,100);
        rect(width-40,lblY,10,10);
        textAlign(LEFT, TOP);
        text("A" + i, width-25,lblY);
        lblY += dLbl;
      }
      
      // digital graph: bottom 1/3
      // with legend
      int graphStart = 2*height/3+2;
      int graphHeight = (height/3) / nDigitalPins;
      for (int i=0; i < nDigitalPins; i++) {
        stroke(dColors[i],50,100);
        fill(dColors[i],50,100);
        int prevVal = dValues[i].peek();
        int xPos = 1;
        for (Integer curVal : dValues[i]) {
          float prevHeight = map(prevVal, 0, 1, graphStart, graphStart+graphHeight-2);
          float curHeight = map(curVal, 0, 1, graphStart, graphStart+graphHeight-2);
          line(xPos-1, prevHeight, xPos, curHeight);
          xPos++;
          prevVal = curVal;
        }
        textAlign(LEFT, TOP);
        text("D" + i, 0,graphStart);
        graphStart += graphHeight;
      }
    }
    
  }
  } catch (Exception e) {
    System.out.println(e.getMessage());
  }
}
