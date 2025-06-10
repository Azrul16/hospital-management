import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medease/screens/admin/admin_dashboard.dart';
import 'package:medease/screens/doctor/doctor_dashboard.dart';
import 'package:medease/screens/patient/patient_dashboard.dart';
import 'package:medease/screens/patient/patient_registration.dart';
import 'package:medease/widgets/web_layout.dart';

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
            setState(() {
              errorMessage = 'Unauthorized user role';
            });
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
            setState(() {
              errorMessage =
                  'No user data found in users or doctors collection';
            });
          }
        }
      } else {
        setState(() {
          errorMessage = 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Login failed: ${e.toString()}';
      });
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
    return WebLayout(
      title: 'Login - MedEase',
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_hospital,
                        size: 72,
                        color: Colors.blue.shade700,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Welcome to MedEase',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
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
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
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
                      SizedBox(height: 32),
                      if (errorMessage.isNotEmpty)
                        Text(errorMessage, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading ? null : _login,
                          child:
                              isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18),
                                  ),
                        ),
                      ),
                      SizedBox(height: 20),
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
      ),
    );
  }
}
