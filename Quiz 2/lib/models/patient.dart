class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String bloodGroup;
  final String diagnosis;
  final String prescription;
  final String notes;
  final String? photoPath;
  final String status; // 'Active', 'Under Observation', 'Critical', 'Recovered'
  final DateTime createdAt;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.email = '',
    required this.bloodGroup,
    required this.diagnosis,
    this.prescription = '',
    this.notes = '',
    this.photoPath,
    this.status = 'Active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'blood_group': bloodGroup,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'notes': notes,
      'photo_path': photoPath,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      gender: map['gender'] as String? ?? 'Male',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      bloodGroup: map['blood_group'] as String? ?? 'O+',
      diagnosis: map['diagnosis'] as String? ?? '',
      prescription: map['prescription'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      photoPath: map['photo_path'] as String?,
      status: map['status'] as String? ?? 'Active',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? email,
    String? bloodGroup,
    String? diagnosis,
    String? prescription,
    String? notes,
    String? photoPath,
    String? status,
    DateTime? createdAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
