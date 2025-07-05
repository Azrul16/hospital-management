import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPrescriptionDetailScreen extends StatelessWidget {
  final String prescriptionId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminPrescriptionDetailScreen({required this.prescriptionId});

  Future<DocumentSnapshot> getPrescriptionDetails() {
    return _firestore.collection('prescriptions').doc(prescriptionId).get();
  }

  Future<DocumentSnapshot> getAppointmentDetails(String appointmentId) {
    return _firestore.collection('appointments').doc(appointmentId).get();
  }

  Future<DocumentSnapshot> getPatientDetails(String patientId) {
    return _firestore.collection('users').doc(patientId).get();
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      String time = DateFormat.jm().format(dt);
      String date = DateFormat('dd MMMM yyyy').format(dt);
      return '$time\n$date';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getPrescriptionDetails(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return _errorScaffold('Error loading prescription details');
        if (!snapshot.hasData || !snapshot.data!.exists)
          return _loadingScaffold();

        var prescriptionData = snapshot.data!.data() as Map<String, dynamic>;

        return FutureBuilder<DocumentSnapshot>(
          future: getAppointmentDetails(prescriptionData['appointmentId']),
          builder: (context, appointmentSnapshot) {
            if (appointmentSnapshot.hasError)
              return _errorScaffold('Error loading appointment details');
            if (!appointmentSnapshot.hasData ||
                !appointmentSnapshot.data!.exists)
              return _loadingScaffold();

            var appointmentData =
                appointmentSnapshot.data!.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: getPatientDetails(appointmentData['patientId']),
              builder: (context, patientSnapshot) {
                if (patientSnapshot.hasError)
                  return _errorScaffold('Error loading patient details');
                if (!patientSnapshot.hasData || !patientSnapshot.data!.exists)
                  return _loadingScaffold();

                var patientData =
                    patientSnapshot.data!.data() as Map<String, dynamic>;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Prescription Details'),
                    backgroundColor: Colors.teal,
                  ),
                  backgroundColor: Colors.grey[100],
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          'Patient Name',
                          patientData['name'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Symptoms',
                          appointmentData['symptoms'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Medication',
                          prescriptionData['medication'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Dosage',
                          prescriptionData['dosage'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Advice',
                          prescriptionData['advice'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Appointment Status',
                          appointmentData['status'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Appointment Date & Time',
                          _formatDateTime(appointmentData['dateTime'] ?? 'N/A'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _errorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Details')),
      body: Center(child: Text(message)),
    );
  }

  Widget _loadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Details')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
