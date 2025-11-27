import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Stream of user data from Firestore
  Stream<DocumentSnapshot>? getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      await _updateLastLogin(credential.user!.uid);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Create user document in Firestore with additional fields
      await _createUserDocument(
        credential.user!,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        role: role,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({String? role}) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Create user document in Firestore for new users
        await _createUserDocument(
          userCredential.user!,
          role: role ?? 'Farmer', // Default role
        );
      } else {
        // Update last login time for existing users
        await _updateLastLogin(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get ID token for backend authentication
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      await _auth.currentUser?.updatePhotoURL(photoURL);
    }
    await _auth.currentUser?.reload();
  }

  // Update email (verify before updating)
  Future<void> updateEmail(String newEmail) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete auth account
      await user.delete();
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Reload user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? role,
  }) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'phone': phone ?? '',
        'address': address ?? '',
        'photoURL': user.photoURL ?? '',
        'role': role ?? 'Farmer', // Default role
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'preferences': {
          'notifications': true,
          'language': 'en',
        },
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
    } catch (e) {
      print('Error creating user document: $e');
      // Don't throw - allow auth to continue even if Firestore fails
    }
  }

  // Update last login time
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
      // Don't throw - allow auth to continue even if Firestore update fails
    }
  }

  // Handle authentication exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please log out and log back in before changing sensitive information.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'preferences': preferences,
      });
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final userData = await getUserData(user.uid);
      return userData?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }
}

