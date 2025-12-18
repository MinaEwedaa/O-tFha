import 'package:flutter_test/flutter_test.dart';
import 'package:otfha/core/utils/validators.dart';
import '../../../helpers/test_helpers.dart';

/// Unit tests for the Validators class
/// 
/// These tests cover all validation functions including:
/// - required, email, password, confirmPassword
/// - phoneNumber, number, positiveNumber
/// - min, max, minLength, maxLength
/// - date, url, combine
/// 
/// Test Count: 58 tests
void main() {
  // ============================================================
  // Validators.required Tests
  // ============================================================
  group('Validators.required', () {
    test('should return error for null value', () {
      // Arrange
      const String? value = null;
      
      // Act
      final result = Validators.required(value);
      
      // Assert
      expect(result, isNotNull);
      expect(result, contains('is required'));
    });

    test('should return error for empty string', () {
      // Arrange
      const value = '';
      
      // Act
      final result = Validators.required(value);
      
      // Assert
      expect(result, isNotNull);
      expect(result, contains('is required'));
    });

    test('should return error for whitespace only string', () {
      // Arrange
      const value = '   ';
      
      // Act
      final result = Validators.required(value);
      
      // Assert
      expect(result, isNotNull);
      expect(result, contains('is required'));
    });

    test('should return null for valid non-empty string', () {
      // Arrange
      const value = 'valid input';
      
      // Act
      final result = Validators.required(value);
      
      // Assert
      expect(result, isNull);
    });

    test('should use custom fieldName in error message', () {
      // Arrange
      const String? value = null;
      const fieldName = 'Username';
      
      // Act
      final result = Validators.required(value, fieldName: fieldName);
      
      // Assert
      expect(result, 'Username is required');
    });

    test('should use default fieldName when not provided', () {
      // Arrange
      const String? value = null;
      
      // Act
      final result = Validators.required(value);
      
      // Assert
      expect(result, 'This field is required');
    });
  });

  // ============================================================
  // Validators.email Tests
  // ============================================================
  group('Validators.email', () {
    test('should return error for null email', () {
      final result = Validators.email(null);
      expect(result, isNotNull);
      expect(result, 'Email is required');
    });

    test('should return error for empty email', () {
      final result = Validators.email('');
      expect(result, isNotNull);
      expect(result, 'Email is required');
    });

    test('should return error for email without @', () {
      final result = Validators.email(InvalidEmails.noAt);
      expect(result, isNotNull);
      expect(result, 'Please enter a valid email');
    });

    test('should return error for email without domain', () {
      final result = Validators.email(InvalidEmails.noDomain);
      expect(result, isNotNull);
    });

    test('should return error for email without user', () {
      final result = Validators.email(InvalidEmails.noUser);
      expect(result, isNotNull);
    });

    test('should return error for email without extension', () {
      final result = Validators.email(InvalidEmails.noExtension);
      expect(result, isNotNull);
    });

    test('should return null for valid simple email', () {
      final result = Validators.email(ValidEmails.simple);
      expect(result, isNull);
    });

    test('should return null for email with subdomain', () {
      final result = Validators.email(ValidEmails.withSubdomain);
      expect(result, isNull);
    });

    test('should return null for email with plus sign', () {
      final result = Validators.email(ValidEmails.withPlus);
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.password Tests
  // ============================================================
  group('Validators.password', () {
    test('should return error for null password', () {
      final result = Validators.password(null);
      expect(result, isNotNull);
      expect(result, 'Password is required');
    });

    test('should return error for empty password', () {
      final result = Validators.password('');
      expect(result, isNotNull);
      expect(result, 'Password is required');
    });

    test('should return error for password shorter than 6 characters', () {
      final result = Validators.password('12345');
      expect(result, isNotNull);
      expect(result, contains('at least 6 characters'));
    });

    test('should return null for password with exactly 6 characters', () {
      final result = Validators.password('123456');
      expect(result, isNull);
    });

    test('should return null for password longer than 6 characters', () {
      final result = Validators.password('password123');
      expect(result, isNull);
    });

    test('should respect custom minLength parameter', () {
      // Should fail with minLength of 10
      final resultFail = Validators.password('12345678', minLength: 10);
      expect(resultFail, isNotNull);
      expect(resultFail, contains('at least 10 characters'));
      
      // Should pass with minLength of 10
      final resultPass = Validators.password('1234567890', minLength: 10);
      expect(resultPass, isNull);
    });
  });

  // ============================================================
  // Validators.confirmPassword Tests
  // ============================================================
  group('Validators.confirmPassword', () {
    test('should return error for null confirmation', () {
      final result = Validators.confirmPassword(null, 'password123');
      expect(result, isNotNull);
      expect(result, 'Please confirm your password');
    });

    test('should return error for empty confirmation', () {
      final result = Validators.confirmPassword('', 'password123');
      expect(result, isNotNull);
      expect(result, 'Please confirm your password');
    });

    test('should return error when passwords do not match', () {
      final result = Validators.confirmPassword('password123', 'password456');
      expect(result, isNotNull);
      expect(result, 'Passwords do not match');
    });

    test('should return null when passwords match', () {
      final result = Validators.confirmPassword('password123', 'password123');
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.phoneNumber Tests
  // ============================================================
  group('Validators.phoneNumber', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.phoneNumber(null);
      expect(result, isNull);
    });

    test('should return null for empty value (optional field)', () {
      final result = Validators.phoneNumber('');
      expect(result, isNull);
    });

    test('should return error for phone number that is too short', () {
      final result = Validators.phoneNumber(InvalidPhoneNumbers.tooShort);
      expect(result, isNotNull);
      expect(result, 'Please enter a valid phone number');
    });

    test('should return null for valid 10-digit phone number', () {
      final result = Validators.phoneNumber(ValidPhoneNumbers.us10Digit);
      expect(result, isNull);
    });

    test('should return null for phone number with + prefix', () {
      final result = Validators.phoneNumber(ValidPhoneNumbers.international);
      expect(result, isNull);
    });

    test('should return null for phone number with dashes and spaces', () {
      final result = Validators.phoneNumber(ValidPhoneNumbers.usFormatted);
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.number Tests
  // ============================================================
  group('Validators.number', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.number(null);
      expect(result, isNull);
    });

    test('should return null for empty value (optional field)', () {
      final result = Validators.number('');
      expect(result, isNull);
    });

    test('should return error for non-numeric string', () {
      final result = Validators.number('abc');
      expect(result, isNotNull);
      expect(result, contains('must be a valid number'));
    });

    test('should return null for valid integer string', () {
      final result = Validators.number('123');
      expect(result, isNull);
    });

    test('should return null for valid decimal string', () {
      final result = Validators.number('123.45');
      expect(result, isNull);
    });

    test('should use custom fieldName in error message', () {
      final result = Validators.number('abc', fieldName: 'Price');
      expect(result, 'Price must be a valid number');
    });
  });

  // ============================================================
  // Validators.positiveNumber Tests
  // ============================================================
  group('Validators.positiveNumber', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.positiveNumber(null);
      expect(result, isNull);
    });

    test('should return error for zero', () {
      final result = Validators.positiveNumber('0');
      expect(result, isNotNull);
      expect(result, contains('must be greater than 0'));
    });

    test('should return error for negative number', () {
      final result = Validators.positiveNumber('-5');
      expect(result, isNotNull);
      expect(result, contains('must be greater than 0'));
    });

    test('should return null for positive number', () {
      final result = Validators.positiveNumber('5');
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.min Tests
  // ============================================================
  group('Validators.min', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.min(null, 5);
      expect(result, isNull);
    });

    test('should return error for non-numeric value', () {
      final result = Validators.min('abc', 5);
      expect(result, isNotNull);
      expect(result, contains('must be a valid number'));
    });

    test('should return error for value below minimum', () {
      final result = Validators.min('4', 5);
      expect(result, isNotNull);
      expect(result, contains('must be at least 5'));
    });

    test('should return null for value exactly at minimum', () {
      final result = Validators.min('5', 5);
      expect(result, isNull);
    });

    test('should return null for value above minimum', () {
      final result = Validators.min('10', 5);
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.max Tests
  // ============================================================
  group('Validators.max', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.max(null, 100);
      expect(result, isNull);
    });

    test('should return error for value above maximum', () {
      final result = Validators.max('150', 100);
      expect(result, isNotNull);
      expect(result, contains('must be at most 100'));
    });

    test('should return null for value exactly at maximum', () {
      final result = Validators.max('100', 100);
      expect(result, isNull);
    });

    test('should return null for value below maximum', () {
      final result = Validators.max('50', 100);
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.minLength Tests
  // ============================================================
  group('Validators.minLength', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.minLength(null, 5);
      expect(result, isNull);
    });

    test('should return error for string shorter than minimum', () {
      final result = Validators.minLength('abc', 5);
      expect(result, isNotNull);
      expect(result, contains('must be at least 5 characters'));
    });

    test('should return null for string exactly at minimum length', () {
      final result = Validators.minLength('abcde', 5);
      expect(result, isNull);
    });

    test('should return null for string longer than minimum', () {
      final result = Validators.minLength('abcdefghij', 5);
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.maxLength Tests
  // ============================================================
  group('Validators.maxLength', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.maxLength(null, 10);
      expect(result, isNull);
    });

    test('should return error for string longer than maximum', () {
      final result = Validators.maxLength('this is a very long string', 10);
      expect(result, isNotNull);
      expect(result, contains('must be at most 10 characters'));
    });

    test('should return null for string at maximum length', () {
      final result = Validators.maxLength('1234567890', 10);
      expect(result, isNull);
    });
  });

  // ============================================================
  // Validators.date Tests
  // ============================================================
  group('Validators.date', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.date(null);
      expect(result, isNull);
    });

    test('should return null for valid ISO date string', () {
      final result = Validators.date('2024-01-15');
      expect(result, isNull);
    });

    test('should return error for invalid date format', () {
      final result = Validators.date('not-a-date');
      expect(result, isNotNull);
      expect(result, 'Please enter a valid date');
    });
  });

  // ============================================================
  // Validators.url Tests
  // ============================================================
  group('Validators.url', () {
    test('should return null for null value (optional field)', () {
      final result = Validators.url(null);
      expect(result, isNull);
    });

    test('should return null for valid http URL', () {
      final result = Validators.url(ValidUrls.http);
      expect(result, isNull);
    });

    test('should return null for valid https URL', () {
      final result = Validators.url(ValidUrls.https);
      expect(result, isNull);
    });

    test('should return error for URL without protocol', () {
      final result = Validators.url(InvalidUrls.noProtocol);
      expect(result, isNotNull);
      expect(result, 'Please enter a valid URL');
    });

    test('should return error for invalid URL format', () {
      final result = Validators.url(InvalidUrls.justText);
      expect(result, isNotNull);
    });
  });

  // ============================================================
  // Validators.combine Tests
  // ============================================================
  group('Validators.combine', () {
    test('should run validators in order and return first error', () {
      // Combine required and email validators
      final combinedValidator = Validators.combine([
        (value) => Validators.required(value, fieldName: 'Email'),
        Validators.email,
      ]);
      
      // Test with empty value - should fail on required first
      final result = combinedValidator('');
      expect(result, 'Email is required');
    });

    test('should return second validator error if first passes', () {
      final combinedValidator = Validators.combine([
        (value) => Validators.required(value, fieldName: 'Email'),
        Validators.email,
      ]);
      
      // Test with non-empty but invalid email
      final result = combinedValidator('notanemail');
      expect(result, 'Please enter a valid email');
    });

    test('should return null when all validators pass', () {
      final combinedValidator = Validators.combine([
        (value) => Validators.required(value, fieldName: 'Email'),
        Validators.email,
      ]);
      
      // Test with valid email
      final result = combinedValidator('test@example.com');
      expect(result, isNull);
    });

    test('should work with multiple validators', () {
      final combinedValidator = Validators.combine([
        (value) => Validators.required(value, fieldName: 'Password'),
        (value) => Validators.minLength(value, 8, fieldName: 'Password'),
        (value) => Validators.maxLength(value, 20, fieldName: 'Password'),
      ]);
      
      // Test too short
      expect(combinedValidator('short'), contains('at least 8'));
      
      // Test too long
      expect(
        combinedValidator('thispasswordiswaytoolongtobeaccepted'),
        contains('at most 20'),
      );
      
      // Test valid
      expect(combinedValidator('validpassword'), isNull);
    });
  });

  // ============================================================
  // Edge Cases and Special Scenarios
  // ============================================================
  group('Edge Cases', () {
    test('should handle strings with special characters in email', () {
      expect(Validators.email('user.name+tag@example.co.uk'), isNull);
    });

    test('should handle negative numbers in min validation', () {
      expect(Validators.min('-10', -5), isNotNull); // -10 < -5
      expect(Validators.min('-3', -5), isNull);     // -3 > -5
    });

    test('should handle decimal values in positive number check', () {
      expect(Validators.positiveNumber('0.001'), isNull);
      expect(Validators.positiveNumber('0.0'), isNotNull);
    });

    test('should handle unicode characters in required validation', () {
      expect(Validators.required('مرحبا'), isNull); // Arabic
      expect(Validators.required('你好'), isNull);   // Chinese
      expect(Validators.required('🌾'), isNull);    // Emoji
    });

    test('should handle very long strings in maxLength', () {
      final longString = 'a' * 1000;
      expect(Validators.maxLength(longString, 100), isNotNull);
    });
  });
}





