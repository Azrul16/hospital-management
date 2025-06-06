import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prescription.dart';
import '../models/medicine.dart';

class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new prescription
  Future<void> createPrescription(Prescription prescription) async {
    try {
      await _firestore
          .collection('prescriptions')
          .doc(prescription.id)
          .set(prescription.toMap());

      // Update appointment to mark that it has a prescription
      await _firestore
          .collection('appointments')
          .doc(prescription.appointmentId)
          .update({'hasPrescription': true});
    } catch (e) {
      rethrow;
    }
  }

  // Get prescription by ID
  Future<Prescription?> getPrescription(String prescriptionId) async {
    try {
      final doc = await _firestore
          .collection('prescriptions')
          .doc(prescriptionId)
          .get();

      if (doc.exists) {
        return Prescription.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get prescriptions for a patient
  Stream<List<Prescription>> getPatientPrescriptions(String patientId) {
    return _firestore
        .collection('prescriptions')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prescription.fromMap(doc.data()))
            .toList());
  }

  // Get prescriptions by appointment
  Future<Prescription?> getPrescriptionByAppointment(String appointmentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('prescriptions')
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Prescription.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update prescription
  Future<void> updatePrescription(String prescriptionId, {
    List<Medicine>? medicines,
    String? diagnosis,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (medicines != null) {
        updates['medicines'] = medicines.map((m) => m.toMap()).toList();
      }
      if (diagnosis != null) {
        updates['diagnosis'] = diagnosis;
      }
      if (notes != null) {
        updates['notes'] = notes;
      }

      await _firestore
          .collection('prescriptions')
          .doc(prescriptionId)
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete prescription
  Future<void> deletePrescription(String prescriptionId, String appointmentId) async {
    try {
      await _firestore
          .collection('prescriptions')
          .doc(prescriptionId)
          .delete();

      // Update appointment to mark that it no longer has a prescription
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({'hasPrescription': false});
    } catch (e) {
      rethrow;
    }
  }

  // Get doctor's prescriptions
  Stream<List<Prescription>> getDoctorPrescriptions(String doctorId) {
    return _firestore
        .collection('prescriptions')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prescription.fromMap(doc.data()))
            .toList());
  }

  // Generate unique prescription ID
  String generatePrescriptionId() {
    return _firestore.collection('prescriptions').doc().id;
  }
}
