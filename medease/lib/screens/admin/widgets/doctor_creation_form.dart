import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorCreationForm extends StatefulWidget {
  @override
  _DoctorCreationFormState createState() => _DoctorCreationFormState();
}

class _DoctorCreationFormState extends State<DoctorCreationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController availabilityController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  String? selectedSpecialization;

  final List<String> specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'General Surgery',
    'Orthopedics',
  ];

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          errorMessage = 'Passwords do not match.';
        });
        return;
      }

      if (selectedSpecialization == null) {
        setState(() {
          errorMessage = 'Please select a specialization.';
        });
        return;
      }

      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        // ✅ Step 1: Register doctor in Firebase Authentication
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        final user = userCredential.user;
        if (user == null) throw Exception("User creation failed.");

        // ✅ Step 2: Save doctor details in Firestore under `doctors` collection
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'specialization': selectedSpecialization,
              'availability': availabilityController.text.trim(),
              'role': 'doctor',
            });

        // ✅ Step 3: Clear form
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        availabilityController.clear();
        setState(() {
          selectedSpecialization = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor registered successfully')),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'email-already-in-use') {
            errorMessage = 'Email is already registered.';
          } else if (e.code == 'invalid-email') {
            errorMessage = 'Invalid email address.';
          } else {
            errorMessage = 'Auth error: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Unexpected error: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Doctor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (val) =>
                        val != null && val.contains('@')
                            ? null
                            : 'Enter a valid email',
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (val) =>
                        val != null && val.length >= 6
                            ? null
                            : 'Password must be at least 6 characters',
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (val) =>
                        val != null && val.length >= 6
                            ? null
                            : 'Confirm your password',
              ),
              SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedSpecialization,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                ),
                items:
                    specializations.map((spec) {
                      return DropdownMenuItem<String>(
                        value: spec,
                        child: Text(spec),
                      );
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedSpecialization = val;
                  });
                },
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please select specialization'
                            : null,
              ),

              SizedBox(height: 12),
              TextFormField(
                controller: availabilityController,
                decoration: InputDecoration(
                  labelText: 'Availability',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter availability'
                            : null,
              ),
              SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Add Doctor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
