import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/bookmark.dart';
import '../providers/library_provider.dart';
import '../services/storage_service.dart';
import '../widgets/document_card.dart';
import '../widgets/document_details_dialog.dart';
import '../widgets/edit_document_dialog.dart';
import 'pdf_reader_screen.dart';

class FavoritesBookmarksScreen extends StatefulWidget {
  const FavoritesBookmarksScreen({super.key});

  @override
  State<FavoritesBookmarksScreen> createState() => _FavoritesBookmarksScreenState();
}

class _FavoritesBookmarksScreenState extends State<FavoritesBookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Bookmark> _bookmarks = [];
  bool _isLoadingBookmarks = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoadingBookmarks = true;
    });
    try {
      final list = await DatabaseHelper.instance.getAllBookmarks();
      setState(() {
        _bookmarks = list;
      });
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    } finally {
      setState(() {
        _isLoadingBookmarks = false;
      });
    }
  }

  Future<void> _deleteBookmark(String id) async {
    await DatabaseHelper.instance.deleteBookmark(id);
    await _loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed')),
      );
    }
  }

  void _openReaderForBookmark(Bookmark bookmark) async {
    final doc = await DatabaseHelper.instance.getDocumentById(bookmark.docId);
    if (doc != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfReaderScreen(document: doc, initialPage: bookmark.pageNumber),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document no longer available in library')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final theme = Theme.of(context);
    final favoriteDocs = libraryProvider.favoriteDocuments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites & Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.star_rounded),
              text: 'Favorites (${favoriteDocs.length})',
            ),
            Tab(
              icon: const Icon(Icons.bookmark_rounded),
              text: 'Bookmarks (${_bookmarks.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Favorites
          favoriteDocs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_outline_rounded, size: 80, color: Colors.amber.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'No Favorite Documents',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the star icon on any PDF in your library to add it to your favorites list.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: favoriteDocs.length,
                  itemBuilder: (context, index) {
                    final doc = favoriteDocs[index];
                    return DocumentCard(
                      document: doc,
                      isGrid: false,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PdfReaderScreen(document: doc),
                        ),
                      ),
                      onDetails: () => showDialog(
                        context: context,
                        builder: (context) => DocumentDetailsDialog(document: doc),
                      ),
                      onEdit: () => showDialog(
                        context: context,
                        builder: (context) => EditDocumentDialog(document: doc),
                      ),
                      onDelete: () async {
                        await libraryProvider.deleteDocument(doc.id, deleteFromStorage: false);
                      },
                    );
                  },
                ),

          // Tab 2: Bookmarks
          _isLoadingBookmarks
              ? const Center(child: CircularProgressIndicator())
              : _bookmarks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              'No Saved Bookmarks',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'While reading a PDF, tap the bookmark button in the top bar to save individual pages.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookmarks,
                      child: ListView.builder(
                        itemCount: _bookmarks.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final bookmark = _bookmarks[index];
                          return Dismissible(
                            key: Key(bookmark.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) => _deleteBookmark(bookmark.id),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                onTap: () => _openReaderForBookmark(bookmark),
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(
                                    '${bookmark.pageNumber}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  bookmark.docTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (bookmark.note.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Note: ${bookmark.note}',
                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                    const SizedBox(height: 2),
                                    Text(
                                      'Saved ${StorageService.formatRelativeDate(bookmark.timestamp)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteBookmark(bookmark.id),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
