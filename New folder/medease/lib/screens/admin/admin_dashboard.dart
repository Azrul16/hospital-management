import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medease/models/patient.dart';
import 'package:medease/screens/admin/admin_appointment_screen.dart';
import 'package:medease/screens/admin/admin_doctor_screen.dart';
import 'package:medease/screens/admin/admin_activity_screen.dart';
import 'package:medease/screens/admin/admin_prescription_screen.dart';
import 'package:medease/screens/admin/widgets/patient_card.dart';
import 'package:medease/screens/admin/widgets/patient_list.dart';
import 'package:medease/screens/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildSummaryCard({
    required String title,
    required AsyncSnapshot<QuerySnapshot> snapshot,

    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    int count = 0;
    if (snapshot.hasData) {
      count = snapshot.data!.docs.length;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 12),
            snapshot.connectionState == ConnectionState.waiting
                ? CircularProgressIndicator(color: color)
                : Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Dashboard Title + Welcome or Info can be added here
            Text(
              'Welcome Back, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 24),

            // Expanded Grid for cards fills available space
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 4 / 5,
                ),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('doctors').snapshots(),
                    builder: (context, snapshot) {
                      return _buildSummaryCard(
                        title: 'Doctors',
                        snapshot: snapshot,
                        color: Colors.teal,
                        icon: Icons.medical_services_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminDoctorScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      return _buildSummaryCard(
                        title: 'Patients',
                        snapshot: snapshot,
                        color: Colors.deepPurple,
                        icon: Icons.people_alt_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminPatientScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('appointments').snapshots(),
                    builder: (context, snapshot) {
                      return _buildSummaryCard(
                        title: 'Appointments',
                        snapshot: snapshot,
                        color: Colors.orange.shade700,
                        icon: Icons.event_note_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminAppointmentScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('prescriptions').snapshots(),
                    builder: (context, snapshot) {
                      return _buildSummaryCard(
                        title: 'Prescriptions',
                        snapshot: snapshot,
                        color: Colors.redAccent,
                        icon: Icons.description_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminPrescriptionScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        _firestore
                            .collection('appointments')
                            .orderBy('createdAt', descending: true)
                            .limit(20)
                            .snapshots(),
                    builder: (context, snapshot) {
                      return _buildSummaryCard(
                        title: 'Recent Activity',
                        snapshot: snapshot,
                        color: Colors.blueGrey,
                        icon: Icons.timeline,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminActivityScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout Button fixed at bottom with spacing
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy placeholder classes — replace with your actual screen implementations

class AdminPatientScreen extends StatelessWidget {
  const AdminPatientScreen({super.key});

  Stream<QuerySnapshot> getPatients() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Patient Management'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: getPatients(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading patients'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final patientDocs = snapshot.data!.docs;

            if (patientDocs.isEmpty) {
              return const Center(child: Text('No patients found.'));
            }

            final patients =
                patientDocs.map((doc) {
                  return Patient.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

            return ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                return PatientCard(patient: patients[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
