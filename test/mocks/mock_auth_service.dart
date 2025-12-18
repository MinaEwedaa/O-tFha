import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Mock AuthService for testing without Firebase
/// 
/// This mock provides predictable responses for all auth operations
/// without requiring actual Firebase connection.
class MockAuthService {
  firebase_auth.User? _currentUser;
  bool _isSignedIn = false;
  final Map<String, MockUserData> _users = {};
  
  // Simulated current user
  firebase_auth.User? get currentUser => _currentUser;
  
  // Simulated auth state stream
  Stream<firebase_auth.User?> get authStateChanges {
    return Stream.value(_currentUser);
  }
  
  /// Sign in with email and password
  Future<MockUserCredential?> signInWithEmail(String email, String password) async {
    // Note: No delay in tests to avoid timer issues
    
    // Check if user exists
    if (_users.containsKey(email)) {
      final userData = _users[email]!;
      if (userData.password == password) {
        _isSignedIn = true;
        return MockUserCredential(
          user: MockUser(
            uid: userData.uid,
            email: email,
            displayName: userData.displayName,
          ),
        );
      } else {
        throw MockAuthException('wrong-password', 'Wrong password provided.');
      }
    }
    
    throw MockAuthException('user-not-found', 'No user found with this email.');
  }
  
  /// Sign up with email and password
  Future<MockUserCredential?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Note: No delay in tests to avoid timer issues
    
    // Check if user already exists
    if (_users.containsKey(email)) {
      throw MockAuthException('email-already-in-use', 'Email already in use.');
    }
    
    // Create new user
    final uid = 'mock-uid-${DateTime.now().millisecondsSinceEpoch}';
    _users[email] = MockUserData(
      uid: uid,
      email: email,
      password: password,
      displayName: displayName ?? '',
    );
    
    _isSignedIn = true;
    return MockUserCredential(
      user: MockUser(
        uid: uid,
        email: email,
        displayName: displayName,
      ),
    );
  }
  
  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _isSignedIn = false;
  }
  
  /// Get ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    if (_isSignedIn) {
      return 'mock-id-token-${DateTime.now().millisecondsSinceEpoch}';
    }
    return null;
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    // Always succeed in mock - no delay to avoid timer issues
  }
  
  /// Check if email is verified
  bool get isEmailVerified => _isSignedIn;
  
  /// Check if user is admin
  Future<bool> isAdmin() async {
    return false; // Default to non-admin in tests
  }
  
  /// Seed test user for testing
  void seedTestUser({
    required String email,
    required String password,
    String? displayName,
    String uid = 'test-uid-123',
  }) {
    _users[email] = MockUserData(
      uid: uid,
      email: email,
      password: password,
      displayName: displayName ?? 'Test User',
    );
  }
  
  /// Clear all test data
  void reset() {
    _users.clear();
    _currentUser = null;
    _isSignedIn = false;
  }
}

/// Mock user data storage
class MockUserData {
  final String uid;
  final String email;
  final String password;
  final String displayName;
  
  MockUserData({
    required this.uid,
    required this.email,
    required this.password,
    required this.displayName,
  });
}

/// Mock User class
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  
  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });
}

/// Mock UserCredential
class MockUserCredential {
  final MockUser? user;
  final MockAdditionalUserInfo? additionalUserInfo;
  
  MockUserCredential({
    this.user,
    this.additionalUserInfo,
  });
}

/// Mock AdditionalUserInfo
class MockAdditionalUserInfo {
  final bool isNewUser;
  
  MockAdditionalUserInfo({this.isNewUser = false});
}

/// Mock AuthException
class MockAuthException implements Exception {
  final String code;
  final String message;
  
  MockAuthException(this.code, this.message);
  
  @override
  String toString() => 'MockAuthException: [$code] $message';
}

