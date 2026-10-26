import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';
import '../services/storage_service.dart';

class DocumentCard extends StatelessWidget {
  final PdfDocument document;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    required this.isGrid,
    required this.onTap,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final theme = Theme.of(context);

    final double progress = (document.pageCount > 0)
        ? (document.lastReadPage / document.pageCount).clamp(0.0, 1.0)
        : 0.0;

    if (isGrid) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Thumbnail area
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 52,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: IconButton(
                          icon: Icon(
                            document.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: document.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => libraryProvider.toggleFavorite(document),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                      if (document.pageCount > 0)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${document.pageCount} pgs',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Reading progress bar
              if (progress > 0)
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              // Body info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          StorageService.formatBytes(document.fileSize),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurfaceVariant),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (value) {
                            if (value == 'details') onDetails();
                            if (value == 'edit') onEdit();
                            if (value == 'delete') onDelete();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text('Metadata Details'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit & Tags'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // List Layout
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.picture_as_pdf_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          document.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  StorageService.formatBytes(document.fileSize),
                  style: theme.textTheme.bodySmall,
                ),
                if (document.pageCount > 0) ...[
                  const Text(' • '),
                  Text('${document.pageCount} pages', style: theme.textTheme.bodySmall),
                ],
                if (document.lastReadPage > 1) ...[
                  const Text(' • '),
                  Text('Pg ${document.lastReadPage}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                ],
              ],
            ),
            if (document.tags.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Tags: ${document.tags}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            if (progress > 0) ...[
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                document.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: document.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () => libraryProvider.toggleFavorite(document),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'details') onDetails();
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Info'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
