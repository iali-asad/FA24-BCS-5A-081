import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';
import '../services/pdf_service.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isConverting = false;

  Future<void> _convertImagesToPdf() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 95);
      if (images.isEmpty) return;

      final titleController = TextEditingController(text: 'Image_Collection_${DateTime.now().millisecondsSinceEpoch ~/ 1000}');
      final title = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Convert Images to PDF'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'New PDF Title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(titleController.text.trim()),
              child: const Text('Convert'),
            ),
          ],
        ),
      );

      if (title != null && title.isNotEmpty && mounted) {
        setState(() {
          _isConverting = true;
        });

        final imageFiles = images.map((x) => File(x.path)).toList();
        final pdfFile = await PdfService.createPdfFromImages(
          imageFiles: imageFiles,
          outputFilename: title,
          pageFormat: PdfPageFormat.a4,
        );

        final length = await pdfFile.length();
        final doc = PdfDocument(
          id: const Uuid().v4(),
          title: title,
          filePath: pdfFile.path,
          fileSize: length,
          pageCount: imageFiles.length,
          dateAdded: DateTime.now(),
          tags: 'Converted, Images',
          description: 'PDF converted from ${imageFiles.length} images.',
        );

        if (!mounted) return;
        final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
        await libraryProvider.addDocument(doc);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully created PDF "$title" with ${imageFiles.length} pages!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting images: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  Future<void> _sharePdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await Share.shareXFiles([XFile(path)], text: 'Shared via DocuVerse PDF (PDFly)');
      }
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Utilities & Tools', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isConverting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Converting images to high-quality PDF...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildToolCard(
                  context,
                  title: 'Image to PDF Converter',
                  description: 'Select multiple photos or images from gallery and merge them into a single PDF document.',
                  icon: Icons.collections_bookmark_rounded,
                  color: Colors.blue,
                  onTap: _convertImagesToPdf,
                ),
                const SizedBox(height: 12),
                _buildToolCard(
                  context,
                  title: 'Share & Export PDF',
                  description: 'Select any PDF file from device storage and share it with other apps or contacts.',
                  icon: Icons.share_rounded,
                  color: Colors.purple,
                  onTap: _sharePdfFile,
                ),
                const SizedBox(height: 12),
                _buildToolCard(
                  context,
                  title: 'Document Scanner',
                  description: 'Use your camera to scan paper documents and convert them into clean PDFs.',
                  icon: Icons.document_scanner_rounded,
                  color: Colors.teal,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Use the Scanner tab in the bottom bar for document scanning!')),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
