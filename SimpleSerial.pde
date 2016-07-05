import processing.serial.*;

int sampleSize;  // per channel
int samplePeriod; // In milliseconds
int triggerValue;
int signalPin;
int[] values;
SerialConnection port;
Oscilloscope scope;
boolean stop = true;

void setup()
{
  port = new SerialConnection(this); //<>//
  /**
  boolean ok = port.openPort("/dev/cu.wchusbserial1420");
  if (!ok) {
    debugPrintln(2, "Port failed to open");
    exit();
  } else {
    debugPrintln(2, "PORT CONNECTED");
  }
  **/
  size(1200, 540);
  scope = new Oscilloscope(port);
  scope.promptForPorts();
  
  sampleSize = 880;
  triggerValue = 222;
  samplePeriod = 5000;
  signalPin = 1;
  
  debugPrint(2,"Warming up...");
  delay(4000);
  debugPrint(2,"Scope Running");
  stop = true;
}

void readConfig()
{
  port.startCmd(21);
  
  values = new int[4];
  for (int i=0; i<4; ++i) {
    values[i] = port.readInt();
  }
  
  port.checkAckLog();
  
  debugPrintln(2, "Test Response: " + values[0] + ", " + values[1] + ", " + values[2] + ", " + values[3]);
}

void writeConfig() 
{
  port.startCmd(20);
  
  port.writeInt(triggerValue);
  port.writeInt(sampleSize);
  port.writeInt(samplePeriod);
  port.writeInt(signalPin);
  
  port.checkAckLog();
}


void readConfig() 
{
  port.startCmd(30);
  
  values = new int[sampleSize];
  
  for (int i=0; i<sampleSize; ++i) {
    values[i] = port.readInt();
    if (values[1] == -1) {
      print('x');
    } else {
      print('.');
    }
  }
  port.checkAckLog();
}

void keyReleased()
{
  switch (key) { //<>//
    case 's':
      debugPrintln(2, "Stopping");
      stop = true;
      break;
    case 'r':
      debugPrintln(2, "Starting");
      stop = false;
      break;
    case 'x':
      debugPrintln(2, "Syncing");
      port.clear();
      break;
    case '1':
      debugPrintln(2, "Test Command 1");
      readConfig();
      break;
    case '2':
      debugPrintln(2, "Test Command 2");
      readConfig();
      debugPrintln(2, "Dumping values:");
      String res = "";
      for (int i=0; i<880; ++i) {
        res += values[i] + ", ";
      }
      debugPrintln(2, res);
      break;
    case '3':
      debugPrintln(2, "Writing Config to Arduino");
      writeConfig();
      break;
    case '-':
      debugPrintln(2, "Test Command 3");
      samplePeriod = samplePeriod/10;
      writeConfig();
      debugPrintln(2, "Set Sample Period to " + samplePeriod);
      break;
    case '+':
      debugPrintln(2, "Test Command 3");
      samplePeriod = samplePeriod * 10;
      writeConfig();
      debugPrintln(2, "Set Sample Period to " + samplePeriod);
      break;
  } 
}

void draw()
{
  if (stop == false) {
    scope.draw();
  }
}