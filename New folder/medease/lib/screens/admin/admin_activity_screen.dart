import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminActivityScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getRecentActivities() async* {
    final usersSnapshot =
        await _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

    final doctorsSnapshot =
        await _firestore
            .collection('doctors')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

    final appointmentsSnapshot =
        await _firestore
            .collection('appointments')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

    List<Map<String, dynamic>> activities = [];

    activities.addAll(
      usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'type': 'User Created',
          'name': data['name'] ?? 'N/A',
          'email': data['email'] ?? 'N/A',
          'createdAt': data['createdAt'],
        };
      }),
    );

    activities.addAll(
      doctorsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'type': 'Doctor Created',
          'name': data['name'] ?? 'N/A',
          'email': data['email'] ?? 'N/A',
          'createdAt': data['createdAt'],
        };
      }),
    );

    activities.addAll(
      appointmentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'type': 'Appointment',
          'description':
              'Appointment with Dr. ${data['doctorName']} is ${data['status']}',
          'createdAt': data['createdAt'],
        };
      }),
    );

    activities.sort((a, b) {
      final aDate = a['createdAt'] as Timestamp?;
      final bDate = b['createdAt'] as Timestamp?;
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    yield activities;
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dt = timestamp.toDate();
    String time = DateFormat.jm().format(dt);
    String date = DateFormat('dd MMM yyyy').format(dt);
    return '$time\n$date';
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          activity['type'] ?? 'Activity',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          activity['name'] != null
              ? '${activity['name']} (${activity['email'] ?? ''})'
              : activity['description'] ?? '',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Text(
          _formatDateTime(activity['createdAt']),
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Monitoring'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getRecentActivities(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading activities'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = snapshot.data!;
          if (activities.isEmpty) {
            return const Center(child: Text('No recent activities found'));
          }
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder:
                (context, index) => _buildActivityCard(activities[index]),
          );
        },
      ),
    );
  }
}
