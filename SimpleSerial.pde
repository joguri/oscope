import processing.serial.*;

int sampleSize;  // per channel
int samplePeriod; // In milliseconds
int triggerValue;
int signalPin;
int[] values;
SerialConnection port;
Oscilloscope scope;
boolean stop = true;
int[] periods;
int periodIndex = 5;

void setup()
{
  port = new SerialConnection(this);
  size(1200, 540);
  scope = new Oscilloscope(port);
  scope.promptForPorts();
  
  sampleSize = 880;
  triggerValue = 222;
  signalPin = 1;
  stop = false;
  periods = new int[] { 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000 };
  samplePeriod = periods[periodIndex];
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
  
  if (samplePeriod > 5000) {
    scope.setContinuousMode(true);
  } else {
    scope.setContinuousMode(false);
  }
  
  port.checkAckLog();
}


void sampleData() 
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
  switch (key) {
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
      debugPrintln(2, "Read Configuration from Arduino");
      readConfig();
      break;
    case '2':
      debugPrintln(2, "Sample Data");
      sampleData();
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
      if (periodIndex > 0) {
        periodIndex -= 1;
      }
      samplePeriod = periods[periodIndex];
      writeConfig();
      debugPrintln(2, "Set Sample Period to " + samplePeriod);
      break;
    case '+':
      debugPrintln(2, "Test Command 3");
      if (periodIndex < 11) {
        periodIndex += 1;
      }
      samplePeriod = periods[periodIndex];
      writeConfig();
      debugPrintln(2, "Set Sample Period to " + samplePeriod);
      break;
  } 
}

void mousePressed()
{
  scope.mousePressed();
  debugPrint(2, "Initializing Configuration");
  delay(2000);
  writeConfig();
  debugPrint(2, "done");
}

void draw()
{
  if (stop == false) {
    scope.draw();
  }
}