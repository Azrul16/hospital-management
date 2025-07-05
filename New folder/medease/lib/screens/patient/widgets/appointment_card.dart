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
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text('Doctor: \$doctorName', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: \$status'),
        onTap: onTap,
      ),
    );
  }
}
