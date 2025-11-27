import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String role = "Farmer"; // default selection
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final displayName = '${_firstNameController.text} ${_lastNameController.text}';
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: displayName,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: '+20${_phoneController.text.trim()}',
        address: _addressController.text.trim(),
        role: role,
      );

      if (mounted) {
        _showSuccess('Account created successfully!');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.signInWithGoogle(role: role);
      
      if (mounted) {
        _showSuccess('Signed in with Google successfully!');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Language (top right)
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'العربية',
                    style: GoogleFonts.poppins(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Logo
                Image.asset('assets/images/logo.png', width: 120),
                const SizedBox(height: 10),

                Text(
                  'Otfha',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // Name fields (first + last)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: GoogleFonts.poppins(color: Colors.black87),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: GoogleFonts.poppins(color: Colors.black87),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.poppins(color: Colors.black87),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone number
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black54)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '🇪🇬',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 5),
                          const Text('+20'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle:
                              GoogleFonts.poppins(color: Colors.black87),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Address
                TextFormField(
                  controller: _addressController,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  decoration: InputDecoration(
                    labelText: 'Address, city, country',
                    labelStyle: GoogleFonts.poppins(color: Colors.black87),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.poppins(color: Colors.black87),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) => value?.isEmpty ?? true ? 'Please confirm password' : null,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: GoogleFonts.poppins(color: Colors.black87),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Radio buttons (roles)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Farmer',
                          groupValue: role,
                          activeColor: Colors.orange,
                          onChanged: (value) => setState(() => role = value!),
                        ),
                        Text('Farmer', style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Investor',
                          groupValue: role,
                          activeColor: Colors.orange,
                          onChanged: (value) => setState(() => role = value!),
                        ),
                        Text('Investor',
                            style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Supplier',
                          groupValue: role,
                          activeColor: Colors.orange,
                          onChanged: (value) => setState(() => role = value!),
                        ),
                        Text('Supplier',
                            style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade200,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Or', style: GoogleFonts.poppins(fontSize: 13)),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Google signup button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: 24,
                      height: 24,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade100,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signUpWithGoogle,
                    label: Text(
                      'Sign up with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account yet? ",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
  Navigator.pushNamed(context, '/login');
},

                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          color: Colors.teal.shade700,
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
        ],
      ),
    );
  }
}
