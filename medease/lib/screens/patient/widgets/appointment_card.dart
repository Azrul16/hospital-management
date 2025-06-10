import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String status;
  final VoidCallback? onTap;

  AppointmentCard({
    required this.doctorName,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.shade200,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          'Doctor: $doctorName',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.teal.shade900,
          ),
        ),
        subtitle: Text(
          'Status: $status',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        onTap: onTap,
      ),
    );
  }
}
