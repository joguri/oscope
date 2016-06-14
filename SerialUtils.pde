import processing.serial.*;

class SerialConnection {
  String name;
  Serial port;
  int defaultWaitTime = 10000;
  PApplet parent;

  SerialConnection(PApplet parent, String name) {
    this.name = name;
    this.parent = parent;
  }

  boolean openPort() {
    try {
      this.port = new Serial(this.parent, this.name, 115200);
      if (this.port != null) {
        this.port.clear();
      }
      return true;
    } 
    catch (Exception e) {
      return false;
    }
  }

  void writeInt(int value) {
    this.port.write(value>>8); //<>//
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
      debugPrintln(2, "** Test Failed");
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
}