import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import 'widgets/appointment_request_card.dart';

class AppointmentRequestsScreen extends StatefulWidget {
  @override
  _AppointmentRequestsScreenState createState() => _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState extends State<AppointmentRequestsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPendingAppointments() {
    return _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  void updateAppointmentStatus(String appointmentId, String status, {String? comment}) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
      'doctorComment': comment ?? '',
      'responseTime': FieldValue.serverTimestamp(),
    });
  }

  void _showRejectDialog(String appointmentId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Appointment'),
        content: TextField(
          controller: commentController,
          decoration: InputDecoration(hintText: 'Add a comment (optional)'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              updateAppointmentStatus(appointmentId, 'rejected', comment: commentController.text);
              Navigator.pop(context);
            },
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPendingAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading appointments'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final appointments = snapshot.data!.docs;
          if (appointments.isEmpty) {
            return Center(child: Text('No pending appointment requests'));
          }
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              var data = appointment.data() as Map<String, dynamic>;
              return AppointmentRequestCard(
                patientName: data['patientName'] ?? 'Unknown',
                dateTime: data['dateTime'] ?? 'N/A',
                symptoms: data['symptoms'] ?? '',
                onAccept: () {
                  updateAppointmentStatus(appointment.id, 'accepted');
                },
                onReject: () {
                  _showRejectDialog(appointment.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
