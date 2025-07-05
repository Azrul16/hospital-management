import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class PatientLoginScreen extends StatefulWidget {
  @override
  _PatientLoginScreenState createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String email = '';
  String password = '';

  bool isLoading = false;
  String errorMessage = '';

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      var user = await _firebaseService.loginWithEmailPassword(email, password);
      if (user != null) {
        // Navigate to patient home or doctor browsing screen
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = 'Login failed. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => email = val,
                validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
              ),
              SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading ? CircularProgressIndicator() : Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
