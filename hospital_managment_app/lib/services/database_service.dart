import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/medicine.dart';
import '../models/appointment.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Doctor methods
  Future<void> addDoctor(Doctor doctor) async {
    await _db.collection('doctors').doc(doctor.id).set(doctor.toMap());
  }

  Future<void> deleteDoctor(String id) async {
    await _db.collection('doctors').doc(id).delete();
  }

  Future<Doctor?> getDoctor(String id) async {
    final doc = await _db.collection('doctors').doc(id).get();
    return doc.exists ? Doctor.fromMap(doc.data()!) : null;
  }

  Future<Doctor?> getDoctorByEmail(String email) async {
    final querySnapshot =
        await _db
            .collection('doctors')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) return null;
    return Doctor.fromMap(querySnapshot.docs.first.data());
  }

  Stream<List<Doctor>> getDoctors() {
    return _db
        .collection('doctors')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Doctor.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<Patient>> getDoctorPatients(String doctorId) {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .asyncMap((snapshot) async {
          final patientIds =
              snapshot.docs
                  .map((doc) => doc.data()['patientId'] as String)
                  .toSet();
          final patients = await Future.wait(
            patientIds.map((id) => getPatient(id)),
          );
          return patients.whereType<Patient>().toList();
        });
  }

  // Patient methods
  Future<void> addPatient(Patient patient) async {
    await _db.collection('patients').doc(patient.id).set(patient.toMap());
  }

  Future<Patient?> getPatient(String id) async {
    final doc = await _db.collection('patients').doc(id).get();
    return doc.exists ? Patient.fromMap(doc.data()!) : null;
  }

  Stream<List<Patient>> getPatients() {
    return _db
        .collection('patients')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Patient.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<Appointment>> getPatientAppointments(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Appointment.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<List<Appointment>> getPatientPrescriptions(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('hasPrescription', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Appointment.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Admin methods
  Stream<List<dynamic>> getAdminStats() async* {
    while (true) {
      final patients = await _db.collection('patients').count().get();
      final doctors =
          await _db
              .collection('doctors')
              .where('isActive', isEqualTo: true)
              .count()
              .get();
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointments =
          await _db
              .collection('appointments')
              .where('date', isGreaterThanOrEqualTo: startOfDay)
              .where('date', isLessThan: endOfDay)
              .count()
              .get();

      yield [patients.count, doctors.count, appointments.count];

      await Future.delayed(
        const Duration(seconds: 30),
      ); // Refresh every 30 seconds
    }
  }

  Stream<List<Map<String, dynamic>>> getRecentActivity() {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    return _db
        .collection('activity_log')
        .where('timestamp', isGreaterThan: twentyFourHoursAgo)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                final timestamp = (data['timestamp'] as Timestamp).toDate();
                final difference = now.difference(timestamp);
                String timeAgo;

                if (difference.inMinutes < 60) {
                  timeAgo = '${difference.inMinutes} minutes ago';
                } else if (difference.inHours < 24) {
                  timeAgo = '${difference.inHours} hours ago';
                } else {
                  timeAgo = '${difference.inDays} days ago';
                }

                return {
                  'icon': _getActivityIcon(data['type'] as String),
                  'title': data['title'] as String,
                  'subtitle': data['subtitle'] as String,
                  'time': timeAgo,
                };
              }).toList(),
        );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'new_doctor':
        return Icons.person_add;
      case 'new_patient':
        return Icons.person_outline;
      case 'appointment':
        return Icons.calendar_today;
      case 'profile_update':
        return Icons.edit;
      default:
        return Icons.info_outline;
    }
  }

  // Prescription methods
  Future<void> savePrescription(
    String appointmentId,
    List<Medicine> medicines,
    String instructions,
    String followUpDate,
  ) async {
    final prescriptionData = {
      'appointmentId': appointmentId,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'instructions': instructions,
      'followUpDate': followUpDate,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db
        .collection('prescriptions')
        .doc(appointmentId)
        .set(prescriptionData);
    await _db.collection('appointments').doc(appointmentId).update({
      'hasPrescription': true,
    });
  }

  Stream<List<Medicine>> getPrescriptionMedicines(String appointmentId) {
    return _db.collection('prescriptions').doc(appointmentId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return [];
      final data = doc.data()!;
      final medicinesData = data['medicines'] as List<dynamic>;
      return medicinesData
          .map((m) => Medicine.fromMap(m as Map<String, dynamic>))
          .toList();
    });
  }
}
