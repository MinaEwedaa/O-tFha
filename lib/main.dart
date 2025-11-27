import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue anyway - app can work without Firebase in some cases
  }
  
  runApp(const OtfhaApp());
}

class OtfhaApp extends StatelessWidget {
  const OtfhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otfha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

// Wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  AuthService? _authService;
  
  AuthService? _getAuthService() {
    try {
      _authService ??= AuthService();
      return _authService;
    } catch (e) {
      print('Failed to initialize AuthService: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = _getAuthService();
    
    // If auth service failed to initialize, show login screen
    if (authService == null) {
      return const LoginScreen();
    }
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          print('Auth state error: ${snapshot.error}');
          // On error, show login screen
          return const LoginScreen();
        }

        // User is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
