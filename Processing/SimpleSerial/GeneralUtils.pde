int debug = 3;

void debugPrint(int priority, String msg) {
  if (debug >= priority) {
    print(msg);
  }
}
void debugPrintln(int priority, String msg) {
  if (debug >= priority) {
    print(msg+"\n");
  }
}