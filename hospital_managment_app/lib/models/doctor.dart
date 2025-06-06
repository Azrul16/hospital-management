class Doctor {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final String phone;
  final bool isActive;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.phone,
    this.isActive = true,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      specialization: map['specialization'],
      phone: map['phone'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'specialization': specialization,
      'phone': phone,
      'isActive': isActive,
    };
  }
}
