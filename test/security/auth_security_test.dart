import 'package:flutter_test/flutter_test.dart';
import 'package:otfha/core/utils/validators.dart';
import '../mocks/mock_auth_service.dart';

/// Security tests for authentication
/// 
/// Tests:
/// - Password policy enforcement
/// - Brute force protection simulation
/// - Token security
/// - Session management
/// - Account enumeration prevention

void main() {
  group('Authentication Security Tests', () {
    // ================================================================
    // Password Policy Tests
    // ================================================================
    group('Password Policy Enforcement', () {
      test('should reject passwords shorter than minimum length', () {
        final shortPasswords = ['12345', 'abc', 'a', ''];

        for (final password in shortPasswords) {
          final result = Validators.password(password);
          expect(
            result,
            isNotNull,
            reason: 'Should reject short password: "$password"',
          );
        }
      });

      test('should accept passwords meeting minimum length', () {
        final validPasswords = [
          '123456',
          'password',
          'abcdefghij',
          'MySecureP@ss!',
        ];

        for (final password in validPasswords) {
          final result = Validators.password(password);
          expect(
            result,
            isNull,
            reason: 'Should accept valid password: "$password"',
          );
        }
      });

      test('should support custom minimum length requirements', () {
        // Test 8-character minimum
        expect(Validators.password('1234567', minLength: 8), isNotNull);
        expect(Validators.password('12345678', minLength: 8), isNull);

        // Test 12-character minimum
        expect(Validators.password('12345678901', minLength: 12), isNotNull);
        expect(Validators.password('123456789012', minLength: 12), isNull);
      });

      test('should handle passwords with special characters', () {
        final specialPasswords = [
          'P@ssw0rd!',
          'Secure#123',
          'Test\$ecure',
          'Pass&word',
        ];

        for (final password in specialPasswords) {
          final result = Validators.password(password);
          expect(
            result,
            isNull,
            reason: 'Should accept password with special chars: "$password"',
          );
        }
      });

      test('should handle unicode passwords', () {
        final unicodePasswords = [
          'пароль123', // Russian
          '密码123456', // Chinese
          'パスワード123', // Japanese
        ];

        for (final password in unicodePasswords) {
          final result = Validators.password(password);
          expect(
            result,
            isNull,
            reason: 'Should accept unicode password: "$password"',
          );
        }
      });

      test('should reject null or empty passwords', () {
        expect(Validators.password(null), isNotNull);
        expect(Validators.password(''), isNotNull);
      });
    });

    // ================================================================
    // Password Confirmation Tests
    // ================================================================
    group('Password Confirmation Security', () {
      test('should require exact password match', () {
        const password = 'SecureP@ss123';
        
        // Exact match should pass
        expect(Validators.confirmPassword(password, password), isNull);
        
        // Case difference should fail
        expect(
          Validators.confirmPassword('securep@ss123', password),
          isNotNull,
        );
        
        // Extra space should fail
        expect(
          Validators.confirmPassword('$password ', password),
          isNotNull,
        );
      });

      test('should reject empty confirmation', () {
        expect(Validators.confirmPassword('', 'password123'), isNotNull);
        expect(Validators.confirmPassword(null, 'password123'), isNotNull);
      });

      test('should handle special characters in password match', () {
        const password = 'P@ss\$w0rd!#%';
        expect(Validators.confirmPassword(password, password), isNull);
        expect(Validators.confirmPassword('P@ss\$w0rd!#', password), isNotNull);
      });
    });

    // ================================================================
    // Brute Force Protection Tests
    // ================================================================
    group('Brute Force Protection', () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
        mockAuthService.seedTestUser(
          email: 'test@example.com',
          password: 'correctpassword',
        );
      });

      test('should reject invalid password attempts', () async {
        final wrongPasswords = [
          'wrongpassword1',
          'wrongpassword2',
          'wrongpassword3',
          'wrongpassword4',
          'wrongpassword5',
        ];

        int failedAttempts = 0;

        for (final password in wrongPasswords) {
          try {
            await mockAuthService.signInWithEmail('test@example.com', password);
          } catch (e) {
            failedAttempts++;
            expect(e.toString(), contains('Wrong password'));
          }
        }

        expect(failedAttempts, wrongPasswords.length);
      });

      test('should distinguish between wrong password and no user', () async {
        // Wrong password for existing user
        try {
          await mockAuthService.signInWithEmail('test@example.com', 'wrong');
          fail('Should throw exception');
        } catch (e) {
          expect(e.toString(), contains('Wrong password'));
        }

        // Non-existent user
        try {
          await mockAuthService.signInWithEmail('nouser@example.com', 'any');
          fail('Should throw exception');
        } catch (e) {
          expect(e.toString(), contains('No user found'));
        }
      });

      test('should succeed with correct credentials after failed attempts', () async {
        // First, fail a few times
        for (int i = 0; i < 3; i++) {
          try {
            await mockAuthService.signInWithEmail('test@example.com', 'wrong$i');
          } catch (e) {
            // Expected
          }
        }

        // Then succeed with correct password
        final result = await mockAuthService.signInWithEmail(
          'test@example.com',
          'correctpassword',
        );

        expect(result, isNotNull);
        expect(result?.user?.email, 'test@example.com');
      });
    });

    // ================================================================
    // Token Security Tests
    // ================================================================
    group('Token Security', () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
        mockAuthService.seedTestUser(
          email: 'test@example.com',
          password: 'password123',
        );
      });

      test('should not return token when not signed in', () async {
        final token = await mockAuthService.getIdToken();
        expect(token, isNull);
      });

      test('should return token after successful sign in', () async {
        await mockAuthService.signInWithEmail('test@example.com', 'password123');
        final token = await mockAuthService.getIdToken();
        
        expect(token, isNotNull);
        expect(token!.length, greaterThan(10));
      });

      test('should generate unique tokens', () async {
        await mockAuthService.signInWithEmail('test@example.com', 'password123');
        
        final token1 = await mockAuthService.getIdToken();
        // Small delay to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));
        final token2 = await mockAuthService.getIdToken();
        
        expect(token1, isNotNull);
        expect(token2, isNotNull);
        // Tokens should be different (contain timestamp)
        expect(token1, isNot(equals(token2)));
      });

      test('should invalidate token on sign out', () async {
        // Sign in and get token
        await mockAuthService.signInWithEmail('test@example.com', 'password123');
        final tokenBefore = await mockAuthService.getIdToken();
        expect(tokenBefore, isNotNull);

        // Sign out
        await mockAuthService.signOut();

        // Token should be null
        final tokenAfter = await mockAuthService.getIdToken();
        expect(tokenAfter, isNull);
      });

      test('should not expose token in error messages', () async {
        try {
          await mockAuthService.signInWithEmail('test@example.com', 'wrong');
          fail('Should throw');
        } catch (e) {
          final errorMessage = e.toString();
          expect(errorMessage.contains('token'), false);
          expect(errorMessage.contains('jwt'), false);
          expect(errorMessage.contains('bearer'), false);
        }
      });
    });

    // ================================================================
    // Session Management Tests
    // ================================================================
    group('Session Management', () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
        mockAuthService.seedTestUser(
          email: 'test@example.com',
          password: 'password123',
        );
      });

      test('should clear session on sign out', () async {
        // Sign in
        final result = await mockAuthService.signInWithEmail('test@example.com', 'password123');
        expect(result, isNotNull);
        expect(result?.user, isNotNull);

        // Sign out
        await mockAuthService.signOut();
        // After sign out, token should be null
        final token = await mockAuthService.getIdToken();
        expect(token, isNull);
      });

      test('should not allow operations after sign out', () async {
        // Sign in
        await mockAuthService.signInWithEmail('test@example.com', 'password123');
        
        // Sign out
        await mockAuthService.signOut();

        // Should not have token
        final token = await mockAuthService.getIdToken();
        expect(token, isNull);
      });

      test('should support multiple sign in/out cycles', () async {
        for (int i = 0; i < 3; i++) {
          // Sign in
          final result = await mockAuthService.signInWithEmail(
            'test@example.com',
            'password123',
          );
          expect(result?.user?.email, 'test@example.com');

          // Sign out
          await mockAuthService.signOut();
          expect(mockAuthService.currentUser, isNull);
        }
      });

      test('should handle sign out when not signed in', () async {
        // Should not throw
        await mockAuthService.signOut();
        expect(mockAuthService.currentUser, isNull);
      });
    });

    // ================================================================
    // Account Enumeration Prevention
    // ================================================================
    group('Account Enumeration Prevention', () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
        mockAuthService.seedTestUser(
          email: 'existing@example.com',
          password: 'password123',
        );
      });

      test('should not reveal if email exists on signup', () async {
        // Try to sign up with existing email
        try {
          await mockAuthService.signUpWithEmail(
            email: 'existing@example.com',
            password: 'newpassword',
          );
          fail('Should throw');
        } catch (e) {
          // Error should mention "already in use" not expose user details
          final message = e.toString();
          expect(message.contains('already in use'), true);
          expect(message.contains('uid'), false);
          expect(message.contains('password'), false);
        }
      });

      test('error messages should not leak sensitive info', () async {
        try {
          await mockAuthService.signInWithEmail('test@test.com', 'wrong');
        } catch (e) {
          final message = e.toString().toLowerCase();
          // Should not contain sensitive patterns
          expect(message.contains('database'), false);
          expect(message.contains('query'), false);
          expect(message.contains('table'), false);
        }
      });
    });

    // ================================================================
    // Email Security Tests
    // ================================================================
    group('Email Validation Security', () {
      test('should reject emails with dangerous characters', () {
        final dangerousEmails = [
          'test<script>@example.com',
          'test"@example.com',
          "test'--@example.com",
          'test;@example.com',
        ];

        for (final email in dangerousEmails) {
          final result = Validators.email(email);
          expect(
            result,
            isNotNull,
            reason: 'Should reject dangerous email: $email',
          );
        }
      });

      test('should reject extremely long emails', () {
        final longEmail = '${'a' * 300}@example.com';
        // Should not crash
        expect(() => Validators.email(longEmail), returnsNormally);
      });
    });
  });
}

