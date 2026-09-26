/*
  Arduino Uno Radar Project
  -------------------------
  Hardware: HC-SR04 ultrasonic sensor mounted on an SG90 servo.
  The servo sweeps 15°-165°, and at each angle the sensor measures
  distance. Data is sent over Serial as "angle,distance." so a
  Processing sketch on your laptop can draw a live radar display.

  Wiring:
    HC-SR04  VCC  -> Arduino 5V
    HC-SR04  GND  -> Arduino GND
    HC-SR04  Trig -> Arduino Pin 10
    HC-SR04  Echo -> Arduino Pin 9
    Servo    Signal -> Arduino Pin 11
    Servo    VCC  -> Arduino 5V
    Servo    GND  -> Arduino GND
*/

#include <Servo.h>

const int trigPin = 10;
const int echoPin = 9;
const int servoPin = 11;

Servo radarServo;

long duration;
int distanceCm;

void setup() {
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  radarServo.attach(servoPin);
}

int getDistance() {
  // Send a 10us pulse to trigger the sensor
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Read the echo pulse duration (30ms timeout ~ 5m max range)
  duration = pulseIn(echoPin, HIGH, 30000);

  if (duration == 0) {
    return 400; // no echo received -> treat as out of range
  }

  int distance = duration * 0.034 / 2; // convert to cm
  return constrain(distance, 0, 400);
}

void sweepAndSend(int startAngle, int endAngle, int step) {
  for (int angle = startAngle; angle != endAngle; angle += step) {
    radarServo.write(angle);
    delay(30); // allow servo to settle
    distanceCm = getDistance();

    Serial.print(angle);
    Serial.print(",");
    Serial.print(distanceCm);
    Serial.print(".");
  }
}

void loop() {
  sweepAndSend(15, 166, 1);   // sweep forward
  sweepAndSend(165, 14, -1);  // sweep backward
}
