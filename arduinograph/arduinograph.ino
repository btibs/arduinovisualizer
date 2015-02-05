int LED_PIN = 10;
int ANALOG_PINS[] = {0,1,2,3,4,5};
int nAnalogPins = 6;
int DIGITAL_PINS[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};
int nDigitalPins = 14;

void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.print("$");
  for (int i=0; i < nAnalogPins; i++) {
    int analogValue = analogRead(ANALOG_PINS[i]);
    Serial.print("A");
    Serial.print(ANALOG_PINS[i]);
    Serial.print(":");
    Serial.print(analogValue);
    Serial.print(",");
  }
  for (int i=0; i < nDigitalPins; i++) {
    int digitalValue = digitalRead(DIGITAL_PINS[i]);
    Serial.print("D");
    Serial.print(DIGITAL_PINS[i]);
    Serial.print(":");
    Serial.print(digitalValue);
    Serial.print(",");
  }
  Serial.println();
  delay(50);
}

