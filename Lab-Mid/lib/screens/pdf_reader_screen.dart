import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/bookmark.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';
import '../widgets/document_details_dialog.dart';

class PdfReaderScreen extends StatefulWidget {
  final PdfDocument document;
  final int initialPage;

  const PdfReaderScreen({
    super.key,
    required this.document,
    this.initialPage = 1,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  PDFViewController? _pdfViewController;
  late int _currentPage;
  late int _totalPages;
  bool _isReady = false;
  bool _errorMessage = false;
  bool _isNightMode = false;
  bool _showControls = true;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage > 0 ? widget.initialPage : widget.document.lastReadPage;
    _totalPages = widget.document.pageCount > 0 ? widget.document.pageCount : 1;
    _isFavorite = widget.document.isFavorite;

    final file = File(widget.document.filePath);
    if (!file.existsSync()) {
      _errorMessage = true;
    }
  }

  void _saveProgress() {
    if (_currentPage > 0) {
      final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
      libraryProvider.updateReadingProgress(widget.document.id, _currentPage, _totalPages);
    }
  }

  Future<void> _addBookmark() async {
    final noteController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookmark Page $_currentPage'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Bookmark Note (Optional)',
            hintText: 'Key chapter or reference...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(noteController.text.trim()),
            child: const Text('Save Bookmark'),
          ),
        ],
      ),
    );

    if (result != null) {
      final bookmark = Bookmark(
        id: const Uuid().v4(),
        docId: widget.document.id,
        docTitle: widget.document.title,
        docPath: widget.document.filePath,
        pageNumber: _currentPage,
        timestamp: DateTime.now(),
        note: result,
      );

      await DatabaseHelper.instance.insertBookmark(bookmark);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmarked page $_currentPage')),
        );
      }
    }
  }

  void _jumpToPageDialog() {
    final pageController = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to Page'),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Page Number (1 - $_totalPages)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final pageNum = int.tryParse(pageController.text);
              if (pageNum != null && pageNum >= 1 && pageNum <= _totalPages) {
                _pdfViewController?.setPage(pageNum - 1);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid page (1 - $_totalPages)')),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_errorMessage) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.document.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Unable to open document',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'The PDF file could not be found at path:\n${widget.document.filePath}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Library'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _isNightMode ? Colors.black : theme.colorScheme.surface,
      appBar: _showControls
          ? AppBar(
              title: Text(
                widget.document.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isNightMode ? Icons.light_mode : Icons.dark_mode_outlined,
                  ),
                  tooltip: _isNightMode ? 'Light Mode' : 'Night Invert Mode',
                  onPressed: () {
                    setState(() {
                      _isNightMode = !_isNightMode;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _isFavorite ? Colors.amber : null,
                  ),
                  tooltip: 'Favorite',
                  onPressed: () async {
                    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
                    await libraryProvider.toggleFavorite(widget.document);
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'Add Bookmark',
                  onPressed: _addBookmark,
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share PDF',
                  onPressed: () {
                    Share.shareXFiles([XFile(widget.document.filePath)], text: widget.document.title);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Metadata',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DocumentDetailsDialog(document: widget.document),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: ColorFiltered(
              colorFilter: _isNightMode
                  ? const ColorFilter.matrix([
                      -1, 0, 0, 0, 255,
                      0, -1, 0, 0, 255,
                      0, 0, -1, 0, 255,
                      0, 0, 0, 1, 0,
                    ])
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: PDFView(
                filePath: widget.document.filePath,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: true,
                pageFling: true,
                defaultPage: _currentPage > 0 ? _currentPage - 1 : 0,
                onRender: (pages) {
                  setState(() {
                    _totalPages = pages ?? widget.document.pageCount;
                    _isReady = true;
                  });
                },
                onError: (error) {
                  setState(() {
                    _errorMessage = true;
                  });
                },
                onPageError: (page, error) {
                  debugPrint('Page $page error: $error');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  _pdfViewController = pdfViewController;
                },
                onPageChanged: (int? page, int? total) {
                  if (page != null) {
                    setState(() {
                      _currentPage = page + 1;
                      if (total != null && total > 0) {
                        _totalPages = total;
                      }
                    });
                    _saveProgress();
                  }
                },
              ),
            ),
          ),
          if (!_isReady && !_errorMessage)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_showControls && _isReady)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: theme.colorScheme.surface.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1
                            ? () => _pdfViewController?.setPage(_currentPage - 2)
                            : null,
                      ),
                      InkWell(
                        onTap: _jumpToPageDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              Text(
                                'Page $_currentPage / $_totalPages',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentPage.toDouble().clamp(1.0, _totalPages.toDouble()),
                          min: 1.0,
                          max: _totalPages > 0 ? _totalPages.toDouble() : 1.0,
                          divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                          label: '$_currentPage',
                          onChanged: (double value) {
                            final page = value.toInt();
                            _pdfViewController?.setPage(page - 1);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _totalPages
                            ? () => _pdfViewController?.setPage(_currentPage)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
