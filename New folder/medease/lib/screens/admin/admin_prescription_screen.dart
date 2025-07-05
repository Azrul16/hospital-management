import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_prescription_detail_screen.dart';

class AdminPrescriptionScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPrescriptions() {
    return _firestore
        .collection('prescriptions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getAppointmentData(String appointmentId) async {
    final doc =
        await _firestore.collection('appointments').doc(appointmentId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPatientData(String patientId) async {
    final doc = await _firestore.collection('users').doc(patientId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prescriptions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading prescriptions'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final prescriptions = snapshot.data!.docs;
          if (prescriptions.isEmpty) {
            return Center(child: Text('No prescriptions found'));
          }
          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              var prescription = prescriptions[index];
              var data = prescription.data() as Map<String, dynamic>;
              return FutureBuilder<Map<String, dynamic>?>(
                future: getAppointmentData(data['appointmentId'] ?? ''),
                builder: (context, appointmentSnapshot) {
                  if (appointmentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  if (!appointmentSnapshot.hasData ||
                      appointmentSnapshot.data == null) {
                    return ListTile(title: Text('Appointment data not found'));
                  }
                  final appointmentData = appointmentSnapshot.data!;
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: getPatientData(appointmentData['patientId'] ?? ''),
                    builder: (context, patientSnapshot) {
                      if (patientSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(title: Text('Loading...'));
                      }
                      if (!patientSnapshot.hasData ||
                          patientSnapshot.data == null) {
                        return ListTile(title: Text('Patient data not found'));
                      }
                      final patientData = patientSnapshot.data!;
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        child: ListTile(
                          title: Text(
                            'Prescription for ${patientData['name'] ?? 'Unknown'}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Symptoms: ${appointmentData['symptoms'] ?? 'N/A'}',
                              ),
                              Text(
                                'Medication: ${data['medication'] ?? 'N/A'}',
                              ),
                              Text('Dosage: ${data['dosage'] ?? 'N/A'}'),
                              Text('Advice: ${data['advice'] ?? 'N/A'}'),
                              Text(
                                'Date: ${data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toString() : 'N/A'}',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => AdminPrescriptionDetailScreen(
                                      prescriptionId: prescription.id,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
