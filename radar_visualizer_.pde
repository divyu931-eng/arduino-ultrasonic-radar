/*
  Radar Visualizer (Processing)
  -----------------------------
  Reads "angle,distance." data from the Arduino over serial and
  draws a classic sweeping radar display.

  SETUP:
  1. Install Processing (free) from processing.org
  2. Close the Arduino IDE's Serial Monitor (only one program can
     use the COM port at a time)
  3. Below, set the correct COM port name for your system
  4. Run this sketch (the Play button)
*/

import processing.serial.*;

Serial myPort;
String angle = "";
String distance = "";
String data = "";
int iAngle, iDistance;
float dotInterval = 250;  // minimum time (ms) between new dots. 0.5s = 500
int lastHitTime = 0;      // tracks when the last dot was added

int maxDistance = 200; // cm - adjust to your sensor's usable range

// Each detected object is stored here with a "life" countdown so it
// fades out over time instead of disappearing the instant the sweep
// moves past it.
ArrayList<float[]> hits = new ArrayList<float[]>(); // {x, y, life}
int hitLifespan = 100;   // how many frames a dot stays visible (~1.5s at 60fps)
int dotSize = 20;       // increase this for an even bigger dot

void setup() {
  size(1200, 700);

  // ---- CHANGE THIS to match your Arduino's COM port ----
  // On Windows it looks like "COM3", "COM5", etc.
  // On Mac/Linux it looks like "/dev/cu.usbmodemXXXX" or "/dev/ttyUSB0"
  // Uncomment the next line to print all available ports:
  // printArray(Serial.list());

  String portName = Serial.list()[0]; // auto-picks first port; change index if wrong
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('.');

  noStroke();
  smooth();
}

void draw() {
  fill(0, 20);
  rect(0, 0, width, height - 100);

  drawRadarGrid();
  drawSweepLine();
  drawObject();
  drawText();
}

void drawRadarGrid() {
  pushMatrix();
  translate(width / 2, height - 100);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);

  // range rings with distance labels
for (int r = 1; r <= 4; r++) {
  float ringDiameter = (width - 100) / 4 * r;
  arc(0, 0, ringDiameter, ringDiameter, PI, TWO_PI);

  int ringDistance = int(maxDistance / 4.0 * r);
  fill(98, 245, 31);
  noStroke();
  textSize(12);
  text(ringDistance + " cm", -10, -(ringDiameter / 2) - 4);
  noFill();
  stroke(98, 245, 31);
}

  // angle lines
  line(-width/2, 0, width/2, 0);
  for (int a = 30; a < 180; a += 30) {
    float x = (width/2) * cos(radians(a));
    float y = -(width/2) * sin(radians(a));
    line(0, 0, x, y);
  }
  popMatrix();
}

void drawSweepLine() {
  pushMatrix();
  translate(width / 2, height - 100);
  strokeWeight(9);
  stroke(30, 250, 60);
  float maxRadius = (width - 100) / 2.0;
float x = maxRadius * cos(radians(iAngle));
float y = -maxRadius * sin(radians(iAngle));
  line(0, 0, x, y);
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width / 2, height - 100);

  // Draw every recent hit, fading it out as its life runs down.
  for (int i = hits.size() - 1; i >= 0; i--) {
    float[] hit = hits.get(i);
    float lifeRatio = hit[2] / (float) hitLifespan;
    float alpha = 130 * sqrt(lifeRatio);

    noStroke();
    fill(255, 100, 100, alpha * 0.5); // soft outer glow
    ellipse(hit[0], hit[1], hit[3] * 2, hit[3] * 2);
    fill(255, 150, 150, alpha); // lighter core, not solid dark red
    ellipse(hit[0], hit[1], hit[3], hit[3]);
    
    //For distance with the dots
    fill(255, 255, 255, alpha);
    textSize(12);
    text(int(hit[4]) + " cm", hit[0] + hit[3], hit[1]);

    hit[2] -= 1; // count down this hit's remaining life
    if (hit[2] <= 0) {
      hits.remove(i);
    }
  }
  popMatrix();
}

void drawText() {
  fill(0);
  noStroke();
  rect(0, height - 100, width, 100);
  fill(98, 245, 31);
  textSize(20);
  text("Angle: " + iAngle + "°", 20, height - 60);
  //text("Distance: " + (iDistance < maxDistance ? iDistance + " cm" : "out of range"), 300, height - 60);
  text("Radar Scanner", width - 220, height - 60);
}

void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.');
  if (data != null) {
    data = data.substring(0, data.length() - 1);
    int index = data.indexOf(",");
    if (index > 0) {
      angle = data.substring(0, index);
      distance = data.substring(index + 1, data.length());
      iAngle = int(angle);
      iDistance = int(distance);

      // Log a new hit point (with full life) if something is in range.
      if (iDistance < maxDistance && millis() - lastHitTime >= dotInterval) {
  float maxRadius = (width - 100) / 2.0;
  float pixsDistance = iDistance * (maxRadius / maxDistance);
  float x = pixsDistance * cos(radians(iAngle));
  float y = -pixsDistance * sin(radians(iAngle));
  float dynamicSize = map(iDistance, 0, maxDistance, dotSize * 1.5, dotSize * 0.5);
  hits.add(new float[]{x, y, hitLifespan, dynamicSize, iDistance});
  lastHitTime = millis();
}
    }
  }
}
