import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Database {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateMail({required String email,required String password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if(user!.providerData.any((info) => info.providerId == 'password')){
        final credential = EmailAuthProvider.credential(
          email: user.email ?? '',
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        debugPrint('Re-authenticated user: ${user.email}');
      }
      await user.verifyBeforeUpdateEmail(email);
        } catch (e) {
      throw Exception(e);
    }
  }

  bool isPasswordProvider() {
    return _firebaseAuth.currentUser?.providerData.any((info) => info.providerId == 'password') ?? false;
  }

  String? get email {
    // Replace with the actual logic to retrieve the email
    return FirebaseAuth.instance.currentUser?.email;
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-in: $e');
    }
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (result.user != null) {
        return result.user;
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-up: $e');
    }
    return null;
  }

  String _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password must be at least 6 characters long.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      return user;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
