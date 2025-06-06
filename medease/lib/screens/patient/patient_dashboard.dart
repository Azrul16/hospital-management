import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import 'widgets/doctor_card.dart';
import 'widgets/appointment_card.dart';
import 'patient_doctors_page.dart';
import 'patient_appointments_page.dart';
import 'patient_profile_page.dart';

class PatientDashboardScreen extends StatefulWidget {
  final String patientId;

  PatientDashboardScreen({required this.patientId});

  @override
  _PatientDashboardScreenState createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;

  final FirebaseService _firebaseService = FirebaseService();

  void _onRequestAppointment(String doctorId, String symptoms) async {
    await _firebaseService.requestAppointment(
      doctorId,
      widget.patientId,
      symptoms,
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
