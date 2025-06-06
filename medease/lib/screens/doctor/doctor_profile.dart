import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medease/screens/auth/auth_wrapper.dart';
import 'package:medease/services/firebase_service.dart';
import 'package:medease/screens/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  DoctorProfileScreen({required this.doctorId});

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _specializationController;
  late TextEditingController _availabilityController;
  late TextEditingController _phoneController;

  bool _hasChanges = false;

  late String _originalName;
  late String _originalSpecialization;
  late String _originalAvailability;
  late String _originalPhone;

  final List<String> _specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'General Surgery',
    'Orthopedics',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _specializationController = TextEditingController();
    _availabilityController = TextEditingController();
    _phoneController = TextEditingController();

    _loadDoctorData();

    _nameController.addListener(_onFieldChanged);
    _specializationController.addListener(_onFieldChanged);
    _availabilityController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _loadDoctorData() async {
    var doc = await _firestore.collection('doctors').doc(widget.doctorId).get();
    if (doc.exists) {
      var data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _specializationController.text = data['specialization'] ?? '';
      _availabilityController.text = data['availability'] ?? '';
      _phoneController.text = data['phone'] ?? '';

      _originalName = _nameController.text;
      _originalSpecialization = _specializationController.text;
      _originalAvailability = _availabilityController.text;
      _originalPhone = _phoneController.text;

      setState(() {});
    }
  }

  void _onFieldChanged() {
    bool changed =
        _nameController.text != _originalName ||
        _specializationController.text != _originalSpecialization ||
        _availabilityController.text != _originalAvailability ||
        _phoneController.text != _originalPhone;
    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  void _saveProfile() async {
    await _firestore.collection('doctors').doc(widget.doctorId).update({
      'name': _nameController.text,
      'specialization': _specializationController.text,
      'availability': _availabilityController.text,
      'phone': _phoneController.text,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    _originalName = _nameController.text;
    _originalSpecialization = _specializationController.text;
    _originalAvailability = _availabilityController.text;
    _originalPhone = _phoneController.text;
    setState(() {
      _hasChanges = false;
    });
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        enabled: enabled,
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 50),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/avatar/doctormale.png'),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_emailController, 'Email', enabled: false),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DropdownButtonFormField<String>(
                value:
                    _specializationController.text.isNotEmpty
                        ? _specializationController.text
                        : null,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _specializations.map((spec) {
                      return DropdownMenuItem<String>(
                        value: spec,
                        child: Text(spec),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _specializationController.text = value!;
                  });
                },
              ),
            ),
            _buildTextField(_availabilityController, 'Availability'),
            _buildTextField(
              _phoneController,
              'Phone',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            if (_hasChanges)
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: Icon(Icons.save),
                label: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseService().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
