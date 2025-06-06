import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new appointment
  Future<void> createAppointment(Appointment appointment) async {
    await _db.collection('appointments').doc(appointment.id).set(appointment.toMap());
  }

  // Get appointments for a specific patient
  Stream<List<Appointment>> getPatientAppointments(String patientId, String status) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data()))
            .toList());
  }

  // Get appointments for a specific doctor
  Stream<List<Appointment>> getDoctorAppointments(String doctorId, String status) {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data()))
            .toList());
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  // Get a single appointment
  Future<Appointment?> getAppointment(String appointmentId) async {
    final doc = await _db.collection('appointments').doc(appointmentId).get();
    return doc.exists ? Appointment.fromMap(doc.data()!) : null;
  }

  // Get all appointments for today
  Stream<List<Appointment>> getTodayAppointments() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data()))
            .toList());
  }

  // Get appointment statistics
  Future<Map<String, int>> getAppointmentStats() async {
    final QuerySnapshot upcoming = await _db
        .collection('appointments')
        .where('status', isEqualTo: 'upcoming')
        .get();

    final QuerySnapshot completed = await _db
        .collection('appointments')
        .where('status', isEqualTo: 'completed')
        .get();

    final QuerySnapshot cancelled = await _db
        .collection('appointments')
        .where('status', isEqualTo: 'cancelled')
        .get();

    return {
      'upcoming': upcoming.docs.length,
      'completed': completed.docs.length,
      'cancelled': cancelled.docs.length,
    };
  }
}
