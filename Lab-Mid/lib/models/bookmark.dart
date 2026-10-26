class Bookmark {
  final String id;
  final String docId;
  final String docTitle;
  final String docPath;
  final int pageNumber;
  final DateTime timestamp;
  final String note;

  Bookmark({
    required this.id,
    required this.docId,
    required this.docTitle,
    required this.docPath,
    required this.pageNumber,
    required this.timestamp,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'docTitle': docTitle,
      'docPath': docPath,
      'pageNumber': pageNumber,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      docId: map['docId'] as String,
      docTitle: map['docTitle'] as String,
      docPath: map['docPath'] as String,
      pageNumber: map['pageNumber'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      note: map['note'] as String? ?? '',
    );
  }
}
