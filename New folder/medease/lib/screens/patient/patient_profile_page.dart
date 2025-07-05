import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medease/screens/login_screen.dart';
import 'package:medease/services/firebase_service.dart';

class PatientProfilePage extends StatefulWidget {
  final String patientId;

  PatientProfilePage({required this.patientId});

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _ageController;
  late TextEditingController _medicalHistoryController;

  String _selectedGender = 'Male';

  // Provide default values to avoid late initialization errors
  String _originalName = '';
  String _originalMobile = '';
  String _originalAge = '';
  String _originalGender = 'Male';
  String _originalMedicalHistory = '';

  bool _hasChanges = false;
  bool _isLoading = true; // <-- Add loading state

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _ageController = TextEditingController();
    _medicalHistoryController = TextEditingController();

    _nameController.addListener(_onFieldChanged);
    _mobileController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _medicalHistoryController.addListener(_onFieldChanged);

    _loadPatientData();
  }

  void _onFieldChanged() {
    // Only check for changes after data has loaded
    if (_isLoading) return;
    bool changed =
        _nameController.text != _originalName ||
        _mobileController.text != _originalMobile ||
        _ageController.text != _originalAge ||
        _selectedGender != _originalGender ||
        _medicalHistoryController.text != _originalMedicalHistory;

    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  void _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });
    var doc = await _firestore.collection('users').doc(widget.patientId).get();
    if (doc.exists) {
      var data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _mobileController.text = data['mobileNumber'] ?? '';
      _ageController.text = data['age'] ?? '';
      _selectedGender = data['gender'] ?? 'Male';
      _medicalHistoryController.text = data['medicalHistory'] ?? '';

      _originalName = _nameController.text;
      _originalMobile = _mobileController.text;
      _originalAge = _ageController.text;
      _originalGender = _selectedGender;
      _originalMedicalHistory = _medicalHistoryController.text;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _saveProfile() async {
    await _firestore.collection('users').doc(widget.patientId).update({
      'name': _nameController.text,
      'mobileNumber': _mobileController.text,
      'age': _ageController.text,
      'gender': _selectedGender,
      'medicalHistory': _medicalHistoryController.text,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));

    _originalName = _nameController.text;
    _originalMobile = _mobileController.text;
    _originalAge = _ageController.text;
    _originalGender = _selectedGender;
    _originalMedicalHistory = _medicalHistoryController.text;

    setState(() {
      _hasChanges = false;
    });
  }

  Widget _buildAvatar() {
    String lower = _selectedGender.toLowerCase();
    if (lower == 'male') {
      return Image.asset('assets/avatar/male.png', width: 120, height: 120);
    } else if (lower == 'female') {
      return Image.asset('assets/avatar/female.png', width: 120, height: 120);
    } else {
      return SizedBox(height: 120); // or use a neutral avatar
    }
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => true,
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                  color: Colors.teal.shade50,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      Center(child: _buildAvatar()),
                      SizedBox(height: 16),
                      _buildCard(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                      ),
                      // Uncomment if you want to show email
                      // _buildCard(
                      //   child: TextField(
                      //     controller: _emailController,
                      //     decoration: InputDecoration(labelText: 'Email'),
                      //     enabled: false,
                      //   ),
                      // ),
                      _buildCard(
                        child: TextField(
                          controller: _mobileController,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _buildCard(
                        child: TextField(
                          controller: _ageController,
                          decoration: InputDecoration(labelText: 'Age'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      _buildCard(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          items:
                              ['Male', 'Female', 'Other']
                                  .map(
                                    (gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                              _onFieldChanged();
                            });
                          },
                          decoration: InputDecoration(labelText: 'Gender'),
                        ),
                      ),
                      _buildCard(
                        child: TextField(
                          controller: _medicalHistoryController,
                          decoration: InputDecoration(
                            labelText: 'Medical History',
                          ),
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_hasChanges)
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseService().signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Logout', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
