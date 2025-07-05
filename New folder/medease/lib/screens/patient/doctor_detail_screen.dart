// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailScreen extends StatelessWidget {
  final String doctorId;

  DoctorDetailScreen({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('doctors')
                .doc(doctorId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading doctor details'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return Center(child: Text('Doctor not found'));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  'Name: ${data['name'] ?? ''}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Specialization: ${data['specialization'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Availability: ${data['availability'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Email: ${data['email'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                // Add more fields as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
