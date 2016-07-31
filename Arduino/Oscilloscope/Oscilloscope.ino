#include <TimerOne.h>

#define ANALOG_IN_0 0
#define ANALOG_IN_1 1
#define ANALOG_IN_2 2
#define ANALOG_IN_3 3
#define ANALOG_IN_4 4
#define ANALOG_IN_5 5
#define ANALOG_IN_6 6
#define ANALOG_IN_7 7

#define CMD_HEADER  1234
#define CMD_SET_CONFIG  20
#define CMD_READ_CONFIG  21
#define CMD_SEND_DATA 30
#define CMD_VOLT_DATA 31
#define CMD_ACK 5678

// Define various ADC prescaler
const unsigned char PS_16 = (1 << ADPS2);
const unsigned char PS_32 = (1 << ADPS2) | (1 << ADPS0);
const unsigned char PS_64 = (1 << ADPS2) | (1 << ADPS1);
const unsigned char PS_128 = (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);

int sampleSize;  // per channel
int samplePeriod; // In milliseconds
int triggerValue;
int signalPin;
int previousValue;

boolean triggerEnabled;

int sCount = 0;
boolean active = false;
boolean continuousMode = false;

void setup() {
  Serial.begin(115200);

  triggerValue = 111;
  sampleSize = 880;
  samplePeriod = 500;
  signalPin = ANALOG_IN_0;
  triggerEnabled = false;
  previousValue = 1025;
  
  // set up the ADC
  ADCSRA &= ~PS_128;  // remove bits set by Arduino library

  // you can choose a prescaler from above.
  // PS_16, PS_32, PS_64 or PS_128
  ADCSRA |= PS_16;   // set our own prescaler to 64 
}


boolean setConfig() {
    waitForSerialAvailable(8);
    triggerValue = readInt();
    sampleSize   = readInt();
    samplePeriod = readInt();
    signalPin    = readInt();
    writeInt(CMD_ACK);
    if (triggerValue == 0) {
      triggerEnabled = false;
    } else {
      triggerEnabled = true;
    }
    if (samplePeriod > 1000) {
      continuousMode = true;
    } else {
      continuousMode = false;
    }
    return true;
}

boolean readConfig() {
    writeInt(triggerValue);
    writeInt(sampleSize);
    writeInt(samplePeriod);
    writeInt(signalPin);
    
    writeInt(CMD_ACK);
    return true;
}

boolean sendVoltages() {
  writeInt(analogRead(ANALOG_IN_0));
  writeInt(analogRead(ANALOG_IN_1));
  writeInt(analogRead(ANALOG_IN_2));
  writeInt(analogRead(ANALOG_IN_3));
  writeInt(analogRead(ANALOG_IN_4));
  writeInt(analogRead(ANALOG_IN_5));
  writeInt(analogRead(ANALOG_IN_6));
  writeInt(analogRead(ANALOG_IN_7));
  writeInt(CMD_ACK);
}

/*******************************************************************************/
/** Test Routines **/
/*******************************************************************************/

void sendDataFrame() {
    sCount = 0;
    previousValue = 2000;
    
    Timer1.initialize(samplePeriod);
    Timer1.attachInterrupt(readSigs);
}

boolean triggered() {
  if (triggerEnabled == false || active == true || continuousMode == true) {
    return true;
  }
  boolean done = false;
  while( !done ) {
    int v1 = analogRead(signalPin);
    if (v1 > triggerValue &&  
        triggerValue > previousValue) {
      active = true;
      return true;
    } else {
      previousValue = v1;
    }
  }
}

void readSigs() {
  if (triggered() == false) {
    return;
  }
  writeInt(analogRead(signalPin));
  ++sCount;
  if (sCount < sampleSize) {
    ;
  } else {
    active = false;
    writeInt(CMD_ACK);
    Timer1.stop();
  }
}

void loop() {
  if (Serial.available() >= 4) {
    int cmdHeader = readInt();
    
    if (cmdHeader == CMD_HEADER) {
      int cmdCode = readInt();
      
      if (cmdCode == CMD_SET_CONFIG) {
        setConfig();
      } else if (cmdCode == CMD_READ_CONFIG) {
        readConfig();
      } else if (cmdCode == CMD_SEND_DATA) {
        sendDataFrame();
      } else if (cmdCode == CMD_VOLT_DATA) {
        sendVoltages();
      }
    }
  }
}


