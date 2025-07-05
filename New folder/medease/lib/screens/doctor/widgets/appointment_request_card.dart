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
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text('Patient: \$patientName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date/Time: \$dateTime'),
            Text('Symptoms: \$symptoms'),
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
    );
  }
}
