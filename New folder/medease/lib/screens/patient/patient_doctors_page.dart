import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

class PatientDoctorsPage extends StatelessWidget {
  final String patientId;
  final Function(String doctorId, String symptoms, [String? doctorComment])
  onRequestAppointment;

  PatientDoctorsPage({
    super.key,
    required this.patientId,
    required this.onRequestAppointment,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getDoctors() {
    return _firestore.collection('doctors').snapshots();
  }

  // Payment handler with your credentials
  Future<bool> _handleSslcommerzPayment(BuildContext context) async {
    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: 'patua685d01b8d4ca6',
        store_passwd: 'patua685d01b8d4ca6@ssl',
        total_amount: 100.00,
        currency: 'BDT',
        tran_id: 'SUB${DateTime.now().millisecondsSinceEpoch}',
        product_category: 'Healthcare',
        sdkType: SSLCSdkType.TESTBOX,
        multi_card_name: "visa,master,bkash",
      ),
    );

    // Start payment
    SSLCTransactionInfoModel result = await sslcommerz.payNow();

    if (result.status == "VALID" || result.status == "SUCCESS") {
      return true;
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment was not successful. Request not sent.'),
        ),
      );
      return false;
    }
  }

  void _showRequestAppointmentDialog(
    BuildContext context,
    String doctorId,
    String doctorName,
  ) {
    TextEditingController symptomsController = TextEditingController();
    TextEditingController doctorCommentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Request Appointment with $doctorName'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: symptomsController,
                    decoration: InputDecoration(
                      labelText: 'Describe your symptoms',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: doctorCommentController,
                    decoration: InputDecoration(
                      labelText: 'Doctor Comment (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // Step 1: Start payment
                  bool paymentSuccess = await _handleSslcommerzPayment(context);
                  if (paymentSuccess) {
                    // Step 2: Only send request if payment succeeded
                    onRequestAppointment(
                      doctorId,
                      symptomsController.text,
                      doctorCommentController.text.isEmpty
                          ? null
                          : doctorCommentController.text,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context); // Close dialog after request
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    // Just close dialog if payment failed
                  }
                },
                child: Text('Request'),
              ),
            ],
          ),
    );
  }

  void _showDoctorDetailsDialog(
    BuildContext context,
    Map<String, dynamic> data,
    String doctorId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    data['name'] ?? 'Doctor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data['specialization'] ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  if (data['experience'] != null)
                    Text('Experience: ${data['experience']} years'),
                  if (data['contact'] != null)
                    Text('Contact: ${data['contact']}'),
                  if (data['email'] != null) Text('Email: ${data['email']}'),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRequestAppointmentDialog(
                        context,
                        doctorId,
                        data['name'] ?? 'Doctor',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.calendar_month),
                    label: Text('Request Appointment'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getDoctors(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading doctors',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final doctors = snapshot.data!.docs;
        if (doctors.isEmpty) {
          return Center(child: Text('No doctors available'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            var doctor = doctors[index];
            var data = doctor.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () => _showDoctorDetailsDialog(context, data, doctor.id),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue.shade700,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              data['specialization'] ?? '',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _showRequestAppointmentDialog(
                            context,
                            doctor.id,
                            data['name'] ?? 'Doctor',
                          );
                        },
                        child: Text('Request'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
