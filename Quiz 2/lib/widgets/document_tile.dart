import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_document.dart';
import '../theme/app_theme.dart';
import '../utils/file_helper.dart';

class DocumentTile extends StatelessWidget {
  final PatientDocument document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DocumentTile({
    super.key,
    required this.document,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = document.fileType == 'image';
    final fileExists = FileHelper.hasValidImage(document.filePath);
    final fileColor = FileHelper.getFileColor(document.fileType);
    final fileIcon = FileHelper.getFileIcon(document.fileType);
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(document.uploadedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: fileColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            image: (isImage && fileExists)
                ? DecorationImage(
                    image: FileHelper.getImageProvider(document.filePath),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (!isImage || !fileExists)
              ? Icon(fileIcon, color: fileColor, size: 24)
              : null,
        ),
        title: Text(
          document.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${FileHelper.formatBytes(document.fileSize)} • $dateStr',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppTheme.primaryTeal),
              tooltip: 'Preview / Open',
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.statusCritical),
              tooltip: 'Delete document',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
