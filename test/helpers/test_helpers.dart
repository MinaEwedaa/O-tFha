/// Test helper utilities for OTFHA unit tests
/// 
/// This file contains shared utilities, fixtures, and helpers
/// used across multiple test files.

/// Returns a fixed DateTime for deterministic testing
/// Using January 15, 2024 at 10:30:45 AM
DateTime fixedDateTime() {
  return DateTime(2024, 1, 15, 10, 30, 45);
}

/// Returns a DateTime representing "just now" (less than 60 seconds ago)
DateTime justNowDateTime() {
  return DateTime.now().subtract(const Duration(seconds: 30));
}

/// Returns a DateTime representing X minutes ago
DateTime minutesAgoDateTime(int minutes) {
  return DateTime.now().subtract(Duration(minutes: minutes));
}

/// Returns a DateTime representing X hours ago
DateTime hoursAgoDateTime(int hours) {
  return DateTime.now().subtract(Duration(hours: hours));
}

/// Returns a DateTime representing X days ago
DateTime daysAgoDateTime(int days) {
  return DateTime.now().subtract(Duration(days: days));
}

/// Returns a DateTime representing X weeks ago
DateTime weeksAgoDateTime(int weeks) {
  return DateTime.now().subtract(Duration(days: weeks * 7));
}

/// Returns a DateTime representing X months ago (approximate)
DateTime monthsAgoDateTime(int months) {
  return DateTime.now().subtract(Duration(days: months * 30));
}

/// Returns a DateTime representing X years ago (approximate)
DateTime yearsAgoDateTime(int years) {
  return DateTime.now().subtract(Duration(days: years * 365));
}

/// Valid email addresses for testing
class ValidEmails {
  static const simple = 'test@example.com';
  static const withSubdomain = 'user@mail.example.com';
  static const withPlus = 'user+tag@example.com';
  static const withNumbers = 'user123@example.com';
  static const withDots = 'first.last@example.com';
  static const withUnderscore = 'first_last@example.com';
  
  static const List<String> all = [
    simple,
    withSubdomain,
    withPlus,
    withNumbers,
    withDots,
    withUnderscore,
  ];
}

/// Invalid email addresses for testing
class InvalidEmails {
  static const noAt = 'testexample.com';
  static const noDomain = 'test@';
  static const noUser = '@example.com';
  static const noExtension = 'test@example';
  static const spaceInMiddle = 'test @example.com';
  static const doubleAt = 'test@@example.com';
  static const justText = 'notanemail';
  
  static const List<String> all = [
    noAt,
    noDomain,
    noUser,
    noExtension,
    spaceInMiddle,
    doubleAt,
    justText,
  ];
}

/// Valid phone numbers for testing
class ValidPhoneNumbers {
  static const us10Digit = '5551234567';
  static const usFormatted = '555-123-4567';
  static const usWithSpaces = '555 123 4567';
  static const international = '+15551234567';
  static const internationalSpaces = '+1 555 123 4567';
  
  static const List<String> all = [
    us10Digit,
    usFormatted,
    usWithSpaces,
    international,
    internationalSpaces,
  ];
}

/// Invalid phone numbers for testing
class InvalidPhoneNumbers {
  static const tooShort = '12345';
  static const letters = 'abcdefghij';
  static const mixed = '555-abc-1234';
  
  static const List<String> all = [
    tooShort,
    letters,
    mixed,
  ];
}

/// Valid URLs for testing
class ValidUrls {
  static const http = 'http://example.com';
  static const https = 'https://example.com';
  static const withPath = 'https://example.com/path/to/page';
  static const withQuery = 'https://example.com?query=value';
  static const withPort = 'https://example.com:8080';
  static const withSubdomain = 'https://www.example.com';
  
  static const List<String> all = [
    http,
    https,
    withPath,
    withQuery,
    withPort,
    withSubdomain,
  ];
}

/// Invalid URLs for testing
class InvalidUrls {
  static const noProtocol = 'example.com';
  static const invalidProtocol = 'ftp://example.com';
  static const noTld = 'https://example';
  static const justText = 'not a url';
  
  static const List<String> all = [
    noProtocol,
    invalidProtocol,
    noTld,
    justText,
  ];
}





