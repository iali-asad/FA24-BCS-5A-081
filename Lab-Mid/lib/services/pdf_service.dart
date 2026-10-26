import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  /// Extract page count from a PDF file using basic parser or fallback
  static Future<int> getPdfPageCount(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return 1;
      final bytes = await file.readAsBytes();
      
      final String content = String.fromCharCodes(bytes.take(100000));
      final regExp = RegExp(r'/Type\s*/Page\b');
      final matches = regExp.allMatches(content);
      if (matches.isNotEmpty) {
        return matches.length;
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  /// Create a PDF document from a list of image file paths (for Scanner & Image-to-PDF)
  static Future<File> createPdfFromImages({
    required List<File> imageFiles,
    required String outputFilename,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    for (final imgFile in imageFiles) {
      if (await imgFile.exists()) {
        final imageBytes = await imgFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
              );
            },
          ),
        );
      }
    }

    final appDir = await getApplicationDocumentsDirectory();
    final pdfsDir = Directory(p.join(appDir.path, 'pdfs'));
    if (!await pdfsDir.exists()) {
      await pdfsDir.create(recursive: true);
    }

    final sanitizedTitle = outputFilename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName = sanitizedTitle.endsWith('.pdf') ? sanitizedTitle : '$sanitizedTitle.pdf';
    final targetPath = p.join(pdfsDir.path, fileName);

    final outputFile = File(targetPath);
    await outputFile.writeAsBytes(await pdf.save());
    return outputFile;
  }

  /// Seed initial asset PDF into local app storage
  static Future<File?> copyAssetSamplePdf() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pdfsDir = Directory(p.join(appDir.path, 'pdfs'));
      if (!await pdfsDir.exists()) {
        await pdfsDir.create(recursive: true);
      }

      final targetPath = p.join(pdfsDir.path, 'DocuVerse_Welcome_Guide.pdf');
      final targetFile = File(targetPath);

      if (!await targetFile.exists()) {
        final byteData = await rootBundle.load('assets/sample.pdf');
        final buffer = byteData.buffer;
        await targetFile.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      return targetFile;
    } catch (e) {
      return null;
    }
  }
}
