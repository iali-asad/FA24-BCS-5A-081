import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';
import '../widgets/document_card.dart';
import '../widgets/document_details_dialog.dart';
import '../widgets/edit_document_dialog.dart';
import 'pdf_reader_screen.dart';

class HomeLibraryScreen extends StatefulWidget {
  final Function(int tabIndex) onNavigateTab;

  const HomeLibraryScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeLibraryScreen> createState() => _HomeLibraryScreenState();
}

class _HomeLibraryScreenState extends State<HomeLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReader(PdfDocument doc, {int initialPage = 1}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfReaderScreen(document: doc, initialPage: initialPage),
      ),
    );
  }

  void _showDeleteConfirmation(PdfDocument doc) {
    bool deleteFromStorage = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Document'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to remove "${doc.title}" from your library?'),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Also delete file from device storage'),
                  subtitle: const Text('This will permanently delete the original PDF file.'),
                  value: deleteFromStorage,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) {
                    setState(() {
                      deleteFromStorage = val ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final provider = Provider.of<LibraryProvider>(dialogContext, listen: false);
                  await provider.deleteDocument(doc.id, deleteFromStorage: deleteFromStorage);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document deleted')),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final theme = Theme.of(context);
    final docs = libraryProvider.documents;
    final recentDocs = libraryProvider.recentDocuments;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'DocuVerse PDF',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(libraryProvider.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: libraryProvider.isGridView ? 'List View' : 'Grid View',
            onPressed: () => libraryProvider.toggleViewMode(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => libraryProvider.loadDocuments(),
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => libraryProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search filename, tags, or description...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              libraryProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildQuickAction(
                          context,
                          icon: Icons.file_upload_outlined,
                          label: 'Import PDF',
                          color: Colors.indigo,
                          onTap: () async {
                            final doc = await libraryProvider.importDocumentFromPicker();
                            if (doc != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Imported "${doc.title}"')),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildQuickAction(
                          context,
                          icon: Icons.document_scanner_outlined,
                          label: 'Scan Doc',
                          color: Colors.teal,
                          onTap: () => widget.onNavigateTab(2),
                        ),
                        const SizedBox(width: 10),
                        _buildQuickAction(
                          context,
                          icon: Icons.transform_rounded,
                          label: 'Tools & Utilities',
                          color: Colors.deepOrange,
                          onTap: () => widget.onNavigateTab(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Recently Opened Carousel
            if (recentDocs.isNotEmpty && _searchController.text.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recently Opened',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigateTab(3),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: recentDocs.length,
                    itemBuilder: (context, index) {
                      final doc = recentDocs[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () => _openReader(doc),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary, size: 20),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          doc.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Page ${doc.lastReadPage} of ${doc.pageCount}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: doc.pageCount > 0 ? (doc.lastReadPage / doc.pageCount) : 0,
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],

            // Sorting Bar & Library Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Documents (${docs.length})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    PopupMenuButton<SortOption>(
                      child: Chip(
                        avatar: Icon(
                          libraryProvider.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                        ),
                        label: Text(_getSortLabel(libraryProvider.sortOption)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSelected: (option) => libraryProvider.setSortOption(option),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: SortOption.dateAdded, child: Text('Sort by Date Added')),
                        const PopupMenuItem(value: SortOption.name, child: Text('Sort by Name')),
                        const PopupMenuItem(value: SortOption.lastOpened, child: Text('Sort by Last Opened')),
                        const PopupMenuItem(value: SortOption.fileSize, child: Text('Sort by File Size')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Document List or Grid
            if (libraryProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (docs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No documents match "${_searchController.text}"'
                              : 'Your PDF Library is Empty',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Import PDFs from storage or scan physical documents with your camera.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => libraryProvider.importDocumentFromPicker(),
                          icon: const Icon(Icons.add),
                          label: const Text('Import PDF File'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (libraryProvider.isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = docs[index];
                      return DocumentCard(
                        document: doc,
                        isGrid: true,
                        onTap: () => _openReader(doc),
                        onDetails: () => showDialog(
                          context: context,
                          builder: (context) => DocumentDetailsDialog(document: doc),
                        ),
                        onEdit: () => showDialog(
                          context: context,
                          builder: (context) => EditDocumentDialog(document: doc),
                        ),
                        onDelete: () => _showDeleteConfirmation(doc),
                      );
                    },
                    childCount: docs.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = docs[index];
                    return DocumentCard(
                      document: doc,
                      isGrid: false,
                      onTap: () => _openReader(doc),
                      onDetails: () => showDialog(
                        context: context,
                        builder: (context) => DocumentDetailsDialog(document: doc),
                      ),
                      onEdit: () => showDialog(
                        context: context,
                        builder: (context) => EditDocumentDialog(document: doc),
                      ),
                      onDelete: () => _showDeleteConfirmation(doc),
                    );
                  },
                  childCount: docs.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => libraryProvider.importDocumentFromPicker(),
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: const Text('Import PDF'),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.name:
        return 'Name';
      case SortOption.lastOpened:
        return 'Last Opened';
      case SortOption.fileSize:
        return 'File Size';
    }
  }
}
