import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminAppointmentDetailScreen({required this.appointmentId});

  Future<DocumentSnapshot> getAppointmentDetails() {
    return _firestore.collection('appointments').doc(appointmentId).get();
  }

  Future<DocumentSnapshot> getDoctorDetails(String doctorId) {
    return _firestore.collection('doctors').doc(doctorId).get();
  }

  Future<DocumentSnapshot> getPatientDetails(String patientId) {
    return _firestore.collection('users').doc(patientId).get();
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      String formattedTime = DateFormat.jm().format(dt); // e.g., 10:30 AM
      String formattedDate = DateFormat(
        'dd MMMM yyyy',
      ).format(dt); // e.g., 04 June 2025
      return '$formattedTime\n$formattedDate';
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
      future: getAppointmentDetails(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorScaffold('Error loading appointment details');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _loadingScaffold();
        }

        var appointmentData = snapshot.data!.data() as Map<String, dynamic>;

        return FutureBuilder<DocumentSnapshot>(
          future: getDoctorDetails(appointmentData['doctorId']),
          builder: (context, doctorSnapshot) {
            if (doctorSnapshot.hasError) {
              return _errorScaffold('Error loading doctor details');
            }
            if (!doctorSnapshot.hasData || !doctorSnapshot.data!.exists) {
              return _loadingScaffold();
            }

            var doctorData =
                doctorSnapshot.data!.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: getPatientDetails(appointmentData['patientId']),
              builder: (context, patientSnapshot) {
                if (patientSnapshot.hasError) {
                  return _errorScaffold('Error loading patient details');
                }
                if (!patientSnapshot.hasData || !patientSnapshot.data!.exists) {
                  return _loadingScaffold();
                }

                var patientData =
                    patientSnapshot.data!.data() as Map<String, dynamic>;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Appointment Details'),
                    backgroundColor: Colors.teal,
                    elevation: 4,
                  ),
                  backgroundColor: Colors.grey[100],
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          'Doctor',
                          '${doctorData['name'] ?? 'N/A'}\nSpecialization: ${doctorData['specialization'] ?? 'N/A'}',
                        ),
                        _buildInfoCard(
                          'Patient',
                          '${patientData['name'] ?? 'N/A'}\nEmail: ${patientData['email'] ?? 'N/A'}\nMobile: ${patientData['mobileNumber'] ?? 'N/A'}',
                        ),
                        _buildInfoCard(
                          'Symptoms',
                          appointmentData['symptoms'] ?? 'N/A',
                        ),
                        _buildInfoCard(
                          'Date & Time',
                          _formatDateTime(appointmentData['dateTime'] ?? 'N/A'),
                        ),
                        _buildInfoCard(
                          'Status',
                          appointmentData['status'] ?? 'N/A',
                        ),
                        if (appointmentData['doctorComment'] != null &&
                            appointmentData['doctorComment']
                                .toString()
                                .isNotEmpty)
                          _buildInfoCard(
                            'Doctor Comment',
                            appointmentData['doctorComment'],
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
      appBar: AppBar(title: const Text('Appointment Details')),
      body: Center(child: Text(message)),
    );
  }

  Widget _loadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
