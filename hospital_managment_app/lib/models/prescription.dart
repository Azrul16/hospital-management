import 'package:cloud_firestore/cloud_firestore.dart';
import 'medicine.dart';

class Prescription {
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final List<Medicine> medicines;
  final String diagnosis;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Prescription({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.medicines,
    required this.diagnosis,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'medicines': medicines.map((medicine) => medicine.toMap()).toList(),
      'diagnosis': diagnosis,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      medicines: (map['medicines'] as List<dynamic>?)
          ?.map((medicine) => Medicine.fromMap(medicine as Map<String, dynamic>))
          .toList() ?? [],
      diagnosis: map['diagnosis'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Prescription copyWith({
    String? id,
    String? appointmentId,
    String? patientId,
    String? doctorId,
    List<Medicine>? medicines,
    String? diagnosis,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      medicines: medicines ?? this.medicines,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Prescription(id: $id, appointmentId: $appointmentId, patientId: $patientId, doctorId: $doctorId, medicines: $medicines, diagnosis: $diagnosis, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
