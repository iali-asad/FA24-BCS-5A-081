class PatientDocument {
  final int? id;
  final int patientId;
  final String title;
  final String filePath;
  final String fileType; // 'image', 'pdf', 'doc', 'other'
  final int fileSize; // in bytes
  final DateTime uploadedAt;

  PatientDocument({
    this.id,
    required this.patientId,
    required this.title,
    required this.filePath,
    required this.fileType,
    this.fileSize = 0,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'title': title,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  factory PatientDocument.fromMap(Map<String, dynamic> map) {
    return PatientDocument(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      title: map['title'] as String? ?? 'Document',
      filePath: map['file_path'] as String? ?? '',
      fileType: map['file_type'] as String? ?? 'other',
      fileSize: map['file_size'] as int? ?? 0,
      uploadedAt: map['uploaded_at'] != null
          ? DateTime.tryParse(map['uploaded_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
