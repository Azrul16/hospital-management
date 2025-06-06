import 'package:flutter/material.dart';
import 'package:medease/models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  String _getAvatarPath(String gender) {
    if (gender.toLowerCase() == 'female') {
      return 'assets/avatar/female.png';
    }
    return 'assets/avatar/male.png';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.green,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                _getAvatarPath(patient.gender),
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Email: ${patient.email}"),
                  Text("Phone: ${patient.mobileNumber}"),
                  Text("Age: ${patient.age}  |  Gender: ${patient.gender}"),
                  if (patient.medicalHistory.isNotEmpty)
                    Text("History: ${patient.medicalHistory}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
