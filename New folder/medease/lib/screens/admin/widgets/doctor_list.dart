import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorList extends StatelessWidget {
  final Stream<QuerySnapshot> doctorsStream;
  final Function(String) onDelete;

  DoctorList({required this.doctorsStream, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: doctorsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading doctors',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final doctors = snapshot.data!.docs;

        if (doctors.isEmpty) {
          return Center(
            child: Text(
              'No doctors found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: doctors.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            var doctor = doctors[index];
            var data = doctor.data() as Map<String, dynamic>;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              color: Colors.teal.shade50.withOpacity(0.4),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(
                    Icons.local_hospital,
                    color: Colors.teal.shade700,
                  ),
                ),
                title: Text(
                  data['name'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('Specialization: ${data['specialization'] ?? ''}'),
                    if (data['availability'] != null)
                      Text('Availability: ${data['availability']}'),
                    if (data['email'] != null) Text('Email: ${data['email']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(doctor.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
