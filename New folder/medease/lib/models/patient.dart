class Patient {
  final String id;
  final String name;
  final String email;
  final String password;
  final String mobileNumber;
  final String age;
  final String gender;
  final String medicalHistory;
  final String role;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNumber,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    this.role = 'patient',
  });

  factory Patient.fromMap(String id, Map<String, dynamic> data) {
    return Patient(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      age: data['age'] ?? '',
      gender: data['gender'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      role: data['role'] ?? 'patient',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'mobileNumber': mobileNumber,
      'age': age,
      'gender': gender,
      'medicalHistory': medicalHistory,
      'role': role,
    };
  }
}
