import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_appointment_detail_screen.dart';

class AdminAppointmentScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading appointments'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final appointments = snapshot.data!.docs;
          if (appointments.isEmpty) {
            return Center(child: Text('No appointments found'));
          }
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              var data = appointment.data() as Map<String, dynamic>;
              bool isComplete = data['status'] == 'completed';
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                color: isComplete ? Colors.green[100] : Colors.red[100],
                child: ListTile(
                  title: Text(
                    'Appointment with Dr. ${data['doctorName'] ?? 'Unknown'}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient ID: ${data['patientId'] ?? 'N/A'}'),
                      Text('Symptoms: ${data['symptoms'] ?? 'N/A'}'),
                      Text('Status: ${data['status'] ?? 'N/A'}'),
                      if (data['doctorComment'] != null &&
                          data['doctorComment'].isNotEmpty)
                        Text('Doctor Comment: ${data['doctorComment']}'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => AdminAppointmentDetailScreen(
                              appointmentId: appointment.id,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
