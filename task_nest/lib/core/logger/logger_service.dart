import 'package:flutter/foundation.dart';

class LoggerService {
  const LoggerService();

  void info(String message) {
    if (kDebugMode) {
      print('[INFO]: $message');
    }
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[ERROR]: $message');
    }
    if (error != null) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
    if (stackTrace != null) {
      if (kDebugMode) {
        print(stackTrace);
      }
    }
  }
}
