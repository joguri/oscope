import processing.serial.*;

int sampleSize;  // per channel
int samplePeriod; // In milliseconds
int triggerValue;
int signalPin;
int[] values;
SerialConnection port;
Oscilloscope scope;

void setup() 
{
  port = new SerialConnection(this, "/dev/cu.wchusbserial1450");
  boolean ok = port.openPort();
  size(1200, 540);
  
  scope = new Oscilloscope(port);
  
  if (!ok) {
    debugPrintln(2, "BAD PORT: " + "/dev/cu.wchusbserial1450");
  } else {
    debugPrintln(2, "PORT CONNECTED");
  }
  
  sampleSize = 880;
  triggerValue = 222;
  samplePeriod = 5000;
  signalPin = 1;
}

void test1()
{
  startCmd(21);
  
  values = new int[4];
  
  for (int i=0; i<4; ++i) {
    values[i] = port.readInt();
  }
  debugPrintln(2, "Test Response: " + values[0] + ", " + values[1] + ", " + values[2] + ", " + values[3]);
  port.checkAckLog();
}

void test3() 
{
  startCmd(20);
  
  port.writeInt(triggerValue);
  port.writeInt(sampleSize);
  port.writeInt(samplePeriod);
  port.writeInt(signalPin);
  
  port.checkAckLog();
}


void test2() 
{
  startCmd(30);
  
  values = new int[880];
  
  for (int i=0; i<880; ++i) {
    values[i] = port.readInt();
    if (values[1] == -1) {
      print('x');
    } else {
      print('.');
    }
  }
  port.checkAckLog();
}

void startCmd(int cmd)
{
  port.writeInt(1234);
  port.writeInt(cmd);
}

void keyReleased()
{
  switch (key) {
    case 's':
      debugPrintln(2, "Syncing");
      port.clear();
      break;
    case '1':
      debugPrintln(2, "Test Command 1");
      test1();
      break;
    case '2':
      debugPrintln(2, "Test Command 2");
      test2();
      debugPrintln(2, "Dumping values:");
      String res = "";
      for (int i=0; i<880; ++i) {
        res += values[i] + ", ";
      }
      debugPrintln(2, res);
      break;
    case '3':
      debugPrintln(2, "Test Command 3");
      test3();
      break;
    case '-':
      debugPrintln(2, "Test Command 3");
      samplePeriod = samplePeriod/10;
      debugPrintln(2, "Set Sample Period to " + samplePeriod);
      break;
    case '+':
      debugPrintln(2, "Test Command 3");
      samplePeriod = samplePeriod * 10;
      debugPrintln(2, "Set Sample Period to " + samplePeriod);
      break;
  } 
}

void draw()
{
  scope.draw();
}