class Doctor {
  final String id;
  final String name;
  final String email;
  final String password;
  final String specialization;
  final String availability;
  final String role;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.specialization,
    required this.availability,
    this.role = 'doctor',
  });

  factory Doctor.fromMap(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      specialization: data['specialization'] ?? '',
      availability: data['availability'] ?? '',
      role: data['role'] ?? 'doctor',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'specialization': specialization,
      'availability': availability,
      'role': role,
    };
  }
}
