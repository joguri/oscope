int readInt() {
  int val1 = Serial.read();
  int val2 = Serial.read();
  return (val1 << 8) | val2;
}

void writeByte(char value) {
  Serial.write( value );
}

void writeInt(int value) {
  Serial.write( (value >> 8) );
  Serial.write( value );
}

boolean waitForSerialAvailable(int count)
{
  while(Serial.available() < count) {
    ;
  }
  return true;
}

