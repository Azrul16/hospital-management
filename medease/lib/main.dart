import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medease/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/patient/patient_registration.dart';
import 'screens/patient/patient_login.dart';
import 'screens/doctor/doctor_login.dart';
import 'screens/doctor/appointment_requests.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MedEaseApp());
}

class MedEaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedEase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/patient_registration': (context) => PatientRegistrationScreen(),
        '/patient_login': (context) => PatientLoginScreen(),
        '/patient_dashboard':
            (context) => PatientDashboardScreen(patientId: 'samplePatientId'),
        '/doctor_login': (context) => DoctorLoginScreen(),
        '/doctor_appointments': (context) => AppointmentRequestsScreen(),
        '/doctor_dashboard':
            (context) => DoctorDashboardScreen(doctorId: 'sampleDoctorId'),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
      },
    );
  }
}
