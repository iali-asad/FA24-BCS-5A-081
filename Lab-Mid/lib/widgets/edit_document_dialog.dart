import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';

class EditDocumentDialog extends StatefulWidget {
  final PdfDocument document;

  const EditDocumentDialog({super.key, required this.document});

  @override
  State<EditDocumentDialog> createState() => _EditDocumentDialogState();
}

class _EditDocumentDialogState extends State<EditDocumentDialog> {
  late TextEditingController _titleController;
  late TextEditingController _tagsController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _tagsController = TextEditingController(text: widget.document.tags);
    _descController = TextEditingController(text: widget.document.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Document Info'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Document Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'Work, Report, Personal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final title = _titleController.text.trim();
            if (title.isEmpty) return;

            final updated = widget.document.copyWith(
              title: title,
              tags: _tagsController.text.trim(),
              description: _descController.text.trim(),
            );

            final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
            await libraryProvider.updateDocument(updated);

            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document info updated successfully')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
