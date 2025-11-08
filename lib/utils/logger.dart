import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// A singleton class for structured logging with file, method, and line tracking.
class AppLogger {
  // Private constructor
  AppLogger._internal();

  /// The single instance of [AppLogger].
  static final AppLogger instance = AppLogger._internal();

  /// Logger instance with custom settings.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to display
      errorMethodCount: 8, // Number of method calls for errors
      lineLength: 90, // Maximum line length
      colors: false, // Use colors for logs
      printEmojis: true, // Print emojis for log levels
      dateTimeFormat: DateTimeFormat.none, // Print timestamp
      noBoxingByDefault: false, // Keep default boxing behavior
    ),
  );

  /// Logs a debug message (only in debug mode).
  void debug(dynamic message) {
    if (kDebugMode) {
      _logger.d(_formatMessage(message));
    }
  }

  /// Logs an informational message.
  void info(dynamic message) {
    _logger.i(_formatMessage(message));
  }

  /// Logs a warning message and sends it to Firebase Crashlytics.
  void warning(dynamic message) {
    final formattedMessage = _formatMessage(message);
    _logger.w(formattedMessage);
    // FirebaseCrashlytics.instance.log("[WARNING] $formattedMessage");
  }

  /// Logs an error message with optional stack trace and sends it to Firebase Crashlytics.
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final formattedMessage = _formatMessage(message);
    _logger.e(formattedMessage, error: error, stackTrace: stackTrace);
    // FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace);
  }

  /// Logs a critical fatal error (for unrecoverable crashes) and sends to Firebase Crashlytics.
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final formattedMessage = _formatMessage(message);
    _logger.f(formattedMessage, error: error, stackTrace: stackTrace);
    // FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace, fatal: true);
  }

  /// Formats the message to include timestamp, file name, method, and line number.
  String _formatMessage(String message) {
    final logDetails = _getLogOrigin();
    // return "${DateTime.now()} | ${logDetails["file"]}:${logDetails["line"]} (${logDetails["method"]}) \n${_sanitizeMessage(message)}";
    return "${DateTime.now()} | ${_getDebugMethodName().toUpperCase()} | ${logDetails["file"]}:${logDetails["line"]} | ${logDetails["method"]} \n${_sanitizeMessage(message)}";
  }

  /// Extracts file name, method name, and line nupmber from the stack trace.
  Map<String, String> _getLogOrigin() {
    try {
      final stackTrace = StackTrace.current.toString().split("\n")[3]; // Skip the logger function itself
      final regex = RegExp(r'^(.*) \((.*):(\d+):\d+\)$');
      final match = regex.firstMatch(stackTrace);
      if (match != null) {
        return {
          // Get the method name from the stack trace
          "method": match.group(1)?.substring(match.group(1)?.lastIndexOf(" ") ?? 0, match.group(1)?.length ?? 0).trim() ?? "UnknownMethod",
          "file": match.group(2)?.split('/').last ?? "UnknownFile",
          "line": match.group(3) ?? "0",
        };
      }
    } catch (_) {
      return {"method": "Unknown", "file": "Unknown", "line": "0"};
    }
    return {"method": "Unknown", "file": "Unknown", "line": "0"};
  }

  // Get the method name from the stack trace
  String _getDebugMethodName() {
    try {
      final stackTrace = StackTrace.current.toString().split("\n")[2];
      final regex = RegExp(r'#\d+\s+(\S+)\s');
      final match = regex.firstMatch(stackTrace);
      if (match != null) {
        return match.group(1) ?? "UnknownMethod";
      }
    } catch (_) {
      return "UnknownMethod";
    }
    return "UnknownMethod";
  }

  /// Sanitizes messages to prevent logging sensitive information.
  String _sanitizeMessage(String message) {
    return message.replaceAll(RegExp(r'(password|token|apikey|secret|key):\s*\S+'), '****');
  }
}

/// Global logger instance for easy access.
final logger = AppLogger.instance;

/// Pretty Dio Logger instance for easy access.
final dioLogger = PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: true, compact: true);
