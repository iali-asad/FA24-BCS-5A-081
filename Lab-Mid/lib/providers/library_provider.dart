import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/pdf_document.dart';
import '../models/history_entry.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

enum SortOption {
  dateAdded,
  name,
  lastOpened,
  fileSize,
}

class LibraryProvider extends ChangeNotifier {
  List<PdfDocument> _allDocuments = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateAdded;
  bool _isAscending = false;
  bool _isGridView = false;
  bool _isLoading = false;

  List<PdfDocument> get documents => _filteredAndSortedDocuments();
  List<PdfDocument> get favoriteDocuments => _allDocuments.where((doc) => doc.isFavorite).toList();
  List<PdfDocument> get recentDocuments {
    final opened = _allDocuments.where((doc) => doc.lastOpened != null).toList();
    opened.sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));
    return opened.take(5).toList();
  }

  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isAscending => _isAscending;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  LibraryProvider() {
    _loadViewMode();
    loadDocuments();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isGridView = prefs.getBool('is_grid_view') ?? false;
    notifyListeners();
  }

  Future<void> toggleViewMode() async {
    _isGridView = !_isGridView;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_grid_view', _isGridView);
  }

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final docs = await DatabaseHelper.instance.getAllDocuments();
      if (docs.isEmpty) {
        // Seed initial sample document
        await _seedSampleDocument();
        _allDocuments = await DatabaseHelper.instance.getAllDocuments();
      } else {
        _allDocuments = docs;
      }
    } catch (e) {
      debugPrint('Error loading documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedSampleDocument() async {
    final sampleFile = await PdfService.copyAssetSamplePdf();
    if (sampleFile != null && await sampleFile.exists()) {
      final length = await sampleFile.length();
      final pageCount = await PdfService.getPdfPageCount(sampleFile.path);

      final doc = PdfDocument(
        id: const Uuid().v4(),
        title: 'DocuVerse Welcome Guide',
        filePath: sampleFile.path,
        fileSize: length,
        pageCount: pageCount,
        dateAdded: DateTime.now(),
        tags: 'Guide, Sample, Start',
        description: 'Welcome guide for DocuVerse PDF (PDFly) application.',
      );

      await DatabaseHelper.instance.insertDocument(doc);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    if (_sortOption == option) {
      _isAscending = !_isAscending;
    } else {
      _sortOption = option;
      _isAscending = (option == SortOption.name);
    }
    notifyListeners();
  }

  List<PdfDocument> _filteredAndSortedDocuments() {
    List<PdfDocument> list = _allDocuments.where((doc) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final titleMatch = doc.title.toLowerCase().contains(q);
      final tagMatch = doc.tags.toLowerCase().contains(q);
      final descMatch = doc.description.toLowerCase().contains(q);
      final pathMatch = doc.filePath.toLowerCase().contains(q);
      return titleMatch || tagMatch || descMatch || pathMatch;
    }).toList();

    list.sort((a, b) {
      int comparison = 0;
      switch (_sortOption) {
        case SortOption.name:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortOption.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
        case SortOption.lastOpened:
          final aTime = a.lastOpened ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.lastOpened ?? DateTime.fromMillisecondsSinceEpoch(0);
          comparison = aTime.compareTo(bTime);
          break;
        case SortOption.fileSize:
          comparison = a.fileSize.compareTo(b.fileSize);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    return list;
  }

  Future<PdfDocument?> importDocumentFromPicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        final savedFile = await StorageService.importFileToAppStorage(pickedFile);
        final length = await savedFile.length();
        final pageCount = await PdfService.getPdfPageCount(savedFile.path);

        final doc = PdfDocument(
          id: const Uuid().v4(),
          title: p.basenameWithoutExtension(savedFile.path),
          filePath: savedFile.path,
          fileSize: length,
          pageCount: pageCount,
          dateAdded: DateTime.now(),
        );

        await DatabaseHelper.instance.insertDocument(doc);
        await loadDocuments();
        return doc;
      }
    } catch (e) {
      debugPrint('Error importing document: $e');
    }
    return null;
  }

  Future<void> addDocument(PdfDocument doc) async {
    await DatabaseHelper.instance.insertDocument(doc);
    await loadDocuments();
  }

  Future<void> updateDocument(PdfDocument doc) async {
    await DatabaseHelper.instance.updateDocument(doc);
    await loadDocuments();
  }

  Future<void> toggleFavorite(PdfDocument doc) async {
    final updated = doc.copyWith(isFavorite: !doc.isFavorite);
    await DatabaseHelper.instance.toggleFavorite(doc.id, updated.isFavorite);
    await loadDocuments();
  }

  Future<void> updateReadingProgress(String docId, int page, int totalPages) async {
    final index = _allDocuments.indexWhere((d) => d.id == docId);
    if (index != -1) {
      final now = DateTime.now();
      final doc = _allDocuments[index];
      
      await DatabaseHelper.instance.updateReadingProgress(docId, page, now);

      // Add to reading history table
      final history = HistoryEntry(
        id: const Uuid().v4(),
        docId: docId,
        docTitle: doc.title,
        docPath: doc.filePath,
        lastReadPage: page,
        totalPages: totalPages > 0 ? totalPages : doc.pageCount,
        timestamp: now,
      );
      await DatabaseHelper.instance.recordHistory(history);

      await loadDocuments();
    }
  }

  Future<void> deleteDocument(String docId, {required bool deleteFromStorage}) async {
    final index = _allDocuments.indexWhere((d) => d.id == docId);
    if (index != -1) {
      final doc = _allDocuments[index];
      await DatabaseHelper.instance.deleteDocument(docId);
      
      if (deleteFromStorage) {
        await StorageService.safeDeleteFile(doc.filePath);
      }
      
      await loadDocuments();
    }
  }
}
