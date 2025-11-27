import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:otfha/services/auth_service.dart';
import 'package:otfha/services/api_service.dart';

/// Integration tests for Firebase Authentication
/// 
/// These tests verify the complete authentication flow:
/// 1. Firebase Auth initialization
/// 2. User registration and login
/// 3. Token generation
/// 4. Backend API authentication
/// 5. Profile management
/// 
/// Note: These tests require Firebase to be properly configured
/// and the backend server to be running on localhost:5000

void main() {
  // Initialize Firebase for testing
  setUpAll(() async {
    // Note: In a real test, you'd use Firebase Test Lab or Emulator
    // For now, this is a template for manual integration testing
  });

  group('Firebase Authentication Integration Tests', () {
    late AuthService authService;
    late ApiService apiService;
    
    const testEmail = 'test_flutter@otfha.test';
    const testPassword = 'TestPassword123!';
    const testDisplayName = 'Flutter Test User';

    setUp(() {
      authService = AuthService();
      apiService = ApiService();
    });

    test('Firebase should be initialized', () async {
      // In a real app, Firebase.initializeApp() would be called
      // This test verifies the initialization is successful
      expect(Firebase.apps.isNotEmpty, true);
    });

    test('Should sign up a new user', () async {
      try {
        final credential = await authService.signUpWithEmail(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        expect(credential, isNotNull);
        expect(credential?.user, isNotNull);
        expect(credential?.user?.email, testEmail);
        expect(credential?.user?.displayName, testDisplayName);
      } catch (e) {
        // User might already exist - that's okay for testing
        if (!e.toString().contains('email-already-in-use')) {
          rethrow;
        }
      }
    });

    test('Should sign in with email and password', () async {
      try {
        final credential = await authService.signInWithEmail(
          testEmail,
          testPassword,
        );

        expect(credential, isNotNull);
        expect(credential?.user, isNotNull);
        expect(credential?.user?.email, testEmail);
      } catch (e) {
        fail('Sign in failed: $e');
      }
    });

    test('Should get Firebase ID token', () async {
      // First sign in
      await authService.signInWithEmail(testEmail, testPassword);
      
      // Get ID token
      final token = await authService.getIdToken();
      
      expect(token, isNotNull);
      expect(token!.length, greaterThan(100));
    });

    test('Should verify token with backend', () async {
      // Sign in and get token
      await authService.signInWithEmail(testEmail, testPassword);
      final token = await authService.getIdToken();
      
      // Verify with backend
      final response = await apiService.post(
        '/v1/auth/verify',
        data: {'token': token},
      );
      
      expect(response['success'], true);
      expect(response['data']['valid'], true);
    });

    test('Should access protected endpoint with authentication', () async {
      // Sign in and get token
      await authService.signInWithEmail(testEmail, testPassword);
      final token = await authService.getIdToken();
      
      // Set auth token
      apiService.setAuthToken(token!);
      
      // Access protected endpoint
      final response = await apiService.get('/v1/auth/me');
      
      expect(response['success'], true);
      expect(response['data']['email'], testEmail);
    });

    test('Should fail to access protected endpoint without authentication', () async {
      // Clear auth token
      apiService.clearAuthToken();
      
      try {
        await apiService.get('/v1/auth/me');
        fail('Should have thrown an exception');
      } catch (e) {
        // Expected to fail with 401
        expect(e.toString().contains('401') || e.toString().contains('Unauthorized'), true);
      }
    });

    test('Should update user profile', () async {
      // Sign in
      await authService.signInWithEmail(testEmail, testPassword);
      
      // Update profile
      await authService.updateProfile(
        displayName: 'Updated Test User',
      );
      
      // Verify update
      await authService.reloadUser();
      final user = authService.currentUser;
      
      expect(user?.displayName, 'Updated Test User');
    });

    test('Should update user preferences in backend', () async {
      // Sign in and get token
      await authService.signInWithEmail(testEmail, testPassword);
      final token = await authService.getIdToken();
      
      apiService.setAuthToken(token!);
      
      // Update preferences
      final response = await apiService.put(
        '/v1/auth/update-profile',
        data: {
          'preferences': {
            'language': 'en',
            'notifications': true,
            'theme': 'dark',
          }
        },
      );
      
      expect(response['success'], true);
    });

    test('Should get user data from Firestore', () async {
      // Sign in
      await authService.signInWithEmail(testEmail, testPassword);
      final user = authService.currentUser;
      
      if (user != null) {
        final userData = await authService.getUserData(user.uid);
        
        expect(userData, isNotNull);
        expect(userData?['email'], testEmail);
      }
    });

    test('Should check if user is admin', () async {
      // Sign in
      await authService.signInWithEmail(testEmail, testPassword);
      
      // Check admin status (should be false for test user)
      final isAdmin = await authService.isAdmin();
      
      expect(isAdmin, false);
    });

    test('Should sign out successfully', () async {
      // Sign in first
      await authService.signInWithEmail(testEmail, testPassword);
      expect(authService.currentUser, isNotNull);
      
      // Sign out
      await authService.signOut();
      
      // Verify signed out
      expect(authService.currentUser, isNull);
    });

    tearDown(() async {
      // Clean up - sign out after each test
      try {
        await authService.signOut();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });
  });

  group('Backend API Integration Tests', () {
    late ApiService apiService;
    
    setUp(() {
      apiService = ApiService();
    });

    test('Should check authentication status', () async {
      final response = await apiService.get('/v1/auth/check');
      
      expect(response['success'], true);
      expect(response['data'], containsPair('authenticated', isA<bool>()));
    });

    test('Should handle token expiration gracefully', () async {
      // Use an expired token
      const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.expired.token';
      apiService.setAuthToken(expiredToken);
      
      try {
        await apiService.get('/v1/auth/me');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString().contains('401') || e.toString().contains('Unauthorized'), true);
      }
    });
  });
}

