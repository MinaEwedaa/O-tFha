import 'package:flutter_test/flutter_test.dart';
import 'package:otfha/core/utils/formatters.dart';

// Note: test_helpers.dart is available for future use with DateTime fixtures

/// Unit tests for the Formatters class
/// 
/// These tests cover all formatting functions including:
/// - Date/time formatting (formatDate, formatShortDate, formatTime, etc.)
/// - Currency formatting (formatCurrency, formatCompactCurrency)
/// - Number formatting (formatNumber, formatPercentage)
/// - Text formatting (capitalize, capitalizeWords, truncate)
/// - Utility formatting (formatFileSize, formatDuration, formatPhoneNumber)
/// 
/// Test Count: 50 tests
void main() {
  // ============================================================
  // Formatters.formatDate Tests
  // ============================================================
  group('Formatters.formatDate', () {
    test('should format date as "MMM dd, yyyy"', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      
      // Act
      final result = Formatters.formatDate(date);
      
      // Assert
      expect(result, 'Jan 15, 2024');
    });

    test('should handle different months correctly', () {
      expect(Formatters.formatDate(DateTime(2024, 6, 1)), 'Jun 01, 2024');
      expect(Formatters.formatDate(DateTime(2024, 12, 25)), 'Dec 25, 2024');
    });

    test('should handle single digit days with leading zero', () {
      final date = DateTime(2024, 3, 5);
      final result = Formatters.formatDate(date);
      expect(result, 'Mar 05, 2024');
    });
  });

  // ============================================================
  // Formatters.formatShortDate Tests
  // ============================================================
  group('Formatters.formatShortDate', () {
    test('should format date as "dd/MM/yyyy"', () {
      final date = DateTime(2024, 1, 15);
      final result = Formatters.formatShortDate(date);
      expect(result, '15/01/2024');
    });

    test('should include leading zeros for single digit day and month', () {
      final date = DateTime(2024, 3, 5);
      final result = Formatters.formatShortDate(date);
      expect(result, '05/03/2024');
    });
  });

  // ============================================================
  // Formatters.formatTime Tests
  // ============================================================
  group('Formatters.formatTime', () {
    test('should format time as "hh:mm a" in AM', () {
      final date = DateTime(2024, 1, 15, 9, 30);
      final result = Formatters.formatTime(date);
      expect(result, '09:30 AM');
    });

    test('should format time as "hh:mm a" in PM', () {
      final date = DateTime(2024, 1, 15, 14, 45);
      final result = Formatters.formatTime(date);
      expect(result, '02:45 PM');
    });

    test('should handle midnight correctly', () {
      final date = DateTime(2024, 1, 15, 0, 0);
      final result = Formatters.formatTime(date);
      expect(result, '12:00 AM');
    });
  });

  // ============================================================
  // Formatters.formatDateTime Tests
  // ============================================================
  group('Formatters.formatDateTime', () {
    test('should format as "MMM dd, yyyy at hh:mm a"', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final result = Formatters.formatDateTime(date);
      expect(result, 'Jan 15, 2024 at 02:30 PM');
    });

    test('should handle AM time correctly', () {
      final date = DateTime(2024, 6, 20, 9, 15);
      final result = Formatters.formatDateTime(date);
      expect(result, 'Jun 20, 2024 at 09:15 AM');
    });
  });

  // ============================================================
  // Formatters.formatRelativeTime Tests
  // ============================================================
  group('Formatters.formatRelativeTime', () {
    test('should return "Just now" for less than 60 seconds ago', () {
      final date = DateTime.now().subtract(const Duration(seconds: 30));
      final result = Formatters.formatRelativeTime(date);
      expect(result, 'Just now');
    });

    test('should return "1 minute ago" for exactly 1 minute', () {
      final date = DateTime.now().subtract(const Duration(minutes: 1));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '1 minute ago');
    });

    test('should return "X minutes ago" for less than 60 minutes', () {
      final date = DateTime.now().subtract(const Duration(minutes: 45));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '45 minutes ago');
    });

    test('should return "1 hour ago" for exactly 1 hour', () {
      final date = DateTime.now().subtract(const Duration(hours: 1));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '1 hour ago');
    });

    test('should return "X hours ago" for less than 24 hours', () {
      final date = DateTime.now().subtract(const Duration(hours: 5));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '5 hours ago');
    });

    test('should return "1 day ago" for exactly 1 day', () {
      final date = DateTime.now().subtract(const Duration(days: 1));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '1 day ago');
    });

    test('should return "X days ago" for less than 7 days', () {
      final date = DateTime.now().subtract(const Duration(days: 5));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '5 days ago');
    });

    test('should return "X weeks ago" for less than 30 days', () {
      final date = DateTime.now().subtract(const Duration(days: 14));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '2 weeks ago');
    });

    test('should return "X months ago" for less than 365 days', () {
      final date = DateTime.now().subtract(const Duration(days: 60));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '2 months ago');
    });

    test('should return "X years ago" for 365+ days', () {
      final date = DateTime.now().subtract(const Duration(days: 730));
      final result = Formatters.formatRelativeTime(date);
      expect(result, '2 years ago');
    });
  });

  // ============================================================
  // Formatters.formatCurrency Tests
  // ============================================================
  group('Formatters.formatCurrency', () {
    test('should format with dollar symbol by default', () {
      final result = Formatters.formatCurrency(1234.56);
      expect(result, contains('\$'));
      expect(result, contains('1,234.56'));
    });

    test('should include exactly 2 decimal places', () {
      final result = Formatters.formatCurrency(100.0);
      expect(result, contains('.00'));
    });

    test('should add thousand separators', () {
      final result = Formatters.formatCurrency(1234567.89);
      expect(result, contains('1,234,567.89'));
    });

    test('should use custom currency symbol', () {
      final result = Formatters.formatCurrency(100.0, symbol: '€');
      expect(result, contains('€'));
    });

    test('should handle zero correctly', () {
      final result = Formatters.formatCurrency(0);
      expect(result, contains('0.00'));
    });

    test('should handle negative values', () {
      final result = Formatters.formatCurrency(-500.0);
      expect(result, contains('-'));
      expect(result, contains('500.00'));
    });
  });

  // ============================================================
  // Formatters.formatCompactCurrency Tests
  // ============================================================
  group('Formatters.formatCompactCurrency', () {
    test('should return full format for amount less than 1000', () {
      final result = Formatters.formatCompactCurrency(500.0);
      expect(result, contains('500'));
      expect(result.contains('K'), isFalse);
    });

    test('should return K format for amount >= 1000', () {
      final result = Formatters.formatCompactCurrency(1500.0);
      expect(result, '\$1.5K');
    });

    test('should return M format for amount >= 1,000,000', () {
      final result = Formatters.formatCompactCurrency(2500000.0);
      expect(result, '\$2.5M');
    });

    test('should use custom symbol', () {
      final result = Formatters.formatCompactCurrency(5000.0, symbol: '£');
      expect(result, '£5.0K');
    });
  });

  // ============================================================
  // Formatters.formatNumber Tests
  // ============================================================
  group('Formatters.formatNumber', () {
    test('should add thousand separators', () {
      final result = Formatters.formatNumber(1234567);
      expect(result, '1,234,567');
    });

    test('should respect decimal places parameter', () {
      final result = Formatters.formatNumber(1234.5678, decimals: 2);
      expect(result, contains('1,234.57'));
    });

    test('should have zero decimals by default', () {
      final result = Formatters.formatNumber(1234.5678);
      expect(result, '1,235'); // Rounded
    });

    test('should handle small numbers without separators', () {
      final result = Formatters.formatNumber(123);
      expect(result, '123');
    });
  });

  // ============================================================
  // Formatters.formatPercentage Tests
  // ============================================================
  group('Formatters.formatPercentage', () {
    test('should append percent symbol', () {
      final result = Formatters.formatPercentage(75.5);
      expect(result, '75.5%');
    });

    test('should respect decimal places parameter', () {
      final result = Formatters.formatPercentage(33.3333, decimals: 2);
      expect(result, '33.33%');
    });

    test('should default to 1 decimal place', () {
      final result = Formatters.formatPercentage(50.0);
      expect(result, '50.0%');
    });
  });

  // ============================================================
  // Formatters.formatFileSize Tests
  // ============================================================
  group('Formatters.formatFileSize', () {
    test('should return bytes for values less than 1024', () {
      final result = Formatters.formatFileSize(500);
      expect(result, '500 B');
    });

    test('should return KB for values >= 1024', () {
      final result = Formatters.formatFileSize(2048);
      expect(result, '2.0 KB');
    });

    test('should return MB for values >= 1024 * 1024', () {
      final result = Formatters.formatFileSize(1048576); // 1 MB
      expect(result, '1.0 MB');
    });

    test('should return GB for values >= 1024 * 1024 * 1024', () {
      final result = Formatters.formatFileSize(1073741824); // 1 GB
      expect(result, '1.0 GB');
    });

    test('should handle exact boundary values', () {
      expect(Formatters.formatFileSize(1023), '1023 B');
      expect(Formatters.formatFileSize(1024), '1.0 KB');
    });
  });

  // ============================================================
  // Formatters.formatDuration Tests
  // ============================================================
  group('Formatters.formatDuration', () {
    test('should format days', () {
      final result = Formatters.formatDuration(const Duration(days: 2));
      expect(result, '2 days');
    });

    test('should format single day with singular form', () {
      final result = Formatters.formatDuration(const Duration(days: 1));
      expect(result, '1 day');
    });

    test('should format hours', () {
      final result = Formatters.formatDuration(const Duration(hours: 5));
      expect(result, '5 hours');
    });

    test('should format hours with minutes', () {
      final result = Formatters.formatDuration(
        const Duration(hours: 2, minutes: 30),
      );
      expect(result, '2 hours 30 minutes');
    });

    test('should format minutes only', () {
      final result = Formatters.formatDuration(const Duration(minutes: 45));
      expect(result, '45 minutes');
    });

    test('should format seconds for short durations', () {
      final result = Formatters.formatDuration(const Duration(seconds: 30));
      expect(result, '30 seconds');
    });

    test('should use singular form for 1 unit', () {
      expect(
        Formatters.formatDuration(const Duration(hours: 1)),
        '1 hour',
      );
      expect(
        Formatters.formatDuration(const Duration(minutes: 1)),
        '1 minute',
      );
      expect(
        Formatters.formatDuration(const Duration(seconds: 1)),
        '1 second',
      );
    });
  });

  // ============================================================
  // Formatters.formatPhoneNumber Tests
  // ============================================================
  group('Formatters.formatPhoneNumber', () {
    test('should format 10-digit US phone number', () {
      final result = Formatters.formatPhoneNumber('5551234567');
      expect(result, '(555) 123-4567');
    });

    test('should format international number with + prefix', () {
      final result = Formatters.formatPhoneNumber('+15551234567');
      expect(result, contains('555'));
      expect(result, contains('123'));
      expect(result, contains('4567'));
    });

    test('should strip non-numeric characters before formatting', () {
      final result = Formatters.formatPhoneNumber('555-123-4567');
      expect(result, '(555) 123-4567');
    });

    test('should return original if format not recognized', () {
      final result = Formatters.formatPhoneNumber('12345');
      expect(result, '12345');
    });
  });

  // ============================================================
  // Formatters.capitalize Tests
  // ============================================================
  group('Formatters.capitalize', () {
    test('should capitalize first letter', () {
      final result = Formatters.capitalize('hello');
      expect(result, 'Hello');
    });

    test('should lowercase the rest of the string', () {
      final result = Formatters.capitalize('hELLO');
      expect(result, 'Hello');
    });

    test('should handle empty string', () {
      final result = Formatters.capitalize('');
      expect(result, '');
    });

    test('should handle single character', () {
      final result = Formatters.capitalize('a');
      expect(result, 'A');
    });
  });

  // ============================================================
  // Formatters.capitalizeWords Tests
  // ============================================================
  group('Formatters.capitalizeWords', () {
    test('should capitalize first letter of each word', () {
      final result = Formatters.capitalizeWords('hello world');
      expect(result, 'Hello World');
    });

    test('should handle multiple words', () {
      final result = Formatters.capitalizeWords('the quick brown fox');
      expect(result, 'The Quick Brown Fox');
    });

    test('should handle empty string', () {
      final result = Formatters.capitalizeWords('');
      expect(result, '');
    });
  });

  // ============================================================
  // Formatters.truncate Tests
  // ============================================================
  group('Formatters.truncate', () {
    test('should not truncate if text is within limit', () {
      final result = Formatters.truncate('Hello', 10);
      expect(result, 'Hello');
    });

    test('should truncate and add ellipsis for long text', () {
      final result = Formatters.truncate('Hello World', 8);
      expect(result, 'Hello...');
      expect(result.length, 8);
    });

    test('should use custom ellipsis', () {
      final result = Formatters.truncate('Hello World', 9, ellipsis: '…');
      expect(result, 'Hello Wo…');
    });

    test('should handle exact length boundary', () {
      final result = Formatters.truncate('Hello', 5);
      expect(result, 'Hello');
    });
  });

  // ============================================================
  // Formatters.formatList Tests
  // ============================================================
  group('Formatters.formatList', () {
    test('should return empty string for empty list', () {
      final result = Formatters.formatList([]);
      expect(result, '');
    });

    test('should return single item as-is', () {
      final result = Formatters.formatList(['Apple']);
      expect(result, 'Apple');
    });

    test('should join multiple items with comma separator', () {
      final result = Formatters.formatList(['Apple', 'Banana', 'Cherry']);
      expect(result, 'Apple, Banana, Cherry');
    });

    test('should use custom separator', () {
      final result = Formatters.formatList(
        ['Apple', 'Banana', 'Cherry'],
        separator: ' | ',
      );
      expect(result, 'Apple | Banana | Cherry');
    });

    test('should use lastSeparator before final item', () {
      final result = Formatters.formatList(
        ['Apple', 'Banana', 'Cherry'],
        lastSeparator: ' and ',
      );
      expect(result, 'Apple, Banana and Cherry');
    });
  });

  // ============================================================
  // Edge Cases
  // ============================================================
  group('Edge Cases', () {
    test('should handle very large currency values', () {
      final result = Formatters.formatCurrency(999999999.99);
      expect(result, contains('999,999,999.99'));
    });

    test('should handle very small decimal values', () {
      final result = Formatters.formatCurrency(0.01);
      expect(result, contains('0.01'));
    });

    test('should handle 100% percentage', () {
      final result = Formatters.formatPercentage(100.0);
      expect(result, '100.0%');
    });

    test('should handle percentage over 100', () {
      final result = Formatters.formatPercentage(150.0);
      expect(result, '150.0%');
    });

    test('should handle truncate with very short maxLength', () {
      final result = Formatters.truncate('Hello World', 5);
      expect(result, 'He...');
    });
  });
}

