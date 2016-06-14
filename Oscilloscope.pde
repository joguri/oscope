
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
    values = new int[500];
  }

  int[] getValue() { //<>//
    int val = 0;
    int incr = 3;
    for (int i=0; i<500; ++i) {
      if (val > 940) {
        incr = -6;
      } else if (val < 370) {
        incr = 8;
      }
      val += incr;
      
      values[i] = val;
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
    stroke(255); //<>//

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
      values = getValue();
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

    int[] results = getValue();
    if (results == null) {
      msg.Draw();
      return;
    }
  }
  
  void draw()
  {
    background(bgImage); //<>//
    drawGrid();
    if (port == null && !demoMode) {
      drawButtons();
      return;
    }

    values = getValue();
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

    int[] results = getValue();
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
}