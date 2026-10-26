import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';
import '../services/pdf_service.dart';

enum ImageFilterMode { original, grayscale, highContrast }

class ScannedPage {
  final String id;
  final File originalFile;
  File processedFile;
  ImageFilterMode filterMode;

  ScannedPage({
    required this.id,
    required this.originalFile,
    required this.processedFile,
    this.filterMode = ImageFilterMode.original,
  });
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<ScannedPage> _pages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  final TextEditingController _pdfTitleController = TextEditingController();

  @override
  void dispose() {
    _pdfTitleController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied. Please enable it in Settings.')),
        );
      }
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo != null) {
        final file = File(photo.path);
        setState(() {
          _pages.add(ScannedPage(
            id: const Uuid().v4(),
            originalFile: file,
            processedFile: file,
          ));
        });
      }
    } catch (e) {
      debugPrint('Error picking camera image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 90);
      if (images.isNotEmpty) {
        setState(() {
          for (var xFile in images) {
            final file = File(xFile.path);
            _pages.add(ScannedPage(
              id: const Uuid().v4(),
              originalFile: file,
              processedFile: file,
            ));
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking gallery images: $e');
    }
  }

  Future<void> _applyFilter(ScannedPage page, ImageFilterMode mode) async {
    if (page.filterMode == mode) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (mode == ImageFilterMode.original) {
        page.processedFile = page.originalFile;
        page.filterMode = mode;
      } else {
        final bytes = await page.originalFile.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          if (mode == ImageFilterMode.grayscale) {
            img.grayscale(decoded);
          } else if (mode == ImageFilterMode.highContrast) {
            img.grayscale(decoded);
            img.contrast(decoded, contrast: 150);
          }

          final tempDir = Directory.systemTemp;
          final targetFile = File('${tempDir.path}/filter_${page.id}.jpg');
          await targetFile.writeAsBytes(img.encodeJpg(decoded, quality: 85));
          page.processedFile = targetFile;
          page.filterMode = mode;
        }
      }
    } catch (e) {
      debugPrint('Error applying filter: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _removePage(int index) {
    setState(() {
      _pages.removeAt(index);
    });
  }

  void _movePage(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, item);
    });
  }

  Future<void> _saveAsPdf() async {
    if (_pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or select at least one page.')),
      );
      return;
    }

    _pdfTitleController.text = 'Scanned_Doc_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Scanned PDF'),
        content: TextField(
          controller: _pdfTitleController,
          decoration: const InputDecoration(
            labelText: 'PDF Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_pdfTitleController.text.trim()),
            child: const Text('Save & Add to Library'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final imageFiles = _pages.map((p) => p.processedFile).toList();
        final pdfFile = await PdfService.createPdfFromImages(
          imageFiles: imageFiles,
          outputFilename: result,
        );

        final length = await pdfFile.length();
        final pageCount = imageFiles.length;

        final newDoc = PdfDocument(
          id: const Uuid().v4(),
          title: result,
          filePath: pdfFile.path,
          fileSize: length,
          pageCount: pageCount,
          dateAdded: DateTime.now(),
          tags: 'Scanned',
          description: 'Multi-page document created using DocuVerse Scanner.',
        );

        final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
        await libraryProvider.addDocument(newDoc);

        setState(() {
          _pages.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved "$result" to PDF Library!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating PDF: $e')),
          );
        }
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_pages.isNotEmpty)
            TextButton.icon(
              onPressed: _isProcessing ? null : _saveAsPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing images and creating PDF...'),
                ],
              ),
            )
          : _pages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Scan Physical Documents',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capture multi-page documents with your camera or select images from your gallery to compile into a PDF.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: _captureFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      child: Row(
                        children: [
                          Text(
                            '${_pages.length} Pages Captured',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _captureFromCamera,
                            icon: const Icon(Icons.add_a_photo, size: 18),
                            label: const Text('Add Camera'),
                          ),
                          TextButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.add_photo_alternate, size: 18),
                            label: const Text('Add Gallery'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _pages.length,
                        onReorder: _movePage,
                        itemBuilder: (context, index) {
                          final page = _pages[index];
                          return Card(
                            key: ValueKey(page.id),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      page.processedFile,
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Page ${index + 1}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 4,
                                          children: [
                                            ChoiceChip(
                                              label: const Text('Color', style: TextStyle(fontSize: 11)),
                                              selected: page.filterMode == ImageFilterMode.original,
                                              onSelected: (_) => _applyFilter(page, ImageFilterMode.original),
                                            ),
                                            ChoiceChip(
                                              label: const Text('Grayscale', style: TextStyle(fontSize: 11)),
                                              selected: page.filterMode == ImageFilterMode.grayscale,
                                              onSelected: (_) => _applyFilter(page, ImageFilterMode.grayscale),
                                            ),
                                            ChoiceChip(
                                              label: const Text('Enhanced', style: TextStyle(fontSize: 11)),
                                              selected: page.filterMode == ImageFilterMode.highContrast,
                                              onSelected: (_) => _applyFilter(page, ImageFilterMode.highContrast),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _removePage(index),
                                  ),
                                  const Icon(Icons.drag_handle, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _saveAsPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text('Compile ${_pages.length} Pages into PDF'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
