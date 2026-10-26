import 'package:flutter/material.dart';
import '../models/pdf_document.dart';
import '../services/storage_service.dart';

class DocumentDetailsDialog extends StatelessWidget {
  final PdfDocument document;

  const DocumentDetailsDialog({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Document Metadata',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(context, 'Title', document.title),
            _buildDetailRow(context, 'File Path', document.filePath),
            _buildDetailRow(context, 'File Size', StorageService.formatBytes(document.fileSize)),
            _buildDetailRow(context, 'Total Pages', '${document.pageCount}'),
            _buildDetailRow(
              context,
              'Date Added',
              StorageService.formatDate(document.dateAdded),
            ),
            if (document.lastOpened != null)
              _buildDetailRow(
                context,
                'Last Opened',
                StorageService.formatDate(document.lastOpened!),
              ),
            _buildDetailRow(context, 'Last Read Page', '${document.lastReadPage}'),
            if (document.tags.isNotEmpty)
              _buildDetailRow(context, 'Tags', document.tags),
            if (document.description.isNotEmpty)
              _buildDetailRow(context, 'Description', document.description),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: theme.textTheme.bodyMedium,
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }
}
