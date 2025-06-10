import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medease/widgets/web_layout.dart';

class PatientAppointmentsPage extends StatelessWidget {
  final String patientId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PatientAppointmentsPage({required this.patientId});

  Stream<QuerySnapshot> getAppointments() {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'completed':
        return const Color.fromARGB(255, 0, 204, 7);
      default:
        return Colors.orange.shade700;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is String) return timestamp;
    if (timestamp is Timestamp) {
      DateTime dt = timestamp.toDate();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
    }
    return 'Invalid time';
  }

  Widget _buildDialogRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade700),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetailsDialog(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 40,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDialogRow(
                    icon: Icons.person,
                    label: 'Doctor',
                    value: data['doctorName'] ?? 'N/A',
                  ),
                  _buildDialogRow(
                    icon: Icons.report_problem,
                    label: 'Symptoms',
                    value: data['symptoms'] ?? 'N/A',
                  ),
                  _buildDialogRow(
                    icon: Icons.schedule,
                    label: 'Request Time',
                    value: _formatTimestamp(data['dateTime']),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('prescriptions')
                            .where(
                              'appointmentId',
                              isEqualTo: data['appointmentId'],
                            )
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildDialogRow(
                          icon: Icons.medical_information,
                          label: 'Prescription',
                          value: 'Error loading prescriptions',
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildDialogRow(
                          icon: Icons.medical_information,
                          label: 'Prescription',
                          value: 'Loading...',
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildDialogRow(
                          icon: Icons.medical_information,
                          label: 'Prescription',
                          value: 'Not available',
                        );
                      }
                      final prescriptions = snapshot.data!.docs;
                      final prescriptionTexts = prescriptions
                          .map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return '${data['medication'] ?? ''} - ${data['dosage'] ?? ''} - ${data['advice'] ?? ''}';
                          })
                          .join('\n');
                      return _buildDialogRow(
                        icon: Icons.medical_information,
                        label: 'Prescription',
                        value: prescriptionTexts,
                      );
                    },
                  ),
                  _buildDialogRow(
                    icon: Icons.access_time_filled,
                    label: 'Response Time',
                    value: _formatTimestamp(data['responseTime']),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      label: Text("Close"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Appointments - MedEase',
      child: Container(
        color: Colors.teal.shade50,
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: getAppointments(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading appointments',
                  style: TextStyle(color: Colors.red),
                ),
              );
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
                var data = appointments[index].data() as Map<String, dynamic>;
                String doctorName = data['doctorName'] ?? 'Unknown';
                String status = data['status'] ?? 'Pending';
                String symptoms = data['symptoms'] ?? 'N/A';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    title: Text(
                      'Dr. $doctorName',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        Text(
                          'Symptoms: $symptoms',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _statusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap:
                        () => _showAppointmentDetailsDialog(context, {
                          ...data,
                          'appointmentId': appointments[index].id,
                        }),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
