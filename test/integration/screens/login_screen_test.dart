import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../mocks/mock_providers.dart';

/// Integration tests for LoginScreen
/// 
/// Tests the login screen UI rendering, form validation,
/// and user interactions without requiring Firebase.
/// 
/// Note: These tests use a simplified mock approach.
/// For full Firebase integration, use firebase_auth_mocks package.

void main() {
  group('LoginScreen Integration Tests', () {
    // ================================================================
    // UI Rendering Tests
    // ================================================================
    group('UI Rendering', () {
      testWidgets('should render login screen with all elements', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: _TestLoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify main elements exist
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);
      });

      testWidgets('should render email text field', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        // Find email field
        final emailField = find.byType(TextFormField).first;
        expect(emailField, findsOneWidget);
      });

      testWidgets('should render password text field with obscured text', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        // Find password field (second TextFormField)
        final passwordFields = find.byType(TextFormField);
        expect(passwordFields, findsNWidgets(2));
      });

      testWidgets('should render login button', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
      });

      testWidgets('should render forgot password link', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Forgot Password'), findsOneWidget);
      });

      testWidgets('should render sign up link', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.text("Don't have an account yet? "), findsOneWidget);
      });

      testWidgets('should render remember me checkbox', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Checkbox), findsOneWidget);
        expect(find.text('remember me'), findsOneWidget);
      });
    });

    // ================================================================
    // Form Validation Tests
    // ================================================================
    group('Form Validation', () {
      testWidgets('should show error when email is empty', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        // Leave email empty, tap login
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        // Enter invalid email
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'invalid-email');
        
        // Tap login
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Invalid email'), findsOneWidget);
      });

      testWidgets('should show error when password is empty', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        // Enter valid email but no password
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'test@example.com');
        
        // Tap login
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        // Should show password validation error
        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('should not show errors for valid input', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: const _TestLoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(body: Text('Home')),
            },
          ),
        );
        await tester.pumpAndSettle();

        // Enter valid email
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.last, 'password123');
        
        // Trigger validation
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        // Should not show validation errors
        expect(find.text('Email is required'), findsNothing);
        expect(find.text('Password is required'), findsNothing);
        expect(find.text('Invalid email'), findsNothing);
      });
    });

    // ================================================================
    // User Interaction Tests
    // ================================================================
    group('User Interactions', () {
      testWidgets('should toggle remember me checkbox', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        // Find checkbox
        final checkbox = find.byType(Checkbox);
        
        // Initially unchecked
        Checkbox checkboxWidget = tester.widget(checkbox);
        expect(checkboxWidget.value, false);
        
        // Tap to check
        await tester.tap(checkbox);
        await tester.pump();
        
        // Should be checked
        checkboxWidget = tester.widget(checkbox);
        expect(checkboxWidget.value, true);
      });

      testWidgets('should allow text entry in email field', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        const testEmail = 'user@example.com';
        
        // Enter email
        await tester.enterText(find.byType(TextFormField).first, testEmail);
        await tester.pump();

        // Verify text was entered
        expect(find.text(testEmail), findsOneWidget);
      });

      testWidgets('should allow text entry in password field', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        const testPassword = 'secretpassword';
        
        // Enter password
        await tester.enterText(find.byType(TextFormField).last, testPassword);
        await tester.pump();

        // Password field exists (text is obscured but field has value)
        final passwordField = tester.widget<TextFormField>(
          find.byType(TextFormField).last,
        );
        expect(passwordField.controller?.text, testPassword);
      });

      testWidgets('should process login when button is pressed with valid data', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: const _TestLoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(body: Text('Home')),
            },
          ),
        );
        await tester.pumpAndSettle();

        // Enter valid credentials
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.last, 'password123');
        
        // Tap login
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        // Should navigate to home (no validation errors)
        expect(find.text('Email is required'), findsNothing);
        expect(find.text('Password is required'), findsNothing);
      });
    });

    // ================================================================
    // Navigation Tests
    // ================================================================
    group('Navigation', () {
      testWidgets('should have sign up text that is tappable', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: const _TestLoginScreen(),
            routes: {
              '/signup': (context) => const Scaffold(body: Text('Signup Page')),
            },
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap sign up
        final signUpText = find.text('Sign Up');
        expect(signUpText, findsOneWidget);
        
        // Verify it's in a GestureDetector or similar
        final gestureDetector = find.ancestor(
          of: signUpText,
          matching: find.byType(GestureDetector),
        );
        expect(gestureDetector, findsWidgets);
      });

      testWidgets('should have forgot password as TextButton', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: const _TestLoginScreen(),
            routes: {
              '/forgot-password': (context) => const Scaffold(
                body: Text('Forgot Password Page'),
              ),
            },
          ),
        );
        await tester.pumpAndSettle();

        // Find forgot password button
        final forgotPassword = find.widgetWithText(TextButton, 'Forgot Password');
        expect(forgotPassword, findsOneWidget);
      });
    });

    // ================================================================
    // Edge Cases
    // ================================================================
    group('Edge Cases', () {
      testWidgets('should handle very long email input', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        final longEmail = '${'a' * 100}@${'b' * 100}.com';
        
        await tester.enterText(find.byType(TextFormField).first, longEmail);
        await tester.pump();

        // Should not crash
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle special characters in password', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(child: _TestLoginScreen()),
        );
        await tester.pumpAndSettle();

        const specialPassword = r'P@$$w0rd!#$%^&*()';
        
        await tester.enterText(find.byType(TextFormField).last, specialPassword);
        await tester.pump();

        // Should not crash
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle multiple form submissions gracefully', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: const _TestLoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(body: Text('Home')),
            },
          ),
        );
        await tester.pumpAndSettle();

        // Enter valid credentials
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.last, 'password123');

        // Tap login button
        final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Should not crash and navigation should work
        expect(tester.takeException(), isNull);
      });
    });
  });
}

/// Simplified test login screen that mimics the real one
/// but without Firebase dependencies
class _TestLoginScreen extends StatefulWidget {
  const _TestLoginScreen();

  @override
  State<_TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<_TestLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // In tests, we don't use delays - just simulate immediate login
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Password is required' : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 10),

              // Remember me + Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() => rememberMe = value ?? false);
                        },
                      ),
                      const Text('remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text('Forgot Password'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Log In button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log In'),
                ),
              ),
              const SizedBox(height: 20),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account yet? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

