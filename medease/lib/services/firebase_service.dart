import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user with email and password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } catch (e) {
      print('Error in registerWithEmailPassword: $e');
      return null;
    }
  }

  // Login user with email and password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } catch (e) {
      print('Error in loginWithEmailPassword: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Add additional user info to Firestore
  Future<void> addUserInfo(String uid, Map<String, dynamic> userInfo) async {
    try {
      await _firestore.collection('users').doc(uid).set(userInfo);
    } catch (e) {
      print('Error adding user info: $e');
      rethrow;
    }
  }

  // Add doctor info to Firestore
  Future<void> addDoctorInfo(
    String uid,
    Map<String, dynamic> doctorInfo,
  ) async {
    try {
      await _firestore.collection('doctors').doc(uid).set(doctorInfo);
    } catch (e) {
      print('Error adding doctor info: $e');
      rethrow;
    }
  }

  // Fetch doctors list as a stream
  Stream<QuerySnapshot> getDoctors() {
    return _firestore.collection('doctors').snapshots();
  }

  // Placeholder for other Firestore methods for appointments, prescriptions, etc.

  // Request an appointment
  Future<void> requestAppointment(
    String doctorId,
    String patientId,
    String symptoms,
  ) async {
    try {
      await _firestore.collection('appointments').add({
        'doctorId': doctorId,
        'patientId': patientId,
        'symptoms': symptoms,
        'status': 'pending',
        'dateTime': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error requesting appointment: $e');
      rethrow;
    }
  }
}
