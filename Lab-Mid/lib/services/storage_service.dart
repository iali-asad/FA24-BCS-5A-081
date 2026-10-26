import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  /// Format byte size into human readable string
  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var index = 0;
    
    double numBytes = bytes.toDouble();
    while (numBytes >= 1024 && index < suffixes.length - 1) {
      numBytes /= 1024;
      index++;
    }

    return '${numBytes.toStringAsFixed(index == 0 ? 0 : decimals)} ${suffixes[index]}';
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  /// Format relative time (e.g., "5 mins ago", "Yesterday")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Copy imported file to app's internal documents folder
  static Future<File> importFileToAppStorage(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfsDir = Directory(p.join(appDir.path, 'pdfs'));
    if (!await pdfsDir.exists()) {
      await pdfsDir.create(recursive: true);
    }

    final filename = p.basename(sourceFile.path);
    final targetPath = p.join(pdfsDir.path, filename);
    
    var destination = File(targetPath);
    if (await destination.exists()) {
      final nameWithoutExt = p.basenameWithoutExtension(filename);
      final ext = p.extension(filename);
      final newName = '${nameWithoutExt}_${DateTime.now().millisecondsSinceEpoch}$ext';
      destination = File(p.join(pdfsDir.path, newName));
    }

    return await sourceFile.copy(destination.path);
  }

  /// Safely delete a file from disk
  static Future<bool> safeDeleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      // Ignore error if permissions prevent delete
    }
    return false;
  }
}
