import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DoctorAppointmentDetailScreen({required this.appointmentId});

  Future<DocumentSnapshot> getAppointmentDetails() {
    return _firestore.collection('appointments').doc(appointmentId).get();
  }

  Future<DocumentSnapshot> getPatientDetails(String patientId) {
    return _firestore.collection('users').doc(patientId).get();
  }

  Future<QuerySnapshot> getPrescriptionDetails() {
    return _firestore
        .collection('prescriptions')
        .where('appointmentId', isEqualTo: appointmentId)
        .get();
  }

  String formatDateTime(String? rawDateTime) {
    if (rawDateTime == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(rawDateTime);
      final time = DateFormat('hh:mm a').format(dateTime);
      final date = DateFormat('dd MMMM yyyy').format(dateTime);
      return '$time\n$date';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getAppointmentDetails(),
      builder: (context, appointmentSnapshot) {
        if (appointmentSnapshot.hasError) {
          return _errorScaffold('Error loading appointment details');
        }
        if (!appointmentSnapshot.hasData || !appointmentSnapshot.data!.exists) {
          return _loadingScaffold();
        }

        var appointmentData =
            appointmentSnapshot.data!.data() as Map<String, dynamic>;

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

            return FutureBuilder<QuerySnapshot>(
              future: getPrescriptionDetails(),
              builder: (context, prescriptionSnapshot) {
                if (prescriptionSnapshot.hasError) {
                  return _errorScaffold('Error loading prescription details');
                }
                if (!prescriptionSnapshot.hasData) {
                  return _loadingScaffold();
                }

                var prescriptions = prescriptionSnapshot.data!.docs;

                return Scaffold(
                  appBar: AppBar(title: Text('Appointment Details')),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _sectionTitle('Patient Info'),
                        _infoCard([
                          _infoTile('Name', patientData['name']),
                          _infoTile(
                            'Mobile Number',
                            patientData['mobileNumber'],
                          ),
                        ]),
                        SizedBox(height: 16),
                        _sectionTitle('Appointment Info'),
                        _infoCard([
                          _infoTile('Symptoms', appointmentData['symptoms']),
                          _infoTile(
                            'Time & Date',
                            formatDateTime(appointmentData['dateTime']),
                          ),
                          if (appointmentData['responseTime'] != null)
                            _infoTile(
                              'Response Time',
                              DateFormat('dd MMM yyyy HH:mm').format(
                                (appointmentData['responseTime'] as Timestamp)
                                    .toDate(),
                              ),
                            ),
                        ]),
                        SizedBox(height: 16),
                        _sectionTitle('Prescriptions'),
                        if (prescriptions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No prescriptions added yet.'),
                          )
                        else
                          ...prescriptions.map((prescription) {
                            var data =
                                prescription.data() as Map<String, dynamic>;
                            final createdAt =
                                data['createdAt'] != null
                                    ? DateFormat('dd MMM yyyy').format(
                                      (data['createdAt'] as Timestamp).toDate(),
                                    )
                                    : 'N/A';

                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Medication: ${data['medication'] ?? 'N/A'}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _showEditPrescriptionDialog(
                                              context,
                                              prescription.id,
                                              data['medication'] ?? '',
                                              data['dosage'] ?? '',
                                              data['advice'] ?? '',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text('Dosage: ${data['dosage'] ?? 'N/A'}'),
                                    Text('Advice: ${data['advice'] ?? 'N/A'}'),
                                    Text('Date: $createdAt'),
                                    if (data['responseTime'] != null)
                                      Text(
                                        'Response Time: ' +
                                            DateFormat(
                                              'dd MMM yyyy HH:mm',
                                            ).format(
                                              (data['responseTime']
                                                      as Timestamp)
                                                  .toDate(),
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
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

  void _showEditPrescriptionDialog(
    BuildContext context,
    String prescriptionId,
    String medication,
    String dosage,
    String advice,
  ) {
    final _medController = TextEditingController(text: medication);
    final _doseController = TextEditingController(text: dosage);
    final _adviceController = TextEditingController(text: advice);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Prescription'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _medController,
                    decoration: InputDecoration(labelText: 'Medication'),
                  ),
                  TextField(
                    controller: _doseController,
                    decoration: InputDecoration(labelText: 'Dosage'),
                  ),
                  TextField(
                    controller: _adviceController,
                    decoration: InputDecoration(labelText: 'Advice'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('prescriptions')
                      .doc(prescriptionId)
                      .update({
                        'medication': _medController.text,
                        'dosage': _doseController.text,
                        'advice': _adviceController.text,
                      });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  Scaffold _errorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment Details')),
      body: Center(child: Text(message)),
    );
  }

  Scaffold _loadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment Details')),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
