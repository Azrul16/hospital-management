import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialization;
  final VoidCallback onRequest;

  DoctorCard({
    required this.name,
    required this.specialization,
    required this.onRequest,
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
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.teal.shade900,
          ),
        ),
        subtitle: Text(
          specialization,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: onRequest,
          child: Text(
            'Request Appointment',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
