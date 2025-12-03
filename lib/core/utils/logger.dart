import 'dart:developer' as developer;

/// Logging service for the application
class AppLogger {
  static const String _name = 'Otfha';
  
  /// Log debug message
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log info message
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log warning message
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log network request
  static void logRequest(String method, String url, {Map<String, dynamic>? data}) {
    debug(
      'HTTP $method: $url${data != null ? '\nData: $data' : ''}',
      tag: 'Network',
    );
  }
  
  /// Log network response
  static void logResponse(int statusCode, String url, {dynamic data}) {
    debug(
      'HTTP Response: $statusCode - $url${data != null ? '\nData: $data' : ''}',
      tag: 'Network',
    );
  }
  
  /// Log authentication events
  static void logAuth(String event, {String? userId}) {
    info(
      'Auth: $event${userId != null ? ' (User: $userId)' : ''}',
      tag: 'Auth',
    );
  }
  
  /// Log navigation events
  static void logNavigation(String from, String to) {
    debug(
      'Navigation: $from -> $to',
      tag: 'Navigation',
    );
  }
  
  /// Log database operations
  static void logDatabase(String operation, String collection, {String? docId}) {
    debug(
      'Database: $operation on $collection${docId != null ? '/$docId' : ''}',
      tag: 'Database',
    );
  }
}



