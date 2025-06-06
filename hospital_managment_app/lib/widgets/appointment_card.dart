import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment on ${appointment.date.day}/${appointment.date.month}/${appointment.date.year} at ${appointment.time}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${appointment.status}',
              style: TextStyle(
                color: appointment.status.toLowerCase() == 'pending'
                    ? Colors.orange
                    : appointment.status.toLowerCase() == 'completed'
                        ? Colors.green
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (appointment.symptoms.isNotEmpty)
              Text(
                'Symptoms: ${appointment.symptoms}',
              ),
            const SizedBox(height: 8),
            if (appointment.hasPrescription != null && appointment.hasPrescription!)
              Text(
                'Prescription available',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
