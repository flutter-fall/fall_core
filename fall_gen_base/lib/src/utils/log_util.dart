class LogUtil {
  static bool debug = false;
  static void d(String msg) {
    if (debug) {
      // ignore: avoid_print
      print(msg);
    }
  }
}
