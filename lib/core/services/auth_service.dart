import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((User? user) async {
        if (user == null) return null;
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          return UserModel.fromMap(userData.data()!);
        }
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          createdAtDateTime: DateTime.now(),
        );
      });

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user == null) throw FirebaseAuthException(code: 'null-user');

      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        return UserModel.fromMap(userData.data()!);
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        createdAtDateTime: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: message);
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user == null) throw FirebaseAuthException(code: 'null-user');

      // Update display name
      await user.updateDisplayName(displayName);

      // Create user model
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        createdAtDateTime: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final userData = await _firestore.collection('users').doc(user.uid).get();
    if (userData.exists) {
      return UserModel.fromMap(userData.data()!);
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      createdAtDateTime: DateTime.now(),
    );
  }
}
