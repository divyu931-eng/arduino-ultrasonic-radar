# 📡 Arduino Ultrasonic Radar

A real-time ultrasonic radar system built using **Arduino Uno, HC-SR04, SG90 Servo Motor, and Processing**.

The project scans objects using an ultrasonic sensor mounted on a servo motor and visualizes their **angle and distance in real time** on a radar interface.

## 📸 Project

![Arduino Ultrasonic Radar](assets/project-photo.jpg)

## 🚀 Features

- 🔄 Servo-based scanning from **15° to 165°**
- 📡 HC-SR04 ultrasonic object detection
- 📏 Real-time distance measurement
- 🎯 Angle-based object positioning
- 💻 Live radar visualization using Processing
- 🔌 Serial communication between Arduino and PC

## 🛠️ Tech Stack

- **Arduino Uno**
- **HC-SR04 Ultrasonic Sensor**
- **SG90 Servo Motor**
- **Arduino IDE**
- **Processing**
- **Serial Communication**

## 🔌 Connections

### HC-SR04

| Sensor | Arduino |
|---|---|
| VCC | 5V |
| GND | GND |
| TRIG | D10 |
| ECHO | D9 |

### SG90 Servo

| Servo | Arduino |
|---|---|
| Signal | D11 |
| VCC | 5V |
| GND | GND |

## ⚙️ Working

The ultrasonic sensor is mounted on an SG90 servo motor.

The Arduino:

1. Rotates the sensor through different angles.
2. Measures the distance of nearby objects.
3. Sends the angle and distance through Serial communication at **9600 baud**.

Processing receives this data and converts it into a radar-style graphical display.

```text
HC-SR04
    ↓
Arduino Uno
    ↓
Serial Communication
    ↓
Processing
    ↓
Real-Time Radar
