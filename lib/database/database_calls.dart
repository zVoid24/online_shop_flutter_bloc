import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signInWithEmail({
    required String password,
    required String email,
  }) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow; // Let the caller handle the exception
    }
  }
}
