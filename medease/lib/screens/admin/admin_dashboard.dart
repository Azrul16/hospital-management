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
import 'package:medease/widgets/web_layout.dart';

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
                fontSize: 22,
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
                    fontSize: 36,
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
    int _selectedIndex = 0;

    Widget _getSelectedPage() {
      switch (_selectedIndex) {
        case 0:
          return AdminDoctorScreen();
        case 1:
          return AdminPatientScreen();
        case 2:
          return AdminAppointmentScreen();
        case 3:
          return AdminPrescriptionScreen();
        case 4:
          return AdminActivityScreen();
        default:
          return Container();
      }
    }

    return WebLayout(
      title: 'Admin Dashboard - MedEase',
      child: StatefulBuilder(
        builder: (context, setState) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.blue.shade50,
                selectedIconTheme: IconThemeData(color: Colors.blue.shade800),
                selectedLabelTextStyle: TextStyle(color: Colors.blue.shade800),
                unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
                unselectedLabelTextStyle: TextStyle(
                  color: Colors.grey.shade600,
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.medical_services_outlined),
                    label: Text('Doctors'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_alt_outlined),
                    label: Text('Patients'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event_note_outlined),
                    label: Text('Appointments'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.description_outlined),
                    label: Text('Prescriptions'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.timeline),
                    label: Text('Activity'),
                  ),
                ],
              ),
              VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, Admin',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 32),
                      Expanded(child: _getSelectedPage()),
                      SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.logout),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          onPressed:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
