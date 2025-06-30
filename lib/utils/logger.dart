import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'DEBUG');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'INFO');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'WARNING');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(message,
          name: 'ERROR', error: error, stackTrace: stackTrace);
    }
  }

  static void api(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'API');
    }
  }

  // Safe logging that can be used during build
  static void safeLog(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      // Use a microtask to avoid build context issues
      Future.microtask(() {
        developer.log(message, name: level);
      });
    }
  }
}
