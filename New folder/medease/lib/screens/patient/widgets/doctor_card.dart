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
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(specialization),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: onRequest,
          child: Text('Request Appointment'),
        ),
      ),
    );
  }
}
