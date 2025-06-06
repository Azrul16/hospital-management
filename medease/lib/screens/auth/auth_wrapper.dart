// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../patient/patient_dashboard.dart';
// import '../doctor/doctor_dashboard.dart';
// import '../admin/admin_dashboard.dart';

// class AuthWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           final user = snapshot.data;
//           if (user == null) {
//             // User not logged in, show login screen or redirect
//             return LoginScreen(); // Replace with your login screen
//           } else {
//             // User logged in, determine role and route accordingly
//             // For example, fetch user role from Firestore or user claims
//             // Here, assuming a function getUserRole() that returns 'patient', 'doctor', or 'admin'
//             return FutureBuilder<String>(
//               future: getUserRole(user.uid),
//               builder: (context, roleSnapshot) {
//                 if (roleSnapshot.connectionState == ConnectionState.done) {
//                   final role = roleSnapshot.data;
//                   if (role == 'patient') {
//                     return PatientDashboardScreen(patientId: user.uid);
//                   } else if (role == 'doctor') {
//                     return DoctorDashboardScreen(doctorId: user.uid);
//                   } else if (role == 'admin') {
//                     return AdminDashboardScreen();
//                   } else {
//                     return Center(child: Text('Unknown user role'));
//                   }
//                 } else {
//                   return Center(child: CircularProgressIndicator());
//                 }
//               },
//             );
//           }
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }

//   Future<String> getUserRole(String uid) async {
//     // Implement fetching user role from Firestore or other source
//     // Example:
//     // var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     // return doc.data()?['role'] ?? 'patient';
//     return 'patient'; // Placeholder
//   }
// }

// // Placeholder login screen widget
// class LoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: Text('Login Screen - Implement your login UI here')),
//     );
//   }
// }
