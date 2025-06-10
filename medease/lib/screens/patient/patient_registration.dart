import 'package:flutter/material.dart';
import 'package:medease/widgets/web_layout.dart';
import '../../services/firebase_service.dart';

class PatientRegistrationScreen extends StatefulWidget {
  @override
  _PatientRegistrationScreenState createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String name = '';
  String mobileNumber = '';
  String age = '';
  String gender = '';

  bool isLoading = false;
  String errorMessage = '';

  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        // Create user in Firebase Auth
        var user = await _firebaseService.registerWithEmailPassword(
          email,
          password,
        );

        if (user != null) {
          // Save additional info in Firestore (users collection)
          await _firebaseService.addUserInfo(user.uid, {
            'email': email,
            'name': name,
            'mobileNumber': mobileNumber,
            'age': age,
            'gender': gender,
            'role': 'patient',
            'createdAt': DateTime.now(),
          });

          // Navigate back or to home after successful registration
          Navigator.pop(context);
        } else {
          setState(() {
            errorMessage = 'Registration failed. Please try again.';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Patient Registration - MedEase',
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        size: 56,
                        color: Colors.blue.shade700,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        decoration: _inputDecoration(
                          'Name',
                          icon: Icons.person,
                        ),
                        onChanged: (val) => name = val,
                        validator:
                            (val) =>
                                val != null && val.isNotEmpty
                                    ? null
                                    : 'Enter your name',
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration(
                          'Mobile Number',
                          icon: Icons.phone,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => mobileNumber = val,
                        validator:
                            (val) =>
                                val != null && val.length >= 10
                                    ? null
                                    : 'Enter a valid mobile number',
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration(
                          'Email',
                          icon: Icons.email,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val,
                        validator:
                            (val) =>
                                val != null && val.contains('@')
                                    ? null
                                    : 'Enter a valid email',
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration(
                          'Age',
                          icon: Icons.calendar_today,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => age = val,
                        validator:
                            (val) =>
                                val != null && val.isNotEmpty
                                    ? null
                                    : 'Enter your age',
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Gender', icon: Icons.wc),
                        items:
                            ['Male', 'Female', 'Others']
                                .map(
                                  (gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => gender = val ?? '',
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Select your gender'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration(
                          'Password',
                          icon: Icons.lock,
                        ),
                        obscureText: true,
                        onChanged: (val) => password = val,
                        validator:
                            (val) =>
                                val != null && val.length >= 6
                                    ? null
                                    : 'Password must be at least 6 characters',
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration(
                          'Confirm Password',
                          icon: Icons.lock_outline,
                        ),
                        obscureText: true,
                        onChanged: (val) => confirmPassword = val,
                        validator:
                            (val) =>
                                val != password
                                    ? 'Passwords do not match'
                                    : null,
                      ),
                      SizedBox(height: 24),
                      if (errorMessage.isNotEmpty)
                        Text(errorMessage, style: TextStyle(color: Colors.red)),
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
                          onPressed: isLoading ? null : register,
                          child:
                              isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Register',
                                    style: TextStyle(fontSize: 18),
                                  ),
                        ),
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
