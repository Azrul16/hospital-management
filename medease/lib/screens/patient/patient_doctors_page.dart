import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medease/widgets/web_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PatientDoctorsPage extends StatelessWidget {
  final String patientId;
  final Function(String doctorId, String symptoms, [String? doctorComment])
  onRequestAppointment;

  PatientDoctorsPage({
    required this.patientId,
    required this.onRequestAppointment,
  });

  Future<bool> _pollPaymentStatus(BuildContext context, String tranId) async {
    const maxAttempts = 10;
    const delay = Duration(seconds: 5);
    int attempt = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Waiting for payment confirmation...'),
              ],
            ),
          ),
    );

    while (attempt < maxAttempts) {
      await Future.delayed(delay);
      attempt++;

      try {
        final res = await http.get(
          Uri.parse('https://sslc.onrender.com/payment-status/$tranId'),
        );

        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final status = data['status'];

          if (status == 'VALID') {
            Navigator.pop(context); // close dialog
            return true;
          } else if (status == 'FAILED' || status == 'CANCELLED') {
            Navigator.pop(context);
            _showErrorSnackBar(context, 'Payment $status');
            return false;
          }
        }
      } catch (_) {}

      // Keep retrying
    }

    Navigator.pop(context); // close dialog
    _showErrorSnackBar(context, 'Payment confirmation timed out');
    return false;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getDoctors() {
    return _firestore.collection('doctors').snapshots();
  }

  // Get current user's email
  String? getCurrentUserEmail() {
    final User? user = _auth.currentUser;
    return user?.email;
  }

  // Custom payment handler using your server
  Future<bool> _handleCustomPayment(BuildContext context, String email) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Initiating payment...'),
                ],
              ),
            ),
      );

      final response = await http.post(
        Uri.parse('https://sslc.onrender.com/initiate-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': 100.00, 'email': email}),
      );

      Navigator.pop(context); // close loading

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paymentUrl = data['GatewayPageURL'];
        final transactionId = data['transactionId'];

        if (paymentUrl == null || transactionId == null) {
          _showErrorSnackBar(context, 'Invalid payment URL or transaction ID');
          return false;
        }

        // Launch payment
        final Uri url = Uri.parse(paymentUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);

          // Show loading while checking payment status
          return await _pollPaymentStatus(context, transactionId);
        } else {
          _showErrorSnackBar(context, 'Could not open payment page');
          return false;
        }
      } else {
        final errorData = json.decode(response.body);
        Navigator.of(context).pop();
        _showErrorSnackBar(context, errorData['error'] ?? 'Payment failed');
        return false;
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorSnackBar(context, 'Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _showPaymentConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Text('Payment Status'),
                content: Text('Have you completed the payment successfully?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('No / Failed'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Yes, Completed'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showRequestAppointmentDialog(
    BuildContext context,
    String doctorId,
    String doctorName,
  ) {
    TextEditingController symptomsController = TextEditingController();
    TextEditingController doctorCommentController = TextEditingController();

    // Get current user's email and pre-fill it
    String? userEmail = getCurrentUserEmail();
    TextEditingController emailController = TextEditingController(
      text: userEmail ?? '',
    );

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
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email for payment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled:
                        userEmail ==
                        null, // Only allow editing if no email found
                  ),
                  SizedBox(height: 12),
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
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payment, color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Text(
                          'Appointment Fee: ৳100',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.payment),
                onPressed: () async {
                  // Validate fields
                  if (emailController.text.trim().isEmpty) {
                    _showErrorSnackBar(context, 'Please enter your email');
                    return;
                  }
                  if (symptomsController.text.trim().isEmpty) {
                    _showErrorSnackBar(
                      context,
                      'Please describe your symptoms',
                    );
                    return;
                  }

                  // Process payment
                  bool paymentSuccess = await _handleCustomPayment(
                    context,
                    emailController.text.trim(),
                  );

                  if (paymentSuccess) {
                    // Send appointment request
                    onRequestAppointment(
                      doctorId,
                      symptomsController.text,
                      doctorCommentController.text.isEmpty
                          ? null
                          : doctorCommentController.text,
                    );
                    Navigator.pop(context);
                    _showSuccessSnackBar(
                      context,
                      'Appointment request sent successfully!',
                    );
                  }
                },
                label: Text('Pay & Request'),
              ),
            ],
          ),
    );
  }

  // Rest of your existing code remains the same...
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
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      'Consultation Fee: ৳100',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
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
    return WebLayout(
      title: 'Doctors - MedEase',
      child: StreamBuilder<QuerySnapshot>(
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
                              SizedBox(height: 4),
                              Text(
                                'Fee: ৳100',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.payment, size: 16),
                          onPressed: () {
                            _showRequestAppointmentDialog(
                              context,
                              doctor.id,
                              data['name'] ?? 'Doctor',
                            );
                          },
                          label: Text('Request'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
