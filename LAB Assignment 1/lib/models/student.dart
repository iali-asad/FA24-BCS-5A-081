class Student {
  final int? id;
  final String name;
  final String email;
  final int age;
  final String? imagePath;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
        'imagePath': imagePath,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as int?,
        name: json['name'] as String,
        email: json['email'] as String,
        age: json['age'] as int,
        imagePath: json['imagePath'] as String?,
      );

  Student copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    String? imagePath,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
