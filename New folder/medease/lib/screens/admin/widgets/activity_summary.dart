import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart'; // You can also use Icons if lucide_icons isn't added

class ActivitySummary extends StatelessWidget {
  final Stream<QuerySnapshot> appointmentsStream;
  final Stream<QuerySnapshot> prescriptionsStream;

  ActivitySummary({
    required this.appointmentsStream,
    required this.prescriptionsStream,
  });

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        width: 160,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: appointmentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildSummaryCard(
                    icon: Icons.calendar_today,
                    label: 'Appointments',
                    count: 0,
                    color: Colors.teal,
                  );
                }
                return _buildSummaryCard(
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  count: snapshot.data!.docs.length,
                  color: Colors.teal,
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: prescriptionsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildSummaryCard(
                    icon: Icons.receipt_long,
                    label: 'Prescriptions',
                    count: 0,
                    color: Colors.indigo,
                  );
                }
                return _buildSummaryCard(
                  icon: Icons.receipt_long,
                  label: 'Prescriptions',
                  count: snapshot.data!.docs.length,
                  color: Colors.indigo,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
