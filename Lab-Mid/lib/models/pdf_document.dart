class PdfDocument {
  final String id;
  final String title;
  final String filePath;
  final int fileSize;
  final int pageCount;
  final DateTime dateAdded;
  final DateTime? lastOpened;
  final bool isFavorite;
  final int lastReadPage;
  final String tags;
  final String description;

  PdfDocument({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileSize,
    required this.pageCount,
    required this.dateAdded,
    this.lastOpened,
    this.isFavorite = false,
    this.lastReadPage = 1,
    this.tags = '',
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'fileSize': fileSize,
      'pageCount': pageCount,
      'dateAdded': dateAdded.toIso8601String(),
      'lastOpened': lastOpened?.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'lastReadPage': lastReadPage,
      'tags': tags,
      'description': description,
    };
  }

  factory PdfDocument.fromMap(Map<String, dynamic> map) {
    return PdfDocument(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      fileSize: map['fileSize'] as int,
      pageCount: map['pageCount'] as int? ?? 0,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      lastOpened: map['lastOpened'] != null ? DateTime.parse(map['lastOpened'] as String) : null,
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      lastReadPage: map['lastReadPage'] as int? ?? 1,
      tags: map['tags'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  PdfDocument copyWith({
    String? id,
    String? title,
    String? filePath,
    int? fileSize,
    int? pageCount,
    DateTime? dateAdded,
    DateTime? lastOpened,
    bool? isFavorite,
    int? lastReadPage,
    String? tags,
    String? description,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      dateAdded: dateAdded ?? this.dateAdded,
      lastOpened: lastOpened ?? this.lastOpened,
      isFavorite: isFavorite ?? this.isFavorite,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      tags: tags ?? this.tags,
      description: description ?? this.description,
    );
  }
}
