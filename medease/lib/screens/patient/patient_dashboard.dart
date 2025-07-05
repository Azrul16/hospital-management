import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import 'widgets/doctor_card.dart';
import 'widgets/appointment_card.dart';
import 'patient_doctors_page.dart';
import 'patient_appointments_page.dart';
import 'patient_profile_page.dart';

import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'widgets/doctor_card.dart';
import 'widgets/appointment_card.dart';
import 'patient_doctors_page.dart';
import 'patient_appointments_page.dart';
import 'patient_profile_page.dart';
import '../../widgets/web_layout.dart';

class PatientDashboardScreen extends StatefulWidget {
  final String patientId;

  PatientDashboardScreen({required this.patientId});

  @override
  _PatientDashboardScreenState createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;

  final FirebaseService _firebaseService = FirebaseService();

  void _onRequestAppointment(
    String doctorId,
    String symptoms, [
    String? doctorComment,
  ]) async {
    await _firebaseService.requestAppointment(
      doctorId,
      widget.patientId,
      symptoms,
      doctorComment: doctorComment,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment requested successfully')),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      PatientDoctorsPage(
        patientId: widget.patientId,
        onRequestAppointment: _onRequestAppointment,
      ),
      PatientAppointmentsPage(patientId: widget.patientId),
      PatientProfilePage(patientId: widget.patientId),
    ];

    return WebLayout(
      title: 'Patient Dashboard',
      child: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.teal.shade50,
            selectedIconTheme: IconThemeData(color: Colors.teal.shade700),
            selectedLabelTextStyle: TextStyle(color: Colors.teal.shade700),
            unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
            unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.local_hospital),
                label: Text('Doctors'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Appointments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
