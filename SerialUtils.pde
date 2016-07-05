import processing.serial.*;

class SerialConnection {
  String name = null;
  Serial port;
  int defaultWaitTime = 10000;
  PApplet parent;
  String[] list;

  SerialConnection(PApplet parent) {
    this.name = null; //<>//
    this.parent = parent; //<>//
    this.port = null;
    this.list = Serial.list();
  }

  boolean openPort(String portName) {
    try {
      this.port = new Serial(this.parent, portName, 115200);
      if (this.port != null) {
        this.port.clear();
        this.name = portName;
      }
      return true;
    } 
    catch (Exception e) {
      return false;
    }
  }
  
  String[] getPorts() {
    return this.list;
  }
  

  void writeInt(int value) {
    this.port.write(value>>8);
    this.port.write(value);
  }

  int readInt() {
    return readIntWithTimeout(defaultWaitTime);
  }

  int readIntWithTimeout(int timeOut) {
    int value = readIntRaw();
    int waited = 0;
    while (value == -1) {
      delay(1);
      value = readIntRaw();
      ++waited;
      if (waited >= timeOut) {
        break;
      }
    }
    return value;
  }

  int readByte() {
    int val1 = port.read();
    return val1;
  }

  void clear() {
    this.port.clear();
  }


  int readIntRaw() {
    int val1 = port.read();  
    int val2 = port.read();
    int retval = (val1 << 8) | val2;
    return retval;
  }

  boolean checkAckLog() {
    boolean retval = false;
    if (checkAck()) {
      debugPrintln(2, "Command OK");
      retval = true;
    } else {
      debugPrintln(2, "** Ack Failed");
    }
    return retval;
  }

  boolean checkAck() 
  {
    int ack = readInt();
    if (ack == 5678) {
      return true;
    } else {
      return false;
    }
  }

  void startCmd(int cmd)
  {
    this.writeInt(1234);
    this.writeInt(cmd);
  }
}