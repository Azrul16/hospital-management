import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medease/screens/admin/admin_dashboard.dart';
import 'package:medease/screens/doctor/doctor_dashboard.dart';
import 'package:medease/screens/forgot_pass.dart';
import 'package:medease/screens/patient/patient_dashboard.dart';
import 'package:medease/screens/patient/patient_registration.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  final String adminEmail = 'admin@gmail.com';
  final String adminPassword = '@admin123';

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      if (email == adminEmail && password == adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
        return;
      }

      // Firebase Auth login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in 'users' collection
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final role = data['role'];

          if (role == 'patient') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PatientDashboardScreen(patientId: user.uid),
              ),
            );
          } else {
            _showError('Unauthorized user role');
          }
        } else {
          // If not in 'users', check in 'doctors' collection
          DocumentSnapshot doctorDoc =
              await _firestore.collection('doctors').doc(user.uid).get();

          if (doctorDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDashboardScreen(doctorId: user.uid),
              ),
            );
          } else {
            _showError('No user data found in users or doctors collection');
          }
        }
      } else {
        _showError('Authentication failed');
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No user found for that email.';
          break;
        case 'wrong-password':
          msg = 'Incorrect password.';
          break;
        case 'invalid-email':
          msg = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
          msg = 'This user has been disabled.';
          break;
        default:
          msg = 'Login failed: ${e.message}';
      }
      _showError(msg);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _goToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PatientRegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F0F9),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 64,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to MedEase',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => email = val.trim(),
                      validator:
                          (val) =>
                              val != null && val.contains('@')
                                  ? null
                                  : 'Enter a valid email',
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      onChanged: (val) => password = val,
                      validator:
                          (val) =>
                              val != null && val.length >= 6
                                  ? null
                                  : 'Password must be at least 6 characters',
                    ),
                    SizedBox(height: 24),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _login,
                        child:
                            isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            ),
                          },
                      child: Text(
                        "Forgot Password? Reset here",
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: _goToRegistration,
                      child: Text("Don't have an account? Register here"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
