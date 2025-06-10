import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medease/screens/doctor/doctor_presctiption_management_screen.dart';
import '../../services/firebase_service.dart';
import 'widgets/appointment_card.dart';
import 'widgets/reject_dialog.dart';
import 'widgets/prescription_dialog.dart';
import 'doctor_appointment_detail_screen.dart';
import 'doctor_profile.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medease/screens/doctor/doctor_presctiption_management_screen.dart';
import '../../services/firebase_service.dart';
import 'widgets/appointment_card.dart';
import 'widgets/reject_dialog.dart';
import 'widgets/prescription_dialog.dart';
import 'doctor_appointment_detail_screen.dart';
import 'doctor_profile.dart';
import '../../widgets/web_layout.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final String doctorId;

  DoctorDashboardScreen({required this.doctorId});

  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  Stream<List<QueryDocumentSnapshot>> getDoctorAppointments() {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .snapshots()
        .map((snapshot) {
          var docs = snapshot.docs;
          int statusPriority(String status) {
            switch (status) {
              case 'pending':
                return 0;
              case 'accepted':
                return 1;
              case 'completed':
                return 2;
              default:
                return 3;
            }
          }

          docs.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            int aPriority = statusPriority(aData['status'] ?? '');
            int bPriority = statusPriority(bData['status'] ?? '');
            if (aPriority != bPriority) {
              return aPriority.compareTo(bPriority);
            }
            var aTime = aData['responseTime'] as Timestamp?;
            var bTime = bData['responseTime'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }

  void updateAppointmentStatus(
    String appointmentId,
    String status, {
    String? comment,
  }) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
      'doctorComment': comment ?? '',
      'responseTime': FieldValue.serverTimestamp(),
    });
  }

  void _showRejectDialog(String appointmentId) {
    showDialog(
      context: context,
      builder:
          (context) => RejectDialog(
            onReject: (comment) {
              updateAppointmentStatus(
                appointmentId,
                'rejected',
                comment: comment,
              );
            },
          ),
    );
  }

  void _showPrescriptionDialog(String appointmentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => DoctorPrescriptionManagementScreen(
              appointmentId: appointmentId,
            ),
      ),
    );
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('|', style: TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }

  Widget _buildColoredMetric(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        // Performance Metrics Bar under AppBar
        Container(
          color: Colors.teal.shade100,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: getDoctorAppointments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              var docs = snapshot.data!;
              int total = docs.length;
              int completed =
                  docs
                      .where(
                        (doc) =>
                            (doc.data() as Map<String, dynamic>)['status'] ==
                            'completed',
                      )
                      .length;
              double completionRate = total > 0 ? (completed / total) * 100 : 0;
              int pendingCount =
                  docs
                      .where(
                        (doc) =>
                            (doc.data() as Map<String, dynamic>)['status'] ==
                            'pending',
                      )
                      .length;
              int acceptedCount =
                  docs
                      .where(
                        (doc) =>
                            (doc.data() as Map<String, dynamic>)['status'] ==
                            'accepted',
                      )
                      .length;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildColoredMetric('Total', total.toString(), Colors.blue),
                    _separator(),
                    _buildColoredMetric(
                      'Completed',
                      completed.toString(),
                      Colors.green,
                    ),
                    _separator(),
                    _buildColoredMetric(
                      'Completion Rate',
                      '${completionRate.toStringAsFixed(1)}%',
                      Colors.orange,
                    ),
                    _separator(),
                    _buildColoredMetric(
                      'Pending', 
                      pendingCount.toString(),
                      Colors.red,
                    ),
                    _separator(),
                    _buildColoredMetric(
                      'Accepted',
                      acceptedCount.toString(),
                      Colors.purple,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search patients or appointments',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              // Optional: implement search logic
            },
          ),
        ),

        // Expanded appointment list
        Expanded(
          child: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: getDoctorAppointments(),
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
              final appointments = snapshot.data!;
              if (appointments.isEmpty) {
                return Center(child: Text('No appointments found'));
              }
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  var data = appointment.data() as Map<String, dynamic>;
                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        _firestore
                            .collection('users')
                            .doc(data['patientId'])
                            .get(),
                    builder: (context, patientSnapshot) {
                      if (patientSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return AppointmentCard(
                          patientName: 'Loading patient...',
                          dateTime: '',
                          status: '',
                        );
                      }
                      if (!patientSnapshot.hasData ||
                          !patientSnapshot.data!.exists) {
                        return AppointmentCard(
                          patientName: 'Unknown patient',
                          dateTime: '',
                          status: '',
                        );
                      }
                      var patientData =
                          patientSnapshot.data!.data() as Map<String, dynamic>;
                      return AppointmentCard(
                        patientName: patientData['name'] ?? 'Unknown',
                        dateTime: data['dateTime'] ?? 'N/A',
                        status: data['status'] ?? '',
                        doctorComment: data['doctorComment'],
                        responseTime:
                            data['responseTime'] != null
                                ? (data['responseTime'] as Timestamp)
                                    .toDate()
                                    .toString()
                                : null,
                        onAccept:
                            data['status'] == 'pending'
                                ? () => updateAppointmentStatus(
                                  appointment.id,
                                  'accepted',
                                )
                                : null,
                        onReject:
                            data['status'] == 'pending'
                                ? () => _showRejectDialog(appointment.id)
                                : null,
                        onWritePrescription:
                            data['status'] == 'accepted'
                                ? () {
                                  _showPrescriptionDialog(appointment.id);
                                }
                                : null,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => DoctorAppointmentDetailScreen(
                                    appointmentId: appointment.id,
                                  ),
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
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      _buildDashboard(),
      DoctorProfileScreen(doctorId: widget.doctorId),
    ];

    return WebLayout(
      title: 'Doctor Dashboard',
      child: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.teal.shade50,
            selectedIconTheme: IconThemeData(color: Colors.teal.shade700),
            selectedLabelTextStyle: TextStyle(color: Colors.teal.shade700),
            unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
            unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
