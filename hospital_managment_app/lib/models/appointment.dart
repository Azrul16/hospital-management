import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime date;
  final String time;
  final String status;
  final String symptoms;
  final bool? hasPrescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.time,
    required this.status,
    required this.symptoms,
    this.hasPrescription,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date,
      'time': time,
      'status': status,
      'symptoms': symptoms,
      'hasPrescription': hasPrescription,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      status: map['status'] ?? '',
      symptoms: map['symptoms'] ?? '',
      hasPrescription: map['hasPrescription'] != null ? map['hasPrescription'] as bool : null,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? date,
    String? time,
    String? status,
    String? symptoms,
    bool? hasPrescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
      hasPrescription: hasPrescription ?? this.hasPrescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, doctorId: $doctorId, patientId: $patientId, date: $date, time: $time, status: $status, symptoms: $symptoms, hasPrescription: $hasPrescription)';
  }
}
