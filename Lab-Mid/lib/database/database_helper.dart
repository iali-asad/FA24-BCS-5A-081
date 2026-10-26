import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pdf_document.dart';
import '../models/bookmark.dart';
import '../models/history_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('docuverse_pdf.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        pageCount INTEGER NOT NULL,
        dateAdded TEXT NOT NULL,
        lastOpened TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        lastReadPage INTEGER NOT NULL DEFAULT 1,
        tags TEXT DEFAULT '',
        description TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        docId TEXT NOT NULL,
        docTitle TEXT NOT NULL,
        docPath TEXT NOT NULL,
        pageNumber INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT DEFAULT '',
        FOREIGN KEY (docId) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_history (
        id TEXT PRIMARY KEY,
        docId TEXT NOT NULL,
        docTitle TEXT NOT NULL,
        docPath TEXT NOT NULL,
        lastReadPage INTEGER NOT NULL,
        totalPages INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (docId) REFERENCES documents (id) ON DELETE CASCADE
      )
    ''');
  }

  // Document Operations
  Future<int> insertDocument(PdfDocument doc) async {
    final db = await instance.database;
    return await db.insert(
      'documents',
      doc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PdfDocument>> getAllDocuments() async {
    final db = await instance.database;
    final result = await db.query('documents', orderBy: 'dateAdded DESC');
    return result.map((json) => PdfDocument.fromMap(json)).toList();
  }

  Future<PdfDocument?> getDocumentById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return PdfDocument.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateDocument(PdfDocument doc) async {
    final db = await instance.database;
    return await db.update(
      'documents',
      doc.toMap(),
      where: 'id = ?',
      whereArgs: [doc.id],
    );
  }

  Future<int> deleteDocument(String id) async {
    final db = await instance.database;
    // Also delete associated bookmarks and history
    await db.delete('bookmarks', where: 'docId = ?', whereArgs: [id]);
    await db.delete('reading_history', where: 'docId = ?', whereArgs: [id]);
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavorite(String id, bool isFav) async {
    final db = await instance.database;
    return await db.update(
      'documents',
      {'isFavorite': isFav ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateReadingProgress(String id, int lastReadPage, DateTime lastOpened) async {
    final db = await instance.database;
    return await db.update(
      'documents',
      {
        'lastReadPage': lastReadPage,
        'lastOpened': lastOpened.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Bookmark Operations
  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await instance.database;
    return await db.insert(
      'bookmarks',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await instance.database;
    final result = await db.query('bookmarks', orderBy: 'timestamp DESC');
    return result.map((json) => Bookmark.fromMap(json)).toList();
  }

  Future<List<Bookmark>> getBookmarksForDocument(String docId) async {
    final db = await instance.database;
    final result = await db.query(
      'bookmarks',
      where: 'docId = ?',
      whereArgs: [docId],
      orderBy: 'pageNumber ASC',
    );
    return result.map((json) => Bookmark.fromMap(json)).toList();
  }

  Future<int> deleteBookmark(String id) async {
    final db = await instance.database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // Reading History Operations
  Future<int> recordHistory(HistoryEntry entry) async {
    final db = await instance.database;
    // Remove duplicate history for same document so it moves to top
    await db.delete('reading_history', where: 'docId = ?', whereArgs: [entry.docId]);
    return await db.insert('reading_history', entry.toMap());
  }

  Future<List<HistoryEntry>> getReadingHistory() async {
    final db = await instance.database;
    final result = await db.query('reading_history', orderBy: 'timestamp DESC');
    return result.map((json) => HistoryEntry.fromMap(json)).toList();
  }

  Future<int> clearHistory() async {
    final db = await instance.database;
    return await db.delete('reading_history');
  }

  Future<int> deleteHistoryEntry(String id) async {
    final db = await instance.database;
    return await db.delete('reading_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
