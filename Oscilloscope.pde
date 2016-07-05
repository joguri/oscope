//<>// //<>// //<>//
class Oscilloscope {

  PImage bgImage;
  int xOff = 300;
  int yOff=40;
  int voltageRef = 5;
  float zoom = 1.0f;
  int screenWidth = 880;
  int screenHeight = 480;
  SerialConnection port = null;
  boolean demoMode=true;
  Button[] buttons;
  Label msg = new Label("Waiting for input ...", 30, 30, 300, 20);
  int stop;
  boolean active = false;
  int[] values;

  Oscilloscope(SerialConnection port) {
    this.port = port;
    bgImage = loadImage("OscilloscopeBackground.png");
  }

  void draw()
  {
    background(bgImage);
    drawGrid();

    if (port == null && !demoMode) {
      drawButtons();
      return;
    }

    values = getValues();
    if (values.length < 1) {
      return;
    }
    drawLine(values);

    if (demoMode) {
      return;
    }

    if (stop == 1 && active == false) {
      return;
    }

    if (active == false) {
      port.writeInt(1234);
      port.writeInt(30);
      active = true;
    }

    int[] results = getValues();
    if (results == null) {
      msg.Draw();
      return;
    }

    boolean ack = port.checkAck();
    if (ack) {
      values = results;
    }
    active = false;
  }

  boolean promptForPorts()
  {
    String[] ports = port.getPorts();
    boolean ok = false;
    if (ports.length == 0) {
      print("ERROR: NO .PORTS AVAILABLE");
    } else if (ports.length == 1) {
      ok = this.port.openPort(ports[0]);
    } else {
      buttons = new Button[ports.length+1];
      for (int i=0; i<ports.length; ++i) {
        println("    [" + nf(i) + "]: " + ports[i]);
        buttons[i] = new Button(ports[i], 20, (i*25)+30, 250, 20);
      }
      int indx = ports.length;
      buttons[indx] = new Button("Demo Mode", 20, (indx*25)+30, 250, 20);
    }
    return ok;
  }

  int[] getValues() 
  {
    port.startCmd(30);
    values = new int[sampleSize];

    for (int i=0; i<sampleSize; ++i) {
      values[i] = port.readInt();
      if (values[1] == -1) {
        print('x');
      } else {
        if (i %20 == 0) {
          print('.');
        }
      }
    }
    boolean ack = port.checkAckLog();
    if (!ack) {
      debugPrintln(2, "Ack Failed, resetting serial port");
      port.clear();
    }
    return values;
  }

  void offLine(int x0, int y0, int x1, int y1) 
  {
    line(x0+xOff, y0+yOff, x1+xOff, y1+yOff);
  }

  void offText(String line, int x, int y) 
  {
    text(line, x+xOff, y + yOff);
  }

  void drawGrid() {
    int chop = voltageRef;
    int chunk = screenHeight/chop;
    stroke(50, 150, 50);

    // Horizontal Lines and Voltage Labels
    for (int i=0; i<=chop; ++i) {
      int place = chunk * i;
      fill(255, 255, 255);
      if (chop-i!=0) {
        offText((chop-i) + "V", 20, place-15);
      }
      offLine(0, place, screenWidth, place);
    }

    // Veritical Lines and tick marks
    chunk = 50;
    chop = screenWidth/50;
    fill(0, 155, 0);
    offText((chunk*(samplePeriod/1000.)) + " ms/div", 105, 460); 
    for (int i=0; i<=chop; ++i) {
      int place = chunk * i;
      offLine(place, 0, place, screenHeight);
      for (int j=0; j<50; ++j) {
        int pp = ((j*screenHeight)/50);
        offLine(place-2, pp, place+2, pp);
      }
    }
  }

  int getY(int val) {
    return (int)(screenHeight - val / 1023.0f * (screenHeight - 1));
  }

  void drawButtons() 
  {
    fill(255, 255, 255);
    textAlign(LEFT);
    text("Select Arduino Serial Port:", 20, 20);

    textAlign(CENTER);
    for (int i=0; i<buttons.length; ++i) {
      buttons[i].Draw();
    }
  }

  void drawLine(int[] valuesx) {
    stroke(255);

    int displayWidth = (int) (screenWidth / zoom);

    int vLen = valuesx.length;
    int k = 0;
    if (vLen > displayWidth) {
      k = displayWidth;
    } else {
      k = vLen;
    }

    if (k < 1) {
      return;
    }

    int x0 = 0;
    int y0 = getY(valuesx[0]);
    for (int i=1; i<k; i++) {
      int x1 = i;
      int y1 = getY(valuesx[i]+1);
      offLine(x0, y0, x1, y1);
      x0 = x1;
      y0 = y1;
    }
  }

  void scopeDraw() {
    background(bgImage);
    drawGrid();
    if (port == null && !demoMode) {
      drawButtons();
      return;
    }

    if (demoMode) {
      int foo[]  =  {1, 2, 3, 4, 5, 6, 7}; // getValue();
      values = foo;
      drawLine(values);
    }

    drawLine(values);

    if (stop == 1 && active == false) {
      return;
    }

    if (active == false) {
      port.writeInt(1234);
      port.writeInt(30);
      active = true;
    }

    int[] results = getValues();
    if (results == null) {
      msg.Draw();
      return;
    }
  }
}