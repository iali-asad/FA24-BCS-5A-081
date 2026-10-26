import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import 'pdf_reader_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await DatabaseHelper.instance.getReadingHistory();
      setState(() {
        _historyList = list;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Reading History'),
        content: const Text('Are you sure you want to clear your reading history list? This will not delete your actual PDF files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.clearHistory();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading history cleared')),
        );
      }
    }
  }

  void _resumeReading(HistoryEntry entry) async {
    final doc = await DatabaseHelper.instance.getDocumentById(entry.docId);
    if (doc != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfReaderScreen(document: doc, initialPage: entry.lastReadPage),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_historyList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Reading History',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Opened documents and reading positions will be tracked automatically here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _historyList.length,
                    itemBuilder: (context, index) {
                      final entry = _historyList[index];
                      final double progress = (entry.totalPages > 0)
                          ? (entry.lastReadPage / entry.totalPages).clamp(0.0, 1.0)
                          : 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () => _resumeReading(entry),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          title: Text(
                            entry.docTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Page ${entry.lastReadPage} of ${entry.totalPages}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const Text(' • '),
                                  Text(
                                    StorageService.formatRelativeDate(entry.timestamp),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 32),
                            color: theme.colorScheme.primary,
                            tooltip: 'Resume',
                            onPressed: () => _resumeReading(entry),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
