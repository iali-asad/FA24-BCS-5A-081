import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../models/patient_document.dart';
import '../theme/app_theme.dart';
import '../utils/file_helper.dart';

class DocumentViewerScreen extends StatelessWidget {
  final PatientDocument document;

  const DocumentViewerScreen({super.key, required this.document});

  Future<void> _openExternally(BuildContext context) async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document preview is displayed directly on screen.'),
            backgroundColor: AppTheme.primaryTeal,
          ),
        );
        return;
      }
      final result = await OpenFilex.open(document.filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exists = FileHelper.hasValidImage(document.filePath);
    final isImage = document.fileType == 'image';
    final dateStr = DateFormat('MMMM d, yyyy • h:mm a').format(document.uploadedAt);

    return Scaffold(
      backgroundColor: isImage ? Colors.black : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isImage ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isImage ? Colors.white : AppTheme.textPrimary,
        ),
        title: Text(
          document.title,
          style: TextStyle(
            color: isImage ? Colors.white : AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.open_in_new_rounded,
              color: isImage ? Colors.white : AppTheme.primaryTeal,
            ),
            tooltip: 'Open in External App',
            onPressed: () => _openExternally(context),
          ),
        ],
      ),
      body: SafeArea(
        child: exists
          ? (isImage
              ? Column(
                  children: [
                    Expanded(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: Image(
                            image: FileHelper.getImageProvider(document.filePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Center(
                              child: Text(
                                'Error loading image file',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: Colors.black87,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  document.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${FileHelper.formatBytes(document.fileSize)} • $dateStr',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openExternally(context),
                            icon: const Icon(Icons.share_outlined, size: 16),
                            label: const Text('Open'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: FileHelper.getFileColor(document.fileType).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FileHelper.getFileIcon(document.fileType),
                                size: 54,
                                color: FileHelper.getFileColor(document.fileType),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              document.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type: ${document.fileType.toUpperCase()} • Size: ${FileHelper.formatBytes(document.fileSize)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded on $dateStr',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.file_open_outlined),
                                label: const Text('Open File in Default Viewer'),
                                onPressed: () => _openExternally(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image_outlined, size: 60, color: AppTheme.statusCritical),
                  const SizedBox(height: 16),
                  const Text(
                    'File not found on device',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    document.filePath,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
