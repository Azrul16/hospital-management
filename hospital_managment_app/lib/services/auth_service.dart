import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register patient
  Future<User?> registerPatient(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // Login user (patient or doctor)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) throw Exception('Login failed');

      // Check if user is a doctor
      final doctorDoc =
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(result.user!.uid)
              .get();

      if (doctorDoc.exists) {
        return {
          'user': result.user,
          'type': 'doctor',
          'data': doctorDoc.data(),
        };
      }

      // Check if user is a patient
      final patientDoc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(result.user!.uid)
              .get();

      if (patientDoc.exists) {
        return {
          'user': result.user,
          'type': 'patient',
          'data': patientDoc.data(),
        };
      }

      throw Exception('User type not found');
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Delete current user
  Future<void> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
