class LogUtil {
  static bool debug = false;
  static void d(String msg, {Object? error, StackTrace? stackTrace}) {
    if (debug) {
      // ignore: avoid_print
      print(msg);
      if (error != null) {
        // ignore: avoid_print
        print('Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void i(String msg, {Object? error, StackTrace? stackTrace}) {
    if (debug) {
      // ignore: avoid_print
      print(msg);
      if (error != null) {
        // ignore: avoid_print
        print('Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void e(String msg, {Object? error, StackTrace? stackTrace}) {
    // ignore: avoid_print
    print(msg);
    if (error != null) {
      // ignore: avoid_print
      print('Error: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('StackTrace: $stackTrace');
    }
  }

  static void w(String msg, {Object? error, StackTrace? stackTrace}) {
    // ignore: avoid_print
    print(msg);
    if (error != null) {
      // ignore: avoid_print
      print('Error: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('StackTrace: $stackTrace');
    }
  }
}
