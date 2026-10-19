import 'dart:io' show File, Directory;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String> saveFileLocally(String sourcePath, {String subDir = 'patient_docs'}) async {
    if (kIsWeb) {
      // In Web browsers (e.g. Chrome / Device Simulator), path is an in-memory blob or data URL.
      return sourcePath;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(appDir.path, subDir));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final ext = p.extension(sourcePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(sourcePath)}$ext';
      final targetPath = p.join(targetDir.path, fileName);

      final savedFile = await File(sourcePath).copy(targetPath);
      return savedFile.path;
    } catch (_) {
      // Fallback in case of storage permission or non-standard directory
      return sourcePath;
    }
  }

  static Future<void> deleteFile(String? path) async {
    if (kIsWeb || path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup error
    }
  }

  static bool hasValidImage(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) return true;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  static ImageProvider getImageProvider(String path) {
    if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return '${dBytes.toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String getFileType(String path) {
    final ext = p.extension(path).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(ext) || path.startsWith('blob:')) {
      return 'image';
    } else if (ext == '.pdf') {
      return 'pdf';
    } else if (['.doc', '.docx', '.txt', '.rtf'].contains(ext)) {
      return 'doc';
    }
    return 'other';
  }

  static IconData getFileIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color getFileColor(String fileType) {
    switch (fileType) {
      case 'image':
        return const Color(0xFF0D9488);
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'doc':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }
}
