class Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int? age;
  final String? address;
  final String? bloodGroup;
  final List<String>? allergies;
  final List<String>? medicalHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.age,
    this.address,
    this.bloodGroup,
    this.allergies,
    this.medicalHistory,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'address': address,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      age: map['age'] != null ? map['age'] as int : null,
      address: map['address'],
      bloodGroup: map['bloodGroup'],
      allergies: map['allergies'] != null 
          ? List<String>.from(map['allergies'])
          : null,
      medicalHistory: map['medicalHistory'] != null 
          ? List<String>.from(map['medicalHistory'])
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? address,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? medicalHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $name, email: $email, phone: $phone, age: $age)';
  }
}
