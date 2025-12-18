import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../mocks/mock_auth_service.dart';

/// Integration tests for Authentication Flow
/// 
/// Tests complete user authentication journeys:
/// - Signup → Home flow
/// - Login → Home flow
/// - Logout flow
/// - Password reset flow
/// 
/// Uses mock services to avoid Firebase dependency.

void main() {
  late MockAuthService mockAuthService;
  
  setUp(() {
    mockAuthService = MockAuthService();
    // Seed a test user
    mockAuthService.seedTestUser(
      email: 'test@example.com',
      password: 'password123',
      displayName: 'Test User',
    );
  });
  
  tearDown(() {
    mockAuthService.reset();
  });

  group('Authentication Flow Integration Tests', () {
    // ================================================================
    // Login Flow Tests
    // ================================================================
    group('Login Flow', () {
      testWidgets('should complete login flow successfully', (tester) async {
        bool navigatedToHome = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestLoginFlow(
              authService: mockAuthService,
              onLoginSuccess: () => navigatedToHome = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(
          find.byKey(const Key('email-field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password-field')),
          'password123',
        );
        
        // Tap login
        await tester.tap(find.byKey(const Key('login-button')));
        await tester.pumpAndSettle();

        // Verify navigation happened
        expect(navigatedToHome, true);
      });

      testWidgets('should show error for invalid credentials', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestLoginFlow(
              authService: mockAuthService,
              onLoginSuccess: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter wrong password
        await tester.enterText(
          find.byKey(const Key('email-field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password-field')),
          'wrongpassword',
        );
        
        // Tap login
        await tester.tap(find.byKey(const Key('login-button')));
        await tester.pumpAndSettle();

        // Should show error
        expect(find.textContaining('Wrong password'), findsOneWidget);
      });

      testWidgets('should show error for non-existent user', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestLoginFlow(
              authService: mockAuthService,
              onLoginSuccess: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter non-existent email
        await tester.enterText(
          find.byKey(const Key('email-field')),
          'nonexistent@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password-field')),
          'password123',
        );
        
        // Tap login
        await tester.tap(find.byKey(const Key('login-button')));
        await tester.pumpAndSettle();

        // Should show error
        expect(find.textContaining('No user found'), findsOneWidget);
      });

      testWidgets('should complete login without errors', (tester) async {
        bool loginSuccess = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestLoginFlow(
              authService: mockAuthService,
              onLoginSuccess: () => loginSuccess = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(
          find.byKey(const Key('email-field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password-field')),
          'password123',
        );
        
        // Tap login
        await tester.tap(find.byKey(const Key('login-button')));
        await tester.pumpAndSettle();

        // Should complete login
        expect(loginSuccess, true);
      });
    });

    // ================================================================
    // Signup Flow Tests
    // ================================================================
    group('Signup Flow', () {
      testWidgets('should complete signup flow successfully', (tester) async {
        bool signupSuccess = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestSignupFlow(
              authService: mockAuthService,
              onSignupSuccess: () => signupSuccess = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter new user details
        await tester.enterText(
          find.byKey(const Key('email-field')),
          'newuser@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password-field')),
          'newpassword123',
        );
        await tester.enterText(
          find.byKey(const Key('name-field')),
          'New User',
        );
        
        // Tap signup
        await tester.tap(find.byKey(const Key('signup-button')));
        await tester.pumpAndSettle();

        // Verify signup happened
        expect(signupSuccess, true);
      });

      testWidgets('should show error for existing email', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestSignupFlow(
              authService: mockAuthService,
              onSignupSuccess: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Try to signup with existing email
        await tester.enterText(
          find.byKey(const Key('email-field')),
          'test@example.com', // Already exists
        );
        await tester.enterText(
          find.byKey(const Key('password-field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('name-field')),
          'Test User',
        );
        
        // Tap signup
        await tester.tap(find.byKey(const Key('signup-button')));
        await tester.pumpAndSettle();

        // Should show error
        expect(find.textContaining('already in use'), findsOneWidget);
      });
    });

    // ================================================================
    // Logout Flow Tests
    // ================================================================
    group('Logout Flow', () {
      testWidgets('should complete logout flow', (tester) async {
        bool loggedOut = false;
        
        // Start logged in
        await mockAuthService.signInWithEmail('test@example.com', 'password123');
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestHomeWithLogout(
              authService: mockAuthService,
              onLogout: () => loggedOut = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap logout
        await tester.tap(find.byKey(const Key('logout-button')));
        await tester.pumpAndSettle();

        // Verify logout happened
        expect(loggedOut, true);
        expect(mockAuthService.currentUser, isNull);
      });
    });

    // ================================================================
    // Complete Auth Journey Tests
    // ================================================================
    group('Complete Auth Journey', () {
      testWidgets('should support signup → login → logout cycle', (tester) async {
        // Step 1: Signup
        final signupResult = await mockAuthService.signUpWithEmail(
          email: 'journey@example.com',
          password: 'journey123',
          displayName: 'Journey User',
        );
        expect(signupResult?.user?.email, 'journey@example.com');
        
        // Step 2: Logout
        await mockAuthService.signOut();
        expect(mockAuthService.currentUser, isNull);
        
        // Step 3: Login with same credentials
        final loginResult = await mockAuthService.signInWithEmail(
          'journey@example.com',
          'journey123',
        );
        expect(loginResult?.user?.email, 'journey@example.com');
      });

      testWidgets('should get ID token after login', (tester) async {
        // Login
        await mockAuthService.signInWithEmail('test@example.com', 'password123');
        
        // Get token
        final token = await mockAuthService.getIdToken();
        
        expect(token, isNotNull);
        expect(token!.startsWith('mock-id-token-'), true);
      });
    });
  });
}

// ================================================================
// Test Widget: Login Flow
// ================================================================
class _TestLoginFlow extends StatefulWidget {
  final MockAuthService authService;
  final VoidCallback onLoginSuccess;

  const _TestLoginFlow({
    required this.authService,
    required this.onLoginSuccess,
  });

  @override
  State<_TestLoginFlow> createState() => _TestLoginFlowState();
}

class _TestLoginFlowState extends State<_TestLoginFlow> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      
      if (mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              key: const Key('email-field'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('password-field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('login-button'),
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Test Widget: Signup Flow
// ================================================================
class _TestSignupFlow extends StatefulWidget {
  final MockAuthService authService;
  final VoidCallback onSignupSuccess;

  const _TestSignupFlow({
    required this.authService,
    required this.onSignupSuccess,
  });

  @override
  State<_TestSignupFlow> createState() => _TestSignupFlowState();
}

class _TestSignupFlowState extends State<_TestSignupFlow> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
      
      if (mounted) {
        widget.onSignupSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              key: const Key('name-field'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('email-field'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('password-field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('signup-button'),
              onPressed: _isLoading ? null : _signup,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Test Widget: Home with Logout
// ================================================================
class _TestHomeWithLogout extends StatelessWidget {
  final MockAuthService authService;
  final VoidCallback onLogout;

  const _TestHomeWithLogout({
    required this.authService,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          key: const Key('logout-button'),
          onPressed: () async {
            await authService.signOut();
            onLogout();
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

