import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  @override
  _DoctorRegistrationScreenState createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String email = '';
  String password = '';
  String name = '';
  String specialization = '';
  String availability = '';

  bool isLoading = false;
  String errorMessage = '';

  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      var user = await _firebaseService.registerWithEmailPassword(
        email,
        password,
      );
      if (user != null) {
        await _firebaseService.addDoctorInfo(user.uid, {
          'email': email,
          'name': name,
          'specialization': specialization,
          'availability': availability,
          'role': 'doctor',
          'createdAt': DateTime.now(),
        });
        // Navigate to doctor dashboard or login screen
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = 'Registration failed. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor Registration')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (val) => name = val,
                validator:
                    (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : 'Enter your name',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => email = val,
                validator:
                    (val) =>
                        val != null && val.contains('@')
                            ? null
                            : 'Enter a valid email',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator:
                    (val) =>
                        val != null && val.length >= 6
                            ? null
                            : 'Password must be at least 6 characters',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Specialization'),
                onChanged: (val) => specialization = val,
                validator:
                    (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : 'Enter your specialization',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Availability'),
                onChanged: (val) => availability = val,
                validator:
                    (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : 'Enter your availability',
              ),
              SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: isLoading ? null : register,
                child:
                    isLoading ? CircularProgressIndicator() : Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
