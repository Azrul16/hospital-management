import 'package:flutter/material.dart';

class AppointmentRequestCard extends StatelessWidget {
  final String patientName;
  final String dateTime;
  final String symptoms;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  AppointmentRequestCard({
    required this.patientName,
    required this.dateTime,
    required this.symptoms,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.shade200,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListTile(
          title: Text(
            'Patient: $patientName',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.teal.shade900,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date/Time: $dateTime',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              Text(
                'Symptoms: $symptoms',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: onAccept,
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: onReject,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
