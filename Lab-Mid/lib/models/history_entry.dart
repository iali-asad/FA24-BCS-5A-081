class HistoryEntry {
  final String id;
  final String docId;
  final String docTitle;
  final String docPath;
  final int lastReadPage;
  final int totalPages;
  final DateTime timestamp;

  HistoryEntry({
    required this.id,
    required this.docId,
    required this.docTitle,
    required this.docPath,
    required this.lastReadPage,
    required this.totalPages,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'docTitle': docTitle,
      'docPath': docPath,
      'lastReadPage': lastReadPage,
      'totalPages': totalPages,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String,
      docId: map['docId'] as String,
      docTitle: map['docTitle'] as String,
      docPath: map['docPath'] as String,
      lastReadPage: map['lastReadPage'] as int,
      totalPages: map['totalPages'] as int? ?? 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
